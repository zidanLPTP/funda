import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/perhitungan/perhitungan_anggaran_tujuan.dart';
import 'package:funda/perhitungan/perhitungan_laporan_bulanan.dart';

void main() {
  late KontenLaporan konten;

  setUpAll(() {
    final berkas = File('aset/konten/laporan.json');
    expect(berkas.existsSync(), isTrue);
    konten = PembacaKonten.uraiLaporan(berkas.readAsStringSync());
  });

  group('Logika Murni Laporan Bulanan (lib/perhitungan/)', () {
    test('Rumus persenTerdekat berbasis integer arithmetic', () {
      expect(persenTerdekat(0, 0), isNull);
      expect(persenTerdekat(100, 0), isNull);
      expect(persenTerdekat(0, 1000), equals(0));
      // 345.000 / 300.000 = 1.15 -> 115%
      expect(persenTerdekat(345000, 300000), equals(115));
      // 2.450.000 / 3.000.000 = 81.666% -> 82%
      expect(persenTerdekat(2450000, 3000000), equals(82));
      // 2.300.000 / 2.000.000 = 1.15 -> 115%
      expect(persenTerdekat(2300000, 2000000), equals(115));
      // 400.000 / 600.000 = 66.666% -> 67%
      expect(persenTerdekat(400000, 600000), equals(67));
      // Batas pembulatan integer: 1 dari 8 = 12.5% dibulatkan ke atas -> 13%
      expect(persenTerdekat(1, 8), equals(13));
      // Total 0 -> tidak ada hasil (null)
      expect(persenTerdekat(0, 0), isNull);
      expect(persenTerdekat(5, 0), isNull);
    });

    // Vektor V1
    test(
      'V1: Arus kas +550k, 78/22, pos Jajan melewati batas, saran tinjau_pos, sensor 115% dan 82%',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 10, 1),
          waktuDibuat: DateTime(2026, 11, 1, 10, 0),
          uangMasukRupiah: 3000000,
          uangKeluarRupiah: 2450000,
          pengeluaranPerSifat: {
            'kebutuhan': 1900000,
            'keinginan': 550000,
            'tabungan': 0,
            'utang': 0,
            'belum_dilabeli': 0,
          },
          daftarPosAnggaran: [
            const PosAnggaranLaporan(
              id: '1',
              nama: 'Makan Harian',
              batasRupiah: 800000,
              terpakaiRupiah: 560000,
              persenTerpakai: 70,
              status: StatusAnggaran.aman,
            ),
            const PosAnggaranLaporan(
              id: '2',
              nama: 'Transportasi',
              batasRupiah: 300000,
              terpakaiRupiah: 255000,
              persenTerpakai: 85,
              status: StatusAnggaran.mendekati,
            ),
            const PosAnggaranLaporan(
              id: '3',
              nama: 'Jajan & Nongkrong',
              batasRupiah: 300000,
              terpakaiRupiah: 345000,
              persenTerpakai: 115,
              status: StatusAnggaran.melewati,
            ),
          ],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 5000000,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);

        // Verifikasi Arus Kas
        expect(laporan.arusKas.selisihRupiah, equals(550000));

        // Verifikasi Komposisi 78/22
        expect(laporan.komposisi.perSifatPersen['kebutuhan'], equals(78));
        expect(laporan.komposisi.perSifatPersen['keinginan'], equals(22));

        // Verifikasi Ringkasan
        expect(laporan.ringkasanAnggaran.totalPos, equals(3));
        expect(laporan.ringkasanAnggaran.posAman, equals(1));
        expect(laporan.ringkasanAnggaran.posMendekati, equals(1));
        expect(laporan.ringkasanAnggaran.posMelewati, equals(1));

        // Verifikasi Temuan & Saran
        expect(laporan.temuan.kode, equals('pos_melewati'));
        expect(laporan.saran.kode, equals('tinjau_pos'));

        // Terapkan Mode Normal & Sensor
        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teksNormal.ringkasanAnggaran,
          equals(
            'Dari 3 pos anggaran: 1 masih aman, 1 mendekati batas, 1 melewati batas.',
          ),
        );
        expect(
          teksNormal.teksTemuan,
          equals(
            'Pos Jajan & Nongkrong melewati batasnya sebesar Rp45.000. Ini bahan belajar, bukan penilaian.',
          ),
        );
        expect(
          teksNormal.teksSaran,
          equals(
            'Tinjau lagi pos Jajan & Nongkrong: ubah batasnya atau kebiasaannya, pilih satu saja.',
          ),
        );

        final teksSensor = terapkanSensor(laporan, konten, sensor: true);
        expect(
          teksSensor.teksTemuan,
          equals(
            'Pos Jajan & Nongkrong sudah terpakai 115 persen dari batasnya. Ini bahan belajar, bukan penilaian.',
          ),
        );
        expect(
          teksSensor.teksArusKasSensor,
          equals('Uang keluar setara 82 persen dari uang masuk.'),
        );
        expect(
          teksSensor.daftarPosAnggaran
              .firstWhere((p) => p.nama == 'Jajan & Nongkrong')
              .teks,
          equals('Jajan & Nongkrong: 115 persen terpakai'),
        );
      },
    );

    // Vektor V2
    test(
      'V2: Pemasukan 2jt, keluar 2.3jt, tanpa anggaran -> temuan arus_kas_negatif, saran buat_anggaran, sensor 115%',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 9, 1),
          waktuDibuat: DateTime(2026, 10, 1, 9, 0),
          uangMasukRupiah: 2000000,
          uangKeluarRupiah: 2300000,
          pengeluaranPerSifat: {
            'kebutuhan': 1500000,
            'keinginan': 800000,
            'tabungan': 0,
            'utang': 0,
            'belum_dilabeli': 0,
          },
          daftarPosAnggaran: [],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 1000000,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.temuan.kode, equals('arus_kas_negatif'));
        expect(laporan.saran.kode, equals('buat_anggaran'));

        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teksNormal.teksTemuan,
          equals(
            'Uang keluarmu lebih besar Rp300.000 dari uang masukmu bulan ini. Ini informasi untuk membantumu memutuskan.',
          ),
        );
        expect(
          teksNormal.teksSaran,
          equals(
            'Buat anggaran untuk bulan depan di menu Anggaran. Mulai dari tiga kategori saja.',
          ),
        );

        final teksSensor = terapkanSensor(laporan, konten, sensor: true);
        expect(
          teksSensor.teksTemuan,
          equals(
            'Uang keluarmu setara 115 persen dari uang masukmu bulan ini. Ini informasi untuk membantumu memutuskan.',
          ),
        );
      },
    );

    // Vektor V3
    test(
      'V3: Pemasukan 0, pengeluaran 100.000 -> temuan arus_kas_tanpa_pemasukan',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 8, 1),
          waktuDibuat: DateTime(2026, 9, 1, 10, 0),
          uangMasukRupiah: 0,
          uangKeluarRupiah: 100000,
          pengeluaranPerSifat: {'kebutuhan': 100000},
          daftarPosAnggaran: [],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 500000,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.temuan.kode, equals('arus_kas_tanpa_pemasukan'));

        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teksNormal.teksTemuan,
          equals(
            'Bulan ini ada uang keluar, tetapi belum ada uang masuk yang tercatat.',
          ),
        );

        final teksSensor = terapkanSensor(laporan, konten, sensor: true);
        expect(
          teksSensor.teksTemuan,
          equals(
            'Bulan ini ada uang keluar, tetapi belum ada uang masuk yang tercatat.',
          ),
        );
      },
    );

    // Vektor V4
    test(
      'V4: Pemasukan 1jt, keluar 400k semua keinginan -> temuan sifat_terbesar (keinginan 100%), saran buat_anggaran',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 7, 1),
          waktuDibuat: DateTime(2026, 8, 1, 10, 0),
          uangMasukRupiah: 1000000,
          uangKeluarRupiah: 400000,
          pengeluaranPerSifat: {'keinginan': 400000},
          daftarPosAnggaran: [],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 2000000,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.temuan.kode, equals('sifat_terbesar'));
        expect(laporan.saran.kode, equals('buat_anggaran'));

        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teksNormal.teksTemuan,
          equals(
            'Bagian pengeluaran terbesarmu bulan ini ada di keinginan: 100 persen.',
          ),
        );
      },
    );

    // Vektor V5
    test(
      'V5: Sifat keinginan seri dengan kebutuhan (200k & 200k) dan arus kas positif -> temuan arus_kas_positif',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 6, 1),
          waktuDibuat: DateTime(2026, 7, 1, 10, 0),
          uangMasukRupiah: 600000,
          uangKeluarRupiah: 400000,
          pengeluaranPerSifat: {'kebutuhan': 200000, 'keinginan': 200000},
          daftarPosAnggaran: [
            const PosAnggaranLaporan(
              id: '1',
              nama: 'Makan',
              batasRupiah: 500000,
              terpakaiRupiah: 200000,
              persenTerpakai: 40,
              status: StatusAnggaran.aman,
            ),
          ],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 1000000,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        // Karena seri, sifat_terbesar dilewati, jatuh ke arus_kas_positif
        expect(laporan.temuan.kode, equals('arus_kas_positif'));

        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teksNormal.teksTemuan,
          equals(
            'Uang masukmu lebih besar Rp200.000 dari uang keluar bulan ini.',
          ),
        );

        final teksSensor = terapkanSensor(laporan, konten, sensor: true);
        expect(
          teksSensor.teksTemuan,
          equals('Uang keluarmu setara 67 persen dari uang masukmu bulan ini.'),
        );
      },
    );

    // Vektor V6
    test(
      'V6: Tanpa transaksi sama sekali -> temuan data_belum_cukup, bebas pembagian nol',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 5, 1),
          waktuDibuat: DateTime(2026, 6, 1, 10, 0),
          uangMasukRupiah: 0,
          uangKeluarRupiah: 0,
          pengeluaranPerSifat: {},
          daftarPosAnggaran: [],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 0,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.temuan.kode, equals('data_belum_cukup'));

        final teks = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teks.teksTemuan,
          equals(
            'Datamu bulan ini masih sedikit. Setiap catatan membantu gambarannya makin jelas.',
          ),
        );
        expect(teks.ringkasanAnggaran, equals('Belum ada anggaran bulan ini.'));
        expect(teks.teksBelumAdaTujuan, equals('Belum ada tujuan aktif.'));
      },
    );

    // Vektor V7
    test(
      'V7: Ada anggaran aman, ada kategori belum dilabeli "Belanja" terpakai -> saran beri_label',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 4, 1),
          waktuDibuat: DateTime(2026, 5, 1, 10, 0),
          uangMasukRupiah: 2000000,
          uangKeluarRupiah: 500000,
          pengeluaranPerSifat: {'kebutuhan': 300000, 'belum_dilabeli': 200000},
          daftarPosAnggaran: [
            const PosAnggaranLaporan(
              id: '1',
              nama: 'Makan',
              batasRupiah: 1000000,
              terpakaiRupiah: 300000,
              persenTerpakai: 30,
              status: StatusAnggaran.aman,
            ),
          ],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 2000000,
          sisaUtangAktifRupiah: 0,
          kategoriBelumDilabeliTerpakai: [
            (nama: 'Belanja', pengeluaranRupiah: 200000),
          ],
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.saran.kode, equals('beri_label'));

        final teks = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teks.teksSaran,
          equals(
            'Beri label pada kategori Belanja supaya gambaran pengeluaranmu lebih jelas.',
          ),
        );
      },
    );

    // Vektor V8
    test(
      'V8: Kekayaan bersih negatif tampil "−Rp..." pada normal dan "Disembunyikan" pada sensor',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 3, 1),
          waktuDibuat: DateTime(2026, 4, 1, 10, 0),
          uangMasukRupiah: 1000000,
          uangKeluarRupiah: 800000,
          pengeluaranPerSifat: {'kebutuhan': 800000},
          daftarPosAnggaran: [],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 500000,
          sisaUtangAktifRupiah: 1500000, // Bersih = -1.000.000
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.snapshotKekayaan.kekayaanBersihRupiah, equals(-1000000));

        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        expect(
          teksNormal.teksKekayaanBersih,
          equals('Kekayaan bersih −Rp1.000.000'),
        );

        final teksSensor = terapkanSensor(laporan, konten, sensor: true);
        expect(
          teksSensor.teksKekayaanBersih,
          equals('Kekayaan bersih Disembunyikan'),
        );
        expect(
          teksSensor.teksSaldoDompet,
          equals('Saldo semua dompet Disembunyikan'),
        );
        expect(teksSensor.teksSisaUtang, equals('Sisa utang Disembunyikan'));
      },
    );

    // Vektor V9
    test(
      'V9: Lebih dari 5 pos anggaran -> hanya 5 tampil (urut melewati > mendekati > aman) + "dan N pos lain"',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 2, 1),
          waktuDibuat: DateTime(2026, 3, 1, 10, 0),
          uangMasukRupiah: 5000000,
          uangKeluarRupiah: 4000000,
          pengeluaranPerSifat: {'kebutuhan': 4000000},
          daftarPosAnggaran: [
            const PosAnggaranLaporan(
              id: '1',
              nama: 'Pos A',
              batasRupiah: 100,
              terpakaiRupiah: 50,
              persenTerpakai: 50,
              status: StatusAnggaran.aman,
            ),
            const PosAnggaranLaporan(
              id: '2',
              nama: 'Pos B',
              batasRupiah: 100,
              terpakaiRupiah: 120,
              persenTerpakai: 120,
              status: StatusAnggaran.melewati,
            ),
            const PosAnggaranLaporan(
              id: '3',
              nama: 'Pos C',
              batasRupiah: 100,
              terpakaiRupiah: 90,
              persenTerpakai: 90,
              status: StatusAnggaran.mendekati,
            ),
            const PosAnggaranLaporan(
              id: '4',
              nama: 'Pos D',
              batasRupiah: 100,
              terpakaiRupiah: 150,
              persenTerpakai: 150,
              status: StatusAnggaran.melewati,
            ),
            const PosAnggaranLaporan(
              id: '5',
              nama: 'Pos E',
              batasRupiah: 100,
              terpakaiRupiah: 85,
              persenTerpakai: 85,
              status: StatusAnggaran.mendekati,
            ),
            const PosAnggaranLaporan(
              id: '6',
              nama: 'Pos F',
              batasRupiah: 100,
              terpakaiRupiah: 30,
              persenTerpakai: 30,
              status: StatusAnggaran.aman,
            ),
            const PosAnggaranLaporan(
              id: '7',
              nama: 'Pos G',
              batasRupiah: 100,
              terpakaiRupiah: 40,
              persenTerpakai: 40,
              status: StatusAnggaran.aman,
            ),
          ],
          daftarTujuanAktif: [],
          saldoDompetAktifRupiah: 3000000,
          sisaUtangAktifRupiah: 0,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);
        expect(laporan.ringkasanAnggaran.totalPos, equals(7));
        expect(laporan.ringkasanAnggaran.daftarPosTampil.length, equals(5));
        expect(laporan.ringkasanAnggaran.jumlahPosLain, equals(2));

        // Verifikasi urutan tampilan: Pos D (melewati 150), Pos B (melewati 120), Pos C (mendekati 90), Pos E (mendekati 85), Pos A (aman 50)
        expect(
          laporan.ringkasanAnggaran.daftarPosTampil[0].nama,
          equals('Pos D'),
        );
        expect(
          laporan.ringkasanAnggaran.daftarPosTampil[1].nama,
          equals('Pos B'),
        );
        expect(
          laporan.ringkasanAnggaran.daftarPosTampil[2].nama,
          equals('Pos C'),
        );
        expect(
          laporan.ringkasanAnggaran.daftarPosTampil[3].nama,
          equals('Pos E'),
        );
        expect(
          laporan.ringkasanAnggaran.daftarPosTampil[4].nama,
          equals('Pos A'),
        );

        final teks = terapkanSensor(laporan, konten, sensor: false);
        expect(teks.barisPosLain, equals('dan 2 pos lain'));
      },
    );

    // UJI WAJIB SENSOR: tidak ada "Rp" maupun angka Rupiah pada seluruh string mode sensor
    test(
      'UJI WAJIB SENSOR: seluruh teks mode sensor bebas kata "Rp" dan format nominal Rupiah',
      () {
        final masukan = MasukanLaporanBulanan(
          bulan: DateTime(2026, 11, 1),
          waktuDibuat: DateTime(2026, 11, 18, 12, 0),
          uangMasukRupiah: 3500000,
          uangKeluarRupiah: 2800000,
          pengeluaranPerSifat: {'kebutuhan': 2000000, 'keinginan': 800000},
          daftarPosAnggaran: [
            const PosAnggaranLaporan(
              id: '1',
              nama: 'Makan',
              batasRupiah: 1000000,
              terpakaiRupiah: 1100000,
              persenTerpakai: 110,
              status: StatusAnggaran.melewati,
            ),
            const PosAnggaranLaporan(
              id: '2',
              nama: 'Bensin',
              batasRupiah: 500000,
              terpakaiRupiah: 450000,
              persenTerpakai: 90,
              status: StatusAnggaran.mendekati,
            ),
          ],
          daftarTujuanAktif: [
            const TujuanLaporan(
              id: 't1',
              nama: 'Laptop Baru',
              danaTerkumpulRupiah: 5000000,
              targetRupiah: 10000000,
              persenProgres: 50,
            ),
          ],
          saldoDompetAktifRupiah: 4000000,
          sisaUtangAktifRupiah: 1500000,
        );

        final laporan = susunLaporanBulanan(masukan, konten: konten);

        final teksSensor = terapkanSensor(laporan, konten, sensor: true);
        final daftarSemuaTeksSensor = teksSensor.semuaTeks;
        expect(daftarSemuaTeksSensor.isNotEmpty, isTrue);

        final regexRupiah = RegExp(r'(Rp|\b\d{1,3}(\.\d{3})+)\b');
        for (final teks in daftarSemuaTeksSensor) {
          expect(
            teks.contains('Rp'),
            isFalse,
            reason: 'Teks sensor tidak boleh memuat "Rp": "$teks"',
          );
          expect(
            regexRupiah.hasMatch(teks),
            isFalse,
            reason:
                'Teks sensor tidak boleh memuat nominal angka Rupiah bertitik: "$teks"',
          );
        }

        // Pastikan mode normal memuat "Rp"
        final teksNormal = terapkanSensor(laporan, konten, sensor: false);
        final adaRpPadaNormal = teksNormal.semuaTeks.any(
          (t) => t.contains('Rp'),
        );
        expect(
          adaRpPadaNormal,
          isTrue,
          reason: 'Mode normal wajib memuat simbol "Rp"',
        );
      },
    );

    // Kasus Batas: Februari kabisat vs biasa, akhir tahun, 23:30 WIB
    test(
      'Kasus Batas: Februari Kabisat (2024), Biasa (2025), Pergantian Tahun, dan Transaksi 23:30 WIB',
      () {
        final kabisat = DateTime(2024, 2, 29, 23, 30);
        final biasa = DateTime(2025, 2, 28, 23, 30);
        final akhirTahun = DateTime(2025, 12, 31, 23, 30);

        expect(formatBulanTahunIndonesia(kabisat), equals('Februari 2024'));
        expect(formatBulanTahunIndonesia(biasa), equals('Februari 2025'));
        expect(formatBulanTahunIndonesia(akhirTahun), equals('Desember 2025'));
      },
    );
  });
}
