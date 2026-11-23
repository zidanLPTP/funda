import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 9B - ringkasan_proteksi_dasar', () {
    test('V1: W = 1.900.000 (rata-rata 3 bulan terakhir), dana = 2.850.000', () {
      final hasil = formatRingkasanProteksiDasar(
        pengeluaranWajibBulananRupiah: 1900000,
        dasarPengeluaranWajib: 'rata-rata 3 bulan terakhir',
        danaDaruratTerkumpul: 2850000,
      );

      const ekspetasi =
          'Pengeluaran wajibmu sekitar Rp1.900.000 per bulan (rata-rata 3 bulan terakhir). '
          'Dana darurat yang terkumpul saat ini: Rp2.850.000. '
          'Biaya kesehatan mendadak atau risiko besar bisa jauh melampaui dana darurat, sehingga proteksi dasar membantu melindungi rencana keuanganmu. '
          'Ini gambaran umum, bukan rekomendasi produk.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanProteksiDasarMisi(
        pengeluaranWajibBulananRupiah: 1900000,
        dasarPengeluaranWajib: 'rata-rata 3 bulan terakhir',
        danaDaruratTerkumpul: 2850000,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V2: W = 1.500.000 (bulan ini), dana = 0', () {
      final hasil = formatRingkasanProteksiDasar(
        pengeluaranWajibBulananRupiah: 1500000,
        dasarPengeluaranWajib: 'bulan ini',
        danaDaruratTerkumpul: 0,
      );

      const ekspetasi =
          'Pengeluaran wajibmu sekitar Rp1.500.000 per bulan (bulan ini). '
          'Dana darurat yang terkumpul saat ini: Rp0. '
          'Biaya kesehatan mendadak atau risiko besar bisa jauh melampaui dana darurat, sehingga proteksi dasar membantu melindungi rencana keuanganmu. '
          'Ini gambaran umum, bukan rekomendasi produk.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanProteksiDasarMisi(
        pengeluaranWajibBulananRupiah: 1500000,
        dasarPengeluaranWajib: 'bulan ini',
        danaDaruratTerkumpul: 0,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V3: W belum ada (0)', () {
      final hasil = formatRingkasanProteksiDasar(
        pengeluaranWajibBulananRupiah: 0,
        dasarPengeluaranWajib: 'belum ada',
        danaDaruratTerkumpul: 500000,
      );

      const ekspetasi =
          'Belum ada catatan pengeluaran kebutuhan untuk melihat gambaran beban wajibmu. '
          'Catat dulu pengeluaran kebutuhanmu agar gambarannya lebih jelas. '
          'Ini gambaran umum, bukan rekomendasi produk.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanProteksiDasarMisi(
        pengeluaranWajibBulananRupiah: 0,
        dasarPengeluaranWajib: 'belum ada',
        danaDaruratTerkumpul: 500000,
      );
      expect(hasilMisi, equals(ekspetasi));
    });
  });
}
