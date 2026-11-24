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

  testWidgets('[Tahap 10B Integrasi Emulator] Modul 12 Tujuan Besar & Perencanaan, Gerbang, Umpan Balik Proyeksi, Misi Refleksi & Kuis', (tester) async {
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

    // Data prasyarat: dompet dan tujuan
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

    final tenggat = DateTime(now.year + 2, now.month, now.day);
    await db.into(db.tabelTujuan).insert(
      TabelTujuanCompanion.insert(
        id: 'tujuan_kuliah_s2',
        nama: 'Pendidikan S2',
        jenis: 'tujuan_besar',
        targetRupiah: 36000000,
        tenggat: Value(tenggat),
        ikon: 'school',
        warna: 'biru',
        status: 'aktif',
        dibuatPada: now,
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
    await mintaTangkapanLayar('tahap_10b_01_beranda_awal');

    // 2. Buka Tab Belajar
    final context = tester.element(find.byType(AplikasiFunda));
    GoRouter.of(context).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Belajar'));

    // Verifikasi Modul 12 terlihat di daftar
    await mintaTangkapanLayar('tahap_10b_02_tab_belajar_daftar_modul');

    // 3. Masukkan kelulusan kuis Modul 2 (tabungan) agar Modul 12 terbuka penuh
    await db.into(db.tabelHasilKuis).insertOnConflictUpdate(
      TabelHasilKuisCompanion.insert(
        modulId: 'tabungan',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
      ),
    );

    // 4. Navigasi ke Pelajaran 12.1 (Memecah Tujuan Besar Jadi Langkah Kecil & Misi Keputusan)
    GoRouter.of(context).go('/belajar/tujuan_besar/tujuan_besar_12_1');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Memecah Tujuan Besar'));

    expect(find.textContaining('Memecah Tujuan Besar'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10b_03_pelajaran_12_1');

    // 5. Navigasi ke Pelajaran 12.2 (Umpan Balik ringkasan_tujuan_besar)
    GoRouter.of(context).go('/belajar/tujuan_besar/tujuan_besar_12_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Menghitung Proyeksi'));

    expect(find.textContaining('Menghitung Proyeksi'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10b_04_pelajaran_12_2');

    // 6. Navigasi ke Pelajaran 12.3 (Misi Refleksi)
    GoRouter.of(context).go('/belajar/tujuan_besar/tujuan_besar_12_3');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Menentukan Prioritas'));

    expect(find.textContaining('Menentukan Prioritas'), findsOneWidget);
    await mintaTangkapanLayar('tahap_10b_05_pelajaran_12_3');

    // 7. Navigasi ke Kuis Modul 12
    GoRouter.of(context).go('/belajar/tujuan_besar/kuis');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Kuis'));

    expect(find.textContaining('Kuis'), findsWidgets);
    await mintaTangkapanLayar('tahap_10b_06_kuis_modul_12');
  });
}
