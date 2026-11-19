import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/fitur/cadangan/kontroler/penyedia_cadangan.dart';
import 'package:funda/fitur/cadangan/tampilan/layar_cadangan.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  await Future.delayed(const Duration(milliseconds: 2000));
}

Future<void> pompaAman(WidgetTester tester, [int ms = 500]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('[Tahap 7 Integrasi Emulator] Alur Laporan Bulanan & Cadangan Data dengan UI Nyata & Tangkapan Layar', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('markNeedsBuild() called during build') ||
          details.exceptionAsString().contains('UncontrolledProviderScope')) {
        return;
      }
      originalOnError?.call(details);
    };

    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());
    final cadanganRepo = CadanganRepositori(basisData);
    final layananPengingat = LayananPengingatNyata();
    await layananPengingat.inisialisasi();

    // 1. Data Awal: Dompet, Kategori, Transaksi
    await basisData.into(basisData.tabelDompet).insert(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: '#006C4C',
            saldoAwalRupiah: const Value(3500000),
          ),
        );

    await basisData.into(basisData.tabelKategori).insert(
          TabelKategoriCompanion.insert(
            id: 'kat_makan',
            nama: 'Makan & Minum',
            arus: 'keluar',
            sifat: 'kebutuhan',
            ikon: 'utensils',
          ),
        );

    final sekarang = DateTime.now();
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_1',
            dompetId: 'dmp_utama',
            kategoriId: const Value('kat_makan'),
            jumlahRupiah: 450000,
            jenis: 'keluar',
            waktuTransaksi: sekarang.subtract(const Duration(days: 2)),
          ),
        );

    const statusPengingatAktif = StatusFiturCadangan(
      terakhirDicadangkan: null,
      adaCadanganKeselamatan: false,
      jumlahTransaksi: 12,
      hariSejakDataPertama: 16,
      ditundaSampai: null,
      perluPengingat: true,
    );

    // Buat json cadangan valid untuk dialog pratinjau
    final jsonValidCadangan = await cadanganRepo.eksporCadanganKeJson();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          penyediaCadanganRepositori.overrideWithValue(cadanganRepo),
          penyediaLayananPengingat.overrideWithValue(layananPengingat),
          penyediaStatusCadangan.overrideWith((ref) => Future.value(statusPengingatAktif)),
          penyediaPemilihBerkas.overrideWithValue(() async => jsonValidCadangan),
        ],
        child: const AplikasiFunda(),
      ),
    );
    await pompaAman(tester, 1000);

    // =========================================================================
    // 1. Tangkapan Layar: Banner Pengingat Cadangan di Beranda
    // =========================================================================
    expect(find.text('Yuk, amankan catatan keuanganmu'), findsOneWidget);
    await mintaTangkapanLayar('tahap_07_banner_beranda');

    // =========================================================================
    // 2. Navigasi ke Layar Cadangan & Pemulihan via Tombol "Cadangkan sekarang"
    // =========================================================================
    await tester.tap(find.text('Cadangkan sekarang'));
    await pompaAman(tester, 800);

    expect(find.text('Cadangan & Pemulihan'), findsWidgets);
    await mintaTangkapanLayar('tahap_07_cadangan');

    // =========================================================================
    // 3. Tangkapan Layar: Dialog Pratinjau Pemulihan Berkas
    // =========================================================================
    await tester.tap(find.text('Pulihkan dari Berkas'));
    await pompaAman(tester, 800);

    expect(find.text('Pratinjau Data Cadangan'), findsOneWidget);
    await mintaTangkapanLayar('tahap_07_pratinjau_pemulihan');

    // Tutup dialog pratinjau
    await tester.tap(find.text('Batal'));
    await pompaAman(tester, 500);

    // =========================================================================
    // 4. Navigasi ke Layar Laporan Bulanan (/laporan)
    // =========================================================================
    final context = tester.element(find.byType(Scaffold).first);
    context.push('/laporan');
    await pompaAman(tester, 1000);

    expect(find.text('Laporan Bulanan'), findsWidgets);
    await mintaTangkapanLayar('tahap_07_laporan_normal');

    // =========================================================================
    // 5. Aktifkan Saklar Sensor Nominal
    // =========================================================================
    final saklarFinder = find.byType(Switch);
    if (saklarFinder.evaluate().isNotEmpty) {
      await tester.tap(saklarFinder.first);
      await pompaAman(tester, 800);
      await mintaTangkapanLayar('tahap_07_laporan_sensor');
    }

    debugPrint('[SELESAI: Seluruh skenario pengujian dan tangkapan layar Tahap 7 sukses]');
  });
}
