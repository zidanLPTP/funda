import 'package:flutter_test/flutter_test.dart';
import 'package:funda/util/format_rupiah.dart';

void main() {
  group('formatRupiah', () {
    test('memformat angka nol dengan benar', () {
      expect(formatRupiah(0), equals('Rp 0'));
    });

    test('memformat angka positif normal dengan pemisah ribuan titik', () {
      expect(formatRupiah(500), equals('Rp 500'));
      expect(formatRupiah(1000), equals('Rp 1.000'));
      expect(formatRupiah(1250000), equals('Rp 1.250.000'));
    });

    test('memformat angka negatif dengan awalan minus sebelum Rp', () {
      expect(formatRupiah(-300000), equals('-Rp 300.000'));
      expect(formatRupiah(-50), equals('-Rp 50'));
    });

    test('memformat nominal besar (>= 1 miliar)', () {
      expect(formatRupiah(1000000000), equals('Rp 1.000.000.000'));
      expect(formatRupiah(2500000000), equals('Rp 2.500.000.000'));
      expect(formatRupiah(1000000000000), equals('Rp 1.000.000.000.000'));
    });
  });

  group('ambilAngkaRupiah', () {
    test('mengonversi teks format Rupiah lengkap menjadi int', () {
      expect(ambilAngkaRupiah('Rp 1.250.000'), equals(1250000));
      expect(ambilAngkaRupiah('Rp 0'), equals(0));
      expect(ambilAngkaRupiah('Rp 500'), equals(500));
    });

    test('mengonversi teks tanpa awalan Rp dan dengan titik', () {
      expect(ambilAngkaRupiah('1.250.000'), equals(1250000));
      expect(ambilAngkaRupiah('50.000'), equals(50000));
    });

    test('mengonversi teks angka polos', () {
      expect(ambilAngkaRupiah('1250000'), equals(1250000));
      expect(ambilAngkaRupiah('0'), equals(0));
    });

    test('mengonversi teks negatif', () {
      expect(ambilAngkaRupiah('-Rp 300.000'), equals(-300000));
      expect(ambilAngkaRupiah('-300000'), equals(-300000));
      expect(ambilAngkaRupiah('−Rp 300.000'), equals(-300000));
    });

    test('mengonversi nominal besar (>= 1 miliar)', () {
      expect(ambilAngkaRupiah('Rp 2.500.000.000'), equals(2500000000));
    });

    test('melempar GalatFormatRupiah untuk masukan tidak valid', () {
      expect(() => ambilAngkaRupiah(''), throwsA(isA<GalatFormatRupiah>()));
      expect(() => ambilAngkaRupiah('   '), throwsA(isA<GalatFormatRupiah>()));
      expect(
        () => ambilAngkaRupiah('bukan angka'),
        throwsA(isA<GalatFormatRupiah>()),
      );
      expect(
        () => ambilAngkaRupiah('Rp abc'),
        throwsA(isA<GalatFormatRupiah>()),
      );
      expect(
        () => ambilAngkaRupiah('Rp 10.000,50'),
        throwsA(isA<GalatFormatRupiah>()),
      );
    });
  });
}
