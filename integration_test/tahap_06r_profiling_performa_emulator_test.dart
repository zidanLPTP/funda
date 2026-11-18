import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class RincianTahapBelajar {
  final double fotoDataMs;
  final double bacaAsetMs;
  final double parseMs;
  final double evaluasiGerbangMs;
  final double buildWidgetMs;
  final double totalMs;

  const RincianTahapBelajar({
    required this.fotoDataMs,
    required this.bacaAsetMs,
    required this.parseMs,
    required this.evaluasiGerbangMs,
    required this.buildWidgetMs,
    required this.totalMs,
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Butir D: Pengukuran Profil Performa Tab Belajar Siklus Penuh 5k & 20k di Emulator', (tester) async {
    await initializeDateFormatting('id_ID', null);

    Future<BasisDataFunda> buatBasisData(int totalTransaksi) async {
      final db = BasisDataFunda(NativeDatabase.memory());
      // Seed dompet
      await db.into(db.tabelDompet).insert(
            TabelDompetCompanion.insert(
              id: 'dmp_1',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'wallet',
              warna: 'tintBiru',
            ),
          );

      // Seed bulk transaksi
      final batchSize = 1000;
      final t0 = DateTime(2026, 3, 1);
      for (var b = 0; b < totalTransaksi; b += batchSize) {
        await db.batch((batch) {
          for (var i = 0; i < batchSize && (b + i) < totalTransaksi; i++) {
            final idx = b + i;
            final isMasuk = idx % 5 == 0;
            batch.insert(
              db.tabelTransaksi,
              TabelTransaksiCompanion.insert(
                id: 'tx_${totalTransaksi}_$idx',
                jenis: isMasuk ? 'masuk' : 'keluar',
                jumlahRupiah: (idx % 10 + 1) * 25000,
                dompetId: 'dmp_1',
                waktuTransaksi: t0.add(Duration(hours: idx % 720)),
                dibuatPada: Value(DateTime.now()),
                diubahPada: Value(DateTime.now()),
              ),
            );
          }
        });
      }
      return db;
    }

    Future<RincianTahapBelajar> ukurTahap(BasisDataFunda db, WidgetTester tester) async {
      // 1. Foto Data (Kueri SQL)
      final swFoto = Stopwatch()..start();
      final repoFoto = FotoDataRepositori(db);
      final fotoData = await repoFoto.ambilFotoData();
      swFoto.stop();

      // 2. Baca Aset
      final swBaca = Stopwatch()..start();
      final kamusStr = await rootBundle.loadString('aset/konten/kamus.json');
      final daftarModulStr = <String>[];
      for (final meta in daftarMetadataModul) {
        final path = 'aset/konten/${meta.$1}/${meta.$2}/modul.json';
        daftarModulStr.add(await rootBundle.loadString(path));
      }
      final daftarPelStr = <String>[];
      for (var i = 1; i <= 5; i++) {
        final path = 'aset/konten/pemula/anggaran_arus_kas/anggaran_arus_kas_1_$i.json';
        daftarPelStr.add(await rootBundle.loadString(path));
      }
      swBaca.stop();

      // 3. Parse JSON
      final swParse = Stopwatch()..start();
      final petaKamus = PembacaKonten.uraiKamus(kamusStr);
      final daftarModulObj = <ModulKonten>[];
      for (var i = 0; i < daftarModulStr.length; i++) {
        daftarModulObj.add(PembacaKonten.uraiModul(daftarModulStr[i]));
      }
      final daftarPelObj = <PelajaranKonten>[];
      for (var i = 1; i <= 5; i++) {
        final path = 'aset/konten/pemula/anggaran_arus_kas/anggaran_arus_kas_1_$i.json';
        daftarPelObj.add(PembacaKonten.uraiPelajaran(
          daftarPelStr[i - 1],
          namaBerkas: path,
          daftarIstilahKamus: petaKamus.keys.toSet(),
        ));
      }
      swParse.stop();

      // 4. Evaluasi Gerbang
      final swGerbang = Stopwatch()..start();
      for (final m in daftarModulObj) {
        tentukanStatusModul(modul: m, fotoData: fotoData);
      }
      for (var i = 0; i < daftarPelObj.length; i++) {
        tentukanStatusPelajaran(
          pelajaran: daftarPelObj[i],
          posisiIndeks: i,
          daftarPelajaranModul: daftarPelObj,
          gerbangModul: daftarModulObj[1].gerbang,
          fotoData: fotoData,
        );
      }
      swGerbang.stop();

      // 5. Build Widget LayarBelajar
      final swWidget = Stopwatch()..start();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: LayarBelajar(),
          ),
        ),
      );
      await tester.pump();
      swWidget.stop();

      // Bersihkan widget tree
      await tester.pumpWidget(const SizedBox());

      final fotoMs = swFoto.elapsedMicroseconds / 1000.0;
      final bacaMs = swBaca.elapsedMicroseconds / 1000.0;
      final parseMs = swParse.elapsedMicroseconds / 1000.0;
      final gerbangMs = swGerbang.elapsedMicroseconds / 1000.0;
      final widgetMs = swWidget.elapsedMicroseconds / 1000.0;
      final totalMs = fotoMs + bacaMs + parseMs + gerbangMs + widgetMs;

      return RincianTahapBelajar(
        fotoDataMs: fotoMs,
        bacaAsetMs: bacaMs,
        parseMs: parseMs,
        evaluasiGerbangMs: gerbangMs,
        buildWidgetMs: widgetMs,
        totalMs: totalMs,
      );
    }

    debugPrint('================================================================================');
    debugPrint('[PENGUKURAN SIKLUS PENUH TAB BELAJAR (5.000 DAN 20.000 TRANSAKSI)]');
    debugPrint('================================================================================');

    for (final count in [5000, 20000]) {
      debugPrint('\n--- PENGUKURAN PADA $count TRANSAKSI ---');
      final db = await buatBasisData(count);

      // Pemanasan 1x
      await ukurTahap(db, tester);

      final hasil = <RincianTahapBelajar>[];
      for (var iter = 0; iter < 10; iter++) {
        hasil.add(await ukurTahap(db, tester));
      }

      debugPrint('Iterasi | FotoData | BacaAset | ParseJSON | Gerbang | BuildUI | Total');
      for (var i = 0; i < 10; i++) {
        final h = hasil[i];
        debugPrint(
          '#${(i + 1).toString().padLeft(2)}     | '
          '${h.fotoDataMs.toStringAsFixed(2).padLeft(7)} ms | '
          '${h.bacaAsetMs.toStringAsFixed(2).padLeft(7)} ms | '
          '${h.parseMs.toStringAsFixed(2).padLeft(7)} ms | '
          '${h.evaluasiGerbangMs.toStringAsFixed(2).padLeft(6)} ms | '
          '${h.buildWidgetMs.toStringAsFixed(2).padLeft(6)} ms | '
          '${h.totalMs.toStringAsFixed(2).padLeft(6)} ms',
        );
      }

      final listTotal = hasil.map((e) => e.totalMs).toList()..sort();
      final median = (listTotal[4] + listTotal[5]) / 2.0;
      final terburuk = listTotal.last;

      debugPrint('REKAP $count TRANSAKSI:');
      debugPrint('  - Median Total: ${median.toStringAsFixed(2)} ms');
      debugPrint('  - Terburuk    : ${terburuk.toStringAsFixed(2)} ms');
      debugPrint('  - Jumlah Kueri: 5 kueri SQL agregasi FotoDataPengguna (bebas N+1)');

      await db.close();
    }
  });
}
