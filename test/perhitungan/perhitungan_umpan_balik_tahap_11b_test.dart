import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 11B - proyeksi_kebebasan_finansial', () {
    test(
      'V1: W = 4.000.000 (rata-rata 3 bulan terakhir), kekayaan bersih = 300.000.000',
      () {
        final hasil = formatProyeksiKebebasanFinansial(
          pengeluaranWajibBulananRupiah: 4000000,
          dasarPengeluaranWajib: 'rata-rata 3 bulan terakhir',
          kekayaanBersihRupiah: 300000000,
        );

        const ekspetasi =
            'Dengan pengeluaran wajib sekitar Rp4.000.000 per bulan (rata-rata 3 bulan terakhir) '
            'atau Rp48.000.000 per tahun, patokan awal 25 kali pengeluaran tahunan '
            'berada di sekitar Rp1.200.000.000. '
            'Kekayaan bersihmu saat ini Rp300.000.000 (sekitar 25 persen dari patokan tersebut). '
            'Ini simulasi aturan praktis, bukan jaminan hasil.';

        expect(hasil, equals(ekspetasi));

        // Verifikasi via RegistriMisi
        final hasilMisi = RegistriMisi.formatProyeksiKebebasanFinansialMisi(
          pengeluaranWajibBulananRupiah: 4000000,
          dasarPengeluaranWajib: 'rata-rata 3 bulan terakhir',
          kekayaanBersihRupiah: 300000000,
        );
        expect(hasilMisi, equals(ekspetasi));
      },
    );

    test(
      'V2: W = 3.000.000 (bulan ini), kekayaan bersih <= 0 (misal -5.000.000 atau Rp0)',
      () {
        // Kasus A: Negatif (-5.000.000)
        final hasilNegatif = formatProyeksiKebebasanFinansial(
          pengeluaranWajibBulananRupiah: 3000000,
          dasarPengeluaranWajib: 'bulan ini',
          kekayaanBersihRupiah: -5000000,
        );

        const ekspetasiNegatif =
            'Dengan pengeluaran wajib sekitar Rp3.000.000 per bulan (bulan ini) '
            'atau Rp36.000.000 per tahun, patokan awal 25 kali pengeluaran tahunan '
            'berada di sekitar Rp900.000.000. '
            'Kekayaan bersihmu saat ini belum positif (−Rp5.000.000), '
            'jadi fokus utama yang paling menenangkan adalah merapikan utang dan '
            'membangun tabungan bertahap. '
            'Ini simulasi aturan praktis, bukan jaminan hasil.';

        expect(hasilNegatif, equals(ekspetasiNegatif));

        // Kasus B: Nol (Rp0)
        final hasilNol = formatProyeksiKebebasanFinansial(
          pengeluaranWajibBulananRupiah: 3000000,
          dasarPengeluaranWajib: 'bulan ini',
          kekayaanBersihRupiah: 0,
        );

        const ekspetasiNol =
            'Dengan pengeluaran wajib sekitar Rp3.000.000 per bulan (bulan ini) '
            'atau Rp36.000.000 per tahun, patokan awal 25 kali pengeluaran tahunan '
            'berada di sekitar Rp900.000.000. '
            'Kekayaan bersihmu saat ini belum positif (Rp0), '
            'jadi fokus utama yang paling menenangkan adalah merapikan utang dan '
            'membangun tabungan bertahap. '
            'Ini simulasi aturan praktis, bukan jaminan hasil.';

        expect(hasilNol, equals(ekspetasiNol));
      },
    );

    test('V3: W <= 0 (belum ada catatan kebutuhan)', () {
      final hasilNol = formatProyeksiKebebasanFinansial(
        pengeluaranWajibBulananRupiah: 0,
        dasarPengeluaranWajib: 'bulan ini',
        kekayaanBersihRupiah: 10000000,
      );

      const ekspetasi =
          'Belum ada catatan pengeluaran kebutuhan untuk menghitung gambaran '
          'dana pensiunmu. Catat pengeluaran kebutuhanmu dulu agar angkanya bisa '
          'dihitung. Ini simulasi aturan praktis, bukan jaminan hasil.';

      expect(hasilNol, equals(ekspetasi));
    });

    test(
      'Evaluasi Gerbang: periode_data transaksi minimal 6 bulan_berbeda (Modul 15)',
      () {
        final syarat = SyaratGerbangData(
          tipe: 'periode_data',
          objek: 'transaksi',
          satuan: 'bulan_berbeda',
          min: 6,
          pesan: 'Catat pemasukanmu minimal di 6 bulan berbeda.',
        );

        // Kurang dari 6 bulan (misal 5 bulan)
        final foto5Bulan = FotoDataPengguna.kosong().copyWith(
          bulanTransaksiBerbeda: 5,
        );
        final hasil5Bulan = evaluasiSyarat(syarat, foto5Bulan);
        expect(hasil5Bulan.terpenuhi, isFalse);

        // Tepat 6 bulan
        final foto6Bulan = FotoDataPengguna.kosong().copyWith(
          bulanTransaksiBerbeda: 6,
        );
        final hasil6Bulan = evaluasiSyarat(syarat, foto6Bulan);
        expect(hasil6Bulan.terpenuhi, isTrue);

        // Lebih dari 6 bulan (misal 7 bulan)
        final foto7Bulan = FotoDataPengguna.kosong().copyWith(
          bulanTransaksiBerbeda: 7,
        );
        final hasil7Bulan = evaluasiSyarat(syarat, foto7Bulan);
        expect(hasil7Bulan.terpenuhi, isTrue);
      },
    );

    test('Konstanta pengaliAturanPraktisPensiun tepat 25', () {
      expect(pengaliAturanPraktisPensiun, equals(25));
    });
  });
}
