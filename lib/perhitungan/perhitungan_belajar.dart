import 'dart:math';

/// Ambang batas persentase kelulusan kuis akhir modul (70%).
/// Menggunakan aritmetika bilangan bulat murni (benar * 100 >= ambang * total).
const int ambangLulusKuis = 70;

/// Status proses belajar pelajaran maupun modul.
enum StatusBelajar {
  terkunci,
  terbuka,
  sedang,
  selesai,
}

/// Representasi data snapshot pengguna untuk evaluasi gerbang data sekali ambil via SQL.
class FotoDataPengguna {
  final int jumlahDompetAktif;
  final int jumlahPemasukan;
  final int jumlahPengeluaran;
  final int jumlahAnggaran;
  final int jumlahTujuanAktif;
  final int jumlahUtangAktif;
  final Map<String, String> kategoriKeluarTerpakai; // kategoriId -> sifat
  final int hariTransaksiBerbeda;
  final int bulanTransaksiBerbeda;
  final Map<String, String> pernyataan; // kunci -> nilai ('true')
  final Map<String, String> progresPelajaran; // pelajaranId -> 'sedang' | 'selesai'
  final Map<String, HasilKuisSnapshot> hasilKuisTerbaik; // modulId -> snapshot
  final bool profilTerisi;
  final bool tujuanDanaDaruratAktif;
  final int saldoTerkumpulDanaDarurat;
  final int sisaUtangAktif;
  final Map<String, int> komposisiSifatBulanIni;

  const FotoDataPengguna({
    required this.jumlahDompetAktif,
    required this.jumlahPemasukan,
    required this.jumlahPengeluaran,
    required this.jumlahAnggaran,
    required this.jumlahTujuanAktif,
    required this.jumlahUtangAktif,
    required this.kategoriKeluarTerpakai,
    required this.hariTransaksiBerbeda,
    required this.bulanTransaksiBerbeda,
    required this.pernyataan,
    required this.progresPelajaran,
    required this.hasilKuisTerbaik,
    this.profilTerisi = false,
    this.tujuanDanaDaruratAktif = false,
    this.saldoTerkumpulDanaDarurat = 0,
    this.sisaUtangAktif = 0,
    this.komposisiSifatBulanIni = const {},
  });

  factory FotoDataPengguna.kosong() {
    return const FotoDataPengguna(
      jumlahDompetAktif: 0,
      jumlahPemasukan: 0,
      jumlahPengeluaran: 0,
      jumlahAnggaran: 0,
      jumlahTujuanAktif: 0,
      jumlahUtangAktif: 0,
      kategoriKeluarTerpakai: {},
      hariTransaksiBerbeda: 0,
      bulanTransaksiBerbeda: 0,
      pernyataan: {},
      progresPelajaran: {},
      hasilKuisTerbaik: {},
      profilTerisi: false,
      tujuanDanaDaruratAktif: false,
      saldoTerkumpulDanaDarurat: 0,
      sisaUtangAktif: 0,
      komposisiSifatBulanIni: {},
    );
  }

  FotoDataPengguna copyWith({
    int? jumlahDompetAktif,
    int? jumlahPemasukan,
    int? jumlahPengeluaran,
    int? jumlahAnggaran,
    int? jumlahTujuanAktif,
    int? jumlahUtangAktif,
    Map<String, String>? kategoriKeluarTerpakai,
    int? hariTransaksiBerbeda,
    int? bulanTransaksiBerbeda,
    Map<String, String>? pernyataan,
    Map<String, String>? progresPelajaran,
    Map<String, HasilKuisSnapshot>? hasilKuisTerbaik,
    bool? profilTerisi,
    bool? tujuanDanaDaruratAktif,
    int? saldoTerkumpulDanaDarurat,
    int? sisaUtangAktif,
    Map<String, int>? komposisiSifatBulanIni,
  }) {
    return FotoDataPengguna(
      jumlahDompetAktif: jumlahDompetAktif ?? this.jumlahDompetAktif,
      jumlahPemasukan: jumlahPemasukan ?? this.jumlahPemasukan,
      jumlahPengeluaran: jumlahPengeluaran ?? this.jumlahPengeluaran,
      jumlahAnggaran: jumlahAnggaran ?? this.jumlahAnggaran,
      jumlahTujuanAktif: jumlahTujuanAktif ?? this.jumlahTujuanAktif,
      jumlahUtangAktif: jumlahUtangAktif ?? this.jumlahUtangAktif,
      kategoriKeluarTerpakai:
          kategoriKeluarTerpakai ?? this.kategoriKeluarTerpakai,
      hariTransaksiBerbeda: hariTransaksiBerbeda ?? this.hariTransaksiBerbeda,
      bulanTransaksiBerbeda:
          bulanTransaksiBerbeda ?? this.bulanTransaksiBerbeda,
      pernyataan: pernyataan ?? this.pernyataan,
      progresPelajaran: progresPelajaran ?? this.progresPelajaran,
      hasilKuisTerbaik: hasilKuisTerbaik ?? this.hasilKuisTerbaik,
      profilTerisi: profilTerisi ?? this.profilTerisi,
      tujuanDanaDaruratAktif:
          tujuanDanaDaruratAktif ?? this.tujuanDanaDaruratAktif,
      saldoTerkumpulDanaDarurat:
          saldoTerkumpulDanaDarurat ?? this.saldoTerkumpulDanaDarurat,
      sisaUtangAktif: sisaUtangAktif ?? this.sisaUtangAktif,
      komposisiSifatBulanIni:
          komposisiSifatBulanIni ?? this.komposisiSifatBulanIni,
    );
  }
}

/// Snapshot hasil kuis terbaik per modul.
class HasilKuisSnapshot {
  final int skorPersen;
  final bool lulus;

  const HasilKuisSnapshot({
    required this.skorPersen,
    required this.lulus,
  });
}

/// Spesifikasi syarat gerbang data.
class SyaratGerbangData {
  final String tipe; // ada_data | aturan_data | periode_data | pernyataan | kuis_lulus | modul_selesai
  final String? objek; // dompet | pemasukan | pengeluaran | transaksi | anggaran | tujuan | utang | kategori
  final String? aturan; // semua_kategori_berlabel
  final String? satuan; // hari_berbeda | bulan_berbeda
  final int min;
  final String? kunci; // untuk pernyataan
  final String? modulId; // untuk kuis_lulus / modul_selesai
  final String pesan;
  final String? atauPernyataan; // Kunci pernyataan yang menjadi opsi ATAU

  const SyaratGerbangData({
    required this.tipe,
    this.objek,
    this.aturan,
    this.satuan,
    this.min = 1,
    this.kunci,
    this.modulId,
    required this.pesan,
    this.atauPernyataan,
  });

  factory SyaratGerbangData.fromJson(Map<String, dynamic> json) {
    return SyaratGerbangData(
      tipe: json['tipe'] as String? ?? 'ada_data',
      objek: json['objek'] as String?,
      aturan: json['aturan'] as String?,
      satuan: json['satuan'] as String?,
      min: (json['min'] as num?)?.toInt() ?? 1,
      kunci: json['kunci'] as String?,
      modulId: json['modulId'] as String?,
      pesan: json['pesan'] as String? ?? '',
      atauPernyataan: json['atauPernyataan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tipe': tipe,
        if (objek != null) 'objek': objek,
        if (aturan != null) 'aturan': aturan,
        if (satuan != null) 'satuan': satuan,
        'min': min,
        if (kunci != null) 'kunci': kunci,
        if (modulId != null) 'modulId': modulId,
        'pesan': pesan,
        if (atauPernyataan != null) 'atauPernyataan': atauPernyataan,
      };
}

/// Hasil evaluasi satu syarat gerbang data.
class HasilEvaluasiSyarat {
  final bool terpenuhi;
  final String pesan;
  final String? rutePengisian;
  final String? atauPernyataan;

  const HasilEvaluasiSyarat({
    required this.terpenuhi,
    required this.pesan,
    this.rutePengisian,
    this.atauPernyataan,
  });
}

/// Hasil status gabungan suatu pelajaran atau modul.
class HasilStatusBelajar {
  final StatusBelajar status;
  final List<String> apaYangKurang;
  final String? ruteAksi;
  final List<String> daftarAtauPernyataan;

  const HasilStatusBelajar({
    required this.status,
    required this.apaYangKurang,
    this.ruteAksi,
    this.daftarAtauPernyataan = const [],
  });
}

// Model Struktur Konten
class KartuPelajaranKonten {
  final String judul;
  final String isi;

  const KartuPelajaranKonten({required this.judul, required this.isi});

  factory KartuPelajaranKonten.fromJson(Map<String, dynamic> json) {
    return KartuPelajaranKonten(
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
    );
  }
}

class CekPahamKonten {
  final String tanya;
  final List<String> pilihan;
  final int benar;
  final String penjelasan;

  const CekPahamKonten({
    required this.tanya,
    required this.pilihan,
    required this.benar,
    required this.penjelasan,
  });

  factory CekPahamKonten.fromJson(Map<String, dynamic> json) {
    return CekPahamKonten(
      tanya: json['tanya'] as String? ?? '',
      pilihan: (json['pilihan'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      benar: (json['benar'] as num?)?.toInt() ?? 0,
      penjelasan: json['penjelasan'] as String? ?? '',
    );
  }
}

class MisiKonten {
  final String tipe;
  final String? objek;
  final String? aturan;
  final int min;
  final String judul;
  final String deskripsi;
  final int perkiraanMenit;
  final String? umpanBalik;

  const MisiKonten({
    required this.tipe,
    this.objek,
    this.aturan,
    this.min = 1,
    required this.judul,
    required this.deskripsi,
    required this.perkiraanMenit,
    this.umpanBalik,
  });

  factory MisiKonten.fromJson(Map<String, dynamic> json) {
    return MisiKonten(
      tipe: json['tipe'] as String? ?? 'ada_data',
      objek: json['objek'] as String?,
      aturan: json['aturan'] as String?,
      min: (json['min'] as num?)?.toInt() ?? 1,
      judul: json['judul'] as String? ?? 'Misi Praktik',
      deskripsi: json['deskripsi'] as String? ?? '',
      perkiraanMenit: (json['perkiraanMenit'] as num?)?.toInt() ?? 2,
      umpanBalik: json['umpanBalik'] as String?,
    );
  }
}

class PelajaranKonten {
  final String id;
  final String modulId;
  final String judul;
  final int durasiMenit;
  final String status; // draf | ditinjau
  final List<SyaratGerbangData> gerbang;
  final String pemantik;
  final List<KartuPelajaranKonten> kartu;
  final int contohAngka;
  final List<CekPahamKonten> cekPaham;
  final MisiKonten misi;
  final String? tindakLanjut;

  const PelajaranKonten({
    required this.id,
    required this.modulId,
    required this.judul,
    required this.durasiMenit,
    required this.status,
    required this.gerbang,
    required this.pemantik,
    required this.kartu,
    required this.contohAngka,
    required this.cekPaham,
    required this.misi,
    this.tindakLanjut,
  });

  factory PelajaranKonten.fromJson(Map<String, dynamic> json, {String? fallbackModulId}) {
    final modul = (json['modul'] as String?) ?? fallbackModulId ?? '';
    return PelajaranKonten(
      id: json['id'] as String? ?? '',
      modulId: modul,
      judul: json['judul'] as String? ?? '',
      durasiMenit: (json['durasiMenit'] as num?)?.toInt() ?? 4,
      status: json['status'] as String? ?? 'draf',
      gerbang: (json['gerbang'] as List<dynamic>?)
              ?.map((e) => SyaratGerbangData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pemantik: json['pemantik'] as String? ?? '',
      kartu: (json['kartu'] as List<dynamic>?)
              ?.map((e) => KartuPelajaranKonten.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      contohAngka: (json['contohAngka'] as num?)?.toInt() ?? 0,
      cekPaham: (json['cekPaham'] as List<dynamic>?)
              ?.map((e) => CekPahamKonten.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      misi: MisiKonten.fromJson(json['misi'] as Map<String, dynamic>? ?? {}),
      tindakLanjut: json['tindakLanjut'] as String?,
    );
  }
}

class SoalKuis {
  final String id;
  final String pelajaranId;
  final String tanya;
  final List<String> pilihan;
  final int benar;
  final String penjelasan;

  const SoalKuis({
    required this.id,
    required this.pelajaranId,
    required this.tanya,
    required this.pilihan,
    required this.benar,
    required this.penjelasan,
  });

  factory SoalKuis.fromJson(Map<String, dynamic> json) {
    return SoalKuis(
      id: json['id'] as String? ?? '',
      pelajaranId: json['pelajaranId'] as String? ?? '',
      tanya: json['tanya'] as String? ?? '',
      pilihan: (json['pilihan'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      benar: (json['benar'] as num?)?.toInt() ?? 0,
      penjelasan: json['penjelasan'] as String? ?? '',
    );
  }
}

class KuisKonten {
  final int jumlahSoal;
  final List<SoalKuis> bankSoal;

  const KuisKonten({required this.jumlahSoal, required this.bankSoal});

  factory KuisKonten.fromJson(Map<String, dynamic> json) {
    return KuisKonten(
      jumlahSoal: (json['jumlahSoal'] as num?)?.toInt() ?? 0,
      bankSoal: (json['bankSoal'] as List<dynamic>?)
              ?.map((e) => SoalKuis.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ModulKonten {
  final String id;
  final String judul;
  final String tingkat;
  final int urutan;
  final String deskripsiSingkat;
  final bool tersedia;
  final List<SyaratGerbangData> gerbang;
  final List<String> daftarPelajaran;
  final KuisKonten kuis;

  const ModulKonten({
    required this.id,
    required this.judul,
    required this.tingkat,
    required this.urutan,
    required this.deskripsiSingkat,
    required this.tersedia,
    required this.gerbang,
    required this.daftarPelajaran,
    required this.kuis,
  });

  factory ModulKonten.fromJson(Map<String, dynamic> json) {
    return ModulKonten(
      id: json['id'] as String? ?? '',
      judul: json['judul'] as String? ?? '',
      tingkat: json['tingkat'] as String? ?? 'pemula',
      urutan: (json['urutan'] as num?)?.toInt() ?? 0,
      deskripsiSingkat: json['deskripsiSingkat'] as String? ?? '',
      tersedia: json['tersedia'] as bool? ?? false,
      gerbang: (json['gerbang'] as List<dynamic>?)
              ?.map((e) => SyaratGerbangData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      daftarPelajaran: (json['daftarPelajaran'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      kuis: KuisKonten.fromJson(json['kuis'] as Map<String, dynamic>? ?? {}),
    );
  }
}

// -----------------------------------------------------------------------------
// FUNGSI MURNI LOGIKA BELAJAR
// -----------------------------------------------------------------------------

/// Menghitung skor kuis dalam persentase integer (0-100).
int hitungSkorKuis({required int benar, required int total}) {
  if (total <= 0) return 0;
  return (benar * 100) ~/ total;
}

/// Menghitung jumlah hari kalender berbeda berdasarkan waktu lokal perangkat.
int hitungHariKalenderBerbeda(List<DateTime> daftarWaktu) {
  final setHari = <String>{};
  for (final w in daftarWaktu) {
    final lokal = w.toLocal();
    final bulanStr = lokal.month.toString().padLeft(2, '0');
    final hariStr = lokal.day.toString().padLeft(2, '0');
    setHari.add('${lokal.year}-$bulanStr-$hariStr');
  }
  return setHari.length;
}

/// Menghitung jumlah bulan kalender berbeda berdasarkan waktu lokal perangkat.
int hitungBulanKalenderBerbeda(List<DateTime> daftarWaktu) {
  final setBulan = <String>{};
  for (final w in daftarWaktu) {
    final lokal = w.toLocal();
    final bulanStr = lokal.month.toString().padLeft(2, '0');
    setBulan.add('${lokal.year}-$bulanStr');
  }
  return setBulan.length;
}

/// Menentukan kelulusan kuis berdasarkan batas minimal 70% dengan aritmetika integer.
bool tentukanLulusKuis({required int benar, required int total}) {
  if (total <= 0) return false;
  return (benar * 100) >= (ambangLulusKuis * total);
}

/// Memilih sejumlah soal dari bank soal dan mengacak urutan soal serta pilihan jawabannya secara deterministik.
List<SoalKuis> pilihDanAcakSoalKuis({
  required List<SoalKuis> bankSoal,
  required int jumlahSoal,
  int? benih,
}) {
  if (bankSoal.isEmpty || jumlahSoal <= 0) return [];
  final rng = Random(benih);

  final daftarSoal = List<SoalKuis>.from(bankSoal)..shuffle(rng);
  final soalTerpilih = daftarSoal.take(jumlahSoal).toList();

  final hasilAcak = <SoalKuis>[];
  for (final soal in soalTerpilih) {
    final teksJawabanBenar = soal.pilihan[soal.benar];
    final pilihanDiacak = List<String>.from(soal.pilihan)..shuffle(rng);
    final indeksBenarBaru = pilihanDiacak.indexOf(teksJawabanBenar);

    hasilAcak.add(
      SoalKuis(
        id: soal.id,
        pelajaranId: soal.pelajaranId,
        tanya: soal.tanya,
        pilihan: pilihanDiacak,
        benar: indeksBenarBaru,
        penjelasan: soal.penjelasan,
      ),
    );
  }
  return hasilAcak;
}

/// Menghitung persentase per sifat pengeluaran menggunakan Metode Sisa Terbesar (Largest Remainder).
/// - Menjamin total seluruh persentase selalu tepat 100% bila ada pengeluaran.
/// - Bila tidak ada pengeluaran (total <= 0), mengembalikan Map kosong (tidak ada hasil, bebas pembagian nol).
/// - Aturan pemecah seri deterministik: prioritas urutan kanonikal ['kebutuhan', 'keinginan', 'tabungan', 'utang', 'belum_dilabeli'].
Map<String, int> hitungKomposisiSifat(Map<String, int> pengeluaranPerSifat) {
  final totalNominal = pengeluaranPerSifat.values.fold<int>(0, (a, b) => a + b);
  if (totalNominal <= 0) return <String, int>{};

  const urutanPrioritas = [
    'kebutuhan',
    'keinginan',
    'tabungan',
    'utang',
    'belum_dilabeli',
  ];

  final hasil = <String, int>{
    'kebutuhan': 0,
    'keinginan': 0,
    'tabungan': 0,
    'utang': 0,
    'belum_dilabeli': 0,
  };

  final kuotaBawah = <String, int>{};
  final sisaPecahan = <String, int>{};

  var totalKuotaBawah = 0;
  for (final sifat in urutanPrioritas) {
    final nominal = pengeluaranPerSifat[sifat] ?? 0;
    if (nominal <= 0) {
      kuotaBawah[sifat] = 0;
      sisaPecahan[sifat] = 0;
      continue;
    }
    final kuota = (nominal * 100) ~/ totalNominal;
    final sisa = (nominal * 100) % totalNominal;
    kuotaBawah[sifat] = kuota;
    sisaPecahan[sifat] = sisa;
    totalKuotaBawah += kuota;
  }

  // Masukkan juga sifat lain di luar kanonikal jika ada
  for (final entry in pengeluaranPerSifat.entries) {
    if (!urutanPrioritas.contains(entry.key)) {
      final nominal = entry.value;
      if (nominal > 0) {
        final kuota = (nominal * 100) ~/ totalNominal;
        final sisa = (nominal * 100) % totalNominal;
        kuotaBawah[entry.key] = kuota;
        sisaPecahan[entry.key] = sisa;
        totalKuotaBawah += kuota;
        hasil[entry.key] = 0;
      }
    }
  }

  var sisaBagi = 100 - totalKuotaBawah;
  final urutanSifat = kuotaBawah.keys.toList()
    ..sort((a, b) {
      final cmpSisa = (sisaPecahan[b] ?? 0).compareTo(sisaPecahan[a] ?? 0);
      if (cmpSisa != 0) return cmpSisa;
      final idxA = urutanPrioritas.indexOf(a);
      final idxB = urutanPrioritas.indexOf(b);
      final posA = idxA == -1 ? 999 : idxA;
      final posB = idxB == -1 ? 999 : idxB;
      return posA.compareTo(posB);
    });

  for (final sifat in urutanSifat) {
    var p = kuotaBawah[sifat] ?? 0;
    if (sisaBagi > 0) {
      p += 1;
      sisaBagi -= 1;
    }
    hasil[sifat] = p;
  }

  return hasil;
}

/// Mengembalikan rute tujuan pengisian berdasarkan nama objek data.
String? ambilRutePengisianObjek(String? objek) {
  switch (objek?.toLowerCase()) {
    case 'dompet':
      return '/dompet';
    case 'pemasukan':
    case 'pengeluaran':
    case 'transaksi':
    case 'arus_kas':
      return '/catatan';
    case 'anggaran':
      return '/anggaran';
    case 'tujuan':
      return '/tujuan';
    case 'utang':
      return '/utang';
    case 'kategori':
      return '/kategori';
    case 'tagihan':
      return '/tagihan';
    case 'profil':
      return '/belajar/tes-awal';
    default:
      return null;
  }
}

/// Mengevaluasi satu syarat gerbang data terhadap foto data pengguna.
HasilEvaluasiSyarat evaluasiSyarat(
  SyaratGerbangData syarat,
  FotoDataPengguna fotoData,
) {
  // Cek logika ATAU pernyataan terlebih dahulu
  if (syarat.atauPernyataan != null) {
    final nilaiPernyataan = fotoData.pernyataan[syarat.atauPernyataan];
    if (nilaiPernyataan == 'true') {
      return HasilEvaluasiSyarat(
        terpenuhi: true,
        pesan: syarat.pesan,
        rutePengisian: ambilRutePengisianObjek(syarat.objek),
        atauPernyataan: syarat.atauPernyataan,
      );
    }
  }

  var terpenuhi = false;

  switch (syarat.tipe) {
    case 'ada_data':
      final count = _hitungJumlahObjek(syarat.objek, fotoData);
      terpenuhi = count >= syarat.min;
      break;

    case 'aturan_data':
      if (syarat.aturan == 'semua_kategori_berlabel') {
        // Asumsi: Semua kategori keluar yang pernah dipakai pengguna bukan 'belum_dilabeli'
        final kategoriKeluar = fotoData.kategoriKeluarTerpakai;
        if (kategoriKeluar.isEmpty) {
          terpenuhi = false;
        } else {
          final adaYangBelum = kategoriKeluar.values.any((sifat) => sifat == 'belum_dilabeli');
          terpenuhi = !adaYangBelum;
        }
      } else {
        terpenuhi = false;
      }
      break;

    case 'periode_data':
      if (syarat.satuan == 'hari_berbeda') {
        terpenuhi = fotoData.hariTransaksiBerbeda >= syarat.min;
      } else if (syarat.satuan == 'bulan_berbeda') {
        terpenuhi = fotoData.bulanTransaksiBerbeda >= syarat.min;
      }
      break;

    case 'pernyataan':
      if (syarat.kunci != null) {
        terpenuhi = fotoData.pernyataan[syarat.kunci] == 'true';
      }
      break;

    case 'kuis_lulus':
      if (syarat.modulId != null) {
        final hasil = fotoData.hasilKuisTerbaik[syarat.modulId];
        terpenuhi = hasil?.lulus ?? false;
      }
      break;

    case 'modul_selesai':
      if (syarat.modulId != null) {
        // modul_selesai dicek dari kelulusan kuis modul tersebut
        final hasil = fotoData.hasilKuisTerbaik[syarat.modulId];
        terpenuhi = hasil?.lulus ?? false;
      }
      break;

    default:
      terpenuhi = false;
      break;
  }

  return HasilEvaluasiSyarat(
    terpenuhi: terpenuhi,
    pesan: syarat.pesan,
    rutePengisian: ambilRutePengisianObjek(syarat.objek),
    atauPernyataan: syarat.atauPernyataan,
  );
}

int _hitungJumlahObjek(String? objek, FotoDataPengguna fotoData) {
  switch (objek?.toLowerCase()) {
    case 'dompet':
      return fotoData.jumlahDompetAktif;
    case 'pemasukan':
      return fotoData.jumlahPemasukan;
    case 'pengeluaran':
      return fotoData.jumlahPengeluaran;
    case 'transaksi':
      return fotoData.jumlahPemasukan + fotoData.jumlahPengeluaran;
    case 'arus_kas':
      return (fotoData.jumlahPemasukan >= 1 && fotoData.jumlahPengeluaran >= 1) ? 1 : 0;
    case 'anggaran':
      return fotoData.jumlahAnggaran;
    case 'tujuan':
      return fotoData.jumlahTujuanAktif;
    case 'utang':
      return fotoData.jumlahUtangAktif;
    case 'kategori':
      return fotoData.kategoriKeluarTerpakai.length;
    case 'profil':
      return fotoData.profilTerisi ? 1 : 0;
    default:
      return 0;
  }
}

/// Menentukan status sebuah pelajaran (Terkunci, Terbuka, Sedang, Selesai).
/// ATURAN KRUSIAL: Pelajaran yang sudah 'selesai' TIDAK PERNAH terkunci ulang.
HasilStatusBelajar tentukanStatusPelajaran({
  required PelajaranKonten pelajaran,
  required int posisiIndeks,
  required List<PelajaranKonten> daftarPelajaranModul,
  required List<SyaratGerbangData> gerbangModul,
  required FotoDataPengguna fotoData,
}) {
  final statusTersimpan = fotoData.progresPelajaran[pelajaran.id];
  if (statusTersimpan == 'selesai') {
    return const HasilStatusBelajar(
      status: StatusBelajar.selesai,
      apaYangKurang: [],
    );
  }

  final apaYangKurang = <String>[];
  String? ruteAksi;
  final daftarAtau = <String>[];

  // 1. Cek prasyarat urutan: pelajaran sebelumnya harus selesai
  if (posisiIndeks > 0) {
    final pelajaranSebelumnya = daftarPelajaranModul[posisiIndeks - 1];
    final statusSebelumnya = fotoData.progresPelajaran[pelajaranSebelumnya.id];
    if (statusSebelumnya != 'selesai') {
      apaYangKurang.add('Selesaikan pelajaran sebelumnya: "${pelajaranSebelumnya.judul}"');
    }
  }

  // 2. Evaluasi gerbang modul induk
  for (final syarat in gerbangModul) {
    final hasil = evaluasiSyarat(syarat, fotoData);
    if (!hasil.terpenuhi) {
      apaYangKurang.add(hasil.pesan);
      ruteAksi ??= hasil.rutePengisian;
      if (hasil.atauPernyataan != null) {
        daftarAtau.add(hasil.atauPernyataan!);
      }
    }
  }

  // 3. Evaluasi gerbang pelajaran sendiri
  for (final syarat in pelajaran.gerbang) {
    final hasil = evaluasiSyarat(syarat, fotoData);
    if (!hasil.terpenuhi) {
      apaYangKurang.add(hasil.pesan);
      ruteAksi ??= hasil.rutePengisian;
      if (hasil.atauPernyataan != null) {
        daftarAtau.add(hasil.atauPernyataan!);
      }
    }
  }

  if (apaYangKurang.isNotEmpty) {
    return HasilStatusBelajar(
      status: StatusBelajar.terkunci,
      apaYangKurang: apaYangKurang,
      ruteAksi: ruteAksi,
      daftarAtauPernyataan: daftarAtau,
    );
  }

  if (statusTersimpan == 'sedang') {
    return const HasilStatusBelajar(
      status: StatusBelajar.sedang,
      apaYangKurang: [],
    );
  }

  return const HasilStatusBelajar(
    status: StatusBelajar.terbuka,
    apaYangKurang: [],
  );
}

/// Menentukan status modul secara keseluruhan.
HasilStatusBelajar tentukanStatusModul({
  required ModulKonten modul,
  required FotoDataPengguna fotoData,
}) {
  if (!modul.tersedia) {
    return const HasilStatusBelajar(
      status: StatusBelajar.terkunci,
      apaYangKurang: ['Segera hadir'],
    );
  }

  final apaYangKurang = <String>[];
  String? ruteAksi;
  final daftarAtau = <String>[];

  // Evaluasi gerbang modul
  for (final syarat in modul.gerbang) {
    final hasil = evaluasiSyarat(syarat, fotoData);
    if (!hasil.terpenuhi) {
      apaYangKurang.add(hasil.pesan);
      ruteAksi ??= hasil.rutePengisian;
      if (hasil.atauPernyataan != null) {
        daftarAtau.add(hasil.atauPernyataan!);
      }
    }
  }

  // Cek apakah seluruh pelajaran selesai
  var semuaPelajaranSelesai = true;
  for (final pelId in modul.daftarPelajaran) {
    if (fotoData.progresPelajaran[pelId] != 'selesai') {
      semuaPelajaranSelesai = false;
      break;
    }
  }

  // Cek apakah kuis lulus
  final hasilKuis = fotoData.hasilKuisTerbaik[modul.id];
  final kuisLulus = hasilKuis?.lulus ?? false;

  if (semuaPelajaranSelesai && kuisLulus) {
    return const HasilStatusBelajar(
      status: StatusBelajar.selesai,
      apaYangKurang: [],
    );
  }

  if (apaYangKurang.isNotEmpty) {
    return HasilStatusBelajar(
      status: StatusBelajar.terkunci,
      apaYangKurang: apaYangKurang,
      ruteAksi: ruteAksi,
      daftarAtauPernyataan: daftarAtau,
    );
  }

  if (!semuaPelajaranSelesai) {
    final adaYangDimulai = modul.daftarPelajaran.any((id) => fotoData.progresPelajaran.containsKey(id));
    return HasilStatusBelajar(
      status: adaYangDimulai ? StatusBelajar.sedang : StatusBelajar.terbuka,
      apaYangKurang: ['Selesaikan seluruh pelajaran di modul ini'],
    );
  }

  // Semua pelajaran selesai tapi kuis belum lulus
  return const HasilStatusBelajar(
    status: StatusBelajar.sedang,
    apaYangKurang: ['Lulus kuis akhir modul'],
  );
}
