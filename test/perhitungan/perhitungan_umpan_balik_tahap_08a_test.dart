import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Pengujian Fungsi Murni Umpan Balik Tahap 8A', () {
    group('1. formatBulanDesimal', () {
      test('x <= 0 menghasilkan "0"', () {
        expect(formatBulanDesimal(0), equals('0'));
        expect(formatBulanDesimal(-10), equals('0'));
      });

      test('kelipatan 10 bulat menghasilkan angka tanpa koma', () {
        expect(formatBulanDesimal(10), equals('1'));
        expect(formatBulanDesimal(20), equals('2'));
        expect(formatBulanDesimal(30), equals('3'));
        expect(formatBulanDesimal(60), equals('6'));
      });

      test('angka dengan desimal menghasilkan koma Indonesia', () {
        expect(formatBulanDesimal(15), equals('1,5'));
        expect(formatBulanDesimal(24), equals('2,4'));
        expect(formatBulanDesimal(5), equals('0,5'));
        expect(formatBulanDesimal(38), equals('3,8'));
      });
    });

    group('2. hitungEstimasiBulan', () {
      test('sisa <= 0 menghasilkan 0', () {
        expect(hitungEstimasiBulan(0, 500000), equals(0));
        expect(hitungEstimasiBulan(-100000, 500000), equals(0));
      });

      test('setoran <= 0 menghasilkan null', () {
        expect(hitungEstimasiBulan(1000000, 0), isNull);
        expect(hitungEstimasiBulan(1000000, -50000), isNull);
      });

      test('vektor materi lampiran (pembulatan ke atas / integer ceiling)', () {
        // Rp3.000.000 / Rp250.000 = 12 bulan tepat
        expect(hitungEstimasiBulan(3000000, 250000), equals(12));
        // Rp3.000.000 / Rp300.000 = 10 bulan tepat
        expect(hitungEstimasiBulan(3000000, 300000), equals(10));
        // Rp4.000.000 / Rp400.000 = 10 bulan
        expect(hitungEstimasiBulan(4000000, 400000), equals(10));
        // Rp4.000.000 / Rp450.000 = 8.88... -> 9 bulan
        expect(hitungEstimasiBulan(4000000, 450000), equals(9));
        // Rp1.000.000 / Rp300.000 = 3.33... -> 4 bulan
        expect(hitungEstimasiBulan(1000000, 300000), equals(4));
        // Rp2.500.000 / Rp500.000 = 5 bulan
        expect(hitungEstimasiBulan(2500000, 500000), equals(5));
      });
    });

    group('3. hitungRataRataSetoranTabungan', () {
      final now = DateTime(2026, 11, 15);

      test('daftar kosong menghasilkan 0', () {
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: [], waktuSekarang: now),
          equals(0),
        );
      });

      test('hanya ada alokasi di luar jendela 3 bulan menghasilkan 0', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 1000000,
            waktu: DateTime(2026, 7, 10), // > 3 bulan
          ),
        ];
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(0),
        );
      });

      test('alokasi hanya bulan berjalan (bulanAktif = 1)', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 300000,
            waktu: DateTime(2026, 11, 2),
          ),
          EntitasAlokasiSimpel(
            jenis: 'ambil',
            jumlahRupiah: 50000,
            waktu: DateTime(2026, 11, 5),
          ),
        ];
        // net = 250000 ~/ 1 = 250000
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(250000),
        );
      });

      test('alokasi dari M-1 dan M (bulanAktif = 2)', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 400000,
            waktu: DateTime(2026, 10, 15),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 600000,
            waktu: DateTime(2026, 11, 10),
          ),
        ];
        // net = 1000000 ~/ 2 = 500000
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(500000),
        );
      });

      test('alokasi dari M-2, M-1, dan M (bulanAktif = 3)', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 300000,
            waktu: DateTime(2026, 9, 20),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 300000,
            waktu: DateTime(2026, 10, 20),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 300000,
            waktu: DateTime(2026, 11, 1),
          ),
        ];
        // net = 900000 ~/ 3 = 300000
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(300000),
        );
      });

      test('net <= 0 menghasilkan 0', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'ambil',
            jumlahRupiah: 500000,
            waktu: DateTime(2026, 11, 5),
          ),
        ];
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(0),
        );
      });
    });

    group('4. hitungPengeluaranWajibBulanan', () {
      final now = DateTime(2026, 11, 15);

      test('data kosong menghasilkan belumAda', () {
        final hasil = hitungPengeluaranWajibBulanan(
          daftarPengeluaran: [],
          waktuSekarang: now,
        );
        expect(hasil.dasar, equals(DasarPengeluaranWajib.belumAda));
        expect(hasil.total, equals(0));
        expect(hasil.bagianKebutuhan, equals(0));
        expect(hasil.bagianUtang, equals(0));
        expect(hasil.jumlahBulan, equals(0));
      });

      test('pengeluaran hanya bulan berjalan (M) menghasilkan dasar bulanBerjalan', () {
        final daftar = [
          ItemPengeluaranWajib(
            jumlahRupiah: 1500000,
            sifat: 'kebutuhan',
            waktu: DateTime(2026, 11, 2),
          ),
          ItemPengeluaranWajib(
            jumlahRupiah: 200000,
            sifat: 'utang',
            waktu: DateTime(2026, 11, 5),
          ),
          ItemPengeluaranWajib(
            jumlahRupiah: 300000,
            sifat: 'keinginan', // diabaikan
            waktu: DateTime(2026, 11, 6),
          ),
        ];
        final hasil = hitungPengeluaranWajibBulanan(
          daftarPengeluaran: daftar,
          waktuSekarang: now,
        );
        expect(hasil.dasar, equals(DasarPengeluaranWajib.bulanBerjalan));
        expect(hasil.total, equals(1700000));
        expect(hasil.bagianKebutuhan, equals(1500000));
        expect(hasil.bagianUtang, equals(200000));
        expect(hasil.jumlahBulan, equals(1));
      });

      test('pengeluaran 3 bulan kalender selesai (M-1, M-2) menghasilkan tigaBulanTerakhir', () {
        final daftar = [
          // M-1 (Oktober 2026): kebutuhan 1.800.000, utang 200.000
          ItemPengeluaranWajib(
            jumlahRupiah: 1800000,
            sifat: 'kebutuhan',
            waktu: DateTime(2026, 10, 5),
          ),
          ItemPengeluaranWajib(
            jumlahRupiah: 200000,
            sifat: 'utang',
            waktu: DateTime(2026, 10, 10),
          ),
          // M-2 (September 2026): kebutuhan 1.600.000, utang 200.000
          ItemPengeluaranWajib(
            jumlahRupiah: 1600000,
            sifat: 'kebutuhan',
            waktu: DateTime(2026, 9, 12),
          ),
          ItemPengeluaranWajib(
            jumlahRupiah: 200000,
            sifat: 'utang',
            waktu: DateTime(2026, 9, 25),
          ),
        ];
        final hasil = hitungPengeluaranWajibBulanan(
          daftarPengeluaran: daftar,
          waktuSekarang: now,
        );
        expect(hasil.dasar, equals(DasarPengeluaranWajib.tigaBulanTerakhir));
        // total = (2000000 + 1800000) ~/ 2 = 1900000
        expect(hasil.total, equals(1900000));
        // keb = (1800000 + 1600000) ~/ 2 = 1700000
        expect(hasil.bagianKebutuhan, equals(1700000));
        // utang = 1900000 - 1700000 = 200000
        expect(hasil.bagianUtang, equals(200000));
        expect(hasil.jumlahBulan, equals(2));
      });
    });

    group('5. formatRingkasanTujuanTabungan', () {
      final now = DateTime(2026, 11, 15);

      test('tujuan null', () {
        expect(
          formatRingkasanTujuanTabungan(tujuan: null, waktuSekarang: now),
          equals('Belum ada tujuan tabungan.'),
        );
      });

      test('tujuan dengan target belum tercapai dan bertenggat', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop untuk skripsi',
          danaTerkumpul: 1000000,
          targetRupiah: 6000000,
          tenggat: DateTime(2027, 9, 15), // 10 bulan ke depan
          dibuatPada: DateTime(2026, 11, 1),
        );
        // sisa = 5.000.000, bulanTersisa = 10 -> setoran = 500.000
        final teks = formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now);
        expect(teks, contains('Tujuan tabunganmu: Laptop untuk skripsi.'));
        expect(teks, contains('Dana terkumpul: Rp1.000.000 dari Rp6.000.000 (16 persen).'));
        expect(teks, contains('kamu perlu menyisihkan sekitar Rp500.000 per bulan.'));
      });

      test('tujuan tanpa tenggat', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Beli Sepeda',
          danaTerkumpul: 500000,
          targetRupiah: 2000000,
          tenggat: null,
          dibuatPada: DateTime(2026, 11, 1),
        );
        final teks = formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now);
        expect(teks, contains('Belum ada tenggat.'));
        expect(teks, contains('Menambahkan tenggat membantu menghitung berapa yang perlu disisihkan tiap bulan.'));
      });

      test('tujuan sudah tercapai (dana >= target)', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Dana Kursus',
          danaTerkumpul: 3000000,
          targetRupiah: 3000000,
          tenggat: DateTime(2026, 12, 1),
          dibuatPada: DateTime(2026, 10, 1),
        );
        final teks = formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now);
        expect(teks, contains('Targetmu sudah tercapai.'));
      });
    });

    group('6. formatEstimasiTabungan', () {
      test('tujuan null', () {
        expect(
          formatEstimasiTabungan(tujuan: null, setoranRataRata: 200000),
          equals('Belum ada tujuan tabungan.'),
        );
      });

      test('target sudah tercapai', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Beli HP',
          danaTerkumpul: 5000000,
          targetRupiah: 5000000,
          dibuatPada: DateTime(2026, 1, 1),
        );
        expect(
          formatEstimasiTabungan(tujuan: t, setoranRataRata: 500000),
          equals('Targetmu sudah tercapai.'),
        );
      });

      test('belum ada setoran (setoran <= 0)', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Beli HP',
          danaTerkumpul: 0,
          targetRupiah: 3000000,
          dibuatPada: DateTime(2026, 1, 1),
        );
        final teks = formatEstimasiTabungan(tujuan: t, setoranRataRata: 0);
        expect(teks, contains('Sisa yang perlu dikumpulkan untuk Beli HP: Rp3.000.000.'));
        expect(teks, contains('Belum ada setoran yang tercatat'));
      });

      test('ada setoran dan penambahan Rp50.000 mempercepat bulan', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Target Skripsi',
          danaTerkumpul: 0,
          targetRupiah: 3000000,
          dibuatPada: DateTime(2026, 1, 1),
        );
        // sisa = 3.000.000, setoran = 250.000 (12 bulan). Tambah 50.000 -> 300.000 (10 bulan). Hemat 2 bulan.
        final teks = formatEstimasiTabungan(tujuan: t, setoranRataRata: 250000);
        expect(teks, contains('Sisa yang perlu dikumpulkan untuk Target Skripsi: Rp3.000.000.'));
        expect(teks, contains('targetmu tercapai sekitar 12 bulan lagi.'));
        expect(teks, contains('jadinya sekitar 10 bulan lagi, 2 bulan lebih cepat.'));
      });
    });

    group('7. formatTeksPengeluaranWajibBulanan', () {
      test('dasar belumAda', () {
        const hasil = HasilPengeluaranWajib(
          total: 0,
          bagianKebutuhan: 0,
          bagianUtang: 0,
          jumlahBulan: 0,
          dasar: DasarPengeluaranWajib.belumAda,
        );
        expect(
          formatTeksPengeluaranWajibBulanan(hasil),
          equals('Belum ada pengeluaran kebutuhan yang bisa dihitung. Catat dulu beberapa pengeluaran kebutuhan.'),
        );
      });

      test('dasar bulanBerjalan tanpa utang', () {
        const hasil = HasilPengeluaranWajib(
          total: 1500000,
          bagianKebutuhan: 1500000,
          bagianUtang: 0,
          jumlahBulan: 1,
          dasar: DasarPengeluaranWajib.bulanBerjalan,
        );
        final teks = formatTeksPengeluaranWajibBulanan(hasil);
        expect(teks, equals('Pengeluaran wajibmu bulan ini sejauh ini Rp1.500.000 (belum satu bulan penuh). Rinciannya: kebutuhan Rp1.500.000.'));
      });

      test('dasar tigaBulanTerakhir dengan cicilan dan utang', () {
        const hasil = HasilPengeluaranWajib(
          total: 1900000,
          bagianKebutuhan: 1700000,
          bagianUtang: 200000,
          jumlahBulan: 3,
          dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
        );
        final teks = formatTeksPengeluaranWajibBulanan(hasil);
        expect(teks, equals('Pengeluaran wajibmu rata-rata Rp1.900.000 per bulan (dari 3 bulan terakhir). Rinciannya: kebutuhan Rp1.700.000, cicilan dan utang Rp200.000.'));
      });
    });

    group('8. formatTargetDanaDarurat', () {
      test('pengeluaran wajib <= 0 menghasilkan pesan peringatan', () {
        const hasil = HasilPengeluaranWajib(
          total: 0,
          bagianKebutuhan: 0,
          bagianUtang: 0,
          jumlahBulan: 0,
          dasar: DasarPengeluaranWajib.belumAda,
        );
        expect(
          formatTargetDanaDarurat(pengeluaranWajib: hasil),
          equals('Catat dulu pengeluaran kebutuhanmu agar target bisa dihitung.'),
        );
      });

      test('vektor materi: pengeluaran wajib Rp1.900.000 (3x = 5.700.000, 6x = 11.400.000)', () {
        const hasil = HasilPengeluaranWajib(
          total: 1900000,
          bagianKebutuhan: 1700000,
          bagianUtang: 200000,
          jumlahBulan: 3,
          dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
        );
        final teks = formatTargetDanaDarurat(pengeluaranWajib: hasil);
        expect(teks, equals(
          'Dengan pengeluaran wajib sekitar Rp1.900.000 per bulan, sebagai aturan praktis dana darurat berada di kisaran 3 sampai 6 kali itu: Rp5.700.000 sampai Rp11.400.000. Titik awal yang masuk akal: Rp5.700.000. Sesuaikan dengan kondisimu.',
        ));
      });

      test('bulan berjalan menambahkan kalimat peringatan perkiraan awal', () {
        const hasil = HasilPengeluaranWajib(
          total: 2000000,
          bagianKebutuhan: 2000000,
          bagianUtang: 0,
          jumlahBulan: 1,
          dasar: DasarPengeluaranWajib.bulanBerjalan,
        );
        final teks = formatTargetDanaDarurat(pengeluaranWajib: hasil);
        expect(teks, contains('Angka ini masih perkiraan awal karena datamu baru bulan ini.'));
      });
    });

    group('9. formatProgresDanaDarurat', () {
      test('tujuan null', () {
        expect(
          formatProgresDanaDarurat(tujuan: null, pengeluaranWajibPerBulan: 1900000),
          equals('Belum ada tujuan dana darurat.'),
        );
      });

      test('vektor materi: dana darurat Rp3.800.000 dari target Rp5.700.000, wajib Rp1.900.000 (setara 2 bulan)', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 3800000,
          targetRupiah: 5700000,
        );
        final teks = formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: 1900000);
        expect(teks, equals('Dana daruratmu: Rp3.800.000 dari target Rp5.700.000 (66 persen). Itu setara sekitar 2 bulan pengeluaran wajibmu.'));
      });

      test('dana darurat Rp2.850.000, wajib Rp1.900.000 (setara 1,5 bulan desimal)', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 2850000,
          targetRupiah: 5700000,
        );
        final teks = formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: 1900000);
        expect(teks, contains('Itu setara sekitar 1,5 bulan pengeluaran wajibmu.'));
      });

      test('target tercapai menambahkan kalimat penutup target tercapai', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 5700000,
          targetRupiah: 5700000,
        );
        final teks = formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: 1900000);
        expect(teks, contains('Targetmu sudah tercapai.'));
      });
    });
  });
}
