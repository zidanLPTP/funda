import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_beranda.dart';

void main() {
  group('Perhitungan Sapaan Kontekstual Beranda', () {
    test('Sapaan pagi (jam 07:00, tanggal pertengahan bulan)', () {
      final waktu = DateTime(2026, 3, 15, 7, 0);
      final hasil = hitungSapaanKontekstual(waktu);
      expect(hasil.sapaan, equals('Selamat pagi'));
      expect(hasil.pesanMotivasi, contains('Awali hari dengan tenang'));
    });

    test('Sapaan siang (jam 13:00, tanggal pertengahan bulan)', () {
      final waktu = DateTime(2026, 3, 15, 13, 0);
      final hasil = hitungSapaanKontekstual(waktu);
      expect(hasil.sapaan, equals('Selamat siang'));
      expect(hasil.pesanMotivasi, contains('makan siangmu'));
    });

    test('Sapaan sore (jam 16:30, tanggal pertengahan bulan)', () {
      final waktu = DateTime(2026, 3, 15, 16, 30);
      final hasil = hitungSapaanKontekstual(waktu);
      expect(hasil.sapaan, equals('Selamat sore'));
      expect(hasil.pesanMotivasi, contains('Sore yang baik'));
    });

    test('Sapaan malam (jam 21:00, tanggal pertengahan bulan)', () {
      final waktu = DateTime(2026, 3, 15, 21, 0);
      final hasil = hitungSapaanKontekstual(waktu);
      expect(hasil.sapaan, equals('Selamat malam'));
      expect(hasil.pesanMotivasi, contains('Tutup hari dengan tenang'));
    });

    test('Pesan khusus awal bulan (tanggal 1-5)', () {
      final waktu = DateTime(2026, 4, 3, 9, 0);
      final hasil = hitungSapaanKontekstual(waktu);
      expect(hasil.sapaan, equals('Selamat pagi'));
      expect(hasil.pesanMotivasi, contains('pos anggaran'));
    });

    test('Pesan khusus akhir bulan (tanggal 25-31)', () {
      final waktu = DateTime(2026, 4, 28, 14, 0);
      final hasil = hitungSapaanKontekstual(waktu);
      expect(hasil.sapaan, equals('Selamat siang'));
      expect(hasil.pesanMotivasi, contains('Laporan Bulanan'));
    });
  });
}
