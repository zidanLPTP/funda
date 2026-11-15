/// Jenis bunga atau skema biaya pinjaman.
enum JenisBunga {
  tanpaBunga('tanpa_bunga', 'Tanpa Bunga (0%)'),
  flat('flat', 'Bunga Flat / Tetap'),
  efektif('efektif', 'Bunga Efektif');

  const JenisBunga(this.kode, this.label);

  final String kode;
  final String label;

  static JenisBunga dariKode(String kode) {
    return JenisBunga.values.firstWhere(
      (b) => b.kode == kode,
      orElse: () => JenisBunga.tanpaBunga,
    );
  }
}
