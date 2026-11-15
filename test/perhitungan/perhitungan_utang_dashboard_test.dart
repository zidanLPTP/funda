import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/arah_penyesuaian_utang.dart';
import 'package:funda/data/model/jenis_tujuan.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';

void main() {
  group('Perhitungan Murni Sisa Utang & Pembayaran', () {
    test(
      'hitungSisaUtang menghitung sisa dari awal, pembayaran, dan penyesuaian',
      () {
        // Sisa awal 10 juta
        // Pembayaran: 1 juta + 2 juta = 3 juta
        // Penyesuaian tambah: 500 ribu (bunga/denda)
        // Penyesuaian kurang: 200 ribu (diskon/koreksi)
        // Sisa = 10jt - 3jt + 500rb - 200rb = 7.300.000
        final penyesuaian = [
          const ItemPenyesuaianUtang(
            arah: ArahPenyesuaianUtang.tambah,
            jumlahRupiah: 500000,
          ),
          const ItemPenyesuaianUtang(
            arah: ArahPenyesuaianUtang.kurang,
            jumlahRupiah: 200000,
          ),
        ];

        final sisa = hitungSisaUtang(
          sisaAwalRupiah: 10000000,
          daftarJumlahPembayaranRupiah: [1000000, 2000000],
          daftarPenyesuaian: penyesuaian,
        );

        expect(sisa, equals(7300000));
      },
    );

    test(
      'hitungSisaUtang bernilai 0 jika total pembayaran tepat sama dengan sisa',
      () {
        final sisa = hitungSisaUtang(
          sisaAwalRupiah: 5000000,
          daftarJumlahPembayaranRupiah: [2500000, 2500000],
          daftarPenyesuaian: [],
        );
        expect(sisa, equals(0));
      },
    );

    test(
      'hitungTotalSisaUtang & hitungTotalCicilanBulanan mengakumulasi data aktif',
      () {
        final totalSisa = hitungTotalSisaUtang([5000000, 12000000, 3000000]);
        expect(totalSisa, equals(20000000));

        final totalCicilan = hitungTotalCicilanBulanan([500000, 1200000, 0]);
        expect(totalCicilan, equals(1700000));

        expect(hitungTotalSisaUtang([]), equals(0));
        expect(hitungTotalCicilanBulanan([]), equals(0));
      },
    );

    test(
      'hitungEstimasiSisaBulan pembulatan ke atas (integer ceiling division)',
      () {
        // Sisa 5jt, cicilan 2jt -> 3 bulan (2jt, 2jt, 1jt)
        expect(
          hitungEstimasiSisaBulan(
            sisaRupiah: 5000000,
            cicilanBulananRupiah: 2000000,
          ),
          equals(3),
        );
        // Sisa 6jt, cicilan 2jt -> tepat 3 bulan
        expect(
          hitungEstimasiSisaBulan(
            sisaRupiah: 6000000,
            cicilanBulananRupiah: 2000000,
          ),
          equals(3),
        );
        // Cicilan 0 atau sisa 0 -> null
        expect(
          hitungEstimasiSisaBulan(sisaRupiah: 5000000, cicilanBulananRupiah: 0),
          isNull,
        );
        expect(
          hitungEstimasiSisaBulan(sisaRupiah: 0, cicilanBulananRupiah: 1000000),
          isNull,
        );
      },
    );

    test(
      'validasiPembayaranUtang menolak pembayaran yang melebihi sisa utang',
      () {
        // Bayar 2jt saat sisa 1.5jt -> ditolak
        final hasilValidasi = validasiPembayaranUtang(
          jumlahRupiah: 2000000,
          sisaUtangSaatIni: 1500000,
        );
        expect(hasilValidasi.sukses, isFalse);
        expect(
          hasilValidasi.pesanGalat,
          contains('melebihi sisa utang saat ini'),
        );

        // Bayar 1.5jt saat sisa 1.5jt -> sukses
        final pas = validasiPembayaranUtang(
          jumlahRupiah: 1500000,
          sisaUtangSaatIni: 1500000,
        );
        expect(pas.sukses, isTrue);

        // Bayar 0 atau negatif -> ditolak
        final nol = validasiPembayaranUtang(
          jumlahRupiah: 0,
          sisaUtangSaatIni: 1500000,
        );
        expect(nol.sukses, isFalse);
      },
    );
  });

  group('Perhitungan Pemasukan Rata-Rata & Rasio Cicilan', () {
    final now = DateTime(2026, 4, 15); // April 2026

    test(
      'hitungPemasukanBulananRataRata memakai 3 bulan kalender terakhir yang sudah selesai',
      () {
        // 3 bulan terakhir selesai dari April 2026: Januari, Februari, Maret 2026
        final daftarTransaksi = [
          // Januari 2026: 9.000.000
          EntitasTransaksi(
            id: 't1',
            jenis: 'masuk',
            jumlahRupiah: 9000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2026, 1, 10),
            dibuatPada: DateTime(2026, 1, 10),
            diubahPada: DateTime(2026, 1, 10),
          ),
          // Februari 2026: 12.000.000
          EntitasTransaksi(
            id: 't2',
            jenis: 'masuk',
            jumlahRupiah: 12000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2026, 2, 1),
            dibuatPada: DateTime(2026, 2, 1),
            diubahPada: DateTime(2026, 2, 1),
          ),
          // Maret 2026: 6.000.000
          EntitasTransaksi(
            id: 't3',
            jenis: 'masuk',
            jumlahRupiah: 6000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2026, 3, 20),
            dibuatPada: DateTime(2026, 3, 20),
            diubahPada: DateTime(2026, 3, 20),
          ),
          // April 2026 (bulan berjalan): 15.000.000 (tidak dimasukkan ke rata-rata 3 bulan)
          EntitasTransaksi(
            id: 't4',
            jenis: 'masuk',
            jumlahRupiah: 15000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2026, 4, 5),
            dibuatPada: DateTime(2026, 4, 5),
            diubahPada: DateTime(2026, 4, 5),
          ),
        ];

        // Total 3 bulan: 9 + 12 + 6 = 27jt / 3 = 9.000.000
        final hasil = hitungPemasukanBulananRataRata(
          daftarTransaksi: daftarTransaksi,
          waktuSekarang: now,
        );

        expect(hasil.nilaiRupiah, equals(9000000));
        expect(hasil.dasar, equals(DasarPemasukanRataRata.rataRata3Bulan));
      },
    );

    test(
      'hitungPemasukanBulananRataRata jatuh kembali ke bulan berjalan jika 3 bulan lalu kosong',
      () {
        // Pengguna baru catat transaksi di bulan berjalan (April)
        final daftarTransaksi = [
          EntitasTransaksi(
            id: 't1',
            jenis: 'masuk',
            jumlahRupiah: 8000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2026, 4, 2),
            dibuatPada: DateTime(2026, 4, 2),
            diubahPada: DateTime(2026, 4, 2),
          ),
        ];

        final hasil = hitungPemasukanBulananRataRata(
          daftarTransaksi: daftarTransaksi,
          waktuSekarang: now,
        );

        expect(hasil.nilaiRupiah, equals(8000000));
        expect(hasil.dasar, equals(DasarPemasukanRataRata.bulanBerjalan));
      },
    );

    test(
      'hitungPemasukanBulananRataRata mengembalikan belumAda jika sama sekali tidak ada pemasukan',
      () {
        final hasil = hitungPemasukanBulananRataRata(
          daftarTransaksi: [],
          waktuSekarang: now,
        );

        expect(hasil.nilaiRupiah, equals(0));
        expect(hasil.dasar, equals(DasarPemasukanRataRata.belumAda));
      },
    );

    test(
      'hitungPemasukanBulananRataRata bekerja pada pergantian tahun (Januari -> Nov, Des, Jan)',
      () {
        final waktuJanuari = DateTime(2026, 1, 10);
        final daftarTransaksi = [
          // September 2025 (4 bulan lalu, diabaikan)
          EntitasTransaksi(
            id: 't_sep',
            jenis: 'masuk',
            jumlahRupiah: 10000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2025, 9, 15),
            dibuatPada: DateTime(2025, 9, 15),
            diubahPada: DateTime(2025, 9, 15),
          ),
          // November 2025
          EntitasTransaksi(
            id: 't_nov',
            jenis: 'masuk',
            jumlahRupiah: 6000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2025, 11, 20),
            dibuatPada: DateTime(2025, 11, 20),
            diubahPada: DateTime(2025, 11, 20),
          ),
          // Desember 2025
          EntitasTransaksi(
            id: 't_des',
            jenis: 'masuk',
            jumlahRupiah: 6000000,
            dompetId: 'd1',
            biayaAdminRupiah: 0,
            waktuTransaksi: DateTime(2025, 12, 25),
            dibuatPada: DateTime(2025, 12, 25),
            diubahPada: DateTime(2025, 12, 25),
          ),
        ];

        // 3 bulan lalu dari Januari 2026: Okt (diabaikan), Nov (6jt), Des (6jt), Total = 12jt / 3 = 4.000.000
        final hasil = hitungPemasukanBulananRataRata(
          daftarTransaksi: daftarTransaksi,
          waktuSekarang: waktuJanuari,
        );

        expect(hasil.nilaiRupiah, equals(4000000));
        expect(hasil.dasar, equals(DasarPemasukanRataRata.rataRata3Bulan));
      },
    );

    test(
      'hitungRasioCicilan menghitung persentase integer dan menangani pemasukan 0',
      () {
        // Cicilan 2jt, pemasukan 10jt -> 20%
        expect(
          hitungRasioCicilan(
            totalCicilanBulananRupiah: 2000000,
            pemasukanBulananRupiah: 10000000,
          ),
          equals(20),
        );
        // Cicilan 1jt, pemasukan 3jt -> 33% (1/3 dibulatkan)
        expect(
          hitungRasioCicilan(
            totalCicilanBulananRupiah: 1000000,
            pemasukanBulananRupiah: 3000000,
          ),
          equals(33),
        );
        // Cicilan melebihi pemasukan (cicilan 5jt, pemasukan 4jt -> 125%)
        expect(
          hitungRasioCicilan(
            totalCicilanBulananRupiah: 5000000,
            pemasukanBulananRupiah: 4000000,
          ),
          equals(125),
        );
        // Pemasukan 0 -> null
        expect(
          hitungRasioCicilan(
            totalCicilanBulananRupiah: 2000000,
            pemasukanBulananRupiah: 0,
          ),
          isNull,
        );
      },
    );
  });

  group('Perhitungan Kekayaan Bersih & Pemilihan Tujuan Terdekat', () {
    test(
      'hitungKekayaanBersih saldo dikurangi utang (bisa positif, nol, atau negatif)',
      () {
        // Saldo 15jt, utang 5jt -> +10jt
        expect(
          hitungKekayaanBersih(
            totalSaldoDompetAktifRupiah: 15000000,
            totalSisaUtangRupiah: 5000000,
          ),
          equals(10000000),
        );
        // Saldo 5jt, utang 5jt -> 0
        expect(
          hitungKekayaanBersih(
            totalSaldoDompetAktifRupiah: 5000000,
            totalSisaUtangRupiah: 5000000,
          ),
          equals(0),
        );
        // Saldo 3jt, utang 10jt -> -7jt (negatif)
        expect(
          hitungKekayaanBersih(
            totalSaldoDompetAktifRupiah: 3000000,
            totalSisaUtangRupiah: 10000000,
          ),
          equals(-7000000),
        );
      },
    );

    test(
      'pilihTujuanTerdekat memilih tujuan aktif bukan dana darurat dengan tenggat paling dekat',
      () {
        final t1 = EntitasTujuan(
          id: 't_darurat',
          nama: 'Dana Darurat',
          jenis: JenisTujuan.danaDarurat.kode,
          targetRupiah: 20000000,
          tenggat: DateTime(2026, 5, 1),
          ikon: 'shield',
          warna: 'emas',
          status: 'aktif',
          dibuatPada: DateTime.now(),
        );
        final t2 = EntitasTujuan(
          id: 't_laptop',
          nama: 'Beli Laptop',
          jenis: JenisTujuan.tujuanBesar.kode,
          targetRupiah: 15000000,
          tenggat: DateTime(2026, 8, 1),
          ikon: 'laptop',
          warna: 'biru',
          status: 'aktif',
          dibuatPada: DateTime.now(),
        );
        final t3 = EntitasTujuan(
          id: 't_liburan',
          nama: 'Liburan Bali',
          jenis: JenisTujuan.tabungan.kode,
          targetRupiah: 5000000,
          tenggat: DateTime(2026, 6, 1), // Lebih dekat dari laptop
          ikon: 'palmtree',
          warna: 'hijau',
          status: 'aktif',
          dibuatPada: DateTime.now(),
        );

        final terpilih = pilihTujuanTerdekat(
          daftarTujuan: [t1, t2, t3],
          petaDanaTerkumpul: {
            't_darurat': 5000000,
            't_laptop': 3000000,
            't_liburan': 1000000,
          },
        );

        // t1 diabaikan karena dana darurat. t3 tenggat Juni vs t2 tenggat Agustus -> pilih t3
        expect(terpilih?.id, equals('t_liburan'));
      },
    );

    test(
      'pilihTujuanTerdekat fallback ke progres tertinggi jika tidak ada yang bertenggat',
      () {
        final t1 = EntitasTujuan(
          id: 't1',
          nama: 'Tujuan A',
          jenis: JenisTujuan.tabungan.kode,
          targetRupiah: 10000000,
          tenggat: null,
          ikon: 'tag',
          warna: 'biru',
          status: 'aktif',
          dibuatPada: DateTime.now(),
        );
        final t2 = EntitasTujuan(
          id: 't2',
          nama: 'Tujuan B',
          jenis: JenisTujuan.tabungan.kode,
          targetRupiah: 10000000,
          tenggat: null,
          ikon: 'tag',
          warna: 'hijau',
          status: 'aktif',
          dibuatPada: DateTime.now(),
        );

        // t1 dana 2jt (20%), t2 dana 6jt (60%)
        final terpilih = pilihTujuanTerdekat(
          daftarTujuan: [t1, t2],
          petaDanaTerkumpul: {'t1': 2000000, 't2': 6000000},
        );

        expect(terpilih?.id, equals('t2'));
      },
    );
  });
}
