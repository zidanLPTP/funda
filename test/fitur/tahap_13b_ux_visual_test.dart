@Timeout(Duration(seconds: 30))
library;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/rute.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/komponen_teks_istilah.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/fitur/belajar/tampilan/layar_tes_awal.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/fitur/tutorial/kontroler/penyedia_tutorial.dart';
import 'package:funda/fitur/tutorial/tampilan/lapisan_tutorial_beranda.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:funda/tema/tema.dart';
import 'package:funda/tema/token.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Pengujian Visual, UX Belajar, Tutorial & Tes Awal (Tahap 13B)', () {
    testWidgets(
      '1. Tutorial Beranda 4 langkah muncul otomatis sekali dan menyimpan tutorial_beranda_selesai ke DB',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaTotalSaldoAktif.overrideWithValue(0),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value(const []),
              ),
            ],
            child: MaterialApp.router(
              theme: TemaFunda.temaTerang,
              routerConfig: ruteFunda,
            ),
          ),
        );
        ruteFunda.go('/');
        await pompaHinggaAda(tester, find.byType(LapisanTutorialBeranda));

        // Langkah 1/4: Ringkasan Keuangan
        expect(find.text('1/4'), findsOneWidget);
        expect(find.text('Ringkasan Keuangan'), findsOneWidget);
        expect(find.text('Lanjut'), findsOneWidget);
        expect(find.text('Lewati'), findsOneWidget);

        // Langkah 2/4: Tab Catatan
        await tester.tap(find.byKey(const Key('tombol_lanjut_tutorial')));
        await tester.pump();
        expect(find.text('2/4'), findsOneWidget);
        expect(find.text('Tab Catatan'), findsOneWidget);

        // Langkah 3/4: Tab Belajar
        await tester.tap(find.byKey(const Key('tombol_lanjut_tutorial')));
        await tester.pump();
        expect(find.text('3/4'), findsOneWidget);
        expect(find.text('Tab Belajar'), findsOneWidget);

        // Langkah 4/4: Tab Lainnya (tombol menjadi Mulai Pakai)
        await tester.tap(find.byKey(const Key('tombol_lanjut_tutorial')));
        await tester.pump();
        expect(find.text('4/4'), findsOneWidget);
        expect(find.text('Tab Lainnya'), findsOneWidget);
        expect(find.text('Mulai Pakai'), findsOneWidget);

        // Selesaikan tutorial
        await tester.tap(find.byKey(const Key('tombol_lanjut_tutorial')));
        await tester.pump();
        expect(find.byType(LapisanTutorialBeranda), findsNothing);

        // Verifikasi nilai tersimpan di tabel_pengaturan
        final status = await db.bacaPengaturan(kunciTutorialBerandaSelesai);
        expect(status, equals('true'));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. Pengaturan menampilkan menu Ulangi Tutorial Aplikasi dan Perbarui Profil Keuangan',
      (tester) async {
        await db.simpanPengaturan(kunciTutorialBerandaSelesai, 'true');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarPengaturan(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Ulangi Tutorial Aplikasi'), findsOneWidget);
        expect(find.text('Perbarui Profil Keuangan'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Cek Paham di Pemutar Pelajaran tampil 1 soal per halaman, bebas badge tahap, dan teks justify',
      (tester) async {
        final pel = PelajaranKonten(
          id: 'pel_uji_13b',
          modulId: 'anggaran_arus_kas',
          judul: 'Pelajaran Uji Justify',
          durasiMenit: 4,
          status: 'draf',
          gerbang: const [],
          pemantik: 'Ini teks pemantik yang harus rata kanan-kiri.',
          kartu: const [
            KartuPelajaranKonten(
              judul: 'Kartu Inti',
              isi: 'Memahami {{arus kas}} sangat membantu pengelolaan uang.',
            ),
          ],
          cekPaham: const [
            CekPahamKonten(
              tanya: 'Pertanyaan Cek Pertama?',
              pilihan: ['Benar Pertama', 'Salah Pertama'],
              benar: 0,
              penjelasan: 'Penjelasan soal pertama.',
            ),
            CekPahamKonten(
              tanya: 'Pertanyaan Cek Kedua?',
              pilihan: ['Salah Kedua', 'Benar Kedua'],
              benar: 1,
              penjelasan: 'Penjelasan soal kedua.',
            ),
          ],
          misi: const MisiKonten(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 1,
            judul: 'Misi Catat Transaksi',
            deskripsi: 'Catat transaksi pertamamu.',
            perkiraanMenit: 2,
          ),
        );

        final kamus = {
          'arus kas': const IstilahKamus(
            istilah: 'Arus Kas',
            arti: 'Aliran uang masuk dan keluar.',
            contohRupiah: 'Masuk Rp3.000.000, keluar Rp2.000.000.',
          ),
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaFotoData.overrideWith(
                (ref) => Future.value(FotoDataPengguna.kosong()),
              ),
              penyediaKamus.overrideWith((ref) => Future.value(kamus)),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: LayarPemutarPelajaran(
                modulId: 'anggaran_arus_kas',
                pelajaranId: pel.id,
                pelajaranOverride: pel,
              ),
            ),
          ),
        );
        await tester.pump();

        // Langkah 0 (Pemantik): bebas badge tahap 'Pemantik' dan rata kiri
        expect(find.text('Pemantik'), findsNothing);
        expect(find.text('Pelajaran Uji Justify'), findsOneWidget);
        final widgetPemantik = tester.widget<Text>(
          find.text('Ini teks pemantik yang harus rata kanan-kiri.'),
        );
        expect(widgetPemantik.textAlign, equals(TextAlign.start));

        // Langkah 1 (Kartu Inti): teks istilah rata kiri + popup kamus rata kiri
        await tester.tap(find.byKey(const Key('tombol_lanjut')));
        await pompaHinggaAda(tester, find.byType(TeksDenganIstilah));
        // Tunggu rebuild provider FutureProvider penyediaKamus agar istilahObj terisi
        await tester.pump();
        await tester.pump();
        expect(find.text('Konsep Inti (1/1)'), findsNothing);
        final richText = tester.widget<RichText>(
          find
              .descendant(
                of: find.byType(TeksDenganIstilah),
                matching: find.byType(RichText),
              )
              .first,
        );
        expect(richText.textAlign, equals(TextAlign.start));

        // Ketuk istilah di kartu untuk cek popup kamus
        TapGestureRecognizer? pengenalKetuk;
        (richText.text as TextSpan).visitChildren((child) {
          if (child is TextSpan &&
              (child.text?.toLowerCase().contains('arus kas') ?? false)) {
            pengenalKetuk = child.recognizer as TapGestureRecognizer?;
            return false;
          }
          return true;
        });
        expect(pengenalKetuk, isNotNull);
        pengenalKetuk!.onTap?.call();
        await pompaHinggaAda(tester, find.byType(AlertDialog));
        final artiKamus = tester.widget<Text>(
          find.text('Aliran uang masuk dan keluar.'),
        );
        expect(artiKamus.textAlign, equals(TextAlign.start));
        await tester.tap(find.text('Mengerti'));
        await tester.pump();

        // Langkah 2 (Cek Paham Soal 1/2): hanya soal 1 yang tampil
        await tester.tap(find.byKey(const Key('tombol_lanjut')));
        await tester.pump();
        expect(find.text('Pertanyaan 1 dari 2'), findsOneWidget);
        expect(find.text('Pertanyaan Cek Pertama?'), findsOneWidget);
        expect(find.text('Pertanyaan Cek Kedua?'), findsNothing);

        // Sebelum dijawab, tombol lanjut nonaktif
        expect(
          tester
              .widget<TombolFunda>(find.byKey(const Key('tombol_lanjut')))
              .padaTekan,
          isNull,
        );

        // Pilih jawaban soal 1 -> umpan balik tampil, tombol lanjut aktif
        await tester.tap(find.text('Benar Pertama'));
        await tester.pump();
        expect(find.text('Penjelasan soal pertama.'), findsOneWidget);

        // Langkah 3 (Cek Paham Soal 2/2): hanya soal 2 yang tampil
        await tester.tap(find.byKey(const Key('tombol_lanjut')));
        await tester.pump();
        expect(find.text('Pertanyaan 2 dari 2'), findsOneWidget);
        expect(find.text('Pertanyaan Cek Kedua?'), findsOneWidget);
        expect(find.text('Pertanyaan Cek Pertama?'), findsNothing);

        // Jawab soal 2 -> masuk ke Misi
        await tester.tap(find.text('Benar Kedua'));
        await tester.pump();
        await tester.tap(find.byKey(const Key('tombol_lanjut')));
        await tester.pump();
        expect(find.text('Misi Catat Transaksi'), findsOneWidget);
        expect(find.text('Misi Praktik Nyata'), findsNothing);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '4. Tab Belajar: Modul 0 ringkas setelah profil tersimpan, bebas banjir gembok & maks 1 kartu rekomendasi',
      (tester) async {
        // Simpan profil ke DB sehingga Modul 0 selesai
        await db
            .into(db.tabelProfilKeuangan)
            .insert(
              TabelProfilKeuanganCompanion.insert(
                id: const drift.Value(1),
                punyaPenghasilan: 'rutin',
                punyaUtang: 'tidak',
                danaDarurat: 'belum',
                menabung: 'rutin',
                investasi: 'belum',
                mencatatKeuangan: 'rutin',
                diisiPada: DateTime.now(),
                diperbaruiPada: DateTime.now(),
              ),
            );

        const modul0 = ModulKonten(
          id: 'mulai_tes_awal',
          judul: 'Mulai & Tes Awal',
          tingkat: 'pemula',
          urutan: 0,
          deskripsiSingkat: 'Kenali profilmu.',
          tersedia: true,
          gerbang: [],
          daftarPelajaran: [],
          kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
        );
        const modul3 = ModulKonten(
          id: 'dana_darurat',
          judul: 'Dana Darurat',
          tingkat: 'pemula',
          urutan: 3,
          deskripsiSingkat: 'Siapkan bantalan.',
          tersedia: true,
          gerbang: [],
          daftarPelajaran: ['dana_darurat_3_1', 'dana_darurat_3_2'],
          kuis: KuisKonten(jumlahSoal: 0, bankSoal: []),
        );
        const pel31 = PelajaranKonten(
          id: 'dana_darurat_3_1',
          modulId: 'dana_darurat',
          judul: 'Pelajaran Darurat 1',
          durasiMenit: 3,
          status: 'draf',
          gerbang: [],
          pemantik: 'P',
          kartu: [],
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 1,
            judul: 'M1',
            deskripsi: 'D1',
            perkiraanMenit: 2,
          ),
        );
        const pel32 = PelajaranKonten(
          id: 'dana_darurat_3_2',
          modulId: 'dana_darurat',
          judul: 'Pelajaran Darurat 2',
          durasiMenit: 3,
          status: 'draf',
          gerbang: [],
          pemantik: 'P',
          kartu: [],
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 1,
            judul: 'M2',
            deskripsi: 'D2',
            perkiraanMenit: 2,
          ),
        );

        final peta = [
          const ItemPetaModul(
            modul: modul0,
            statusModul: HasilStatusBelajar(
              status: StatusBelajar.terbuka,
              apaYangKurang: [],
            ),
            daftarPelajaran: [],
          ),
          const ItemPetaModul(
            modul: modul3,
            statusModul: HasilStatusBelajar(
              status: StatusBelajar.terkunci,
              apaYangKurang: ['Selesaikan syarat Modul 3.'],
            ),
            daftarPelajaran: [
              (
                pel31,
                HasilStatusBelajar(
                  status: StatusBelajar.terkunci,
                  apaYangKurang: ['Selesaikan syarat Modul 3.'],
                ),
              ),
              (
                pel32,
                HasilStatusBelajar(
                  status: StatusBelajar.terkunci,
                  apaYangKurang: ['Selesaikan syarat Modul 3.'],
                ),
              ),
            ],
          ),
        ];

        final rekList = [
          const InfoRekomendasiModul(
            modul: modul3,
            judulAlasan: 'Bantalan Keuangan',
            deskripsiAlasan: 'Mulai siapkan dana darurat.',
            statusModul: HasilStatusBelajar(
              status: StatusBelajar.terkunci,
              apaYangKurang: ['Selesaikan syarat Modul 3.'],
            ),
          ),
          const InfoRekomendasiModul(
            modul: modul0,
            judulAlasan: 'Alasan Kedua',
            deskripsiAlasan: 'Tidak boleh tampil bertumpuk.',
            statusModul: HasilStatusBelajar(
              status: StatusBelajar.terbuka,
              apaYangKurang: [],
            ),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaPetaBelajar.overrideWith((ref) => Future.value(peta)),
              penyediaDaftarRekomendasiModul.overrideWith(
                (ref) => Future.value(rekList),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarBelajar(),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_modul_0_tersimpan')),
        );

        // Modul 0 tidak membuka tes awal ulang dan bertanda profil tersimpan
        expect(find.text('Buka Tes Awal'), findsNothing);
        expect(find.text('Profil keuanganmu sudah tersimpan'), findsOneWidget);

        // Hanya maksimal 1 kartu sorotan rekomendasi, tanpa badge 'Saran untuk kamu'
        expect(
          find.byKey(const Key('kartu_sorotan_rekomendasi')),
          findsOneWidget,
        );
        expect(find.text('Saran untuk kamu'), findsNothing);
        expect(find.text('Tidak boleh tampil bertumpuk.'), findsNothing);

        // Ketuk modul Dana Darurat untuk memeriksa detail modul di lembar bawah
        await tester.ensureVisible(find.text('Dana Darurat').last);
        await tester.pump();
        await tester.tap(find.text('Dana Darurat').last);
        await pompaHinggaAda(tester, find.text('Selesaikan syarat Modul 3.'));

        // Bebas ikon gembok di baris pelajaran
        expect(find.byIcon(LucideIcons.lock), findsNothing);
        // Syarat muncul 1x di level modul (bukan 2x+ di tiap baris)
        expect(find.text('Selesaikan syarat Modul 3.'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '5. Skala teks 2.0 pada 360x640 bebas overflow di Beranda, Tutorial, dan Pengaturan',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Uji Beranda pada skala teks 2.0
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaTotalSaldoAktif.overrideWithValue(2500000),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(
                  totalMasuk: 5000000,
                  totalKeluar: 2500000,
                  selisih: 2500000,
                ),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value([
                  EntitasDompet(
                    id: 'd1',
                    nama: 'Dompet Utama',
                    jenis: 'tunai',
                    ikon: 'wallet',
                    warna: 'tintHijau',
                    saldoAwalRupiah: 2500000,
                    urutan: 0,
                    diarsipkan: false,
                    dibuatPada: DateTime.now(),
                  ),
                ]),
              ),
              penyediaSisaAnggaranBulanIni.overrideWith(
                (ref) => Future.value(1000000),
              ),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarBeranda(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);

        // Uji LapisanTutorialBeranda pada skala teks 2.0
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [penyediaTanpaAnimasi.overrideWithValue(true)],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
                disableAnimations: true,
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: Scaffold(
                  body: Stack(
                    children: [
                      LapisanTutorialBeranda(
                        daftarLangkah: const [
                          ItemSorotanTutorial(
                            judul: 'Ringkasan Keuangan',
                            deskripsi:
                                'Pantau arus kas masuk & keluar serta total saldo seluruh dompetmu.',
                            ikon: LucideIcons.wallet,
                            warnaAksen: WarnaFunda.utama,
                            warnaLatarIkon: WarnaFunda.tintHijau,
                          ),
                        ],
                        padaSelesai: () {},
                        padaLewati: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Ringkasan Keuangan'), findsOneWidget);

        await bongkarWidget(tester);

        // Uji LayarPengaturan pada skala teks 2.0
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarPengaturan(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Ulangi Tutorial Aplikasi'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Ulangi Tutorial Aplikasi'), findsOneWidget);

        await bongkarWidget(tester);

        // Uji LayarTesAwal pada skala teks 2.0 (pembuka -> profil -> transisi)
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarTesAwal(),
              ),
            ),
          ),
        );
        await pompaHinggaAda(tester, find.text('Mulai Sekarang'));
        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );
  });
}
