import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';

void main() {
  test('Tolok Ukur Beban 20.000 Transaksi + 20 Utang pada Pembukaan Layar Pelajaran Modul 5 (5.1, 5.2, 5.3)', () async {
    final basisData = BasisDataFunda(NativeDatabase.memory());
    addTearDown(() => basisData.close());

    final now = DateTime.now();

    // Pastikan dompet utama ada
    await basisData.into(basisData.tabelDompet).insertOnConflictUpdate(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'dompet',
            warna: 'hijau',
          ),
        );

    // Suntik 20.000 transaksi dan 20 utang via batch
    await basisData.batch((batch) {
      final txList = List<Insertable<EntitasTransaksi>>.generate(
        20000,
        (i) => TabelTransaksiCompanion.insert(
          id: 'tx_beban_$i',
          dompetId: 'dmp_utama',
          jenis: i.isEven ? 'masuk' : 'keluar',
          jumlahRupiah: 10000 + (i % 50) * 1000,
          waktuTransaksi: now.subtract(Duration(minutes: i)),
        ),
      );
      batch.insertAll(basisData.tabelTransaksi, txList);

      final utangList = List<Insertable<EntitasUtang>>.generate(
        20,
        (u) => TabelUtangCompanion.insert(
          id: 'utang_beban_$u',
          nama: 'Utang Beban $u',
          pokokAwalRupiah: const Value(5000000),
          sisaAwalRupiah: 3000000,
          jenis: 'kredit_barang',
          jenisBunga: 'flat',
          status: const Value('aktif'),
          dibuatPada: now,
        ),
      );
      batch.insertAll(basisData.tabelUtang, utangList);
    });

    final pelajaranIds = [
      'waspada_penipuan_5_1',
      'waspada_penipuan_5_2',
      'waspada_penipuan_5_3',
    ];

    for (final pelId in pelajaranIds) {
      final jsonStr = File('aset/konten/pemula/waspada_penipuan/$pelId.json').readAsStringSync();

      // Pemanasan 1x: kueri status dan muat pelajaran
      await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals(pelId))).getSingleOrNull();
      await (basisData.select(basisData.tabelProgresPelajaran)..where((p) => p.pelajaranId.equals(pelId))).getSingleOrNull();
      PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: '$pelId.json');

      final listKompPel = <int>[];

      // 10 Iterasi tanpa helper pompa
      for (var it = 0; it < 10; it++) {
        final swKomp = Stopwatch()..start();
        // 2 Kueri database yang dieksekusi saat membuka layar pemutar pelajaran:
        await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals(pelId))).getSingleOrNull();
        await (basisData.select(basisData.tabelProgresPelajaran)..where((p) => p.pelajaranId.equals(pelId))).getSingleOrNull();
        PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: '$pelId.json');
        swKomp.stop();
        listKompPel.add(swKomp.elapsedMilliseconds);
      }

      final listKompSorted = List<int>.from(listKompPel)..sort();
      final medianKomp = listKompSorted[listKompSorted.length ~/ 2];
      final terburukKomp = listKompSorted.last;

      debugPrint('=== [TOLOK UKUR BEBAN MEMBUKA $pelId] ===');
      debugPrint('Jumlah kueri database per buka: 2 kueri (tabel_hasil_misi, tabel_progres_pelajaran)');
      debugPrint('Durasi komputasi (10 iterasi): $listKompPel ms (Median: $medianKomp ms, Terburuk: $terburukKomp ms)');
      expect(medianKomp, lessThan(50), reason: 'Median waktu buka layar pelajaran $pelId wajib di bawah 50 ms');
    }
  });
}
