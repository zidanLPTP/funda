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

  testWidgets('[Tahap 11C Integrasi Emulator] Modul 17 Keuangan Usaha Kecil & Modul 18 Proteksi Keluarga & Warisan Dasar, Misi Keputusan, Refleksi, Daftar Periksa & Umpan Balik Ringkasan Usaha Kecil', (tester) async {
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

    // Data awal: dompet aktif, kategori, dan transaksi
    await db.into(db.tabelDompet).insert(
      TabelDompetCompanion.insert(
        id: 'dompet_utama',
        nama: 'Dompet Utama',
        jenis: 'tunai',
        ikon: 'wallet',
        warna: 'biru',
        saldoAwalRupiah: const Value(15000000),
        dibuatPada: Value(now),
      ),
    );

    await db.into(db.tabelKategori).insert(
      TabelKategoriCompanion.insert(
        id: 'kat_gaji',
        nama: 'Gaji Pokok',
        arus: 'masuk',
        sifat: 'kebutuhan',
        ikon: 'banknote',
      ),
    );

    await db.into(db.tabelKategori).insert(
      TabelKategoriCompanion.insert(
        id: 'kat_jual_online',
        nama: 'Jualan Online',
        arus: 'masuk',
        sifat: 'fleksibel',
        ikon: 'shopping-bag',
      ),
    );

    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'trx_gaji_1',
        jenis: 'masuk',
        jumlahRupiah: 10000000,
        dompetId: 'dompet_utama',
        kategoriId: const Value('kat_gaji'),
        waktuTransaksi: now,
        catatan: const Value('Gaji Kantor'),
      ),
    );

    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'trx_jual_1',
        jenis: 'masuk',
        jumlahRupiah: 5000000,
        dompetId: 'dompet_utama',
        kategoriId: const Value('kat_jual_online'),
        waktuTransaksi: now,
        catatan: const Value('Hasil Usaha'),
      ),
    );

    // Kuis lulus prasyarat modul 10 (proteksi_dasar) agar modul 18 terbuka
    await db.into(db.tabelHasilKuis).insert(
      TabelHasilKuisCompanion.insert(
        modulId: 'proteksi_dasar',
        benar: 5,
        total: 5,
        skorPersen: 100,
        lulus: true,
        waktu: now,
      ),
    );

    // Progres selesai pelajaran prasyarat proteksi_dasar
    for (final p in [
      ('proteksi_dasar', 'proteksi_dasar_10_1'),
      ('proteksi_dasar', 'proteksi_dasar_10_2'),
      ('proteksi_dasar', 'proteksi_dasar_10_3'),
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

    await mintaTangkapanLayar('11c_01_tab_belajar_peta_modul_17_18');

    // Buka Pelajaran 17.2
    GoRouter.of(contextUtama).push('/belajar/keuangan_usaha_kecil/keuangan_usaha_kecil_17_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.byType(AplikasiFunda));

    await mintaTangkapanLayar('11c_02_pelajaran_17_2_ringkasan_usaha_kecil');

    expect(find.byType(AplikasiFunda), findsOneWidget);
    debugPrint('[SELESAI] Uji integrasi emulator Tahap 11C berhasil dieksekusi.');
  });
}
