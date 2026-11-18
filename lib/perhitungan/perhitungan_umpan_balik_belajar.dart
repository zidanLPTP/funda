import '../util/format_rupiah.dart';

/// Memformat nominal Rupiah tanpa spasi antara "Rp" dan angka sesuai konvensi teks materi edukasi.
String formatRupiahRapat(int nominal) {
  return formatRupiah(nominal).replaceAll('Rp ', 'Rp');
}

/// Porsi kebutuhan pada pola 50/30/20.
/// aturan praktis populer, TODO-VERIFIKASI
const int persentaseKebutuhanAturanPraktis = 50;

/// Porsi keinginan pada pola 50/30/20.
/// aturan praktis populer, TODO-VERIFIKASI
const int persentaseKeinginanAturanPraktis = 30;

/// Porsi tabungan dan utang pada pola 50/30/20.
/// aturan praktis populer, TODO-VERIFIKASI
const int persentaseTabunganUtangAturanPraktis = 20;

/// Menghasilkan teks umpan balik untuk misi pencatatan pengeluaran terbaru.
///
/// Teks: "Kamu sudah mencatat {n} pengeluaran. Yang terbaru: {kategori}, {jumlah}. Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi."
String formatCatatanPengeluaranTerbaru({
  required int jumlahTotal,
  required String kategori,
  required int nominal,
}) {
  final formatNominal = formatRupiahRapat(nominal);
  return 'Kamu sudah mencatat $jumlahTotal pengeluaran. '
      'Yang terbaru: $kategori, $formatNominal. '
      'Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi.';
}

/// Menghasilkan teks umpan balik perbandingan pola anggaran buatan pengguna vs pola 50/30/20.
///
/// Teks terdiri dari 3 kalimat dan 1 kalimat penutup:
/// 1. "Pemasukanmu bulan ini: Rp X."
/// 2. "Anggaran buatanmu: kebutuhan Rp A, keinginan Rp B, tabungan dan utang Rp C." (+ ", belum dilabeli Rp D" jika D > 0)
/// 3. "Sebagai perbandingan, pola populer 50/30/20 dari pemasukan yang sama: kebutuhan Rp K, keinginan Rp L, tabungan dan utang Rp M."
/// 4. "Keduanya titik awal. Sesuaikan dengan kondisimu."
String formatPerbandinganPolaAnggaran({
  required int pemasukan,
  required int kebutuhan,
  required int keinginan,
  required int tabunganDanUtang,
  int belumDilabeli = 0,
}) {
  if (pemasukan <= 0) {
    return 'Catat pemasukan bulan ini dulu agar perbandingan bisa dihitung.';
  }

  final k = pemasukan * persentaseKebutuhanAturanPraktis ~/ 100;
  final l = pemasukan * persentaseKeinginanAturanPraktis ~/ 100;
  final m = pemasukan - k - l;

  final kStr = formatRupiahRapat(k);
  final lStr = formatRupiahRapat(l);
  final mStr = formatRupiahRapat(m);

  final aStr = formatRupiahRapat(kebutuhan);
  final bStr = formatRupiahRapat(keinginan);
  final cStr = formatRupiahRapat(tabunganDanUtang);
  final dStr = belumDilabeli > 0 ? ', belum dilabeli ${formatRupiahRapat(belumDilabeli)}' : '';

  return 'Pemasukanmu bulan ini: ${formatRupiahRapat(pemasukan)}. '
      'Anggaran buatanmu: kebutuhan $aStr, keinginan $bStr, tabungan dan utang $cStr$dStr. '
      'Sebagai perbandingan, pola populer 50/30/20 dari pemasukan yang sama: kebutuhan $kStr, keinginan $lStr, tabungan dan utang $mStr. '
      'Keduanya titik awal. Sesuaikan dengan kondisimu.';
}

/// Item evaluasi anggaran per pos untuk penghitungan realisasi murni.
class PosAnggaranEvaluasi {
  final String nama;
  final int batas;
  final int terpakai;

  const PosAnggaranEvaluasi({
    required this.nama,
    required this.batas,
    required this.terpakai,
  });

  int get sisa => batas - terpakai;
  int get lebih => terpakai - batas;
}

/// Menghasilkan teks umpan balik realisasi anggaran bulan ini berdasarkan data pos anggaran.
///
/// Status pos:
/// - aman: rasio pemakaian < 80% (< 0.8)
/// - mendekati: rasio pemakaian 80% sampai 100% (0.8 s.d 1.0)
/// - melewati: rasio pemakaian > 100% (> 1.0)
String formatRealisasiAnggaranBulanIni(List<PosAnggaranEvaluasi> daftarPos) {
  if (daftarPos.isEmpty) {
    return 'Belum ada anggaran bulan ini.';
  }

  var aman = 0;
  var mendekati = 0;
  var melewati = 0;

  PosAnggaranEvaluasi? posSisaTerbanyak;
  PosAnggaranEvaluasi? posMelewatiTerjauh;

  for (final pos in daftarPos) {
    if (pos.batas <= 0) {
      if (pos.terpakai > 0) {
        melewati++;
      } else {
        aman++;
      }
      continue;
    }

    // Hindari pembagian pecahan double: terpakai * 100 vs batas * 80
    final terpakaiPersen = (pos.terpakai * 100);
    if (terpakaiPersen < pos.batas * 80) {
      aman++;
    } else if (terpakaiPersen <= pos.batas * 100) {
      mendekati++;
    } else {
      melewati++;
    }

    if (pos.sisa > 0) {
      if (posSisaTerbanyak == null || pos.sisa > posSisaTerbanyak.sisa) {
        posSisaTerbanyak = pos;
      }
    }

    if (pos.lebih > 0) {
      if (posMelewatiTerjauh == null || pos.lebih > posMelewatiTerjauh.lebih) {
        posMelewatiTerjauh = pos;
      }
    }
  }

  final sb = StringBuffer();
  sb.write('Dari ${daftarPos.length} pos anggaran: $aman masih aman, $mendekati mendekati batas, $melewati melewati batas.');

  if (posSisaTerbanyak != null) {
    sb.write(' Pos dengan sisa terbanyak: ${posSisaTerbanyak.nama} (sisa ${formatRupiahRapat(posSisaTerbanyak.sisa)}).');
  }

  if (melewati > 0 && posMelewatiTerjauh != null) {
    sb.write(' Pos yang melewati batas paling jauh: ${posMelewatiTerjauh.nama} (lebih ${formatRupiahRapat(posMelewatiTerjauh.lebih)}).');
  }

  sb.write(' Ini bahan belajar, bukan penilaian.');
  return sb.toString();
}
