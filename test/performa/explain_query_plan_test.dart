// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:funda/data/basis_data.dart';

void main() {
  test('EXPLAIN QUERY PLAN untuk seluruh kueri Beranda dan Foto Data Pengguna', () async {
    final db = BasisDataFunda(NativeDatabase.memory());

    // Helper untuk menjalankan EXPLAIN QUERY PLAN
    Future<List<String>> explain(String sql, [List<dynamic> args = const []]) async {
      final rows = await db.customSelect(
        'EXPLAIN QUERY PLAN $sql',
        variables: args.map((a) {
          if (a is int) return Variable.withInt(a);
          if (a is String) return Variable.withString(a);
          if (a is double) return Variable.withReal(a);
          return Variable.withString(a.toString());
        }).toList(),
      ).get();

      return rows.map((r) => r.read<String>('detail')).toList();
    }

    print('=== EXPLAIN QUERY PLAN KUERI BERANDA & FOTO DATA ===');

    // 1. Arus Kas
    final eqp1 = await explain(
      '''
      SELECT 
        COALESCE(SUM(CASE WHEN jenis = 'masuk' THEN jumlah_rupiah ELSE 0 END), 0) AS total_masuk,
        COALESCE(SUM(CASE WHEN jenis = 'keluar' THEN jumlah_rupiah ELSE 0 END), 0) AS total_keluar
      FROM tabel_transaksi
      WHERE waktu_transaksi >= ? AND waktu_transaksi <= ?
      ''',
      [1700000000, 1705000000],
    );
    print('1. Arus Kas: ${eqp1.join(" | ")}');

    // 2. Saldo Aktif Dompet
    final eqp2 = await explain('SELECT * FROM tabel_dompet WHERE diarsipkan = 0');
    print('2. Dompet Aktif: ${eqp2.join(" | ")}');

    // 3. Sisa Utang Aktif
    final eqp3 = await explain(
      '''
      SELECT 
        COALESCE(SUM(
          u.sisa_awal_rupiah
          - COALESCE((
              SELECT SUM(t.jumlah_rupiah)
              FROM tabel_pembayaran_utang pu
              JOIN tabel_transaksi t ON pu.transaksi_id = t.id
              WHERE pu.utang_id = u.id
            ), 0)
          + COALESCE((
              SELECT SUM(CASE WHEN arah = 'tambah' THEN jumlah_rupiah ELSE -jumlah_rupiah END)
              FROM tabel_penyesuaian_utang
              WHERE utang_id = u.id
            ), 0)
        ), 0) AS total_sisa
      FROM tabel_utang u
      WHERE u.status = 'aktif';
      ''',
    );
    print('3. Sisa Utang: ${eqp3.join(" | ")}');

    // 4. Cicilan Bulanan Aktif
    final eqp4 = await explain('SELECT cicilan_bulanan_rupiah FROM tabel_utang WHERE status = \'aktif\'');
    print('4. Cicilan Utang: ${eqp4.join(" | ")}');

    // 5. Anggaran Realisasi
    final eqp5 = await explain(
      '''
      SELECT 
        a.id AS anggaran_id,
        a.kategori_id,
        a.batas_rupiah,
        COALESCE(SUM(t.jumlah_rupiah), 0) AS terpakai_rupiah
      FROM tabel_anggaran a
      LEFT JOIN tabel_transaksi t ON t.kategori_id = a.kategori_id 
        AND t.jenis = 'keluar'
        AND t.waktu_transaksi >= ? AND t.waktu_transaksi <= ?
      WHERE a.tahun = ? AND a.bulan = ?
      GROUP BY a.id, a.kategori_id, a.batas_rupiah;
      ''',
      [1700000000, 1705000000, 2026, 3],
    );
    print('5. Anggaran Realisasi: ${eqp5.join(" | ")}');

    // 6. Tujuan Aktif
    final eqp6 = await explain('SELECT * FROM tabel_tujuan WHERE status = \'aktif\'');
    print('6. Tujuan Aktif: ${eqp6.join(" | ")}');

    // 7. Tagihan Jadwal Gabungan (Tagihan Aktif + Pembayaran Terarah)
    final eqp7a = await explain('SELECT * FROM tabel_tagihan WHERE diarsipkan = 0');
    final eqp7b = await explain('SELECT id, jumlah_rupiah FROM tabel_transaksi WHERE id IN (\'tx_1\', \'tx_2\')');
    print('7. Tagihan Aktif & Transaksi: ${eqp7a.join(" | ")} | ${eqp7b.join(" | ")}');

    // 8. 5 Transaksi Terakhir (ORDER BY waktu_transaksi DESC, id DESC LIMIT 5)
    final eqp8 = await explain(
      'SELECT * FROM tabel_transaksi ORDER BY waktu_transaksi DESC, id DESC LIMIT 5 OFFSET 0'
    );
    print('8. 5 Transaksi Terakhir: ${eqp8.join(" | ")}');

    // 9. Pemasukan Rata-rata 3 Bulan
    final eqp9 = await explain(
      '''
      SELECT 
        strftime('%Y-%m', datetime(waktu_transaksi, 'unixepoch')) as periode_bulan,
        SUM(jumlah_rupiah) as total_masuk
      FROM tabel_transaksi
      WHERE jenis = 'masuk' AND waktu_transaksi >= ? AND waktu_transaksi <= ?
      GROUP BY periode_bulan
      ''',
      [1700000000, 1705000000],
    );
    print('9. Pemasukan Rata-rata: ${eqp9.join(" | ")}');

    // 10. Foto Data Pengguna
    final eqp10a = await explain(
      '''
      SELECT 
        (SELECT COUNT(*) FROM tabel_dompet WHERE diarsipkan = 0) as jml_dompet,
        (SELECT COUNT(*) FROM tabel_transaksi WHERE jenis = 'masuk') as jml_masuk,
        (SELECT COUNT(*) FROM tabel_transaksi WHERE jenis = 'keluar') as jml_keluar,
        (SELECT COUNT(*) FROM tabel_anggaran) as jml_anggaran,
        (SELECT COUNT(*) FROM tabel_tujuan WHERE status = 'aktif') as jml_tujuan,
        (SELECT COUNT(*) FROM tabel_utang WHERE status = 'aktif') as jml_utang,
        (SELECT COUNT(DISTINCT date(waktu_transaksi + 25200, 'unixepoch')) FROM tabel_transaksi) as hari_berbeda,
        (SELECT COUNT(DISTINCT strftime('%Y-%m', datetime(waktu_transaksi + 25200, 'unixepoch'))) FROM tabel_transaksi) as bulan_berbeda
      '''
    );
    final eqp10b = await explain(
      '''
      SELECT DISTINCT k.id, k.sifat 
      FROM tabel_transaksi t 
      JOIN tabel_kategori k ON t.kategori_id = k.id 
      WHERE t.jenis = 'keluar'
      '''
    );
    print('10a. Foto Data Ringkasan: ${eqp10a.join(" | ")}');
    print('10b. Foto Data Kategori: ${eqp10b.join(" | ")}');

    await db.close();
  });
}
