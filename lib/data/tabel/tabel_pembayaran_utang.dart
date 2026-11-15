import 'package:drift/drift.dart';
import 'tabel_transaksi.dart';
import 'tabel_utang.dart';

/// Skema tabel relasi pembayaran utang terhadap transaksi pengeluaran.
@DataClassName('EntitasPembayaranUtang')
class TabelPembayaranUtang extends Table {
  TextColumn get id => text()();
  TextColumn get utangId =>
      text().references(TabelUtang, #id, onDelete: KeyAction.cascade)();
  TextColumn get transaksiId => text().unique().references(
    TabelTransaksi,
    #id,
    onDelete: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {id};
}
