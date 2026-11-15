import 'package:drift/drift.dart';
import 'tabel_dompet.dart';
import 'tabel_kategori.dart';

/// Skema tabel transaksi keuangan Funda.
@DataClassName('EntitasTransaksi')
@TableIndex(name: 'idx_transaksi_waktu', columns: {#waktuTransaksi})
@TableIndex(name: 'idx_transaksi_dompet', columns: {#dompetId})
class TabelTransaksi extends Table {
  @override
  String get tableName => 'tabel_transaksi';

  /// Pengenal unik transaksi (UUID).
  TextColumn get id => text()();

  /// Jenis transaksi: 'masuk', 'keluar', 'transfer', 'penyesuaian_masuk', 'penyesuaian_keluar'.
  TextColumn get jenis => text()();

  /// Jumlah nominal transaksi dalam bilangan bulat Rupiah (selalu > 0).
  IntColumn get jumlahRupiah => integer()();

  /// ID dompet sumber / dompet utama yang terpengaruh.
  @ReferenceName('transaksiDompetAsal')
  TextColumn get dompetId => text().references(TabelDompet, #id)();

  /// ID dompet tujuan (khusus jenis 'transfer').
  @ReferenceName('transaksiDompetTujuan')
  TextColumn get dompetTujuanId =>
      text().nullable().references(TabelDompet, #id)();

  /// ID kategori transaksi (wajib untuk masuk/keluar, null untuk transfer dan penyesuaian).
  TextColumn get kategoriId =>
      text().nullable().references(TabelKategori, #id)();

  /// Biaya administrasi transfer dalam Rupiah (hanya untuk transfer, >= 0).
  IntColumn get biayaAdminRupiah => integer().withDefault(const Constant(0))();

  /// Catatan atau deskripsi transaksi opsional.
  TextColumn get catatan => text().nullable()();

  /// Waktu pelaksanaan transaksi (disimpan dalam DateTime UTC).
  DateTimeColumn get waktuTransaksi => dateTime()();

  /// Waktu baris data ini dibuat di perangkat.
  DateTimeColumn get dibuatPada => dateTime().withDefault(currentDateAndTime)();

  /// Waktu baris data ini terakhir kali diubah.
  DateTimeColumn get diubahPada => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
