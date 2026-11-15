import 'package:drift/drift.dart';
import 'tabel_utang.dart';

/// Skema tabel penyesuaian sisa utang (bunga/denda bertambah atau koreksi/diskon berkurang).
@DataClassName('EntitasPenyesuaianUtang')
class TabelPenyesuaianUtang extends Table {
  TextColumn get id => text()();
  TextColumn get utangId =>
      text().references(TabelUtang, #id, onDelete: KeyAction.cascade)();
  TextColumn get arah => text()(); // tambah, kurang
  IntColumn get jumlahRupiah => integer()();
  TextColumn get catatan => text().nullable()();
  DateTimeColumn get tanggal => dateTime()();
  DateTimeColumn get dibuatPada => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
