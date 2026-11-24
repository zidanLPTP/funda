import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk mengelola status sesi simulasi Mode Sandbox investasi.
///
/// Data pada repositori ini TERISOLASI TOTAL dari data pengguna asli:
/// tidak memiliki hubungan foreign key ke dompet, transaksi, kategori, atau tabel keuangan lainnya.
class SandboxRepositori {
  final BasisDataFunda _db;

  const SandboxRepositori(this._db);

  /// Mengambil sesi sandbox aktif saat ini (paling terakhir diperbarui).
  Future<EntitasSesiSandbox?> ambilSesiTerakhir() async {
    return (_db.select(_db.tabelSesiSandbox)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Aliran reaktif sesi sandbox aktif.
  Stream<EntitasSesiSandbox?> pantauSesiTerakhir() {
    return (_db.select(_db.tabelSesiSandbox)
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Menyimpan atau memperbarui sesi sandbox secara atomik.
  Future<int> simpanSesi({
    int saldoAwalRupiah = 10000000,
    required int alokasiPasarUangPersen,
    required int alokasiObligasiPersen,
    required int alokasiSahamPersen,
    required int bulanBerjalan,
    required int nilaiSaatIniRupiah,
    required String skenarioAktif,
    required String riwayatJson,
  }) async {
    final sekarang = DateTime.now();
    final sesiLama = await ambilSesiTerakhir();

    if (sesiLama != null) {
      await (_db.update(
        _db.tabelSesiSandbox,
      )..where((t) => t.id.equals(sesiLama.id))).write(
        TabelSesiSandboxCompanion(
          saldoAwalRupiah: Value(saldoAwalRupiah),
          alokasiPasarUangPersen: Value(alokasiPasarUangPersen),
          alokasiObligasiPersen: Value(alokasiObligasiPersen),
          alokasiSahamPersen: Value(alokasiSahamPersen),
          bulanBerjalan: Value(bulanBerjalan),
          nilaiSaatIniRupiah: Value(nilaiSaatIniRupiah),
          skenarioAktif: Value(skenarioAktif),
          riwayatJson: Value(riwayatJson),
          diperbaruiPada: Value(sekarang),
        ),
      );
      return sesiLama.id;
    } else {
      return _db
          .into(_db.tabelSesiSandbox)
          .insert(
            TabelSesiSandboxCompanion.insert(
              saldoAwalRupiah: Value(saldoAwalRupiah),
              alokasiPasarUangPersen: alokasiPasarUangPersen,
              alokasiObligasiPersen: alokasiObligasiPersen,
              alokasiSahamPersen: alokasiSahamPersen,
              bulanBerjalan: Value(bulanBerjalan),
              nilaiSaatIniRupiah: nilaiSaatIniRupiah,
              skenarioAktif: skenarioAktif,
              riwayatJson: riwayatJson,
              diperbaruiPada: sekarang,
            ),
          );
    }
  }

  /// Mereset seluruh sesi simulasi sandbox kembali ke keadaan kosong / awal.
  Future<void> resetSesi() async {
    await _db.delete(_db.tabelSesiSandbox).go();
  }
}
