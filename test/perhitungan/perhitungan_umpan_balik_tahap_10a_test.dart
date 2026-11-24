import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('Perhitungan Umpan Balik Tahap 10A - ringkasan_pemasukan_tambahan', () {
    test('V1: 2 sumber: Gaji 3.000.000, Freelance 1.200.000', () {
      final hasil = formatRingkasanPemasukanTambahan(
        petaPemasukanPerKategori: {
          'Freelance': 1200000,
          'Gaji': 3000000,
        },
        baruSatuSumber: false,
      );

      const ekspetasi =
          'Bulan ini pemasukanmu datang dari 2 sumber dengan total Rp4.200.000. '
          'Terbesar: Gaji (Rp3.000.000), diikuti Freelance (Rp1.200.000). '
          'Memisahkan catatan per sumber membantumu mengatur porsi untuk kebutuhan dan masa sepi.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPemasukanTambahanMisi(
        petaPemasukanPerKategori: {
          'Freelance': 1200000,
          'Gaji': 3000000,
        },
        baruSatuSumber: false,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V2: 1 sumber: Uang Saku 1.500.000', () {
      final hasil = formatRingkasanPemasukanTambahan(
        petaPemasukanPerKategori: {
          'Uang Saku': 1500000,
        },
        baruSatuSumber: false,
      );

      const ekspetasi =
          'Bulan ini pemasukanmu berasal dari 1 sumber: Uang Saku (Rp1.500.000). '
          'Mencatat per sumber memudahkanmu melihat perkembangan jika nanti ada penghasilan tambahan.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPemasukanTambahanMisi(
        petaPemasukanPerKategori: {
          'Uang Saku': 1500000,
        },
        baruSatuSumber: false,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V3: kosong + baruSatuSumber: true', () {
      final hasil = formatRingkasanPemasukanTambahan(
        petaPemasukanPerKategori: {},
        baruSatuSumber: true,
      );

      const ekspetasi =
          'Kamu menyatakan baru punya satu sumber penghasilan. '
          'Saat nanti ada pemasukan tambahan, catat dengan kategori terpisah agar alirannya mudah dipantau.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPemasukanTambahanMisi(
        petaPemasukanPerKategori: {},
        baruSatuSumber: true,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V4: kosong + baruSatuSumber: false', () {
      final hasil = formatRingkasanPemasukanTambahan(
        petaPemasukanPerKategori: {},
        baruSatuSumber: false,
      );

      const ekspetasi =
          'Belum ada pemasukan yang tercatat bulan ini. '
          'Catat pemasukanmu agar pembagian sumbernya terlihat.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPemasukanTambahanMisi(
        petaPemasukanPerKategori: {},
        baruSatuSumber: false,
      );
      expect(hasilMisi, equals(ekspetasi));
    });
  });

  group('Perhitungan Umpan Balik Tahap 10A - ringkasan_penghasilan_tahunan', () {
    test('V1: total 18.000.000, 6 bulan -> rata-rata Rp3.000.000', () {
      final hasil = formatRingkasanPenghasilanTahunan(
        totalPemasukanTahunIni: 18000000,
        jumlahBulanTercatat: 6,
      );

      const ekspetasi =
          'Total pemasukanmu yang tercatat tahun ini: Rp18.000.000 (dari 6 bulan yang tercatat). '
          'Rata-rata sekitar Rp3.000.000 per bulan. '
          'Catatan yang rapi memudahkanmu saat menyiapkan pelaporan pajak. '
          'Ini edukasi umum, bukan nasihat pajak.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPenghasilanTahunanMisi(
        totalPemasukanTahunIni: 18000000,
        jumlahBulanTercatat: 6,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V2: total 10.000.000, 3 bulan -> rata-rata Rp3.333.333', () {
      final hasil = formatRingkasanPenghasilanTahunan(
        totalPemasukanTahunIni: 10000000,
        jumlahBulanTercatat: 3,
      );

      const ekspetasi =
          'Total pemasukanmu yang tercatat tahun ini: Rp10.000.000 (dari 3 bulan yang tercatat). '
          'Rata-rata sekitar Rp3.333.333 per bulan. '
          'Catatan yang rapi memudahkanmu saat menyiapkan pelaporan pajak. '
          'Ini edukasi umum, bukan nasihat pajak.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPenghasilanTahunanMisi(
        totalPemasukanTahunIni: 10000000,
        jumlahBulanTercatat: 3,
      );
      expect(hasilMisi, equals(ekspetasi));
    });

    test('V3: total 0, 0 bulan', () {
      final hasil = formatRingkasanPenghasilanTahunan(
        totalPemasukanTahunIni: 0,
        jumlahBulanTercatat: 0,
      );

      const ekspetasi =
          'Belum ada pemasukan yang tercatat di tahun ini. '
          'Catat pemasukanmu secara rutin agar rekap tahunanmu mudah dilihat saat waktunya lapor pajak.';

      expect(hasil, equals(ekspetasi));

      // Verifikasi delegasi RegistriMisi
      final hasilMisi = RegistriMisi.formatRingkasanPenghasilanTahunanMisi(
        totalPemasukanTahunIni: 0,
        jumlahBulanTercatat: 0,
      );
      expect(hasilMisi, equals(ekspetasi));
    });
  });

  group('Uji Kesetaraan SQL vs Fungsi Murni untuk sumber_pemasukan', () {
    late BasisDataFunda db;
    late FotoDataRepositori repo;

    setUp(() {
      db = BasisDataFunda(NativeDatabase.memory());
      repo = FotoDataRepositori(db);
    });

    tearDown(() async {
      await db.close();
    });

    int hitungSumberPemasukanMurni(List<({String jenis, String? kategoriId})> daftarTransaksi) {
      return daftarTransaksi
          .where((t) => t.jenis == 'masuk' && t.kategoriId != null)
          .map((t) => t.kategoriId!)
          .toSet()
          .length;
    }

    test('Kesetaraan SQL COUNT(DISTINCT kategori_id) vs fungsi murni pada berbagai skenario transaksi', () async {
      final now = DateTime.now();

      // Tambah dompet
      await db.into(db.tabelDompet).insert(
        TabelDompetCompanion.insert(
          id: 'dmp_1',
          nama: 'Dompet Utama',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'tintHijau',
        ),
      );

      // Kategori pemasukan
      await db.into(db.tabelKategori).insert(
        TabelKategoriCompanion.insert(
          id: 'kat_gaji',
          nama: 'Gaji',
          arus: 'masuk',
          ikon: 'briefcase',
          sifat: 'kebutuhan',
        ),
      );
      await db.into(db.tabelKategori).insert(
        TabelKategoriCompanion.insert(
          id: 'kat_freelance',
          nama: 'Freelance',
          arus: 'masuk',
          ikon: 'laptop',
          sifat: 'kebutuhan',
        ),
      );
      await db.into(db.tabelKategori).insert(
        TabelKategoriCompanion.insert(
          id: 'kat_makan',
          nama: 'Makanan',
          arus: 'keluar',
          ikon: 'utensils',
          sifat: 'kebutuhan',
        ),
      );

      // Skenario 1: Belum ada transaksi masuk
      final foto1 = await repo.ambilFotoData();
      final murni1 = hitungSumberPemasukanMurni([]);
      expect(foto1.jumlahSumberPemasukan, equals(murni1));
      expect(foto1.jumlahSumberPemasukan, equals(0));

      // Skenario 2: Transaksi keluar (tidak dihitung sebagai sumber pemasukan)
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_keluar_1',
          dompetId: 'dmp_1',
          jumlahRupiah: 50000,
          jenis: 'keluar',
          kategoriId: const Value('kat_makan'),
          waktuTransaksi: now,
        ),
      );
      final daftarSimulasi = [
        (jenis: 'keluar', kategoriId: 'kat_makan'),
      ];
      final foto2 = await repo.ambilFotoData();
      final murni2 = hitungSumberPemasukanMurni(daftarSimulasi);
      expect(foto2.jumlahSumberPemasukan, equals(murni2));
      expect(foto2.jumlahSumberPemasukan, equals(0));

      // Skenario 3: Transaksi masuk kategori gaji (1 sumber)
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_masuk_1',
          dompetId: 'dmp_1',
          jumlahRupiah: 3000000,
          jenis: 'masuk',
          kategoriId: const Value('kat_gaji'),
          waktuTransaksi: now,
        ),
      );
      daftarSimulasi.add((jenis: 'masuk', kategoriId: 'kat_gaji'));
      final foto3 = await repo.ambilFotoData();
      final murni3 = hitungSumberPemasukanMurni(daftarSimulasi);
      expect(foto3.jumlahSumberPemasukan, equals(murni3));
      expect(foto3.jumlahSumberPemasukan, equals(1));

      // Skenario 4: Transaksi masuk lagi dengan kategori gaji yang sama (tetap 1 sumber karena DISTINCT)
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_masuk_2',
          dompetId: 'dmp_1',
          jumlahRupiah: 1000000,
          jenis: 'masuk',
          kategoriId: const Value('kat_gaji'),
          waktuTransaksi: now,
        ),
      );
      daftarSimulasi.add((jenis: 'masuk', kategoriId: 'kat_gaji'));
      final foto4 = await repo.ambilFotoData();
      final murni4 = hitungSumberPemasukanMurni(daftarSimulasi);
      expect(foto4.jumlahSumberPemasukan, equals(murni4));
      expect(foto4.jumlahSumberPemasukan, equals(1));

      // Skenario 5: Transaksi masuk kategori freelance (menjadi 2 sumber berbeda)
      await db.into(db.tabelTransaksi).insert(
        TabelTransaksiCompanion.insert(
          id: 'tx_masuk_3',
          dompetId: 'dmp_1',
          jumlahRupiah: 1200000,
          jenis: 'masuk',
          kategoriId: const Value('kat_freelance'),
          waktuTransaksi: now,
        ),
      );
      daftarSimulasi.add((jenis: 'masuk', kategoriId: 'kat_freelance'));
      final foto5 = await repo.ambilFotoData();
      final murni5 = hitungSumberPemasukanMurni(daftarSimulasi);
      expect(foto5.jumlahSumberPemasukan, equals(murni5));
      expect(foto5.jumlahSumberPemasukan, equals(2));
    });
  });
}
