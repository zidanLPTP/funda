/// Status pencapaian target tujuan finansial.
enum StatusTujuan {
  aktif('aktif', 'Sedang Berjalan'),
  tercapai('tercapai', 'Tercapai'),
  diarsipkan('diarsipkan', 'Diarsipkan');

  const StatusTujuan(this.kode, this.label);
  final String kode;
  final String label;

  static StatusTujuan dariKode(String kode) {
    return StatusTujuan.values.firstWhere(
      (s) => s.kode == kode,
      orElse: () => StatusTujuan.aktif,
    );
  }
}
