import 'package:drift/drift.dart';
import 'tabel_kantong.dart';

/// Tabel mutasi alokasi saldo ke/dari kantong.
@DataClassName('EntitasAlokasiKantong')
class TabelAlokasiKantong extends Table {
  TextColumn get id => text()();
  TextColumn get kantongId => text().references(TabelKantong, #id)();
  TextColumn get jenis => text()(); // isi | ambil
  IntColumn get jumlahRupiah => integer()(); // int > 0
  TextColumn get catatan => text().nullable()();
  DateTimeColumn get waktu => dateTime()();
  DateTimeColumn get dibuatPada => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
