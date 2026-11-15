import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;

  setUp(() {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
  });

  tearDown(() async {
    await basisData.close();
  });

  test('Uji Performa: 5.000 Transaksi Dummy', () async {
    // 1. Buat 2 dompet
    await repoDompet.tambahDompet(
      TabelDompetCompanion(
        id: const Value('dompet_utama'),
        nama: const Value('Dompet Utama'),
        jenis: Value(JenisDompet.tunai.name),
        ikon: const Value('wallet'),
        warna: const Value('tintHijau'),
        saldoAwalRupiah: const Value(10000000),
      ),
    );

    await repoDompet.tambahDompet(
      TabelDompetCompanion(
        id: const Value('dompet_tabungan'),
        nama: const Value('Tabungan Masa Depan'),
        jenis: Value(JenisDompet.rekeningBank.name),
        ikon: const Value('building2'),
        warna: const Value('tintBiru'),
        saldoAwalRupiah: const Value(50000000),
      ),
    );

    // Ambil kategori pertama
    final semuaKategori = await basisData.select(basisData.tabelKategori).get();
    final idKategori = semuaKategori.first.id;

    // 2. Siapkan 5.000 transaksi dummy dalam batch transaksi database
    final waktuAwal = DateTime(2026, 1, 1);
    final daftarCompanion = <TabelTransaksiCompanion>[];

    for (var i = 0; i < 5000; i++) {
      final jenis = i % 4 == 0
          ? JenisTransaksi.masuk.kode
          : i % 4 == 1
          ? JenisTransaksi.keluar.kode
          : i % 4 == 2
          ? JenisTransaksi.transfer.kode
          : JenisTransaksi.penyesuaianMasuk.kode;

      daftarCompanion.add(
        TabelTransaksiCompanion(
          id: Value('tx_$i'),
          jenis: Value(jenis),
          jumlahRupiah: Value(10000 + (i * 100)),
          dompetId: const Value('dompet_utama'),
          dompetTujuanId: jenis == JenisTransaksi.transfer.kode
              ? const Value('dompet_tabungan')
              : const Value(null),
          kategoriId:
              jenis == JenisTransaksi.masuk.kode ||
                  jenis == JenisTransaksi.keluar.kode
              ? Value(idKategori)
              : const Value(null),
          biayaAdminRupiah: jenis == JenisTransaksi.transfer.kode
              ? const Value(2500)
              : const Value(0),
          catatan: Value('Catatan transaksi dummy ke-$i'),
          waktuTransaksi: Value(waktuAwal.add(Duration(hours: i))),
          dibuatPada: Value(waktuAwal.add(Duration(hours: i))),
          diubahPada: Value(waktuAwal.add(Duration(hours: i))),
        ),
      );
    }

    // Masukkan data sekaligus dalam batch
    final stopwatchInsert = Stopwatch()..start();
    await basisData.batch((batch) {
      batch.insertAll(basisData.tabelTransaksi, daftarCompanion);
    });
    stopwatchInsert.stop();
    // print('Batch insert 5000 transaksi selesai dalam: ${stopwatchInsert.elapsedMilliseconds} ms');

    // 3. Ukur waktu kueri riwayat 5.000 transaksi dari basis data
    // Lakukan warm-up 1 kali, lalu ukur 3 kali untuk stabilitas benchmark
    await (basisData.select(basisData.tabelTransaksi)..limit(10)).get();

    final daftarDurasiKueri = <int>[];
    List<EntitasTransaksi> hasilKueri = [];

    for (var iterasi = 0; iterasi < 3; iterasi++) {
      final sw = Stopwatch()..start();
      hasilKueri =
          await (basisData.select(basisData.tabelTransaksi)..orderBy([
                (t) => OrderingTerm(
                  expression: t.waktuTransaksi,
                  mode: OrderingMode.desc,
                ),
              ]))
              .get();
      sw.stop();
      daftarDurasiKueri.add(sw.elapsedMilliseconds);
    }

    final rerataDurasiKueri =
        daftarDurasiKueri.reduce((a, b) => a + b) ~/ daftarDurasiKueri.length;

    // 4. Ukur waktu hitung saldo dompet secara murni dari 5.000 transaksi
    final daftarDurasiHitung = <int>[];
    var saldoDihitung = 0;

    for (var iterasi = 0; iterasi < 5; iterasi++) {
      final sw = Stopwatch()..start();
      saldoDihitung = hitungSaldoDompet(
        saldoAwalRupiah: 10000000,
        daftarTransaksi: hasilKueri,
        dompetId: 'dompet_utama',
      );
      sw.stop();
      daftarDurasiHitung.add(sw.elapsedMicroseconds);
    }

    final rerataDurasiHitungUs =
        daftarDurasiHitung.reduce((a, b) => a + b) ~/ daftarDurasiHitung.length;
    final rerataDurasiHitungMs = rerataDurasiHitungUs / 1000.0;

    // 5. Ukur waktu hitung arus kas untuk rentang waktu 1 bulan
    final swArusKas = Stopwatch()..start();
    final arusKas = hitungArusKas(
      daftarTransaksi: hasilKueri,
      mulai: DateTime(2026, 1, 1),
      selesai: DateTime(2026, 1, 31, 23, 59, 59),
    );
    swArusKas.stop();
    final durasiArusKasMs = swArusKas.elapsedMilliseconds;

    // Output angka performa ke log pengujian
    // ignore: avoid_print
    print('=== HASIL PENGUJIAN PERFORMA 5.000 TRANSAKSI ===');
    // ignore: avoid_print
    print('- Kueri 5.000 transaksi (Drift SQLite): $rerataDurasiKueri ms');
    // ignore: avoid_print
    print(
      '- Hitung Saldo Murni (5.000 baris): $rerataDurasiHitungUs µs (${rerataDurasiHitungMs.toStringAsFixed(2)} ms)',
    );
    // ignore: avoid_print
    print('- Hitung Arus Kas 1 Bulan (5.000 baris): $durasiArusKasMs ms');
    // ignore: avoid_print
    print('================================================');

    expect(hasilKueri.length, equals(5000));
    expect(saldoDihitung, isA<int>());
    expect(arusKas.totalMasuk, isA<int>());
    expect(arusKas.totalKeluar, isA<int>());

    // Verifikasi performa perhitungan murni sangat cepat (< 50ms)
    expect(rerataDurasiHitungMs, lessThan(50));
  });
}
