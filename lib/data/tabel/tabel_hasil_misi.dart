import 'package:drift/drift.dart';

/// Tabel penyimpan status verifikasi misi praktik pengguna.
@DataClassName('EntitasHasilMisi')
class TabelHasilMisi extends Table {
  /// ID misi (biasanya identik dengan pelajaran_id atau kode unik misi).
  TextColumn get misiId => text()();

  /// ID pelajaran yang memuat misi ini.
  TextColumn get pelajaranId => text()();

  /// Tipe verifikasi misi: 'ada_data', 'aturan_data', 'lihat_hitungan', dsb.
  TextColumn get tipe => text()();

  /// Status penyelesaian misi: 'selesai' | 'dilewati'.
  TextColumn get status => text()();

  /// Muatan tambahan hasil misi dalam format JSON (opsional).
  TextColumn get muatanJson => text().nullable()();

  /// Waktu misi diselesaikan atau dilewati.
  DateTimeColumn get selesaiPada => dateTime()();

  @override
  Set<Column> get primaryKey => {misiId};
}
