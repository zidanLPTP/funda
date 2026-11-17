import 'dart:io';
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

void _sinyalkanLayar(String namaLayar) {
  try {
    File('/sdcard/layar_aktif.txt').writeAsStringSync(namaLayar);
  } catch (_) {}
  debugPrint('[SCREEN_READY: $namaLayar]');
}

Future<void> pompaAman(WidgetTester tester, [int ms = 500]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Tahap 5: Alur End-to-End Tes Awal, Profil Keuangan & Rekomendasi Personalisasi di Emulator Pixel 8',
      (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('markNeedsBuild() called during build') ||
          details.exceptionAsString().contains('UncontrolledProviderScope')) {
        debugPrint('[IGNORED_RIVERPOD_TEARDOWN_ASSERTION]');
        return;
      }
      originalOnError?.call(details);
    };

    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());

    // Siapkan dompet utama agar gerbang belajar dompet >= 1 terbuka
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

    await pompaAman(tester, 1000);
    _sinyalkanLayar('01_beranda_awal');

    // 1. Pindah ke Tab Belajar
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);
    _sinyalkanLayar('02_tab_belajar_peta');

    // 2. Ketuk Tombol "Buka Tes Awal" pada Kartu Modul 0
    final tombolBukaTes = find.text('Buka Tes Awal');
    expect(tombolBukaTes, findsOneWidget);
    await tester.tap(tombolBukaTes);
    await pompaAman(tester, 1000);

    _sinyalkanLayar('03_layar_tes_awal_pembuka');
    expect(find.text('Mulai & Tes Awal'), findsOneWidget);

    // 3. Isi Tujuan Utama
    final inputTujuan = find.byType(TextField);
    expect(inputTujuan, findsOneWidget);
    await tester.enterText(inputTujuan, 'Bebas utang dan punya tabungan impian');
    await pompaAman(tester, 500);

    // Ketuk "Mulai Sekarang" untuk masuk tahap Profil
    final tombolMulaiSekarang = find.text('Mulai Sekarang');
    expect(tombolMulaiSekarang, findsOneWidget);
    await tester.tap(tombolMulaiSekarang);
    await pompaAman(tester, 800);

    _sinyalkanLayar('04_pertanyaan_profil_keuangan');

    // 4. Jawab 6 Pertanyaan Profil
    for (var i = 0; i < 6; i++) {
      expect(find.textContaining('Profil (${i + 1}/6)'), findsOneWidget);

      // Pilih opsi pertama
      final opsiPertama = find.byType(InkWell).first;
      await tester.tap(opsiPertama);
      await pompaAman(tester, 300);

      if (i < 5) {
        final tombolLanjut = find.text('Pertanyaan Berikutnya');
        await tester.tap(tombolLanjut);
        await pompaAman(tester, 500);
      } else {
        final tombolKeTes = find.text('Lanjut ke Tes Pemahaman');
        await tester.tap(tombolKeTes);
        await pompaAman(tester, 800);
      }
    }

    _sinyalkanLayar('05_pertanyaan_soal_tes_awal');

    // 5. Jawab 12 Soal Tes Awal
    for (var i = 0; i < 12; i++) {
      expect(find.textContaining('Tes Awal (${i + 1}/12)'), findsOneWidget);

      // Pilih opsi kedua
      final semuaPilihan = find.byType(InkWell);
      if (semuaPilihan.evaluate().length >= 2) {
        await tester.tap(semuaPilihan.at(1));
      } else {
        await tester.tap(semuaPilihan.first);
      }
      await pompaAman(tester, 300);

      if (i < 11) {
        final tombolLanjutSoal = find.text('Soal Berikutnya');
        await tester.tap(tombolLanjutSoal);
        await pompaAman(tester, 500);
      } else {
        final tombolLihatHasil = find.text('Lihat Hasil');
        await tester.tap(tombolLihatHasil);
        await pompaAman(tester, 1200);
      }
    }

    _sinyalkanLayar('06_layar_hasil_dan_rekomendasi');

    // 6. Verifikasi Layar Hasil & Rekomendasi
    expect(find.text('Hasil Tes Awal'), findsOneWidget);
    expect(find.text('Profil Berhasil Dibentuk'), findsOneWidget);
    expect(find.textContaining('Skor pemahaman awalmu:'), findsOneWidget);
    expect(find.text('Rekomendasi Belajar Untukmu'), findsOneWidget);

    // Verifikasi data tersimpan di basis data SQLite
    final profilDb = await basisData.select(basisData.tabelProfilKeuangan).getSingleOrNull();
    expect(profilDb, isNotNull);
    expect(profilDb!.tujuanUtama, equals('Bebas utang dan punya tabungan impian'));

    final hasilDb = await basisData.select(basisData.tabelHasilTesAwal).getSingleOrNull();
    expect(hasilDb, isNotNull);
    expect(hasilDb!.skorTotalPersen, inInclusiveRange(0, 100));

    // Ketuk tombol Buka Peta Belajar
    final tombolSelesai = find.text('Buka Peta Belajar');
    expect(tombolSelesai, findsOneWidget);
    await tester.tap(tombolSelesai);
    await pompaAman(tester, 1000);

    _sinyalkanLayar('07_tab_belajar_dengan_rekomendasi');

    // Verifikasi kembali di Tab Belajar dengan Kartu Rekomendasi tampil
    expect(find.text('Saran untuk kamu'), findsOneWidget);
    expect(find.text('Profilku'), findsOneWidget);

    debugPrint('[BERHASIL] Seluruh alur integrasi Tes Awal & Personalisasi lolos di Emulator Pixel 8.');
  });
}
