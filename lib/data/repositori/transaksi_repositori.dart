import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mengelola baris catatan transaksi keuangan.
class TransaksiRepositori {
  const TransaksiRepositori(this._db);

  final BasisDataFunda _db;

  /// Memantau seluruh transaksi, diurutkan dari yang terbaru (waktuTransaksi descending).
  Stream<List<EntitasTransaksi>> pantauSemuaTransaksi() {
    final kueri = _db.select(_db.tabelTransaksi)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau transaksi yang terkait dengan suatu dompet (sebagai asal maupun tujuan).
  Stream<List<EntitasTransaksi>> pantauTransaksiDompet(String dompetId) {
    final kueri = _db.select(_db.tabelTransaksi)
      ..where(
        (t) => t.dompetId.equals(dompetId) | t.dompetTujuanId.equals(dompetId),
      )
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Mengambil semua transaksi sekali panggil.
  Future<List<EntitasTransaksi>> ambilSemuaTransaksi() {
    final kueri = _db.select(_db.tabelTransaksi)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.waktuTransaksi, mode: OrderingMode.desc),
      ]);
    return kueri.get();
  }

  /// Mengambil transaksi berdasarkan ID.
  Future<EntitasTransaksi?> ambilTransaksiBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelTransaksi,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Menambah transaksi baru ke database.
  Future<int> tambahTransaksi(TabelTransaksiCompanion transaksi) {
    return _db.into(_db.tabelTransaksi).insert(transaksi);
  }

  /// Memperbarui baris transaksi yang sudah ada.
  Future<bool> perbaruiTransaksi(TabelTransaksiCompanion transaksi) {
    return _db.update(_db.tabelTransaksi).replace(transaksi);
  }

  /// Menghapus transaksi berdasarkan ID.
  Future<int> hapusTransaksi(String id) {
    return (_db.delete(_db.tabelTransaksi)..where((t) => t.id.equals(id))).go();
  }
}
