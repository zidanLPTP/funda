import 'package:drift/drift.dart';

/// Definisi skema tabel pengaturan aplikasi Funda.
/// Penamaan tabel dan kolom menggunakan snake_case bahasa Indonesia.
@DataClassName('EntitasPengaturan')
class TabelPengaturan extends Table {
  @override
  String get tableName => 'tabel_pengaturan';

  /// Kunci pengaturan unik (misal: 'versi_aplikasi', 'tema_gelap', dll).
  TextColumn get kunci => text()();

  /// Nilai pengaturan tersimpan dalam bentuk teks string.
  TextColumn get nilai => text()();

  /// Waktu pengaturan terakhir kali diubah.
  DateTimeColumn get diubahPada => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {kunci};
}
