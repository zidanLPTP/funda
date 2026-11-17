import '../../../perhitungan/perhitungan_belajar.dart';
import '../../../perhitungan/perhitungan_keuangan.dart';
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
            statusTeks = 'Syarat misi terpenuhi (pemasukan dan pengeluaran sudah tercatat).';
          } else if (!adaMasuk && !adaKeluar) {
            statusTeks = 'Catat minimal 1 pemasukan dan 1 pengeluaran.';
          } else if (!adaMasuk) {
            statusTeks = 'Catat minimal 1 pemasukan untuk melengkapi arus kas.';
          } else {
            statusTeks = 'Catat minimal 1 pengeluaran untuk melengkapi arus kas.';
          }
          return HasilEvaluasiMisi(
            selesai: cukup,
            statusTeks: statusTeks,
          );
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
          final adaYangBelum = kategoriKeluar.values.any((s) => s == 'belum_dilabeli');
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
        return (fotoData.jumlahPemasukan >= 1 && fotoData.jumlahPengeluaran >= 1) ? 1 : 0;
      case 'anggaran':
        return fotoData.jumlahAnggaran;
      case 'tujuan':
        return fotoData.jumlahTujuanAktif;
      case 'utang':
        return fotoData.jumlahUtangAktif;
      default:
        return 0;
    }
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
}
