import 'package:drift/drift.dart';

/// Tabel penyimpan riwayat pengerjaan tes awal oleh pengguna.
@DataClassName('EntitasHasilTesAwal')
class TabelHasilTesAwal extends Table {
  /// Kunci primer bertambah otomatis.
  IntColumn get id => integer().autoIncrement()();

  /// Waktu tes awal diselesaikan.
  DateTimeColumn get waktu => dateTime()();

  /// Jawaban detail pengguna per butir soal dalam format JSON string.
  TextColumn get jawabanJson => text()();

  /// Rincian skor persentase per modul dalam format JSON string.
  TextColumn get skorPerModulJson => text()();

  /// Skor total tes awal dalam persentase integer (0-100).
  IntColumn get skorTotalPersen => integer()();
}
