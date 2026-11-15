/// Status penandaan periode tagihan.
enum StatusPembayaranTagihan {
  dibayar('dibayar', 'Dibayar'),
  dilewati('dilewati', 'Dilewati');

  const StatusPembayaranTagihan(this.kode, this.judul);
  final String kode;
  final String judul;

  static StatusPembayaranTagihan dariKode(String kode) {
    return StatusPembayaranTagihan.values.firstWhere(
      (s) => s.kode == kode,
      orElse: () => StatusPembayaranTagihan.dibayar,
    );
  }
}
