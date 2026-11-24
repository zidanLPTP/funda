import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
import '../../../perhitungan/perhitungan_umpan_balik_belajar.dart';
import '../../../perhitungan/perhitungan_utang_dashboard.dart';
import '../../../util/format_rupiah.dart';

/// Hasil evaluasi apakah suatu misi telah memenuhi syarat verifikasi pengguna.
class HasilEvaluasiMisi {
  final bool selesai;
  final String statusTeks;
  final bool didukung;

  const HasilEvaluasiMisi({
    required this.selesai,
    required this.statusTeks,
    this.didukung = true,
  });
}

/// Evaluator untuk memverifikasi jenis misi yang didukung di Tahap 4.
class RegistriMisi {
  static const Set<String> jenisMisiDidukung = {
    'ada_data',
    'aturan_data',
    'lihat_hitungan',
    'keputusan',
    'daftar_periksa',
    'refleksi',
    'sandbox',
  };

  /// Mengevaluasi misi berdasarkan foto data pengguna.
  static HasilEvaluasiMisi evaluasi({
    required MisiKonten misi,
    required FotoDataPengguna fotoData,
  }) {
    if (!jenisMisiDidukung.contains(misi.tipe)) {
      return const HasilEvaluasiMisi(
        selesai: false,
        statusTeks: 'Jenis misi ini belum didukung pada versi ini.',
        didukung: false,
      );
    }

    switch (misi.tipe) {
      case 'ada_data':
        if (misi.objek?.toLowerCase() == 'arus_kas') {
          final adaMasuk = fotoData.jumlahPemasukan >= 1;
          final adaKeluar = fotoData.jumlahPengeluaran >= 1;
          final cukup = adaMasuk && adaKeluar;
          String statusTeks;
          if (cukup) {
            statusTeks =
                'Syarat misi terpenuhi (pemasukan dan pengeluaran sudah tercatat).';
          } else if (!adaMasuk && !adaKeluar) {
            statusTeks = 'Catat minimal 1 pemasukan dan 1 pengeluaran.';
          } else if (!adaMasuk) {
            statusTeks = 'Catat minimal 1 pemasukan untuk melengkapi arus kas.';
          } else {
            statusTeks =
                'Catat minimal 1 pengeluaran untuk melengkapi arus kas.';
          }
          return HasilEvaluasiMisi(selesai: cukup, statusTeks: statusTeks);
        }
        final jumlah = _hitungJumlah(misi.objek, fotoData);
        final cukup = jumlah >= misi.min;
        return HasilEvaluasiMisi(
          selesai: cukup,
          statusTeks: cukup
              ? 'Syarat misi terpenuhi ($jumlah tercatat).'
              : 'Baru ada $jumlah dari minimal ${misi.min} data.',
        );

      case 'aturan_data':
        if (misi.aturan == 'semua_kategori_berlabel') {
          final kategoriKeluar = fotoData.kategoriKeluarTerpakai;
          if (kategoriKeluar.isEmpty) {
            return const HasilEvaluasiMisi(
              selesai: false,
              statusTeks: 'Belum ada transaksi pengeluaran untuk dilabeli.',
            );
          }
          final adaYangBelum = kategoriKeluar.values.any(
            (s) => s == 'belum_dilabeli',
          );
          return HasilEvaluasiMisi(
            selesai: !adaYangBelum,
            statusTeks: !adaYangBelum
                ? 'Semua pos kategori pengeluaranmu sudah dilabeli rapi.'
                : 'Masih ada kategori yang belum kamu beri label sifat.',
          );
        }
        return const HasilEvaluasiMisi(
          selesai: false,
          statusTeks: 'Aturan misi belum dikenal.',
        );

      case 'lihat_hitungan':
        // Pengguna cukup membuka layar hitungan dan menekan tombol paham
        return const HasilEvaluasiMisi(
          selesai: true,
          statusTeks: 'Hitungan siap dipelajari.',
        );

      case 'keputusan':
        return const HasilEvaluasiMisi(
          selesai: false,
          statusTeks: 'Tentukan keputusanmu pada skenario di atas.',
        );

      case 'daftar_periksa':
        return const HasilEvaluasiMisi(
          selesai: false,
          statusTeks: 'Centang langkah-langkah yang sudah kamu lakukan.',
        );

      case 'refleksi':
        return const HasilEvaluasiMisi(
          selesai: false,
          statusTeks: 'Tulis refleksimu pada kolom di atas.',
        );

      case 'sandbox':
        return const HasilEvaluasiMisi(
          selesai: false,
          statusTeks: 'Jalankan simulasi di Mode Sandbox.',
        );

      default:
        return const HasilEvaluasiMisi(
          selesai: false,
          statusTeks: 'Belum didukung',
          didukung: false,
        );
    }
  }

  static int _hitungJumlah(String? objek, FotoDataPengguna fotoData) {
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
        return (fotoData.jumlahPemasukan >= 1 &&
                fotoData.jumlahPengeluaran >= 1)
            ? 1
            : 0;
      case 'anggaran':
        return fotoData.jumlahAnggaran;
      case 'tujuan':
        return fotoData.jumlahTujuanAktif;
      case 'tujuan_tabungan':
        return fotoData.jumlahTujuanTabungan;
      case 'isi_tujuan_tabungan':
        return fotoData.jumlahIsiTujuanTabungan;
      case 'pengeluaran_kebutuhan':
        return fotoData.jumlahPengeluaranKebutuhan;
      case 'tujuan_dana_darurat':
        return fotoData.jumlahTujuanDanaDarurat;
      case 'isi_dana_darurat':
        return fotoData.jumlahIsiDanaDarurat;
      case 'utang':
        return fotoData.jumlahUtangAktif;
      default:
        return 0;
    }
  }

  /// Evaluasi logika untuk opsi misi keputusan.
  static bool evaluasiKeputusan(OpsiKeputusanMisi opsi) {
    return opsi.aman;
  }

  /// Evaluasi logika untuk misi daftar periksa.
  static bool evaluasiDaftarPeriksa({
    required Set<String> dicentang,
    required int minimalDicentang,
  }) {
    return dicentang.length >= minimalDicentang;
  }

  /// Evaluasi logika untuk misi refleksi.
  /// Memeriksa apakah teks setelah ditrim mencapai minimal karakter yang ditentukan (default 10).
  static bool evaluasiRefleksi(String teks, {int minimalKarakter = 10}) {
    return teks.trim().length >= minimalKarakter;
  }

  /// Menghasilkan umpan balik ringkasan langganan dan pengeluaran keinginan.
  static String formatRingkasanLanggananDanKeinginanMisi({
    required List<ItemLanggananUmpanBalik> daftarTagihan,
    required int totalKeinginanBulanIniRupiah,
  }) {
    return formatRingkasanLanggananDanKeinginan(
      daftarTagihan: daftarTagihan,
      totalKeinginanBulanIniRupiah: totalKeinginanBulanIniRupiah,
    );
  }

  /// Menghasilkan umpan balik ringkasan proteksi dasar (beban wajib dan dana darurat).
  static String formatRingkasanProteksiDasarMisi({
    required int pengeluaranWajibBulananRupiah,
    String? dasarPengeluaranWajib,
    required int danaDaruratTerkumpul,
  }) {
    return formatRingkasanProteksiDasar(
      pengeluaranWajibBulananRupiah: pengeluaranWajibBulananRupiah,
      dasarPengeluaranWajib: dasarPengeluaranWajib,
      danaDaruratTerkumpul: danaDaruratTerkumpul,
    );
  }

  /// Menghasilkan umpan balik ringkasan pemasukan tambahan (banyak sumber).
  static String formatRingkasanPemasukanTambahanMisi({
    required Map<String, int> petaPemasukanPerKategori,
    required bool baruSatuSumber,
  }) {
    return formatRingkasanPemasukanTambahan(
      petaPemasukanPerKategori: petaPemasukanPerKategori,
      baruSatuSumber: baruSatuSumber,
    );
  }

  /// Menghasilkan umpan balik ringkasan penghasilan tahunan (persiapan pajak).
  static String formatRingkasanPenghasilanTahunanMisi({
    required int totalPemasukanTahunIni,
    required int jumlahBulanTercatat,
  }) {
    return formatRingkasanPenghasilanTahunan(
      totalPemasukanTahunIni: totalPemasukanTahunIni,
      jumlahBulanTercatat: jumlahBulanTercatat,
    );
  }

  /// Menghasilkan umpan balik ringkasan tujuan besar (proyeksi dan setoran bulanan).
  static String formatRingkasanTujuanBesarMisi({
    required DataTujuanBesarUmpanBalik? tujuan,
  }) {
    return formatRingkasanTujuanBesar(tujuan: tujuan);
  }

  /// Menghasilkan umpan balik uji kemampuan KPR dari data pemasukan dan cicilan aktif.
  static String formatUjiKemampuanKprMisi({
    required HasilPemasukanRataRata? pemasukanRataRata,
    required int totalCicilanAktifRupiah,
    required int totalSaldoDompetAktifRupiah,
    String? deskripsiDasarOverride,
  }) {
    return formatUjiKemampuanKpr(
      pemasukanRataRata: pemasukanRataRata,
      totalCicilanAktifRupiah: totalCicilanAktifRupiah,
      totalSaldoDompetAktifRupiah: totalSaldoDompetAktifRupiah,
      deskripsiDasarOverride: deskripsiDasarOverride,
    );
  }

  /// Menghasilkan umpan balik proyeksi patokan kebebasan finansial dari pengeluaran wajib dan kekayaan bersih.
  static String formatProyeksiKebebasanFinansialMisi({
    required int pengeluaranWajibBulananRupiah,
    required String dasarPengeluaranWajib,
    required int kekayaanBersihRupiah,
  }) {
    return formatProyeksiKebebasanFinansial(
      pengeluaranWajibBulananRupiah: pengeluaranWajibBulananRupiah,
      dasarPengeluaranWajib: dasarPengeluaranWajib,
      kekayaanBersihRupiah: kekayaanBersihRupiah,
    );
  }

  /// Menghasilkan umpan balik ringkasan usaha kecil (17.2).
  static String formatRingkasanUsahaKecilMisi({
    required int jumlahDompetAktif,
    required int totalPemasukanBulanIniRupiah,
    required int totalPengeluaranBulanIniRupiah,
    required bool belumPunyaUsaha,
  }) {
    return formatRingkasanUsahaKecil(
      jumlahDompetAktif: jumlahDompetAktif,
      totalPemasukanBulanIniRupiah: totalPemasukanBulanIniRupiah,
      totalPengeluaranBulanIniRupiah: totalPengeluaranBulanIniRupiah,
      belumPunyaUsaha: belumPunyaUsaha,
    );
  }
}

/// Penyedia teks umpan balik dari data nyata pengguna tanpa jargon.
class RegistriUmpanBalik {
  /// Menghasilkan teks dan angka umpan balik untuk arus kas bulan ini.
  static String formatArusKasBulanIni(HasilArusKas arusKas) {
    final masuk = formatRupiah(arusKas.totalMasuk);
    final keluar = formatRupiah(arusKas.totalKeluar);
    final selisih = formatRupiah(arusKas.selisih.abs());

    if (arusKas.selisih > 0) {
      return 'Bulan ini uang yang masuk ($masuk) lebih besar daripada uang yang keluar ($keluar). Ada ruang simpanan sebesar $selisih.';
    } else if (arusKas.selisih < 0) {
      return 'Bulan ini uang yang keluar ($keluar) lebih besar daripada uang yang masuk ($masuk). Selisih pengeluaranmu adalah $selisih.';
    } else {
      return 'Bulan ini uang masuk dan uang keluar kamu seimbang di angka $masuk.';
    }
  }

  /// Menghasilkan teks dan rincian umpan balik untuk komposisi sifat pengeluaran.
  static String formatKomposisiSifat(Map<String, int> persenPerSifat) {
    final keb = persenPerSifat['kebutuhan'] ?? 0;
    final kei = persenPerSifat['keinginan'] ?? 0;
    final tab = persenPerSifat['tabungan'] ?? 0;
    final utg = persenPerSifat['utang'] ?? 0;
    final blm = persenPerSifat['belum_dilabeli'] ?? 0;

    final bagian = <String>[];
    if (keb > 0) bagian.add('Kebutuhan $keb%');
    if (kei > 0) bagian.add('Keinginan $kei%');
    if (tab > 0) bagian.add('Tabungan $tab%');
    if (utg > 0) bagian.add('Cicilan $utg%');
    if (blm > 0) bagian.add('Belum Berlabel $blm%');

    if (bagian.isEmpty) {
      return 'Belum ada pengeluaran yang tercatat di bulan ini untuk dianalisis.';
    }

    return 'Porsi belanjamu bulan ini: ${bagian.join(", ")}. Kamu bisa melihat pos mana yang paling dominan.';
  }

  /// Menghasilkan umpan balik pencatatan pengeluaran terbaru.
  static String formatCatatanPengeluaranTerbaruMisi({
    required int jumlahTotal,
    required String kategori,
    required int nominal,
  }) {
    return formatCatatanPengeluaranTerbaru(
      jumlahTotal: jumlahTotal,
      kategori: kategori,
      nominal: nominal,
    );
  }

  /// Menghasilkan umpan balik perbandingan pola anggaran buatan pengguna vs pola 50/30/20.
  static String formatPerbandinganPolaAnggaranMisi({
    required int pemasukan,
    required int kebutuhan,
    required int keinginan,
    required int tabunganDanUtang,
    int belumDilabeli = 0,
  }) {
    return formatPerbandinganPolaAnggaran(
      pemasukan: pemasukan,
      kebutuhan: kebutuhan,
      keinginan: keinginan,
      tabunganDanUtang: tabunganDanUtang,
      belumDilabeli: belumDilabeli,
    );
  }

  /// Menghasilkan umpan balik realisasi anggaran bulan ini.
  static String formatRealisasiAnggaranBulanIniMisi(
    List<PosAnggaranEvaluasi> daftarPos,
  ) {
    return formatRealisasiAnggaranBulanIni(daftarPos);
  }

  /// Menghasilkan umpan balik ringkasan tujuan tabungan.
  static String formatRingkasanTujuanTabunganMisi({
    required DataTujuanTabunganUmpanBalik? tujuan,
    required DateTime waktuSekarang,
  }) {
    return formatRingkasanTujuanTabungan(
      tujuan: tujuan,
      waktuSekarang: waktuSekarang,
    );
  }

  /// Menghasilkan umpan balik estimasi tabungan.
  static String formatEstimasiTabunganMisi({
    required DataTujuanTabunganUmpanBalik? tujuan,
    required int setoranRataRata,
  }) {
    return formatEstimasiTabungan(
      tujuan: tujuan,
      setoranRataRata: setoranRataRata,
    );
  }

  /// Menghasilkan umpan balik pengeluaran wajib bulanan.
  static String formatPengeluaranWajibBulananMisi(HasilPengeluaranWajib hasil) {
    return formatTeksPengeluaranWajibBulanan(hasil);
  }

  /// Menghasilkan umpan balik target dana darurat.
  static String formatTargetDanaDaruratMisi({
    required HasilPengeluaranWajib pengeluaranWajib,
  }) {
    return formatTargetDanaDarurat(pengeluaranWajib: pengeluaranWajib);
  }

  /// Menghasilkan umpan balik progres dana darurat.
  static String formatProgresDanaDaruratMisi({
    required DataTujuanDanaDaruratUmpanBalik? tujuan,
    required int? pengeluaranWajibPerBulan,
  }) {
    return formatProgresDanaDarurat(
      tujuan: tujuan,
      pengeluaranWajibPerBulan: pengeluaranWajibPerBulan,
    );
  }

  /// Menghasilkan umpan balik ringkasan utang.
  static String formatRingkasanUtangMisi({
    required List<ItemUtangUmpanBalik> daftarUtang,
    required HasilPemasukanRataRata? pemasukan,
    required bool tidakPunyaUtang,
  }) {
    return formatRingkasanUtang(
      daftarUtang: daftarUtang,
      pemasukan: pemasukan,
      tidakPunyaUtang: tidakPunyaUtang,
    );
  }

  /// Menghasilkan umpan balik biaya pinjaman tercatat.
  static String formatBiayaPinjamanTercatatMisi({
    required List<ItemUtangUmpanBalik> daftarUtang,
    required bool tidakPunyaUtang,
  }) {
    return formatBiayaPinjamanTercatat(
      daftarUtang: daftarUtang,
      tidakPunyaUtang: tidakPunyaUtang,
    );
  }

  /// Menghasilkan umpan balik rasio cicilan bulan ini.
  static String formatRasioCicilanBulanIniMisi({
    required int totalCicilanBulanan,
    required HasilPemasukanRataRata? pemasukan,
  }) {
    return formatRasioCicilanBulanIni(
      totalCicilanBulanan: totalCicilanBulanan,
      pemasukan: pemasukan,
    );
  }

  /// Menghasilkan umpan balik urutan pelunasan.
  static String formatUrutanPelunasanMisi({
    required List<ItemUtangUmpanBalik> daftarUtang,
    required bool tidakPunyaUtang,
  }) {
    return formatUrutanPelunasan(
      daftarUtang: daftarUtang,
      tidakPunyaUtang: tidakPunyaUtang,
    );
  }

  /// Menghasilkan umpan balik ringkasan langganan dan pengeluaran keinginan.
  static String formatRingkasanLanggananDanKeinginanMisi({
    required List<ItemLanggananUmpanBalik> daftarTagihan,
    required int totalKeinginanBulanIniRupiah,
  }) {
    return formatRingkasanLanggananDanKeinginan(
      daftarTagihan: daftarTagihan,
      totalKeinginanBulanIniRupiah: totalKeinginanBulanIniRupiah,
    );
  }

  /// Menghasilkan umpan balik ringkasan proteksi dasar (beban wajib dan dana darurat).
  static String formatRingkasanProteksiDasarMisi({
    required int pengeluaranWajibBulananRupiah,
    String? dasarPengeluaranWajib,
    required int danaDaruratTerkumpul,
  }) {
    return formatRingkasanProteksiDasar(
      pengeluaranWajibBulananRupiah: pengeluaranWajibBulananRupiah,
      dasarPengeluaranWajib: dasarPengeluaranWajib,
      danaDaruratTerkumpul: danaDaruratTerkumpul,
    );
  }

  /// Menghasilkan umpan balik ringkasan pemasukan tambahan (banyak sumber).
  static String formatRingkasanPemasukanTambahanMisi({
    required Map<String, int> petaPemasukanPerKategori,
    required bool baruSatuSumber,
  }) {
    return formatRingkasanPemasukanTambahan(
      petaPemasukanPerKategori: petaPemasukanPerKategori,
      baruSatuSumber: baruSatuSumber,
    );
  }

  /// Menghasilkan umpan balik ringkasan penghasilan tahunan (persiapan pajak).
  static String formatRingkasanPenghasilanTahunanMisi({
    required int totalPemasukanTahunIni,
    required int jumlahBulanTercatat,
  }) {
    return formatRingkasanPenghasilanTahunan(
      totalPemasukanTahunIni: totalPemasukanTahunIni,
      jumlahBulanTercatat: jumlahBulanTercatat,
    );
  }

  /// Menghasilkan umpan balik ringkasan tujuan besar (proyeksi dan setoran bulanan).
  static String formatRingkasanTujuanBesarMisi({
    required DataTujuanBesarUmpanBalik? tujuan,
  }) {
    return formatRingkasanTujuanBesar(tujuan: tujuan);
  }

  /// Menghasilkan umpan balik uji kemampuan KPR dari data pemasukan dan cicilan aktif.
  static String formatUjiKemampuanKprMisi({
    required HasilPemasukanRataRata? pemasukanRataRata,
    required int totalCicilanAktifRupiah,
    required int totalSaldoDompetAktifRupiah,
    String? deskripsiDasarOverride,
  }) {
    return formatUjiKemampuanKpr(
      pemasukanRataRata: pemasukanRataRata,
      totalCicilanAktifRupiah: totalCicilanAktifRupiah,
      totalSaldoDompetAktifRupiah: totalSaldoDompetAktifRupiah,
      deskripsiDasarOverride: deskripsiDasarOverride,
    );
  }

  /// Menghasilkan umpan balik proyeksi patokan kebebasan finansial dari pengeluaran wajib dan kekayaan bersih.
  static String formatProyeksiKebebasanFinansialMisi({
    required int pengeluaranWajibBulananRupiah,
    required String dasarPengeluaranWajib,
    required int kekayaanBersihRupiah,
  }) {
    return formatProyeksiKebebasanFinansial(
      pengeluaranWajibBulananRupiah: pengeluaranWajibBulananRupiah,
      dasarPengeluaranWajib: dasarPengeluaranWajib,
      kekayaanBersihRupiah: kekayaanBersihRupiah,
    );
  }

  /// Menghasilkan umpan balik ringkasan usaha kecil (17.2).
  static String formatRingkasanUsahaKecilMisi({
    required int jumlahDompetAktif,
    required int totalPemasukanBulanIniRupiah,
    required int totalPengeluaranBulanIniRupiah,
    required bool belumPunyaUsaha,
  }) {
    return formatRingkasanUsahaKecil(
      jumlahDompetAktif: jumlahDompetAktif,
      totalPemasukanBulanIniRupiah: totalPemasukanBulanIniRupiah,
      totalPengeluaranBulanIniRupiah: totalPengeluaranBulanIniRupiah,
      belumPunyaUsaha: belumPunyaUsaha,
    );
  }
}
