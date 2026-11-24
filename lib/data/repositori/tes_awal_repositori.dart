import 'dart:convert';
import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk menyimpan dan mengambil riwayat hasil tes awal pengguna.
class TesAwalRepositori {
  final BasisDataFunda _db;

  const TesAwalRepositori(this._db);

  /// Mengambil hasil tes awal yang terakhir kali dikerjakan pengguna.
  Future<EntitasHasilTesAwal?> ambilHasilTerakhir() async {
    return (_db.select(_db.tabelHasilTesAwal)
          ..orderBy([(t) => OrderingTerm.desc(t.waktu)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Aliran reaktif hasil tes awal terakhir.
  Stream<EntitasHasilTesAwal?> pantauHasilTerakhir() {
    return (_db.select(_db.tabelHasilTesAwal)
          ..orderBy([(t) => OrderingTerm.desc(t.waktu)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Menyimpan riwayat pengerjaan tes awal.
  Future<int> simpanHasilTesAwal({
    required Map<String, int> jawaban,
    required Map<String, int> skorPerModul,
    required int skorTotalPersen,
  }) async {
    return _db
        .into(_db.tabelHasilTesAwal)
        .insert(
          TabelHasilTesAwalCompanion.insert(
            waktu: DateTime.now(),
            jawabanJson: jsonEncode(jawaban),
            skorPerModulJson: jsonEncode(skorPerModul),
            skorTotalPersen: skorTotalPersen,
          ),
        );
  }
}
