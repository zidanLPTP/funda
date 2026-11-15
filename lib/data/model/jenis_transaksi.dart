/// Jenis aksi transaksi yang dicatat di aplikasi.
enum JenisTransaksi {
  masuk('masuk', 'Pemasukan'),
  keluar('keluar', 'Pengeluaran'),
  transfer('transfer', 'Transfer Antar Dompet'),
  penyesuaianMasuk('penyesuaian_masuk', 'Penyesuaian Saldo (Tambah)'),
  penyesuaianKeluar('penyesuaian_keluar', 'Penyesuaian Saldo (Kurang)');

  const JenisTransaksi(this.kode, this.label);

  final String kode;
  final String label;

  static JenisTransaksi dariKode(String kode) {
    return JenisTransaksi.values.firstWhere(
      (j) => j.kode == kode,
      orElse: () => JenisTransaksi.keluar,
    );
  }
}
