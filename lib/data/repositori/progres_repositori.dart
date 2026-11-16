import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mencatat dan memantau progres belajar pengguna per pelajaran.
class ProgresRepositori {
  final BasisDataFunda _db;

  const ProgresRepositori(this._db);

  /// Memantau seluruh progres pelajaran secara realtime.
  Stream<List<EntitasProgresPelajaran>> pantauSemuaProgres() {
    return _db.select(_db.tabelProgresPelajaran).watch();
  }

  /// Mengambil seluruh progres pelajaran sekali ambil.
  Future<List<EntitasProgresPelajaran>> ambilSemuaProgres() {
    return _db.select(_db.tabelProgresPelajaran).get();
  }

  /// Mengambil progres spesifik untuk suatu pelajaran.
  Future<EntitasProgresPelajaran?> ambilProgresPelajaran(String pelajaranId) {
    final kueri = _db.select(_db.tabelProgresPelajaran)
      ..where((p) => p.pelajaranId.equals(pelajaranId));
    return kueri.getSingleOrNull();
  }

  /// Memperbarui atau menyimpan posisi langkah kartu pelajaran pengguna.
  Future<void> simpanProgresLangkah({
    required String pelajaranId,
    required String modulId,
    required int indeksLangkah,
  }) async {
    final sekarang = DateTime.now();
    await _db.into(_db.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion(
            pelajaranId: Value(pelajaranId),
            modulId: Value(modulId),
            status: const Value('sedang'),
            indeksLangkah: Value(indeksLangkah),
            dibuatPada: Value(sekarang),
          ),
        );
  }

  /// Menandai pelajaran telah selesai secara permanen.
  Future<void> tandaiPelajaranSelesai({
    required String pelajaranId,
    required String modulId,
  }) async {
    final sekarang = DateTime.now();
    await _db.into(_db.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion(
            pelajaranId: Value(pelajaranId),
            modulId: Value(modulId),
            status: const Value('selesai'),
            selesaiPada: Value(sekarang),
            dibuatPada: Value(sekarang),
          ),
        );
  }
}
