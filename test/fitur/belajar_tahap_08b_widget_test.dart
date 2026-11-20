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
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
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

  group('Uji Widget Tahap 8B: Pemutar Pelajaran, Kartu Misi Umpan Balik, Tombol Pernyataan, Kuis & Skala Teks 2.0', () {
    testWidgets('1. Render contohAngka pada 4 pelajaran Modul 4', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final daftarUji = [
        ('utang_cicilan', 'utang_cicilan_4_1', 'Tiga cicilan kecil yang menumpuk (pemasukan Rp3.000.000 per bulan)', 'Cicilan HP', 'Rp450.000'),
        ('utang_cicilan', 'utang_cicilan_4_2', 'Pinjaman Rp12.000.000 selama 12 bulan, bunga flat 12 persen per tahun', 'Pokok', 'Rp12.000.000'),
        ('utang_cicilan', 'utang_cicilan_4_3', 'Rasio cicilan untuk pemasukan Rp3.000.000', 'Total cicilan per bulan', 'Rp900.000'),
        ('utang_cicilan', 'utang_cicilan_4_4', 'Tiga utang dengan bunga berbeda (contoh)', 'Paylater: sisa, bunga 36 persen per tahun', 'Rp800.000'),
      ];

      for (final (modulId, pelajaranId, judulContoh, labelBaris, nilaiBaris) in daftarUji) {
        final file = File('aset/konten/pemula/$modulId/$pelajaranId.json');
        expect(file.existsSync(), isTrue);
        final pel = PembacaKonten.uraiPelajaran(file.readAsStringSync(), namaBerkas: '$pelajaranId.json');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
              penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
              penyediaTeksUmpanBalikMisi(pel.misi.umpanBalik ?? '').overrideWith((ref) => Future.value('Umpan balik tiruan')),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: LayarPemutarPelajaran(
                modulId: modulId,
                pelajaranId: pelajaranId,
                pelajaranOverride: pel,
              ),
            ),
          ),
        );

        await pompaAman(tester);

        // Maju ke langkah Contoh Angka (setelah 3 kartu konsep)
        for (var i = 0; i < 4; i++) {
          await tester.tap(find.text('Lanjut'));
          await pompaAman(tester);
        }

        expect(find.text(judulContoh), findsOneWidget, reason: '$pelajaranId harus menampilkan judul contoh angka');
        expect(find.text(labelBaris), findsOneWidget, reason: '$pelajaranId harus menampilkan label baris');
        expect(find.text(nilaiBaris), findsOneWidget, reason: '$pelajaranId harus menampilkan nilai baris');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('2. Render kartu misi untuk 4 kunci umpan balik baru Modul 4', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final daftarUmpanBalik = [
        ('ringkasan_utang', 'Kamu punya 3 utang aktif dengan sisa total Rp6.300.000. Cicilan per bulan: Rp1.030.000. Itu sekitar 25 persen dari pemasukanmu (rata-rata 3 bulan terakhir). Ini gambaran, bukan penilaian.'),
        ('biaya_pinjaman_tercatat', 'Kredit HP: pokok Rp6.000.000, cicilan Rp550.000 x 12 bulan = total Rp6.600.000. Biaya pinjaman: Rp600.000. Hitungan ini memakai cicilan x tenor yang kamu catat dan belum memasukkan denda.'),
        ('rasio_cicilan_bulan_ini', 'Total cicilanmu Rp1.030.000 per bulan, dibandingkan pemasukan Rp4.000.000 per bulan (rata-rata 3 bulan terakhir). Rasio cicilanmu 25 persen. Kalau pemasukanmu turun 25 persen, rasionya menjadi 34 persen. Ini angka untuk kamu pahami, bukan nilai.'),
        ('urutan_pelunasan', 'Urutan bola salju (sisa terkecil dulu): Paylater (Rp800.000), lalu Pinjaman Teman (Rp1.500.000), lalu Kredit HP (Rp4.000.000). Urutan longsor (bunga tertinggi dulu): Paylater (36 persen per tahun), lalu Kredit HP (18 persen per tahun), lalu Pinjaman Teman (tanpa bunga). Urutan longsor memakai persen bunga yang kamu catat. Kalau jenis bunganya berbeda, anggap sebagai perkiraan. Pilih salah satu dan konsisten. Ini bahan belajar, bukan keharusan.'),
      ];

      for (final (kunci, teksUmpanBalik) in daftarUmpanBalik) {
        final pel = PelajaranKonten(
          id: 'utang_cicilan_4_1',
          modulId: 'utang_cicilan',
          judul: 'Uji Misi $kunci',
          durasiMenit: 5,
          status: 'draf',
          gerbang: const [],
          pemantik: 'Pengantar misi.',
          kartu: const [KartuPelajaranKonten(judul: 'Kartu', isi: 'Isi kartu.')],
          contohAngka: const ContohAngkaKonten(
            judul: 'Contoh',
            baris: [BarisContohAngka(label: 'Item', jumlah: 100000)],
            kesimpulan: 'Kesimpulan.',
          ),
          cekPaham: const [],
          misi: MisiKonten(
            tipe: 'ada_data',
            objek: 'utang',
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
              penyediaFotoData.overrideWith((ref) => Future.value(
                FotoDataPengguna.kosong().copyWith(jumlahUtangAktif: 1),
              )),
              penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
              penyediaTeksUmpanBalikMisi(kunci).overrideWith((ref) => Future.value(teksUmpanBalik)),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: LayarPemutarPelajaran(
                modulId: 'utang_cicilan',
                pelajaranId: pel.id,
                pelajaranOverride: pel,
              ),
            ),
          ),
        );

        await pompaAman(tester);

        // Maju ke langkah Umpan Balik (langkah ke-8)
        for (var i = 0; i < 7; i++) {
          final tombolLanjut = find.text('Lanjut');
          if (tombolLanjut.evaluate().isNotEmpty) {
            await tester.tap(tombolLanjut);
            await pompaAman(tester);
          }
        }

        // Verifikasi kartu umpan balik
        expect(find.text(teksUmpanBalik), findsOneWidget, reason: 'Kunci $kunci harus merender teks umpan balik lengkap');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('3. Tombol "Aku tidak punya ini" tampil pada modul terkunci dan menyimpan pernyataan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Muat Modul 4 dan Pelajaran 4.1 dari berkas JSON
      final modul4File = File('aset/konten/pemula/utang_cicilan/modul.json');
      final modul4Json = jsonDecode(modul4File.readAsStringSync()) as Map<String, dynamic>;
      final modul4 = ModulKonten.fromJson(modul4Json);

      final pel41File = File('aset/konten/pemula/utang_cicilan/utang_cicilan_4_1.json');
      final pel41 = PembacaKonten.uraiPelajaran(pel41File.readAsStringSync(), namaBerkas: 'utang_cicilan_4_1.json');

      // Foto data dengan modul 3 selesai, tetapi tanpa utang (dan belum ada pernyataan tidak_punya_utang)
      final fotoDataTerkunci = FotoDataPengguna.kosong().copyWith(
        progresPelajaran: {
          'dana_darurat_3_1': 'selesai',
          'dana_darurat_3_2': 'selesai',
          'dana_darurat_3_3': 'selesai',
        },
        hasilKuisTerbaik: {
          'dana_darurat': const HasilKuisSnapshot(skorPersen: 80, lulus: true),
        },
        jumlahUtangAktif: 0,
        pernyataan: {},
      );

      final statusModul = tentukanStatusModul(modul: modul4, fotoData: fotoDataTerkunci);
      final statusPel = tentukanStatusPelajaran(
        pelajaran: pel41,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel41],
        gerbangModul: modul4.gerbang,
        fotoData: fotoDataTerkunci,
      );

      final itemModul4 = ItemPetaModul(
        modul: modul4,
        statusModul: statusModul,
        daftarPelajaran: [(pel41, statusPel)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(fotoDataTerkunci)),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaPetaBelajar.overrideWith((ref) => Future.value([itemModul4])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarBelajar(),
          ),
        ),
      );

      await pompaAman(tester);

      // Verifikasi modul Utang & Cicilan ada
      final teksModul = find.text('Utang & Cicilan');
      expect(teksModul, findsOneWidget);

      // Scroll ke modul Utang & Cicilan
      await tester.ensureVisible(teksModul);
      await pompaAman(tester);

      // Verifikasi tombol "Aku tidak punya ini" muncul
      final tombolPernyataan = find.text('Aku tidak punya ini');
      expect(tombolPernyataan, findsOneWidget);

      // Ketuk tombol pernyataan
      await tester.ensureVisible(tombolPernyataan);
      await tester.tap(tombolPernyataan);
      await pompaAman(tester);

      // Verifikasi pernyataan tersimpan di database
      final hasilDb = await (db.select(db.tabelPernyataan)..where((p) => p.kunci.equals('tidak_punya_utang'))).getSingleOrNull();
      expect(hasilDb, isNotNull);
      expect(hasilDb!.nilai, equals('true'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('4. Kuis Modul 4: pilih 5 dari 10 bankSoal dengan pelajaranId valid', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fileModul = File('aset/konten/pemula/utang_cicilan/modul.json');
      final modulJson = jsonDecode(fileModul.readAsStringSync()) as Map<String, dynamic>;
      final modul = ModulKonten.fromJson(modulJson);

      expect(modul.kuis.jumlahSoal, equals(5));
      expect(modul.kuis.bankSoal.length, equals(10));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(
              modulId: 'utang_cicilan',
              benih: 42,
            ),
          ),
        ),
      );

      await pompaAman(tester);

      // Verifikasi judul kuis / indikator soal
      expect(find.text('Soal 1/5'), findsOneWidget);

      // Jawab 5 pertanyaan
      for (var s = 1; s <= 5; s++) {
        final daftarTeks = tester.widgetList<Text>(find.byType(Text));
        final pilihanItem = daftarTeks.firstWhere(
          (w) => modul.kuis.bankSoal.any((b) => b.pilihan.contains(w.data)),
        );
        await tester.tap(find.text(pilihanItem.data!));
        await pompaAman(tester);

        if (s < 5) {
          final tombolLanjut = find.text('Soal Berikutnya');
          expect(tombolLanjut, findsOneWidget);
          await tester.tap(tombolLanjut);
          await pompaAman(tester);
        } else {
          final tombolSelesai = find.text('Lihat Hasil Kuis');
          expect(tombolSelesai, findsOneWidget);
          await tester.tap(tombolSelesai);
          await pompaAman(tester);
        }
      }

      // Verifikasi layar hasil kuis muncul
      expect(find.text('Skor Kuis Kamu'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('5. Aksesibilitas: Layar pemutar pelajaran Modul 4 pada TextScaler linear 2.0 tanpa overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final file = File('aset/konten/pemula/utang_cicilan/utang_cicilan_4_1.json');
      final pel = PembacaKonten.uraiPelajaran(file.readAsStringSync(), namaBerkas: 'utang_cicilan_4_1.json');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaTeksUmpanBalikMisi(pel.misi.umpanBalik ?? '').overrideWith((ref) => Future.value('Umpan balik skala 2.0')),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: LayarPemutarPelajaran(
                modulId: 'utang_cicilan',
                pelajaranId: pel.id,
                pelajaranOverride: pel,
              ),
            ),
          ),
        ),
      );

      await pompaAman(tester);
      expect(tester.takeException(), isNull);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Lanjut'));
        await pompaAman(tester);
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
