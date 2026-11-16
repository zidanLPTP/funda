import 'package:drift/drift.dart';

/// Tabel penyimpan pernyataan pengguna (mis. 'aku tidak punya utang').
/// Digunakan oleh gerbang data untuk syarat bertipe pernyataan atau opsi ATAU.
@DataClassName('EntitasPernyataan')
class TabelPernyataan extends Table {
  /// Kunci unik pernyataan (contoh: 'tidak_punya_utang', 'baru_satu_sumber_penghasilan').
  TextColumn get kunci => text()();

  /// Nilai pernyataan (contoh: 'true', 'false', atau teks khusus).
  TextColumn get nilai => text()();

  /// Waktu pernyataan disimpan atau terakhir kali diubah.
  DateTimeColumn get diubahPada => dateTime()();

  @override
  Set<Column> get primaryKey => {kunci};
}
