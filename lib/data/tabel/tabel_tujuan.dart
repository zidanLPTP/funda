import 'package:drift/drift.dart';

/// Tabel target tujuan finansial (tabungan, dana darurat, tujuan besar).
@DataClassName('EntitasTujuan')
class TabelTujuan extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  TextColumn get jenis =>
      text()(); // tabungan | dana_darurat | tujuan_besar | lainnya
  IntColumn get targetRupiah => integer()(); // int > 0
  DateTimeColumn get tenggat => dateTime().nullable()();
  TextColumn get ikon => text()();
  TextColumn get warna => text()(); // Kunci token tint
  TextColumn get status => text()(); // aktif | tercapai | diarsipkan
  DateTimeColumn get dibuatPada => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
