import 'package:drift/drift.dart';

/// Tabel penyimpan progres belajar pengguna per pelajaran.
@DataClassName('EntitasProgresPelajaran')
class TabelProgresPelajaran extends Table {
  /// ID stabil pelajaran (contoh: 'anggaran_arus_kas_1_2').
  TextColumn get pelajaranId => text()();

  /// ID modul induk (contoh: 'anggaran_arus_kas').
  TextColumn get modulId => text()();

  /// Status penyelesaian: 'sedang' | 'selesai'.
  TextColumn get status => text()();

  /// Indeks langkah kartu terakhir yang dibuka pengguna (0-based).
  IntColumn get indeksLangkah => integer().withDefault(const Constant(0))();

  /// Waktu pertama kali pelajaran dimulai.
  DateTimeColumn get dibuatPada => dateTime()();

  /// Waktu pelajaran dinyatakan selesai (null jika masih 'sedang').
  DateTimeColumn get selesaiPada => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {pelajaranId};
}
