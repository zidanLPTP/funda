import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mencatat hasil verifikasi dan status misi pengguna.
class HasilMisiRepositori {
  final BasisDataFunda _db;

  const HasilMisiRepositori(this._db);

  /// Memantau seluruh status hasil misi secara realtime.
  Stream<List<EntitasHasilMisi>> pantauHasilMisi() {
    return _db.select(_db.tabelHasilMisi).watch();
  }

  /// Mengambil hasil misi spesifik berdasarkan misiId.
  Future<EntitasHasilMisi?> ambilHasilMisi(String misiId) {
    final kueri = _db.select(_db.tabelHasilMisi)
      ..where((m) => m.misiId.equals(misiId));
    return kueri.getSingleOrNull();
  }

  /// Menyimpan hasil misi (selesai atau dilewati).
  Future<void> simpanHasilMisi({
    required String misiId,
    required String pelajaranId,
    required String tipe,
    required String status,
    String? muatanJson,
  }) async {
    await _db
        .into(_db.tabelHasilMisi)
        .insertOnConflictUpdate(
          TabelHasilMisiCompanion.insert(
            misiId: misiId,
            pelajaranId: pelajaranId,
            tipe: tipe,
            status: status,
            muatanJson: Value(muatanJson),
            selesaiPada: DateTime.now(),
          ),
        );
  }
}
