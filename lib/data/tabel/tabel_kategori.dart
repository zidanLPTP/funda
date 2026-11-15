import 'package:drift/drift.dart';

/// Skema tabel kategori transaksi Funda.
@DataClassName('EntitasKategori')
class TabelKategori extends Table {
  @override
  String get tableName => 'tabel_kategori';

  /// Pengenal unik kategori (UUID).
  TextColumn get id => text()();

  /// Nama kategori (misal: 'Makan Harian', 'Gaji', 'Hiburan').
  TextColumn get nama => text().withLength(min: 1, max: 100)();

  /// Arah arus kas ('masuk' atau 'keluar').
  TextColumn get arus => text()();

  /// Sifat pengeluaran ('kebutuhan', 'keinginan', 'tabungan', 'utang', 'belum_dilabeli', 'tidak_berlaku').
  TextColumn get sifat => text()();

  /// Kunci pengenal ikon dari pustaka Lucide.
  TextColumn get ikon => text()();

  /// Penanda apakah kategori ini adalah kategori bawaan sistem.
  BoolColumn get bawaan => boolean().withDefault(const Constant(false))();

  /// Penanda apakah kategori diarsipkan oleh pengguna.
  BoolColumn get diarsipkan => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
