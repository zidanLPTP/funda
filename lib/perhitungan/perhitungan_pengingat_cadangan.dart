/// Ambang batas jumlah transaksi sebelum cadangan pertama diingatkan (20 transaksi).
const int ambangTransaksiBelumCadangan = 20;

/// Ambang batas hari sejak transaksi pertama sebelum cadangan pertama diingatkan (7 hari).
const int ambangHariSejakDataPertama = 7;

/// Ambang batas hari sejak cadangan terakhir sebelum pengingat berikutnya muncul (30 hari).
const int ambangHariPernahCadangan = 30;

/// Durasi penundaan pengingat cadangan jika pengguna memilih opsi "Nanti" (14 hari).
const int durasiTundaCadanganHari = 14;

/// Fungsi murni untuk mengevaluasi apakah banner pengingat cadangan perlu ditampilkan di Beranda.
///
/// Aturan:
/// 1. Jika pengguna pernah menunda pengingat (`ditundaSampai != null`) dan `sekarang < ditundaSampai`, kembalikan false.
/// 2. Jika belum pernah dicadangkan (`terakhirCadangan == null`):
///    - Ditampilkan jika `jumlahTransaksi >= 20` atau `hariSejakDataPertama >= 7`.
/// 3. Jika sudah pernah dicadangkan (`terakhirCadangan != null`):
///    - Ditampilkan jika sudah lebih dari 30 hari (`sekarang - terakhirCadangan > 30 hari`)
///      DAN terdapat transaksi baru sejak tanggal pencadangan terakhir.
bool perluIngatkanCadangan({
  required DateTime sekarang,
  required DateTime? terakhirCadangan,
  required int jumlahTransaksi,
  required int hariSejakDataPertama,
  DateTime? ditundaSampai,
  bool adaTransaksiBaruSejakCadangan = true,
}) {
  // Aturan 1: Sedang dalam masa tunda
  if (ditundaSampai != null && sekarang.isBefore(ditundaSampai)) {
    return false;
  }

  // Aturan 2: Belum pernah dicadangkan
  if (terakhirCadangan == null) {
    if (jumlahTransaksi >= ambangTransaksiBelumCadangan ||
        hariSejakDataPertama >= ambangHariSejakDataPertama) {
      return true;
    }
    return false;
  }

  // Aturan 3: Pernah dicadangkan > 30 hari lalu dan ada transaksi baru
  final selisihHari = sekarang.difference(terakhirCadangan).inDays;
  if (selisihHari > ambangHariPernahCadangan && adaTransaksiBaruSejakCadangan) {
    return true;
  }

  return false;
}
