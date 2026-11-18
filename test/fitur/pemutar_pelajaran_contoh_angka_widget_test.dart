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
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';
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

  group('Butir 5(a): Uji Widget Baru Pemutar Pelajaran, Contoh Angka & Aksesibilitas', () {
    testWidgets('1. Pemutar pelajaran merender contohAngka berbaris: negatif tampil Rp900.000 rapat & ringkasan berbeda', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const contohAngkaUji = ContohAngkaKonten(
        judul: 'Contoh Arus Kas Budi',
        baris: [
          BarisContohAngka(label: 'Gaji Pokok', jumlah: 3000000),
          BarisContohAngka(label: 'Sewa Kamar', jumlah: -900000),
          BarisContohAngka(label: 'Makan & Minum', jumlah: -1200000),
          BarisContohAngka(label: 'Sisa Bersih', jumlah: 900000, ringkasan: true),
        ],
        kesimpulan: 'Arus kas Budi positif sebesar Rp900.000.',
      );

      final pelajaran = PelajaranKonten(
        id: 'anggaran_arus_kas_1_1',
        modulId: 'anggaran_arus_kas',
        judul: 'Uji Contoh Angka',
        durasiMenit: 4,
        status: 'draf',
        gerbang: const [],
        pemantik: 'Pemantik pengantar.',
        kartu: const [KartuPelajaranKonten(judul: 'Konsep', isi: 'Isi ringkas.')],
        contohAngka: contohAngkaUji,
        cekPaham: const [],
        misi: const MisiKonten(
          tipe: 'ada_data',
          objek: 'transaksi',
          min: 1,
          judul: 'Catat Pengeluaran',
          deskripsi: 'Catat 1 pengeluaran.',
          perkiraanMenit: 2,
          umpanBalik: 'catatan_pengeluaran_terbaru',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaTeksUmpanBalikMisi(pelajaran.misi.umpanBalik!).overrideWith((ref) => Future.value('Umpan balik tiruan')),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'anggaran_arus_kas',
              pelajaranId: pelajaran.id,
              pelajaranOverride: pelajaran,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Berpindah dari Pemantik -> Konsep Inti -> Contoh Nyata
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Periksa judul dan kesimpulan contohAngka
      expect(find.text('Contoh Arus Kas Budi'), findsOneWidget);
      expect(find.text('Arus kas Budi positif sebesar Rp900.000.'), findsOneWidget);

      // Periksa baris nominal: Sewa Kamar (-900000) tampil sebagai '−Rp900.000' rapat (U+2212) sesuai Tahap 6-R Butir B
      expect(find.text('Sewa Kamar'), findsOneWidget);
      expect(find.text('−Rp900.000'), findsOneWidget); // Pada Sewa Kamar (negatif rapat U+2212)
      expect(find.text('Rp900.000'), findsOneWidget); // Pada Sisa Bersih (positif)

      // Periksa styling baris ringkasan (FontWeight.bold)
      final textSisaBersih = tester.widget<Text>(find.text('Sisa Bersih'));
      expect(textSisaBersih.style?.fontWeight, FontWeight.bold);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('2. Kartu misi merender ketiga umpan balik baru dengan teks persis sesuai aturan angka', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Umpan Balik 1: catatan_pengeluaran_terbaru
      final teksUmpanBalik1 = formatCatatanPengeluaranTerbaru(
        jumlahTotal: 1,
        kategori: 'Makan',
        nominal: 25000,
      );
      expect(teksUmpanBalik1, 'Kamu sudah mencatat 1 pengeluaran. Yang terbaru: Makan, Rp25.000. Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi.');

      // Umpan Balik 2: perbandingan_pola_anggaran
      final teksUmpanBalik2 = formatPerbandinganPolaAnggaran(
        pemasukan: 2500000,
        kebutuhan: 1250000,
        keinginan: 750000,
        tabunganDanUtang: 500000,
        belumDilabeli: 0,
      );
      expect(
        teksUmpanBalik2,
        'Pemasukanmu bulan ini: Rp2.500.000. Anggaran buatanmu: kebutuhan Rp1.250.000, keinginan Rp750.000, tabungan dan utang Rp500.000. Sebagai perbandingan, pola populer 50/30/20 dari pemasukan yang sama: kebutuhan Rp1.250.000, keinginan Rp750.000, tabungan dan utang Rp500.000. Keduanya titik awal. Sesuaikan dengan kondisimu.',
      );

      // Umpan Balik 3: realisasi_anggaran_bulan_ini
      final evaluasiPos = [
        const PosAnggaranEvaluasi(
          nama: 'Makan Harian',
          batas: 1000000,
          terpakai: 750000,
        ),
        const PosAnggaranEvaluasi(
          nama: 'Transportasi',
          batas: 500000,
          terpakai: 450000,
        ),
        const PosAnggaranEvaluasi(
          nama: 'Jajan & Nongkrong',
          batas: 300000,
          terpakai: 360000,
        ),
      ];
      final teksUmpanBalik3 = formatRealisasiAnggaranBulanIni(evaluasiPos);
      expect(
        teksUmpanBalik3,
        'Dari 3 pos anggaran: 1 masih aman, 1 mendekati batas, 1 melewati batas. Pos dengan sisa terbanyak: Makan Harian (sisa Rp250.000). Pos yang melewati batas paling jauh: Jajan & Nongkrong (lebih Rp60.000). Ini bahan belajar, bukan penilaian.',
      );

      // Verifikasi komponen kartu misi merender teks umpan balik ini ke layar
      final pelajaran = PelajaranKonten(
        id: 'anggaran_arus_kas_1_4',
        modulId: 'anggaran_arus_kas',
        judul: 'Uji Kartu Misi Umpan Balik',
        durasiMenit: 4,
        status: 'draf',
        gerbang: const [],
        pemantik: 'Pemantik',
        kartu: const [],
        cekPaham: const [],
        misi: const MisiKonten(
          tipe: 'ada_data',
          objek: 'anggaran',
          min: 3,
          judul: 'Buat 3 Anggaran',
          deskripsi: 'Deskripsi',
          perkiraanMenit: 2,
          umpanBalik: 'perbandingan_pola_anggaran',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaTeksUmpanBalikMisi(pelajaran.misi.umpanBalik!).overrideWith((ref) => Future.value(teksUmpanBalik2)),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'anggaran_arus_kas',
              pelajaranId: pelajaran.id,
              pelajaranOverride: pelajaran,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Berpindah dari Pemantik (langkah 0) -> Cek Paham (langkah 1) -> Misi (langkah 2)
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Misi Praktik Nyata'), findsOneWidget);
      expect(find.text('Buat 3 Anggaran'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('3. Kuis modul mengambil acak 5 soal dari bank 10 soal & beda susunan pada benih berbeda', (tester) async {
      final bank10 = List.generate(
        10,
        (i) => SoalKuis(
          id: 'soal_${i + 1}',
          pelajaranId: 'anggaran_arus_kas_1_1',
          tanya: 'Pertanyaan Soal ${i + 1}',
          pilihan: ['Pilihan A', 'Pilihan B', 'Pilihan C'],
          benar: 0,
          penjelasan: 'Penjelasan ${i + 1}',
        ),
      );

      // Ambil dua susunan soal dengan benih berbeda via fungsi murni
      final soalBenih1 = pilihDanAcakSoalKuis(bankSoal: bank10, jumlahSoal: 5, benih: 42);
      final soalBenih2 = pilihDanAcakSoalKuis(bankSoal: bank10, jumlahSoal: 5, benih: 99);

      expect(soalBenih1.length, 5);
      expect(soalBenih2.length, 5);

      final idSoal1 = soalBenih1.map((s) => s.id).toList();
      final idSoal2 = soalBenih2.map((s) => s.id).toList();

      expect(idSoal1, isNot(equals(idSoal2)));

      // Verifikasi pada widget LayarKuisModul
      final modulUji = ModulKonten(
        id: 'anggaran_arus_kas',
        judul: 'Anggaran & Arus Kas',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: 'Deskripsi',
        tersedia: true,
        gerbang: const [],
        daftarPelajaran: const ['anggaran_arus_kas_1_1'],
        kuis: KuisKonten(jumlahSoal: 5, bankSoal: bank10),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modulUji])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(
              modulId: 'anggaran_arus_kas',
              benih: 42,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('Soal 1/5'), findsOneWidget);
      expect(find.text(soalBenih1.first.tanya), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('4. Aksesibilitas: teks skala 2.0 tidak meluap (overflow) di layar pemutar dan kartu misi', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const contohAngkaLengkap = ContohAngkaKonten(
        judul: 'Arus Kas Bulanan Detail',
        baris: [
          BarisContohAngka(label: 'Penghasilan', jumlah: 5000000),
          BarisContohAngka(label: 'Kebutuhan Pokok', jumlah: -2500000),
          BarisContohAngka(label: 'Keinginan & Rekreasi', jumlah: -1500000),
          BarisContohAngka(label: 'Investasi Masa Depan', jumlah: -1000000),
          BarisContohAngka(label: 'Total Sisa', jumlah: 0, ringkasan: true),
        ],
        kesimpulan: 'Arus kas seimbang dan seluruh alokasi terpenuhi dengan baik.',
      );

      final pelajaran = PelajaranKonten(
        id: 'anggaran_arus_kas_1_1',
        modulId: 'anggaran_arus_kas',
        judul: 'Uji Aksesibilitas Skala Teks 2.0',
        durasiMenit: 4,
        status: 'draf',
        gerbang: const [],
        pemantik: 'Pemantik panjang untuk menguji wrap dan scrolling dengan skala teks besar.',
        kartu: const [
          KartuPelajaranKonten(
            judul: 'Konsep Arus Kas Rinci',
            isi: 'Arus kas adalah pergerakan masuk dan keluar uang secara nyata dalam satu periode tertentu.',
          ),
        ],
        contohAngka: contohAngkaLengkap,
        cekPaham: const [],
        misi: const MisiKonten(
          tipe: 'ada_data',
          objek: 'transaksi',
          min: 1,
          judul: 'Misi Uji Skala',
          deskripsi: 'Catat transaksi baru untuk menyelesaikan misi belajar.',
          perkiraanMenit: 2,
          umpanBalik: 'catatan_pengeluaran_terbaru',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaTeksUmpanBalikMisi(pelajaran.misi.umpanBalik!).overrideWith(
              (ref) => Future.value('Kamu sudah mencatat 1 pengeluaran. Terakhir: Makan Siang Rp35.000.'),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2.0),
                ),
                child: child!,
              );
            },
            home: LayarPemutarPelajaran(
              modulId: 'anggaran_arus_kas',
              pelajaranId: pelajaran.id,
              pelajaranOverride: pelajaran,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Memastikan tidak ada FlutterError di langkah 0 (Pemantik)
      expect(tester.takeException(), isNull);
      expect(find.text('Uji Aksesibilitas Skala Teks 2.0'), findsOneWidget);

      // Pindah ke Konsep
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Konsep Arus Kas Rinci'), findsOneWidget);

      // Pindah ke Contoh Angka
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Arus Kas Bulanan Detail'), findsOneWidget);

      // Pindah ke Cek Paham (kosong, lanjut)
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Pindah ke Misi Praktik Nyata
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Misi Praktik Nyata'), findsOneWidget);
      expect(find.text('Misi Uji Skala'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
