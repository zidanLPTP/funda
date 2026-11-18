import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/data/repositori/pernyataan_repositori.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/komponen_teks_istilah.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

BasisDataFunda buatBasisDataUji() {
  return BasisDataFunda(NativeDatabase.memory());
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Pengujian Widget Komponen Teks Istilah & Dialog Kamus', () {
    testWidgets('TeksDenganIstilah menampilkan dialog kamus saat istilah diklik', (tester) async {
      final mapKamus = {
        'arus kas': const IstilahKamus(
          istilah: 'Arus Kas',
          arti: 'Aliran uang masuk dan uang keluar dalam kurun waktu tertentu.',
          contohRupiah: 'Gaji Rp5.000.000 masuk, belanja Rp3.500.000 keluar.',
        ),
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaKamus.overrideWith((ref) => Future.value(mapKamus)),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const Scaffold(
              body: TeksDenganIstilah(
                teks: 'Pahami bagaimana {{arus kas}} bekerja setiap bulannya.',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan teks dan istilah terurai dalam RichText
      expect(find.textContaining('Pahami bagaimana'), findsOneWidget);
      expect(find.textContaining('arus kas'), findsOneWidget);

      // Picu aksi ketuk pada recognizer istilah 'arus kas'
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final span = richText.text as TextSpan;
      var ditemukan = false;
      span.visitChildren((child) {
        if (child is TextSpan && (child.text?.toLowerCase().contains('arus kas') ?? false)) {
          final tapRec = child.recognizer as TapGestureRecognizer?;
          tapRec?.onTap?.call();
          ditemukan = true;
          return false;
        }
        return true;
      });
      expect(ditemukan, isTrue, reason: 'Span istilah harus ditemukan');
      await tester.pumpAndSettle();

      // Dialog kamus terbuka
      expect(find.text('Arus Kas'), findsOneWidget);
      expect(find.text('Aliran uang masuk dan uang keluar dalam kurun waktu tertentu.'), findsOneWidget);
      expect(find.text('Gaji Rp5.000.000 masuk, belanja Rp3.500.000 keluar.'), findsOneWidget);

      // Tutup dialog
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();
      expect(find.text('Aliran uang masuk dan uang keluar dalam kurun waktu tertentu.'), findsNothing);
    });
  });

  group('Pengujian Widget Tab Belajar (Peta Belajar)', () {
    late BasisDataFunda db;

    setUp(() {
      db = buatBasisDataUji();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('LayarBelajar menampilkan modul tersedia, segera hadir, dan pelajaran terkunci', (tester) async {
      final modulAktif = ModulKonten(
        id: 'anggaran_arus_kas',
        judul: 'Anggaran & Arus Kas',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: 'Fondasi penting arus kas.',
        tersedia: true,
        gerbang: const [],
        daftarPelajaran: const ['anggaran_arus_kas_1_2'],
        kuis: const KuisKonten(
          jumlahSoal: 2,
          bankSoal: [
            SoalKuis(
              id: 'q1',
              pelajaranId: 'anggaran_arus_kas_1_2',
              tanya: 'Apa itu arus kas?',
              pilihan: ['A', 'B'],
              benar: 0,
              penjelasan: 'Penjelasan A',
            ),
            SoalKuis(
              id: 'q2',
              pelajaranId: 'anggaran_arus_kas_1_2',
              tanya: 'Apa itu kebutuhan?',
              pilihan: ['X', 'Y'],
              benar: 0,
              penjelasan: 'Penjelasan X',
            ),
          ],
        ),
      );

      final modulSegeraHadir = ModulKonten(
        id: 'investasi_pemula',
        judul: 'Investasi Pemula',
        tingkat: 'pemula',
        urutan: 2,
        deskripsiSingkat: 'Mengenal reksa dana.',
        tersedia: false,
        gerbang: const [],
        daftarPelajaran: const [],
        kuis: const KuisKonten(jumlahSoal: 0, bankSoal: []),
      );

      final pel1 = PelajaranKonten(
        id: 'anggaran_arus_kas_1_2',
        modulId: 'anggaran_arus_kas',
        judul: 'Memetakan Arus Kas',
        durasiMenit: 3,
        status: 'draf',
        gerbang: const [
          SyaratGerbangData(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 3,
            pesan: 'Catat minimal 3 transaksi nyata.',
            atauPernyataan: 'tidak_punya_transaksi',
          ),
        ],
        pemantik: 'Pemantik cerita',
        kartu: const [KartuPelajaranKonten(judul: 'Konsep', isi: 'Isi')],
        contohAngka: ContohAngkaKonten.kosong,
        cekPaham: const [],
        misi: const MisiKonten(
          tipe: 'ada_data',
          objek: 'transaksi',
          min: 1,
          judul: 'Misi',
          deskripsi: 'Deskripsi',
          perkiraanMenit: 2,
          umpanBalik: 'arus_kas_bulan_ini',
        ),
      );

      final itemModul1 = ItemPetaModul(
        modul: modulAktif,
        statusModul: const HasilStatusBelajar(
          status: StatusBelajar.sedang,
          apaYangKurang: [],
        ),
        daftarPelajaran: [
          (
            pel1,
            const HasilStatusBelajar(
              status: StatusBelajar.terkunci,
              apaYangKurang: ['Catat minimal 3 transaksi nyata.'],
              ruteAksi: '/catatan',
              daftarAtauPernyataan: ['tidak_punya_transaksi'],
            )
          ),
        ],
      );

      final itemModul2 = ItemPetaModul(
        modul: modulSegeraHadir,
        statusModul: const HasilStatusBelajar(
          status: StatusBelajar.terkunci,
          apaYangKurang: [],
        ),
        daftarPelajaran: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaPetaBelajar.overrideWith(
              (ref) => Future.value([itemModul1, itemModul2]),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarBelajar(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cek judul layar dan bagian
      expect(find.text('Belajar Finansial'), findsOneWidget);
      expect(find.text('Tingkat Pemula'), findsOneWidget);
      expect(find.text('Anggaran & Arus Kas'), findsOneWidget);
      expect(find.text('Investasi Pemula'), findsOneWidget);
      expect(find.text('Segera Hadir'), findsOneWidget);

      // Cek pelajaran terkunci dan tombol pernyataan
      expect(find.text('Memetakan Arus Kas'), findsOneWidget);
      expect(find.text('Catat minimal 3 transaksi nyata.'), findsOneWidget);
      expect(find.text('Aku tidak punya ini'), findsOneWidget);
      expect(find.text('Lengkapi Data Sekarang'), findsOneWidget);

      // Ketuk tombol "Aku tidak punya ini"
      await tester.ensureVisible(find.text('Aku tidak punya ini'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aku tidak punya ini'));
      await tester.pumpAndSettle();

      // Verifikasi di DB bahwa pernyataan tersimpan
      final repo = PernyataanRepositori(db);
      final pernyataan = await repo.ambilSemuaPernyataan();
      expect(pernyataan['tidak_punya_transaksi'], equals('true'));

      // Bersihkan pohon widget
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Pengujian Widget Kuis Modul', () {
    late BasisDataFunda db;

    setUp(() {
      db = buatBasisDataUji();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('LayarKuisModul alur pengerjaan dan hasil kelulusan', (tester) async {
      final modulKuis = ModulKonten(
        id: 'modul_uji',
        judul: 'Modul Uji',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: 'Deskripsi',
        tersedia: true,
        gerbang: const [],
        daftarPelajaran: const [],
        kuis: const KuisKonten(
          jumlahSoal: 2,
          bankSoal: [
            SoalKuis(
              id: 's1',
              pelajaranId: 'pel_1',
              tanya: 'Berapa satu tambah satu?',
              pilihan: ['Dua', 'Tiga'],
              benar: 0,
              penjelasan: 'Satu tambah satu adalah dua.',
            ),
            SoalKuis(
              id: 's2',
              pelajaranId: 'pel_1',
              tanya: 'Warna langit cerah?',
              pilihan: ['Merah', 'Biru'],
              benar: 1,
              penjelasan: 'Langit cerah berwarna biru.',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith(
              (ref) => Future.value([modulKuis]),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(modulId: 'modul_uji'),
          ),
        ),
      );
      // Tunggu hingga microtask future provider selesai
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // Soal 1 tampil (diacak)
      expect(find.text('Soal 1/2'), findsOneWidget);
      final isSoalTambah = find.text('Berapa satu tambah satu?').evaluate().isNotEmpty;
      final jawaban1 = isSoalTambah ? 'Dua' : 'Biru';
      final penjelasan1 = isSoalTambah ? 'Satu tambah satu adalah dua.' : 'Langit cerah berwarna biru.';

      // Pilih jawaban benar soal 1
      await tester.tap(find.text(jawaban1));
      await tester.pumpAndSettle();

      // Penjelasan langsung muncul
      expect(find.text(penjelasan1), findsOneWidget);

      // Lanjut ke soal 2
      await tester.tap(find.text('Soal Berikutnya'));
      await tester.pumpAndSettle();

      // Soal 2 tampil
      expect(find.text('Soal 2/2'), findsOneWidget);
      final jawaban2 = isSoalTambah ? 'Biru' : 'Dua';
      final penjelasan2 = isSoalTambah ? 'Langit cerah berwarna biru.' : 'Satu tambah satu adalah dua.';

      // Pilih jawaban benar soal 2
      await tester.tap(find.text(jawaban2));
      await tester.pumpAndSettle();
      expect(find.text(penjelasan2), findsOneWidget);

      // Selesaikan kuis
      await tester.tap(find.text('Lihat Hasil Kuis'));
      await tester.pumpAndSettle();

      // Layar Hasil Kelulusan
      expect(find.text('Selamat, Kamu Lulus!'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Syarat kelulusan: minimal 70%'), findsOneWidget);

      // Pastikan hasil tersimpan di DB
      final hasilKuis = await db.select(db.tabelHasilKuis).get();
      expect(hasilKuis.length, equals(1));
      expect(hasilKuis.first.lulus, isTrue);
      expect(hasilKuis.first.skorPersen, equals(100));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Pengujian Widget Pemutar Pelajaran & Alur Kartu', () {
    late BasisDataFunda db;

    setUp(() {
      db = buatBasisDataUji();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('LayarPemutarPelajaran menyajikan kartu bertahap dan memproses cek paham & misi', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarPemutarPelajaran(
              modulId: 'anggaran_arus_kas',
              pelajaranId: 'anggaran_arus_kas_1_2',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Langkah 1: Pemantik
      expect(find.text('Pemantik'), findsOneWidget);
      expect(find.textContaining('Temanmu bertanya, "Uangmu bulan ini cukup?"'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 2: Kartu Konsep 1/3
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Arus kas: uang masuk dikurangi uang keluar'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 3: Kartu Konsep 2/3
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Petakan dari mana dan ke mana'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 4: Kartu Konsep 3/3
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Membaca hasilnya dengan tenang'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 5: Contoh Angka
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Contoh arus kas satu bulan'), findsOneWidget);
      expect(find.text('Uang saku dan gaji paruh waktu'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 6: Cek Paham
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Uji Pemahaman Singkat'), findsOneWidget);
      expect(find.textContaining('Pemasukan Rp3.000.000 dan pengeluaran Rp3.200.000'), findsOneWidget);

      // Jawab ketiga soal cek paham
      await tester.tap(find.text('Minus Rp200.000, uang keluar lebih besar'));
      await tester.pumpAndSettle();

      final soal2 = find.text('Biaya kos bulanan');
      await tester.ensureVisible(soal2);
      await tester.pumpAndSettle();
      await tester.tap(soal2);
      await tester.pumpAndSettle();

      final soal3 = find.text('Cari bagian pengeluaran terbesar dan lihat mana yang bisa disesuaikan');
      await tester.ensureVisible(soal3);
      await tester.pumpAndSettle();
      await tester.tap(soal3);
      await tester.pumpAndSettle();

      // Sekarang tombol Lanjut aktif -> Langkah 7: Misi Praktik
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Petakan uang masuk dan keluar'), findsOneWidget);
      expect(find.text('Belum relevan buat aku'), findsOneWidget);

      // Pengguna memilih lewati misi
      await tester.tap(find.text('Belum relevan buat aku'));
      await tester.pumpAndSettle();
      expect(find.text('Misi ini kamu lewati.'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 8: Umpan Balik
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Hasil dari Datamu'), findsOneWidget);

      // Ketuk Lanjut -> Langkah 9: Tindak Lanjut
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Langkah Kecil Berikutnya'), findsOneWidget);
      expect(find.text('Selesai Belajar'), findsOneWidget);

      // Selesaikan pelajaran
      await tester.tap(find.text('Selesai Belajar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Pastikan status pelajaran tersimpan 'selesai' di DB
      final progres = await db.select(db.tabelProgresPelajaran).get();
      expect(progres.length, equals(1));
      expect(progres.first.status, equals('selesai'));

      // Unmount widget sebelum database ditutup agar timer dibersihkan
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Pengujian Widget Aksesibilitas Skala Teks 2.0x Bebas Overflow', () {
    late BasisDataFunda db;

    setUp(() {
      db = buatBasisDataUji();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('LayarKuisModul pada TextScaler 2.0 tidak mengalami overflow', (tester) async {
      final modulKuis = ModulKonten(
        id: 'modul_uji_skala',
        judul: 'Uji Skala',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: 'Deskripsi',
        tersedia: true,
        gerbang: const [],
        daftarPelajaran: const [],
        kuis: const KuisKonten(
          jumlahSoal: 1,
          bankSoal: [
            SoalKuis(
              id: 's1',
              pelajaranId: 'pel_skala',
              tanya: 'Pertanyaan panjang untuk menguji teks membesar pada layar mobile?',
              pilihan: ['Pilihan A dengan teks panjang', 'Pilihan B dengan teks panjang'],
              benar: 0,
              penjelasan: 'Penjelasan panjang tentang prinsip pengelolaan uang.',
            ),
          ],
        ),
      );

      // Tangkap galat Flutter jika terjadi overflow
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
        previousOnError?.call(details);
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith(
              (ref) => Future.value([modulKuis]),
            ),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
                size: Size(390, 844),
              ),
              child: const LayarKuisModul(modulId: 'modul_uji_skala'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      FlutterError.onError = previousOnError;

      final overflowErrors = errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflowErrors, isEmpty, reason: 'Tidak boleh ada overflow pada skala teks 2.0x');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
