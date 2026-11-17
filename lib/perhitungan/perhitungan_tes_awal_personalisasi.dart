import '../fitur/belajar/model/pembaca_konten.dart';
import 'perhitungan_belajar.dart';

/// Konstanta heuristik urutan saran personalisasi (bukan penilaian atau nasihat keuangan).
const String alasanSkorTesRendah = 'skor_tes_rendah';
const String alasanPunyaUtangTercatat = 'punya_utang_tercatat';
const String alasanDanaDaruratKosong = 'dana_darurat_kosong';
const String alasanKeinginanTerbesar = 'keinginan_terbesar';
const String alasanBelumAdaModulSelesai = 'belum_ada_modul_selesai';

/// Ambang kelulusan kuis untuk mengidentifikasi topik yang perlu diperdalam.
const int ambangLulusKuis = 70;

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
  final List<String> kodeAlasan;
  final bool tersedia;
  final bool terbuka;
  final List<String> apaYangKurang;

  const ModulRekomendasi({
    required this.modulId,
    required this.kodeAlasan,
    required this.tersedia,
    required this.terbuka,
    this.apaYangKurang = const [],
  });

  /// Kode alasan utama untuk kompatibilitas tampilan.
  String get kodeAlasanUtama => kodeAlasan.isNotEmpty ? kodeAlasan.first : '';
}

/// Menghitung rekomendasi modul berdasarkan profil, hasil tes awal, dan foto data (maksimal 3 modul).
List<ModulRekomendasi> rekomendasiModul({
  ProfilKeuanganSnapshot? profil,
  HasilSkorTesAwal? hasilTes,
  required FotoDataPengguna fotoData,
  required List<ModulKonten> daftarModul,
  required Map<String, HasilStatusBelajar> statusModul,
}) {
  // 1. Modul yang sudah selesai dikeluarkan dari rekomendasi
  final modulSelesai = <String>{};
  for (final entry in statusModul.entries) {
    if (entry.value.status == StatusBelajar.selesai) {
      modulSelesai.add(entry.key);
    }
  }

  final alasanPerModul = <String, List<String>>{};

  void tambahAlasan(String modulId, String kodeAlasan) {
    if (modulSelesai.contains(modulId)) return;
    final list = alasanPerModul.putIfAbsent(modulId, () => []);
    if (!list.contains(kodeAlasan)) {
      list.add(kodeAlasan);
    }
  }

  // Aturan 1: Modul bertingkat pemula yang skor tesnya < ambangLulusKuis (70) -> alasan skor_tes_rendah
  if (hasilTes != null) {
    for (final modul in daftarModul) {
      if (modul.tingkat == 'pemula' && modul.id != 'mulai_tes_awal') {
        final skor = hasilTes.skorPerModul[modul.id];
        if (skor != null && skor < ambangLulusKuis) {
          tambahAlasan(modul.id, alasanSkorTesRendah);
        }
      }
    }
  }

  // Aturan 2: Ada utang aktif dengan sisa > 0 -> modul utang_cicilan, alasan punya_utang_tercatat
  final adaUtangAktif =
      fotoData.sisaUtangAktif > 0 || (profil != null && profil.punyaUtang == 'ya');
  if (adaUtangAktif) {
    tambahAlasan('utang_cicilan', alasanPunyaUtangTercatat);
  }

  // Aturan 3: Tidak ada tujuan dana_darurat aktif, atau dana terkumpulnya 0 -> modul dana_darurat, alasan dana_darurat_kosong
  final danaDaruratKosong =
      (!fotoData.tujuanDanaDaruratAktif || fotoData.saldoTerkumpulDanaDarurat <= 0) ||
      (profil != null && profil.danaDarurat == 'belum');
  if (danaDaruratKosong) {
    tambahAlasan('dana_darurat', alasanDanaDaruratKosong);
  }

  // Aturan 4: Komposisi sifat pengeluaran bulan ini: keinginan merupakan sifat terbesar secara STRIK
  // (bukan gabungan / bukan seri) dan total pengeluaran > 0 -> modul psikologi_uang, alasan keinginan_terbesar
  final comp = fotoData.komposisiSifatBulanIni;
  final keinginan = comp['keinginan'] ?? 0;
  final kebutuhan = comp['kebutuhan'] ?? 0;
  final tabungan = comp['tabungan'] ?? 0;
  final utang = comp['utang'] ?? 0;
  final belum = comp['belum_dilabeli'] ?? 0;
  final totalPengeluaran = keinginan + kebutuhan + tabungan + utang + belum;

  if (totalPengeluaran > 0 &&
      keinginan > kebutuhan &&
      keinginan > tabungan &&
      keinginan > utang &&
      keinginan > belum) {
    tambahAlasan('psikologi_uang', alasanKeinginanTerbesar);
  }

  // Aturan 5: Bila belum ada modul yang selesai -> modul pertama yang terbuka, alasan belum_ada_modul_selesai
  if (modulSelesai.isEmpty) {
    for (final modul in daftarModul) {
      if (modul.id != 'mulai_tes_awal') {
        final stat = statusModul[modul.id];
        if (stat != null && stat.status == StatusBelajar.terbuka) {
          tambahAlasan(modul.id, alasanBelumAdaModulSelesai);
          break;
        }
      }
    }
  }

  // Urutkan modul berdasarkan urutan modul di kurikulum, ambil maksimal 3
  final daftarKandidat = <ModulRekomendasi>[];
  for (final modul in daftarModul) {
    if (alasanPerModul.containsKey(modul.id)) {
      final stat = statusModul[modul.id];
      daftarKandidat.add(
        ModulRekomendasi(
          modulId: modul.id,
          kodeAlasan: alasanPerModul[modul.id]!,
          tersedia: modul.tersedia,
          terbuka: stat?.status == StatusBelajar.terbuka,
          apaYangKurang: stat?.apaYangKurang ?? const [],
        ),
      );
      if (daftarKandidat.length == 3) {
        break;
      }
    }
  }

  return daftarKandidat;
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
