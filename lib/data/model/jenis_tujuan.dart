/// Jenis tujuan finansial pada aplikasi Funda.
enum JenisTujuan {
  tabungan('tabungan', 'Tabungan'),
  danaDarurat('dana_darurat', 'Dana Darurat'),
  tujuanBesar('tujuan_besar', 'Tujuan Besar'),
  lainnya('lainnya', 'Lainnya');

  const JenisTujuan(this.kode, this.label);
  final String kode;
  final String label;

  static JenisTujuan dariKode(String kode) {
    return JenisTujuan.values.firstWhere(
      (j) => j.kode == kode,
      orElse: () => JenisTujuan.lainnya,
    );
  }
}
