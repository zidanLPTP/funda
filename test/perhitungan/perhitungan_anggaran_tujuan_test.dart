import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_alokasi.dart';
import 'package:funda/perhitungan/perhitungan_anggaran_tujuan.dart';

void main() {
  group('hitungSaldoKantong', () {
    test('saldo awal kosong menghasilkan 0', () {
      expect(hitungSaldoKantong([]), equals(0));
    });

    test('mengakumulasi isi dan ambil dengan benar', () {
      final sekarang = DateTime.now();
      final alokasi = [
        EntitasAlokasiKantong(
          id: 'a1',
          kantongId: 'k1',
          jenis: JenisAlokasi.isi.kode,
          jumlahRupiah: 500000,
          catatan: null,
          waktu: sekarang,
          dibuatPada: sekarang,
        ),
        EntitasAlokasiKantong(
          id: 'a2',
          kantongId: 'k1',
          jenis: JenisAlokasi.ambil.kode,
          jumlahRupiah: 200000,
          catatan: null,
          waktu: sekarang,
          dibuatPada: sekarang,
        ),
      ];
      expect(hitungSaldoKantong(alokasi), equals(300000));
    });

    test('validasiAmbilKantong menolak pengambilan melebihi saldo kantong', () {
      expect(
        () => validasiAmbilKantong(saldoKantong: 100000, jumlahAmbil: 150000),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => validasiAmbilKantong(saldoKantong: 100000, jumlahAmbil: 100000),
        returnsNormally,
      );
    });
  });

  group('hitungSaldoBebasDompet', () {
    test('mengurangi saldo dompet dengan total saldo kantong-kantongnya', () {
      final saldoBebas = hitungSaldoBebasDompet(
        saldoDompetRupiah: 1000000,
        daftarSaldoKantongRupiah: [200000, 300000],
      );
      expect(saldoBebas, equals(500000));
    });

    test(
      'saldo bebas boleh bernilai negatif jika kantong melebihi saldo dompet',
      () {
        final saldoBebas = hitungSaldoBebasDompet(
          saldoDompetRupiah: 300000,
          daftarSaldoKantongRupiah: [500000],
        );
        expect(saldoBebas, equals(-200000));
      },
    );
  });

  group('hitungDanaTujuan & hitungProgresTujuan', () {
    test('menjumlahkan seluruh saldo kantong yang tertaut ke tujuan', () {
      expect(hitungDanaTujuan([500000, 750000, 250000]), equals(1500000));
    });

    test('menghitung progres persen integer tanpa double', () {
      // 500.000 dari 1.000.000 = 50%
      expect(
        hitungProgresTujuan(danaRupiah: 500000, targetRupiah: 1000000),
        equals(50),
      );
      // 333.333 dari 1.000.000 = 33%
      expect(
        hitungProgresTujuan(danaRupiah: 333333, targetRupiah: 1000000),
        equals(33),
      );
      // Dana melebihi target = 150%
      expect(
        hitungProgresTujuan(danaRupiah: 1500000, targetRupiah: 1000000),
        equals(150),
      );
      // Target 0 menghasilkan 0%
      expect(
        hitungProgresTujuan(danaRupiah: 100000, targetRupiah: 0),
        equals(0),
      );
    });
  });

  group('hitungSetoranBulananDibutuhkan', () {
    test('tenggat null mengembalikan null', () {
      final setoran = hitungSetoranBulananDibutuhkan(
        targetRupiah: 10000000,
        danaTerkumpulRupiah: 2000000,
        tenggat: null,
        waktuSekarang: DateTime(2026, 1, 1),
      );
      expect(setoran, isNull);
    });

    test('dana sudah tercapai mengembalikan 0', () {
      final setoran = hitungSetoranBulananDibutuhkan(
        targetRupiah: 5000000,
        danaTerkumpulRupiah: 6000000,
        tenggat: DateTime(2026, 6, 1),
        waktuSekarang: DateTime(2026, 1, 1),
      );
      expect(setoran, equals(0));
    });

    test('pembulatan ke atas dengan aritmetika integer', () {
      // Sisa 1.000.000 dalam 3 bulan: 1.000.000 / 3 = 333.333,33 -> dibulatkan ke atas jadi 333.334
      final setoran = hitungSetoranBulananDibutuhkan(
        targetRupiah: 1000000,
        danaTerkumpulRupiah: 0,
        tenggat: DateTime(2026, 4, 1), // sisa 3 bulan (Jan, Feb, Mar)
        waktuSekarang: DateTime(2026, 1, 1),
      );
      expect(setoran, equals(333334));
    });

    test('tenggat bulan ini atau lewat mengembalikan seluruh sisa', () {
      final setoran = hitungSetoranBulananDibutuhkan(
        targetRupiah: 1000000,
        danaTerkumpulRupiah: 200000,
        tenggat: DateTime(2026, 1, 15),
        waktuSekarang: DateTime(2026, 1, 20),
      );
      expect(setoran, equals(800000));
    });
  });

  group('hitungRealisasiAnggaran & StatusAnggaran', () {
    test('status aman jika pengeluaran < 80%', () {
      final realisasi = hitungRealisasiAnggaran(
        batasRupiah: 1000000,
        terpakaiRupiah: 790000,
      );
      expect(realisasi.status, equals(StatusAnggaran.aman));
      expect(realisasi.persenTerpakai, equals(79));
      expect(realisasi.sisaRupiah, equals(210000));
    });

    test('status mendekati tepat pada batas 80% sampai 100%', () {
      final r80 = hitungRealisasiAnggaran(
        batasRupiah: 1000000,
        terpakaiRupiah: 800000,
      );
      expect(r80.status, equals(StatusAnggaran.mendekati));
      expect(r80.persenTerpakai, equals(80));

      final r100 = hitungRealisasiAnggaran(
        batasRupiah: 1000000,
        terpakaiRupiah: 1000000,
      );
      expect(r100.status, equals(StatusAnggaran.mendekati));
      expect(r100.persenTerpakai, equals(100));
      expect(r100.sisaRupiah, equals(0));
    });

    test('status melewati jika pengeluaran > 100%', () {
      final r101 = hitungRealisasiAnggaran(
        batasRupiah: 1000000,
        terpakaiRupiah: 1050000,
      );
      expect(r101.status, equals(StatusAnggaran.melewati));
      expect(r101.persenTerpakai, equals(105));
      expect(r101.sisaRupiah, equals(-50000));
    });
  });

  group('hitungRingkasanAnggaran', () {
    test('mengakumulasi total batas, terpakai, sisa, dan sifat kategori', () {
      final items = [
        ItemRealisasiAnggaran(
          kategoriId: 'k_makan',
          namaKategori: 'Makan Harian',
          sifatKategori: 'kebutuhan',
          batasRupiah: 2000000,
          terpakaiRupiah: 1500000,
        ),
        ItemRealisasiAnggaran(
          kategoriId: 'k_hobi',
          namaKategori: 'Hobi',
          sifatKategori: 'keinginan',
          batasRupiah: 500000,
          terpakaiRupiah: 600000,
        ),
      ];

      final ringkasan = hitungRingkasanAnggaran(items);
      expect(ringkasan.totalBatasRupiah, equals(2500000));
      expect(ringkasan.totalTerpakaiRupiah, equals(2100000));
      expect(ringkasan.totalSisaRupiah, equals(400000));

      expect(
        ringkasan.perSifat['kebutuhan']?.totalBatasRupiah,
        equals(2000000),
      );
      expect(
        ringkasan.perSifat['kebutuhan']?.totalTerpakaiRupiah,
        equals(1500000),
      );

      expect(ringkasan.perSifat['keinginan']?.totalBatasRupiah, equals(500000));
      expect(
        ringkasan.perSifat['keinginan']?.totalTerpakaiRupiah,
        equals(600000),
      );
    });
  });

  group('ambilRentangBulanAnggaran (Kalender & Zona Waktu)', () {
    test('Februari tahun kabisat (2024) memiliki 29 hari', () {
      final rentang = ambilRentangBulanAnggaran(tahun: 2024, bulan: 2);
      expect(rentang.mulai.day, equals(1));
      expect(rentang.selesai.day, equals(29));
      expect(rentang.selesai.hour, equals(23));
      expect(rentang.selesai.minute, equals(59));
      expect(rentang.selesai.second, equals(59));
    });

    test('Februari tahun biasa (2025) memiliki 28 hari', () {
      final rentang = ambilRentangBulanAnggaran(tahun: 2025, bulan: 2);
      expect(rentang.mulai.day, equals(1));
      expect(rentang.selesai.day, equals(28));
    });

    test('Pergantian tahun (Desember ke Januari)', () {
      final des = ambilRentangBulanAnggaran(tahun: 2026, bulan: 12);
      expect(des.mulai, equals(DateTime(2026, 12, 1, 0, 0, 0)));
      expect(des.selesai, equals(DateTime(2026, 12, 31, 23, 59, 59, 999)));

      final jan = ambilRentangBulanAnggaran(tahun: 2027, bulan: 1);
      expect(jan.mulai, equals(DateTime(2027, 1, 1, 0, 0, 0)));
      expect(jan.selesai, equals(DateTime(2027, 1, 31, 23, 59, 59, 999)));
    });

    test(
      'transaksi jam 23:30 WIB tanggal 31 Januari masuk ke bulan Januari',
      () {
        // 31 Jan 23:30 WIB = 31 Jan 16:30 UTC
        final waktuWib = DateTime(2026, 1, 31, 23, 30);
        final rentangJan = ambilRentangBulanAnggaran(tahun: 2026, bulan: 1);

        expect(waktuWib.isAfter(rentangJan.mulai), isTrue);
        expect(waktuWib.isBefore(rentangJan.selesai), isTrue);
      },
    );
  });
}
