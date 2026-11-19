import '../util/format_rupiah.dart';

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
