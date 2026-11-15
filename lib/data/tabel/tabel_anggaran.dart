import 'package:drift/drift.dart';
import 'tabel_kategori.dart';

/// Tabel anggaran bulanan per kategori.
@DataClassName('EntitasAnggaran')
class TabelAnggaran extends Table {
  TextColumn get id => text()();
  IntColumn get tahun => integer()();
  IntColumn get bulan => integer()(); // 1 - 12
  TextColumn get kategoriId => text().references(TabelKategori, #id)();
  IntColumn get batasRupiah => integer()(); // int > 0
  DateTimeColumn get dibuatPada => dateTime()();
  DateTimeColumn get diubahPada => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {tahun, bulan, kategoriId},
  ];
}
