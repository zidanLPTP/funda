/// Status penyelesaian catatan utang.
enum StatusUtang {
  aktif('aktif', 'Aktif'),
  lunas('lunas', 'Lunas'),
  diarsipkan('diarsipkan', 'Diarsipkan');

  const StatusUtang(this.kode, this.label);

  final String kode;
  final String label;

  static StatusUtang dariKode(String kode) {
    return StatusUtang.values.firstWhere(
      (s) => s.kode == kode,
      orElse: () => StatusUtang.aktif,
    );
  }
}
