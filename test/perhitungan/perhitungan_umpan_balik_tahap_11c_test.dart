import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 11C - ringkasan_usaha_kecil', () {
    test('V1: belumPunyaUsaha: true (apa pun jumlah dompet/transaksi)', () {
      final hasil = formatRingkasanUsahaKecil(
        jumlahDompetAktif: 0,
        totalPemasukanBulanIniRupiah: 0,
        totalPengeluaranBulanIniRupiah: 0,
        belumPunyaUsaha: true,
      );

      const ekspetasi =
          'Kamu menyatakan belum punya usaha saat ini. Pelajaran ini tetap bisa kamu jadikan bekal agar nanti sejak hari pertama usaha, uang pribadi dan uang usaha langsung terpisah rapi.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi via RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanUsahaKecilMisi(
        jumlahDompetAktif: 5,
        totalPemasukanBulanIniRupiah: 10000000,
        totalPengeluaranBulanIniRupiah: 5000000,
        belumPunyaUsaha: true,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V2: belumPunyaUsaha: false, 3 dompet aktif, masuk 8.000.000, keluar 5.000.000', () {
      final hasil = formatRingkasanUsahaKecil(
        jumlahDompetAktif: 3,
        totalPemasukanBulanIniRupiah: 8000000,
        totalPengeluaranBulanIniRupiah: 5000000,
        belumPunyaUsaha: false,
      );

      const ekspetasi =
          'Kamu sudah punya 3 dompet aktif yang bisa dipakai memisahkan uang pribadi dan uang usaha. '
          'Arus kas tercatat bulan ini: uang masuk Rp8.000.000, uang keluar Rp5.000.000. '
          'Pisahkan catatan pribadi dan usaha agar modal kerja tidak terpakai tanpa sadar.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi via RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanUsahaKecilMisi(
        jumlahDompetAktif: 3,
        totalPemasukanBulanIniRupiah: 8000000,
        totalPengeluaranBulanIniRupiah: 5000000,
        belumPunyaUsaha: false,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V3: belumPunyaUsaha: false, 1 dompet aktif, masuk 0, keluar 0', () {
      final hasil = formatRingkasanUsahaKecil(
        jumlahDompetAktif: 1,
        totalPemasukanBulanIniRupiah: 0,
        totalPengeluaranBulanIniRupiah: 0,
        belumPunyaUsaha: false,
      );

      const ekspetasi =
          'Saat ini kamu baru punya 1 dompet aktif. Membuat dompet terpisah untuk usaha membantumu melihat hasil usaha lebih jernih. '
          'Belum ada transaksi tercatat bulan ini. '
          'Pisahkan catatan pribadi dan usaha agar modal kerja tidak terpakai tanpa sadar.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi via RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanUsahaKecilMisi(
        jumlahDompetAktif: 1,
        totalPemasukanBulanIniRupiah: 0,
        totalPengeluaranBulanIniRupiah: 0,
        belumPunyaUsaha: false,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('Evaluasi Gerbang Modul 17: ada_data sumber_pemasukan min 2 ATAU belum_punya_usaha', () {
      final syarat = SyaratGerbangData(
        tipe: 'ada_data',
        objek: 'sumber_pemasukan',
        min: 2,
        atauPernyataan: 'belum_punya_usaha',
        pesan:
            'Catat pemasukan dari minimal 2 kategori berbeda dulu. Kalau kamu belum punya usaha saat ini, pilih Aku tidak punya ini.',
      );

      // Kasus 1: Pemasukan hanya 1 kategori, belum ada pernyataan -> Terkunci
      final foto1 = FotoDataPengguna.kosong().copyWith(
        jumlahSumberPemasukan: 1,
        pernyataan: {},
      );
      final hasil1 = evaluasiSyarat(syarat, foto1);
      expect(hasil1.terpenuhi, isFalse);
      expect(hasil1.atauPernyataan, equals('belum_punya_usaha'));

      // Kasus 2: Pemasukan hanya 1 kategori, tetapi ada pernyataan belum_punya_usaha -> Terbuka
      final foto2 = FotoDataPengguna.kosong().copyWith(
        jumlahSumberPemasukan: 1,
        pernyataan: {'belum_punya_usaha': 'true'},
      );
      final hasil2 = evaluasiSyarat(syarat, foto2);
      expect(hasil2.terpenuhi, isTrue);

      // Kasus 3: Pemasukan 2 kategori tanpa pernyataan -> Terbuka
      final foto3 = FotoDataPengguna.kosong().copyWith(
        jumlahSumberPemasukan: 2,
        pernyataan: {},
      );
      final hasil3 = evaluasiSyarat(syarat, foto3);
      expect(hasil3.terpenuhi, isTrue);
    });

    test('Evaluasi Gerbang Modul 18: modul_selesai proteksi_dasar', () {
      final syarat = SyaratGerbangData(
        tipe: 'modul_selesai',
        modulId: 'proteksi_dasar',
        pesan:
            'Selesaikan Modul 10 (Proteksi Dasar) dulu sebelum mempelajari perencanaan proteksi keluarga dan warisan dasar.',
      );

      // Belum selesai Modul 10 -> Terkunci
      final fotoBelum = FotoDataPengguna.kosong().copyWith(
        hasilKuisTerbaik: {
          'anggaran_arus_kas': const HasilKuisSnapshot(lulus: true, skorPersen: 100),
        },
      );
      final hasilBelum = evaluasiSyarat(syarat, fotoBelum);
      expect(hasilBelum.terpenuhi, isFalse);

      // Sudah selesai Modul 10 (proteksi_dasar) -> Terbuka
      final fotoSudah = FotoDataPengguna.kosong().copyWith(
        hasilKuisTerbaik: {
          'anggaran_arus_kas': const HasilKuisSnapshot(lulus: true, skorPersen: 100),
          'proteksi_dasar': const HasilKuisSnapshot(lulus: true, skorPersen: 80),
        },
      );
      final hasilSudah = evaluasiSyarat(syarat, fotoSudah);
      expect(hasilSudah.terpenuhi, isTrue);
    });
  });
}
