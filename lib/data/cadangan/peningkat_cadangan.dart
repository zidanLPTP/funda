/// Definisi fungsi peningkat skema cadangan antar versi.
typedef FungsiPeningkatTabel = Map<String, List<Map<String, dynamic>>> Function(
  Map<String, List<Map<String, dynamic>>> tabel,
);

/// Registri fungsi peningkatan skema data cadangan Funda untuk menjaga kompatibilitas masa depan.
class RegistriPeningkatCadangan {
  /// Versi skema basis data saat sistem cadangan pertama kali diimplementasikan (Tahap 7 = skema 10).
  static const int versiSkemaCadanganPertama = 10;

  static final Map<int, FungsiPeningkatTabel> _registri = {
    // Versi 10 -> 11 (Tahap 9A: Penambahan tabel_sesi_sandbox yang dikecualikan dari cadangan)
    10: (tabel) => tabel,
  };

  /// Mendaftarkan fungsi peningkat dari versi [dariVersi] ke [dariVersi + 1].
  static void daftarkan(int dariVersi, FungsiPeningkatTabel peningkat) {
    _registri[dariVersi] = peningkat;
  }

  /// Memeriksa apakah peningkat untuk versi tertentu telah terdaftar.
  static bool adaPeningkat(int dariVersi) => _registri.containsKey(dariVersi);

  /// Menjalankan rantai fungsi peningkat dari versi awal sampai versi target aplikasi.
  static Map<String, List<Map<String, dynamic>>> tingkatkan(
    Map<String, List<Map<String, dynamic>>> tabel, {
    required int dariVersi,
    required int keVersi,
  }) {
    var hasil = tabel;
    for (var v = dariVersi; v < keVersi; v++) {
      final peningkat = _registri[v];
      if (peningkat == null) {
        throw StateError(
          'Tidak ditemukan fungsi peningkat skema cadangan dari versi $v ke ${v + 1}. '
          'Setiap kenaikan schemaVersion wajib mendaftarkan fungsi peningkat di RegistriPeningkatCadangan.',
        );
      }
      hasil = peningkat(hasil);
    }
    return hasil;
  }
}
