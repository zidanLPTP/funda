/// Arah mutasi penyesuaian saldo utang.
enum ArahPenyesuaianUtang {
  tambah('tambah', 'Tambah Sisa (Bunga/Denda)'),
  kurang('kurang', 'Kurang Sisa (Koreksi/Diskon)');

  const ArahPenyesuaianUtang(this.kode, this.label);

  final String kode;
  final String label;

  static ArahPenyesuaianUtang dariKode(String kode) {
    return ArahPenyesuaianUtang.values.firstWhere(
      (a) => a.kode == kode,
      orElse: () => ArahPenyesuaianUtang.tambah,
    );
  }
}
