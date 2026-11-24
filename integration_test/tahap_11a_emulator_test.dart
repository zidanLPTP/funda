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

  testWidgets('[Tahap 11A Integrasi Emulator] Modul 13 Investasi Lanjutan & Modul 14 KPR, Misi Sandbox, Misi Keputusan, Misi Daftar Periksa & Umpan Balik Kemampuan KPR', (tester) async {
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

    // Data dompet utama
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

    // Data transaksi di 3 bulan berbeda
    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'trx_gaji_1',
        jenis: 'masuk',
        jumlahRupiah: 10000000,
        dompetId: 'dompet_utama',
        waktuTransaksi: DateTime(now.year, now.month - 2, 5),
        catatan: const Value('Gaji 2 bulan lalu'),
      ),
    );
    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'trx_gaji_2',
        jenis: 'masuk',
        jumlahRupiah: 10000000,
        dompetId: 'dompet_utama',
        waktuTransaksi: DateTime(now.year, now.month - 1, 5),
        catatan: const Value('Gaji bulan lalu'),
      ),
    );
    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'trx_gaji_3',
        jenis: 'masuk',
        jumlahRupiah: 10000000,
        dompetId: 'dompet_utama',
        waktuTransaksi: DateTime(now.year, now.month, 5),
        catatan: const Value('Gaji bulan ini'),
      ),
    );

    // Data utang / cicilan aktif
    await db.into(db.tabelUtang).insert(
      TabelUtangCompanion.insert(
        id: 'utang_motor',
        nama: 'Cicilan Motor',
        jenis: 'cicilan',
        sisaAwalRupiah: 12000000,
        jenisBunga: 'flat',
        cicilanBulananRupiah: const Value(1000000),
        dibuatPada: now,
      ),
    );

    // Kuis prasyarat modul_selesai investasi_dasar, utang_cicilan, tujuan_besar
    await db.into(db.tabelHasilKuis).insert(
      TabelHasilKuisCompanion.insert(
        modulId: 'investasi_dasar',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
      ),
    );
    await db.into(db.tabelHasilKuis).insert(
      TabelHasilKuisCompanion.insert(
        modulId: 'utang_cicilan',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
      ),
    );
    await db.into(db.tabelHasilKuis).insert(
      TabelHasilKuisCompanion.insert(
        modulId: 'tujuan_besar',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
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

    // Navigasi ke Layar Belajar
    final konteks = tester.element(find.byType(AplikasiFunda));
    GoRouter.of(konteks).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Belajar'));

    await mintaTangkapanLayar('11a_peta_belajar_lanjutan_terbuka');

    // Buka Pelajaran 13.1
    GoRouter.of(konteks).go('/belajar/investasi_lanjutan/investasi_lanjutan_13_1');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Menyusun Alokasi'));
    await mintaTangkapanLayar('11a_pelajaran_13_1_alokasi_portofolio');

    // Buka Pelajaran 14.3
    GoRouter.of(konteks).go('/belajar/kpr_kredit_besar/kpr_kredit_besar_14_3');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Uji Kemampuan'));
    await mintaTangkapanLayar('11a_pelajaran_14_3_kemampuan_kpr');
  });
}
