import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PembacaKonten Unit & Validasi Format Konten', () {
    test('Urai kamus valid dan tangani format rusak', () {
      const kamusValid = '''
      [
        {
          "istilah": "arus kas",
          "arti": "Selisih pemasukan dan pengeluaran.",
          "contohRupiah": "Rp500.000 per bulan"
        }
      ]
      ''';
      final kamus = PembacaKonten.uraiKamus(kamusValid);
      expect(kamus.containsKey('arus kas'), isTrue);
      expect(kamus['arus kas']!.arti, equals('Selisih pemasukan dan pengeluaran.'));

      // Format bukan array
      expect(
        () => PembacaKonten.uraiKamus('{"bukan": "array"}'),
        throwsA(isA<GalatKonten>()),
      );

      // Kolom wajib kosong
      const kamusKosong = '[{"istilah": "", "arti": "x", "contohRupiah": "y"}]';
      expect(
        () => PembacaKonten.uraiKamus(kamusKosong),
        throwsA(isA<GalatKonten>()),
      );
    });

    test('Urai modul valid dan tangkap galat kolom wajib', () {
      const modulValid = '''
      {
        "id": "anggaran_arus_kas",
        "judul": "Anggaran & Arus Kas",
        "tingkat": "pemula",
        "urutan": 1,
        "deskripsiSingkat": "Deskripsi",
        "tersedia": true,
        "gerbang": [],
        "daftarPelajaran": ["anggaran_arus_kas_1_2"],
        "kuis": { "jumlahSoal": 1, "bankSoal": [] }
      }
      ''';
      final modul = PembacaKonten.uraiModul(modulValid);
      expect(modul.id, equals('anggaran_arus_kas'));
      expect(modul.tersedia, isTrue);

      // Tingkat tidak valid
      const modulTingkatSalah = '''
      {
        "id": "x",
        "judul": "y",
        "tingkat": "expert",
        "urutan": 1,
        "tersedia": true,
        "daftarPelajaran": []
      }
      ''';
      expect(
        () => PembacaKonten.uraiModul(modulTingkatSalah),
        throwsA(isA<GalatKonten>()),
      );
    });

    test('Validasi ketat pelajaran: batas kartu, durasi, format ID stabil', () {
      // Lebih dari 3 kartu -> Galat!
      const pelajaran4Kartu = '''
      {
        "id": "modul_1_2",
        "judul": "Judul",
        "durasiMenit": 4,
        "status": "draf",
        "pemantik": "Pemantik",
        "kartu": [
          {"judul": "K1", "isi": "I1"},
          {"judul": "K2", "isi": "I2"},
          {"judul": "K3", "isi": "I3"},
          {"judul": "K4", "isi": "I4"}
        ],
        "contohAngka": 1000,
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "dompet", "min": 1}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(pelajaran4Kartu, namaBerkas: 'uji.json'),
        throwsA(isA<GalatKonten>()),
      );

      // ID tidak berformat <modul>_<nomor>
      const pelajaranIdSalah = '''
      {
        "id": "id-tidak-stabil",
        "judul": "Judul",
        "durasiMenit": 4,
        "status": "draf",
        "kartu": [{"judul": "K1", "isi": "I1"}],
        "contohAngka": 1000,
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "dompet", "min": 1}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(pelajaranIdSalah, namaBerkas: 'uji.json'),
        throwsA(isA<GalatKonten>()),
      );
    });

    test('Pemeriksa istilah kamus: istilah {{...}} wajib ada di kamus', () {
      const pelajaranIstilahSalah = '''
      {
        "id": "modul_1_2",
        "judul": "Judul",
        "durasiMenit": 4,
        "status": "draf",
        "pemantik": "Mengenal {{istilah_fiktif_gaib}}",
        "kartu": [{"judul": "K1", "isi": "Isi kartu"}],
        "contohAngka": 1000,
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "dompet", "min": 1}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(
          pelajaranIstilahSalah,
          namaBerkas: 'uji.json',
          daftarIstilahKamus: {'arus kas', 'kebutuhan'},
        ),
        throwsA(isA<GalatKonten>()),
      );
    });

    test('Pemeriksa bahasa: kata terlarang memicu galat, kalimat > 25 kata memicu peringatan', () {
      expect(
        () => PembacaKonten.periksaBahasaTeks('Kamu sangat boros sekali!', namaBerkas: 'uji.json'),
        throwsA(isA<GalatKonten>()),
      );
      expect(
        () => PembacaKonten.periksaBahasaTeks('Itu adalah perilaku salah.', namaBerkas: 'uji.json'),
        throwsA(isA<GalatKonten>()),
      );

      final peringatan = <String>[];
      final kalimatPanjang = '${List.generate(28, (i) => 'kata$i').join(' ')}.';
      PembacaKonten.periksaBahasaTeks(kalimatPanjang, namaBerkas: 'uji.json', daftarPeringatan: peringatan);
      expect(peringatan.length, equals(1));
    });
  });

  group('Pemeriksa Konten Nyata di Repositori (aset/konten)', () {
    test('Semua berkas kamus, modul, dan pelajaran di repo lolos validasi ketat', () {
      final berkasKamus = File('aset/konten/kamus.json');
      expect(berkasKamus.existsSync(), isTrue, reason: 'Berkas kamus.json wajib ada');

      final mapKamus = PembacaKonten.uraiKamus(berkasKamus.readAsStringSync());
      expect(mapKamus.length, greaterThanOrEqualTo(8));
      final daftarIstilahKamus = mapKamus.keys.toSet();

      final dirKonten = Directory('aset/konten');
      final semuaBerkasJson = dirKonten
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.json') &&
              !f.path.endsWith('kamus.json') &&
              !f.path.endsWith('rekomendasi.json') &&
              !f.path.endsWith('tes_awal.json'))
          .toList();

      expect(semuaBerkasJson.length, greaterThanOrEqualTo(19), reason: 'Minimal 19 modul (modul 0..18)');

      final daftarPeringatan = <String>[];

      for (final berkas in semuaBerkasJson) {
        final konten = berkas.readAsStringSync();
        final namaBerkas = berkas.path;

        if (berkas.path.endsWith('modul.json')) {
          final modul = PembacaKonten.uraiModul(konten, namaBerkas: namaBerkas);
          expect(modul.id, isNotEmpty);
        } else {
          // Berkas pelajaran
          final pelajaran = PembacaKonten.uraiPelajaran(
            konten,
            namaBerkas: namaBerkas,
            daftarIstilahKamus: daftarIstilahKamus,
            daftarPeringatan: daftarPeringatan,
          );
          expect(pelajaran.kartu.length, inInclusiveRange(1, 3));
          expect(pelajaran.durasiMenit, inInclusiveRange(3, 8));
        }
      }
    });
  });
}
