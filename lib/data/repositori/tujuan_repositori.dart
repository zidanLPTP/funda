import 'package:drift/drift.dart';
import '../basis_data.dart';
import '../model/jenis_tujuan.dart';
import '../model/status_tujuan.dart';

/// Repositori untuk mengelola target tujuan finansial.
class TujuanRepositori {
  const TujuanRepositori(this._db);

  final BasisDataFunda _db;

  /// Memantau seluruh tujuan finansial yang tidak diarsipkan.
  Stream<List<EntitasTujuan>> pantauTujuanAktif() {
    final kueri = _db.select(_db.tabelTujuan)
      ..where((t) => t.status.isNotValue(StatusTujuan.diarsipkan.kode))
      ..orderBy([
        (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Memantau seluruh tujuan (termasuk yang diarsipkan).
  Stream<List<EntitasTujuan>> pantauSemuaTujuan() {
    final kueri = _db.select(_db.tabelTujuan)
      ..orderBy([
        (t) => OrderingTerm(expression: t.dibuatPada, mode: OrderingMode.desc),
      ]);
    return kueri.watch();
  }

  /// Mengambil tujuan berdasarkan ID.
  Future<EntitasTujuan?> ambilTujuanBerdasarkanId(String id) {
    return (_db.select(
      _db.tabelTujuan,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  static int _pencacahUnik = 0;

  /// Helper pembuatan tujuan finansial dengan parameter dasar.
  Future<String> buatTujuan({
    required String nama,
    required String jenis,
    required int targetRupiah,
    required String ikon,
    required String warna,
    DateTime? tenggat,
  }) async {
    final id = 'tuj_${DateTime.now().microsecondsSinceEpoch}_${++_pencacahUnik}';
    final sekarang = DateTime.now();
    await tambahTujuan(
      TabelTujuanCompanion(
        id: Value(id),
        nama: Value(nama),
        jenis: Value(jenis),
        targetRupiah: Value(targetRupiah),
        tenggat: Value(tenggat),
        ikon: Value(ikon),
        warna: Value(warna),
        status: const Value('aktif'),
        dibuatPada: Value(sekarang),
      ),
    );
    return id;
  }

  /// Helper pembaruan tujuan finansial.
  Future<void> ubahTujuan({
    required String id,
    required String nama,
    required int targetRupiah,
    required String ikon,
    required String warna,
    DateTime? tenggat,
  }) async {
    await perbaruiTujuan(
      TabelTujuanCompanion(
        id: Value(id),
        nama: Value(nama),
        targetRupiah: Value(targetRupiah),
        tenggat: Value(tenggat),
        ikon: Value(ikon),
        warna: Value(warna),
        status: const Value('aktif'),
      ),
    );
  }

  /// Menambah target tujuan finansial baru.
  /// Menegakkan aturan: Hanya SATU tujuan Dana Darurat yang berstatus aktif pada satu waktu.
  Future<int> tambahTujuan(TabelTujuanCompanion tujuan) async {
    final jenis = tujuan.jenis.value;
    final status = tujuan.status.value;

    if (jenis == JenisTujuan.danaDarurat.kode &&
        status == StatusTujuan.aktif.kode) {
      final sudahAda = await _adaDanaDaruratAktif();
      if (sudahAda) {
        throw StateError(
          'Kamu sudah memiliki satu tujuan Dana Darurat yang aktif. '
          'Selesaikan atau arsipkan tujuan sebelumnya terlebih dahulu ya.',
        );
      }
    }

    return _db.into(_db.tabelTujuan).insert(tujuan);
  }

  /// Memperbarui tujuan yang sudah ada.
  Future<bool> perbaruiTujuan(TabelTujuanCompanion tujuan) async {
    final id = tujuan.id.value;
    final jenis = tujuan.jenis.value;
    final status = tujuan.status.value;

    if (jenis == JenisTujuan.danaDarurat.kode &&
        status == StatusTujuan.aktif.kode) {
      final sudahAda = await _adaDanaDaruratAktif(kecualikanId: id);
      if (sudahAda) {
        throw StateError(
          'Kamu sudah memiliki satu tujuan Dana Darurat yang aktif. '
          'Selesaikan atau arsipkan tujuan sebelumnya terlebih dahulu ya.',
        );
      }
    }

    return _db.update(_db.tabelTujuan).replace(tujuan);
  }

  /// Mengubah status tujuan menjadi tercapai atau diarsipkan.
  Future<int> ubahStatusTujuan(String id, StatusTujuan statusBaru) {
    return (_db.update(_db.tabelTujuan)..where((t) => t.id.equals(id))).write(
      TabelTujuanCompanion(status: Value(statusBaru.kode)),
    );
  }

  /// Menghapus tujuan jika belum memiliki kantong terkait.
  Future<int> hapusTujuan(String id) async {
    final jumlahKantong =
        await (_db.selectOnly(_db.tabelKantong)
              ..addColumns([_db.tabelKantong.id.count()])
              ..where(_db.tabelKantong.tujuanId.equals(id)))
            .getSingle();

    final total = jumlahKantong.read(_db.tabelKantong.id.count()) ?? 0;
    if (total > 0) {
      throw StateError(
        'Tujuan tidak dapat dihapus karena masih memiliki kantong alokasi yang tertaut. '
        'Kamu bisa mengarsipkannya saja.',
      );
    }

    return (_db.delete(_db.tabelTujuan)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> _adaDanaDaruratAktif({String? kecualikanId}) async {
    final kueri = _db.select(_db.tabelTujuan)
      ..where((t) {
        var kondisi =
            t.jenis.equals(JenisTujuan.danaDarurat.kode) &
            t.status.equals(StatusTujuan.aktif.kode);
        if (kecualikanId != null) {
          kondisi = kondisi & t.id.isNotValue(kecualikanId);
        }
        return kondisi;
      });
    final hasil = await kueri.get();
    return hasil.isNotEmpty;
  }
}
