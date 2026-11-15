import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;
  late TransaksiRepositori repoTransaksi;
  late UtangRepositori repoUtang;
  late KategoriRepositori repoKategori;
  final daftarIdDompet = <String>[];
  late String idKategori;

  setUp(() async {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
    repoTransaksi = TransaksiRepositori(basisData);
    repoUtang = UtangRepositori(basisData);
    repoKategori = KategoriRepositori(basisData);

    daftarIdDompet.clear();

    // Buat 3 dompet
    for (var i = 1; i <= 3; i++) {
      final id = await repoDompet.buatDompet(
        nama: 'Dompet $i',
        jenis: JenisDompet.rekeningBank.kode,
        ikon: 'building2',
        warna: 'tintBiru',
        saldoAwalRupiah: 10000000 * i,
      );
      daftarIdDompet.add(id);
    }

    // Buat 1 kategori
    await repoKategori.tambahKategoriKustom(
      TabelKategoriCompanion.insert(
        id: 'kat_makan',
        nama: 'Makan & Minum',
        arus: 'keluar',
        sifat: 'kebutuhan',
        ikon: 'utensils',
      ),
    );
    idKategori = 'kat_makan';

    // Buat 20 utang dummy
    for (var i = 1; i <= 20; i++) {
      await repoUtang.buatUtang(
        nama: 'Utang $i',
        jenis: 'kredit_barang',
        pemberi: 'Pemberi $i',
        sisaAwalRupiah: 5000000 * i,
        pokokAwalRupiah: 6000000 * i,
        jenisBunga: 'flat',
        bungaBasisPoinPerTahun: 500,
        cicilanBulananRupiah: 500000,
      );
    }
  });

  tearDown(() async {
    await basisData.close();
  });

  Future<void> isiTransaksiDummy(int jumlah, {int prefixId = 0}) async {
    final sekarang = DateTime.now();
    final rng = Random(42 + prefixId);
    final daftarCompanion = <TabelTransaksiCompanion>[];

    for (var i = 0; i < jumlah; i++) {
      final jenisIndex = i % 4;
      final jenis = switch (jenisIndex) {
        0 => JenisTransaksi.masuk.kode,
        1 => JenisTransaksi.keluar.kode,
        2 => JenisTransaksi.transfer.kode,
        _ => JenisTransaksi.keluar.kode,
      };

      final waktu = sekarang.subtract(Duration(minutes: (jumlah - i) * 10));
      final dompetAsal = daftarIdDompet[i % daftarIdDompet.length];
      final dompetTujuan = daftarIdDompet[(i + 1) % daftarIdDompet.length];

      daftarCompanion.add(
        TabelTransaksiCompanion.insert(
          id: 'trx_${prefixId}_$i',
          jenis: jenis,
          jumlahRupiah: 10000 + (rng.nextInt(500) * 1000),
          dompetId: dompetAsal,
          dompetTujuanId: jenis == JenisTransaksi.transfer.kode
              ? drift.Value(dompetTujuan)
              : const drift.Value(null),
          kategoriId: jenis == JenisTransaksi.transfer.kode
              ? const drift.Value(null)
              : drift.Value(idKategori),
          biayaAdminRupiah: jenis == JenisTransaksi.transfer.kode
              ? const drift.Value(2500)
              : const drift.Value(0),
          catatan: drift.Value('Catatan dummy ke-$i'),
          waktuTransaksi: waktu,
        ),
      );
    }

    await basisData.batch((batch) {
      batch.insertAll(basisData.tabelTransaksi, daftarCompanion);
    });
  }

  /// Menghitung nilai median dan nilai terburuk dari daftar durasi dalam mikrodetik.
  ({double medianMs, double terburukMs, List<double> rincianMs})
  hitungStatistik(List<int> durasiMikrodetik) {
    final listMs = durasiMikrodetik.map((d) => d / 1000.0).toList();
    listMs.sort();
    final median = listMs[listMs.length ~/ 2];
    final terburuk = listMs.last;
    return (medianMs: median, terburukMs: terburuk, rincianMs: listMs);
  }

  test('Benchmark Bersih Performa: 5.000 vs 20.000 Transaksi', () async {
    // -------------------------------------------------------------------------
    // Bagian A: 5.000 Transaksi
    // -------------------------------------------------------------------------
    await isiTransaksiDummy(5000, prefixId: 5);
    final daftarDompet = await repoDompet.ambilSemuaDompet();

    // 1. Riwayat Halaman Pertama (50 item pertama) - 5.000 Transaksi
    // Warm-up 1x
    await repoTransaksi.ambilTransaksiKursor(limit: 50);
    // 5 Iterasi Pengukuran
    final durasiRiwayat5k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      final hasil = await repoTransaksi.ambilTransaksiKursor(limit: 50);
      sw.stop();
      expect(hasil.length, 50);
      durasiRiwayat5k.add(sw.elapsedMicroseconds);
    }
    final statRiwayat5k = hitungStatistik(durasiRiwayat5k);

    // 2. Saldo Dompet (SQL SUM agregasi) - 5.000 Transaksi
    await repoTransaksi.hitungSaldoDompetSQL(
      dompetId: daftarDompet.first.id,
      saldoAwalRupiah: daftarDompet.first.saldoAwalRupiah,
    ); // Warmup 1x
    final durasiSaldo5k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      for (final d in daftarDompet) {
        await repoTransaksi.hitungSaldoDompetSQL(
          dompetId: d.id,
          saldoAwalRupiah: d.saldoAwalRupiah,
        );
      }
      sw.stop();
      durasiSaldo5k.add(sw.elapsedMicroseconds);
    }
    final statSaldo5k = hitungStatistik(durasiSaldo5k);

    // 3. Arus Kas Bulan Berjalan (SQL SUM) - 5.000 Transaksi
    final sekarang = DateTime.now();
    final mulaiBulan = DateTime(sekarang.year, sekarang.month, 1);
    final akhirBulan = DateTime(
      sekarang.year,
      sekarang.month + 1,
      0,
      23,
      59,
      59,
    );
    await repoTransaksi.hitungArusKasSQL(
      mulai: mulaiBulan,
      selesai: akhirBulan,
    ); // Warmup
    final durasiArusKas5k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      await repoTransaksi.hitungArusKasSQL(
        mulai: mulaiBulan,
        selesai: akhirBulan,
      );
      sw.stop();
      durasiArusKas5k.add(sw.elapsedMicroseconds);
    }
    final statArusKas5k = hitungStatistik(durasiArusKas5k);

    // 4. Total Sisa Utang Aktif (SQL SUM 20 Utang) - 5.000 Transaksi
    await repoUtang.hitungTotalSisaUtangAktifSQL(); // Warmup
    final durasiUtang5k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      await repoUtang.hitungTotalSisaUtangAktifSQL();
      sw.stop();
      durasiUtang5k.add(sw.elapsedMicroseconds);
    }
    final statUtang5k = hitungStatistik(durasiUtang5k);

    // -------------------------------------------------------------------------
    // Bagian B: 20.000 Transaksi (Tambah 15.000 lagi)
    // -------------------------------------------------------------------------
    await isiTransaksiDummy(15000, prefixId: 20);

    // 1. Riwayat Halaman Pertama (50 item pertama) - 20.000 Transaksi
    await repoTransaksi.ambilTransaksiKursor(limit: 50); // Warmup
    final durasiRiwayat20k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      final hasil = await repoTransaksi.ambilTransaksiKursor(limit: 50);
      sw.stop();
      expect(hasil.length, 50);
      durasiRiwayat20k.add(sw.elapsedMicroseconds);
    }
    final statRiwayat20k = hitungStatistik(durasiRiwayat20k);

    // 2. Saldo Semua Dompet (SQL SUM agregasi) - 20.000 Transaksi
    await repoTransaksi.hitungSaldoDompetSQL(
      dompetId: daftarDompet.first.id,
      saldoAwalRupiah: daftarDompet.first.saldoAwalRupiah,
    ); // Warmup
    final durasiSaldo20k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      for (final d in daftarDompet) {
        await repoTransaksi.hitungSaldoDompetSQL(
          dompetId: d.id,
          saldoAwalRupiah: d.saldoAwalRupiah,
        );
      }
      sw.stop();
      durasiSaldo20k.add(sw.elapsedMicroseconds);
    }
    final statSaldo20k = hitungStatistik(durasiSaldo20k);

    // 3. Arus Kas Bulan Berjalan (SQL SUM) - 20.000 Transaksi
    await repoTransaksi.hitungArusKasSQL(
      mulai: mulaiBulan,
      selesai: akhirBulan,
    ); // Warmup
    final durasiArusKas20k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      await repoTransaksi.hitungArusKasSQL(
        mulai: mulaiBulan,
        selesai: akhirBulan,
      );
      sw.stop();
      durasiArusKas20k.add(sw.elapsedMicroseconds);
    }
    final statArusKas20k = hitungStatistik(durasiArusKas20k);

    // 4. Total Sisa Utang Aktif (SQL SUM 20 Utang) - 20.000 Transaksi
    await repoUtang.hitungTotalSisaUtangAktifSQL(); // Warmup
    final durasiUtang20k = <int>[];
    for (var i = 0; i < 5; i++) {
      final sw = Stopwatch()..start();
      await repoUtang.hitungTotalSisaUtangAktifSQL();
      sw.stop();
      durasiUtang20k.add(sw.elapsedMicroseconds);
    }
    final statUtang20k = hitungStatistik(durasiUtang20k);

    // Cetak Rekapitulasi Terstruktur untuk Laporan
    // ignore: avoid_print
    print('''
================================================================================
HASIL BENCHMARK PERFORMA TAHAP 3B (WARM-UP 1X + 5 ITERASI PENGUKURAN)
================================================================================
1. Halaman Pertama Riwayat (50 transaksi pertama via Kursor):
   - 5.000 transaksi  : Median = ${statRiwayat5k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statRiwayat5k.terburukMs.toStringAsFixed(2)} ms
   - 20.000 transaksi : Median = ${statRiwayat20k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statRiwayat20k.terburukMs.toStringAsFixed(2)} ms

2. Total Saldo Semua Dompet (SQL SUM 3 Dompet):
   - 5.000 transaksi  : Median = ${statSaldo5k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statSaldo5k.terburukMs.toStringAsFixed(2)} ms
   - 20.000 transaksi : Median = ${statSaldo20k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statSaldo20k.terburukMs.toStringAsFixed(2)} ms

3. Arus Kas Bulan Berjalan (SQL SUM):
   - 5.000 transaksi  : Median = ${statArusKas5k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statArusKas5k.terburukMs.toStringAsFixed(2)} ms
   - 20.000 transaksi : Median = ${statArusKas20k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statArusKas20k.terburukMs.toStringAsFixed(2)} ms

4. Total Sisa Utang Aktif (SQL SUM 20 Utang):
   - 5.000 transaksi  : Median = ${statUtang5k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statUtang5k.terburukMs.toStringAsFixed(2)} ms
   - 20.000 transaksi : Median = ${statUtang20k.medianMs.toStringAsFixed(2)} ms | Terburuk = ${statUtang20k.terburukMs.toStringAsFixed(2)} ms
================================================================================
''');

    // Verifikasi batas toleransi performa Funda (selalu di bawah batas 50ms)
    expect(statRiwayat5k.medianMs, lessThan(30.0));
    expect(statRiwayat20k.medianMs, lessThan(50.0));
    expect(statSaldo5k.medianMs, lessThan(30.0));
    expect(statSaldo20k.medianMs, lessThan(50.0));
    expect(statArusKas5k.medianMs, lessThan(30.0));
    expect(statArusKas20k.medianMs, lessThan(50.0));
    expect(statUtang20k.medianMs, lessThan(30.0));
  });
}
