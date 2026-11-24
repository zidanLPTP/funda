import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';

void main() {
  group('1. Pengujian Umpan Balik: catatan_pengeluaran_terbaru', () {
    test(
      'Format pengeluaran terbaru dengan n pengeluaran dan kategori terbaru',
      () {
        final hasil = formatCatatanPengeluaranTerbaru(
          jumlahTotal: 3,
          kategori: 'Makan Harian',
          nominal: 25000,
        );

        expect(
          hasil,
          equals(
            'Kamu sudah mencatat 3 pengeluaran. Yang terbaru: Makan Harian, Rp25.000. Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi.',
          ),
        );
      },
    );

    test('Tanpa pengeluaran menghasilkan pesan ramah awal', () {
      final hasil = formatCatatanPengeluaranTerbaru(
        jumlahTotal: 0,
        kategori: '',
        nominal: 0,
      );

      expect(
        hasil,
        equals(
          'Belum ada pengeluaran yang dicatat. Dari catatan seperti ini kita mulai melihat ke mana uangmu pergi.',
        ),
      );
    });
  });

  group('Format Negatif Rapat (U+2212)', () {
    test(
      'formatRupiahRapat(-900000) menghasilkan tanda minus U+2212 sebelum Rp tanpa spasi',
      () {
        final hasil = formatRupiahRapat(-900000);
        expect(hasil, equals('−Rp900.000'));
        expect(hasil.codeUnitAt(0), equals(0x2212));
      },
    );
  });

  group('2. Pengujian Umpan Balik: perbandingan_pola_anggaran', () {
    test(
      'Pemasukan 2.500.000 -> K: 1.250.000, L: 750.000, M: 500.000 tanpa belum dilabeli (D = 0)',
      () {
        final hasil = formatPerbandinganPolaAnggaran(
          pemasukan: 2500000,
          kebutuhan: 1500000,
          keinginan: 600000,
          tabunganDanUtang: 400000,
          belumDilabeli: 0,
        );

        expect(
          hasil,
          equals(
            'Pemasukanmu bulan ini: Rp2.500.000. '
            'Anggaran buatanmu: kebutuhan Rp1.500.000, keinginan Rp600.000, tabungan dan utang Rp400.000. '
            'Sebagai perbandingan, pola populer 50/30/20 dari pemasukan yang sama: kebutuhan Rp1.250.000, keinginan Rp750.000, tabungan dan utang Rp500.000. '
            'Keduanya titik awal. Sesuaikan dengan kondisimu.',
          ),
        );
      },
    );

    test(
      'Pemasukan 3.333.333 -> K: 1.666.666, L: 999.999, M: 666.668 dengan belum dilabeli (D > 0)',
      () {
        final hasil = formatPerbandinganPolaAnggaran(
          pemasukan: 3333333,
          kebutuhan: 1800000,
          keinginan: 700000,
          tabunganDanUtang: 500000,
          belumDilabeli: 333333,
        );

        expect(
          hasil,
          equals(
            'Pemasukanmu bulan ini: Rp3.333.333. '
            'Anggaran buatanmu: kebutuhan Rp1.800.000, keinginan Rp700.000, tabungan dan utang Rp500.000, belum dilabeli Rp333.333. '
            'Sebagai perbandingan, pola populer 50/30/20 dari pemasukan yang sama: kebutuhan Rp1.666.666, keinginan Rp999.999, tabungan dan utang Rp666.668. '
            'Keduanya titik awal. Sesuaikan dengan kondisimu.',
          ),
        );
      },
    );

    test('Pemasukan 0 -> minta catat pemasukan bulan ini dulu', () {
      final hasil = formatPerbandinganPolaAnggaran(
        pemasukan: 0,
        kebutuhan: 1000000,
        keinginan: 500000,
        tabunganDanUtang: 200000,
      );

      expect(
        hasil,
        equals(
          'Catat pemasukan bulan ini dulu agar perbandingan bisa dihitung.',
        ),
      );
    });
  });

  group('3. Pengujian Umpan Balik: realisasi_anggaran_bulan_ini', () {
    test('Uji angka tangan: Makan Harian, Transportasi, Jajan & Nongkrong', () {
      final daftarPos = [
        const PosAnggaranEvaluasi(
          nama: 'Makan Harian',
          batas: 800000,
          terpakai: 560000,
        ), // 70% -> aman, sisa 240.000
        const PosAnggaranEvaluasi(
          nama: 'Transportasi',
          batas: 300000,
          terpakai: 255000,
        ), // 85% -> mendekati, sisa 45.000
        const PosAnggaranEvaluasi(
          nama: 'Jajan & Nongkrong',
          batas: 300000,
          terpakai: 345000,
        ), // 115% -> melewati, lebih 45.000
      ];

      final hasil = formatRealisasiAnggaranBulanIni(daftarPos);

      expect(
        hasil,
        equals(
          'Dari 3 pos anggaran: 1 masih aman, 1 mendekati batas, 1 melewati batas. '
          'Pos dengan sisa terbanyak: Makan Harian (sisa Rp240.000). '
          'Pos yang melewati batas paling jauh: Jajan & Nongkrong (lebih Rp45.000). '
          'Ini bahan belajar, bukan penilaian.',
        ),
      );
    });

    test(
      'Tanpa pos anggaran menghasilkan teks belum ada anggaran bulan ini',
      () {
        final hasil = formatRealisasiAnggaranBulanIni([]);
        expect(hasil, equals('Belum ada anggaran bulan ini.'));
      },
    );

    test('Semua pos aman tanpa ada yang melewati batas', () {
      final daftarPos = [
        const PosAnggaranEvaluasi(
          nama: 'Makan Harian',
          batas: 800000,
          terpakai: 400000,
        ), // sisa 400.000
        const PosAnggaranEvaluasi(
          nama: 'Listrik',
          batas: 200000,
          terpakai: 150000,
        ), // sisa 50.000
      ];

      final hasil = formatRealisasiAnggaranBulanIni(daftarPos);

      expect(
        hasil,
        equals(
          'Dari 2 pos anggaran: 2 masih aman, 0 mendekati batas, 0 melewati batas. '
          'Pos dengan sisa terbanyak: Makan Harian (sisa Rp400.000). '
          'Ini bahan belajar, bukan penilaian.',
        ),
      );
    });
  });
}
