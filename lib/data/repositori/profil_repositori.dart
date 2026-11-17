import 'package:drift/drift.dart';
import '../basis_data.dart';

/// Repositori untuk menyimpan dan mengambil data profil keuangan pengguna.
class ProfilRepositori {
  final BasisDataFunda _db;

  const ProfilRepositori(this._db);

  /// Mengambil profil keuangan pengguna yang tersimpan (1 baris aktif).
  Future<EntitasProfilKeuangan?> ambilProfil() async {
    return (_db.select(_db.tabelProfilKeuangan)..limit(1)).getSingleOrNull();
  }

  /// Aliran reaktif profil keuangan pengguna.
  Stream<EntitasProfilKeuangan?> pantauProfil() {
    return (_db.select(_db.tabelProfilKeuangan)..limit(1)).watchSingleOrNull();
  }

  /// Menyimpan atau memperbarui profil keuangan pengguna.
  Future<void> simpanProfil({
    required String punyaPenghasilan,
    required String punyaUtang,
    required String danaDarurat,
    required String menabung,
    required String investasi,
    required String mencatatKeuangan,
    String? tujuanUtama,
  }) async {
    final sekarang = DateTime.now();
    final profilLama = await ambilProfil();

    if (profilLama != null) {
      // Perbarui profil yang ada
      await (_db.update(_db.tabelProfilKeuangan)
            ..where((t) => t.id.equals(profilLama.id)))
          .write(
        TabelProfilKeuanganCompanion(
          punyaPenghasilan: Value(punyaPenghasilan),
          punyaUtang: Value(punyaUtang),
          danaDarurat: Value(danaDarurat),
          menabung: Value(menabung),
          investasi: Value(investasi),
          mencatatKeuangan: Value(mencatatKeuangan),
          tujuanUtama: Value(tujuanUtama),
          diperbaruiPada: Value(sekarang),
        ),
      );
    } else {
      // Masukkan profil baru
      await _db.into(_db.tabelProfilKeuangan).insert(
            TabelProfilKeuanganCompanion.insert(
              punyaPenghasilan: punyaPenghasilan,
              punyaUtang: punyaUtang,
              danaDarurat: danaDarurat,
              menabung: menabung,
              investasi: investasi,
              mencatatKeuangan: mencatatKeuangan,
              tujuanUtama: Value(tujuanUtama),
              diisiPada: sekarang,
              diperbaruiPada: sekarang,
            ),
          );
    }
  }

  /// Menghapus profil keuangan jika pengguna ingin mengulang/reset tes awal.
  Future<void> hapusProfil() async {
    await _db.delete(_db.tabelProfilKeuangan).go();
  }
}
