import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Pengujian Fungsi Murni Umpan Balik Tahap 8A', () {
    group('1. formatBulanDesimal & pemotongan integer murni (tanpa double)', () {
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

      test('vektor uji pemotongan integer murni (dana * 10 ~/ W)', () {
        // dana 3.724.000, W 1.900.000 -> (3.724.000 * 10) ~/ 1.900.000 = 19 -> "1,9" (bukan "2")
        final x1 = (3724000 * 10) ~/ 1900000;
        expect(formatBulanDesimal(x1), equals('1,9'));

        // dana 5.700.000, W 1.900.000 -> (5.700.000 * 10) ~/ 1.900.000 = 30 -> "3"
        final x2 = (5700000 * 10) ~/ 1900000;
        expect(formatBulanDesimal(x2), equals('3'));

        // dana 0, W 1.900.000 -> 0 -> "0"
        final x3 = (0 * 10) ~/ 1900000;
        expect(formatBulanDesimal(x3), equals('0'));
      });
    });

    group('2. hitungEstimasiBulan (pembulatan ceiling integer & pembedaan null vs 0)', () {
      test('sisa <= 0 menghasilkan 0', () {
        expect(hitungEstimasiBulan(0, 500000), equals(0));
        expect(hitungEstimasiBulan(-100000, 500000), equals(0));
      });

      test('setoran <= 0 menghasilkan null (tidak ada hasil, dibedakan dari 0 bulan)', () {
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

    group('3. hitungRataRataSetoranTabungan (vektor lengkap prompt Tahap 8A)', () {
      final now = DateTime(2026, 11, 15);

      test('daftar kosong menghasilkan 0', () {
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: [], waktuSekarang: now),
          equals(0),
        );
      });

      test('isi 300.000 hanya bulan ini -> 300.000', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 300000,
            waktu: DateTime(2026, 11, 2),
          ),
        ];
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(300000),
        );
      });

      test('isi 200.000 bulan lalu + 400.000 bulan ini -> 300.000 (600.000 / 2)', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 200000,
            waktu: DateTime(2026, 10, 15),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 400000,
            waktu: DateTime(2026, 11, 10),
          ),
        ];
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(300000),
        );
      });

      test('isi 100.000 dua bulan lalu, tidak ada bulan lalu, 200.000 bulan ini -> 100.000 (300.000 / 3)', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 100000,
            waktu: DateTime(2026, 9, 20),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 200000,
            waktu: DateTime(2026, 11, 5),
          ),
        ];
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(100000),
        );
      });

      test('ada ambil -> dikurangkan', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 500000,
            waktu: DateTime(2026, 11, 2),
          ),
          EntitasAlokasiSimpel(
            jenis: 'ambil',
            jumlahRupiah: 200000,
            waktu: DateTime(2026, 11, 10),
          ),
        ];
        // net = 300.000 ~/ 1 = 300.000
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(300000),
        );
      });

      test('total <= 0 -> 0', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 200000,
            waktu: DateTime(2026, 11, 2),
          ),
          EntitasAlokasiSimpel(
            jenis: 'ambil',
            jumlahRupiah: 300000,
            waktu: DateTime(2026, 11, 5),
          ),
        ];
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(0),
        );
      });

      test('pergantian tahun (misal Januari 2027: alokasi di November dan Desember 2026)', () {
        final janNow = DateTime(2027, 1, 15);
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 150000,
            waktu: DateTime(2026, 11, 20),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 150000,
            waktu: DateTime(2026, 12, 10),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 300000,
            waktu: DateTime(2027, 1, 5),
          ),
        ];
        // Jarak tertua = November (jarak 2 -> bulanAktif = 3), net = 600.000 ~/ 3 = 200.000
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: janNow),
          equals(200000),
        );
      });

      test('alokasi 23:30 WIB di hari terakhir bulan', () {
        final alokasi = [
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 400000,
            waktu: DateTime(2026, 10, 31, 23, 30),
          ),
          EntitasAlokasiSimpel(
            jenis: 'isi',
            jumlahRupiah: 200000,
            waktu: DateTime(2026, 11, 1, 8, 0),
          ),
        ];
        // Oktober dan November -> bulanAktif = 2, total = 600.000 ~/ 2 = 300.000
        expect(
          hitungRataRataSetoranTabungan(daftarAlokasi: alokasi, waktuSekarang: now),
          equals(300000),
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

      test('vektor 3 bulan lalu kebutuhan/utang 1.700.000/200.000, 1.600.000/200.000, 1.800.000/200.000', () {
        final daftar = [
          // M-1 (Oktober 2026)
          ItemPengeluaranWajib(
            jumlahRupiah: 1700000,
            sifat: 'kebutuhan',
            waktu: DateTime(2026, 10, 5),
          ),
          ItemPengeluaranWajib(
            jumlahRupiah: 200000,
            sifat: 'utang',
            waktu: DateTime(2026, 10, 10),
          ),
          // M-2 (September 2026)
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
          // M-3 (Agustus 2026)
          ItemPengeluaranWajib(
            jumlahRupiah: 1800000,
            sifat: 'kebutuhan',
            waktu: DateTime(2026, 8, 14),
          ),
          ItemPengeluaranWajib(
            jumlahRupiah: 200000,
            sifat: 'utang',
            waktu: DateTime(2026, 8, 20),
          ),
        ];
        final hasil = hitungPengeluaranWajibBulanan(
          daftarPengeluaran: daftar,
          waktuSekarang: now,
        );
        expect(hasil.dasar, equals(DasarPengeluaranWajib.tigaBulanTerakhir));
        // total: 1900000 + 1800000 + 2000000 = 5700000 ~/ 3 = 1900000
        expect(hasil.total, equals(1900000));
        // keb: 1700000 + 1600000 + 1800000 = 5100000 ~/ 3 = 1700000
        expect(hasil.bagianKebutuhan, equals(1700000));
        // utang: 1900000 - 1700000 = 200000
        expect(hasil.bagianUtang, equals(200000));
        expect(hasil.jumlahBulan, equals(3));
      });
    });

    group('5. formatRingkasanTujuanTabungan (assertion pada STRING LENGKAP)', () {
      final now = DateTime(2026, 11, 15);

      test('tanpa tujuan: "Belum ada tujuan tabungan."', () {
        expect(
          formatRingkasanTujuanTabungan(tujuan: null, waktuSekarang: now),
          equals('Belum ada tujuan tabungan.'),
        );
      });

      test('Laptop Skripsi target 6.000.000, dana 0, tenggat 12 bulan lagi', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 0,
          targetRupiah: 6000000,
          tenggat: DateTime(2027, 11, 15), // 12 bulan
          dibuatPada: DateTime(2026, 11, 1),
        );
        expect(
          formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now),
          equals('Tujuan tabunganmu: Laptop Skripsi. Dana terkumpul: Rp0 dari Rp6.000.000 (0 persen). Untuk sampai di target sebelum tenggat, kamu perlu menyisihkan sekitar Rp500.000 per bulan.'),
        );
      });

      test('target 5.000.000, dana 1.000.000, tenggat 8 bulan lagi', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 1000000,
          targetRupiah: 5000000,
          tenggat: DateTime(2027, 7, 15), // 8 bulan
          dibuatPada: DateTime(2026, 11, 1),
        );
        expect(
          formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now),
          equals('Tujuan tabunganmu: Laptop Skripsi. Dana terkumpul: Rp1.000.000 dari Rp5.000.000 (20 persen). Untuk sampai di target sebelum tenggat, kamu perlu menyisihkan sekitar Rp500.000 per bulan.'),
        );
      });

      test('tanpa tenggat dan sisa > 0', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 1000000,
          targetRupiah: 5000000,
          tenggat: null,
          dibuatPada: DateTime(2026, 11, 1),
        );
        expect(
          formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now),
          equals('Tujuan tabunganmu: Laptop Skripsi. Dana terkumpul: Rp1.000.000 dari Rp5.000.000 (20 persen). Belum ada tenggat. Menambahkan tenggat membantu menghitung berapa yang perlu disisihkan tiap bulan.'),
        );
      });

      test('sudah tercapai (dana >= target)', () {
        final t = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 5000000,
          targetRupiah: 5000000,
          tenggat: DateTime(2027, 11, 15),
          dibuatPada: DateTime(2026, 11, 1),
        );
        expect(
          formatRingkasanTujuanTabungan(tujuan: t, waktuSekarang: now),
          equals('Tujuan tabunganmu: Laptop Skripsi. Dana terkumpul: Rp5.000.000 dari Rp5.000.000 (100 persen). Targetmu sudah tercapai.'),
        );
      });
    });

    group('6. formatEstimasiTabungan (assertion pada STRING LENGKAP)', () {
      final t = DataTujuanTabunganUmpanBalik(
        nama: 'Laptop Skripsi',
        danaTerkumpul: 3000000,
        targetRupiah: 6000000, // sisa 3.000.000
        dibuatPada: DateTime(2026, 1, 1),
      );

      test('tanpa tujuan: "Belum ada tujuan tabungan."', () {
        expect(
          formatEstimasiTabungan(tujuan: null, setoranRataRata: 250000),
          equals('Belum ada tujuan tabungan.'),
        );
      });

      test('sisa 0: "Targetmu sudah tercapai."', () {
        final tSelesai = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 6000000,
          targetRupiah: 6000000,
          dibuatPada: DateTime(2026, 1, 1),
        );
        expect(
          formatEstimasiTabungan(tujuan: tSelesai, setoranRataRata: 250000),
          equals('Targetmu sudah tercapai.'),
        );
      });

      test('setoran 0: memakai kalimat "Belum ada setoran yang tercatat, ..."', () {
        expect(
          formatEstimasiTabungan(tujuan: t, setoranRataRata: 0),
          equals('Sisa yang perlu dikumpulkan untuk Laptop Skripsi: Rp3.000.000. Belum ada setoran yang tercatat, jadi waktu tercapainya belum bisa dihitung. Mulai dari nominal kecil yang masuk akal untukmu.'),
        );
      });

      test('sisa 3.000.000 setoran 250.000 -> n 12, n2 10 ("2 bulan lebih cepat")', () {
        expect(
          formatEstimasiTabungan(tujuan: t, setoranRataRata: 250000),
          equals('Sisa yang perlu dikumpulkan untuk Laptop Skripsi: Rp3.000.000. Dengan setoran sekitar Rp250.000 per bulan seperti sekarang, targetmu tercapai sekitar 12 bulan lagi. Kalau kamu menambah Rp50.000 per bulan, jadinya sekitar 10 bulan lagi, 2 bulan lebih cepat. Ini hitungan sederhana. Sesuaikan dengan kondisimu.'),
        );
      });

      test('sisa 4.000.000 setoran 400.000 -> 10 dan 9 ("1 bulan lebih cepat")', () {
        final t4 = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 2000000,
          targetRupiah: 6000000, // sisa 4.000.000
          dibuatPada: DateTime(2026, 1, 1),
        );
        expect(
          formatEstimasiTabungan(tujuan: t4, setoranRataRata: 400000),
          equals('Sisa yang perlu dikumpulkan untuk Laptop Skripsi: Rp4.000.000. Dengan setoran sekitar Rp400.000 per bulan seperti sekarang, targetmu tercapai sekitar 10 bulan lagi. Kalau kamu menambah Rp50.000 per bulan, jadinya sekitar 9 bulan lagi, 1 bulan lebih cepat. Ini hitungan sederhana. Sesuaikan dengan kondisimu.'),
        );
      });

      test('sisa 100.000 setoran 100.000 -> 1 dan 1 (kalimat "tetap")', () {
        final t1 = DataTujuanTabunganUmpanBalik(
          nama: 'Laptop Skripsi',
          danaTerkumpul: 5900000,
          targetRupiah: 6000000, // sisa 100.000
          dibuatPada: DateTime(2026, 1, 1),
        );
        expect(
          formatEstimasiTabungan(tujuan: t1, setoranRataRata: 100000),
          equals('Sisa yang perlu dikumpulkan untuk Laptop Skripsi: Rp100.000. Dengan setoran sekitar Rp100.000 per bulan seperti sekarang, targetmu tercapai sekitar 1 bulan lagi. Kalau kamu menambah Rp50.000 per bulan, waktunya tetap sekitar 1 bulan lagi. Ini hitungan sederhana. Sesuaikan dengan kondisimu.'),
        );
      });
    });

    group('7. formatTeksPengeluaranWajibBulanan (assertion pada STRING LENGKAP)', () {
      test('tanpa data (belumAda)', () {
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

      test('tiga bulan kalender terakhir: total 1.900.000, kebutuhan 1.700.000, utang 200.000', () {
        const hasil = HasilPengeluaranWajib(
          total: 1900000,
          bagianKebutuhan: 1700000,
          bagianUtang: 200000,
          jumlahBulan: 3,
          dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
        );
        expect(
          formatTeksPengeluaranWajibBulanan(hasil),
          equals('Pengeluaran wajibmu rata-rata Rp1.900.000 per bulan (dari 3 bulan terakhir). Rinciannya: kebutuhan Rp1.700.000, cicilan dan utang Rp200.000.'),
        );
      });

      test('dua bulan data (tanpa cicilan dan utang)', () {
        const hasil = HasilPengeluaranWajib(
          total: 1500000,
          bagianKebutuhan: 1500000,
          bagianUtang: 0,
          jumlahBulan: 2,
          dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
        );
        expect(
          formatTeksPengeluaranWajibBulanan(hasil),
          equals('Pengeluaran wajibmu rata-rata Rp1.500.000 per bulan (dari 2 bulan terakhir). Rinciannya: kebutuhan Rp1.500.000.'),
        );
      });

      test('hanya bulan berjalan kebutuhan 900.000', () {
        const hasil = HasilPengeluaranWajib(
          total: 900000,
          bagianKebutuhan: 900000,
          bagianUtang: 0,
          jumlahBulan: 1,
          dasar: DasarPengeluaranWajib.bulanBerjalan,
        );
        expect(
          formatTeksPengeluaranWajibBulanan(hasil),
          equals('Pengeluaran wajibmu bulan ini sejauh ini Rp900.000 (belum satu bulan penuh). Rinciannya: kebutuhan Rp900.000.'),
        );
      });
    });

    group('8. formatTargetDanaDarurat (assertion pada STRING LENGKAP)', () {
      test('W = 0: "Catat dulu pengeluaran kebutuhanmu agar target bisa dihitung."', () {
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

      test('W 1.900.000 (3 bulan kalender)', () {
        const hasil = HasilPengeluaranWajib(
          total: 1900000,
          bagianKebutuhan: 1700000,
          bagianUtang: 200000,
          jumlahBulan: 3,
          dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
        );
        expect(
          formatTargetDanaDarurat(pengeluaranWajib: hasil),
          equals('Dengan pengeluaran wajib sekitar Rp1.900.000 per bulan, sebagai aturan praktis dana darurat berada di kisaran 3 sampai 6 kali itu: Rp5.700.000 sampai Rp11.400.000. Titik awal yang masuk akal: Rp5.700.000. Sesuaikan dengan kondisimu.'),
        );
      });

      test('W 2.000.000 (3 bulan kalender)', () {
        const hasil = HasilPengeluaranWajib(
          total: 2000000,
          bagianKebutuhan: 2000000,
          bagianUtang: 0,
          jumlahBulan: 3,
          dasar: DasarPengeluaranWajib.tigaBulanTerakhir,
        );
        expect(
          formatTargetDanaDarurat(pengeluaranWajib: hasil),
          equals('Dengan pengeluaran wajib sekitar Rp2.000.000 per bulan, sebagai aturan praktis dana darurat berada di kisaran 3 sampai 6 kali itu: Rp6.000.000 sampai Rp12.000.000. Titik awal yang masuk akal: Rp6.000.000. Sesuaikan dengan kondisimu.'),
        );
      });

      test('dasar bulan berjalan menambahkan kalimat perkiraan awal', () {
        const hasil = HasilPengeluaranWajib(
          total: 2000000,
          bagianKebutuhan: 2000000,
          bagianUtang: 0,
          jumlahBulan: 1,
          dasar: DasarPengeluaranWajib.bulanBerjalan,
        );
        expect(
          formatTargetDanaDarurat(pengeluaranWajib: hasil),
          equals('Dengan pengeluaran wajib sekitar Rp2.000.000 per bulan, sebagai aturan praktis dana darurat berada di kisaran 3 sampai 6 kali itu: Rp6.000.000 sampai Rp12.000.000. Titik awal yang masuk akal: Rp6.000.000. Sesuaikan dengan kondisimu. Angka ini masih perkiraan awal karena datamu baru bulan ini.'),
        );
      });
    });

    group('9. formatProgresDanaDarurat (assertion pada STRING LENGKAP)', () {
      test('tanpa tujuan: "Belum ada tujuan dana darurat."', () {
        expect(
          formatProgresDanaDarurat(tujuan: null, pengeluaranWajibPerBulan: 1900000),
          equals('Belum ada tujuan dana darurat.'),
        );
      });

      test('dana 2.850.000, target 5.700.000, W 1.900.000 -> "1,5 bulan"', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 2850000,
          targetRupiah: 5700000,
        );
        expect(
          formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: 1900000),
          equals('Dana daruratmu: Rp2.850.000 dari target Rp5.700.000 (50 persen). Itu setara sekitar 1,5 bulan pengeluaran wajibmu.'),
        );
      });

      test('dana 5.700.000 (tercapai), target 5.700.000, W 1.900.000', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 5700000,
          targetRupiah: 5700000,
        );
        expect(
          formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: 1900000),
          equals('Dana daruratmu: Rp5.700.000 dari target Rp5.700.000 (100 persen). Itu setara sekitar 3 bulan pengeluaran wajibmu. Targetmu sudah tercapai.'),
        );
      });

      test('tanpa W (pengeluaranWajibPerBulan null atau 0)', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 2850000,
          targetRupiah: 5700000,
        );
        expect(
          formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: null),
          equals('Dana daruratmu: Rp2.850.000 dari target Rp5.700.000 (50 persen).'),
        );
      });

      test('dana 0 ("0 bulan")', () {
        const t = DataTujuanDanaDaruratUmpanBalik(
          danaTerkumpul: 0,
          targetRupiah: 5700000,
        );
        expect(
          formatProgresDanaDarurat(tujuan: t, pengeluaranWajibPerBulan: 1900000),
          equals('Dana daruratmu: Rp0 dari target Rp5.700.000 (0 persen). Itu setara sekitar 0 bulan pengeluaran wajibmu.'),
        );
      });
    });
  });
}
