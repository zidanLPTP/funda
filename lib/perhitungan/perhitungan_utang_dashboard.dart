import '../data/basis_data.dart';
import '../data/model/arah_penyesuaian_utang.dart';
import '../data/model/jenis_tujuan.dart';
import '../util/format_rupiah.dart';

/// Ambang batas aturan praktis rasio cicilan perbankan (30%).
/// BELUM digunakan untuk melabeli aman/bahaya di UI (hanya ditampilkan persentasenya).
/// TODO-VERIFIKASI: Acuan perbankan 30% untuk materi edukasi cicilan nanti.
const int ambangRasioCicilanAturanPraktis = 30;

/// Sumber dasar perhitungan pemasukan rata-rata pengguna.
enum DasarPemasukanRataRata {
  /// Berdasarkan rata-rata 3 bulan kalender terakhir yang sudah selesai.
  rataRata3Bulan('dari rata-rata pemasukan 3 bulan terakhir'),

  /// Berdasarkan total pemasukan bulan berjalan (jika belum ada data 3 bulan lalu).
  bulanBerjalan('dari pemasukan bulan ini'),

  /// Belum ada catatan pemasukan sama sekali.
  belumAda('belum ada catatan pemasukan');

  const DasarPemasukanRataRata(this.keterangan);
  final String keterangan;
}

/// Hasil evaluasi pemasukan bulanan rata-rata beserta dasar perhitungannya.
class HasilPemasukanRataRata {
  const HasilPemasukanRataRata({
    required this.nilaiRupiah,
    required this.dasar,
  });

  final int nilaiRupiah;
  final DasarPemasukanRataRata dasar;
}

/// Representasi item penyesuaian utang untuk kalkulasi murni.
class ItemPenyesuaianUtang {
  const ItemPenyesuaianUtang({required this.arah, required this.jumlahRupiah});

  final ArahPenyesuaianUtang arah;
  final int jumlahRupiah;
}

/// Hasil validasi transaksi/pembayaran utang.
class HasilValidasiUtang {
  const HasilValidasiUtang({required this.sukses, this.pesanGalat});

  final bool sukses;
  final String? pesanGalat;
}

/// Menghitung sisa utang saat ini dari sisa awal, riwayat pembayaran, dan penyesuaian.
/// Sisa utang = sisaAwal - totalPembayaran + penyesuaianTambah - penyesuaianKurang.
/// Nilai sisa utang dibatasi minimal 0 (lunas).
int hitungSisaUtang({
  required int sisaAwalRupiah,
  required List<int> daftarJumlahPembayaranRupiah,
  required List<ItemPenyesuaianUtang> daftarPenyesuaian,
}) {
  var total = sisaAwalRupiah;

  for (final bayar in daftarJumlahPembayaranRupiah) {
    total -= bayar;
  }

  for (final p in daftarPenyesuaian) {
    if (p.arah == ArahPenyesuaianUtang.tambah) {
      total += p.jumlahRupiah;
    } else {
      total -= p.jumlahRupiah;
    }
  }

  return total < 0 ? 0 : total;
}

/// Menghitung total seluruh sisa utang aktif.
int hitungTotalSisaUtang(List<int> daftarSisaUtangAktifRupiah) {
  var total = 0;
  for (final sisa in daftarSisaUtangAktifRupiah) {
    total += sisa;
  }
  return total;
}

/// Menghitung total kewajiban cicilan bulanan dari seluruh utang aktif.
int hitungTotalCicilanBulanan(List<int> daftarCicilanBulananAktifRupiah) {
  var total = 0;
  for (final cicilan in daftarCicilanBulananAktifRupiah) {
    total += cicilan;
  }
  return total;
}

/// Menghitung estimasi sisa bulan pelunasan dengan pembulatan ke atas (integer ceiling).
/// Jika cicilan 0 atau sisa utang 0, kembalikan null (tidak ada estimasi pasti).
int? hitungEstimasiSisaBulan({
  required int sisaRupiah,
  required int cicilanBulananRupiah,
}) {
  if (cicilanBulananRupiah <= 0 || sisaRupiah <= 0) return null;
  return (sisaRupiah + cicilanBulananRupiah - 1) ~/ cicilanBulananRupiah;
}

/// Menghitung pemasukan bulanan rata-rata:
/// - Menggunakan 3 bulan kalender terakhir yang SUDAH selesai jika ada data transaksi masuk.
/// - Jika tidak ada data di 3 bulan selesai, gunakan total pemasukan bulan berjalan.
/// - Jika tidak ada sama sekali pemasukan, kembalikan 0 dengan dasar belumAda.
HasilPemasukanRataRata hitungPemasukanBulananRataRata({
  required List<EntitasTransaksi> daftarTransaksi,
  required DateTime waktuSekarang,
}) {
  // Hanya ambil transaksi pemasukan
  final transaksiMasuk = daftarTransaksi
      .where((t) => t.jenis == 'masuk')
      .toList();

  if (transaksiMasuk.isEmpty) {
    return const HasilPemasukanRataRata(
      nilaiRupiah: 0,
      dasar: DasarPemasukanRataRata.belumAda,
    );
  }

  // Tentukan 3 bulan kalender terakhir yang sudah selesai
  final bulanTigaLalu = <({int tahun, int bulan})>[];
  var kursorTahun = waktuSekarang.year;
  var kursorBulan = waktuSekarang.month;

  for (var i = 0; i < 3; i++) {
    kursorBulan--;
    if (kursorBulan == 0) {
      kursorBulan = 12;
      kursorTahun--;
    }
    bulanTigaLalu.add((tahun: kursorTahun, bulan: kursorBulan));
  }

  // Kelompokkan pemasukan berdasarkan (tahun, bulan) waktu lokal
  final petaPemasukanPerBulan = <String, int>{};
  var pemasukanBulanBerjalan = 0;

  for (final t in transaksiMasuk) {
    final waktuLokal = t.waktuTransaksi.toLocal();
    final kunci = '${waktuLokal.year}_${waktuLokal.month}';
    petaPemasukanPerBulan[kunci] =
        (petaPemasukanPerBulan[kunci] ?? 0) + t.jumlahRupiah;

    if (waktuLokal.year == waktuSekarang.year &&
        waktuLokal.month == waktuSekarang.month) {
      pemasukanBulanBerjalan += t.jumlahRupiah;
    }
  }

  // Cek apakah ada data di 3 bulan terakhir
  var total3Bulan = 0;
  var adaData3Bulan = false;

  for (final periode in bulanTigaLalu) {
    final kunci = '${periode.tahun}_${periode.bulan}';
    final nominal = petaPemasukanPerBulan[kunci] ?? 0;
    if (nominal > 0) {
      adaData3Bulan = true;
    }
    total3Bulan += nominal;
  }

  if (adaData3Bulan) {
    return HasilPemasukanRataRata(
      nilaiRupiah: total3Bulan ~/ 3,
      dasar: DasarPemasukanRataRata.rataRata3Bulan,
    );
  }

  if (pemasukanBulanBerjalan > 0) {
    return HasilPemasukanRataRata(
      nilaiRupiah: pemasukanBulanBerjalan,
      dasar: DasarPemasukanRataRata.bulanBerjalan,
    );
  }

  return const HasilPemasukanRataRata(
    nilaiRupiah: 0,
    dasar: DasarPemasukanRataRata.belumAda,
  );
}

/// Menghitung rasio cicilan terhadap pemasukan bulanan dalam persentase integer.
/// Jika pemasukan bulanan <= 0, kembalikan null (tidak terdefinisi).
int? hitungRasioCicilan({
  required int totalCicilanBulananRupiah,
  required int pemasukanBulananRupiah,
}) {
  if (pemasukanBulananRupiah <= 0) return null;
  // Pembulatan aritmatika integer terdekat
  return ((totalCicilanBulananRupiah * 100) + (pemasukanBulananRupiah ~/ 2)) ~/
      pemasukanBulananRupiah;
}

/// Menghitung kekayaan bersih (total saldo dompet aktif dikurangi total sisa utang).
/// Nilai kekayaan bersih bisa bernilai negatif jika utang melebihi aset.
int hitungKekayaanBersih({
  required int totalSaldoDompetAktifRupiah,
  required int totalSisaUtangRupiah,
}) {
  return totalSaldoDompetAktifRupiah - totalSisaUtangRupiah;
}

/// Memilih tujuan terdekat untuk kartu Beranda:
/// - Tujuan aktif yang BUKAN dana_darurat.
/// - Prioritas 1: Memiliki tenggat dan belum tercapai (tenggat paling dekat).
/// - Prioritas 2: Jika tidak ada bertenggat, yang progresnya tertinggi dan belum tercapai.
EntitasTujuan? pilihTujuanTerdekat({
  required List<EntitasTujuan> daftarTujuan,
  Map<String, int> petaDanaTerkumpul = const {},
}) {
  final tujuanKandidat = daftarTujuan.where((t) {
    if (t.status != 'aktif') return false;
    if (t.jenis == JenisTujuan.danaDarurat.kode) return false;
    final dana = petaDanaTerkumpul[t.id] ?? 0;
    return dana < t.targetRupiah; // Belum tercapai
  }).toList();

  if (tujuanKandidat.isEmpty) return null;

  // 1. Cari yang bertenggat
  final denganTenggat = tujuanKandidat.where((t) => t.tenggat != null).toList();
  if (denganTenggat.isNotEmpty) {
    denganTenggat.sort((a, b) => a.tenggat!.compareTo(b.tenggat!));
    return denganTenggat.first;
  }

  // 2. Fallback: Progres tertinggi
  tujuanKandidat.sort((a, b) {
    final danaA = petaDanaTerkumpul[a.id] ?? 0;
    final danaB = petaDanaTerkumpul[b.id] ?? 0;
    final progresA = a.targetRupiah > 0 ? (danaA * 100) ~/ a.targetRupiah : 0;
    final progresB = b.targetRupiah > 0 ? (danaB * 100) ~/ b.targetRupiah : 0;
    return progresB.compareTo(progresA);
  });

  return tujuanKandidat.first;
}

/// Validasi formulir pencatatan utang baru/ubah.
HasilValidasiUtang validasiUtang({
  required String nama,
  required int sisaAwalRupiah,
  int? cicilanBulananRupiah,
  int? bungaBasisPoinPerTahun,
}) {
  if (nama.trim().isEmpty) {
    return const HasilValidasiUtang(
      sukses: false,
      pesanGalat: 'Nama utang belum diisi.',
    );
  }

  if (sisaAwalRupiah <= 0) {
    return const HasilValidasiUtang(
      sukses: false,
      pesanGalat: 'Sisa utang harus lebih besar dari Rp 0.',
    );
  }

  if (cicilanBulananRupiah != null && cicilanBulananRupiah < 0) {
    return const HasilValidasiUtang(
      sukses: false,
      pesanGalat: 'Cicilan bulanan tidak boleh bernilai negatif.',
    );
  }

  if (bungaBasisPoinPerTahun != null && bungaBasisPoinPerTahun < 0) {
    return const HasilValidasiUtang(
      sukses: false,
      pesanGalat: 'Bunga per tahun tidak boleh negatif.',
    );
  }

  return const HasilValidasiUtang(sukses: true);
}

/// Validasi pembayaran utang:
/// - Jumlah pembayaran harus > 0.
/// - Pembayaran tidak boleh melebihi sisa utang saat ini.
HasilValidasiUtang validasiPembayaranUtang({
  required int jumlahRupiah,
  required int sisaUtangSaatIni,
}) {
  if (jumlahRupiah <= 0) {
    return const HasilValidasiUtang(
      sukses: false,
      pesanGalat: 'Jumlah pembayaran harus lebih besar dari Rp 0.',
    );
  }

  if (jumlahRupiah > sisaUtangSaatIni) {
    return HasilValidasiUtang(
      sukses: false,
      pesanGalat:
          'Jumlah pembayaran melebihi sisa utang saat ini (${formatRupiah(sisaUtangSaatIni)}). '
          'Bila ada penambahan bunga atau denda, sesuaikan sisa utang terlebih dahulu.',
    );
  }

  return const HasilValidasiUtang(sukses: true);
}

/// Mengonversi teks input persentase bunga (misal "12.5" atau "12,5" atau "10")
/// menjadi integer basis poin murni tanpa menggunakan tipe double (100 bp = 1%).
int konversiTeksKeBasisPoin(String teks) {
  final bersih = teks.trim().replaceAll('%', '').replaceAll(',', '.');
  if (bersih.isEmpty) return 0;

  final bagian = bersih.split('.');
  final bulat = int.tryParse(bagian[0]) ?? 0;
  if (bagian.length == 1) {
    return bulat * 100;
  }

  var desimalStr = bagian[1];
  if (desimalStr.length == 1) {
    desimalStr = '${desimalStr}0';
  } else if (desimalStr.length > 2) {
    desimalStr = desimalStr.substring(0, 2);
  }

  final desimal = int.tryParse(desimalStr) ?? 0;
  return (bulat * 100) + desimal;
}

/// Memformat integer basis poin menjadi representasi persentase string (misal 1250 -> "12.5%").
String formatBasisPoinKePersen(int basisPoin) {
  final bulat = basisPoin ~/ 100;
  final sisa = basisPoin % 100;
  if (sisa == 0) return '$bulat%';
  if (sisa % 10 == 0) return '$bulat.${sisa ~/ 10}%';
  return '$bulat.$sisa%';
}
