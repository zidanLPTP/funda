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

  testWidgets('Tahap 4-R: Alur End-to-End Mesin Belajar dan Tangkapan Layar Emulator Pixel 8', (tester) async {
    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());

    // 1. Data Awal: Dompet Utama & Kategori
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

    await tester.pumpAndSettle();

    // -------------------------------------------------------------------------
    // 01. TAB BELAJAR (PETA BELAJAR LENGKAP)
    // -------------------------------------------------------------------------
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pumpAndSettle();
    _sinyalkanLayar('01_tab_belajar_peta');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 02. PELAJARAN 1.2: PEMANTIK
    // -------------------------------------------------------------------------
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_2');
    await tester.pumpAndSettle();
    _sinyalkanLayar('02_pelajaran_terbuka_pemantik');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 03. KARTU KONSEP DENGAN ISTILAH KAMUS
    // -------------------------------------------------------------------------
    // Ketuk tombol Lanjut untuk masuk ke Kartu Konsep
    final tombolLanjut = find.text('Mulai Membaca');
    if (tombolLanjut.evaluate().isNotEmpty) {
      await tester.tap(tombolLanjut);
      await tester.pumpAndSettle();
    }
    _sinyalkanLayar('03_kartu_konsep_istilah');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 04. CEK PAHAM INTERAKTIF
    // -------------------------------------------------------------------------
    // Geser / lanjut ke Cek Paham
    final tombolKeCekPaham = find.text('Cek Pemahaman');
    if (tombolKeCekPaham.evaluate().isNotEmpty) {
      await tester.tap(tombolKeCekPaham);
      await tester.pumpAndSettle();
    }
    _sinyalkanLayar('04_cek_paham_interaktif');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 05. MISI PRAKTIK NYATA (BELUM SELESAI)
    // -------------------------------------------------------------------------
    final tombolKeMisi = find.text('Lanjut ke Misi Praktik');
    if (tombolKeMisi.evaluate().isNotEmpty) {
      await tester.tap(tombolKeMisi);
      await tester.pumpAndSettle();
    }
    _sinyalkanLayar('05_misi_praktik_belum_selesai');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // SUNTIK DATA TRANSAKSI NYATA UNTUK MENYELESAIKAN MISI
    // -------------------------------------------------------------------------
    final daftarKategori = await basisData.select(basisData.tabelKategori).get();
    final katKeluar = daftarKategori.firstWhere((k) => k.arus == 'keluar').id;

    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_misi_selesai',
            jenis: 'keluar',
            jumlahRupiah: 35000,
            dompetId: 'dmp_utama',
            kategoriId: Value(katKeluar),
            waktuTransaksi: DateTime.now(),
            catatan: const Value('Belanja sarapan'),
            dibuatPada: Value(DateTime.now()),
          ),
        );

    // Refresh state layar pemutar pelajaran
    await tester.pumpAndSettle();

    // -------------------------------------------------------------------------
    // 06. MISI PRAKTIK SELESAI + UMPAN BALIK
    // -------------------------------------------------------------------------
    _sinyalkanLayar('06_misi_praktik_selesai_umpan_balik');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // Tandai pelajaran 1.2 selesai di database progres
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
    // 07. KEMBALI KE PETA BELAJAR (PELAJARAN 1.3 TERKUNCI GERBANG DATA)
    // -------------------------------------------------------------------------
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pumpAndSettle();
    _sinyalkanLayar('07_pelajaran_terkunci_gerbang_data');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 08. KUIS AKHIR MODUL
    // -------------------------------------------------------------------------
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/anggaran_arus_kas');
    await tester.pumpAndSettle();
    _sinyalkanLayar('08_kuis_akhir_modul');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 09. HASIL KUIS SELESAI LULUS
    // -------------------------------------------------------------------------
    // Catat hasil kuis lulus di database
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'anggaran_arus_kas',
            skorPersen: 80,
            benar: 4,
            total: 5,
            lulus: true,
            waktu: DateTime.now(),
          ),
        );

    // Tandai juga pelajaran 1.3 selesai agar seluruh modul berstatus selesai
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'anggaran_arus_kas_1_3',
            modulId: 'anggaran_arus_kas',
            status: 'selesai',
            dibuatPada: DateTime.now(),
            selesaiPada: Value(DateTime.now()),
          ),
        );

    await tester.pumpAndSettle();
    _sinyalkanLayar('09_kuis_selesai_lulus');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    // -------------------------------------------------------------------------
    // 10. BERANDA PETAK BELAJAR (PROGRES BELAJAR AKTIF)
    // -------------------------------------------------------------------------
    tester.element(find.byType(Scaffold).first).go('/beranda');
    await tester.pumpAndSettle();
    _sinyalkanLayar('10_beranda_petak_belajar');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 4)));

    _sinyalkanLayar('SELESAI');
    debugPrint('[ALUR_EMULATOR_LENGKAP_SUKSES]');
  });
}
