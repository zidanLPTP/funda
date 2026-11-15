/// Jenis-jenis utang yang dicatat pengguna.
enum JenisUtang {
  cicilan('cicilan', 'Cicilan'),
  pinjamanPribadi('pinjaman_pribadi', 'Pinjaman Pribadi'),
  paylater('paylater', 'Paylater'),
  kartuKredit('kartu_kredit', 'Kartu Kredit'),
  lainnya('lainnya', 'Utang Lainnya');

  const JenisUtang(this.kode, this.label);

  final String kode;
  final String label;

  static JenisUtang dariKode(String kode) {
    return JenisUtang.values.firstWhere(
      (j) => j.kode == kode,
      orElse: () => JenisUtang.lainnya,
    );
  }
}
