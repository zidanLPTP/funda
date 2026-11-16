import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';

void main() {
  group('Butir C.1: Pemeriksa Konten Rusak (9+ Kasus dengan Nama Berkas & Kolom Terstruktur)', () {
    // 1. kamus.json bukan format array
    test('1. kamus.json: format bukan array', () {
      expect(
        () => PembacaKonten.uraiKamus('{"bukan": "array"}', namaBerkas: 'kamus.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'kamus.json' && e.pesan.contains('array'))),
      );
    });

    // 2. kamus.json: istilah kosong
    test('2. kamus.json: kolom istilah kosong', () {
      const jsonStr = '[{"istilah": "", "arti": "Definisi", "contohRupiah": "Rp100"}]';
      expect(
        () => PembacaKonten.uraiKamus(jsonStr, namaBerkas: 'kamus.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'kamus.json' && e.kolom == 'istilah')),
      );
    });

    // 3. kamus.json: arti kosong
    test('3. kamus.json: kolom arti kosong', () {
      const jsonStr = '[{"istilah": "Arus Kas", "arti": "  ", "contohRupiah": "Rp100"}]';
      expect(
        () => PembacaKonten.uraiKamus(jsonStr, namaBerkas: 'kamus.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'kamus.json' && e.kolom == 'arti')),
      );
    });

    // 4. kamus.json: contohRupiah tidak ada
    test('4. kamus.json: kolom contohRupiah tidak ada', () {
      const jsonStr = '[{"istilah": "Arus Kas", "arti": "Definisi"}]';
      expect(
        () => PembacaKonten.uraiKamus(jsonStr, namaBerkas: 'kamus.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'kamus.json' && e.kolom == 'contohRupiah')),
      );
    });

    // 5. modul.json: bukan objek JSON
    test('5. modul.json: format bukan objek', () {
      expect(
        () => PembacaKonten.uraiModul('["bukan", "objek"]', namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json')),
      );
    });

    // 6. modul.json: kolom id kosong
    test('6. modul.json: kolom id kosong', () {
      const jsonStr = '{"id": "", "judul": "Judul", "tingkat": "pemula"}';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'id')),
      );
    });

    // 7. modul.json: kolom judul kosong
    test('7. modul.json: kolom judul kosong', () {
      const jsonStr = '{"id": "modul_1", "judul": "", "tingkat": "pemula"}';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'judul')),
      );
    });

    // 8. modul.json: tingkat tidak valid (harus pemula, menengah, atau lanjutan)
    test('8. modul.json: tingkat di luar pemula/menengah/lanjutan', () {
      const jsonStr = '{"id": "modul_1", "judul": "Judul", "tingkat": "ahli"}';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'tingkat')),
      );
    });

    // 9. modul.json: kuis jumlahSoal <= 0
    test('9. modul.json: kolom kuis.jumlahSoal bernilai <= 0', () {
      const jsonStr = '''
      {
        "id": "modul_1",
        "judul": "Judul",
        "tingkat": "pemula",
        "urutan": 1,
        "deskripsiSingkat": "Deskripsi",
        "tersedia": true,
        "daftarPelajaran": ["modul_1_1"],
        "kuis": {"jumlahSoal": 0, "bankSoal": []}
      }
      ''';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'kuis.jumlahSoal')),
      );
    });

    // 10. pelajaran.json: durasiMenit <= 0
    test('10. pelajaran.json: durasiMenit <= 0', () {
      const jsonStr = '''
      {
        "id": "modul_1_1",
        "modulId": "modul_1",
        "judul": "Judul",
        "durasiMenit": 0,
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [{"tanya": "T", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P"}],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'durasiMenit')),
      );
    });

    // 11. pelajaran.json: cekPaham benar di luar indeks pilihan
    test('11. pelajaran.json: cekPaham indeks benar di luar rentang pilihan', () {
      const jsonStr = '''
      {
        "id": "modul_1_1",
        "modulId": "modul_1",
        "judul": "Judul",
        "durasiMenit": 5,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 5, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'cekPaham.benar')),
      );
    });

    // 12. pelajaran.json: misi min < 1
    test('12. pelajaran.json: misi min < 1', () {
      const jsonStr = '''
      {
        "id": "modul_1_1",
        "modulId": "modul_1",
        "judul": "Judul",
        "durasiMenit": 5,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 0, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'misi.min')),
      );
    });
  });
}
