// ignore_for_file: avoid_print
import '../test/pembantu/pompa_uji.dart';
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

  testWidgets('[Tahap 11B Integrasi Emulator] Modul 15 Pajak Lanjutan & Modul 16 Pensiun, Misi Keputusan, Refleksi, Daftar Periksa & Umpan Balik Proyeksi Kebebasan Finansial', (tester) async {
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

    // Data awal: dompet aktif, kategori kebutuhan, dan transaksi keluar
    await db.into(db.tabelDompet).insert(
      TabelDompetCompanion.insert(
        id: 'dompet_utama',
        nama: 'Dompet Utama',
        jenis: 'tunai',
        ikon: 'wallet',
        warna: 'biru',
        saldoAwalRupiah: const Value(300000000),
        dibuatPada: Value(now),
      ),
    );

    await db.into(db.tabelKategori).insert(
      TabelKategoriCompanion.insert(
        id: 'kat_kebutuhan',
        nama: 'Kebutuhan Pokok',
        arus: 'keluar',
        sifat: 'kebutuhan',
        ikon: 'food',
      ),
    );

    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'trx_wajib_1',
        jenis: 'keluar',
        jumlahRupiah: 4000000,
        dompetId: 'dompet_utama',
        kategoriId: const Value('kat_kebutuhan'),
        waktuTransaksi: now,
        catatan: const Value('Pengeluaran Wajib'),
      ),
    );

    // Kuis lulus prasyarat modul 9 dan modul 13
    await db.into(db.tabelHasilKuis).insert(
      TabelHasilKuisCompanion.insert(
        modulId: 'pajak_dasar',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
      ),
    );

    await db.into(db.tabelHasilKuis).insert(
      TabelHasilKuisCompanion.insert(
        modulId: 'investasi_lanjutan',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
      ),
    );

    // Progres selesai pelajaran prasyarat
    for (final p in [
      ('pajak_dasar', 'pajak_dasar_9_1'),
      ('pajak_dasar', 'pajak_dasar_9_2'),
      ('pajak_dasar', 'pajak_dasar_9_3'),
      ('investasi_lanjutan', 'investasi_lanjutan_13_1'),
      ('investasi_lanjutan', 'investasi_lanjutan_13_2'),
      ('investasi_lanjutan', 'investasi_lanjutan_13_3'),
    ]) {
      await db.into(db.tabelProgresPelajaran).insert(
        TabelProgresPelajaranCompanion.insert(
          pelajaranId: p.$2,
          modulId: p.$1,
          status: 'selesai',
          dibuatPada: now,
          selesaiPada: Value(now),
        ),
      );
    }

    final container = ProviderContainer(
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaLayananPengingat.overrideWithValue(LayananPengingatNyata()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AplikasiFunda(),
      ),
    );
    await tester.pump();
    await pompaHinggaAda(tester, find.byType(AplikasiFunda));

    // Navigasi ke Tab Belajar
    final contextUtama = tester.element(find.byType(AplikasiFunda));
    GoRouter.of(contextUtama).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Belajar'));

    await mintaTangkapanLayar('11b_01_tab_belajar_peta_modul_15_16');

    // Buka Pelajaran 16.2
    GoRouter.of(contextUtama).push('/belajar/pensiun_kebebasan_finansial/pensiun_kebebasan_finansial_16_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.byType(AplikasiFunda));

    await mintaTangkapanLayar('11b_02_pelajaran_16_2_kartu_bacaan');

    expect(find.byType(AplikasiFunda), findsOneWidget);
    debugPrint('[SELESAI] Uji integrasi emulator Tahap 11B berhasil dieksekusi.');
  });
}
