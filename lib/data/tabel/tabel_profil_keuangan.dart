import 'package:drift/drift.dart';

/// Tabel penyimpan profil keuangan pengguna (1 baris aktif).
@DataClassName('EntitasProfilKeuangan')
class TabelProfilKeuangan extends Table {
  /// Kunci primer bertambah otomatis.
  IntColumn get id => integer().autoIncrement()();

  /// Status penghasilan pengguna: 'rutin', 'tidak_rutin', 'belum'.
  TextColumn get punyaPenghasilan => text()();

  /// Status kepemilikan utang: 'ya', 'tidak', 'tidak_yakin'.
  TextColumn get punyaUtang => text()();

  /// Kesiapan dana darurat: 'belum', 'sedikit', 'sudah'.
  TextColumn get danaDarurat => text()();

  /// Kebiasaan menabung: 'belum', 'kadang', 'rutin'.
  TextColumn get menabung => text()();

  /// Pengalaman investasi: 'belum', 'pernah', 'aktif'.
  TextColumn get investasi => text()();

  /// Kebiasaan mencatat keuangan: 'belum', 'kadang', 'rutin'.
  TextColumn get mencatatKeuangan => text()();

  /// Tujuan keuangan utama (opsional, maksimal 100 karakter).
  TextColumn get tujuanUtama => text().nullable()();

  /// Waktu pertama kali profil diisi.
  DateTimeColumn get diisiPada => dateTime()();

  /// Waktu profil terakhir kali diperbarui.
  DateTimeColumn get diperbaruiPada => dateTime()();
}
