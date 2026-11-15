/// Jenis dompet yang didukung oleh aplikasi Funda.
enum JenisDompet {
  tunai('tunai', 'Tunai'),
  rekeningBank('rekening_bank', 'Rekening Bank'),
  eWallet('e_wallet', 'Dompet Digital / E-Wallet'),
  lainnya('lainnya', 'Lainnya');

  const JenisDompet(this.kode, this.label);

  final String kode;
  final String label;

  static JenisDompet dariKode(String kode) {
    return JenisDompet.values.firstWhere(
      (j) => j.kode == kode,
      orElse: () => JenisDompet.lainnya,
    );
  }
}
