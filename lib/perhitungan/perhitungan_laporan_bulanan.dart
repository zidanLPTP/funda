import 'perhitungan_anggaran_tujuan.dart';
import 'perhitungan_belajar.dart';
import 'perhitungan_umpan_balik_belajar.dart';
import '../fitur/belajar/model/pembaca_konten.dart';

/// Menghitung persentase tunggal dengan pembulatan ke terdekat memakai aritmetika integer murni.
/// Rumus: (bagian * 200 + total) ~/ (total * 2).
/// Mengembalikan null jika total <= 0 (menghindari pembagian dengan nol).
int? persenTerdekat(int bagian, int total) {
  if (total <= 0) return null;
  return ((bagian * 200) + total) ~/ (total * 2);
}

/// Representasi data satu pos anggaran untuk laporan bulanan.
class PosAnggaranLaporan {
  final String id;
  final String nama;
  final int batasRupiah;
  final int terpakaiRupiah;
  final int persenTerpakai;
  final StatusAnggaran status;

  const PosAnggaranLaporan({
    required this.id,
    required this.nama,
    required this.batasRupiah,
    required this.terpakaiRupiah,
    required this.persenTerpakai,
    required this.status,
  });

  int get selisihMelewati => terpakaiRupiah - batasRupiah;

  factory PosAnggaranLaporan.dariItem(ItemRealisasiAnggaran item) {
    final realisasi = item.realisasi;
    return PosAnggaranLaporan(
      id: item.anggaranId.isNotEmpty ? item.anggaranId : item.kategoriId,
      nama: item.namaKategori,
      batasRupiah: item.batasRupiah,
      terpakaiRupiah: item.terpakaiRupiah,
      persenTerpakai: realisasi.persenTerpakai,
      status: realisasi.status,
    );
  }
}

/// Representasi data tujuan keuangan untuk laporan bulanan.
class TujuanLaporan {
  final String id;
  final String nama;
  final int danaTerkumpulRupiah;
  final int targetRupiah;
  final int persenProgres;

  const TujuanLaporan({
    required this.id,
    required this.nama,
    required this.danaTerkumpulRupiah,
    required this.targetRupiah,
    required this.persenProgres,
  });
}

/// Parameter temuan laporan bulanan.
class TemuanLaporan {
  final String kode;
  final Map<String, dynamic> parameter;

  const TemuanLaporan({
    required this.kode,
    required this.parameter,
  });
}

/// Parameter saran laporan bulanan.
class SaranLaporan {
  final String kode;
  final Map<String, dynamic> parameter;

  const SaranLaporan({
    required this.kode,
    required this.parameter,
  });
}

/// Data snapshot kekayaan pada tanggal laporan dibuat.
class SnapshotKekayaanLaporan {
  final int totalSaldoDompetRupiah;
  final int totalSisaUtangRupiah;
  final int kekayaanBersihRupiah;

  const SnapshotKekayaanLaporan({
    required this.totalSaldoDompetRupiah,
    required this.totalSisaUtangRupiah,
    required this.kekayaanBersihRupiah,
  });
}

/// Arus kas laporan bulanan.
class ArusKasLaporan {
  final int uangMasukRupiah;
  final int uangKeluarRupiah;
  final int selisihRupiah;

  const ArusKasLaporan({
    required this.uangMasukRupiah,
    required this.uangKeluarRupiah,
    required this.selisihRupiah,
  });
}

/// Komposisi pengeluaran laporan bulanan.
class KomposisiPengeluaranLaporan {
  final Map<String, int> perSifatRupiah;
  final Map<String, int> perSifatPersen;

  const KomposisiPengeluaranLaporan({
    required this.perSifatRupiah,
    required this.perSifatPersen,
  });
}

/// Ringkasan pos anggaran laporan bulanan.
class RingkasanAnggaranLaporan {
  final int totalPos;
  final int posAman;
  final int posMendekati;
  final int posMelewati;
  final List<PosAnggaranLaporan> daftarPosTampil;
  final int jumlahPosLain;

  const RingkasanAnggaranLaporan({
    required this.totalPos,
    required this.posAman,
    required this.posMendekati,
    required this.posMelewati,
    required this.daftarPosTampil,
    required this.jumlahPosLain,
  });
}

/// Data masukan murni untuk menyusun laporan bulanan.
class MasukanLaporanBulanan {
  final DateTime bulan;
  final DateTime waktuDibuat;
  final int uangMasukRupiah;
  final int uangKeluarRupiah;
  final Map<String, int> pengeluaranPerSifat;
  final List<PosAnggaranLaporan> daftarPosAnggaran;
  final List<TujuanLaporan> daftarTujuanAktif;
  final int saldoDompetAktifRupiah;
  final int sisaUtangAktifRupiah;
  final List<({String nama, int pengeluaranRupiah})> kategoriBelumDilabeliTerpakai;

  const MasukanLaporanBulanan({
    required this.bulan,
    required this.waktuDibuat,
    required this.uangMasukRupiah,
    required this.uangKeluarRupiah,
    required this.pengeluaranPerSifat,
    required this.daftarPosAnggaran,
    required this.daftarTujuanAktif,
    required this.saldoDompetAktifRupiah,
    required this.sisaUtangAktifRupiah,
    this.kategoriBelumDilabeliTerpakai = const [],
  });
}

/// Model data lengkap dan immutable laporan bulanan.
class LaporanBulanan {
  final DateTime bulan;
  final DateTime tanggalDibuat;
  final ArusKasLaporan arusKas;
  final KomposisiPengeluaranLaporan komposisi;
  final RingkasanAnggaranLaporan ringkasanAnggaran;
  final List<TujuanLaporan> daftarTujuan;
  final SnapshotKekayaanLaporan snapshotKekayaan;
  final TemuanLaporan temuan;
  final SaranLaporan saran;

  const LaporanBulanan({
    required this.bulan,
    required this.tanggalDibuat,
    required this.arusKas,
    required this.komposisi,
    required this.ringkasanAnggaran,
    required this.daftarTujuan,
    required this.snapshotKekayaan,
    required this.temuan,
    required this.saran,
  });
}

/// Menentukan temuan tunggal berdasarkan aturan prioritas resmi 1 sampai 6.
TemuanLaporan tentukanTemuan({
  required int uangMasukRupiah,
  required int uangKeluarRupiah,
  required Map<String, int> pengeluaranPerSifat,
  required List<PosAnggaranLaporan> daftarPosAnggaran,
  required KontenLaporan? konten,
}) {
  // 1. pos_melewati: ada pos melewati batas; ambil yang paling jauh (terpakai - batas terbesar)
  final posMelewati = daftarPosAnggaran.where((p) => p.status == StatusAnggaran.melewati).toList();
  if (posMelewati.isNotEmpty) {
    posMelewati.sort((a, b) {
      final diff = b.selisihMelewati.compareTo(a.selisihMelewati);
      if (diff != 0) return diff;
      return a.nama.compareTo(b.nama);
    });
    final posTerjauh = posMelewati.first;
    final persenPos = persenTerdekat(posTerjauh.terpakaiRupiah, posTerjauh.batasRupiah) ?? posTerjauh.persenTerpakai;
    return TemuanLaporan(
      kode: 'pos_melewati',
      parameter: {
        'nama': posTerjauh.nama,
        'jumlah': formatRupiahRapat(posTerjauh.selisihMelewati),
        'persen': persenPos,
      },
    );
  }

  // 2. arus_kas_tanpa_pemasukan: pemasukan 0 dan pengeluaran > 0
  if (uangMasukRupiah == 0 && uangKeluarRupiah > 0) {
    return const TemuanLaporan(
      kode: 'arus_kas_tanpa_pemasukan',
      parameter: {},
    );
  }

  // 3. arus_kas_negatif: pengeluaran > pemasukan > 0
  if (uangKeluarRupiah > uangMasukRupiah && uangMasukRupiah > 0) {
    final selisih = uangKeluarRupiah - uangMasukRupiah;
    final persen = persenTerdekat(uangKeluarRupiah, uangMasukRupiah) ?? 0;
    return TemuanLaporan(
      kode: 'arus_kas_negatif',
      parameter: {
        'jumlah': formatRupiahRapat(selisih),
        'persen': persen,
      },
    );
  }

  // 4. sifat_terbesar: ada pengeluaran dan satu sifat terbesar secara STRIK
  if (uangKeluarRupiah > 0) {
    String? sifatMax;
    var maxVal = 0;
    var seri = false;

    for (final entry in pengeluaranPerSifat.entries) {
      if (entry.value <= 0) continue;
      if (entry.value > maxVal) {
        maxVal = entry.value;
        sifatMax = entry.key;
        seri = false;
      } else if (entry.value == maxVal) {
        seri = true;
      }
    }

    if (sifatMax != null && !seri && maxVal > 0) {
      final komposisiPersen = hitungKomposisiSifat(pengeluaranPerSifat);
      final persenSifat = komposisiPersen[sifatMax] ?? 0;
      final frasa = konten != null
          ? konten.frasaUntukSifat(sifatMax)
          : (sifatMax == 'belum_dilabeli' ? 'pengeluaran yang belum dilabeli' : sifatMax);
      return TemuanLaporan(
        kode: 'sifat_terbesar',
        parameter: {
          'sifat': frasa,
          'persen': persenSifat,
        },
      );
    }
  }

  // 5. arus_kas_positif: pemasukan > pengeluaran
  if (uangMasukRupiah > uangKeluarRupiah) {
    final selisih = uangMasukRupiah - uangKeluarRupiah;
    final persen = persenTerdekat(uangKeluarRupiah, uangMasukRupiah) ?? 0;
    return TemuanLaporan(
      kode: 'arus_kas_positif',
      parameter: {
        'jumlah': formatRupiahRapat(selisih),
        'persen': persen,
      },
    );
  }

  // 6. data_belum_cukup: selain itu
  return const TemuanLaporan(
    kode: 'data_belum_cukup',
    parameter: {},
  );
}

/// Menentukan saran tunggal berdasarkan aturan prioritas resmi 1 sampai 4.
SaranLaporan tentukanSaran({
  required List<PosAnggaranLaporan> daftarPosAnggaran,
  required List<({String nama, int pengeluaranRupiah})> kategoriBelumDilabeliTerpakai,
}) {
  // 1. buat_anggaran: tidak ada anggaran bulan ini
  if (daftarPosAnggaran.isEmpty) {
    return const SaranLaporan(
      kode: 'buat_anggaran',
      parameter: {},
    );
  }

  // 2. tinjau_pos: ada pos melewati; pos terjauh
  final posMelewati = daftarPosAnggaran.where((p) => p.status == StatusAnggaran.melewati).toList();
  if (posMelewati.isNotEmpty) {
    posMelewati.sort((a, b) {
      final diff = b.selisihMelewati.compareTo(a.selisihMelewati);
      if (diff != 0) return diff;
      return a.nama.compareTo(b.nama);
    });
    return SaranLaporan(
      kode: 'tinjau_pos',
      parameter: {
        'nama': posMelewati.first.nama,
      },
    );
  }

  // 3. beri_label: ada kategori belum dilabeli yang terpakai bulan ini; pengeluaran terbesar
  final belumDilabeliAktif = kategoriBelumDilabeliTerpakai.where((k) => k.pengeluaranRupiah > 0).toList();
  if (belumDilabeliAktif.isNotEmpty) {
    belumDilabeliAktif.sort((a, b) {
      final diff = b.pengeluaranRupiah.compareTo(a.pengeluaranRupiah);
      if (diff != 0) return diff;
      return a.nama.compareTo(b.nama);
    });
    return SaranLaporan(
      kode: 'beri_label',
      parameter: {
        'nama': belumDilabeliAktif.first.nama,
      },
    );
  }

  // 4. salin_anggaran: selain itu
  return const SaranLaporan(
    kode: 'salin_anggaran',
    parameter: {},
  );
}

/// Menyusun objek laporan bulanan lengkap dan immutable.
LaporanBulanan susunLaporanBulanan(
  MasukanLaporanBulanan masukan, {
  KontenLaporan? konten,
}) {
  final selisih = masukan.uangMasukRupiah - masukan.uangKeluarRupiah;
  final arusKas = ArusKasLaporan(
    uangMasukRupiah: masukan.uangMasukRupiah,
    uangKeluarRupiah: masukan.uangKeluarRupiah,
    selisihRupiah: selisih,
  );

  // Komposisi pengeluaran
  final komposisiPersen = hitungKomposisiSifat(masukan.pengeluaranPerSifat);
  final komposisi = KomposisiPengeluaranLaporan(
    perSifatRupiah: Map.unmodifiable(masukan.pengeluaranPerSifat),
    perSifatPersen: Map.unmodifiable(komposisiPersen),
  );

  // Evaluasi pos anggaran: urut melewati > mendekati > aman, ambil maksimal 5
  var countAman = 0;
  var countMendekati = 0;
  var countMelewati = 0;

  for (final p in masukan.daftarPosAnggaran) {
    switch (p.status) {
      case StatusAnggaran.aman:
        countAman++;
        break;
      case StatusAnggaran.mendekati:
        countMendekati++;
        break;
      case StatusAnggaran.melewati:
        countMelewati++;
        break;
    }
  }

  final daftarUrut = List<PosAnggaranLaporan>.from(masukan.daftarPosAnggaran);
  daftarUrut.sort((a, b) {
    // 1. Urutan status: melewati (0) > mendekati (1) > aman (2)
    final prioritasStatusA = a.status == StatusAnggaran.melewati
        ? 0
        : (a.status == StatusAnggaran.mendekati ? 1 : 2);
    final prioritasStatusB = b.status == StatusAnggaran.melewati
        ? 0
        : (b.status == StatusAnggaran.mendekati ? 1 : 2);

    if (prioritasStatusA != prioritasStatusB) {
      return prioritasStatusA.compareTo(prioritasStatusB);
    }

    // Jika melewati, urutkan dari selisih melewati terbesar
    if (a.status == StatusAnggaran.melewati) {
      final diff = b.selisihMelewati.compareTo(a.selisihMelewati);
      if (diff != 0) return diff;
    }

    // Jika mendekati atau aman, urutkan persentase terpakai terbesar
    final diffPersen = b.persenTerpakai.compareTo(a.persenTerpakai);
    if (diffPersen != 0) return diffPersen;

    return a.nama.compareTo(b.nama);
  });

  final daftarTampil = daftarUrut.take(5).toList();
  final posLain = daftarUrut.length > 5 ? daftarUrut.length - 5 : 0;

  final ringkasanAnggaran = RingkasanAnggaranLaporan(
    totalPos: masukan.daftarPosAnggaran.length,
    posAman: countAman,
    posMendekati: countMendekati,
    posMelewati: countMelewati,
    daftarPosTampil: List.unmodifiable(daftarTampil),
    jumlahPosLain: posLain,
  );

  // Tujuan aktif (maksimal 3)
  final daftarTujuan = masukan.daftarTujuanAktif.take(3).toList();

  // Snapshot kekayaan
  final kekayaanBersih = masukan.saldoDompetAktifRupiah - masukan.sisaUtangAktifRupiah;
  final snapshotKekayaan = SnapshotKekayaanLaporan(
    totalSaldoDompetRupiah: masukan.saldoDompetAktifRupiah,
    totalSisaUtangRupiah: masukan.sisaUtangAktifRupiah,
    kekayaanBersihRupiah: kekayaanBersih,
  );

  // Temuan & Saran
  final temuan = tentukanTemuan(
    uangMasukRupiah: masukan.uangMasukRupiah,
    uangKeluarRupiah: masukan.uangKeluarRupiah,
    pengeluaranPerSifat: masukan.pengeluaranPerSifat,
    daftarPosAnggaran: masukan.daftarPosAnggaran,
    konten: konten,
  );

  final saran = tentukanSaran(
    daftarPosAnggaran: masukan.daftarPosAnggaran,
    kategoriBelumDilabeliTerpakai: masukan.kategoriBelumDilabeliTerpakai,
  );

  return LaporanBulanan(
    bulan: masukan.bulan,
    tanggalDibuat: masukan.waktuDibuat,
    arusKas: arusKas,
    komposisi: komposisi,
    ringkasanAnggaran: ringkasanAnggaran,
    daftarTujuan: List.unmodifiable(daftarTujuan),
    snapshotKekayaan: snapshotKekayaan,
    temuan: temuan,
    saran: saran,
  );
}

/// Representasi baris pos anggaran terformat.
class PosAnggaranTerformat {
  final String nama;
  final String teks;
  final int persen;
  final StatusAnggaran status;

  const PosAnggaranTerformat({
    required this.nama,
    required this.teks,
    required this.persen,
    required this.status,
  });
}

/// Representasi baris tujuan terformat.
class TujuanTerformat {
  final String nama;
  final String teks;
  final int persen;

  const TujuanTerformat({
    required this.nama,
    required this.teks,
    required this.persen,
  });
}

/// Kumpulan teks lengkap siap tampil untuk antarmuka UI, gambar PNG, dan PDF.
class TampilanTeksLaporan {
  final bool sensor;
  final String judulPeriode;
  final String labelPerTanggal;
  final String labelUangMasuk;
  final String nilaiUangMasuk;
  final String labelUangKeluar;
  final String nilaiUangKeluar;
  final String labelSelisih;
  final String nilaiSelisih;
  final String? teksArusKasSensor;
  final Map<String, String> komposisiPerSifat;
  final String ringkasanAnggaran;
  final List<PosAnggaranTerformat> daftarPosAnggaran;
  final String? barisPosLain;
  final List<TujuanTerformat> daftarTujuan;
  final String? teksBelumAdaTujuan;
  final String teksSaldoDompet;
  final String teksSisaUtang;
  final String teksKekayaanBersih;
  final String teksTemuan;
  final String teksSaran;
  final String catatanKakiEkspor;
  final String catatanKakiAplikasi;

  const TampilanTeksLaporan({
    required this.sensor,
    required this.judulPeriode,
    required this.labelPerTanggal,
    required this.labelUangMasuk,
    required this.nilaiUangMasuk,
    required this.labelUangKeluar,
    required this.nilaiUangKeluar,
    required this.labelSelisih,
    required this.nilaiSelisih,
    this.teksArusKasSensor,
    required this.komposisiPerSifat,
    required this.ringkasanAnggaran,
    required this.daftarPosAnggaran,
    this.barisPosLain,
    required this.daftarTujuan,
    this.teksBelumAdaTujuan,
    required this.teksSaldoDompet,
    required this.teksSisaUtang,
    required this.teksKekayaanBersih,
    required this.teksTemuan,
    required this.teksSaran,
    required this.catatanKakiEkspor,
    required this.catatanKakiAplikasi,
  });

  /// Mengumpulkan semua string teks yang dihasilkan untuk keperluan audit dan pengujian sensor.
  List<String> get semuaTeks {
    final list = <String>[
      judulPeriode,
      labelPerTanggal,
      labelUangMasuk,
      nilaiUangMasuk,
      labelUangKeluar,
      nilaiUangKeluar,
      labelSelisih,
      nilaiSelisih,
      ?teksArusKasSensor,
      ...komposisiPerSifat.values,
      ringkasanAnggaran,
      ...daftarPosAnggaran.map((p) => p.teks),
      ?barisPosLain,
      ...daftarTujuan.map((t) => t.teks),
      ?teksBelumAdaTujuan,
      teksSaldoDompet,
      teksSisaUtang,
      teksKekayaanBersih,
      teksTemuan,
      teksSaran,
      catatanKakiEkspor,
      catatanKakiAplikasi,
    ];
    return list;
  }
}

/// Menghasilkan format tanggal Indonesia sederhana (mis. "18 November 2026").
String _formatTanggalIndonesia(DateTime dt) {
  const bulanIndo = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  return '${dt.day} ${bulanIndo[dt.month]} ${dt.year}';
}

/// Menghasilkan nama bulan dan tahun Indonesia (mis. "November 2026").
String formatBulanTahunIndonesia(DateTime dt) {
  const bulanIndo = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  return '${bulanIndo[dt.month]} ${dt.year}';
}

/// Menggantikan placeholder {kunci} pada template teks.
String _gantiPlaceholder(String template, Map<String, dynamic> parameter) {
  var hasil = template;
  for (final entry in parameter.entries) {
    hasil = hasil.replaceAll('{${entry.key}}', entry.value.toString());
  }
  return hasil;
}

/// Menerapkan aturan mode sensor atau normal untuk menghasilkan teks laporan siap tampil.
TampilanTeksLaporan terapkanSensor(
  LaporanBulanan laporan,
  KontenLaporan konten, {
  required bool sensor,
}) {
  final labelPerTanggal = _gantiPlaceholder(
    konten.label['perTanggal'] ?? 'Per {tanggal}',
    {'tanggal': _formatTanggalIndonesia(laporan.tanggalDibuat)},
  );

  final judulPeriode = 'Laporan Funda - ${formatBulanTahunIndonesia(laporan.bulan)}';

  // Arus kas
  final String nilaiUangMasuk;
  final String nilaiUangKeluar;
  final String nilaiSelisih;
  final String? teksArusKasSensor;

  if (sensor) {
    final disembunyikan = konten.label['disembunyikan'] ?? 'Disembunyikan';
    nilaiUangMasuk = disembunyikan;
    nilaiUangKeluar = disembunyikan;
    nilaiSelisih = disembunyikan;

    final persenArusKas = persenTerdekat(
      laporan.arusKas.uangKeluarRupiah,
      laporan.arusKas.uangMasukRupiah,
    );
    if (persenArusKas != null) {
      teksArusKasSensor = _gantiPlaceholder(
        konten.baris.arusKasSensor,
        {'persen': persenArusKas},
      );
    } else {
      teksArusKasSensor = null;
    }
  } else {
    nilaiUangMasuk = formatRupiahRapat(laporan.arusKas.uangMasukRupiah);
    nilaiUangKeluar = formatRupiahRapat(laporan.arusKas.uangKeluarRupiah);
    nilaiSelisih = formatRupiahRapat(laporan.arusKas.selisihRupiah);
    teksArusKasSensor = null;
  }

  // Komposisi pengeluaran
  final komposisiMap = <String, String>{};
  const urutanSifat = ['kebutuhan', 'keinginan', 'tabungan', 'utang', 'belum_dilabeli'];
  for (final sifat in urutanSifat) {
    final persen = laporan.komposisi.perSifatPersen[sifat] ?? 0;
    final nominal = laporan.komposisi.perSifatRupiah[sifat] ?? 0;
    final frasa = konten.frasaUntukSifat(sifat);

    if (sensor) {
      komposisiMap[sifat] = '$frasa: $persen persen';
    } else {
      komposisiMap[sifat] = '$frasa: $persen persen (${formatRupiahRapat(nominal)})';
    }
  }

  // Realisasi anggaran
  final String ringkasanAnggaran;
  if (laporan.ringkasanAnggaran.totalPos == 0) {
    ringkasanAnggaran = konten.baris.belumAdaAnggaran;
  } else {
    ringkasanAnggaran = _gantiPlaceholder(
      konten.baris.ringkasanAnggaran,
      {
        'n': laporan.ringkasanAnggaran.totalPos,
        'a': laporan.ringkasanAnggaran.posAman,
        'b': laporan.ringkasanAnggaran.posMendekati,
        'c': laporan.ringkasanAnggaran.posMelewati,
      },
    );
  }

  final daftarPos = <PosAnggaranTerformat>[];
  for (final pos in laporan.ringkasanAnggaran.daftarPosTampil) {
    final String teksPos;
    if (sensor) {
      teksPos = _gantiPlaceholder(
        konten.baris.posAnggaranSensor,
        {
          'nama': pos.nama,
          'persen': pos.persenTerpakai,
        },
      );
    } else {
      teksPos = _gantiPlaceholder(
        konten.baris.posAnggaranNormal,
        {
          'nama': pos.nama,
          'terpakai': formatRupiahRapat(pos.terpakaiRupiah),
          'batas': formatRupiahRapat(pos.batasRupiah),
          'persen': pos.persenTerpakai,
        },
      );
    }
    daftarPos.add(
      PosAnggaranTerformat(
        nama: pos.nama,
        teks: teksPos,
        persen: pos.persenTerpakai,
        status: pos.status,
      ),
    );
  }

  final barisPosLain = laporan.ringkasanAnggaran.jumlahPosLain > 0
      ? _gantiPlaceholder(konten.baris.posLain, {'n': laporan.ringkasanAnggaran.jumlahPosLain})
      : null;

  // Tujuan
  final daftarTujuan = <TujuanTerformat>[];
  for (final tuj in laporan.daftarTujuan) {
    final String teksTujuan;
    if (sensor) {
      teksTujuan = _gantiPlaceholder(
        konten.baris.tujuanSensor,
        {
          'nama': tuj.nama,
          'persen': tuj.persenProgres,
        },
      );
    } else {
      teksTujuan = _gantiPlaceholder(
        konten.baris.tujuanNormal,
        {
          'nama': tuj.nama,
          'dana': formatRupiahRapat(tuj.danaTerkumpulRupiah),
          'target': formatRupiahRapat(tuj.targetRupiah),
          'persen': tuj.persenProgres,
        },
      );
    }
    daftarTujuan.add(
      TujuanTerformat(
        nama: tuj.nama,
        teks: teksTujuan,
        persen: tuj.persenProgres,
      ),
    );
  }
  final teksBelumAdaTujuan = daftarTujuan.isEmpty ? konten.baris.belumAdaTujuan : null;

  // Snapshot kekayaan
  final String teksSaldoDompet;
  final String teksSisaUtang;
  final String teksKekayaanBersih;

  if (sensor) {
    final disembunyikan = konten.label['disembunyikan'] ?? 'Disembunyikan';
    teksSaldoDompet = _gantiPlaceholder(konten.baris.saldoDompet, {'jumlah': disembunyikan});
    teksSisaUtang = _gantiPlaceholder(konten.baris.sisaUtang, {'jumlah': disembunyikan});
    teksKekayaanBersih = _gantiPlaceholder(konten.baris.kekayaanBersih, {'jumlah': disembunyikan});
  } else {
    teksSaldoDompet = _gantiPlaceholder(
      konten.baris.saldoDompet,
      {'jumlah': formatRupiahRapat(laporan.snapshotKekayaan.totalSaldoDompetRupiah)},
    );
    teksSisaUtang = _gantiPlaceholder(
      konten.baris.sisaUtang,
      {'jumlah': formatRupiahRapat(laporan.snapshotKekayaan.totalSisaUtangRupiah)},
    );
    teksKekayaanBersih = _gantiPlaceholder(
      konten.baris.kekayaanBersih,
      {'jumlah': formatRupiahRapat(laporan.snapshotKekayaan.kekayaanBersihRupiah)},
    );
  }

  // Temuan
  final itemTemuan = konten.temuanUntukKode(laporan.temuan.kode);
  final templateTemuan = itemTemuan != null
      ? (sensor ? itemTemuan.sensor : itemTemuan.normal)
      : 'Temuan tidak tersedia';
  final teksTemuan = _gantiPlaceholder(templateTemuan, laporan.temuan.parameter);

  // Saran
  final itemSaran = konten.saranUntukKode(laporan.saran.kode);
  final templateSaran = itemSaran != null ? itemSaran.teks : 'Saran tidak tersedia';
  final teksSaran = _gantiPlaceholder(templateSaran, laporan.saran.parameter);

  return TampilanTeksLaporan(
    sensor: sensor,
    judulPeriode: judulPeriode,
    labelPerTanggal: labelPerTanggal,
    labelUangMasuk: konten.label['uangMasuk'] ?? 'Uang masuk',
    nilaiUangMasuk: nilaiUangMasuk,
    labelUangKeluar: konten.label['uangKeluar'] ?? 'Uang keluar',
    nilaiUangKeluar: nilaiUangKeluar,
    labelSelisih: konten.label['selisih'] ?? 'Selisih',
    nilaiSelisih: nilaiSelisih,
    teksArusKasSensor: teksArusKasSensor,
    komposisiPerSifat: komposisiMap,
    ringkasanAnggaran: ringkasanAnggaran,
    daftarPosAnggaran: daftarPos,
    barisPosLain: barisPosLain,
    daftarTujuan: daftarTujuan,
    teksBelumAdaTujuan: teksBelumAdaTujuan,
    teksSaldoDompet: teksSaldoDompet,
    teksSisaUtang: teksSisaUtang,
    teksKekayaanBersih: teksKekayaanBersih,
    teksTemuan: teksTemuan,
    teksSaran: teksSaran,
    catatanKakiEkspor: konten.catatanKaki['ekspor'] ?? '',
    catatanKakiAplikasi: konten.catatanKaki['aplikasi'] ?? '',
  );
}
