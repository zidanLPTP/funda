/// Arah arus kas transaksi atau kategori.
enum ArusTransaksi {
  masuk('masuk', 'Pemasukan'),
  keluar('keluar', 'Pengeluaran');

  const ArusTransaksi(this.kode, this.label);

  final String kode;
  final String label;

  static ArusTransaksi dariKode(String kode) {
    return ArusTransaksi.values.firstWhere(
      (a) => a.kode == kode,
      orElse: () => ArusTransaksi.keluar,
    );
  }
}
