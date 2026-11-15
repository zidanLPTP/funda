import 'package:drift/drift.dart';

/// Skema tabel utang dan cicilan pengguna.
@DataClassName('EntitasUtang')
class TabelUtang extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text()();
  TextColumn get jenis =>
      text()(); // cicilan, pinjaman_pribadi, paylater, kartu_kredit, lainnya
  TextColumn get pemberi => text().nullable()();
  IntColumn get sisaAwalRupiah => integer()();
  IntColumn get pokokAwalRupiah => integer().nullable()();
  TextColumn get jenisBunga => text()(); // tanpa_bunga, flat, efektif
  IntColumn get bungaBasisPoinPerTahun =>
      integer().withDefault(const Constant(0))(); // 100 = 1%
  IntColumn get tenorBulan => integer().nullable()();
  IntColumn get cicilanBulananRupiah =>
      integer().withDefault(const Constant(0))();
  IntColumn get tanggalJatuhTempoBulanan => integer().nullable()(); // 1-31
  DateTimeColumn get tanggalMulai => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('aktif'))(); // aktif, lunas, diarsipkan
  DateTimeColumn get dibuatPada => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
