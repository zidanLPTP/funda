import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mengelola entitas dompet.
class DompetRepositori {
  const DompetRepositori(this._db);

  final BasisDataFunda _db;

  /// Memantau seluruh dompet (termasuk yang diarsipkan), diurutkan berdasarkan urutan lalu nama.
  Stream<List<EntitasDompet>> pantauSemuaDompet() {
    final kueri = _db.select(_db.tabelDompet)
      ..orderBy([
        (t) => OrderingTerm(expression: t.urutan, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.nama, mode: OrderingMode.asc),
      ]);
    return kueri.watch();
  }

  /// Memantau dompet yang aktif saja (tidak diarsipkan).
  Stream<List<EntitasDompet>> pantauDompetAktif() {
    final kueri = _db.select(_db.tabelDompet)
      ..where((t) => t.diarsipkan.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.urutan, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.nama, mode: OrderingMode.asc),
      ]);
    return kueri.watch();
  }

  /// Mengambil satu dompet berdasarkan ID.
  Future<EntitasDompet?> ambilDompetBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelDompet,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Menambah dompet baru.
  Future<int> tambahDompet(TabelDompetCompanion dompet) {
    return _db.into(_db.tabelDompet).insert(dompet);
  }

  /// Memperbarui informasi dompet.
  Future<bool> perbaruiDompet(TabelDompetCompanion dompet) {
    return _db.update(_db.tabelDompet).replace(dompet);
  }

  /// Mengarsipkan atau memulihkan dompet.
  Future<int> arsipkanDompet(String id, bool diarsipkan) {
    return (_db.update(_db.tabelDompet)..where((t) => t.id.equals(id))).write(
      TabelDompetCompanion(diarsipkan: Value(diarsipkan)),
    );
  }

  /// Mengecek apakah dompet memiliki baris transaksi terkait (baik sebagai asal maupun tujuan).
  Future<bool> cekApakahDompetMemilikiTransaksi(String id) async {
    final kueri = _db.select(_db.tabelTransaksi)
      ..where((t) => t.dompetId.equals(id) | t.dompetTujuanId.equals(id))
      ..limit(1);
    final hasil = await kueri.get();
    return hasil.isNotEmpty;
  }

  /// Menghapus dompet secara permanen.
  /// Hanya boleh dilakukan bila dompet belum memiliki riwayat transaksi sama sekali.
  Future<int> hapusDompetPermanen(String id) async {
    final adaTransaksi = await cekApakahDompetMemilikiTransaksi(id);
    if (adaTransaksi) {
      throw StateError(
        'Dompet ini sudah memiliki transaksi tercatat dan tidak dapat dihapus permanen. Gunakan fitur arsip.',
      );
    }
    return (_db.delete(_db.tabelDompet)..where((t) => t.id.equals(id))).go();
  }
}
