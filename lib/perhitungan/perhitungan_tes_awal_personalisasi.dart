import '../fitur/belajar/model/pembaca_konten.dart';

/// Hasil perhitungan skor tes awal.
class HasilSkorTesAwal {
  final Map<String, int> skorPerModul;
  final int skorTotalPersen;
  final int totalBenar;
  final int totalSoal;

  const HasilSkorTesAwal({
    required this.skorPerModul,
    required this.skorTotalPersen,
    required this.totalBenar,
    required this.totalSoal,
  });
}

/// Menghitung skor tes awal secara murni dan deterministik.
HasilSkorTesAwal hitungSkorTesAwal({
  required Map<String, int> jawabanPengguna,
  required List<SoalTesAwalKonten> daftarSoal,
}) {
  if (daftarSoal.isEmpty) {
    return const HasilSkorTesAwal(
      skorPerModul: {},
      skorTotalPersen: 0,
      totalBenar: 0,
      totalSoal: 0,
    );
  }

  final hitungBenarPerModul = <String, int>{};
  final hitungTotalPerModul = <String, int>{};
  var totalBenar = 0;

  for (final soal in daftarSoal) {
    hitungTotalPerModul[soal.modulId] =
        (hitungTotalPerModul[soal.modulId] ?? 0) + 1;
    final jawaban = jawabanPengguna[soal.id];
    if (jawaban != null && jawaban == soal.benar) {
      hitungBenarPerModul[soal.modulId] =
          (hitungBenarPerModul[soal.modulId] ?? 0) + 1;
      totalBenar++;
    }
  }

  final skorPerModul = <String, int>{};
  for (final entry in hitungTotalPerModul.entries) {
    final modulId = entry.key;
    final total = entry.value;
    final benar = hitungBenarPerModul[modulId] ?? 0;
    skorPerModul[modulId] = (benar * 100) ~/ total;
  }

  final skorTotalPersen = (totalBenar * 100) ~/ daftarSoal.length;

  return HasilSkorTesAwal(
    skorPerModul: skorPerModul,
    skorTotalPersen: skorTotalPersen,
    totalBenar: totalBenar,
    totalSoal: daftarSoal.length,
  );
}

/// Model objek snapshot profil keuangan murni.
class ProfilKeuanganSnapshot {
  final String punyaPenghasilan;
  final String punyaUtang;
  final String danaDarurat;
  final String menabung;
  final String investasi;
  final String mencatatKeuangan;
  final String? tujuanUtama;

  const ProfilKeuanganSnapshot({
    required this.punyaPenghasilan,
    required this.punyaUtang,
    required this.danaDarurat,
    required this.menabung,
    required this.investasi,
    required this.mencatatKeuangan,
    this.tujuanUtama,
  });
}

/// Membangun snapshot profil keuangan dengan sanitasi masukan.
ProfilKeuanganSnapshot bangunProfil({
  required Map<String, String> jawabanProfil,
  String? tujuanUtama,
}) {
  const himpunanPenghasilan = {'rutin', 'tidak_rutin', 'belum'};
  const himpunanUtang = {'ya', 'tidak', 'tidak_yakin'};
  const himpunanDanaDarurat = {'belum', 'sedikit', 'sudah'};
  const himpunanMenabung = {'belum', 'kadang', 'rutin'};
  const himpunanInvestasi = {'belum', 'pernah', 'aktif'};
  const himpunanMencatat = {'belum', 'kadang', 'rutin'};

  final rawPenghasilan =
      jawabanProfil['punya_penghasilan']?.trim().toLowerCase();
  final penghasilan =
      himpunanPenghasilan.contains(rawPenghasilan) ? rawPenghasilan! : 'belum';

  final rawUtang = jawabanProfil['punya_utang']?.trim().toLowerCase();
  final utang = himpunanUtang.contains(rawUtang) ? rawUtang! : 'tidak_yakin';

  final rawDarurat = jawabanProfil['dana_darurat']?.trim().toLowerCase();
  final darurat =
      himpunanDanaDarurat.contains(rawDarurat) ? rawDarurat! : 'belum';

  final rawMenabung = jawabanProfil['menabung']?.trim().toLowerCase();
  final menabung =
      himpunanMenabung.contains(rawMenabung) ? rawMenabung! : 'belum';

  final rawInvestasi = jawabanProfil['investasi']?.trim().toLowerCase();
  final investasi =
      himpunanInvestasi.contains(rawInvestasi) ? rawInvestasi! : 'belum';

  final rawMencatat = jawabanProfil['mencatat_keuangan']?.trim().toLowerCase();
  final mencatat =
      himpunanMencatat.contains(rawMencatat) ? rawMencatat! : 'belum';

  String? tujuanSanitasi;
  if (tujuanUtama != null && tujuanUtama.trim().isNotEmpty) {
    final t = tujuanUtama.trim();
    tujuanSanitasi = t.length > 100 ? t.substring(0, 100) : t;
  }

  return ProfilKeuanganSnapshot(
    punyaPenghasilan: penghasilan,
    punyaUtang: utang,
    danaDarurat: darurat,
    menabung: menabung,
    investasi: investasi,
    mencatatKeuangan: mencatat,
    tujuanUtama: tujuanSanitasi,
  );
}

/// Item rekomendasi hasil evaluasi personalisasi.
class ModulRekomendasi {
  final String modulId;
  final String kodeAlasan;
  final int prioritas;

  const ModulRekomendasi({
    required this.modulId,
    required this.kodeAlasan,
    required this.prioritas,
  });
}

/// Menghitung rekomendasi modul berdasarkan profil dan skor tes awal (maks 3 modul).
List<ModulRekomendasi> rekomendasiModul({
  required ProfilKeuanganSnapshot profil,
  required Map<String, int> skorPerModul,
  required Set<String> modulSelesai,
}) {
  final daftarKandidat = <ModulRekomendasi>[];

  // Aturan 1: Jika punya utang 'ya', prioritaskan utang_cicilan
  if (profil.punyaUtang == 'ya' && !modulSelesai.contains('utang_cicilan')) {
    daftarKandidat.add(
      const ModulRekomendasi(
        modulId: 'utang_cicilan',
        kodeAlasan: 'ada_utang',
        prioritas: 1,
      ),
    );
  }

  // Aturan 2: Jika dana darurat 'belum', prioritaskan dana_darurat
  if (profil.danaDarurat == 'belum' && !modulSelesai.contains('dana_darurat')) {
    daftarKandidat.add(
      const ModulRekomendasi(
        modulId: 'dana_darurat',
        kodeAlasan: 'dana_darurat_kosong',
        prioritas: 2,
      ),
    );
  }

  // Aturan 3: Modul dengan skor tes awal rendah (< 70%)
  // Urutkan dari skor terkecil (0% lalu 50%)
  final modulSkorRendah = skorPerModul.entries
      .where((e) => e.value < 70 && !modulSelesai.contains(e.key))
      .toList()
    ..sort((a, b) => a.value.compareTo(b.value));

  for (final entry in modulSkorRendah) {
    if (!daftarKandidat.any((k) => k.modulId == entry.key)) {
      daftarKandidat.add(
        ModulRekomendasi(
          modulId: entry.key,
          kodeAlasan: 'skor_rendah',
          prioritas: 3,
        ),
      );
    }
  }

  // Aturan 4: Jika ada kecocokan teks tujuanUtama
  if (profil.tujuanUtama != null && profil.tujuanUtama!.isNotEmpty) {
    final teksLower = profil.tujuanUtama!.toLowerCase();
    final pemetaanKataKunci = {
      'utang_cicilan': ['utang', 'cicil', 'pinjol', 'kredit'],
      'dana_darurat': ['darurat', 'jaga-jaga', 'tak terduga'],
      'tabungan': ['nabung', 'menabung', 'simpanan'],
      'anggaran_arus_kas': ['anggaran', 'arus kas', 'catat', 'gaji'],
      'waspada_penipuan': ['tipu', 'penipuan', 'bodong'],
    };

    for (final entry in pemetaanKataKunci.entries) {
      final modulId = entry.key;
      if (!modulSelesai.contains(modulId) &&
          !daftarKandidat.any((k) => k.modulId == modulId)) {
        if (entry.value.any((kata) => teksLower.contains(kata))) {
          daftarKandidat.add(
            ModulRekomendasi(
              modulId: modulId,
              kodeAlasan: 'keinginan_terbesar',
              prioritas: 4,
            ),
          );
        }
      }
    }
  }

  // Aturan 5: Jika belum ada modul yang selesai dan kandidat masih kurang dari 3, tawarkan anggaran_arus_kas
  if (modulSelesai.isEmpty && !modulSelesai.contains('anggaran_arus_kas')) {
    if (!daftarKandidat.any((k) => k.modulId == 'anggaran_arus_kas')) {
      daftarKandidat.add(
        const ModulRekomendasi(
          modulId: 'anggaran_arus_kas',
          kodeAlasan: 'fondasi_awal',
          prioritas: 5,
        ),
      );
    }
  }

  // Saring unik dan ambil maksimal 3 modul
  final hasilUnik = <String, ModulRekomendasi>{};
  for (final item in daftarKandidat) {
    if (!hasilUnik.containsKey(item.modulId)) {
      hasilUnik[item.modulId] = item;
    }
    if (hasilUnik.length == 3) break;
  }

  return hasilUnik.values.toList();
}

enum AlasanTargetBelajar {
  sedangBerjalan,
  rekomendasi,
  terbukaPertama,
  selesaiSemua,
}

class RekomendasiTargetBelajar {
  final String modulId;
  final String pelajaranId;

  const RekomendasiTargetBelajar({
    required this.modulId,
    required this.pelajaranId,
  });
}

class TargetLanjutBelajar {
  final String modulId;
  final String pelajaranId;
  final AlasanTargetBelajar alasan;

  const TargetLanjutBelajar({
    required this.modulId,
    required this.pelajaranId,
    required this.alasan,
  });
}

/// Menentukan target tombol "Lanjut Belajar" di Beranda.
TargetLanjutBelajar tentukanTargetLanjutBelajar({
  required String? pelajaranSedang,
  required String? modulSedang,
  required List<RekomendasiTargetBelajar> rekomendasiTerbuka,
  required String modulTerbukaPertama,
  required String pelajaranTerbukaPertama,
}) {
  // 1. Sedang dikerjakan
  if (pelajaranSedang != null && modulSedang != null) {
    return TargetLanjutBelajar(
      modulId: modulSedang,
      pelajaranId: pelajaranSedang,
      alasan: AlasanTargetBelajar.sedangBerjalan,
    );
  }

  // 2. Rekomendasi pertama yang sudah terbuka gerbangnya
  if (rekomendasiTerbuka.isNotEmpty) {
    final rek = rekomendasiTerbuka.first;
    return TargetLanjutBelajar(
      modulId: rek.modulId,
      pelajaranId: rek.pelajaranId,
      alasan: AlasanTargetBelajar.rekomendasi,
    );
  }

  // 3. Modul terbuka pertama
  return TargetLanjutBelajar(
    modulId: modulTerbukaPertama,
    pelajaranId: pelajaranTerbukaPertama,
    alasan: AlasanTargetBelajar.terbukaPertama,
  );
}
