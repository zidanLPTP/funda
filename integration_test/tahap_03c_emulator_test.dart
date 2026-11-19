import '../test/pembantu/pompa_uji.dart';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void _sinyalkanLayar(String namaLayar) {
  try {
    final dir = Directory('/data/data/com.funda.funda/files');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File(
      '/data/data/com.funda.funda/files/layar_aktif.txt',
    ).writeAsStringSync(namaLayar);
  } catch (_) {}
  try {
    File('/sdcard/layar_aktif.txt').writeAsStringSync(namaLayar);
  } catch (_) {}
  debugPrint('[SCREEN_READY: $namaLayar]');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tahap 3C-R: Benchmark Performa, Tangkapan Layar, dan Notifikasi Emulator', (
    tester,
  ) async {
    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());

    final daftarKategoriAwal = await basisData
        .select(basisData.tabelKategori)
        .get();
    final katKeluar = daftarKategoriAwal
        .firstWhere((k) => k.arus == 'keluar')
        .id;
    final katMasuk = daftarKategoriAwal.firstWhere((k) => k.arus == 'masuk').id;

    // 1. Buat 5 Dompet
    for (var i = 1; i <= 5; i++) {
      await basisData
          .into(basisData.tabelDompet)
          .insert(
            TabelDompetCompanion.insert(
              id: 'dmp_$i',
              nama: 'Dompet Utama $i',
              jenis: i == 1 ? 'tunai' : 'rekening_bank',
              ikon: 'wallet',
              warna: 'tintBiru',
              saldoAwalRupiah: const Value(10000000),
              dibuatPada: Value(DateTime(2026, 1, 1)),
            ),
          );
    }

    // 2. Suntikkan 20.000 Transaksi (batch insert berkinerja tinggi)
    debugPrint('[EMULATOR_SETUP] Menyuntikkan 20.000 transaksi...');
    final waktuAwal = DateTime(2026, 1, 1);
    for (var batchIdx = 0; batchIdx < 40; batchIdx++) {
      await basisData.batch((b) {
        for (var i = 0; i < 500; i++) {
          final idx = batchIdx * 500 + i;
          final isMasuk = idx % 5 == 0;
          b.insert(
            basisData.tabelTransaksi,
            TabelTransaksiCompanion.insert(
              id: 'tx_$idx',
              jenis: isMasuk ? 'masuk' : 'keluar',
              jumlahRupiah: (idx % 10 + 1) * 25000,
              dompetId: 'dmp_${(idx % 5) + 1}',
              kategoriId: Value(isMasuk ? katMasuk : katKeluar),
              waktuTransaksi: waktuAwal.add(Duration(hours: idx)),
              catatan: Value('Catatan transaksi $idx'),
              dibuatPada: Value(waktuAwal.add(Duration(hours: idx))),
            ),
          );
        }
      });
    }

    // 3. Suntikkan 20 Utang
    debugPrint('[EMULATOR_SETUP] Menyuntikkan 20 utang...');
    for (var i = 1; i <= 20; i++) {
      await basisData
          .into(basisData.tabelUtang)
          .insert(
            TabelUtangCompanion.insert(
              id: 'utg_$i',
              nama: 'Kewajiban Cicilan $i',
              jenis: i % 2 == 0 ? 'kpr' : 'kartu_kredit',
              pokokAwalRupiah: const Value(10000000),
              sisaAwalRupiah: 8000000,
              bungaBasisPoinPerTahun: const Value(1000),
              jenisBunga: 'tetap',
              tenorBulan: const Value(12),
              cicilanBulananRupiah: const Value(750000),
              tanggalJatuhTempoBulanan: Value((i % 28) + 1),
              status: const Value('aktif'),
              dibuatPada: DateTime(2026, 2, 1),
            ),
          );
    }

    // 4. Suntikkan 20 Tagihan Berulang
    debugPrint('[EMULATOR_SETUP] Menyuntikkan 20 tagihan...');
    for (var i = 1; i <= 20; i++) {
      await basisData
          .into(basisData.tabelTagihan)
          .insert(
            TabelTagihanCompanion.insert(
              id: 'tag_$i',
              nama: i % 2 == 0 ? 'Langganan Cloud $i' : 'Tagihan Listrik $i',
              jenis: i % 2 == 0 ? 'langganan' : 'tagihan',
              jumlahPerkiraanRupiah: Value(i % 3 == 0 ? null : (i * 50000)),
              kategoriId: katKeluar,
              dompetId: const Value('dmp_1'),
              frekuensi: i % 4 == 0 ? 'mingguan' : 'bulanan',
              jatuhTempoPertama: DateTime(2026, 3, (i % 25) + 1),
              pengingatHariSebelum: const Value('[0,1,3]'),
              dibuatPada: DateTime(2026, 3, 1),
            ),
          );
    }

    debugPrint(
      '[EMULATOR_SETUP] Seluruh data 20.000 transaksi + 20 utang + 20 tagihan selesai disuntikkan.',
    );

    // -------------------------------------------------------------------------
    // PENGUKURAN BENCHMARK DI EMULATOR (1x pemanasan + 5 iterasi)
    // -------------------------------------------------------------------------
    final repoTransaksi = TransaksiRepositori(basisData);
    final repoUtang = UtangRepositori(basisData);

    // A. Pengukuran Halaman Pertama Riwayat (50 transaksi pertama)
    // Pemanasan
    await repoTransaksi.ambilTransaksiBerhalaman(limit: 50, offset: 0);

    final durasiRiwayatList = <int>[];
    for (var iter = 1; iter <= 5; iter++) {
      final sw = Stopwatch()..start();
      final hasil = await repoTransaksi.ambilTransaksiBerhalaman(
        limit: 50,
        offset: 0,
      );
      sw.stop();
      durasiRiwayatList.add(sw.elapsedMicroseconds);
      expect(hasil.length, equals(50));
    }
    durasiRiwayatList.sort();
    final medianRiwayatMs = durasiRiwayatList[2] / 1000.0;
    final terburukRiwayatMs = durasiRiwayatList.last / 1000.0;

    // B. Pengukuran Agregasi SQL Beranda (Arus Kas, Total Saldo, Sisa Utang)
    // Pemanasan
    await repoTransaksi.hitungArusKasSQL(
      mulai: DateTime(2026, 3, 1),
      selesai: DateTime(2026, 3, 31),
    );
    await repoUtang.hitungTotalSisaUtangAktifSQL();

    final durasiBerandaList = <int>[];
    for (var iter = 1; iter <= 5; iter++) {
      final sw = Stopwatch()..start();
      await repoTransaksi.hitungArusKasSQL(
        mulai: DateTime(2026, 3, 1),
        selesai: DateTime(2026, 3, 31),
      );
      await repoUtang.hitungTotalSisaUtangAktifSQL();
      sw.stop();
      durasiBerandaList.add(sw.elapsedMicroseconds);
    }
    durasiBerandaList.sort();
    final medianBerandaMs = durasiBerandaList[2] / 1000.0;
    final terburukBerandaMs = durasiBerandaList.last / 1000.0;

    debugPrint('[BENCHMARK_EMULATOR_RESULT]');
    debugPrint(
      'Halaman Pertama Riwayat (50 dari 20.000 transaksi): Median = ${medianRiwayatMs.toStringAsFixed(2)} ms, Terburuk = ${terburukRiwayatMs.toStringAsFixed(2)} ms, Kueri = 1 kueri SELECT LIMIT 50',
    );
    debugPrint(
      'Waktu Muat Agregasi Beranda (20.000 transaksi + 20 utang): Median = ${medianBerandaMs.toStringAsFixed(2)} ms, Terburuk = ${terburukBerandaMs.toStringAsFixed(2)} ms, Kueri = 2 kueri agregasi SQL (SUM)',
    );

    // -------------------------------------------------------------------------
    // TAMPILKAN APLIKASI DI EMULATOR & NAVIGASI LAYAR
    // -------------------------------------------------------------------------
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

    await pompaAman(tester);
    _sinyalkanLayar('01_beranda');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    // Navigasi ke Jadwal Tagihan (/tagihan)
    tester.element(find.byType(Scaffold).first).push('/tagihan');
    await pompaAman(tester);
    _sinyalkanLayar('02_jadwal_tagihan');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    // Navigasi ke Semua Tagihan (/tagihan/semua)
    tester.element(find.byType(Scaffold).first).push('/tagihan/semua');
    await pompaAman(tester);
    _sinyalkanLayar('03_semua_tagihan');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    // Navigasi ke Form Tambah Tagihan (/tagihan/tambah)
    tester.element(find.byType(Scaffold).first).push('/tagihan/tambah');
    await pompaAman(tester);
    _sinyalkanLayar('04_form_tagihan');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    // Navigasi ke Pengaturan (/pengaturan)
    tester.element(find.byType(Scaffold).first).go('/pengaturan');
    await pompaAman(tester);
    _sinyalkanLayar('05_pengaturan');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 3)));

    // Picu tombol "Jadwalkan Pengingat Uji" di layar pengaturan
    final tombolUji = find.widgetWithText(
      TombolFunda,
      'Jadwalkan Pengingat Uji (2 Menit Lagi)',
    );
    if (tombolUji.evaluate().isNotEmpty) {
      await tester.tap(tombolUji);
      await pompaAman(tester);
      _sinyalkanLayar('08_notifikasi');
      debugPrint('[NOTIFIKASI_TERJADWAL: Pengingat 2 menit berhasil dipicu]');
    }
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    // Navigasi ke Daftar Utang (/utang)
    tester.element(find.byType(Scaffold).first).go('/utang');
    await pompaAman(tester);
    _sinyalkanLayar('06_daftar_utang');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    // Navigasi ke Kekayaan Bersih (/kekayaan-bersih)
    tester.element(find.byType(Scaffold).first).go('/kekayaan-bersih');
    await pompaAman(tester);
    _sinyalkanLayar('07_kekayaan_bersih');
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 5)));

    _sinyalkanLayar('SELESAI');
    debugPrint('[EMULATOR_TEST_SELESAI]');
  });
}
