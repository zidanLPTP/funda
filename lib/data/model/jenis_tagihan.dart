/// Jenis komitmen berulang: tagihan wajib atau langganan.
enum JenisTagihan {
  tagihan('tagihan', 'Tagihan'),
  langganan('langganan', 'Langganan');

  const JenisTagihan(this.kode, this.judul);
  final String kode;
  final String judul;

  static JenisTagihan dariKode(String kode) {
    return JenisTagihan.values.firstWhere(
      (j) => j.kode == kode,
      orElse: () => JenisTagihan.tagihan,
    );
  }
}
