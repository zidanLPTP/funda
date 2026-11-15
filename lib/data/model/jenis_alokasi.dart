/// Jenis operasi mutasi saldo alokasi kantong.
enum JenisAlokasi {
  isi('isi', 'Isi Kantong'),
  ambil('ambil', 'Ambil dari Kantong');

  const JenisAlokasi(this.kode, this.label);
  final String kode;
  final String label;

  static JenisAlokasi dariKode(String kode) {
    return JenisAlokasi.values.firstWhere(
      (j) => j.kode == kode,
      orElse: () => JenisAlokasi.isi,
    );
  }
}
