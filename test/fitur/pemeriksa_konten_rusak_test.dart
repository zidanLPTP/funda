import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';

void main() {
  group('Butir B.3 & B.4: Pemeriksa Konten Rusak & Pemeriksa Bahasa Lengkap', () {
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

    // 10. modul.json: ID pelajaran duplikat di daftarPelajaran
    test('10. modul.json: ID duplikat pada daftarPelajaran', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas",
        "judul": "Anggaran & Arus Kas",
        "tingkat": "pemula",
        "urutan": 1,
        "deskripsiSingkat": "Deskripsi",
        "tersedia": true,
        "daftarPelajaran": ["anggaran_arus_kas_1_2", "anggaran_arus_kas_1_2"],
        "kuis": {"jumlahSoal": 1, "bankSoal": []}
      }
      ''';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'daftarPelajaran' && e.pesan.contains('duplikat'))),
      );
    });

    // 11. modul.json: ID soal kuis duplikat
    test('11. modul.json: ID duplikat pada bankSoal kuis', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas",
        "judul": "Anggaran & Arus Kas",
        "tingkat": "pemula",
        "urutan": 1,
        "deskripsiSingkat": "Deskripsi",
        "tersedia": true,
        "daftarPelajaran": ["anggaran_arus_kas_1_2"],
        "kuis": {
          "jumlahSoal": 1,
          "bankSoal": [
            {"id": "soal_1", "pelajaranId": "anggaran_arus_kas_1_2", "tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
            {"id": "soal_1", "pelajaranId": "anggaran_arus_kas_1_2", "tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
          ]
        }
      }
      ''';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.pesan.contains('duplikat'))),
      );
    });

    // 12. modul.json: soal kuis mereferensikan pelajaranId yang tidak ada
    test('12. modul.json: referensi pelajaranId soal kuis tidak ada di daftarPelajaran', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas",
        "judul": "Anggaran & Arus Kas",
        "tingkat": "pemula",
        "urutan": 1,
        "deskripsiSingkat": "Deskripsi",
        "tersedia": true,
        "daftarPelajaran": ["anggaran_arus_kas_1_2"],
        "kuis": {
          "jumlahSoal": 1,
          "bankSoal": [
            {"id": "soal_1", "pelajaranId": "pelajaran_fiktif_99", "tanya": "T", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P"}
          ]
        }
      }
      ''';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.pesan.contains('tidak terdaftar'))),
      );
    });

    // 13. modul.json: objek gerbang tidak dikenal
    test('13. modul.json: referensi objek gerbang data tidak dikenal', () {
      const jsonStr = '''
      {
        "id": "modul_1",
        "judul": "Judul",
        "tingkat": "pemula",
        "urutan": 1,
        "deskripsiSingkat": "Deskripsi",
        "tersedia": true,
        "gerbang": [{"tipe": "ada_data", "objek": "crypto_wallet", "min": 1, "pesan": "Hubungkan wallet"}],
        "daftarPelajaran": ["modul_1_1"],
        "kuis": {"jumlahSoal": 1, "bankSoal": []}
      }
      ''';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'gerbang[0].objek')),
      );
    });

    // 14. pelajaran.json: ID tidak berformat stabil <modul>_<nomor>
    test('14. pelajaran.json: ID tidak berformat stabil <modul>_<nomor>', () {
      const jsonStr = '''
      {
        "id": "pelajaran-bebas-tanpa-nomor",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 4,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'id' && e.pesan.contains('stabil'))),
      );
    });

    // 15. pelajaran.json: durasi di luar 3 sampai 8 menit
    test('15. pelajaran.json: durasi di luar rentang 3 sampai 8 menit (< 3 atau > 8)', () {
      const jsonKurang = '''
      {
        "id": "anggaran_arus_kas_1_2",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 2,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonKurang, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'durasiMenit')),
      );

      const jsonLebih = '''
      {
        "id": "anggaran_arus_kas_1_2",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 10,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonLebih, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'durasiMenit')),
      );
    });

    // 16. pelajaran.json: kartu > 3
    test('16. pelajaran.json: kartu lebih dari 3 kartu konsep', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas_1_2",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 5,
        "status": "draf",
        "kartu": [
          {"judul": "J1", "isi": "I1"},
          {"judul": "J2", "isi": "I2"},
          {"judul": "J3", "isi": "I3"},
          {"judul": "J4", "isi": "I4"}
        ],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'kartu')),
      );
    });

    // 17. pelajaran.json: istilah {{...}} tidak ada di kamus
    test('17. pelajaran.json: istilah {{istilah_asing}} tidak terdaftar di kamus.json', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas_1_2",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 5,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "Pahami konsep {{istilah_tidak_ada}} sekarang."}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "ada_data", "objek": "transaksi", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json', daftarIstilahKamus: {'arus kas', 'kebutuhan'}),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.pesan.contains('tidak ditemukan di kamus.json'))),
      );
    });

    // 18. pelajaran.json: jenis misi yang belum didukung (misal: simulasi_investasi)
    test('18. pelajaran.json: jenis misi yang belum didukung ditolak', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas_1_2",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 5,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {"tipe": "simulasi_saham_ai", "min": 1, "judul": "M", "deskripsi": "D", "perkiraanMenit": 2}
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'misi.tipe' && e.pesan.contains('belum didukung'))),
      );
    });

    // 19. pelajaran.json: umpan balik misi tidak dikenal
    test('19. pelajaran.json: referensi umpanBalik misi tidak terdaftar di registri', () {
      const jsonStr = '''
      {
        "id": "anggaran_arus_kas_1_2",
        "modulId": "anggaran_arus_kas",
        "judul": "Judul",
        "durasiMenit": 5,
        "status": "draf",
        "kartu": [{"judul": "J", "isi": "I"}],
        "cekPaham": [
          {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
          {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
        ],
        "misi": {
          "tipe": "ada_data",
          "objek": "transaksi",
          "min": 1,
          "judul": "M",
          "deskripsi": "D",
          "perkiraanMenit": 2,
          "umpanBalik": "prediksi_cuan_masa_depan"
        }
      }
      ''';
      expect(
        () => PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'pelajaran.json' && e.kolom == 'misi.umpanBalik')),
      );
    });

    // 20. Pemeriksa Bahasa: Uji Positif Kata Terlarang (boros, bodoh, malas, dll)
    test('20. Pemeriksa bahasa: konten sintetis berisi kata terlarang harus GAGAL', () {
      const teksBoros = 'Jangan boros saat berbelanja bulanan.';
      expect(
        () => PembacaKonten.periksaBahasaTeks(teksBoros, namaBerkas: 'uji_bahasa.json'),
        throwsA(predicate((e) => e is GalatKonten && e.pesan.contains('boros'))),
      );

      const teksMenghakimi = 'Cara yang kamu lakukan ini salah dan merugikan.';
      expect(
        () => PembacaKonten.periksaBahasaTeks(teksMenghakimi, namaBerkas: 'uji_bahasa.json'),
        throwsA(predicate((e) => e is GalatKonten && e.pesan.contains('salah'))),
      );
    });

    // 21. Pemeriksa Bahasa: Uji Positif Istilah Teknis Polos tanpa {{ }} (defisit/surplus)
    test('21. Pemeriksa bahasa: istilah teknis polos tanpa {{ }} (misal versi lama 1_3 "defisit") harus GAGAL', () {
      // Kalimat persis baris 44 versi lama anggaran_arus_kas_1_3.json
      const kalimatLamaBaris44 = 'Saat arus kas bulananmu mulai terasa sesak atau defisit';
      expect(
        () => PembacaKonten.periksaBahasaTeks(kalimatLamaBaris44, namaBerkas: 'anggaran_arus_kas_1_3.json'),
        throwsA(predicate((e) => e is GalatKonten && e.pesan.contains('defisit') && e.pesan.contains('tooltip'))),
      );

      // Kalimat yang sudah diperbaiki dengan {{defisit}} harus LOLOS
      const kalimatBaruBaris44 = 'Saat arus kas bulananmu mulai terasa sesak atau {{defisit}}';
      expect(
        () => PembacaKonten.periksaBahasaTeks(kalimatBaruBaris44, namaBerkas: 'anggaran_arus_kas_1_3.json'),
        returnsNormally,
      );
    });

    // 22. Pemeriksa Bahasa: Kalimat > 25 kata menghasilkan peringatan
    test('22. Pemeriksa bahasa: kalimat > 25 kata menghasilkan peringatan terdaftar', () {
      const kalimatPanjang = 'Setiap rupiah yang masuk ke dalam dompetmu adalah hasil dari kerja kerasmu sendiri dan kamu berhak mengalokasikannya dengan penuh rasa bangga dan bahagia untuk masa depan yang cerah.';
      final daftarPeringatan = <String>[];
      PembacaKonten.periksaBahasaTeks(kalimatPanjang, namaBerkas: 'uji_panjang.json', daftarPeringatan: daftarPeringatan);
      expect(daftarPeringatan.length, 1);
      expect(daftarPeringatan.first, contains('Kalimat panjang'));
    });

    // 23. Pemeriksa Konten: Misi otomatis terpenuhi oleh gerbang pelajaran sendiri GAGAL
    test('23. Pemeriksa konten: misi ada_data otomatis terpenuhi oleh gerbang pelajaran sendiri harus GAGAL', () {
      final pelajaranRusak = {
        'id': 'modul_uji_1_1',
        'judul': 'Uji Pelajaran',
        'durasiMenit': 4,
        'status': 'draf',
        'gerbang': [
          {'tipe': 'ada_data', 'objek': 'pemasukan', 'min': 1, 'pesan': 'Catat 1 pemasukan'}
        ],
        'pemantik': 'Pemantik singkat.',
        'kartu': [
          {'judul': 'Kartu 1', 'isi': 'Isi kartu konsep.'}
        ],
        'contohAngka': 100000,
        'cekPaham': [
          {'tanya': 'Tanya 1', 'pilihan': ['A', 'B'], 'benar': 0, 'penjelasan': 'P1'},
          {'tanya': 'Tanya 2', 'pilihan': ['A', 'B'], 'benar': 1, 'penjelasan': 'P2'}
        ],
        'misi': {
          'tipe': 'ada_data',
          'objek': 'pemasukan',
          'min': 1,
          'judul': 'Misi Sama',
          'deskripsi': 'Deskripsi',
          'perkiraanMenit': 2,
          'umpanBalik': 'arus_kas_bulan_ini'
        }
      };

      expect(
        () => PembacaKonten.validasiKontenPelajaran(pelajaranRusak, namaBerkas: 'pelajaran_rusak.json'),
        throwsA(predicate((e) => e is GalatKonten && e.pesan.contains('otomatis terpenuhi oleh gerbang'))),
      );
    });

    // 24. Pemeriksa Konten: Misi bertipe lihat_hitungan atau beda objek LOLOS (uji positif)
    test('24. Pemeriksa konten: misi lihat_hitungan atau objek beda dengan gerbang harus LOLOS', () {
      final pelajaranValid = {
        'id': 'modul_uji_1_2',
        'judul': 'Uji Pelajaran Valid',
        'durasiMenit': 4,
        'status': 'draf',
        'gerbang': [
          {'tipe': 'ada_data', 'objek': 'dompet', 'min': 1, 'pesan': 'Buat 1 dompet'}
        ],
        'pemantik': 'Pemantik singkat.',
        'kartu': [
          {'judul': 'Kartu 1', 'isi': 'Isi kartu konsep.'}
        ],
        'contohAngka': 100000,
        'cekPaham': [
          {'tanya': 'Tanya 1', 'pilihan': ['A', 'B'], 'benar': 0, 'penjelasan': 'P1'},
          {'tanya': 'Tanya 2', 'pilihan': ['A', 'B'], 'benar': 1, 'penjelasan': 'P2'}
        ],
        'misi': {
          'tipe': 'ada_data',
          'objek': 'arus_kas',
          'min': 1,
          'judul': 'Misi Arus Kas',
          'deskripsi': 'Deskripsi',
          'perkiraanMenit': 2,
          'umpanBalik': 'arus_kas_bulan_ini'
        }
      };

      expect(
        () => PembacaKonten.validasiKontenPelajaran(pelajaranValid, namaBerkas: 'pelajaran_valid.json'),
        returnsNormally,
      );

      final pelajaranLihatHitungan = Map<String, dynamic>.from(pelajaranValid)
        ..['id'] = 'modul_uji_1_3'
        ..['gerbang'] = [
          {'tipe': 'ada_data', 'objek': 'pemasukan', 'min': 1}
        ]
        ..['misi'] = {
          'tipe': 'lihat_hitungan',
          'judul': 'Misi Lihat Hitungan',
          'deskripsi': 'Deskripsi',
          'perkiraanMenit': 1,
        };

      expect(
        () => PembacaKonten.validasiKontenPelajaran(pelajaranLihatHitungan, namaBerkas: 'pelajaran_lihat.json'),
        returnsNormally,
      );
    });

    // -------------------------------------------------------------------------
    // Pengujian Validasi Konten Tes Awal (tes_awal.json) Rusak (Tahap 5)
    // -------------------------------------------------------------------------
    group('Pengujian Validasi Konten Tes Awal (tes_awal.json) Rusak', () {
      test('1. tes_awal.json bukan objek JSON', () {
        expect(
          () => PembacaKonten.uraiTesAwal('["bukan", "objek"]', namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.berkas == 'tes_awal.json')),
        );
      });

      test('2. tes_awal.json pertanyaanProfil kurang dari 6', () {
        final jsonStr = '''
        {
          "judul": "Tes Awal",
          "deskripsi": "Deskripsi",
          "pertanyaanProfil": [
            {"kunci": "punya_penghasilan", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}]}
          ],
          "tujuanUtama": {"tanya": "Tanya?", "petunjuk": "P", "maksimalKarakter": 100},
          "soalTesAwal": []
        }
        ''';
        expect(
          () => PembacaKonten.uraiTesAwal(jsonStr, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom == 'pertanyaanProfil')),
        );
      });

      test('3. tes_awal.json pertanyaanProfil kunci tidak dikenal', () {
        final jsonStr = '''
        {
          "judul": "Tes Awal",
          "deskripsi": "Deskripsi",
          "pertanyaanProfil": [
            {"kunci": "kunci_ajaib_salah", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}, {"nilai": "b", "teks": "B"}]},
            {"kunci": "punya_utang", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}, {"nilai": "b", "teks": "B"}]},
            {"kunci": "dana_darurat", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}, {"nilai": "b", "teks": "B"}]},
            {"kunci": "menabung", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}, {"nilai": "b", "teks": "B"}]},
            {"kunci": "investasi", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}, {"nilai": "b", "teks": "B"}]},
            {"kunci": "mencatat_keuangan", "tanya": "Tanya?", "pilihan": [{"nilai": "a", "teks": "A"}, {"nilai": "b", "teks": "B"}]}
          ],
          "tujuanUtama": {"tanya": "Tanya?", "petunjuk": "P", "maksimalKarakter": 100},
          "soalTesAwal": []
        }
        ''';
        expect(
          () => PembacaKonten.uraiTesAwal(jsonStr, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('kunci') == true)),
        );
      });

      test('4. tes_awal.json jumlah soal bukan 12', () {
        final jsonStr = '''
        {
          "judul": "Tes Awal",
          "deskripsi": "Deskripsi",
          "pertanyaanProfil": [
            {"kunci": "punya_penghasilan", "tanya": "Tanya?", "pilihan": [{"nilai": "rutin", "teks": "A"}, {"nilai": "belum", "teks": "B"}]},
            {"kunci": "punya_utang", "tanya": "Tanya?", "pilihan": [{"nilai": "ya", "teks": "A"}, {"nilai": "tidak", "teks": "B"}]},
            {"kunci": "dana_darurat", "tanya": "Tanya?", "pilihan": [{"nilai": "belum", "teks": "A"}, {"nilai": "sudah", "teks": "B"}]},
            {"kunci": "menabung", "tanya": "Tanya?", "pilihan": [{"nilai": "kadang", "teks": "A"}, {"nilai": "rutin", "teks": "B"}]},
            {"kunci": "investasi", "tanya": "Tanya?", "pilihan": [{"nilai": "belum", "teks": "A"}, {"nilai": "aktif", "teks": "B"}]},
            {"kunci": "mencatat_keuangan", "tanya": "Tanya?", "pilihan": [{"nilai": "belum", "teks": "A"}, {"nilai": "rutin", "teks": "B"}]}
          ],
          "tujuanUtama": {"tanya": "Tanya?", "petunjuk": "P", "maksimalKarakter": 100},
          "soalTesAwal": [
            {
              "id": "s1", "modulId": "anggaran_arus_kas", "tanya": "T?", "pilihan": ["A", "B", "C", "Belum tahu, nggak apa-apa"], "benar": 0, "penjelasan": "P"
            }
          ]
        }
        ''';
        expect(
          () => PembacaKonten.uraiTesAwal(jsonStr, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom == 'soalTesAwal')),
        );
      });

      test('5. tes_awal.json opsi ke-4 bukan "Belum tahu, nggak apa-apa"', () {
        // Buat 12 soal tetapi soal pertama opsi ke-4 nya bukan standar
        final modulList = ['anggaran_arus_kas', 'tabungan', 'dana_darurat', 'utang_cicilan', 'waspada_penipuan', 'psikologi_uang'];
        final daftarSoal = <Map<String, dynamic>>[];
        var idCounter = 1;
        for (final m in modulList) {
          for (var i = 1; i <= 2; i++) {
            final nomor = idCounter++;
            daftarSoal.add({
              'id': 's_$nomor',
              'modulId': m,
              'tanya': 'Pertanyaan soal?',
              'pilihan': ['A', 'B', 'C', nomor == 1 ? 'Pilihan Sembarangan' : 'Belum tahu, nggak apa-apa'],
              'benar': 0,
              'penjelasan': 'Penjelasan jawaban.',
            });
          }
        }

        final data = {
          'judul': 'Tes Awal',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [
            {'kunci': 'punya_penghasilan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'rutin', 'teks': 'A'}, {'nilai': 'belum', 'teks': 'B'}]},
            {'kunci': 'punya_utang', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'ya', 'teks': 'A'}, {'nilai': 'tidak', 'teks': 'B'}]},
            {'kunci': 'dana_darurat', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'sudah', 'teks': 'B'}]},
            {'kunci': 'menabung', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'kadang', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]},
            {'kunci': 'investasi', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'aktif', 'teks': 'B'}]},
            {'kunci': 'mencatat_keuangan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]}
          ],
          'tujuanUtama': {'tanya': 'Tanya?', 'petunjuk': 'P', 'maksimalKarakter': 100},
          'soalTesAwal': daftarSoal,
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(data, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('pilihan[3]') == true)),
        );
      });

      test('6. tes_awal.json soal mereferensikan modulId tidak valid', () {
        final modulList = ['anggaran_arus_kas', 'tabungan', 'dana_darurat', 'utang_cicilan', 'waspada_penipuan', 'modul_salah_tidak_ada'];
        final daftarSoal = <Map<String, dynamic>>[];
        var idCounter = 1;
        for (final m in modulList) {
          for (var i = 1; i <= 2; i++) {
            final nomor = idCounter++;
            daftarSoal.add({
              'id': 's_$nomor',
              'modulId': m,
              'tanya': 'Pertanyaan soal?',
              'pilihan': ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
              'benar': 0,
              'penjelasan': 'Penjelasan jawaban.',
            });
          }
        }

        final data = {
          'judul': 'Tes Awal',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [
            {'kunci': 'punya_penghasilan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'rutin', 'teks': 'A'}, {'nilai': 'belum', 'teks': 'B'}]},
            {'kunci': 'punya_utang', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'ya', 'teks': 'A'}, {'nilai': 'tidak', 'teks': 'B'}]},
            {'kunci': 'dana_darurat', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'sudah', 'teks': 'B'}]},
            {'kunci': 'menabung', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'kadang', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]},
            {'kunci': 'investasi', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'aktif', 'teks': 'B'}]},
            {'kunci': 'mencatat_keuangan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]}
          ],
          'tujuanUtama': {'tanya': 'Tanya?', 'petunjuk': 'P', 'maksimalKarakter': 100},
          'soalTesAwal': daftarSoal,
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(data, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('modulId') == true)),
        );
      });

      test('7. tes_awal.json nilai pilihan profil tidak cocok dengan skema database', () {
        final data = {
          'judul': 'Tes Awal',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [
            {'kunci': 'punya_penghasilan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'nilai_ilegal', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]},
            {'kunci': 'punya_utang', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'ya', 'teks': 'A'}, {'nilai': 'tidak', 'teks': 'B'}]},
            {'kunci': 'dana_darurat', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'sudah', 'teks': 'B'}]},
            {'kunci': 'menabung', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'kadang', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]},
            {'kunci': 'investasi', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'aktif', 'teks': 'B'}]},
            {'kunci': 'mencatat_keuangan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]}
          ],
          'tujuanUtama': {'tanya': 'Tanya?', 'petunjuk': 'P', 'maksimalKarakter': 100},
          'soalTesAwal': [],
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(data, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('pilihan') == true)),
        );
      });

      test('8. tes_awal.json soal memuat angka aturan praktis (50/30/20) ditolak', () {
        final modulList = ['anggaran_arus_kas', 'tabungan', 'dana_darurat', 'utang_cicilan', 'waspada_penipuan', 'psikologi_uang'];
        final daftarSoal = <Map<String, dynamic>>[];
        var idCounter = 1;
        for (final m in modulList) {
          for (var i = 1; i <= 2; i++) {
            final nomor = idCounter++;
            daftarSoal.add({
              'id': 's_$nomor',
              'modulId': m,
              'tanya': nomor == 1 ? 'Bagaimana rumus 50/30/20 membagi gaji?' : 'Pertanyaan normal?',
              'pilihan': ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'],
              'benar': 0,
              'penjelasan': 'Penjelasan jawaban.',
            });
          }
        }

        final data = {
          'judul': 'Tes Awal',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [
            {'kunci': 'punya_penghasilan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'rutin', 'teks': 'A'}, {'nilai': 'belum', 'teks': 'B'}]},
            {'kunci': 'punya_utang', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'ya', 'teks': 'A'}, {'nilai': 'tidak', 'teks': 'B'}]},
            {'kunci': 'dana_darurat', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'sudah', 'teks': 'B'}]},
            {'kunci': 'menabung', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'kadang', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]},
            {'kunci': 'investasi', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'aktif', 'teks': 'B'}]},
            {'kunci': 'mencatat_keuangan', 'tanya': 'Tanya?', 'pilihan': [{'nilai': 'belum', 'teks': 'A'}, {'nilai': 'rutin', 'teks': 'B'}]}
          ],
          'tujuanUtama': {'tanya': 'Tanya?', 'petunjuk': 'P', 'maksimalKarakter': 100},
          'soalTesAwal': daftarSoal,
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(data, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('soalTesAwal') == true)),
        );
      });

      test('9. tes_awal.json memuat kata terlarang (malas) ditolak', () {
        final data = {
          'judul': 'Tes Awal untuk orang malas',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [],
          'tujuanUtama': {},
          'soalTesAwal': [],
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(data, namaBerkas: 'tes_awal.json'),
          throwsA(predicate((e) => e is GalatKonten && e.berkas == 'tes_awal.json')),
        );
      });

      test('10. rekomendasi.json bukan objek JSON atau alasan kosong', () {
        expect(
          () => PembacaKonten.uraiRekomendasi('["bukan", "objek"]', namaBerkas: 'rekomendasi.json'),
          throwsA(predicate((e) => e is GalatKonten && e.berkas == 'rekomendasi.json')),
        );
        expect(
          () => PembacaKonten.uraiRekomendasi('{"alasan": {}}', namaBerkas: 'rekomendasi.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom == 'alasan')),
        );
      });

      test('11. rekomendasi.json kehilangan kode alasan resmi yang wajib ada', () {
        const jsonKurang = '''
        {
          "alasan": {
            "skor_tes_rendah": {"judul": "A", "deskripsi": "B"}
          }
        }
        ''';
        expect(
          () => PembacaKonten.uraiRekomendasi(jsonKurang, namaBerkas: 'rekomendasi.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom == 'alasan')),
        );
      });

      test('12. rekomendasi.json memuat kode alasan asing yang tidak dikenal kode', () {
        const jsonAsing = '''
        {
          "alasan": {
            "skor_tes_rendah": {"judul": "A", "deskripsi": "B"},
            "punya_utang_tercatat": {"judul": "A", "deskripsi": "B"},
            "dana_darurat_kosong": {"judul": "A", "deskripsi": "B"},
            "keinginan_terbesar": {"judul": "A", "deskripsi": "B"},
            "belum_ada_modul_selesai": {"judul": "A", "deskripsi": "B"},
            "alasan_aneh_asing": {"judul": "A", "deskripsi": "B"}
          }
        }
        ''';
        expect(
          () => PembacaKonten.uraiRekomendasi(jsonAsing, namaBerkas: 'rekomendasi.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('alasan.alasan_aneh_asing') == true)),
        );
      });

      test('13. rekomendasi.json memuat klaim keuangan menghakimi ditolak', () {
        const jsonKlaim = '''
        {
          "alasan": {
            "skor_tes_rendah": {"judul": "Pengeluaran terlalu tinggi", "deskripsi": "Kondisi keuangan buruk"},
            "punya_utang_tercatat": {"judul": "A", "deskripsi": "B"},
            "dana_darurat_kosong": {"judul": "A", "deskripsi": "B"},
            "keinginan_terbesar": {"judul": "A", "deskripsi": "B"},
            "belum_ada_modul_selesai": {"judul": "A", "deskripsi": "B"}
          }
        }
        ''';
        expect(
          () => PembacaKonten.uraiRekomendasi(jsonKlaim, namaBerkas: 'rekomendasi.json'),
          throwsA(predicate((e) => e is GalatKonten && e.kolom?.contains('skor_tes_rendah') == true)),
        );
      });

      test('14. Uji Positif: konten sintetis berkata terlarang (bodoh) pada rekomendasi GAGAL', () {
        const jsonBodoh = '''
        {
          "alasan": {
            "skor_tes_rendah": {"judul": "Jangan bodoh", "deskripsi": "B"},
            "punya_utang_tercatat": {"judul": "A", "deskripsi": "B"},
            "dana_darurat_kosong": {"judul": "A", "deskripsi": "B"},
            "keinginan_terbesar": {"judul": "A", "deskripsi": "B"},
            "belum_ada_modul_selesai": {"judul": "A", "deskripsi": "B"}
          }
        }
        ''';
        expect(
          () => PembacaKonten.uraiRekomendasi(jsonBodoh, namaBerkas: 'rekomendasi.json'),
          throwsA(predicate((e) => e is GalatKonten && e.berkas == 'rekomendasi.json')),
        );
      });
    });
  });
}
