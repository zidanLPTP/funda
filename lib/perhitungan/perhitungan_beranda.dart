/// Record representasi sapaan ramah dan pesan kontekstual beranda.
typedef DataSapaanBeranda = ({String sapaan, String pesanMotivasi});

/// Menghasilkan sapaan waktu dan pesan refleksi yang bersahabat dan memberdayakan.
DataSapaanBeranda hitungSapaanKontekstual(DateTime waktu) {
  final jam = waktu.hour;
  final menit = waktu.minute;
  final tanggal = waktu.day;

  final String sapaan;
  if (jam >= 5 && jam < 12) {
    sapaan = 'Selamat pagi';
  } else if (jam >= 12 && jam < 15) {
    sapaan = 'Selamat siang';
  } else if (jam >= 15 && (jam < 18 || (jam == 18 && menit < 30))) {
    sapaan = 'Selamat sore';
  } else {
    sapaan = 'Selamat malam';
  }

  final String pesanMotivasi;
  if (tanggal <= 5) {
    pesanMotivasi =
        'Waktunya menata pos anggaran dan mengecek alokasi kantongmu.';
  } else if (tanggal >= 25) {
    pesanMotivasi =
        'Akhir bulan yang baik untuk meninjau pencapaian di Laporan Bulanan.';
  } else if (jam >= 5 && jam < 12) {
    pesanMotivasi =
        'Awali hari dengan tenang, catat pengeluaran kecilmu hari ini.';
  } else if (jam >= 12 && jam < 15) {
    pesanMotivasi =
        'Istirahat sejenak dan luangkan waktu mencatat makan siangmu.';
  } else if (jam >= 15 && (jam < 18 || (jam == 18 && menit < 30))) {
    pesanMotivasi = 'Sore yang baik untuk memeriksa sisa pos harianmu.';
  } else {
    pesanMotivasi =
        'Tutup hari dengan tenang, seluruh catatanmu tersimpan privat.';
  }

  return (sapaan: sapaan, pesanMotivasi: pesanMotivasi);
}
