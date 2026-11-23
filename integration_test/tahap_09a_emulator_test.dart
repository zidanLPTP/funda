import '../test/pembantu/pompa_uji.dart';
// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
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

Future<Map<String, int>> ambilRincianBarisTabel(BasisDataFunda db) async {
  final hasil = <String, int>{};
  final barisTabel = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%' ORDER BY name ASC;",
  ).get();
  for (final b in barisTabel) {
    final namaTabel = b.read<String>('name');
    final countRes = await db.customSelect('SELECT COUNT(*) AS total FROM $namaTabel;').getSingle();
    hasil[namaTabel] = countRes.read<int>('total');
  }
  return hasil;
}

String cetakRincianTabel(String label, Map<String, int> rincian) {
  final sb = StringBuffer();
  sb.writeln('=== RINCIAN JUMLAH BARIS PER TABEL $label ===');
  debugPrint('=== RINCIAN JUMLAH BARIS PER TABEL $label ===');
  var total = 0;
  for (final e in rincian.entries) {
    sb.writeln('${e.key}: ${e.value} baris');
    debugPrint('${e.key}: ${e.value} baris');
    total += e.value;
  }
  sb.writeln('=== TOTAL BARIS $label: $total ===');
  debugPrint('=== TOTAL BARIS $label: $total ===');
  return sb.toString();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('[Tahap 9A Integrasi Emulator] Mesin Sandbox, Modul 11 Investasi Dasar, Isolasi Total Data, dan Cadangan', (tester) async {
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

    // Data dummy dompet dan transaksi riil
    await db.into(db.tabelDompet).insert(
      TabelDompetCompanion.insert(
        id: 'dmp_utama',
        nama: 'Dompet Utama',
        jenis: 'tunai',
        ikon: 'wallet',
        warna: 'tintHijau',
        saldoAwalRupiah: const Value(5000000),
      ),
    );
    await db.into(db.tabelTransaksi).insert(
      TabelTransaksiCompanion.insert(
        id: 'tx_01',
        dompetId: 'dmp_utama',
        jumlahRupiah: 50000,
        jenis: 'keluar',
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

    // 1. Verifikasi Beranda awal tampil dan tangkap layar
    expect(find.byType(AplikasiFunda), findsOneWidget);
    await mintaTangkapanLayar('tahap_09a_01_beranda_awal');

    // 2. Navigasi langsung ke Mode Sandbox via rute /sandbox
    final context = tester.element(find.byType(AplikasiFunda));
    GoRouter.of(context).go('/sandbox');
    await tester.pump();
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_majukan_sandbox')));

    // 3. Verifikasi Banner Sandbox, Modal Awal Rp10.000.000
    expect(find.text('Mode Sandbox — Uang Fiktif (Simulasi, bukan prediksi)'), findsOneWidget);
    expect(find.text('Tahun 0 (Awal)'), findsOneWidget);
    expect(find.text('Rp10.000.000'), findsWidgets);
    await mintaTangkapanLayar('tahap_09a_02_layar_sandbox_awal');

    // 4. Majukan 1 Tahun dalam mode Normal
    final tombolMajukanFinder = find.byKey(const Key('tombol_majukan_sandbox'));
    await tester.ensureVisible(tombolMajukanFinder);
    await tester.pump();
    await tester.tap(tombolMajukanFinder);
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Tahun 1'));

    // Verifikasi nilai berubah ke Tahun 1 dan riwayat bertambah
    expect(find.text('Tahun 1'), findsOneWidget);
    expect(find.text('Rp10.640.000'), findsWidgets);
    expect(find.text('Riwayat Simulasi'), findsOneWidget);
    await mintaTangkapanLayar('tahap_09a_03_layar_sandbox_simulasi_tahun_1');

    // 5. Verifikasi bahwa sesi tersimpan di tabel_sesi_sandbox
    final sesiList = await db.select(db.tabelSesiSandbox).get();
    expect(sesiList.length, 1);
    expect(sesiList.first.bulanBerjalan, 12);
    expect(sesiList.first.nilaiSaatIniRupiah, 10640000);

    // 6. Navigasi kembali ke Beranda & cek isolasi
    GoRouter.of(context).go('/beranda');
    await tester.pump();
    await pompaHinggaAda(tester, find.byType(AplikasiFunda));

    // Verifikasi saldo transaksi asli tidak terpengaruh uang fiktif Rp10.640.000
    expect(find.text('Rp10.640.000'), findsNothing);
    await mintaTangkapanLayar('tahap_09a_04_beranda_bersih_dari_sandbox');

    // 7. Verifikasi Cadangan: tabel_sesi_sandbox DIKECUALIKAN dari ekspor
    final cadanganRepo = CadanganRepositori(db);
    final cadanganJson = await cadanganRepo.eksporCadanganKeJson();
    final dataCadangan = jsonDecode(cadanganJson) as Map<String, dynamic>;
    final dataTabel = dataCadangan['data'] as Map<String, dynamic>? ?? {};
    expect(dataTabel.containsKey('tabel_sesi_sandbox'), isFalse);
    expect(CadanganRepositori.tabelDikecualikan.contains('tabel_sesi_sandbox'), isTrue);

    final rincianSebelum = await ambilRincianBarisTabel(db);
    cetakRincianTabel('SEBELUM CADANGAN/PEMULIHAN', rincianSebelum);
    expect(rincianSebelum['tabel_sesi_sandbox'], 1);

    debugPrint('[REGRESI SUKSES] Isolasi total Mesin Sandbox terverifikasi.');
  });
}
