import '../util/format_rupiah.dart';
import 'perhitungan_utang_dashboard.dart';

/// Memformat nominal Rupiah tanpa spasi antara "Rp" dan angka sesuai konvensi teks materi edukasi.
///
/// Untuk nominal negatif, menggunakan tanda minus standar U+2212 ("−") sebelum "Rp" tanpa spasi,
/// misalnya `formatRupiahRapat(-900000)` -> `"−Rp900.000"`.
String formatRupiahRapat(int nominal) {
  if (nominal < 0) {
    final formatPositif = formatRupiah(nominal.abs()).replaceAll('Rp ', 'Rp');
    return '−$formatPositif';
  }
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

/// Tambahan nominal simulasi kenaikan setoran per bulan (Rp50.000).
const int tambahanSimulasiRupiah = 50000;

/// Batas bawah kelipatan dana darurat terhadap pengeluaran wajib bulanan (3 bulan).
/// aturan praktis, TODO-VERIFIKASI
const int bulanDanaDaruratMin = 3;

/// Batas atas kelipatan dana darurat terhadap pengeluaran wajib bulanan (6 bulan).
/// aturan praktis, TODO-VERIFIKASI
const int bulanDanaDaruratMax = 6;

/// Memformat angka x = (dana * 10 ~/ W) menjadi teks desimal dengan koma Indonesia,
/// misalnya 15 -> "1,5", 30 -> "3", 0 -> "0".
String formatBulanDesimal(int x) {
  if (x <= 0) return '0';
  final bulat = x ~/ 10;
  final desimal = x % 10;
  if (desimal == 0) return '$bulat';
  return '$bulat,$desimal';
}

/// Menghitung estimasi bulan yang dibutuhkan untuk mencapai sisa target dengan pembulatan ke atas.
/// - sisa <= 0 -> mengembalikan 0 (target sudah tercapai).
/// - setoran <= 0 -> mengembalikan null (tidak ada kemajuan yang dapat dihitung).
/// - pembulatan ke atas (integer ceiling division): (sisa + setoran - 1) ~/ setoran.
int? hitungEstimasiBulan(int sisa, int setoran) {
  if (sisa <= 0) return 0;
  if (setoran <= 0) return null;
  return (sisa + setoran - 1) ~/ setoran;
}

/// Entitas simpel untuk representasi alokasi pada fungsi murni perhitungan setoran tabungan.
class EntitasAlokasiSimpel {
  final String jenis; // 'isi' | 'ambil'
  final int jumlahRupiah;
  final DateTime waktu;

  const EntitasAlokasiSimpel({
    required this.jenis,
    required this.jumlahRupiah,
    required this.waktu,
  });
}

/// Menghitung rata-rata setoran bulanan ke tujuan tabungan.
/// - Jendela = bulan berjalan dan 2 bulan kalender sebelumnya (3 bulan kalender).
/// - bulanAktif = jumlah bulan kalender dari bulan alokasi pertama dalam jendela sampai bulan berjalan (1 sampai 3).
/// - setoran = (total isi - total ambil pada tujuan tabungan dalam jendela) ~/ bulanAktif.
/// - Jika tidak ada alokasi dalam jendela atau hasil <= 0, mengembalikan 0.
int hitungRataRataSetoranTabungan({
  required List<EntitasAlokasiSimpel> daftarAlokasi,
  required DateTime waktuSekarang,
}) {
  final sekarangLokal = waktuSekarang.toLocal();
  final tahunSekarang = sekarangLokal.year;
  final bulanSekarang = sekarangLokal.month;

  // Bangun 3 bulan jendela (M, M-1, M-2)
  // Jarak: 0 untuk bulan berjalan (M), 1 untuk M-1, 2 untuk M-2
  final petaJarakBulan = <String, int>{};
  var kursorTahun = tahunSekarang;
  var kursorBulan = bulanSekarang;
  for (var jarak = 0; jarak < 3; jarak++) {
    final kunci = '$kursorTahun-${kursorBulan.toString().padLeft(2, '0')}';
    petaJarakBulan[kunci] = jarak;
    kursorBulan--;
    if (kursorBulan == 0) {
      kursorBulan = 12;
      kursorTahun--;
    }
  }

  var totalIsi = 0;
  var totalAmbil = 0;
  int? jarakTertua; // jarak bulan paling lampau yang memiliki data alokasi (0..2)

  for (final a in daftarAlokasi) {
    final lokal = a.waktu.toLocal();
    final kunci = '${lokal.year}-${lokal.month.toString().padLeft(2, '0')}';
    final jarak = petaJarakBulan[kunci];
    if (jarak != null) {
      if (a.jenis == 'isi') {
        totalIsi += a.jumlahRupiah;
      } else if (a.jenis == 'ambil') {
        totalAmbil += a.jumlahRupiah;
      }
      if (jarakTertua == null || jarak > jarakTertua) {
        jarakTertua = jarak;
      }
    }
  }

  if (jarakTertua == null) return 0;

  final bulanAktif = jarakTertua + 1;
  final net = totalIsi - totalAmbil;
  if (net <= 0) return 0;
  return net ~/ bulanAktif;
}

/// Item pengeluaran wajib untuk penghitungan kebutuhan dan utang bulanan.
class ItemPengeluaranWajib {
  final int jumlahRupiah;
  final String sifat; // 'kebutuhan' | 'utang'
  final DateTime waktu;

  const ItemPengeluaranWajib({
    required this.jumlahRupiah,
    required this.sifat,
    required this.waktu,
  });
}

/// Dasar perhitungan pengeluaran wajib bulanan.
enum DasarPengeluaranWajib {
  tigaBulanTerakhir,
  bulanBerjalan,
  belumAda,
}

/// Hasil perhitungan pengeluaran wajib bulanan.
class HasilPengeluaranWajib {
  final int total;
  final int bagianKebutuhan;
  final int bagianUtang;
  final int jumlahBulan;
  final DasarPengeluaranWajib dasar;

  const HasilPengeluaranWajib({
    required this.total,
    required this.bagianKebutuhan,
    required this.bagianUtang,
    required this.jumlahBulan,
    required this.dasar,
  });
}

/// Menghitung pengeluaran wajib bulanan rata-rata (generalisasi dari hitungPemasukanBulananRataRata).
/// Pengeluaran wajib = kebutuhan + utang.
/// - 3 bulan kalender selesai terakhir yang punya data:
///   total rata-rata = totalSemua ~/ n; bagianKebutuhan = totalKebutuhan ~/ n; bagianUtang = total - bagianKebutuhan.
/// - Bila 3 bulan selesai terakhir kosong: memakai bulan berjalan (jika ada data).
/// - Bila tidak ada sama sekali: mengembalikan status belumAda.
HasilPengeluaranWajib hitungPengeluaranWajibBulanan({
  required List<ItemPengeluaranWajib> daftarPengeluaran,
  required DateTime waktuSekarang,
}) {
  final sekarangLokal = waktuSekarang.toLocal();

  // 1. Tentukan 3 bulan kalender terakhir yang sudah selesai (M-1, M-2, M-3)
  final tigaBulanSelesai = <String>[];
  var kursorTahun = sekarangLokal.year;
  var kursorBulan = sekarangLokal.month;

  for (var i = 0; i < 3; i++) {
    kursorBulan--;
    if (kursorBulan == 0) {
      kursorBulan = 12;
      kursorTahun--;
    }
    tigaBulanSelesai.add('$kursorTahun-${kursorBulan.toString().padLeft(2, '0')}');
  }

  final kunciBulanBerjalan =
      '${sekarangLokal.year}-${sekarangLokal.month.toString().padLeft(2, '0')}';

  // 2. Akumulasi per bulan kalender
  final petaKebutuhanPerBulan = <String, int>{};
  final petaUtangPerBulan = <String, int>{};

  for (final item in daftarPengeluaran) {
    if (item.sifat != 'kebutuhan' && item.sifat != 'utang') continue;
    final waktuLokal = item.waktu.toLocal();
    final kunci = '${waktuLokal.year}-${waktuLokal.month.toString().padLeft(2, '0')}';
    if (item.sifat == 'kebutuhan') {
      petaKebutuhanPerBulan[kunci] = (petaKebutuhanPerBulan[kunci] ?? 0) + item.jumlahRupiah;
    } else if (item.sifat == 'utang') {
      petaUtangPerBulan[kunci] = (petaUtangPerBulan[kunci] ?? 0) + item.jumlahRupiah;
    }
  }

  // 3. Evaluasi 3 bulan selesai terakhir
  var totalKebutuhan3Bulan = 0;
  var totalUtang3Bulan = 0;
  var bulanAdaData = 0;

  for (final kunci in tigaBulanSelesai) {
    final keb = petaKebutuhanPerBulan[kunci] ?? 0;
    final utg = petaUtangPerBulan[kunci] ?? 0;
    if (keb > 0 || utg > 0) {
      bulanAdaData++;
      totalKebutuhan3Bulan += keb;
      totalUtang3Bulan += utg;
    }
  }

  if (bulanAdaData > 0) {
    final totalSemua = totalKebutuhan3Bulan + totalUtang3Bulan;
    final rataRataTotal = totalSemua ~/ bulanAdaData;
    final bagianKebutuhan = totalKebutuhan3Bulan ~/ bulanAdaData;
    final bagianUtang = rataRataTotal - bagianKebutuhan;
    return HasilPengeluaranWajib(
      total: rataRataTotal,
      bagianKebutuhan: bagianKebutuhan,
      bagianUtang: bagianUtang,
      jumlahBulan: bulanAdaData,
      dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
    );
  }

  // 4. Jika 3 bulan selesai kosong, cek bulan berjalan
  final kebBerjalan = petaKebutuhanPerBulan[kunciBulanBerjalan] ?? 0;
  final utgBerjalan = petaUtangPerBulan[kunciBulanBerjalan] ?? 0;
  if (kebBerjalan > 0 || utgBerjalan > 0) {
    final totalBerjalan = kebBerjalan + utgBerjalan;
    return HasilPengeluaranWajib(
      total: totalBerjalan,
      bagianKebutuhan: kebBerjalan,
      bagianUtang: utgBerjalan,
      jumlahBulan: 1,
      dasar: DasarPengeluaranWajib.bulanBerjalan,
    );
  }

  // 5. Belum ada data
  return const HasilPengeluaranWajib(
    total: 0,
    bagianKebutuhan: 0,
    bagianUtang: 0,
    jumlahBulan: 0,
    dasar: DasarPengeluaranWajib.belumAda,
  );
}

/// Data tujuan tabungan untuk evaluasi generator umpan balik.
class DataTujuanTabunganUmpanBalik {
  final String nama;
  final int danaTerkumpul;
  final int targetRupiah;
  final DateTime? tenggat;
  final DateTime dibuatPada;

  const DataTujuanTabunganUmpanBalik({
    required this.nama,
    required this.danaTerkumpul,
    required this.targetRupiah,
    this.tenggat,
    required this.dibuatPada,
  });
}

/// Memilih tujuan tabungan aktif dengan prioritas:
/// 1. Tenggat paling dekat (ascending).
/// 2. Bila tidak ada yang bertenggat, yang paling baru dibuat (dibuatPada descending).
DataTujuanTabunganUmpanBalik? pilihTujuanTabunganUmpanBalik(
  List<DataTujuanTabunganUmpanBalik> daftarTujuan,
) {
  if (daftarTujuan.isEmpty) return null;

  final denganTenggat = daftarTujuan.where((t) => t.tenggat != null).toList();
  if (denganTenggat.isNotEmpty) {
    denganTenggat.sort((a, b) => a.tenggat!.compareTo(b.tenggat!));
    return denganTenggat.first;
  }

  final salinan = List<DataTujuanTabunganUmpanBalik>.from(daftarTujuan);
  salinan.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));
  return salinan.first;
}

/// 1. Menghasilkan teks umpan balik ringkasan_tujuan_tabungan.
String formatRingkasanTujuanTabungan({
  required DataTujuanTabunganUmpanBalik? tujuan,
  required DateTime waktuSekarang,
}) {
  if (tujuan == null) {
    return 'Belum ada tujuan tabungan.';
  }

  final nama = tujuan.nama;
  final danaStr = formatRupiahRapat(tujuan.danaTerkumpul);
  final targetStr = formatRupiahRapat(tujuan.targetRupiah);
  final persen = tujuan.targetRupiah > 0
      ? (tujuan.danaTerkumpul * 100) ~/ tujuan.targetRupiah
      : 0;
  final sisa = tujuan.targetRupiah - tujuan.danaTerkumpul;

  final k1 = 'Tujuan tabunganmu: $nama.';
  final k2 = 'Dana terkumpul: $danaStr dari $targetStr ($persen persen).';

  if (sisa <= 0) {
    return '$k1 $k2 Targetmu sudah tercapai.';
  }

  if (tujuan.tenggat != null) {
    // Hitung bulan tersisa selaras dengan hitungSetoranBulananDibutuhkan
    final selisihTahun = tujuan.tenggat!.year - waktuSekarang.year;
    final selisihBulan =
        (selisihTahun * 12) + (tujuan.tenggat!.month - waktuSekarang.month);
    final bulanTersisa = selisihBulan <= 0 ? 1 : selisihBulan;
    final setoran = (sisa + bulanTersisa - 1) ~/ bulanTersisa;
    final setoranStr = formatRupiahRapat(setoran);
    return '$k1 $k2 Untuk sampai di target sebelum tenggat, kamu perlu menyisihkan sekitar $setoranStr per bulan.';
  } else {
    return '$k1 $k2 Belum ada tenggat. Menambahkan tenggat membantu menghitung berapa yang perlu disisihkan tiap bulan.';
  }
}

/// 2. Menghasilkan teks umpan balik estimasi_tabungan.
String formatEstimasiTabungan({
  required DataTujuanTabunganUmpanBalik? tujuan,
  required int setoranRataRata,
}) {
  if (tujuan == null) {
    return 'Belum ada tujuan tabungan.';
  }

  final sisa = tujuan.targetRupiah - tujuan.danaTerkumpul;
  if (sisa <= 0) {
    return 'Targetmu sudah tercapai.';
  }

  final sisaStr = formatRupiahRapat(sisa);
  final k1 = 'Sisa yang perlu dikumpulkan untuk ${tujuan.nama}: $sisaStr.';

  if (setoranRataRata <= 0) {
    return '$k1 Belum ada setoran yang tercatat, jadi waktu tercapainya belum bisa dihitung. Mulai dari nominal kecil yang masuk akal untukmu.';
  }

  final n = hitungEstimasiBulan(sisa, setoranRataRata)!;
  final setoran2 = setoranRataRata + tambahanSimulasiRupiah;
  final n2 = hitungEstimasiBulan(sisa, setoran2)!;
  final setoranStr = formatRupiahRapat(setoranRataRata);

  final k2 =
      'Dengan setoran sekitar $setoranStr per bulan seperti sekarang, targetmu tercapai sekitar $n bulan lagi.';
  String k3;
  if (n > n2) {
    final hemat = n - n2;
    k3 =
        'Kalau kamu menambah Rp50.000 per bulan, jadinya sekitar $n2 bulan lagi, $hemat bulan lebih cepat. Ini hitungan sederhana. Sesuaikan dengan kondisimu.';
  } else {
    k3 =
        'Kalau kamu menambah Rp50.000 per bulan, waktunya tetap sekitar $n2 bulan lagi. Ini hitungan sederhana. Sesuaikan dengan kondisimu.';
  }

  return '$k1 $k2 $k3';
}

/// 3. Menghasilkan teks umpan balik pengeluaran_wajib_bulanan.
String formatTeksPengeluaranWajibBulanan(HasilPengeluaranWajib hasil) {
  switch (hasil.dasar) {
    case DasarPengeluaranWajib.tigaBulanTerakhir:
      final totalStr = formatRupiahRapat(hasil.total);
      final kebStr = formatRupiahRapat(hasil.bagianKebutuhan);
      final rincianUtang = hasil.bagianUtang > 0
          ? ', cicilan dan utang ${formatRupiahRapat(hasil.bagianUtang)}'
          : '';
      return 'Pengeluaran wajibmu rata-rata $totalStr per bulan (dari ${hasil.jumlahBulan} bulan terakhir). Rinciannya: kebutuhan $kebStr$rincianUtang.';

    case DasarPengeluaranWajib.bulanBerjalan:
      final totalStr = formatRupiahRapat(hasil.total);
      final kebStr = formatRupiahRapat(hasil.bagianKebutuhan);
      final rincianUtang = hasil.bagianUtang > 0
          ? ', cicilan dan utang ${formatRupiahRapat(hasil.bagianUtang)}'
          : '';
      return 'Pengeluaran wajibmu bulan ini sejauh ini $totalStr (belum satu bulan penuh). Rinciannya: kebutuhan $kebStr$rincianUtang.';

    case DasarPengeluaranWajib.belumAda:
      return 'Belum ada pengeluaran kebutuhan yang bisa dihitung. Catat dulu beberapa pengeluaran kebutuhan.';
  }
}

/// 4. Menghasilkan teks umpan balik target_dana_darurat.
String formatTargetDanaDarurat({
  required HasilPengeluaranWajib pengeluaranWajib,
}) {
  final w = pengeluaranWajib.total;
  if (w <= 0 || pengeluaranWajib.dasar == DasarPengeluaranWajib.belumAda) {
    return 'Catat dulu pengeluaran kebutuhanmu agar target bisa dihitung.';
  }

  final minTarget = w * bulanDanaDaruratMin;
  final maxTarget = w * bulanDanaDaruratMax;
  final wStr = formatRupiahRapat(w);
  final minStr = formatRupiahRapat(minTarget);
  final maxStr = formatRupiahRapat(maxTarget);

  final teksDasar =
      'Dengan pengeluaran wajib sekitar $wStr per bulan, sebagai aturan praktis dana darurat berada di kisaran 3 sampai 6 kali itu: $minStr sampai $maxStr. Titik awal yang masuk akal: $minStr. Sesuaikan dengan kondisimu.';

  if (pengeluaranWajib.dasar == DasarPengeluaranWajib.bulanBerjalan) {
    return '$teksDasar Angka ini masih perkiraan awal karena datamu baru bulan ini.';
  }
  return teksDasar;
}

/// Data tujuan dana darurat untuk evaluasi umpan balik.
class DataTujuanDanaDaruratUmpanBalik {
  final int danaTerkumpul;
  final int targetRupiah;

  const DataTujuanDanaDaruratUmpanBalik({
    required this.danaTerkumpul,
    required this.targetRupiah,
  });
}

/// 5. Menghasilkan teks umpan balik progres_dana_darurat.
String formatProgresDanaDarurat({
  required DataTujuanDanaDaruratUmpanBalik? tujuan,
  required int? pengeluaranWajibPerBulan,
}) {
  if (tujuan == null) {
    return 'Belum ada tujuan dana darurat.';
  }

  final danaStr = formatRupiahRapat(tujuan.danaTerkumpul);
  final targetStr = formatRupiahRapat(tujuan.targetRupiah);
  final persen = tujuan.targetRupiah > 0
      ? (tujuan.danaTerkumpul * 100) ~/ tujuan.targetRupiah
      : 0;

  final sb = StringBuffer();
  sb.write('Dana daruratmu: $danaStr dari target $targetStr ($persen persen).');

  final w = pengeluaranWajibPerBulan;
  if (w != null && w > 0) {
    final x = (tujuan.danaTerkumpul * 10) ~/ w;
    final xStr = formatBulanDesimal(x);
    sb.write(' Itu setara sekitar $xStr bulan pengeluaran wajibmu.');
  }

  if (tujuan.danaTerkumpul >= tujuan.targetRupiah) {
    sb.write(' Targetmu sudah tercapai.');
  }

  return sb.toString();
}

/// Menghasilkan teks umpan balik untuk misi pencatatan pengeluaran terbaru.
///
/// Teks: "Kamu sudah mencatat {n} pengeluaran. Yang terbaru: {kategori}, {jumlah}. Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi."
String formatCatatanPengeluaranTerbaru({
  required int jumlahTotal,
  required String kategori,
  required int nominal,
}) {
  if (jumlahTotal <= 0) {
    return 'Belum ada pengeluaran yang dicatat. Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi.';
  }
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

/// Data item utang untuk evaluasi umpan balik edukatif Tahap 8B.
class ItemUtangUmpanBalik {
  final String nama;
  final int sisaRupiah;
  final int pokokAwalRupiah;
  final int cicilanBulananRupiah;
  final int? tenorBulan;
  final String jenisBunga; // 'tanpa_bunga', 'flat', 'efektif'
  final int bungaBasisPoinPerTahun;
  final String status; // 'aktif', 'lunas', 'diarsipkan'

  const ItemUtangUmpanBalik({
    required this.nama,
    required this.sisaRupiah,
    this.pokokAwalRupiah = 0,
    this.cicilanBulananRupiah = 0,
    this.tenorBulan,
    this.jenisBunga = 'tanpa_bunga',
    this.bungaBasisPoinPerTahun = 0,
    this.status = 'aktif',
  });
}

/// Memformat bunga tahunan dari basis poin menjadi string persentase integer murni tanpa desimal gantung.
///
/// Contoh:
/// - 1800 -> "18"
/// - 1850 -> "18,5"
/// - 1205 -> "12,05"
/// - 50 -> "0,5"
/// - 0 -> "0"
String formatBungaPersen(int bp) {
  final bulat = bp ~/ 100;
  final sisa = bp % 100;
  if (sisa == 0) return '$bulat';
  if (sisa % 10 == 0) {
    return '$bulat,${sisa ~/ 10}';
  }
  final sisaStr = sisa < 10 ? '0$sisa' : '$sisa';
  return '$bulat,$sisaStr';
}

/// Menghasilkan umpan balik untuk misi 4.1: ringkasan_utang
String formatRingkasanUtang({
  required List<ItemUtangUmpanBalik> daftarUtang,
  required HasilPemasukanRataRata? pemasukan,
  required bool tidakPunyaUtang,
}) {
  final utangAktif = daftarUtang.where((u) => u.status == 'aktif').toList();
  final n = utangAktif.length;

  if (n == 0) {
    if (tidakPunyaUtang) {
      return 'Kamu menyatakan tidak punya utang. Pelajaran ini tetap berguna untuk jaga-jaga. Kalau suatu saat berutang, catat di menu Utang.';
    }
    return 'Belum ada utang yang tercatat.';
  }

  var totalSisa = 0;
  var totalCicilan = 0;
  for (final u in utangAktif) {
    totalSisa += u.sisaRupiah;
    totalCicilan += u.cicilanBulananRupiah;
  }

  final sb = StringBuffer();
  sb.write('Kamu punya $n utang aktif dengan sisa total ${formatRupiahRapat(totalSisa)}. Cicilan per bulan: ${formatRupiahRapat(totalCicilan)}.');

  if (totalCicilan > 0) {
    if (pemasukan != null && pemasukan.dasar != DasarPemasukanRataRata.belumAda && pemasukan.nilaiRupiah > 0) {
      final persen = (totalCicilan * 100) ~/ pemasukan.nilaiRupiah;
      final teksDasar = pemasukan.dasar == DasarPemasukanRataRata.rataRata3Bulan
          ? 'rata-rata 3 bulan terakhir'
          : 'bulan ini';
      sb.write(' Itu sekitar $persen persen dari pemasukanmu ($teksDasar).');
    } else {
      sb.write(' Catat pemasukanmu supaya perbandingannya bisa dihitung.');
    }
  }

  sb.write(' Ini gambaran, bukan penilaian.');
  return sb.toString();
}

/// Menghasilkan umpan balik untuk misi 4.2: biaya_pinjaman_tercatat
String formatBiayaPinjamanTercatat({
  required List<ItemUtangUmpanBalik> daftarUtang,
  required bool tidakPunyaUtang,
}) {
  final utangAktif = daftarUtang.where((u) => u.status == 'aktif').toList();
  if (utangAktif.isEmpty) {
    if (tidakPunyaUtang) {
      return 'Kamu menyatakan tidak punya utang, jadi belum ada biaya pinjaman yang dihitung. Contoh di pelajaran ini bisa kamu pakai kalau nanti menerima tawaran pinjaman.';
    }
    return 'Belum ada utang yang tercatat.';
  }

  // Utang layak: pokok_awal > 0, tenor_bulan > 0, cicilan > 0
  final utangLayak = <({ItemUtangUmpanBalik utang, int total, int biaya})>[];
  for (final u in utangAktif) {
    if (u.pokokAwalRupiah > 0 && u.tenorBulan != null && u.tenorBulan! > 0 && u.cicilanBulananRupiah > 0) {
      final total = u.cicilanBulananRupiah * u.tenorBulan!;
      final selisih = total - u.pokokAwalRupiah;
      final biaya = selisih < 0 ? 0 : selisih;
      utangLayak.add((utang: u, total: total, biaya: biaya));
    }
  }

  if (utangLayak.isEmpty) {
    return 'Belum ada utang dengan pokok awal, tenor, dan cicilan yang lengkap. Lengkapi datanya di menu Utang agar biaya pinjaman bisa dihitung.';
  }

  // Urut biaya menurun lalu nama menaik
  utangLayak.sort((a, b) {
    final bandingBiaya = b.biaya.compareTo(a.biaya);
    if (bandingBiaya != 0) return bandingBiaya;
    return a.utang.nama.compareTo(b.utang.nama);
  });

  final sb = StringBuffer();
  final batas = utangLayak.length > 3 ? 3 : utangLayak.length;
  for (var i = 0; i < batas; i++) {
    final item = utangLayak[i];
    if (i > 0) sb.write(' ');
    sb.write('${item.utang.nama}: pokok ${formatRupiahRapat(item.utang.pokokAwalRupiah)}, cicilan ${formatRupiahRapat(item.utang.cicilanBulananRupiah)} x ${item.utang.tenorBulan} bulan = total ${formatRupiahRapat(item.total)}. Biaya pinjaman: ${formatRupiahRapat(item.biaya)}.');
  }

  if (utangLayak.length > 3) {
    final sisa = utangLayak.length - 3;
    sb.write(' Dan $sisa utang lain.');
  }

  sb.write(' Hitungan ini memakai cicilan x tenor yang kamu catat dan belum memasukkan denda.');
  return sb.toString();
}

/// Menghasilkan umpan balik untuk misi 4.3: rasio_cicilan_bulan_ini
String formatRasioCicilanBulanIni({
  required int totalCicilanBulanan,
  required HasilPemasukanRataRata? pemasukan,
}) {
  if (pemasukan == null || pemasukan.dasar == DasarPemasukanRataRata.belumAda || pemasukan.nilaiRupiah <= 0) {
    return 'Belum ada pemasukan yang tercatat, jadi rasio cicilan belum bisa dihitung. Catat pemasukanmu dulu.';
  }

  if (totalCicilanBulanan <= 0) {
    return 'Cicilan bulananmu belum tercatat (Rp0), jadi rasio cicilanmu 0 persen.';
  }

  final persen = (totalCicilanBulanan * 100) ~/ pemasukan.nilaiRupiah;
  final pemasukan2 = (pemasukan.nilaiRupiah * 75) ~/ 100;
  final persen2 = pemasukan2 <= 0 ? 0 : (totalCicilanBulanan * 100) ~/ pemasukan2;
  final teksDasar = pemasukan.dasar == DasarPemasukanRataRata.rataRata3Bulan
      ? 'rata-rata 3 bulan terakhir'
      : 'bulan ini';

  return 'Total cicilanmu ${formatRupiahRapat(totalCicilanBulanan)} per bulan, dibandingkan pemasukan ${formatRupiahRapat(pemasukan.nilaiRupiah)} per bulan ($teksDasar). Rasio cicilanmu $persen persen. Kalau pemasukanmu turun 25 persen, rasionya menjadi $persen2 persen. Ini angka untuk kamu pahami, bukan nilai.';
}

/// Menghasilkan umpan balik untuk misi 4.4: urutan_pelunasan
String formatUrutanPelunasan({
  required List<ItemUtangUmpanBalik> daftarUtang,
  required bool tidakPunyaUtang,
}) {
  final utangAktifBersisa = daftarUtang.where((u) => u.status == 'aktif' && u.sisaRupiah > 0).toList();

  if (utangAktifBersisa.isEmpty) {
    if (tidakPunyaUtang) {
      return 'Kamu menyatakan tidak punya utang, jadi belum ada yang perlu diurutkan. Pelajaran ini siap dipakai kalau nanti kamu berutang.';
    }
    return 'Belum ada utang aktif untuk diurutkan.';
  }

  if (utangAktifBersisa.length == 1) {
    final u = utangAktifBersisa.first;
    return 'Kamu hanya punya satu utang aktif: ${u.nama} (sisa ${formatRupiahRapat(u.sisaRupiah)}). Fokuskan uang ekstra ke utang ini.';
  }

  // Bola salju: sisa menaik lalu nama menaik
  final bolaSalju = List<ItemUtangUmpanBalik>.from(utangAktifBersisa);
  bolaSalju.sort((a, b) {
    final bandingSisa = a.sisaRupiah.compareTo(b.sisaRupiah);
    if (bandingSisa != 0) return bandingSisa;
    return a.nama.compareTo(b.nama);
  });
  final daftarBolaSalju = bolaSalju.map((u) => '${u.nama} (${formatRupiahRapat(u.sisaRupiah)})').join(', lalu ');

  // Longsor:
  // Kelompok 1: bungaBasisPoinPerTahun > 0 -> bp menurun, sisa menaik, nama menaik
  final kelompokBunga = utangAktifBersisa.where((u) => u.bungaBasisPoinPerTahun > 0).toList();
  kelompokBunga.sort((a, b) {
    final bandingBp = b.bungaBasisPoinPerTahun.compareTo(a.bungaBasisPoinPerTahun);
    if (bandingBp != 0) return bandingBp;
    final bandingSisa = a.sisaRupiah.compareTo(b.sisaRupiah);
    if (bandingSisa != 0) return bandingSisa;
    return a.nama.compareTo(b.nama);
  });

  // Kelompok 2: bungaBasisPoinPerTahun <= 0
  final kelompokTanpaBunga = utangAktifBersisa.where((u) => u.bungaBasisPoinPerTahun <= 0).toList();
  kelompokTanpaBunga.sort((a, b) {
    final bandingSisa = a.sisaRupiah.compareTo(b.sisaRupiah);
    if (bandingSisa != 0) return bandingSisa;
    return a.nama.compareTo(b.nama);
  });

  final daftarLongsorItem = <String>[];
  for (final u in kelompokBunga) {
    daftarLongsorItem.add('${u.nama} (${formatBungaPersen(u.bungaBasisPoinPerTahun)} persen per tahun)');
  }
  for (final u in kelompokTanpaBunga) {
    final label = u.jenisBunga == 'tanpa_bunga' ? 'tanpa bunga' : 'bunga belum dicatat';
    daftarLongsorItem.add('${u.nama} ($label)');
  }
  final daftarLongsor = daftarLongsorItem.join(', lalu ');

  return 'Urutan bola salju (sisa terkecil dulu): $daftarBolaSalju. '
      'Urutan longsor (bunga tertinggi dulu): $daftarLongsor. '
      'Urutan longsor memakai persen bunga yang kamu catat. Kalau jenis bunganya berbeda, anggap sebagai perkiraan. '
      'Pilih salah satu dan konsisten. Ini bahan belajar, bukan keharusan.';
}

/// Data item langganan/tagihan untuk evaluasi umpan balik edukatif Tahap 8D.
class ItemLanggananUmpanBalik {
  final String nama;
  final String jenis; // 'langganan' | 'tagihan'
  final String frekuensi; // 'mingguan' | 'bulanan' | 'tahunan'
  final int? jumlahPerkiraanRupiah;
  final bool aktif;
  final bool diarsipkan;

  const ItemLanggananUmpanBalik({
    required this.nama,
    this.jenis = 'langganan',
    this.frekuensi = 'bulanan',
    this.jumlahPerkiraanRupiah,
    this.aktif = true,
    this.diarsipkan = false,
  });
}

/// Menghasilkan umpan balik untuk misi 6.2: ringkasan_langganan_dan_keinginan
String formatRingkasanLanggananDanKeinginan({
  required List<ItemLanggananUmpanBalik> daftarTagihan,
  required int totalKeinginanBulanIniRupiah,
}) {
  final langgananAktif = daftarTagihan
      .where((t) => t.jenis == 'langganan' && t.aktif && !t.diarsipkan)
      .toList();

  final denganPerkiraan = langgananAktif
      .where((t) => t.jumlahPerkiraanRupiah != null && t.jumlahPerkiraanRupiah! > 0)
      .toList();
  final tanpaPerkiraan = langgananAktif
      .where((t) => t.jumlahPerkiraanRupiah == null || t.jumlahPerkiraanRupiah! <= 0)
      .toList();

  final n = denganPerkiraan.length;
  final m = tanpaPerkiraan.length;

  var totalPerkiraanBulanan = 0;
  for (final item in denganPerkiraan) {
    final nominal = item.jumlahPerkiraanRupiah!;
    switch (item.frekuensi) {
      case 'mingguan':
        totalPerkiraanBulanan += nominal * 4;
        break;
      case 'tahunan':
        totalPerkiraanBulanan += nominal ~/ 12;
        break;
      case 'bulanan':
      default:
        totalPerkiraanBulanan += nominal;
        break;
    }
  }

  final sbLangganan = StringBuffer();
  if (n > 0) {
    sbLangganan.write(
      'Kamu punya $n langganan aktif dengan perkiraan sekitar ${formatRupiahRapat(totalPerkiraanBulanan)} per bulan.',
    );
    if (m > 0) {
      sbLangganan.write(' ($m langganan belum ada perkiraan.)');
    }
  } else if (m > 0) {
    sbLangganan.write(
      'Kamu punya $m langganan aktif yang belum diisi perkiraan biayanya.',
    );
  } else {
    sbLangganan.write(
      'Belum ada langganan aktif yang tercatat di menu Tagihan.',
    );
  }

  final sbKeinginan = StringBuffer();
  if (totalKeinginanBulanIniRupiah > 0) {
    sbKeinginan.write(
      'Pengeluaran keinginanmu bulan ini tercatat ${formatRupiahRapat(totalKeinginanBulanIniRupiah)}.',
    );
  } else {
    sbKeinginan.write(
      'Belum ada pengeluaran keinginan yang tercatat bulan ini.',
    );
  }

  const penutup = 'Ini gambaran untuk kamu kenali, bukan penilaian.';

  return '${sbLangganan.toString()} ${sbKeinginan.toString()} $penutup';
}

/// Menghasilkan umpan balik untuk misi 10.3: ringkasan_proteksi_dasar
///
/// Masukan:
/// - [pengeluaranWajibBulananRupiah]: nominal pengeluaran wajib bulanan (<= 0 jika belum ada).
/// - [dasarPengeluaranWajib]: string dasar pengeluaran wajib ('rata-rata 3 bulan terakhir' atau 'bulan ini').
/// - [danaDaruratTerkumpul]: nominal Rupiah dari tujuan dana_darurat aktif/tercapai, 0 bila belum ada.
String formatRingkasanProteksiDasar({
  required int pengeluaranWajibBulananRupiah,
  String? dasarPengeluaranWajib,
  required int danaDaruratTerkumpul,
}) {
  if (pengeluaranWajibBulananRupiah <= 0) {
    return 'Belum ada catatan pengeluaran kebutuhan untuk melihat gambaran beban wajibmu. '
        'Catat dulu pengeluaran kebutuhanmu agar gambarannya lebih jelas. '
        'Ini gambaran umum, bukan rekomendasi produk.';
  }

  final wStr = formatRupiahRapat(pengeluaranWajibBulananRupiah);
  final dasarStr = dasarPengeluaranWajib ?? 'rata-rata 3 bulan terakhir';
  final danaStr = formatRupiahRapat(danaDaruratTerkumpul);

  return 'Pengeluaran wajibmu sekitar $wStr per bulan ($dasarStr). '
      'Dana darurat yang terkumpul saat ini: $danaStr. '
      'Biaya kesehatan mendadak atau risiko besar bisa jauh melampaui dana darurat, sehingga proteksi dasar membantu melindungi rencana keuanganmu. '
      'Ini gambaran umum, bukan rekomendasi produk.';
}

/// Menghasilkan umpan balik untuk misi 8.2: ringkasan_pemasukan_tambahan
///
/// Masukan:
/// - [petaPemasukanPerKategori]: `Map<String, int>` total pemasukan bulan berjalan per nama kategori (hanya yang > 0).
/// - [baruSatuSumber]: bool dari pernyataan 'baru_satu_sumber'.
String formatRingkasanPemasukanTambahan({
  required Map<String, int> petaPemasukanPerKategori,
  required bool baruSatuSumber,
}) {
  final entriPositif = petaPemasukanPerKategori.entries
      .where((e) => e.value > 0)
      .toList();

  if (entriPositif.isEmpty) {
    if (baruSatuSumber) {
      return 'Kamu menyatakan baru punya satu sumber penghasilan. '
          'Saat nanti ada pemasukan tambahan, catat dengan kategori terpisah agar alirannya mudah dipantau.';
    }
    return 'Belum ada pemasukan yang tercatat bulan ini. '
        'Catat pemasukanmu agar pembagian sumbernya terlihat.';
  }

  if (entriPositif.length == 1) {
    final e = entriPositif.first;
    final jumlahStr = formatRupiahRapat(e.value);
    return 'Bulan ini pemasukanmu berasal dari 1 sumber: ${e.key} ($jumlahStr). '
        'Mencatat per sumber memudahkanmu melihat perkembangan jika nanti ada penghasilan tambahan.';
  }

  // Urut nominal menurun (descending), lalu nama menaik (ascending)
  entriPositif.sort((a, b) {
    final bandingNominal = b.value.compareTo(a.value);
    if (bandingNominal != 0) return bandingNominal;
    return a.key.compareTo(b.key);
  });

  var total = 0;
  for (final e in entriPositif) {
    total += e.value;
  }
  final n = entriPositif.length;
  final totalStr = formatRupiahRapat(total);
  final e1 = entriPositif[0];
  final e2 = entriPositif[1];
  final nama1 = e1.key;
  final jumlah1 = formatRupiahRapat(e1.value);
  final nama2 = e2.key;
  final jumlah2 = formatRupiahRapat(e2.value);

  return 'Bulan ini pemasukanmu datang dari $n sumber dengan total $totalStr. '
      'Terbesar: $nama1 ($jumlah1), diikuti $nama2 ($jumlah2). '
      'Memisahkan catatan per sumber membantumu mengatur porsi untuk kebutuhan dan masa sepi.';
}

/// Menghasilkan umpan balik untuk misi 9.2: ringkasan_penghasilan_tahunan
///
/// Masukan:
/// - [totalPemasukanTahunIni]: seluruh transaksi masuk pada tahun kalender berjalan menurut zona waktu lokal.
/// - [jumlahBulanTercatat]: jumlah bulan kalender berbeda di tahun berjalan yang memiliki transaksi masuk.
String formatRingkasanPenghasilanTahunan({
  required int totalPemasukanTahunIni,
  required int jumlahBulanTercatat,
}) {
  if (totalPemasukanTahunIni <= 0 || jumlahBulanTercatat <= 0) {
    return 'Belum ada pemasukan yang tercatat di tahun ini. '
        'Catat pemasukanmu secara rutin agar rekap tahunanmu mudah dilihat saat waktunya lapor pajak.';
  }

  final rataRata = totalPemasukanTahunIni ~/ jumlahBulanTercatat;
  final totalStr = formatRupiahRapat(totalPemasukanTahunIni);
  final rataStr = formatRupiahRapat(rataRata);

  return 'Total pemasukanmu yang tercatat tahun ini: $totalStr (dari $jumlahBulanTercatat bulan yang tercatat). '
      'Rata-rata sekitar $rataStr per bulan. '
      'Catatan yang rapi memudahkanmu saat menyiapkan pelaporan pajak. '
      'Ini edukasi umum, bukan nasihat pajak.';
}

/// Data tujuan untuk evaluasi umpan balik ringkasan_tujuan_besar.
class DataTujuanBesarUmpanBalik {
  final String nama;
  final int targetRupiah;
  final int danaTerkumpulRupiah;
  final int? bulanTersisa;
  final String jenis;
  final DateTime dibuatPada;
  final DateTime? tenggat;

  const DataTujuanBesarUmpanBalik({
    required this.nama,
    required this.targetRupiah,
    required this.danaTerkumpulRupiah,
    this.bulanTersisa,
    required this.jenis,
    required this.dibuatPada,
    this.tenggat,
  });
}

/// Menghitung selisih bulan dari waktu sekarang menuju tenggat (minimal 1 bulan).
int hitungBulanTersisa(DateTime tenggat, DateTime waktuSekarang) {
  final selisih = (tenggat.year - waktuSekarang.year) * 12 +
      (tenggat.month - waktuSekarang.month);
  return selisih <= 0 ? 1 : selisih;
}

/// Memilih satu tujuan dari daftar tujuan non-dana-darurat untuk umpan balik misi 12.2.
///
/// Aturan pemilihan:
/// - Jika ada tujuan dengan jenis `tujuan_besar`:
///   - Utamakan yang memiliki tenggat (bulanTersisa != null && bulanTersisa > 0) dengan tenggat paling dekat (bulanTersisa terkecil).
///   - Jika tenggat sama/seri, pilih yang paling baru dibuat (dibuatPada terbaru).
///   - Jika tidak ada yang memiliki tenggat, pilih yang paling baru dibuat (dibuatPada terbaru).
/// - Jika tidak ada jenis `tujuan_besar`, pilih tujuan non-dana-darurat mana pun yang target nominalnya terbesar.
///   - Jika target nominal sama/seri, pilih yang paling baru dibuat.
DataTujuanBesarUmpanBalik? pilihTujuanBesarUmpanBalik(
  List<DataTujuanBesarUmpanBalik> daftar,
) {
  final valid = daftar.where((d) => d.jenis != 'dana_darurat').toList();
  if (valid.isEmpty) return null;

  final daftarTujuanBesar =
      valid.where((d) => d.jenis == 'tujuan_besar').toList();

  if (daftarTujuanBesar.isNotEmpty) {
    final bertenggat = daftarTujuanBesar
        .where((d) => d.bulanTersisa != null && d.bulanTersisa! > 0)
        .toList();
    if (bertenggat.isNotEmpty) {
      bertenggat.sort((a, b) {
        final bandingBulan = a.bulanTersisa!.compareTo(b.bulanTersisa!);
        if (bandingBulan != 0) return bandingBulan;
        return b.dibuatPada.compareTo(a.dibuatPada);
      });
      return bertenggat.first;
    }

    daftarTujuanBesar.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));
    return daftarTujuanBesar.first;
  }

  valid.sort((a, b) {
    final bandingTarget = b.targetRupiah.compareTo(a.targetRupiah);
    if (bandingTarget != 0) return bandingTarget;
    return b.dibuatPada.compareTo(a.dibuatPada);
  });
  return valid.first;
}

/// Menghasilkan umpan balik untuk misi 12.2: ringkasan_tujuan_besar
///
/// Aturan:
/// - Jika belum ada tujuan selain dana darurat:
///   "Belum ada tujuan aktif selain dana darurat. Buat satu tujuan di menu Tujuan agar proyeksinya bisa dihitung."
/// - Jika ada tujuan:
///   - Kalimat 1: "Tujuan besarmu: {nama} (target {target}, terkumpul {dana})."
///   - Kalimat 2:
///     - Jika target tercapai (dana >= target): "Targetmu sudah tercapai."
///     - Jika belum tercapai dan ada tenggat: "Sisa {sisa} dalam {N} bulan berarti kamu perlu menyisihkan sekitar {setoran} per bulan."
///       dengan setoran = (sisa + bulan - 1) ~/ bulan
///     - Jika belum tercapai dan tanpa tenggat: "Sisa {sisa}. Tambahkan tenggat agar setoran bulanannya bisa dihitung."
///   - Kalimat 3 (penutup tetap):
///     "Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus."
String formatRingkasanTujuanBesar({
  required DataTujuanBesarUmpanBalik? tujuan,
}) {
  if (tujuan == null) {
    return 'Belum ada tujuan aktif selain dana darurat. Buat satu tujuan di menu Tujuan agar proyeksinya bisa dihitung.';
  }

  final targetStr = formatRupiahRapat(tujuan.targetRupiah);
  final danaStr = formatRupiahRapat(tujuan.danaTerkumpulRupiah);
  final k1 = 'Tujuan besarmu: ${tujuan.nama} (target $targetStr, terkumpul $danaStr).';

  String k2;
  if (tujuan.danaTerkumpulRupiah >= tujuan.targetRupiah) {
    k2 = 'Targetmu sudah tercapai.';
  } else {
    final sisa = tujuan.targetRupiah - tujuan.danaTerkumpulRupiah;
    final sisaStr = formatRupiahRapat(sisa);
    final bulan = tujuan.bulanTersisa;
    if (bulan != null && bulan > 0) {
      final setoran = (sisa + bulan - 1) ~/ bulan;
      final setoranStr = formatRupiahRapat(setoran);
      k2 = 'Sisa $sisaStr dalam $bulan bulan berarti kamu perlu menyisihkan sekitar $setoranStr per bulan.';
    } else {
      k2 = 'Sisa $sisaStr. Tambahkan tenggat agar setoran bulanannya bisa dihitung.';
    }
  }

  const k3 = 'Fokus pada satu atau dua tujuan utama lebih mudah dijalankan daripada mengejar semuanya sekaligus.';

  return '$k1 $k2 $k3';
}

/// Konstanta patokan aturan praktis rasio cicilan maksimal.
/// TODO-VERIFIKASI: aturan praktis umum rasio cicilan 30%
const int batasAturanPraktisCicilanPersen = 30;

/// Menghasilkan teks umpan balik on-demand misi 14.3: uji_kemampuan_kpr.
///
/// Masukan:
/// - [pemasukanRataRata]: `HasilPemasukanRataRata?` dari kalkulasi pemasukan rata-rata.
/// - [totalCicilanAktifRupiah]: total cicilan bulanan yang sedang berjalan.
/// - [totalSaldoDompetAktifRupiah]: total saldo seluruh dompet aktif pengguna saat ini.
/// - [deskripsiDasarOverride]: opsi teks dasar pemasukan jika ingin ditentukan secara eksplisit.
String formatUjiKemampuanKpr({
  required HasilPemasukanRataRata? pemasukanRataRata,
  required int totalCicilanAktifRupiah,
  required int totalSaldoDompetAktifRupiah,
  String? deskripsiDasarOverride,
}) {
  if (pemasukanRataRata == null ||
      pemasukanRataRata.dasar == DasarPemasukanRataRata.belumAda ||
      pemasukanRataRata.nilaiRupiah <= 0) {
    return 'Belum ada catatan pemasukan untuk menguji ruang cicilanmu. '
        'Catat pemasukanmu secara rutin dulu agar gambarannya bisa dihitung. '
        'Ini simulasi edukatif, bukan persetujuan kredit.';
  }

  final pemasukan = pemasukanRataRata.nilaiRupiah;
  final dasarStr = deskripsiDasarOverride ??
      (pemasukanRataRata.dasar == DasarPemasukanRataRata.bulanBerjalan
          ? 'bulan ini'
          : 'rata-rata 3 bulan terakhir');

  final ruangCicilanMaksimal =
      (pemasukan * batasAturanPraktisCicilanPersen) ~/ 100;
  final sisaMentah = ruangCicilanMaksimal - totalCicilanAktifRupiah;
  final sisaRuangCicilan = sisaMentah < 0 ? 0 : sisaMentah;

  final pemasukanStr = formatRupiahRapat(pemasukan);
  final cicilanStr = formatRupiahRapat(totalCicilanAktifRupiah);
  final sisaRuangStr = formatRupiahRapat(sisaRuangCicilan);
  final saldoStr = formatRupiahRapat(totalSaldoDompetAktifRupiah);

  final sb = StringBuffer();
  sb.write(
    'Dengan pemasukan sekitar $pemasukanStr per bulan ($dasarStr) dan '
    'cicilan aktif saat ini $cicilanStr, estimasi sisa ruang cicilan '
    '(memakai patokan umum 30 persen) adalah sekitar $sisaRuangStr per bulan.',
  );

  if (sisaRuangCicilan == 0) {
    sb.write(
      ' Cicilan aktifmu saat ini sudah memenuhi atau melampaui patokan 30 persen, '
      'sehingga melunasi sebagian utang dulu biasanya jauh lebih tenang '
      'sebelum mengambil kredit besar.',
    );
  }

  sb.write(
    ' Total saldo dompet aktifmu saat ini tercatat $saldoStr '
    '(belum dikurangi dana darurat dan kebutuhan harian). '
    'Ini simulasi edukatif, bukan persetujuan kredit.',
  );

  return sb.toString();
}




