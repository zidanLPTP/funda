@Timeout(Duration(seconds: 30))
library;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/konfigurasi_debug.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/komponen_teks_istilah.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_detail_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:funda/tema/tema.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  group('Tahap 13C: Redesain Anti-Slop, Animasi Kata & Bersih Debug UI', () {
    late BasisDataFunda db;

    setUp(() async {
      db = BasisDataFunda(NativeDatabase.memory());
      await db.simpanPengaturan('tutorial_beranda_selesai', 'true');
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets(
      '1. Fitur debug UI dan tag Draf nonaktif di Beranda, Lainnya, Pengaturan, dan Pemutar Pelajaran',
      (tester) async {
        expect(aktifkanFiturDebugUi, isFalse);

        // Beranda tanpa banner pengembang
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaTotalSaldoAktif.overrideWithValue(0),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
              ),
              penyediaDaftarDompetAktif.overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarBeranda(),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.textContaining('Mode Pengembang: Buka Galeri Komponen & Token'),
          findsNothing,
        );
        await bongkarWidget(tester);

        // Lainnya tanpa kartu Galeri Komponen UI
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarLainnya(),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Galeri Komponen UI'), findsNothing);
        await bongkarWidget(tester);

        // Pengaturan tanpa tombol Jadwalkan Pengingat Uji
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
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
        expect(
          find.text('Jadwalkan Pengingat Uji (2 Menit Lagi)'),
          findsNothing,
        );
        await bongkarWidget(tester);

        // Pemutar pelajaran tanpa label Draf
        const pel = PelajaranKonten(
          id: 'pel_13c_1',
          modulId: 'tabungan',
          judul: 'Menabung Rutin',
          durasiMenit: 3,
          status: 'draf',
          gerbang: [],
          pemantik: 'Mulai menabung dari nominal kecil.',
          kartu: [KartuPelajaranKonten(judul: 'Kunci', isi: 'Sisihkan dulu.')],
          contohAngka: ContohAngkaKonten.kosong,
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 1,
            judul: 'Misi',
            deskripsi: 'Deskripsi',
            perkiraanMenit: 2,
          ),
        );
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaFotoData.overrideWith(
                (ref) => Future.value(FotoDataPengguna.kosong()),
              ),
              penyediaKamus.overrideWith((ref) => Future.value(const {})),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarPemutarPelajaran(
                modulId: 'tabungan',
                pelajaranId: 'pel_13c_1',
                pelajaranOverride: pel,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Draf'), findsNothing);
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. TeksAnimasiKata merender semua kata, dukung ketukan istilah kamus, dan selesai instan tanpa ticker',
      (tester) async {
        final kamus = {
          'dana darurat': const IstilahKamus(
            istilah: 'Dana Darurat',
            arti: 'Cadangan uang untuk keadaan mendesak.',
            contohRupiah: 'Misal Rp3.000.000 untuk kebutuhan 1 bulan.',
          ),
        };

        // Mode tanpa animasi (pengujian/disableAnimations) -> langsung render TeksDenganIstilah utuh
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaKamus.overrideWith((ref) => Future.value(kamus)),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16),
                  child: TeksAnimasiKata(
                    teks: 'Siapkan {{dana darurat}} sejak awal.',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.byType(TeksDenganIstilah), findsOneWidget);
        final richText = tester.widget<RichText>(
          find
              .descendant(
                of: find.byType(TeksDenganIstilah),
                matching: find.byType(RichText),
              )
              .first,
        );
        expect(richText.textAlign, equals(TextAlign.start));

        // Ketuk istilah di dalam teks untuk membuka popup kamus
        TapGestureRecognizer? ketuk;
        (richText.text as TextSpan).visitChildren((span) {
          if (span is TextSpan &&
              (span.text?.toLowerCase().contains('dana darurat') ?? false)) {
            ketuk = span.recognizer as TapGestureRecognizer?;
            return false;
          }
          return true;
        });
        expect(ketuk, isNotNull);
        ketuk!.onTap?.call();
        await pompaHinggaAda(tester, find.byType(AlertDialog));
        expect(find.text('Dana Darurat'), findsOneWidget);
        final artiWidget = tester.widget<Text>(
          find.text('Cadangan uang untuk keadaan mendesak.'),
        );
        expect(artiWidget.textAlign, equals(TextAlign.start));
        await bongkarWidget(tester);

        // Mode animasi aktif + ketuk untuk langsung menampilkan kondisi akhir seketika
        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaTanpaAnimasi.overrideWithValue(false),
              penyediaKamus.overrideWith((ref) => Future.value(kamus)),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16),
                  child: TeksAnimasiKata(teks: 'Mulai langkah kecil hari ini.'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        // Selama animasi berjalan, setiap kata tersedia sebagai teks widget
        expect(find.textContaining('Mulai'), findsOneWidget);
        // Ketuk untuk menuntaskan animasi instan
        await tester.tap(find.byType(TeksAnimasiKata));
        await tester.pump();
        expect(find.byType(TeksDenganIstilah), findsOneWidget);
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. LayarBelajar tampil ramping dengan pil progres x/y, split card atas, tombol pil gelap & lembar detail modul',
      (tester) async {
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

        const modul = ModulKonten(
          id: 'tujuan_besar',
          judul: 'Tujuan Besar & Perencanaan',
          tingkat: 'menengah',
          urutan: 12,
          deskripsiSingkat: 'Rencanakan target besarmu bertahap.',
          tersedia: true,
          gerbang: [],
          daftarPelajaran: ['pel_12_1', 'pel_12_2'],
          kuis: KuisKonten(jumlahSoal: 5, bankSoal: []),
        );
        const pel1 = PelajaranKonten(
          id: 'pel_12_1',
          modulId: 'tujuan_besar',
          judul: 'Memecah Tujuan Besar',
          durasiMenit: 4,
          status: 'draf',
          gerbang: [],
          pemantik: 'Punya tujuan besar memang bikin semangat.',
          kartu: [KartuPelajaranKonten(judul: 'K1', isi: 'Bagi per bulan.')],
          contohAngka: ContohAngkaKonten.kosong,
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'tujuan',
            min: 1,
            judul: 'Misi',
            deskripsi: 'Buat 1 tujuan.',
            perkiraanMenit: 2,
          ),
        );
        const pel2 = PelajaranKonten(
          id: 'pel_12_2',
          modulId: 'tujuan_besar',
          judul: 'Menghitung Dampak Harga',
          durasiMenit: 5,
          status: 'draf',
          gerbang: [],
          pemantik: 'Harga barang bisa naik seiring waktu.',
          kartu: [KartuPelajaranKonten(judul: 'K1', isi: 'Siapkan selisih.')],
          contohAngka: ContohAngkaKonten.kosong,
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'tujuan',
            min: 1,
            judul: 'Misi',
            deskripsi: 'Cek target.',
            perkiraanMenit: 2,
          ),
        );

        final peta = [
          const ItemPetaModul(
            modul: modul,
            statusModul: HasilStatusBelajar(
              status: StatusBelajar.sedang,
              apaYangKurang: [],
            ),
            daftarPelajaran: [
              (
                pel1,
                HasilStatusBelajar(
                  status: StatusBelajar.selesai,
                  apaYangKurang: [],
                ),
              ),
              (
                pel2,
                HasilStatusBelajar(
                  status: StatusBelajar.terbuka,
                  apaYangKurang: [],
                ),
              ),
            ],
          ),
        ];

        const rekList = [
          InfoRekomendasiModul(
            modul: modul,
            judulAlasan: 'Prioritas Tujuan',
            deskripsiAlasan: 'Cocok untuk rencana dana jangka menengahmu.',
            statusModul: HasilStatusBelajar(
              status: StatusBelajar.sedang,
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
          find.byKey(const Key('kartu_sorotan_rekomendasi')),
        );

        // Split card atas dengan tombol pil gelap dan ilustrasi vektor
        expect(
          find.byWidgetPredicate(
            (w) => w is TombolFunda && w.varian == VarianTombolFunda.pilGelap,
          ),
          findsOneWidget,
        );
        expect(find.byType(IlustrasiGeometrisFunda), findsWidgets);
        // Kartu modul ramping menampilkan pil progres x/y, daftar pelajaran belum dibentangkan
        expect(find.text('1/2'), findsOneWidget);
        expect(find.text('Memecah Tujuan Besar'), findsNothing);

        // Ketuk kartu modul -> membuka halaman penuh LayarDetailModul editorial
        await tester.tap(find.byKey(const Key('kartu_modul_tujuan_besar')));
        await pompaHinggaAda(tester, find.byType(LayarDetailModul));
        expect(
          find.byKey(const Key('header_kanvas_detail_modul')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tombol_kembali_detail_modul')),
          findsOneWidget,
        );
        expect(find.text('Memecah Tujuan Besar'), findsOneWidget);
        expect(find.text('Menghitung Dampak Harga'), findsOneWidget);
        // Bersih tanpa tombol "Baca Ulang" / "Mulai" per baris, diganti 1 sticky CTA pil gelap
        expect(find.text('Baca Ulang'), findsNothing);
        expect(find.text('Mulai'), findsNothing);
        expect(
          find.byKey(const Key('tombol_aksi_detail_modul')),
          findsOneWidget,
        );

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '5. LayarDetailModul bebas overflow pada layar 360x640 skala teks 2.0',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const modul = ModulKonten(
          id: 'dana_darurat',
          judul: 'Dana Darurat Untuk Situasi Tak Terduga',
          tingkat: 'pemula',
          urutan: 3,
          deskripsiSingkat: 'Bangun bantalan aman perlahan.',
          tersedia: true,
          gerbang: [],
          daftarPelajaran: ['dana_darurat_3_1'],
          kuis: KuisKonten(jumlahSoal: 5, bankSoal: []),
        );
        const pel = PelajaranKonten(
          id: 'dana_darurat_3_1',
          modulId: 'dana_darurat',
          judul: 'Berapa Bulan Dana Darurat yang Ideal',
          durasiMenit: 4,
          status: 'draf',
          gerbang: [],
          pemantik: 'Situasi darurat bisa datang kapan saja.',
          kartu: [KartuPelajaranKonten(judul: 'K1', isi: 'Mulai 1 bulan.')],
          contohAngka: ContohAngkaKonten.kosong,
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'tujuan',
            min: 1,
            judul: 'Misi',
            deskripsi: 'Buat target.',
            perkiraanMenit: 2,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaPetaBelajar.overrideWith(
                (ref) => Future.value([
                  const ItemPetaModul(
                    modul: modul,
                    statusModul: HasilStatusBelajar(
                      status: StatusBelajar.sedang,
                      apaYangKurang: [],
                    ),
                    daftarPelajaran: [
                      (
                        pel,
                        HasilStatusBelajar(
                          status: StatusBelajar.sedang,
                          apaYangKurang: [],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarDetailModul(modulId: 'dana_darurat'),
              ),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('header_kanvas_detail_modul')),
        );
        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '4. LayarPemutarPelajaran tampil dengan progress bar bersegmen, tombol X, kanvas ilustrasi, rata kiri & bebas overflow 2.0x pada 360x640',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const pel = PelajaranKonten(
          id: 'pel_13c_layout',
          modulId: 'waspada_penipuan',
          judul: 'Kenali Pola Penawaran Tidak Masuk Akal',
          durasiMenit: 4,
          status: 'draf',
          gerbang: [],
          pemantik:
              'Tawaran untung cepat sering membuat siapa saja tergoda di saat mendesak.',
          kartu: [
            KartuPelajaranKonten(
              judul: 'Tanda Bahaya Pertama',
              isi: 'Janji untung pasti tanpa risiko patut diwaspadai.',
            ),
          ],
          contohAngka: ContohAngkaKonten(
            judul: 'Simulasi Angka Wajar vs Janggal',
            baris: [
              BarisContohAngka(label: 'Modal Awal', jumlah: 1000000),
              BarisContohAngka(
                label: 'Janji Balik 1 Minggu',
                jumlah: 2000000,
                ringkasan: true,
              ),
            ],
            kesimpulan: 'Selalu cek izin resmi sebelum menyerahkan uang.',
          ),
          cekPaham: [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 1,
            judul: 'Misi Catat',
            deskripsi: 'Catat 1 transaksi.',
            perkiraanMenit: 2,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaFotoData.overrideWith(
                (ref) => Future.value(FotoDataPengguna.kosong()),
              ),
              penyediaKamus.overrideWith((ref) => Future.value(const {})),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarPemutarPelajaran(
                  modulId: 'waspada_penipuan',
                  pelajaranId: 'pel_13c_layout',
                  pelajaranOverride: pel,
                ),
              ),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('progress_bersegmen_pelajaran')),
        );

        // Verifikasi bilah atas editorial, kanvas ilustrasi, rata kiri & tombol pil gelap
        expect(find.byKey(const Key('tombol_tutup_pelajaran')), findsOneWidget);
        expect(
          find.byKey(const Key('progress_bersegmen_pelajaran')),
          findsOneWidget,
        );
        expect(find.byType(KanvasIlustrasiPelajaran), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is TombolFunda && w.varian == VarianTombolFunda.pilGelap,
          ),
          findsOneWidget,
        );
        expect(find.text('Draf'), findsNothing);

        final pemantikWidget = tester.widget<Text>(find.text(pel.pemantik));
        expect(pemantikWidget.textAlign, equals(TextAlign.start));
        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );
  });
}
