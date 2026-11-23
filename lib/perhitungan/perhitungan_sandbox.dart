/// Logika murni untuk simulasi mode sandbox edukasi investasi di Funda.
///
/// Seluruh perhitungan di sini murni memakai aritmetika integer ([int])
/// dalam satuan Rupiah penuh dan basis poin (1 bp = 0.01% = 1/10000).
/// DILARANG menggunakan tipe pecahan mengambang untuk menjaga presisi dan
/// stabilitas lintas arsitektur platform.
library;

// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinPasarUangNormal = 400; // +4%
// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinObligasiNormal = 600; // +6%
// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinSahamNormal = 1000; // +10%

// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinPasarUangTurun = 300; // +3%
// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinObligasiTurun = -200; // -2%
// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinSahamTurun = -2000; // -20%

// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinPasarUangNaik = 500; // +5%
// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinObligasiNaik = 800; // +8%
// TODO-VERIFIKASI: angka simulasi edukatif, bukan prediksi
const int basisPoinSahamNaik = 1800; // +18%

/// Memeriksa apakah alokasi tiga instrumen sah (masing-masing 0..100 dan total tepat 100).
bool validasiAlokasiSandbox({
  required int persenPasarUang,
  required int persenObligasi,
  required int persenSaham,
}) {
  if (persenPasarUang < 0 || persenPasarUang > 100) return false;
  if (persenObligasi < 0 || persenObligasi > 100) return false;
  if (persenSaham < 0 || persenSaham > 100) return false;
  return persenPasarUang + persenObligasi + persenSaham == 100;
}

/// Representasi hasil simulasi majemuk sandbox per instrumen dan total.
class HasilSimulasiSandbox {
  final int nilaiPasarUang;
  final int nilaiObligasi;
  final int nilaiSaham;
  final int nilaiAkhirTotal;
  final int selisihRupiah;

  const HasilSimulasiSandbox({
    required this.nilaiPasarUang,
    required this.nilaiObligasi,
    required this.nilaiSaham,
    required this.nilaiAkhirTotal,
    required this.selisihRupiah,
  });
}

/// Menghitung perkembangan majemuk tahunan portofolio investasi fiktif sandbox.
///
/// [saldoAwal] dalam satuan Rupiah penuh (misalnya 10.000.000).
/// [skenario] bernilai 'normal', 'turun', atau 'naik'.
HasilSimulasiSandbox hitungSimulasiSandbox({
  required int saldoAwal,
  required int persenPasarUang,
  required int persenObligasi,
  required int persenSaham,
  required int jumlahTahun,
  required String skenario,
}) {
  if (!validasiAlokasiSandbox(
    persenPasarUang: persenPasarUang,
    persenObligasi: persenObligasi,
    persenSaham: persenSaham,
  )) {
    throw ArgumentError(
      'Total alokasi harus tepat 100% dan tiap instrumen berada di antara 0..100%',
    );
  }

  int bpPU;
  int bpOB;
  int bpSH;

  switch (skenario) {
    case 'normal':
      bpPU = basisPoinPasarUangNormal;
      bpOB = basisPoinObligasiNormal;
      bpSH = basisPoinSahamNormal;
      break;
    case 'turun':
      bpPU = basisPoinPasarUangTurun;
      bpOB = basisPoinObligasiTurun;
      bpSH = basisPoinSahamTurun;
      break;
    case 'naik':
      bpPU = basisPoinPasarUangNaik;
      bpOB = basisPoinObligasiNaik;
      bpSH = basisPoinSahamNaik;
      break;
    default:
      throw ArgumentError('Skenario tidak dikenal: $skenario');
  }

  // Hitung alokasi porsi awal per instrumen dengan pembagian integer.
  // Sisa porsi dialokasikan ke saham untuk mencegah selisih pembulatan integer.
  final nilaiAwalRupiah = saldoAwal;
  final nominalPasarUang = (nilaiAwalRupiah * persenPasarUang) ~/ 100;
  final nominalObligasi = (nilaiAwalRupiah * persenObligasi) ~/ 100;
  final nominalSaham = nilaiAwalRupiah - nominalPasarUang - nominalObligasi;

  int nilaiPU = nominalPasarUang;
  int nilaiOB = nominalObligasi;
  int nilaiSH = nominalSaham;

  // Majukan per tahun secara majemuk dengan aritmetika integer
  for (int thn = 0; thn < jumlahTahun; thn++) {
    nilaiPU = nilaiPU + (nilaiPU * bpPU ~/ 10000);
    nilaiOB = nilaiOB + (nilaiOB * bpOB ~/ 10000);
    nilaiSH = nilaiSH + (nilaiSH * bpSH ~/ 10000);
  }

  final nilaiAkhirTotal = nilaiPU + nilaiOB + nilaiSH;
  final selisihRupiah = nilaiAkhirTotal - saldoAwal;

  return HasilSimulasiSandbox(
    nilaiPasarUang: nilaiPU,
    nilaiObligasi: nilaiOB,
    nilaiSaham: nilaiSH,
    nilaiAkhirTotal: nilaiAkhirTotal,
    selisihRupiah: selisihRupiah,
  );
}

/// Menghitung perkiraan daya beli riil uang tunai yang tergerus inflasi tahunan.
///
/// Secara default menggunakan pembulatan integer terdekat (round half-up)
/// `(nilai * 10000 + pembagi ~/ 2) ~/ pembagi` agar selaras persis dengan angka
/// ilustrasi materi (8.219.271 setelah 5 tahun untuk nilai awal 10.000.000 pada 4%).
int hitungDayaBeliInflasi({
  required int nilaiAwal,
  required int inflasiBpPerTahun,
  required int jumlahTahun,
  bool pembulatanTerdekat = true,
}) {
  if (jumlahTahun <= 0) return nilaiAwal;

  int nilaiBerjalan = nilaiAwal;
  final pembagi = 10000 + inflasiBpPerTahun;

  for (int thn = 0; thn < jumlahTahun; thn++) {
    if (pembulatanTerdekat) {
      nilaiBerjalan = (nilaiBerjalan * 10000 + pembagi ~/ 2) ~/ pembagi;
    } else {
      nilaiBerjalan = nilaiBerjalan * 10000 ~/ pembagi;
    }
  }

  return nilaiBerjalan;
}
