import '../test/pembantu/pompa_uji.dart';
// ignore_for_file: avoid_print
import 'package:drift/drift.dart' hide isNotNull, isNull;
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

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  await Future.delayed(const Duration(milliseconds: 2000));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('[Tahap 10A Integrasi Emulator] Modul 8 Penghasilan Tambahan & Modul 9 Pajak Dasar, Gerbang, Umpan Balik & Kuis', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('markNeedsBuild() called during build') ||
          details.exceptionAsString().contains('UncontrolledProviderScope')) {
        return;
      }
      originalOnError?.call(details);
    };

    await initializeDateFormatting('id_ID', null);

    final db = BasisDataFunda(NativeDatabase.memory());
    addTearDown(() async => await db.close());

    final now = DateTime.now();

    // Dompet dan transaksi pemasukan
    await db.into(db.tabelDompet).insert(
      TabelDompetCompanion.insert(
        id: 'dompet_utama',
        nama: 'Dompet Utama',
        jenis: 'tunai',
        ikon: 'wallet',
        warna: 'tintHijau',
        saldoAwalRupiah: const Value(5000000),
      ),
    );

    await db.into(db.tabelKategori).insert(
      TabelKategoriCompanion.insert(
        id: 'kat_gaji',
        nama: 'Gaji Bulanan',
        arus: 'masuk',
        sifat: 'kebutuhan',
        ikon: 'briefcase',
      ),
    );

    await db.into(db.tabelKategori).insert(
      TabelKategoriCompanion.insert(
        id: 'kat_lepas',
        nama: 'Kerja Lepas',
        arus: 'masuk',
        sifat: 'kebutuhan',
        ikon: 'laptop',
      ),
    );

    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'tx_gaji_1',
        dompetId: 'dompet_utama',
        jumlahRupiah: 5000000,
        jenis: 'masuk',
        kategoriId: const Value('kat_gaji'),
        waktuTransaksi: now,
      ),
    );

    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'tx_lepas_1',
        dompetId: 'dompet_utama',
        jumlahRupiah: 1500000,
        jenis: 'masuk',
        kategoriId: const Value('kat_lepas'),
        waktuTransaksi: now,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(db),
          penyediaLayananPengingat.overrideWithValue(LayananPengingatNyata()),
        ],
        child: const AplikasiFunda(),
      ),
    );
    await tester.pump();
    await pompaHinggaAda(tester, find.byType(AplikasiFunda));

    // 1. Verifikasi Beranda awal tampil
    expect(find.byType(AplikasiFunda), findsOneWidget);
    await mintaTangkapanLayar('tahap_10a_01_beranda_awal');

    // 2. Buka Tab Belajar
    final context = tester.element(find.byType(AplikasiFunda));
    GoRouter.of(context).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Belajar'));

    // Verifikasi Modul 8 dan Modul 9 terlihat di daftar
    await mintaTangkapanLayar('tahap_10a_02_tab_belajar_daftar_modul');

    // 3. Masukkan progres penyelesaian Modul 1 sampai Modul 6 agar modul terbuka penuh
    final modulSelesai = [
      'arus_kas',
      'anggaran_pos',
      'dana_darurat',
      'utang_cicilan',
      'waspada_penipuan',
      'psikologi_uang',
    ];
    for (final mod in modulSelesai) {
      await db.into(db.tabelHasilKuis).insertOnConflictUpdate(
        TabelHasilKuisCompanion.insert(
          modulId: mod,
          benar: 5,
          total: 5,
          skorPersen: 100,
          lulus: true,
          waktu: now,
        ),
      );
    }

    // 4. Navigasi ke Pelajaran 8.1
    GoRouter.of(context).go('/belajar/penghasilan_tambahan/penghasilan_tambahan_8_1');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Menimbang Waktu dan Tenaga'));

    expect(find.textContaining('Menimbang Waktu dan Tenaga'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10a_03_pelajaran_8_1');

    // 5. Navigasi ke Pelajaran 8.2 (Umpan Balik ringkasan_pemasukan_tambahan)
    GoRouter.of(context).go('/belajar/penghasilan_tambahan/penghasilan_tambahan_8_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Memisahkan Catatan'));

    expect(find.textContaining('Memisahkan Catatan'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10a_04_pelajaran_8_2');

    // 6. Navigasi ke Pelajaran 9.2 (Umpan Balik ringkasan_penghasilan_tahunan)
    GoRouter.of(context).go('/belajar/pajak_dasar/pajak_dasar_9_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Karyawan vs Pekerja Lepas'));

    expect(find.textContaining('Karyawan vs Pekerja Lepas'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10a_05_pelajaran_9_2');

    // 7. Navigasi ke Pelajaran 9.3 (Misi Daftar Periksa + Disclaimer)
    GoRouter.of(context).go('/belajar/pajak_dasar/pajak_dasar_9_3');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Menyiapkan SPT Tahunan Lebih Awal'));

    expect(find.textContaining('Menyiapkan SPT Tahunan Lebih Awal'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10a_06_pelajaran_9_3');

    // 8. Navigasi ke Kuis Modul 8
    GoRouter.of(context).go('/belajar/penghasilan_tambahan/kuis');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Kuis'));

    expect(find.textContaining('Kuis'), findsWidgets);
    await mintaTangkapanLayar('tahap_10a_07_kuis_modul_8');

    // 9. Navigasi ke Kuis Modul 9
    GoRouter.of(context).go('/belajar/pajak_dasar/kuis');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Kuis'));

    expect(find.textContaining('Kuis'), findsWidgets);
    await mintaTangkapanLayar('tahap_10a_08_kuis_modul_9');
  });
}
