/// Sifat kategori pengeluaran / pemasukan.
enum SifatKategori {
  kebutuhan('kebutuhan', 'Kebutuhan'),
  keinginan('keinginan', 'Keinginan'),
  tabungan('tabungan', 'Tabungan'),
  utang('utang', 'Utang / Cicilan'),
  belumDilabeli('belum_dilabeli', 'Belum Dilabeli'),
  tidakBerlaku('tidak_berlaku', 'Tidak Berlaku');

  const SifatKategori(this.kode, this.label);

  final String kode;
  final String label;

  static SifatKategori dariKode(String kode) {
    return SifatKategori.values.firstWhere(
      (s) => s.kode == kode,
      orElse: () => SifatKategori.belumDilabeli,
    );
  }
}
