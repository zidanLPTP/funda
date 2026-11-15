import '../data/basis_data.dart';
import '../data/model/jenis_alokasi.dart';

/// Status evaluasi realisasi pengeluaran terhadap batas anggaran bulanan.
enum StatusAnggaran {
  /// Pengeluaran masih di bawah 80% dari batas anggaran.
  aman('aman', 'Aman'),

  /// Pengeluaran sudah mencapai 80% hingga 100% dari batas anggaran.
  mendekati('mendekati', 'Mendekati Batas'),

  /// Pengeluaran telah melampaui 100% dari batas anggaran.
  melewati('melewati', 'Melewati Anggaran');

  const StatusAnggaran(this.kode, this.label);
  final String kode;
  final String label;
}

/// Hasil evaluasi realisasi satu pos anggaran.
class RealisasiAnggaran {
  const RealisasiAnggaran({
    required this.batasRupiah,
    required this.terpakaiRupiah,
    required this.sisaRupiah,
    required this.persenTerpakai,
    required this.status,
  });

  final int batasRupiah;
  final int terpakaiRupiah;
  final int sisaRupiah;
  final int persenTerpakai;
  final StatusAnggaran status;
}

/// Item anggaran untuk keperluan agregasi dan ringkasan.
class ItemRealisasiAnggaran {
  const ItemRealisasiAnggaran({
    this.anggaranId = '',
    required this.kategoriId,
    required this.namaKategori,
    required this.sifatKategori,
    this.ikonKategori = 'pieChart',
    required this.batasRupiah,
    required this.terpakaiRupiah,
  });

  final String anggaranId;
  final String kategoriId;
  final String namaKategori;
  final String sifatKategori;
  final String ikonKategori;
  final int batasRupiah;
  final int terpakaiRupiah;

  String get kategoriNama => namaKategori;
  String get kategoriIkon => ikonKategori;

  RealisasiAnggaran get realisasi => hitungRealisasiAnggaran(
    batasRupiah: batasRupiah,
    terpakaiRupiah: terpakaiRupiah,
  );

  int get persentase => realisasi.persenTerpakai;
  int get sisaRupiah => realisasi.sisaRupiah;
  StatusAnggaran get status => realisasi.status;
}

/// Ringkasan total anggaran beserta pengelompokan sifat kategori.
class RingkasanAnggaran {
  const RingkasanAnggaran({
    required this.totalBatasRupiah,
    required this.totalTerpakaiRupiah,
    required this.totalSisaRupiah,
    required this.perSifat,
  });

  final int totalBatasRupiah;
  final int totalTerpakaiRupiah;
  final int totalSisaRupiah;
  final Map<String, RingkasanSubSifat> perSifat;

  int get persentaseTerpakai => totalBatasRupiah <= 0
      ? 0
      : (totalTerpakaiRupiah * 100) ~/ totalBatasRupiah;

  int get totalKebutuhanBatasRupiah =>
      perSifat['kebutuhan']?.totalBatasRupiah ?? 0;
  int get totalKebutuhanTerpakaiRupiah =>
      perSifat['kebutuhan']?.totalTerpakaiRupiah ?? 0;

  int get totalKeinginanBatasRupiah =>
      perSifat['keinginan']?.totalBatasRupiah ?? 0;
  int get totalKeinginanTerpakaiRupiah =>
      perSifat['keinginan']?.totalTerpakaiRupiah ?? 0;

  int get totalTabunganBatasRupiah =>
      perSifat['tabungan']?.totalBatasRupiah ?? 0;
  int get totalTabunganTerpakaiRupiah =>
      perSifat['tabungan']?.totalTerpakaiRupiah ?? 0;

  int get totalUtangBatasRupiah => perSifat['utang']?.totalBatasRupiah ?? 0;
  int get totalUtangTerpakaiRupiah =>
      perSifat['utang']?.totalTerpakaiRupiah ?? 0;
}

/// Subtotal anggaran untuk kelompok sifat tertentu (kebutuhan, keinginan, dll).
class RingkasanSubSifat {
  const RingkasanSubSifat({
    required this.totalBatasRupiah,
    required this.totalTerpakaiRupiah,
  });

  final int totalBatasRupiah;
  final int totalTerpakaiRupiah;

  int get totalSisaRupiah => totalBatasRupiah - totalTerpakaiRupiah;
}

/// Rentang waktu awal dan akhir bulan dalam zona waktu lokal.
class RentangBulan {
  const RentangBulan({required this.mulai, required this.selesai});

  final DateTime mulai;
  final DateTime selesai;
}

/// Menghitung saldo kantong dari riwayat alokasi kantong (isi - ambil).
/// Saldo kantong tidak boleh negatif.
int hitungSaldoKantong(List<EntitasAlokasiKantong> alokasi) {
  var saldo = 0;
  for (final item in alokasi) {
    if (item.jenis == JenisAlokasi.isi.kode) {
      saldo += item.jumlahRupiah;
    } else if (item.jenis == JenisAlokasi.ambil.kode) {
      saldo -= item.jumlahRupiah;
    }
  }
  return saldo;
}

/// Memvalidasi tindakan pengambilan saldo kantong.
/// Melemparkan ArgumentError jika jumlah ambil melebihi saldo kantong.
void validasiAmbilKantong({
  required int saldoKantong,
  required int jumlahAmbil,
}) {
  if (jumlahAmbil <= 0) {
    throw ArgumentError('Jumlah pengambilan harus lebih besar dari nol.');
  }
  if (jumlahAmbil > saldoKantong) {
    throw ArgumentError('Saldo kantong tidak mencukupi untuk pengambilan ini.');
  }
}

/// Menghitung saldo bebas sebuah dompet.
/// Saldo bebas = Saldo dompet - total saldo seluruh kantong yang ada di dompet tersebut.
/// Saldo bebas diperbolehkan bernilai negatif.
int hitungSaldoBebasDompet({
  required int saldoDompetRupiah,
  required List<int> daftarSaldoKantongRupiah,
}) {
  final totalKantong = daftarSaldoKantongRupiah.fold<int>(
    0,
    (sebelum, sekarang) => sebelum + sekarang,
  );
  return saldoDompetRupiah - totalKantong;
}

/// Menghitung total dana terkumpul dari seluruh kantong yang tertaut pada suatu tujuan.
int hitungDanaTujuan(List<int> daftarSaldoKantongTertautRupiah) {
  return daftarSaldoKantongTertautRupiah.fold<int>(
    0,
    (sebelum, sekarang) => sebelum + sekarang,
  );
}

/// Menghitung persentase progres tujuan secara bilangan bulat (aritmetika integer murni tanpa double).
/// Dana diperbolehkan melebihi target (> 100%).
int hitungProgresTujuan({required int danaRupiah, required int targetRupiah}) {
  if (targetRupiah <= 0) return 0;
  return (danaRupiah * 100) ~/ targetRupiah;
}

/// Menghitung estimasi setoran bulanan yang dibutuhkan untuk mencapai target tujuan.
/// Menggunakan pembulatan ke atas berbasis aritmetika integer murni.
/// Mengembalikan null jika tujuan tidak memiliki tenggat waktu.
int? hitungSetoranBulananDibutuhkan({
  required int targetRupiah,
  required int danaTerkumpulRupiah,
  required DateTime? tenggat,
  required DateTime waktuSekarang,
}) {
  if (tenggat == null) return null;

  final sisa = targetRupiah - danaTerkumpulRupiah;
  if (sisa <= 0) return 0;

  // Hitung selisih bulan antara waktu sekarang dengan tenggat
  final selisihTahun = tenggat.year - waktuSekarang.year;
  final selisihBulan =
      (selisihTahun * 12) + (tenggat.month - waktuSekarang.month);

  // Jika tenggat jatuh pada bulan yang sama atau sudah lewat, seluruh sisa harus dicapai bulan ini
  final bulanTersisa = selisihBulan <= 0 ? 1 : selisihBulan;

  // Pembulatan ke atas integer: (a + b - 1) ~/ b
  return (sisa + bulanTersisa - 1) ~/ bulanTersisa;
}

/// Menghitung realisasi anggaran bulanan per kategori.
RealisasiAnggaran hitungRealisasiAnggaran({
  required int batasRupiah,
  required int terpakaiRupiah,
}) {
  final sisaRupiah = batasRupiah - terpakaiRupiah;
  final persenTerpakai = batasRupiah <= 0
      ? 0
      : (terpakaiRupiah * 100) ~/ batasRupiah;

  final StatusAnggaran status;
  if (persenTerpakai < 80) {
    status = StatusAnggaran.aman;
  } else if (persenTerpakai <= 100) {
    status = StatusAnggaran.mendekati;
  } else {
    status = StatusAnggaran.melewati;
  }

  return RealisasiAnggaran(
    batasRupiah: batasRupiah,
    terpakaiRupiah: terpakaiRupiah,
    sisaRupiah: sisaRupiah,
    persenTerpakai: persenTerpakai,
    status: status,
  );
}

/// Menghitung akumulasi ringkasan anggaran untuk satu periode bulan.
RingkasanAnggaran hitungRingkasanAnggaran(
  List<ItemRealisasiAnggaran> daftarItem,
) {
  var totalBatas = 0;
  var totalTerpakai = 0;
  final perSifatMap = <String, ({int batas, int terpakai})>{};

  for (final item in daftarItem) {
    totalBatas += item.batasRupiah;
    totalTerpakai += item.terpakaiRupiah;

    final saatIni = perSifatMap[item.sifatKategori] ?? (batas: 0, terpakai: 0);
    perSifatMap[item.sifatKategori] = (
      batas: saatIni.batas + item.batasRupiah,
      terpakai: saatIni.terpakai + item.terpakaiRupiah,
    );
  }

  final hasilPerSifat = perSifatMap.map(
    (kunci, nilai) => MapEntry(
      kunci,
      RingkasanSubSifat(
        totalBatasRupiah: nilai.batas,
        totalTerpakaiRupiah: nilai.terpakai,
      ),
    ),
  );

  return RingkasanAnggaran(
    totalBatasRupiah: totalBatas,
    totalTerpakaiRupiah: totalTerpakai,
    totalSisaRupiah: totalBatas - totalTerpakai,
    perSifat: hasilPerSifat,
  );
}

/// Mengambil rentang awal dan akhir bulan anggaran menurut kalender zona waktu lokal perangkat.
/// Dibungkus dalam satu fungsi terpusat agar mudah disesuaikan bila kelak mendukung siklus gajian.
RentangBulan ambilRentangBulanAnggaran({
  required int tahun,
  required int bulan,
}) {
  final awal = DateTime(tahun, bulan, 1, 0, 0, 0, 0);
  // Hari ke-0 pada bulan berikutnya = hari terakhir bulan ini
  final akhir = DateTime(tahun, bulan + 1, 0, 23, 59, 59, 999);
  return RentangBulan(mulai: awal, selesai: akhir);
}
