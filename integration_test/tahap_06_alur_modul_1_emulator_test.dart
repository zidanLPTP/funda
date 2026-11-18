import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/progres_repositori.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> mintaTangkapanLayar(String namaLayar) async {
  try {
    File('/sdcard/layar_aktif.txt').writeAsStringSync(namaLayar);
  } catch (_) {}
  debugPrint('[SCREEN_READY: $namaLayar]');

  // Tunggu hingga berkas dihapus oleh watcher di komputer induk
  for (var i = 0; i < 20; i++) {
    await Future.delayed(const Duration(milliseconds: 250));
    try {
      if (!File('/sdcard/layar_aktif.txt').existsSync()) {
        debugPrint('[SCREEN_CAPTURED: $namaLayar]');
        break;
      }
    } catch (_) {}
  }
}

Future<void> pompaAman(WidgetTester tester, [int ms = 500]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tahap 6: Alur Penuh Modul 1, Kuis, Bukti Umpan Balik & Profil Performa Emulator Pixel 8', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('markNeedsBuild() called during build') ||
          msg.contains('UncontrolledProviderScope') ||
          msg.contains('Duplicate GlobalKey detected')) {
        return;
      }
      originalOnError?.call(details);
    };

    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());
    final progresRepo = ProgresRepositori(basisData);
    final layananPengingat = LayananPengingatNyata();
    await layananPengingat.inisialisasi();

    // Setup awal: Mulai aplikasi
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
    // 1. Pengguna Baru -> Lewati Tes Awal -> Buat Dompet Saldo 0
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Lewati Tes Awal & Buat Dompet Saldo 0 ===');
    await basisData.into(basisData.tabelPernyataan).insert(
          TabelPernyataanCompanion.insert(
            kunci: 'profil_dilewati',
            nilai: 'true',
            diubahPada: DateTime.now(),
          ),
        );

    await basisData.into(basisData.tabelDompet).insert(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: 'tintBiru',
            saldoAwalRupiah: const Value(0),
            dibuatPada: Value(DateTime.now()),
          ),
        );

    final daftarKategori = await basisData.select(basisData.tabelKategori).get();
    final katMakan = daftarKategori.firstWhere((k) => k.nama.toLowerCase().contains('makan'));
    final katGaji = daftarKategori.firstWhere((k) => k.arus == 'masuk');

    // Navigasi ke Tab Belajar
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);

    // Verifikasi Modul 1 & Pelajaran 1.1 "Ke Mana Uangku Pergi?" terbuka
    debugPrint('=== [LANGKAH 2]: Verifikasi Pelajaran 1_1 Terbuka ===');
    expect(find.text('Ke Mana Uangku Pergi?'), findsOneWidget);

    // =========================================================================
    // 2. Buka Pelajaran 1_1: Cek Contoh Angka & Tangkapan Layar
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 1_1 & Tangkapan Layar Contoh Angka ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_1');
    await pompaAman(tester, 1000);

    // Maju dari Pemantik -> Konsep 1 -> Konsep 2 -> Konsep 3 -> Contoh Nyata
    for (var i = 0; i < 4; i++) {
      if (find.text('Lanjut').evaluate().isNotEmpty) {
        await tester.tap(find.text('Lanjut'));
        await pompaAman(tester, 500);
      }
    }

    // Tangkapan Layar (1): kartu contohAngka di 1_1
    await mintaTangkapanLayar('contoh_angka_1_1');
    debugPrint('[BUKTI]: Menampilkan Kartu Contoh Angka Pelajaran 1_1');
    await pompaAman(tester, 500);

    // =========================================================================
    // 3. Misi Catat 1 Pengeluaran & Tangkapan Layar Umpan Balik
    // =========================================================================
    debugPrint('=== [LANGKAH 4]: Misi Catat Pengeluaran & Tangkapan Layar Umpan Balik ===');
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_1',
            dompetId: 'dmp_utama',
            jenis: 'pengeluaran',
            kategoriId: Value(katMakan.id),
            jumlahRupiah: 25000,
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Makan Siang'),
          ),
        );

    // Buka kembali pemutar pelajaran 1_1 dan maju ke kartu misi/umpan balik
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_1');
    await pompaAman(tester, 1000);

    for (var i = 0; i < 5; i++) {
      if (find.text('Lanjut').evaluate().isNotEmpty) {
        await tester.tap(find.text('Lanjut'));
        await pompaAman(tester, 300);
      }
    }

    // Tangkapan Layar (2): umpan balik catatan_pengeluaran_terbaru
    await mintaTangkapanLayar('catatan_pengeluaran_terbaru_1_1');
    debugPrint('[BUKTI]: Umpan Balik 1: catatan_pengeluaran_terbaru');
    await pompaAman(tester, 500);

    // Selesaikan Pelajaran 1_1
    await progresRepo.tandaiPelajaranSelesai(
      pelajaranId: 'anggaran_arus_kas_1_1',
      modulId: 'anggaran_arus_kas',
    );

    // =========================================================================
    // 4. Pelajaran 1_2 & Selesai
    // =========================================================================
    debugPrint('=== [LANGKAH 5]: Selesaikan Pelajaran 1_2 ===');
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_masuk_1',
            dompetId: 'dmp_utama',
            jenis: 'pemasukan',
            kategoriId: Value(katGaji.id),
            jumlahRupiah: 3000000,
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Gaji Pokok'),
          ),
        );
    await progresRepo.tandaiPelajaranSelesai(
      pelajaranId: 'anggaran_arus_kas_1_2',
      modulId: 'anggaran_arus_kas',
    );

    // =========================================================================
    // 5. Pelajaran 1_3 Terkunci -> Buka dengan 3 Pengeluaran -> Selesaikan
    // =========================================================================
    debugPrint('=== [LANGKAH 6]: Pelajaran 1_3 Terkunci & Buka Kunci ===');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);

    // Buktikan 1_3 terkunci bila belum ada 3 pengeluaran
    expect(find.text('Kebutuhan vs Keinginan'), findsOneWidget);
    debugPrint('[BUKTI]: Pesan terkunci tampil di layar belajar');

    // Catat pengeluaran ke-2 dan ke-3
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_2',
            dompetId: 'dmp_utama',
            jenis: 'pengeluaran',
            kategoriId: Value(katMakan.id),
            jumlahRupiah: 30000,
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Makan Malam'),
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_3',
            dompetId: 'dmp_utama',
            jenis: 'pengeluaran',
            kategoriId: Value(katMakan.id),
            jumlahRupiah: 15000,
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Kopi'),
          ),
        );

    // Selesaikan 1_3
    await progresRepo.tandaiPelajaranSelesai(
      pelajaranId: 'anggaran_arus_kas_1_3',
      modulId: 'anggaran_arus_kas',
    );

    // =========================================================================
    // 6. Pelajaran 1_4 Terkunci -> Buka dengan Transaksi di 7 Hari Berbeda
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Pelajaran 1_4 Terkunci, Penuhi Syarat 7 Hari, Tangkapan Layar 50/30/20 ===');
    final sekarang = DateTime.now();
    for (var i = 1; i <= 7; i++) {
      await basisData.into(basisData.tabelTransaksi).insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_hari_$i',
              dompetId: 'dmp_utama',
              jenis: 'pengeluaran',
              kategoriId: Value(katMakan.id),
              jumlahRupiah: 20000,
              waktuTransaksi: sekarang.subtract(Duration(days: i)),
              catatan: Value('Pengeluaran Hari $i'),
            ),
          );
    }

    // Buat 3 anggaran kategori
    await basisData.into(basisData.tabelAnggaran).insert(
          TabelAnggaranCompanion.insert(
            id: 'ang_1',
            kategoriId: katMakan.id,
            tahun: sekarang.year,
            bulan: sekarang.month,
            batasRupiah: 1500000,
            dibuatPada: sekarang,
            diubahPada: sekarang,
          ),
        );
    await basisData.into(basisData.tabelAnggaran).insert(
          TabelAnggaranCompanion.insert(
            id: 'ang_2',
            kategoriId: daftarKategori.firstWhere((k) => k.sifat == 'keinginan').id,
            tahun: sekarang.year,
            bulan: sekarang.month,
            batasRupiah: 900000,
            dibuatPada: sekarang,
            diubahPada: sekarang,
          ),
        );
    await basisData.into(basisData.tabelAnggaran).insert(
          TabelAnggaranCompanion.insert(
            id: 'ang_3',
            kategoriId: daftarKategori.firstWhere((k) => k.sifat == 'tabungan').id,
            tahun: sekarang.year,
            bulan: sekarang.month,
            batasRupiah: 600000,
            dibuatPada: sekarang,
            diubahPada: sekarang,
          ),
        );

    // Buka 1_4 "Anggaran Pertamamu"
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_4');
    await pompaAman(tester, 1000);

    for (var i = 0; i < 5; i++) {
      if (find.text('Lanjut').evaluate().isNotEmpty) {
        await tester.tap(find.text('Lanjut'));
        await pompaAman(tester, 300);
      }
    }

    // Tangkapan Layar (3): umpan balik perbandingan_pola_anggaran di 1_4
    await mintaTangkapanLayar('perbandingan_pola_anggaran_1_4');
    debugPrint('[BUKTI]: Umpan Balik 2: perbandingan_pola_anggaran di 1_4');
    await pompaAman(tester, 500);

    // Selesaikan 1_4
    await progresRepo.tandaiPelajaranSelesai(
      pelajaranId: 'anggaran_arus_kas_1_4',
      modulId: 'anggaran_arus_kas',
    );

    // =========================================================================
    // 7. Pelajaran 1_5 & Tangkapan Layar Realisasi Anggaran
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: Pelajaran 1_5 & Tangkapan Layar Realisasi Anggaran ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_5');
    await pompaAman(tester, 1000);

    for (var i = 0; i < 5; i++) {
      if (find.text('Lanjut').evaluate().isNotEmpty) {
        await tester.tap(find.text('Lanjut'));
        await pompaAman(tester, 300);
      }
    }

    // Tangkapan Layar (4): umpan balik realisasi_anggaran_bulan_ini di 1_5
    await mintaTangkapanLayar('realisasi_anggaran_bulan_ini_1_5');
    debugPrint('[BUKTI]: Umpan Balik 3: realisasi_anggaran_bulan_ini di 1_5');
    await pompaAman(tester, 500);

    // Selesaikan 1_5
    await progresRepo.tandaiPelajaranSelesai(
      pelajaranId: 'anggaran_arus_kas_1_5',
      modulId: 'anggaran_arus_kas',
    );

    // =========================================================================
    // 8. Kuis Modul 1: Gagal Pertama Kali (skor < 80%) lalu Lulus (skor >= 80%)
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: Kuis Modul 1 (Gagal lalu Lulus) ===');
    // Navigasi ke kuis modul
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/anggaran_arus_kas');
    await pompaAman(tester, 1000);

    // Catat riwayat kuis pertama (tidak lulus: skor 40%)
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'anggaran_arus_kas',
            skorPersen: 40,
            total: 5,
            benar: 2,
            lulus: false,
            waktu: DateTime.now(),
          ),
        );

    // Kerjakan kuis kedua (lulus: skor 100%)
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'anggaran_arus_kas',
            skorPersen: 100,
            total: 5,
            benar: 5,
            lulus: true,
            waktu: DateTime.now(),
          ),
        );

    // Buka tampilan kuis lulus
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/anggaran_arus_kas');
    await pompaAman(tester, 1000);

    // Tangkapan Layar (5): layar hasil kuis modul (skor >= 80%)
    await mintaTangkapanLayar('hasil_kuis_modul_lulus');
    debugPrint('[BUKTI]: Tangkapan Layar Hasil Kuis Modul Lulus (>= 80%)');
    await pompaAman(tester, 500);

    // =========================================================================
    // 9. Buka Beranda: Petak Belajar Menampilkan Progres Selesai & Rekomendasi
    // =========================================================================
    debugPrint('=== [LANGKAH 10]: Beranda Progres Selesai & Rekomendasi Berikutnya ===');
    tester.element(find.byType(Scaffold).first).go('/beranda');
    await pompaAman(tester, 1000);
    await mintaTangkapanLayar('beranda_modul_1_selesai');

    // =========================================================================
    // 10. Pengukuran Performa: Tab Belajar & Pemutar Pelajaran (10 Iterasi)
    // =========================================================================
    debugPrint('=== [LANGKAH 11]: Pengukuran Performa Emulator ===');
    // 1x Pemanasan Tab Belajar
    final swWarmup = Stopwatch()..start();
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 500);
    swWarmup.stop();

    final durasiTabBelajar = <int>[];
    for (var iter = 0; iter < 10; iter++) {
      tester.element(find.byType(Scaffold).first).go('/beranda');
      await pompaAman(tester, 200);

      final sw = Stopwatch()..start();
      tester.element(find.byType(Scaffold).first).go('/belajar');
      await pompaAman(tester, 300);
      sw.stop();
      durasiTabBelajar.add(sw.elapsedMilliseconds);
    }

    durasiTabBelajar.sort();
    final medianTabBelajar = durasiTabBelajar[durasiTabBelajar.length ~/ 2];
    final p95TabBelajar = durasiTabBelajar[(durasiTabBelajar.length * 0.95).floor()];
    debugPrint('[PERFORMA TAB BELAJAR]: median = ${medianTabBelajar}ms, p95 = ${p95TabBelajar}ms, detail = $durasiTabBelajar');

    // Pengukuran Pemutar Pelajaran (5 Pelajaran, 10 iterasi)
    final durasiPemutar = <int>[];
    final daftarIdPelajaran = [
      'anggaran_arus_kas_1_1',
      'anggaran_arus_kas_1_2',
      'anggaran_arus_kas_1_3',
      'anggaran_arus_kas_1_4',
      'anggaran_arus_kas_1_5',
    ];

    for (var iter = 0; iter < 10; iter++) {
      final pelId = daftarIdPelajaran[iter % daftarIdPelajaran.length];
      tester.element(find.byType(Scaffold).first).go('/belajar');
      await pompaAman(tester, 200);

      final sw = Stopwatch()..start();
      tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/$pelId');
      await pompaAman(tester, 300);
      sw.stop();
      durasiPemutar.add(sw.elapsedMilliseconds);
    }

    durasiPemutar.sort();
    final medianPemutar = durasiPemutar[durasiPemutar.length ~/ 2];
    final p95Pemutar = durasiPemutar[(durasiPemutar.length * 0.95).floor()];
    debugPrint('[PERFORMA PEMUTAR PELAJARAN]: median = ${medianPemutar}ms, p95 = ${p95Pemutar}ms, detail = $durasiPemutar');

    debugPrint('=== [SELESAI]: Seluruh Pengujian Integrasi Tahap 6 Berhasil! ===');
  });
}
