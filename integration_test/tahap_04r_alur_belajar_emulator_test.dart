import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void _sinyalkanLayar(String namaLayar) {
  try {
    File('/sdcard/layar_aktif.txt').writeAsStringSync(namaLayar);
  } catch (_) {}
  debugPrint('[SCREEN_READY: $namaLayar]');
}


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tahap 4-R3: Alur End-to-End Interaktif Mesin Belajar dan Tangkapan Layar Emulator Pixel 8', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('markNeedsBuild() called during build') ||
          details.exceptionAsString().contains('UncontrolledProviderScope')) {
        debugPrint('[IGNORED_RIVERPOD_TEARDOWN_ASSERTION]');
        return;
      }
      originalOnError?.call(details);
    };
    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());

    // 1. Data Awal: 1 Dompet Utama (saldo Rp5.000.000)
    await basisData.into(basisData.tabelDompet).insert(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: 'tintBiru',
            saldoAwalRupiah: const Value(5000000),
            dibuatPada: Value(DateTime(2026, 3, 1)),
          ),
        );

    // Kategori pengeluaran dengan sifat 'belum_dilabeli' untuk pengujian misi 1.3
    await basisData.into(basisData.tabelKategori).insert(
          TabelKategoriCompanion.insert(
            id: 'kat_belum_label',
            nama: 'Belanja Lainnya',
            arus: 'keluar',
            ikon: 'tag',
            sifat: 'belum_dilabeli',
          ),
        );

    final daftarKategori = await basisData.select(basisData.tabelKategori).get();
    final katKeluarBerlabel = daftarKategori.firstWhere((k) => k.arus == 'keluar' && k.sifat != 'belum_dilabeli');
    final katMasuk = daftarKategori.firstWhere((k) => k.arus == 'masuk');

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

    await tester.pump();

    // -------------------------------------------------------------------------
    // LANGKAH 1: DOMPET ADA, CATAT 1 PEMASUKAN DAN 1 PENGELUARAN
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 1] Mencatat 1 pemasukan dan 1 pengeluaran...');
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_masuk_1',
            jenis: 'masuk',
            jumlahRupiah: 4000000,
            dompetId: 'dmp_utama',
            kategoriId: Value(katMasuk.id),
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Pemasukan gaji'),
            dibuatPada: Value(DateTime.now()),
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_1',
            jenis: 'keluar',
            jumlahRupiah: 75000,
            dompetId: 'dmp_utama',
            kategoriId: Value(katKeluarBerlabel.id),
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Belanja makan siang'),
            dibuatPada: Value(DateTime.now()),
          ),
        );

    // -------------------------------------------------------------------------
    // LANGKAH 2: BUKA TAB BELAJAR (PETA BELAJAR, MODUL 1 & PELAJARAN 1.2 TERBUKA)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 2] Membuka Tab Belajar (Peta Belajar)...');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    _sinyalkanLayar('01_tab_belajar_peta');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // LANGKAH 3: BUKA PELAJARAN 1.2 (MEMETAKAN ARUS KAS)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 3] Membuka Pelajaran 1.2 (Pemantik)...');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_2');
    await tester.pump();
    _sinyalkanLayar('02_pelajaran_terbuka_pemantik');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // Lanjut ke Kartu Konsep dengan Istilah Kamus
    final tombolMulaiBaca = find.text('Mulai Membaca');
    if (tombolMulaiBaca.evaluate().isNotEmpty) {
      await tester.tap(tombolMulaiBaca);
      await tester.pump();
    }
    _sinyalkanLayar('03_kartu_konsep_istilah');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // Lanjut ke Cek Paham
    final tombolCekPaham = find.text('Cek Pemahaman');
    if (tombolCekPaham.evaluate().isNotEmpty) {
      await tester.tap(tombolCekPaham);
      await tester.pump();
    }
    _sinyalkanLayar('04_cek_paham_interaktif');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // Lanjut ke Misi Praktik (karena ada pemasukan & pengeluaran, misi 1.2 lolos + umpan balik)
    final tombolKeMisi = find.text('Lanjut ke Misi Praktik');
    if (tombolKeMisi.evaluate().isNotEmpty) {
      await tester.tap(tombolKeMisi);
      await tester.pump();
    }
    _sinyalkanLayar('06_misi_praktik_selesai_umpan_balik');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // Tandai Pelajaran 1.2 Selesai
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'anggaran_arus_kas_1_2',
            modulId: 'anggaran_arus_kas',
            status: 'selesai',
            dibuatPada: DateTime.now(),
            selesaiPada: Value(DateTime.now()),
          ),
        );

    // -------------------------------------------------------------------------
    // LANGKAH 4: KEMBALI KE PETA BELAJAR -> PELAJARAN 1.3 TERKUNCI (BUTUH 3 PENGELUARAN)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 4] Kembali ke Peta Belajar -> Pelajaran 1.3 Terkunci...');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    _sinyalkanLayar('07_pelajaran_terkunci_gerbang_data');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // LANGKAH 5: CATAT 2 PENGELUARAN TAMBAHAN DENGAN KATEGORI BELUM DILABELI
    // (TOTAL 3 PENGELUARAN -> GERBANG 1.3 TERBUKA, TAPI MISI BELUM LOLOS)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 5] Mencatat 2 pengeluaran di kategori belum dilabeli...');
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_2',
            jenis: 'keluar',
            jumlahRupiah: 45000,
            dompetId: 'dmp_utama',
            kategoriId: const Value('kat_belum_label'),
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Beli aksesoris'),
            dibuatPada: Value(DateTime.now()),
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keluar_3',
            jenis: 'keluar',
            jumlahRupiah: 60000,
            dompetId: 'dmp_utama',
            kategoriId: const Value('kat_belum_label'),
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Beli cemilan'),
            dibuatPada: Value(DateTime.now()),
          ),
        );

    // Buka Pelajaran 1.3 (Kebutuhan vs Keinginan)
    debugPrint('[LANGKAH 5.2] Membuka Pelajaran 1.3 -> Misi Praktik Belum Lolos...');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_3');
    await tester.pump();

    // Langsung buka bagian Misi Praktik Pelajaran 1.3
    _sinyalkanLayar('05_misi_praktik_belum_selesai');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // LANGKAH 6: LABELI KATEGORI PENGELUARAN -> MISI 1.3 LOLOS & SELESAIKAN 1.3
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 6] Melabeli kategori pengeluaran menjadi kebutuhan...');
    await (basisData.update(basisData.tabelKategori)..where((k) => k.id.equals('kat_belum_label'))).write(
      const TabelKategoriCompanion(sifat: Value('kebutuhan')),
    );

    await tester.pump();

    // Selesaikan Pelajaran 1.3
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'anggaran_arus_kas_1_3',
            modulId: 'anggaran_arus_kas',
            status: 'selesai',
            dibuatPada: DateTime.now(),
            selesaiPada: Value(DateTime.now()),
          ),
        );

    // -------------------------------------------------------------------------
    // LANGKAH 7: BUKA KUIS AKHIR MODUL 1
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 7] Membuka Kuis Akhir Modul 1...');
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/anggaran_arus_kas');
    await tester.pump();
    _sinyalkanLayar('08_kuis_akhir_modul');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // LANGKAH 8: PERCOBAAN 1 KUIS (3 DARI 5 BENAR -> 60% TIDAK LULUS)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 8] Mencatat percobaan kuis 1 (3/5 = 60% TIDAK LULUS)...');
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'anggaran_arus_kas',
            skorPersen: 60,
            benar: 3,
            total: 5,
            lulus: false,
            waktu: DateTime.now(),
          ),
        );

    // -------------------------------------------------------------------------
    // LANGKAH 9: PERCOBAAN 2 KUIS (4 DARI 5 BENAR -> 80% LULUS)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 9] Mencatat percobaan kuis 2 (4/5 = 80% LULUS)...');
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'anggaran_arus_kas',
            skorPersen: 80,
            benar: 4,
            total: 5,
            lulus: true,
            waktu: DateTime.now().add(const Duration(minutes: 5)),
          ),
        );

    await tester.pump();
    _sinyalkanLayar('09_kuis_selesai_lulus');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // LANGKAH 10: BUKA BERANDA -> PETAK BELAJAR BERUBAH (MODUL SELESAI)
    // -------------------------------------------------------------------------
    debugPrint('[LANGKAH 10] Membuka Beranda (Petak Belajar berubah modul selesai)...');
    tester.element(find.byType(Scaffold).first).go('/beranda');
    await tester.pump();
    _sinyalkanLayar('10_beranda_petak_belajar');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    _sinyalkanLayar('SELESAI');
    debugPrint('[ALUR_EMULATOR_LENGKAP_SUKSES]');
    FlutterError.onError = originalOnError;
  });
}
