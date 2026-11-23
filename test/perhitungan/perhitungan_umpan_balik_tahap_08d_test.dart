import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 8D - ringkasan_langganan_dan_keinginan', () {
    test('V1: 2 bulanan (50rb, 100rb) + 1 tahunan (240rb -> 20rb/bln), keinginan 350rb', () {
      final daftar = [
        const ItemLanggananUmpanBalik(
          nama: 'Musik',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 50000,
        ),
        const ItemLanggananUmpanBalik(
          nama: 'Film',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 100000,
        ),
        const ItemLanggananUmpanBalik(
          nama: 'Penyimpanan Awan',
          jenis: 'langganan',
          frekuensi: 'tahunan',
          jumlahPerkiraanRupiah: 240000,
        ),
      ];

      final hasil = formatRingkasanLanggananDanKeinginan(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 350000,
      );

      const ekspetasi =
          'Kamu punya 3 langganan aktif dengan perkiraan sekitar Rp170.000 per bulan. '
          'Pengeluaran keinginanmu bulan ini tercatat Rp350.000. '
          'Ini gambaran untuk kamu kenali, bukan penilaian.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanLanggananDanKeinginanMisi(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 350000,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V2: 1 mingguan (25rb -> 100rb/bln) + 1 tanpa perkiraan, keinginan 0', () {
      final daftar = [
        const ItemLanggananUmpanBalik(
          nama: 'Kebugaran',
          jenis: 'langganan',
          frekuensi: 'mingguan',
          jumlahPerkiraanRupiah: 25000,
        ),
        const ItemLanggananUmpanBalik(
          nama: 'Aplikasi Desain',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: null,
        ),
      ];

      final hasil = formatRingkasanLanggananDanKeinginan(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 0,
      );

      const ekspetasi =
          'Kamu punya 1 langganan aktif dengan perkiraan sekitar Rp100.000 per bulan. '
          '(1 langganan belum ada perkiraan.) '
          'Belum ada pengeluaran keinginan yang tercatat bulan ini. '
          'Ini gambaran untuk kamu kenali, bukan penilaian.';

      expect(hasil, equals(ekspetasi));
    });

    test('V3: 2 langganan tanpa perkiraan, keinginan 200rb', () {
      final daftar = [
        const ItemLanggananUmpanBalik(
          nama: 'Layanan A',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: null,
        ),
        const ItemLanggananUmpanBalik(
          nama: 'Layanan B',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 0,
        ),
      ];

      final hasil = formatRingkasanLanggananDanKeinginan(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 200000,
      );

      const ekspetasi =
          'Kamu punya 2 langganan aktif yang belum diisi perkiraan biayanya. '
          'Pengeluaran keinginanmu bulan ini tercatat Rp200.000. '
          'Ini gambaran untuk kamu kenali, bukan penilaian.';

      expect(hasil, equals(ekspetasi));
    });

    test('V4: 0 langganan, 0 keinginan', () {
      final daftar = <ItemLanggananUmpanBalik>[];

      final hasil = formatRingkasanLanggananDanKeinginan(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 0,
      );

      const ekspetasi =
          'Belum ada langganan aktif yang tercatat di menu Tagihan. '
          'Belum ada pengeluaran keinginan yang tercatat bulan ini. '
          'Ini gambaran untuk kamu kenali, bukan penilaian.';

      expect(hasil, equals(ekspetasi));
    });

    test('V5: tagihan berjenis tagihan dan langganan tidak aktif/diarsipkan tidak dihitung', () {
      final daftar = [
        // Jenis tagihan bukan langganan
        const ItemLanggananUmpanBalik(
          nama: 'Listrik PLN',
          jenis: 'tagihan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 250000,
          aktif: true,
          diarsipkan: false,
        ),
        const ItemLanggananUmpanBalik(
          nama: 'Air PDAM',
          jenis: 'tagihan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 80000,
          aktif: true,
          diarsipkan: false,
        ),
        // Langganan tidak aktif
        const ItemLanggananUmpanBalik(
          nama: 'Koran Online',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 50000,
          aktif: false,
          diarsipkan: false,
        ),
        // Langganan diarsipkan
        const ItemLanggananUmpanBalik(
          nama: 'Gym Lama',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: 300000,
          aktif: true,
          diarsipkan: true,
        ),
      ];

      final hasil = formatRingkasanLanggananDanKeinginan(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 0,
      );

      const ekspetasi =
          'Belum ada langganan aktif yang tercatat di menu Tagihan. '
          'Belum ada pengeluaran keinginan yang tercatat bulan ini. '
          'Ini gambaran untuk kamu kenali, bukan penilaian.';

      expect(hasil, equals(ekspetasi));

      // Jika ada pengeluaran keinginan
      final hasilDenganKeinginan = formatRingkasanLanggananDanKeinginan(
        daftarTagihan: daftar,
        totalKeinginanBulanIniRupiah: 150000,
      );

      const ekspetasiDenganKeinginan =
          'Belum ada langganan aktif yang tercatat di menu Tagihan. '
          'Pengeluaran keinginanmu bulan ini tercatat Rp150.000. '
          'Ini gambaran untuk kamu kenali, bukan penilaian.';

      expect(hasilDenganKeinginan, equals(ekspetasiDenganKeinginan));
    });
  });
}
