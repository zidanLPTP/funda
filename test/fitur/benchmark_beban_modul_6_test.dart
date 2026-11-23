import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';

void main() {
  test('Tolok Ukur Beban 20.000 Transaksi + 20 Utang + 20 Tagihan pada Tab Belajar (6 Modul) dan Pelajaran 6.1-6.3', () async {
    final basisData = BasisDataFunda(NativeDatabase.memory());
    addTearDown(() => basisData.close());

    final now = DateTime.now();

    // Pastikan dompet dan kategori ada
    await basisData.into(basisData.tabelDompet).insertOnConflictUpdate(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'dompet',
            warna: 'hijau',
          ),
        );

    await basisData.into(basisData.tabelKategori).insertOnConflictUpdate(
          TabelKategoriCompanion.insert(
            id: 'kat_makan',
            nama: 'Makan',
            arus: 'keluar',
            sifat: 'kebutuhan',
            ikon: 'utensils',
          ),
        );

    // Suntik 20.000 transaksi + 20 utang + 20 tagihan via batch
    await basisData.batch((batch) {
      final txList = List<Insertable<EntitasTransaksi>>.generate(
        20000,
        (i) => TabelTransaksiCompanion.insert(
          id: 'tx_beban_$i',
          dompetId: 'dmp_utama',
          kategoriId: const Value('kat_makan'),
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

      final tagihanList = List<Insertable<EntitasTagihan>>.generate(
        20,
        (t) => TabelTagihanCompanion.insert(
          id: 'tagihan_beban_$t',
          nama: 'Tagihan Beban $t',
          jenis: t.isEven ? 'langganan' : 'tagihan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: Value(50000 + t * 5000),
          kategoriId: 'kat_makan',
          jatuhTempoPertama: now,
          dibuatPada: now,
        ),
      );
      batch.insertAll(basisData.tabelTagihan, tagihanList);
    });

    // Muat 6 Modul Pemula
    final modulFolder = [
      'anggaran_arus_kas',
      'tabungan',
      'dana_darurat',
      'utang_cicilan',
      'waspada_penipuan',
      'psikologi_uang',
    ];
    final daftarModul = <ModulKonten>[];
    for (final folder in modulFolder) {
      final file = File('aset/konten/pemula/$folder/modul.json');
      daftarModul.add(PembacaKonten.uraiModul(file.readAsStringSync(), namaBerkas: '$folder/modul.json'));
    }

    // Pakai FotoDataRepositori resmi aplikasi
    final fotoRepo = FotoDataRepositori(basisData);

    // 1. Pemanasan 1x Tab Belajar
    final fotoAwal = await fotoRepo.ambilFotoData();
    for (final m in daftarModul) {
      tentukanStatusModul(modul: m, fotoData: fotoAwal);
    }

    // 2. 10 Iterasi Tab Belajar tanpa helper pompa
    final listKompTabBelajar = <int>[];
    for (var it = 0; it < 10; it++) {
      final sw = Stopwatch()..start();
      final foto = await fotoRepo.ambilFotoData();
      for (final m in daftarModul) {
        tentukanStatusModul(modul: m, fotoData: foto);
      }
      sw.stop();
      listKompTabBelajar.add(sw.elapsedMilliseconds);
    }

    final listTabSorted = List<int>.from(listKompTabBelajar)..sort();
    final medianTab = listTabSorted[listTabSorted.length ~/ 2];
    final terburukTab = listTabSorted.last;

    debugPrint('=== [TOLOK UKUR BEBAN TAB BELAJAR (6 MODUL PEMULA TERSEDIA)] ===');
    debugPrint('Dataset: 20.000 Transaksi, 20 Utang, 20 Tagihan');
    debugPrint('Jumlah kueri database per evaluasi: 4 kueri agregasi (dompet, transaksi, utang, tagihan)');
    debugPrint('Durasi komputasi (10 iterasi): $listKompTabBelajar ms (Median: $medianTab ms, Terburuk: $terburukTab ms)');
    expect(medianTab, lessThan(100), reason: 'Target komputasi Tab Belajar median < 100 ms');

    // 3. Pengujian pembukaan pelajaran 6.1, 6.2, 6.3
    final pelajaranIds = [
      'psikologi_uang_6_1',
      'psikologi_uang_6_2',
      'psikologi_uang_6_3',
    ];

    for (final pelId in pelajaranIds) {
      final jsonStr = File('aset/konten/pemula/psikologi_uang/$pelId.json').readAsStringSync();

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
