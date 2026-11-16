import '../basis_data.dart';

/// Repositori untuk mencatat pernyataan pengguna (seperti 'aku tidak punya utang').
class PernyataanRepositori {
  final BasisDataFunda _db;

  const PernyataanRepositori(this._db);

  /// Memantau seluruh pernyataan secara realtime dalam bentuk Map kunci dan nilai.
  Stream<Map<String, String>> pantauSemuaPernyataan() {
    return _db.select(_db.tabelPernyataan).watch().map((daftar) {
      return {for (final p in daftar) p.kunci: p.nilai};
    });
  }

  /// Mengambil seluruh pernyataan dalam bentuk Map kunci dan nilai.
  Future<Map<String, String>> ambilSemuaPernyataan() async {
    final daftar = await _db.select(_db.tabelPernyataan).get();
    return {for (final p in daftar) p.kunci: p.nilai};
  }

  /// Menyimpan atau memperbarui suatu pernyataan.
  Future<void> simpanPernyataan(String kunci, String nilai) async {
    await _db.into(_db.tabelPernyataan).insertOnConflictUpdate(
          TabelPernyataanCompanion.insert(
            kunci: kunci,
            nilai: nilai,
            diubahPada: DateTime.now(),
          ),
        );
  }

  /// Menghapus atau mencabut suatu pernyataan.
  Future<int> hapusPernyataan(String kunci) {
    return (_db.delete(_db.tabelPernyataan)..where((p) => p.kunci.equals(kunci))).go();
  }
}
