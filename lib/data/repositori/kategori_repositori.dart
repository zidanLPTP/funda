import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mengelola entitas kategori keuangan.
class KategoriRepositori {
  const KategoriRepositori(this._db);

  final BasisDataFunda _db;

  /// Memantau seluruh kategori.
  Stream<List<EntitasKategori>> pantauSemuaKategori() {
    final kueri = _db.select(_db.tabelKategori)
      ..orderBy([
        (t) => OrderingTerm(expression: t.nama, mode: OrderingMode.asc),
      ]);
    return kueri.watch();
  }

  /// Memantau kategori aktif (tidak diarsipkan) berdasarkan arah arus ('masuk' atau 'keluar').
  Stream<List<EntitasKategori>> pantauKategoriBerdasarkanArus(String arus) {
    final kueri = _db.select(_db.tabelKategori)
      ..where((t) => t.arus.equals(arus) & t.diarsipkan.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.nama, mode: OrderingMode.asc),
      ]);
    return kueri.watch();
  }

  /// Mengambil semua kategori sekali panggil.
  Future<List<EntitasKategori>> ambilSemuaKategori() {
    return _db.select(_db.tabelKategori).get();
  }

  /// Mengambil kategori berdasarkan ID.
  Future<EntitasKategori?> ambilKategoriBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelKategori,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Menambah kategori kustom baru buatan pengguna.
  Future<int> tambahKategoriKustom(TabelKategoriCompanion kategori) {
    return _db.into(_db.tabelKategori).insert(kategori);
  }

  /// Memperbarui kategori (misalnya mengubah sifat atau nama).
  Future<bool> perbaruiKategori(TabelKategoriCompanion kategori) {
    return _db.update(_db.tabelKategori).replace(kategori);
  }

  /// Mengarsipkan atau memulihkan kategori.
  Future<int> arsipkanKategori(String id, bool diarsipkan) {
    return (_db.update(_db.tabelKategori)..where((t) => t.id.equals(id))).write(
      TabelKategoriCompanion(diarsipkan: Value(diarsipkan)),
    );
  }

  /// Mengecek apakah kategori memiliki transaksi yang merujuk padanya.
  Future<bool> cekApakahKategoriMemilikiTransaksi(String id) async {
    final kueri = _db.select(_db.tabelTransaksi)
      ..where((t) => t.kategoriId.equals(id))
      ..limit(1);
    final hasil = await kueri.get();
    return hasil.isNotEmpty;
  }

  /// Menghapus kategori kustom secara permanen.
  /// Kategori bawaan tidak boleh dihapus. Kategori kustom yang sudah dipakai transaksi tidak boleh dihapus.
  Future<int> hapusKategoriKustom(String id) async {
    final kategori = await ambilKategoriBerdasarkanId(id);
    if (kategori == null) {
      return 0;
    }
    if (kategori.bawaan) {
      throw StateError(
        'Kategori bawaan sistem tidak boleh dihapus. Kamu bisa mengarsipkannya.',
      );
    }
    final adaTransaksi = await cekApakahKategoriMemilikiTransaksi(id);
    if (adaTransaksi) {
      throw StateError(
        'Kategori ini sudah dipakai dalam transaksi tercatat. Gunakan fitur arsip.',
      );
    }

    return (_db.delete(_db.tabelKategori)..where((t) => t.id.equals(id))).go();
  }
}
