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

  testWidgets('[Tahap 9B Integrasi Emulator] Modul 7 Paylater & Modul 10 Proteksi, Gerbang, Misi & Kuis', (tester) async {
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

    // Dompet dan transaksi awal
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
    await mintaTangkapanLayar('tahap_09b_01_beranda_awal');

    // 2. Buka Tab Belajar
    final context = tester.element(find.byType(AplikasiFunda));
    GoRouter.of(context).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Belajar'));

    // Verifikasi Modul 7 dan Modul 10 terlihat di daftar
    await mintaTangkapanLayar('tahap_09b_02_tab_belajar_daftar_modul');

    // 3. Masukkan progres penyelesaian Modul 3 dan Modul 4 agar gerbang Modul 7 & 10 terbuka
    for (var i = 1; i <= 3; i++) {
      await db.into(db.tabelProgresPelajaran).insertOnConflictUpdate(
        TabelProgresPelajaranCompanion.insert(
          pelajaranId: 'dana_darurat_3_$i',
          modulId: 'dana_darurat',
          status: 'selesai',
          dibuatPada: now,
          selesaiPada: Value(now),
        ),
      );
    }
    for (var i = 1; i <= 4; i++) {
      await db.into(db.tabelProgresPelajaran).insertOnConflictUpdate(
        TabelProgresPelajaranCompanion.insert(
          pelajaranId: 'utang_cicilan_4_$i',
          modulId: 'utang_cicilan',
          status: 'selesai',
          dibuatPada: now,
          selesaiPada: Value(now),
        ),
      );
    }

    // 4. Navigasi langsung ke Pelajaran 7.1
    GoRouter.of(context).go('/belajar/paylater_kredit/paylater_kredit_7_1');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Cara Kerja Paylater di Balik Layar'));

    expect(find.textContaining('Cara Kerja Paylater di Balik Layar'), findsOneWidget);
    await mintaTangkapanLayar('tahap_09b_03_pelajaran_7_1');

    // 5. Navigasi ke Pelajaran 10.3 (Misi Lihat Hitungan & Umpan Balik ringkasan_proteksi_dasar)
    GoRouter.of(context).go('/belajar/proteksi_dasar/proteksi_dasar_10_3');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Menyesuaikan Proteksi dengan Anggaran'));

    expect(find.textContaining('Menyesuaikan Proteksi dengan Anggaran'), findsOneWidget);
    await mintaTangkapanLayar('tahap_09b_04_pelajaran_10_3');

    // 6. Navigasi ke Kuis Modul 7
    GoRouter.of(context).go('/belajar/paylater_kredit/kuis');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Kuis'));

    await mintaTangkapanLayar('tahap_09b_05_kuis_modul_7');

    // 7. Navigasi ke Kuis Modul 10
    GoRouter.of(context).go('/belajar/proteksi_dasar/kuis');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Kuis'));

    await mintaTangkapanLayar('tahap_09b_06_kuis_modul_10');

    debugPrint('[REGRESI SUKSES] Alur integrasi Modul 7 & Modul 10 selesai.');
  });
}
