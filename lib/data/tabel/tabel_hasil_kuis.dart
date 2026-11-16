import 'package:drift/drift.dart';

/// Tabel penyimpan riwayat pengerjaan kuis akhir modul oleh pengguna.
@DataClassName('EntitasHasilKuis')
class TabelHasilKuis extends Table {
  /// Kunci primer bertambah otomatis.
  IntColumn get id => integer().autoIncrement()();

  /// ID modul yang diuji.
  TextColumn get modulId => text()();

  /// Jumlah jawaban benar.
  IntColumn get benar => integer()();

  /// Total soal dalam kuis.
  IntColumn get total => integer()();

  /// Skor dalam persentase integer (0-100).
  IntColumn get skorPersen => integer()();

  /// Status kelulusan (lulus bila skor >= ambangLulusKuis 70%).
  BoolColumn get lulus => boolean()();

  /// Waktu kuis diselesaikan.
  DateTimeColumn get waktu => dateTime()();
}
