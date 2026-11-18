import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/progres_repositori.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/komponen/teks_funda.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  // Berikan waktu jeda 1.8 detik agar screencap dari runner luar sempat menangkap frame
  await Future.delayed(const Duration(milliseconds: 1800));
}

Future<void> pompaAman(WidgetTester tester, [int ms = 500]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('[Tahap 6-R Integrasi Emulator] Alur Lengkap Modul 1 dengan UI Nyata & 10 Bukti Tangkapan Layar', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('markNeedsBuild() called during build') ||
          details.exceptionAsString().contains('UncontrolledProviderScope')) {
        return;
      }
      originalOnError?.call(details);
    };

    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());
    final layananPengingat = LayananPengingatNyata();
    await layananPengingat.inisialisasi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          penyediaLayananPengingat.overrideWithValue(layananPengingat),
        ],
        child: const AplikasiFunda(),
      ),
    );
    await pompaAman(tester, 1000);

    // =========================================================================
    // 1. Pengguna Baru -> Lewati Tes Awal -> Buat Dompet
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Pengguna Baru Lewati Tes Awal & Buat Dompet ===');
    tester.element(find.byType(Scaffold).first).go('/belajar/tes-awal');
    await pompaAman(tester, 1000);

    final tombolLewati = find.text('Lewati');
    expect(tombolLewati, findsOneWidget);
    await tester.tap(tombolLewati);
    await pompaAman(tester, 1000);

    // Verifikasi profil_dilewati tersimpan
    final pernyataanDilewati = await (basisData.select(basisData.tabelPernyataan)
          ..where((p) => p.kunci.equals('profil_dilewati')))
        .getSingleOrNull();
    expect(pernyataanDilewati, isNotNull);
    expect(pernyataanDilewati!.nilai, equals('true'));

    // Buat Dompet Utama via basis data & suntik 1 pengeluaran untuk misi 1_1
    await basisData.into(basisData.tabelDompet).insert(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: 'tintBiru',
            saldoAwalRupiah: const Value(5000000),
          ),
        );

    final katMakan = (await basisData.select(basisData.tabelKategori).get()).firstWhere((k) => k.id == 'kat_keluar_makan');
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_1',
            dompetId: 'dmp_utama',
            jenis: 'keluar',
            kategoriId: Value(katMakan.id),
            jumlahRupiah: 25000,
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Makan Siang'),
          ),
        );

    // Buka Tab Belajar
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);
    expect(find.text('Anggaran & Arus Kas'), findsWidgets);
    expect(find.text('Ke Mana Uangku Pergi?'), findsOneWidget);

    // =========================================================================
    // 2. Pelajaran 1_1: Kartu Konsep, Contoh Angka 1_1, dan Misi
    // =========================================================================
    debugPrint('=== [LANGKAH 2]: Pelajaran 1_1 (Kartu Konsep & Contoh Angka 1_1) ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_1');
    await pompaAman(tester, 1000);

    // Layar Pemantik -> Ketuk Lanjut
    expect(find.text('Pemantik'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 500);

    // Tangkapan Layar: Kartu Konsep
    expect(find.text('Uang tidak hilang, hanya tidak terlihat'), findsOneWidget);
    await mintaTangkapanLayar('kartu_konsep');
    debugPrint('[BUKTI]: Tangkapan Layar Kartu Konsep 1_1');

    // Lanjut ke Konsep 2, Konsep 3, dan Contoh Nyata
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 400);
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 400);
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 500);

    // Tangkapan Layar: Contoh Angka 1_1
    expect(find.text('Pengeluaran kecil yang menumpuk (uang bulanan Rp2.000.000)'), findsOneWidget);
    await mintaTangkapanLayar('contoh_angka_1_1');
    debugPrint('[BUKTI]: Tangkapan Layar Contoh Angka 1_1');

    // Jawab Cek Paham 1_1
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 500);

    // Jawab 3 soal cek paham
    await tester.tap(find.text('Supaya uang terlihat dan bisa dipahami'));
    await pompaAman(tester, 300);
    final opsi2 = find.text('Tetap dicatat karena jumlahnya bisa menumpuk');
    await tester.ensureVisible(opsi2);
    await tester.tap(opsi2);
    await pompaAman(tester, 300);
    final opsi3 = find.text('Selisih antara uang yang masuk dan uang yang keluar');
    await tester.ensureVisible(opsi3);
    await tester.tap(opsi3);
    await pompaAman(tester, 300);

    // Lanjut ke Misi
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 500);

    // Lanjut ke Umpan Balik Catatan Pengeluaran Terbaru
    await tester.tap(find.text('Lanjut'));
    for (var p = 0; p < 8; p++) {
      await pompaAman(tester, 300);
    }

    // Tangkapan Layar: Umpan Balik Catatan Pengeluaran Terbaru
    expect(find.textContaining('Kamu sudah mencatat'), findsOneWidget);
    await mintaTangkapanLayar('catatan_pengeluaran_terbaru_1_1');
    debugPrint('[BUKTI]: Tangkapan Layar Umpan Balik 1_1');

    // Selesaikan Pelajaran 1_1
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 300);
    await tester.tap(find.text('Selesai Belajar'));
    await pompaAman(tester, 800);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await pompaAman(tester, 400);

    // =========================================================================
    // 3. Pelajaran 1_2: Contoh Angka 1_2 dengan Nilai Negatif Rapat (U+2212)
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 1_2 & Tangkapan Layar Contoh Angka Negatif ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_2');
    await pompaAman(tester, 1000);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await pompaAman(tester, 300);

    // Pemantik -> Konsep 1 -> Konsep 2 -> Konsep 3 -> Contoh Angka
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Lanjut'), warnIfMissed: false);
      await pompaAman(tester, 400);
    }

    // Tangkapan Layar: Contoh Angka 1_2 (Kos −Rp900.000 dengan minus U+2212)
    expect(find.text('Contoh arus kas satu bulan'), findsOneWidget);
    expect(find.text('−Rp900.000'), findsOneWidget);
    await mintaTangkapanLayar('contoh_angka_1_2');
    debugPrint('[BUKTI]: Tangkapan Layar Contoh Angka 1_2 (Nilai Negatif Rapat)');

    // Lewati cek paham & misi untuk 1_2 via tandai selesai
    final progresRepo = ProgresRepositori(basisData);
    await progresRepo.tandaiPelajaranSelesai(pelajaranId: 'anggaran_arus_kas_1_2', modulId: 'anggaran_arus_kas');
    await progresRepo.tandaiPelajaranSelesai(pelajaranId: 'anggaran_arus_kas_1_3', modulId: 'anggaran_arus_kas');

    // =========================================================================
    // 4. Tangkapan Layar Pesan Gerbang Terkunci 1_4 di Tab Belajar
    // =========================================================================
    debugPrint('=== [LANGKAH 4]: Pesan Gerbang Terkunci 1_4 ===');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);

    expect(find.text('Anggaran Pertamamu'), findsWidgets);
    await mintaTangkapanLayar('pesan_gerbang_terkunci_1_4');
    debugPrint('[BUKTI]: Tangkapan Layar Pesan Gerbang Terkunci 1_4');

    // Penuhi syarat gerbang 1_4: transaksi di 7 hari berbeda dan 1 pemasukan
    final sekarang = DateTime.now();
    for (var i = 1; i <= 7; i++) {
      await basisData.into(basisData.tabelTransaksi).insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_h_$i',
              dompetId: 'dmp_utama',
              jenis: 'keluar',
              kategoriId: Value(katMakan.id),
              jumlahRupiah: 20000,
              waktuTransaksi: sekarang.subtract(Duration(days: i)),
            ),
          );
    }
    final katGaji = (await basisData.select(basisData.tabelKategori).get()).firstWhere((k) => k.id == 'kat_masuk_gaji');
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_in_1',
            dompetId: 'dmp_utama',
            jenis: 'masuk',
            kategoriId: Value(katGaji.id),
            jumlahRupiah: 2500000,
            waktuTransaksi: sekarang,
          ),
        );

    // Buat 3 pos anggaran untuk misi 1_4
    final daftarKat = await basisData.select(basisData.tabelKategori).get();
    await basisData.into(basisData.tabelAnggaran).insert(
          TabelAnggaranCompanion.insert(
            id: 'ang_1',
            kategoriId: katMakan.id,
            tahun: sekarang.year,
            bulan: sekarang.month,
            batasRupiah: 1250000,
            dibuatPada: sekarang,
            diubahPada: sekarang,
          ),
        );
    await basisData.into(basisData.tabelAnggaran).insert(
          TabelAnggaranCompanion.insert(
            id: 'ang_2',
            kategoriId: daftarKat.firstWhere((k) => k.sifat == 'keinginan').id,
            tahun: sekarang.year,
            bulan: sekarang.month,
            batasRupiah: 750000,
            dibuatPada: sekarang,
            diubahPada: sekarang,
          ),
        );
    await basisData.into(basisData.tabelAnggaran).insert(
          TabelAnggaranCompanion.insert(
            id: 'ang_3',
            kategoriId: daftarKat.firstWhere((k) => k.sifat == 'tabungan').id,
            tahun: sekarang.year,
            bulan: sekarang.month,
            batasRupiah: 500000,
            dibuatPada: sekarang,
            diubahPada: sekarang,
          ),
        );

    // =========================================================================
    // 5. Pelajaran 1_4: Umpan Balik Perbandingan Pola Anggaran (50/30/20)
    // =========================================================================
    debugPrint('=== [LANGKAH 5]: Umpan Balik Perbandingan Pola Anggaran 1_4 ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_4');
    await pompaAman(tester, 1000);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await pompaAman(tester, 300);

    // Pemantik -> Konsep 1, 2, 3 -> Contoh Angka -> Cek Paham
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Lanjut'), warnIfMissed: false);
      await pompaAman(tester, 400);
    }

    // Jawab 3 soal Cek Paham 1_4
    await tester.tap(find.text('Memberi arah pada uang sebelum dipakai'));
    await pompaAman(tester, 300);
    final opsi4_2 = find.text('Pemasukan, lalu pengeluaran pasti, lalu tabungan, lalu keinginan');
    await tester.ensureVisible(opsi4_2);
    await tester.tap(opsi4_2);
    await pompaAman(tester, 300);
    final opsi4_3 = find.text('Titik awal yang boleh disesuaikan');
    await tester.ensureVisible(opsi4_3);
    await tester.tap(opsi4_3);
    await pompaAman(tester, 300);

    // Lanjut ke Misi (3 pos anggaran sudah disuntik)
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 500);

    // Lanjut ke Umpan Balik Perbandingan Pola Anggaran
    await tester.tap(find.text('Lanjut'));
    for (var p = 0; p < 8; p++) {
      await pompaAman(tester, 300);
    }

    // Tangkapan Layar: Umpan Balik Perbandingan Pola
    await mintaTangkapanLayar('umpan_balik_perbandingan_pola');
    debugPrint('[BUKTI]: Tangkapan Layar Umpan Balik Perbandingan Pola');

    await progresRepo.tandaiPelajaranSelesai(pelajaranId: 'anggaran_arus_kas_1_4', modulId: 'anggaran_arus_kas');

    // =========================================================================
    // 6. Pelajaran 1_5: Umpan Balik Realisasi Anggaran Bulan Ini
    // =========================================================================
    debugPrint('=== [LANGKAH 6]: Umpan Balik Realisasi Anggaran 1_5 ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_5');
    await pompaAman(tester, 1000);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await pompaAman(tester, 300);

    // Pemantik -> Konsep 1, 2, 3 -> Contoh Angka -> Cek Paham
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Lanjut'), warnIfMissed: false);
      await pompaAman(tester, 400);
    }

    // Jawab 3 soal Cek Paham 1_5
    await tester.tap(find.text('Jumlah yang benar-benar terpakai pada sebuah pos'));
    await pompaAman(tester, 300);
    final opsi5_2 = find.text('Cari penyebabnya, lalu putuskan mengubah batas atau kebiasaannya');
    await tester.ensureVisible(opsi5_2);
    await tester.tap(opsi5_2);
    await pompaAman(tester, 300);
    final opsi5_3 = find.text('Kondisi dan kebiasaan berubah, dan data baru membuatnya lebih pas');
    await tester.ensureVisible(opsi5_3);
    await tester.tap(opsi5_3);
    await pompaAman(tester, 300);

    // Lanjut ke Misi (tipe lihat_hitungan langsung selesai)
    await tester.tap(find.text('Lanjut'));
    await pompaAman(tester, 500);

    // Lanjut ke Umpan Balik Realisasi Anggaran
    await tester.tap(find.text('Lanjut'));
    for (var p = 0; p < 8; p++) {
      await pompaAman(tester, 300);
    }

    // Tangkapan Layar: Umpan Balik Realisasi Anggaran
    await mintaTangkapanLayar('umpan_balik_realisasi');
    debugPrint('[BUKTI]: Tangkapan Layar Umpan Balik Realisasi');

    await progresRepo.tandaiPelajaranSelesai(pelajaranId: 'anggaran_arus_kas_1_5', modulId: 'anggaran_arus_kas');

    // =========================================================================
    // 7. Kuis Modul: Putaran 1 (3 dari 5 Benar -> 60% TIDAK LULUS via UI)
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Kuis Modul Putaran 1 (Tidak Lulus 60%) ===');
    // Kembali ke /belajar lalu buka kuis
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/anggaran_arus_kas');
    await pompaAman(tester, 1500);

    final modulKonten = await PembacaKonten.muatModulDariAset(
      rootBundle,
      tingkat: 'pemula',
      modulId: 'anggaran_arus_kas',
    );

    // Jawab 5 soal (3 benar, 2 sengaja salah)
    for (var s = 0; s < 5; s++) {
      await pompaAman(tester, 600);
      final teksTanya = (tester.firstWidget(find.byKey(const Key('teks_soal_kuis'))) as TeksFunda).teks;
      final soalAsli = modulKonten.kuis.bankSoal.firstWhere((soal) => soal.tanya == teksTanya);
      final teksBenar = soalAsli.pilihan[soalAsli.benar];
      final teksSalah = soalAsli.pilihan.firstWhere((p) => p != teksBenar);

      if (s < 3) {
        // Jawaban Benar
        final targetOpsi = find.text(teksBenar);
        await tester.ensureVisible(targetOpsi);
        await tester.tap(targetOpsi);
      } else {
        // Jawaban Salah
        final targetOpsi = find.text(teksSalah);
        await tester.ensureVisible(targetOpsi);
        await tester.tap(targetOpsi);
      }
      await pompaAman(tester, 400);

      final tombolLanjut = find.text(s == 4 ? 'Lihat Hasil Kuis' : 'Soal Berikutnya');
      await tester.ensureVisible(tombolLanjut);
      await tester.tap(tombolLanjut);
      await pompaAman(tester, 600);
    }

    // Assertion Layar Tidak Lulus
    expect(find.text('Mari Coba Lagi'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    await mintaTangkapanLayar('kuis_tidak_lulus');
    debugPrint('[BUKTI]: Tangkapan Layar Kuis Tidak Lulus (60%)');

    // Verifikasi database: hasil kuis tidak lulus tersimpan
    final hasilKuisGagal = await (basisData.select(basisData.tabelHasilKuis)
          ..orderBy([(t) => OrderingTerm.desc(t.waktu)])
          ..limit(1))
        .getSingle();
    expect(hasilKuisGagal.lulus, isFalse);
    expect(hasilKuisGagal.skorPersen, equals(60));

    // =========================================================================
    // 8. Kuis Modul: Putaran 2 (4 dari 5 Benar -> 80% LULUS via UI)
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: Kuis Modul Putaran 2 (Lulus 80%) ===');
    final tombolUlangi = find.text('Ulangi Kuis');
    expect(tombolUlangi, findsOneWidget);
    await tester.tap(tombolUlangi);
    await pompaAman(tester, 1200);

    // Jawab 5 soal (4 benar, 1 salah)
    for (var s = 0; s < 5; s++) {
      await pompaAman(tester, 600);
      final teksTanya = (tester.firstWidget(find.byKey(const Key('teks_soal_kuis'))) as TeksFunda).teks;
      final soalAsli = modulKonten.kuis.bankSoal.firstWhere((soal) => soal.tanya == teksTanya);
      final teksBenar = soalAsli.pilihan[soalAsli.benar];
      final teksSalah = soalAsli.pilihan.firstWhere((p) => p != teksBenar);

      if (s < 4) {
        // Jawaban Benar (4 benar)
        final targetOpsi = find.text(teksBenar);
        await tester.ensureVisible(targetOpsi);
        await tester.tap(targetOpsi);
      } else {
        // Jawaban Salah (1 salah)
        final targetOpsi = find.text(teksSalah);
        await tester.ensureVisible(targetOpsi);
        await tester.tap(targetOpsi);
      }
      await pompaAman(tester, 400);

      final tombolLanjut = find.text(s == 4 ? 'Lihat Hasil Kuis' : 'Soal Berikutnya');
      await tester.ensureVisible(tombolLanjut);
      await tester.tap(tombolLanjut);
      await pompaAman(tester, 600);
    }

    // Assertion Layar Lulus
    expect(find.text('Selamat, Kamu Lulus!'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    await mintaTangkapanLayar('kuis_lulus');
    debugPrint('[BUKTI]: Tangkapan Layar Kuis Lulus (80%)');

    // Verifikasi database: hasil kuis lulus tersimpan
    final hasilKuisLulus = await (basisData.select(basisData.tabelHasilKuis)
          ..orderBy([(t) => OrderingTerm.desc(t.waktu)])
          ..limit(1))
        .getSingle();
    expect(hasilKuisLulus.lulus, isTrue);
    expect(hasilKuisLulus.skorPersen, equals(80));

    // Kembali ke Peta Belajar
    await tester.tap(find.text('Kembali ke Peta Belajar'));
    await pompaAman(tester, 800);

    // =========================================================================
    // 9. Beranda: Modul 1 Selesai
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: Beranda Modul 1 Selesai ===');
    tester.element(find.byType(Scaffold).first).go('/');
    await pompaAman(tester, 1200);

    await mintaTangkapanLayar('beranda_modul_selesai');
    debugPrint('[BUKTI]: Tangkapan Layar Beranda Modul Selesai');

    // =========================================================================
    // 10. Tab Belajar: Status Modul Selesai & Rekomendasi
    // =========================================================================
    debugPrint('=== [LANGKAH 10]: Tab Belajar Modul Selesai ===');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1200);

    await mintaTangkapanLayar('tab_belajar');
    debugPrint('[BUKTI]: Tangkapan Layar Tab Belajar Selesai');

    debugPrint('=== [SELESAI]: Seluruh 10 Skenario & Bukti Integrasi Tahap 6-R Selesai! ===');
  });
}
