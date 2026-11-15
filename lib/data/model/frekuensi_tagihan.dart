/// Frekuensi pengulangan jatuh tempo tagihan atau langganan.
enum FrekuensiTagihan {
  mingguan('mingguan', 'Mingguan'),
  bulanan('bulanan', 'Bulanan'),
  tahunan('tahunan', 'Tahunan');

  const FrekuensiTagihan(this.kode, this.judul);
  final String kode;
  final String judul;

  static FrekuensiTagihan dariKode(String kode) {
    return FrekuensiTagihan.values.firstWhere(
      (f) => f.kode == kode,
      orElse: () => FrekuensiTagihan.bulanan,
    );
  }
}
