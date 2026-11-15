import 'package:intl/intl.dart';

/// Pengecualian ketika masukan teks format Rupiah tidak valid.
class GalatFormatRupiah implements Exception {
  const GalatFormatRupiah(this.pesan);

  final String pesan;

  @override
  String toString() => 'GalatFormatRupiah: $pesan';
}

/// Pemformat angka ribuan Indonesia menggunakan titik sebagai pemisah ribuan.
final _pemformatRibuan = NumberFormat('#,##0', 'id_ID');

/// Memformat nominal uang [int] Rupiah ke bentuk teks yang rapi dan terstandarisasi.
///
/// Contoh:
/// - `formatRupiah(1250000)` -> `'Rp 1.250.000'`
/// - `formatRupiah(0)` -> `'Rp 0'`
/// - `formatRupiah(-300000)` -> `'-Rp 300.000'`
String formatRupiah(int nominal) {
  if (nominal == 0) {
    return 'Rp 0';
  }

  if (nominal < 0) {
    final nilaiPositif = nominal.abs();
    final teksAngka = _pemformatRibuan
        .format(nilaiPositif)
        .replaceAll(',', '.');
    return '-Rp $teksAngka';
  }

  final teksAngka = _pemformatRibuan.format(nominal).replaceAll(',', '.');
  return 'Rp $teksAngka';
}

/// Mengambil nilai [int] Rupiah dari teks masukan pengguna.
///
/// Menerima teks seperti `'Rp 1.250.000'`, `'1.250.000'`, `'1250000'`,
/// `'-Rp 300.000'`, `'−Rp 300.000'`.
///
/// Melempar [GalatFormatRupiah] jika teks tidak valid, kosong, atau mengandung
/// desimal/koma (karena Funda hanya menggunakan bilangan bulat Rupiah).
int ambilAngkaRupiah(String teks) {
  final teksBersih = teks.trim();
  if (teksBersih.isEmpty) {
    throw const GalatFormatRupiah('Masukan teks tidak boleh kosong.');
  }

  // Cek apakah ada koma desimal
  if (teksBersih.contains(',')) {
    throw const GalatFormatRupiah(
      'Funda hanya menerima bilangan bulat Rupiah tanpa pecahan sen/desimal.',
    );
  }

  // Cek tanda negatif (- standar atau − U+2212)
  var tandaNegatif = false;
  var teksTanpaTanda = teksBersih;
  if (teksTanpaTanda.startsWith('-') || teksTanpaTanda.startsWith('−')) {
    tandaNegatif = true;
    teksTanpaTanda = teksTanpaTanda.substring(1).trim();
  }

  // Buang awalan "Rp" atau "rp"
  if (teksTanpaTanda.toLowerCase().startsWith('rp')) {
    teksTanpaTanda = teksTanpaTanda.substring(2).trim();
  }

  // Jika setelah dibuang awalan ada tanda minus lagi (misal "Rp -300")
  if (teksTanpaTanda.startsWith('-') || teksTanpaTanda.startsWith('−')) {
    tandaNegatif = true;
    teksTanpaTanda = teksTanpaTanda.substring(1).trim();
  }

  if (teksTanpaTanda.isEmpty) {
    throw const GalatFormatRupiah('Nominal angka tidak ditemukan dalam teks.');
  }

  // Buang tanda titik pemisah ribuan dan spasi
  final digitHanya = teksTanpaTanda.replaceAll('.', '').replaceAll(' ', '');

  final hasil = int.tryParse(digitHanya);
  if (hasil == null) {
    throw GalatFormatRupiah('Masukan "$teks" bukan angka Rupiah yang valid.');
  }

  return tandaNegatif ? -hasil : hasil;
}
