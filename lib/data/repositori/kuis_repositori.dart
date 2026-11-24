import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mencatat dan memantau riwayat kuis akhir modul.
class KuisRepositori {
  final BasisDataFunda _db;

  const KuisRepositori(this._db);

  /// Memantau seluruh riwayat pengerjaan kuis secara realtime.
  Stream<List<EntitasHasilKuis>> pantauSemuaHasilKuis() {
    return _db.select(_db.tabelHasilKuis).watch();
  }

  /// Mengambil hasil kuis terbaik (skor tertinggi) untuk modul tertentu.
  Future<EntitasHasilKuis?> ambilHasilKuisTerbaikModul(String modulId) async {
    final kueri = _db.select(_db.tabelHasilKuis)
      ..where((k) => k.modulId.equals(modulId))
      ..orderBy([(k) => OrderingTerm.desc(k.skorPersen)]);
    final hasil = await kueri.get();
    return hasil.firstOrNull;
  }

  /// Menyimpan riwayat pengerjaan kuis baru.
  Future<int> simpanHasilKuis({
    required String modulId,
    required int benar,
    required int total,
    required int skorPersen,
    required bool lulus,
  }) {
    return _db
        .into(_db.tabelHasilKuis)
        .insert(
          TabelHasilKuisCompanion.insert(
            modulId: modulId,
            benar: benar,
            total: total,
            skorPersen: skorPersen,
            lulus: lulus,
            waktu: DateTime.now(),
          ),
        );
  }
}
