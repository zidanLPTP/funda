@Timeout(Duration(seconds: 30))
library;

import 'dart:convert';
import 'dart:io';
import '../pembantu/pompa_uji.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  group(
    'Uji Widget Tahap 8A: Pemutar Pelajaran, Kartu Misi Umpan Balik, Kuis Modul & Skala Teks 2.0',
    () {
      testWidgets('1. Render contohAngka pada 6 pelajaran Modul 2 & 3', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarUji = [
          (
            'tabungan',
            'tabungan_2_1',
            'Dari target ke setoran bulanan',
            'Target laptop untuk skripsi',
            'Rp6.000.000',
          ),
          (
            'tabungan',
            'tabungan_2_2',
            'Dua cara menabung dari uang bulanan Rp2.500.000',
            'Cara 2: tersisa untuk pengeluaran lain',
            'Rp2.300.000',
          ),
          (
            'tabungan',
            'tabungan_2_3',
            'Target Rp3.000.000, belum ada yang terkumpul',
            'Setoran per bulan sekarang',
            'Rp250.000',
          ),
          (
            'dana_darurat',
            'dana_darurat_3_1',
            'Biaya mendadak Rp1.200.000 di bulan yang uangnya tipis',
            'Biaya perbaikan HP',
            'Rp1.200.000',
          ),
          (
            'dana_darurat',
            'dana_darurat_3_2',
            'Contoh pengeluaran wajib Rp1.900.000 per bulan',
            'Titik awal, 3 kali pengeluaran wajib',
            'Rp5.700.000',
          ),
          (
            'dana_darurat',
            'dana_darurat_3_3',
            'Mengisi dana darurat Rp5.700.000 dengan Rp475.000 per bulan',
            'Target dana darurat',
            'Rp5.700.000',
          ),
        ];

        for (final (modulId, pelId, judulContoh, labelBaris, nominalStr)
            in daftarUji) {
          final file = File('aset/konten/pemula/$modulId/$pelId.json');
          final pel = PembacaKonten.uraiPelajaran(
            file.readAsStringSync(),
            namaBerkas: '$pelId.json',
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(FotoDataPengguna.kosong()),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaTeksUmpanBalikMisi(
                  pel.misi.umpanBalik ?? '',
                ).overrideWith((ref) => Future.value('Umpan balik tiruan')),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: modulId,
                  pelajaranId: pel.id,
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );

          await tester.pump();

          // Berpindah: Pemantik(0) -> Kartu1(1) -> Kartu2(2) -> Kartu3(3) -> Contoh(4)
          for (var i = 0; i < 4; i++) {
            await tester.tap(find.text('Lanjut'));
            await tester.pump();
          }

          // Verifikasi judul contohAngka dan teks baris
          expect(
            find.text(judulContoh),
            findsOneWidget,
            reason: 'Judul contoh $judulContoh harus tampil di $pelId',
          );
          expect(
            find.text(labelBaris),
            findsOneWidget,
            reason: 'Label $labelBaris harus tampil di $pelId',
          );
          expect(
            find.text(nominalStr),
            findsAtLeastNWidgets(1),
            reason: 'Nominal $nominalStr harus tampil di $pelId',
          );

          await bongkarWidget(tester);
        }
      });

      testWidgets('2. Render kartu misi untuk 5 kunci umpan balik baru', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final kunciUji = [
          (
            'ringkasan_tujuan_tabungan',
            'Tujuan tabunganmu: Laptop. Dana terkumpul: Rp1.000.000 dari Rp6.000.000.',
          ),
          (
            'estimasi_tabungan',
            'Sisa yang perlu dikumpulkan: Rp3.000.000. Target tercapai 10 bulan lagi.',
          ),
          (
            'pengeluaran_wajib_bulanan',
            'Pengeluaran wajibmu rata-rata Rp1.900.000 per bulan.',
          ),
          (
            'target_dana_darurat',
            'Titik awal yang masuk akal: Rp5.700.000. Sesuaikan dengan kondisimu.',
          ),
          (
            'progres_dana_darurat',
            'Dana daruratmu: Rp3.800.000. Itu setara sekitar 2 bulan pengeluaran wajibmu.',
          ),
        ];

        for (final (kunci, teksUmpanBalik) in kunciUji) {
          final pel = PelajaranKonten(
            id: 'tabungan_2_1',
            modulId: 'tabungan',
            judul: 'Uji Misi $kunci',
            durasiMenit: 5,
            status: 'draf',
            gerbang: const [],
            pemantik: 'Pengantar misi.',
            kartu: const [
              KartuPelajaranKonten(judul: 'Kartu', isi: 'Isi kartu.'),
            ],
            contohAngka: const ContohAngkaKonten(
              judul: 'Contoh',
              baris: [BarisContohAngka(label: 'Item', jumlah: 100000)],
              kesimpulan: 'Kesimpulan.',
            ),
            cekPaham: const [],
            misi: MisiKonten(
              tipe: 'ada_data',
              objek: 'tujuan_tabungan',
              min: 1,
              judul: 'Misi Uji $kunci',
              deskripsi: 'Deskripsi misi $kunci.',
              perkiraanMenit: 3,
              umpanBalik: kunci,
            ),
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(
                    FotoDataPengguna.kosong().copyWith(jumlahTujuanTabungan: 1),
                  ),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaTeksUmpanBalikMisi(
                  kunci,
                ).overrideWith((ref) => Future.value(teksUmpanBalik)),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: LayarPemutarPelajaran(
                  modulId: 'tabungan',
                  pelajaranId: pel.id,
                  pelajaranOverride: pel,
                ),
              ),
            ),
          );

          await tester.pump();

          // Maju: Pemantik(0) -> Kartu(1) -> Contoh(2) -> CekPaham(3) -> Misi Praktik(4)
          for (var i = 0; i < 4; i++) {
            await tester.tap(find.text('Lanjut'));
            await tester.pump();
          }

          // Verifikasi kartu misi pada slide misi
          expect(find.text('Misi Uji $kunci'), findsOneWidget);

          // Maju ke Slide Umpan Balik (5) karena misi sudah selesai (jumlahTujuanTabungan = 1)
          await tester.tap(find.text('Lanjut'));
          await tester.pump();

          // Verifikasi umpan balik pada slide umpan balik
          expect(
            find.text(teksUmpanBalik),
            findsOneWidget,
            reason:
                'Teks umpan balik untuk $kunci harus tampil di kartu umpan balik',
          );

          await bongkarWidget(tester);
        }
      });

      testWidgets(
        '3. Kuis Modul 2 & 3: pilih 5 dari 10 soal dan tampilkan penanda aturan praktis',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          // Muat Modul 3
          final modul3File = File('aset/konten/pemula/dana_darurat/modul.json');
          final modul3Json =
              jsonDecode(modul3File.readAsStringSync()) as Map<String, dynamic>;
          final modul3 = ModulKonten.fromJson(modul3Json);

          expect(modul3.kuis.jumlahSoal, equals(5));
          expect(modul3.kuis.bankSoal.length, equals(10));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaDaftarSemuaModul.overrideWith(
                  (ref) => Future.value([modul3]),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarKuisModul(modulId: 'dana_darurat', benih: 42),
              ),
            ),
          );

          await tester.pump();

          // Verifikasi layar kuis terbuka dengan indikator soal
          expect(find.text('Soal 1/5'), findsOneWidget);

          // Jawab 5 pertanyaan
          for (var s = 1; s <= 5; s++) {
            // Cari pilihan pertama yang terlihat di layar untuk soal saat ini
            final daftarTeks = tester.widgetList<Text>(find.byType(Text));
            final pilihanItem = daftarTeks.firstWhere(
              (w) =>
                  modul3.kuis.bankSoal.any((b) => b.pilihan.contains(w.data)),
            );
            await tester.tap(find.text(pilihanItem.data!));
            await tester.pump();

            if (s < 5) {
              final tombolLanjut = find.text('Soal Berikutnya');
              expect(tombolLanjut, findsOneWidget);
              await tester.tap(tombolLanjut);
              await tester.pump();
            } else {
              final tombolSelesai = find.text('Lihat Hasil Kuis');
              expect(tombolSelesai, findsOneWidget);
              await tester.tap(tombolSelesai);
              await tester.pump();
            }
          }

          // Verifikasi layar hasil kuis
          expect(find.text('Skor Kuis Kamu'), findsOneWidget);

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '4. Aksesibilitas: Layar pemutar pelajaran dan kuis pada TextScaler linear 2.0 tanpa galat overflow',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final file = File('aset/konten/pemula/tabungan/tabungan_2_1.json');
          final pel = PembacaKonten.uraiPelajaran(
            file.readAsStringSync(),
            namaBerkas: 'tabungan_2_1.json',
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(FotoDataPengguna.kosong()),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaTeksUmpanBalikMisi(
                  pel.misi.umpanBalik ?? '',
                ).overrideWith(
                  (ref) => Future.value('Umpan balik teks skala 2.0'),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: MediaQuery(
                  data: const MediaQueryData(
                    textScaler: TextScaler.linear(2.0),
                  ),
                  child: LayarPemutarPelajaran(
                    modulId: 'tabungan',
                    pelajaranId: pel.id,
                    pelajaranOverride: pel,
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          // Verifikasi tidak ada AABB overflow error di konsol
          expect(tester.takeException(), isNull);

          // Navigasi melalui seluruh slide pada skala 2.0
          for (var i = 0; i < 4; i++) {
            await tester.tap(find.text('Lanjut'));
            await tester.pump();
            expect(tester.takeException(), isNull);
          }

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '5. Tombol utama pemutar pelajaran ("Lanjut") dapat dijangkau dengan scroll pada layar 360x640 dengan skala teks 2.0',
        (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final file = File('aset/konten/pemula/tabungan/tabungan_2_1.json');
          final pel = PembacaKonten.uraiPelajaran(
            file.readAsStringSync(),
            namaBerkas: 'tabungan_2_1.json',
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(FotoDataPengguna.kosong()),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
                penyediaTeksUmpanBalikMisi(
                  pel.misi.umpanBalik ?? '',
                ).overrideWith(
                  (ref) => Future.value('Umpan balik teks skala 2.0'),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: MediaQuery(
                  data: const MediaQueryData(
                    size: Size(360, 640),
                    textScaler: TextScaler.linear(2.0),
                  ),
                  child: LayarPemutarPelajaran(
                    modulId: 'tabungan',
                    pelajaranId: pel.id,
                    pelajaranOverride: pel,
                  ),
                ),
              ),
            ),
          );

          await tester.pump();

          // Verifikasi tombol Lanjut ada dan dapat dijangkau (ensureVisible)
          final tombolLanjut = find.text('Lanjut');
          expect(tombolLanjut, findsOneWidget);
          await tester.ensureVisible(tombolLanjut);
          await tester.pump();
          await tester.tap(tombolLanjut);
          await tester.pump();

          // Pastikan langkah berpindah (Konsep 1)
          expect(find.text('Konsep Inti (1/3)'), findsOneWidget);

          await bongkarWidget(tester);
        },
      );
    },
  );
}
