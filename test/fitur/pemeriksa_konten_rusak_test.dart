import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';

void main() {
  group('Butir B.3 & B.4: Pemeriksa Konten Rusak & Pemeriksa Bahasa Lengkap', () {
    // 1. kamus.json bukan format array
    test('1. kamus.json: format bukan array', () {
      expect(
        () => PembacaKonten.uraiKamus(
          '{"bukan": "array"}',
          namaBerkas: 'kamus.json',
        ),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'kamus.json' &&
                e.pesan.contains('array'),
          ),
        ),
      );
    });

    // 2. kamus.json: istilah kosong
    test('2. kamus.json: kolom istilah kosong', () {
      const jsonStr =
          '[{"istilah": "", "arti": "Definisi", "contohRupiah": "Rp100"}]';
      expect(
        () => PembacaKonten.uraiKamus(jsonStr, namaBerkas: 'kamus.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'kamus.json' &&
                e.kolom == 'istilah',
          ),
        ),
      );
    });

    // 3. kamus.json: arti kosong
    test('3. kamus.json: kolom arti kosong', () {
      const jsonStr =
          '[{"istilah": "Arus Kas", "arti": "  ", "contohRupiah": "Rp100"}]';
      expect(
        () => PembacaKonten.uraiKamus(jsonStr, namaBerkas: 'kamus.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'kamus.json' &&
                e.kolom == 'arti',
          ),
        ),
      );
    });

    // 4. kamus.json: contohRupiah tidak ada
    test('4. kamus.json: kolom contohRupiah tidak ada', () {
      const jsonStr = '[{"istilah": "Arus Kas", "arti": "Definisi"}]';
      expect(
        () => PembacaKonten.uraiKamus(jsonStr, namaBerkas: 'kamus.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'kamus.json' &&
                e.kolom == 'contohRupiah',
          ),
        ),
      );
    });

    // 5. modul.json: bukan objek JSON
    test('5. modul.json: format bukan objek', () {
      expect(
        () => PembacaKonten.uraiModul(
          '["bukan", "objek"]',
          namaBerkas: 'modul.json',
        ),
        throwsA(predicate((e) => e is GalatKonten && e.berkas == 'modul.json')),
      );
    });

    // 6. modul.json: kolom id kosong
    test('6. modul.json: kolom id kosong', () {
      const jsonStr = '{"id": "", "judul": "Judul", "tingkat": "pemula"}';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten && e.berkas == 'modul.json' && e.kolom == 'id',
          ),
        ),
      );
    });

    // 7. modul.json: kolom judul kosong
    test('7. modul.json: kolom judul kosong', () {
      const jsonStr = '{"id": "modul_1", "judul": "", "tingkat": "pemula"}';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'modul.json' &&
                e.kolom == 'judul',
          ),
        ),
      );
    });

    // 8. modul.json: tingkat tidak valid (harus pemula, menengah, atau lanjutan)
    test('8. modul.json: tingkat di luar pemula/menengah/lanjutan', () {
      const jsonStr = '{"id": "modul_1", "judul": "Judul", "tingkat": "ahli"}';
      expect(
        () => PembacaKonten.uraiModul(jsonStr, namaBerkas: 'modul.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'modul.json' &&
                e.kolom == 'tingkat',
          ),
        ),
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
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'modul.json' &&
                e.kolom == 'kuis.jumlahSoal',
          ),
        ),
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
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'modul.json' &&
                e.kolom == 'daftarPelajaran' &&
                e.pesan.contains('duplikat'),
          ),
        ),
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
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'modul.json' &&
                e.pesan.contains('duplikat'),
          ),
        ),
      );
    });

    // 12. modul.json: soal kuis mereferensikan pelajaranId yang tidak ada
    test(
      '12. modul.json: referensi pelajaranId soal kuis tidak ada di daftarPelajaran',
      () {
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
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'modul.json' &&
                  e.pesan.contains('tidak terdaftar'),
            ),
          ),
        );
      },
    );

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
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'modul.json' &&
                e.kolom == 'gerbang[0].objek',
          ),
        ),
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
        () =>
            PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'pelajaran.json' &&
                e.kolom == 'id' &&
                e.pesan.contains('stabil'),
          ),
        ),
      );
    });

    // 15. pelajaran.json: durasi di luar 3 sampai 8 menit
    test(
      '15. pelajaran.json: durasi di luar rentang 3 sampai 8 menit (< 3 atau > 8)',
      () {
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
          () => PembacaKonten.uraiPelajaran(
            jsonKurang,
            namaBerkas: 'pelajaran.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'pelajaran.json' &&
                  e.kolom == 'durasiMenit',
            ),
          ),
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
          () => PembacaKonten.uraiPelajaran(
            jsonLebih,
            namaBerkas: 'pelajaran.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'pelajaran.json' &&
                  e.kolom == 'durasiMenit',
            ),
          ),
        );
      },
    );

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
        () =>
            PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'pelajaran.json' &&
                e.kolom == 'kartu',
          ),
        ),
      );
    });

    // 17. pelajaran.json: istilah {{...}} tidak ada di kamus
    test(
      '17. pelajaran.json: istilah {{istilah_asing}} tidak terdaftar di kamus.json',
      () {
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
          () => PembacaKonten.uraiPelajaran(
            jsonStr,
            namaBerkas: 'pelajaran.json',
            daftarIstilahKamus: {'arus kas', 'kebutuhan'},
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'pelajaran.json' &&
                  e.pesan.contains('tidak ditemukan di kamus.json'),
            ),
          ),
        );
      },
    );

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
        () =>
            PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: 'pelajaran.json'),
        throwsA(
          predicate(
            (e) =>
                e is GalatKonten &&
                e.berkas == 'pelajaran.json' &&
                e.kolom == 'misi.tipe' &&
                e.pesan.contains('belum didukung'),
          ),
        ),
      );
    });

    // 19. pelajaran.json: umpan balik misi tidak dikenal
    test(
      '19. pelajaran.json: referensi umpanBalik misi tidak terdaftar di registri',
      () {
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
          () => PembacaKonten.uraiPelajaran(
            jsonStr,
            namaBerkas: 'pelajaran.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'pelajaran.json' &&
                  e.kolom == 'misi.umpanBalik',
            ),
          ),
        );
      },
    );

    // 20. Pemeriksa Bahasa: Uji Positif Kata Terlarang (boros, bodoh, malas, dll)
    test(
      '20. Pemeriksa bahasa: konten sintetis berisi kata terlarang harus GAGAL',
      () {
        const teksBoros = 'Jangan boros saat berbelanja bulanan.';
        expect(
          () => PembacaKonten.periksaBahasaTeks(
            teksBoros,
            namaBerkas: 'uji_bahasa.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.pesan.contains('boros')),
          ),
        );

        const teksMenghakimi =
            'Cara yang kamu lakukan ini salah dan merugikan.';
        expect(
          () => PembacaKonten.periksaBahasaTeks(
            teksMenghakimi,
            namaBerkas: 'uji_bahasa.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.pesan.contains('salah')),
          ),
        );
      },
    );

    // 21. Pemeriksa Bahasa: Uji Positif Istilah Teknis Polos tanpa {{ }} (defisit/surplus)
    test(
      '21. Pemeriksa bahasa: istilah teknis polos tanpa {{ }} (misal versi lama 1_3 "defisit") harus GAGAL',
      () {
        // Kalimat persis baris 44 versi lama anggaran_arus_kas_1_3.json
        const kalimatLamaBaris44 =
            'Saat arus kas bulananmu mulai terasa sesak atau defisit';
        expect(
          () => PembacaKonten.periksaBahasaTeks(
            kalimatLamaBaris44,
            namaBerkas: 'anggaran_arus_kas_1_3.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.pesan.contains('defisit') &&
                  e.pesan.contains('tooltip'),
            ),
          ),
        );

        // Kalimat yang sudah diperbaiki dengan {{defisit}} harus LOLOS
        const kalimatBaruBaris44 =
            'Saat arus kas bulananmu mulai terasa sesak atau {{defisit}}';
        expect(
          () => PembacaKonten.periksaBahasaTeks(
            kalimatBaruBaris44,
            namaBerkas: 'anggaran_arus_kas_1_3.json',
          ),
          returnsNormally,
        );
      },
    );

    // 22. Pemeriksa Bahasa: Kalimat > 25 kata menghasilkan peringatan
    test(
      '22. Pemeriksa bahasa: kalimat > 25 kata menghasilkan peringatan terdaftar',
      () {
        const kalimatPanjang =
            'Setiap rupiah yang masuk ke dalam dompetmu adalah hasil dari kerja kerasmu sendiri dan kamu berhak mengalokasikannya dengan penuh rasa bangga dan bahagia untuk masa depan yang cerah.';
        final daftarPeringatan = <String>[];
        PembacaKonten.periksaBahasaTeks(
          kalimatPanjang,
          namaBerkas: 'uji_panjang.json',
          daftarPeringatan: daftarPeringatan,
        );
        expect(daftarPeringatan.length, 1);
        expect(daftarPeringatan.first, contains('Kalimat panjang'));
      },
    );

    // 23. Pemeriksa Konten: Misi otomatis terpenuhi oleh gerbang pelajaran sendiri GAGAL
    test(
      '23. Pemeriksa konten: misi ada_data otomatis terpenuhi oleh gerbang pelajaran sendiri harus GAGAL',
      () {
        final pelajaranRusak = {
          'id': 'modul_uji_1_1',
          'judul': 'Uji Pelajaran',
          'durasiMenit': 4,
          'status': 'draf',
          'gerbang': [
            {
              'tipe': 'ada_data',
              'objek': 'pemasukan',
              'min': 1,
              'pesan': 'Catat 1 pemasukan',
            },
          ],
          'pemantik': 'Pemantik singkat.',
          'kartu': [
            {'judul': 'Kartu 1', 'isi': 'Isi kartu konsep.'},
          ],
          'contohAngka': 100000,
          'cekPaham': [
            {
              'tanya': 'Tanya 1',
              'pilihan': ['A', 'B'],
              'benar': 0,
              'penjelasan': 'P1',
            },
            {
              'tanya': 'Tanya 2',
              'pilihan': ['A', 'B'],
              'benar': 1,
              'penjelasan': 'P2',
            },
          ],
          'misi': {
            'tipe': 'ada_data',
            'objek': 'pemasukan',
            'min': 1,
            'judul': 'Misi Sama',
            'deskripsi': 'Deskripsi',
            'perkiraanMenit': 2,
            'umpanBalik': 'arus_kas_bulan_ini',
          },
        };

        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            pelajaranRusak,
            namaBerkas: 'pelajaran_rusak.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.pesan.contains('otomatis terpenuhi oleh gerbang'),
            ),
          ),
        );
      },
    );

    // 24. Pemeriksa Konten: Misi bertipe lihat_hitungan atau beda objek LOLOS (uji positif)
    test(
      '24. Pemeriksa konten: misi lihat_hitungan atau objek beda dengan gerbang harus LOLOS',
      () {
        final pelajaranValid = {
          'id': 'modul_uji_1_2',
          'judul': 'Uji Pelajaran Valid',
          'durasiMenit': 4,
          'status': 'draf',
          'gerbang': [
            {
              'tipe': 'ada_data',
              'objek': 'dompet',
              'min': 1,
              'pesan': 'Buat 1 dompet',
            },
          ],
          'pemantik': 'Pemantik singkat.',
          'kartu': [
            {'judul': 'Kartu 1', 'isi': 'Isi kartu konsep.'},
          ],
          'contohAngka': 100000,
          'cekPaham': [
            {
              'tanya': 'Tanya 1',
              'pilihan': ['A', 'B'],
              'benar': 0,
              'penjelasan': 'P1',
            },
            {
              'tanya': 'Tanya 2',
              'pilihan': ['A', 'B'],
              'benar': 1,
              'penjelasan': 'P2',
            },
          ],
          'misi': {
            'tipe': 'ada_data',
            'objek': 'arus_kas',
            'min': 1,
            'judul': 'Misi Arus Kas',
            'deskripsi': 'Deskripsi',
            'perkiraanMenit': 2,
            'umpanBalik': 'arus_kas_bulan_ini',
          },
        };

        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            pelajaranValid,
            namaBerkas: 'pelajaran_valid.json',
          ),
          returnsNormally,
        );

        final pelajaranLihatHitungan = Map<String, dynamic>.from(pelajaranValid)
          ..['id'] = 'modul_uji_1_3'
          ..['gerbang'] = [
            {'tipe': 'ada_data', 'objek': 'pemasukan', 'min': 1},
          ]
          ..['misi'] = {
            'tipe': 'lihat_hitungan',
            'judul': 'Misi Lihat Hitungan',
            'deskripsi': 'Deskripsi',
            'perkiraanMenit': 1,
          };

        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            pelajaranLihatHitungan,
            namaBerkas: 'pelajaran_lihat.json',
          ),
          returnsNormally,
        );
      },
    );

    // -------------------------------------------------------------------------
    // Pengujian Validasi Konten Tes Awal (tes_awal.json) Rusak (Tahap 5)
    // -------------------------------------------------------------------------
    group('Pengujian Validasi Konten Tes Awal (tes_awal.json) Rusak', () {
      test('1. tes_awal.json bukan objek JSON', () {
        expect(
          () => PembacaKonten.uraiTesAwal(
            '["bukan", "objek"]',
            namaBerkas: 'tes_awal.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.berkas == 'tes_awal.json'),
          ),
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
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'pertanyaanProfil'),
          ),
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
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.kolom?.contains('kunci') == true,
            ),
          ),
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
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'soalTesAwal'),
          ),
        );
      });

      test('5. tes_awal.json opsi ke-4 bukan "Belum tahu, nggak apa-apa"', () {
        // Buat 12 soal tetapi soal pertama opsi ke-4 nya bukan standar
        final modulList = [
          'anggaran_arus_kas',
          'tabungan',
          'dana_darurat',
          'utang_cicilan',
          'waspada_penipuan',
          'psikologi_uang',
        ];
        final daftarSoal = <Map<String, dynamic>>[];
        var idCounter = 1;
        for (final m in modulList) {
          for (var i = 1; i <= 2; i++) {
            final nomor = idCounter++;
            daftarSoal.add({
              'id': 's_$nomor',
              'modulId': m,
              'tanya': 'Pertanyaan soal?',
              'pilihan': [
                'A',
                'B',
                'C',
                nomor == 1
                    ? 'Pilihan Sembarangan'
                    : 'Belum tahu, nggak apa-apa',
              ],
              'benar': 0,
              'penjelasan': 'Penjelasan jawaban.',
            });
          }
        }

        final data = {
          'judul': 'Tes Awal',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [
            {
              'kunci': 'punya_penghasilan',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'rutin', 'teks': 'A'},
                {'nilai': 'belum', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'punya_utang',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'ya', 'teks': 'A'},
                {'nilai': 'tidak', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'dana_darurat',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'belum', 'teks': 'A'},
                {'nilai': 'sudah', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'menabung',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'kadang', 'teks': 'A'},
                {'nilai': 'rutin', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'investasi',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'belum', 'teks': 'A'},
                {'nilai': 'aktif', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'mencatat_keuangan',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'belum', 'teks': 'A'},
                {'nilai': 'rutin', 'teks': 'B'},
              ],
            },
          ],
          'tujuanUtama': {
            'tanya': 'Tanya?',
            'petunjuk': 'P',
            'maksimalKarakter': 100,
          },
          'soalTesAwal': daftarSoal,
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(
            data,
            namaBerkas: 'tes_awal.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten && e.kolom?.contains('pilihan[3]') == true,
            ),
          ),
        );
      });

      test('6. tes_awal.json soal mereferensikan modulId tidak valid', () {
        final modulList = [
          'anggaran_arus_kas',
          'tabungan',
          'dana_darurat',
          'utang_cicilan',
          'waspada_penipuan',
          'modul_salah_tidak_ada',
        ];
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
            {
              'kunci': 'punya_penghasilan',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'rutin', 'teks': 'A'},
                {'nilai': 'belum', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'punya_utang',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'ya', 'teks': 'A'},
                {'nilai': 'tidak', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'dana_darurat',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'belum', 'teks': 'A'},
                {'nilai': 'sudah', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'menabung',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'kadang', 'teks': 'A'},
                {'nilai': 'rutin', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'investasi',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'belum', 'teks': 'A'},
                {'nilai': 'aktif', 'teks': 'B'},
              ],
            },
            {
              'kunci': 'mencatat_keuangan',
              'tanya': 'Tanya?',
              'pilihan': [
                {'nilai': 'belum', 'teks': 'A'},
                {'nilai': 'rutin', 'teks': 'B'},
              ],
            },
          ],
          'tujuanUtama': {
            'tanya': 'Tanya?',
            'petunjuk': 'P',
            'maksimalKarakter': 100,
          },
          'soalTesAwal': daftarSoal,
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(
            data,
            namaBerkas: 'tes_awal.json',
          ),
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.kolom?.contains('modulId') == true,
            ),
          ),
        );
      });

      test(
        '7. tes_awal.json nilai pilihan profil tidak cocok dengan skema database',
        () {
          final data = {
            'judul': 'Tes Awal',
            'deskripsi': 'Deskripsi',
            'pertanyaanProfil': [
              {
                'kunci': 'punya_penghasilan',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'nilai_ilegal', 'teks': 'A'},
                  {'nilai': 'rutin', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'punya_utang',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'ya', 'teks': 'A'},
                  {'nilai': 'tidak', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'dana_darurat',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'belum', 'teks': 'A'},
                  {'nilai': 'sudah', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'menabung',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'kadang', 'teks': 'A'},
                  {'nilai': 'rutin', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'investasi',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'belum', 'teks': 'A'},
                  {'nilai': 'aktif', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'mencatat_keuangan',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'belum', 'teks': 'A'},
                  {'nilai': 'rutin', 'teks': 'B'},
                ],
              },
            ],
            'tujuanUtama': {
              'tanya': 'Tanya?',
              'petunjuk': 'P',
              'maksimalKarakter': 100,
            },
            'soalTesAwal': [],
          };

          expect(
            () => PembacaKonten.validasiKontenTesAwal(
              data,
              namaBerkas: 'tes_awal.json',
            ),
            throwsA(
              predicate(
                (e) => e is GalatKonten && e.kolom?.contains('pilihan') == true,
              ),
            ),
          );
        },
      );

      test(
        '8. tes_awal.json soal memuat angka aturan praktis (50/30/20) ditolak',
        () {
          final modulList = [
            'anggaran_arus_kas',
            'tabungan',
            'dana_darurat',
            'utang_cicilan',
            'waspada_penipuan',
            'psikologi_uang',
          ];
          final daftarSoal = <Map<String, dynamic>>[];
          var idCounter = 1;
          for (final m in modulList) {
            for (var i = 1; i <= 2; i++) {
              final nomor = idCounter++;
              daftarSoal.add({
                'id': 's_$nomor',
                'modulId': m,
                'tanya': nomor == 1
                    ? 'Bagaimana rumus 50/30/20 membagi gaji?'
                    : 'Pertanyaan normal?',
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
              {
                'kunci': 'punya_penghasilan',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'rutin', 'teks': 'A'},
                  {'nilai': 'belum', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'punya_utang',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'ya', 'teks': 'A'},
                  {'nilai': 'tidak', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'dana_darurat',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'belum', 'teks': 'A'},
                  {'nilai': 'sudah', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'menabung',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'kadang', 'teks': 'A'},
                  {'nilai': 'rutin', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'investasi',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'belum', 'teks': 'A'},
                  {'nilai': 'aktif', 'teks': 'B'},
                ],
              },
              {
                'kunci': 'mencatat_keuangan',
                'tanya': 'Tanya?',
                'pilihan': [
                  {'nilai': 'belum', 'teks': 'A'},
                  {'nilai': 'rutin', 'teks': 'B'},
                ],
              },
            ],
            'tujuanUtama': {
              'tanya': 'Tanya?',
              'petunjuk': 'P',
              'maksimalKarakter': 100,
            },
            'soalTesAwal': daftarSoal,
          };

          expect(
            () => PembacaKonten.validasiKontenTesAwal(
              data,
              namaBerkas: 'tes_awal.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom?.contains('soalTesAwal') == true,
              ),
            ),
          );
        },
      );

      test('9. tes_awal.json memuat kata terlarang (malas) ditolak', () {
        final data = {
          'judul': 'Tes Awal untuk orang malas',
          'deskripsi': 'Deskripsi',
          'pertanyaanProfil': [],
          'tujuanUtama': {},
          'soalTesAwal': [],
        };

        expect(
          () => PembacaKonten.validasiKontenTesAwal(
            data,
            namaBerkas: 'tes_awal.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.berkas == 'tes_awal.json'),
          ),
        );
      });

      test('10. rekomendasi.json bukan objek JSON atau alasan kosong', () {
        expect(
          () => PembacaKonten.uraiRekomendasi(
            '["bukan", "objek"]',
            namaBerkas: 'rekomendasi.json',
          ),
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.berkas == 'rekomendasi.json',
            ),
          ),
        );
        expect(
          () => PembacaKonten.uraiRekomendasi(
            '{"alasan": {}}',
            namaBerkas: 'rekomendasi.json',
          ),
          throwsA(predicate((e) => e is GalatKonten && e.kolom == 'alasan')),
        );
      });

      test(
        '11. rekomendasi.json kehilangan kode alasan resmi yang wajib ada',
        () {
          const jsonKurang = '''
        {
          "alasan": {
            "skor_tes_rendah": {"judul": "A", "deskripsi": "B"}
          }
        }
        ''';
          expect(
            () => PembacaKonten.uraiRekomendasi(
              jsonKurang,
              namaBerkas: 'rekomendasi.json',
            ),
            throwsA(predicate((e) => e is GalatKonten && e.kolom == 'alasan')),
          );
        },
      );

      test(
        '12. rekomendasi.json memuat kode alasan asing yang tidak dikenal kode',
        () {
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
            () => PembacaKonten.uraiRekomendasi(
              jsonAsing,
              namaBerkas: 'rekomendasi.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom?.contains('alasan.alasan_aneh_asing') == true,
              ),
            ),
          );
        },
      );

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
          () => PembacaKonten.uraiRekomendasi(
            jsonKlaim,
            namaBerkas: 'rekomendasi.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.kolom?.contains('skor_tes_rendah') == true,
            ),
          ),
        );
      });

      test(
        '14. Uji Positif: konten sintetis berkata terlarang (bodoh) pada rekomendasi GAGAL',
        () {
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
            () => PembacaKonten.uraiRekomendasi(
              jsonBodoh,
              namaBerkas: 'rekomendasi.json',
            ),
            throwsA(
              predicate(
                (e) => e is GalatKonten && e.berkas == 'rekomendasi.json',
              ),
            ),
          );
        },
      );
    });

    // =========================================================================
    // Tahap 6: Pengujian Validasi Konten Rusak untuk Bidang Baru
    // =========================================================================
    group('Pengujian Validasi Konten Rusak Bidang Baru (Tahap 6)', () {
      // 1. contohAngka rusak (bukan objek, judul kosong, atau baris kosong/jumlah bukan angka)
      test('1. contohAngka rusak: judul kosong ditolak', () {
        const jsonStr = '''
        {
          "id": "anggaran_arus_kas_1_1",
          "modul": "anggaran_arus_kas",
          "judul": "Judul",
          "durasiMenit": 4,
          "status": "draf",
          "kartu": [{"judul": "J", "isi": "I"}],
          "contohAngka": {
            "judul": "",
            "baris": [{"label": "Kopi", "jumlah": 18000}],
            "kesimpulan": "K"
          },
          "cekPaham": [
            {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
            {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
          ],
          "misi": {"tipe": "ada_data", "objek": "pengeluaran", "min": 1, "judul": "M", "umpanBalik": "catatan_pengeluaran_terbaru"}
        }
        ''';
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonStr,
            namaBerkas: 'pelajaran_rusak.json',
          ),
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.kolom == 'contohAngka.judul',
            ),
          ),
        );
      });

      test('1b. contohAngka rusak: baris kosong ditolak', () {
        const jsonStr = '''
        {
          "id": "anggaran_arus_kas_1_1",
          "modul": "anggaran_arus_kas",
          "judul": "Judul",
          "durasiMenit": 4,
          "status": "draf",
          "kartu": [{"judul": "J", "isi": "I"}],
          "contohAngka": {
            "judul": "Judul Contoh",
            "baris": [],
            "kesimpulan": "K"
          },
          "cekPaham": [
            {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
            {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
          ],
          "misi": {"tipe": "ada_data", "objek": "pengeluaran", "min": 1, "judul": "M", "umpanBalik": "catatan_pengeluaran_terbaru"}
        }
        ''';
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonStr,
            namaBerkas: 'pelajaran_rusak.json',
          ),
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.kolom == 'contohAngka.baris',
            ),
          ),
        );
      });

      // 2. aturanPraktis tanpa catatanReviewer
      test(
        '2. aturanPraktis: true tanpa catatanReviewer TODO-VERIFIKASI ditolak',
        () {
          const jsonStr = '''
        {
          "id": "anggaran_arus_kas_1_4",
          "modul": "anggaran_arus_kas",
          "judul": "Judul",
          "durasiMenit": 7,
          "status": "draf",
          "aturanPraktis": true,
          "kartu": [{"judul": "J", "isi": "Pola 50/30/20 adalah panduan."}],
          "cekPaham": [
            {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
            {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
          ],
          "misi": {"tipe": "ada_data", "objek": "anggaran", "min": 3, "judul": "M", "umpanBalik": "perbandingan_pola_anggaran"}
        }
        ''';
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonStr,
              namaBerkas: 'pelajaran_rusak.json',
            ),
            throwsA(
              predicate(
                (e) => e is GalatKonten && e.kolom == 'catatanReviewer',
              ),
            ),
          );
        },
      );

      // 3. angka 50/30/20 tanpa penanda aturanPraktis
      test(
        '3. teks memuat angka aturan praktis 50/30/20 tanpa penanda aturanPraktis ditolak',
        () {
          const jsonStr = '''
        {
          "id": "anggaran_arus_kas_1_4",
          "modul": "anggaran_arus_kas",
          "judul": "Judul",
          "durasiMenit": 7,
          "status": "draf",
          "kartu": [{"judul": "J", "isi": "Pola 50/30/20 membagi pengeluaranmu."}],
          "cekPaham": [
            {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
            {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
          ],
          "misi": {"tipe": "ada_data", "objek": "anggaran", "min": 3, "judul": "M", "umpanBalik": "perbandingan_pola_anggaran"}
        }
        ''';
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonStr,
              namaBerkas: 'pelajaran_rusak.json',
            ),
            throwsA(
              predicate(
                (e) => e is GalatKonten && e.pesan.contains('aturan praktis'),
              ),
            ),
          );
        },
      );

      // 4. umpanBalik tidak ada di registri
      test('4. umpanBalik misi tidak terdaftar di registri ditolak', () {
        const jsonStr = '''
        {
          "id": "anggaran_arus_kas_1_1",
          "modul": "anggaran_arus_kas",
          "judul": "Judul",
          "durasiMenit": 4,
          "status": "draf",
          "kartu": [{"judul": "J", "isi": "I"}],
          "cekPaham": [
            {"tanya": "T1", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P1"},
            {"tanya": "T2", "pilihan": ["A", "B"], "benar": 0, "penjelasan": "P2"}
          ],
          "misi": {
            "tipe": "ada_data",
            "objek": "pengeluaran",
            "min": 1,
            "judul": "M",
            "umpanBalik": "umpan_balik_khayalan_123"
          }
        }
        ''';
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonStr,
            namaBerkas: 'pelajaran_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'misi.umpanBalik'),
          ),
        );
      });

      // 5. pelajaranId kuis tidak ada / tidak valid
      test(
        '5. pelajaranId kuis tidak ada di daftarPelajaran modul ditolak',
        () {
          const jsonModulStr = '''
        {
          "id": "anggaran_arus_kas",
          "judul": "Anggaran & Arus Kas",
          "tingkat": "pemula",
          "urutan": 1,
          "tersedia": true,
          "daftarPelajaran": ["anggaran_arus_kas_1_1", "anggaran_arus_kas_1_2"],
          "kuis": {
            "jumlahSoal": 2,
            "bankSoal": [
              {
                "id": "soal_1",
                "pelajaranId": "anggaran_arus_kas_1_1",
                "tanya": "T1",
                "pilihan": ["A", "B"],
                "benar": 0,
                "penjelasan": "P1"
              },
              {
                "id": "soal_2",
                "pelajaranId": "anggaran_arus_kas_9_9_palsu",
                "tanya": "T2",
                "pilihan": ["A", "B"],
                "benar": 0,
                "penjelasan": "P2"
              }
            ]
          }
        }
        ''';
          expect(
            () => PembacaKonten.uraiModul(
              jsonModulStr,
              namaBerkas: 'modul_rusak.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom?.contains('pelajaranId') == true,
              ),
            ),
          );
        },
      );

      // 6. jumlah bankSoal < jumlahSoal
      test('6. jumlah bankSoal < jumlahSoal di modul.json ditolak', () {
        const jsonModulStr = '''
        {
          "id": "anggaran_arus_kas",
          "judul": "Anggaran & Arus Kas",
          "tingkat": "pemula",
          "urutan": 1,
          "tersedia": true,
          "daftarPelajaran": ["anggaran_arus_kas_1_1"],
          "kuis": {
            "jumlahSoal": 5,
            "bankSoal": [
              {
                "id": "soal_1",
                "pelajaranId": "anggaran_arus_kas_1_1",
                "tanya": "T1",
                "pilihan": ["A", "B"],
                "benar": 0,
                "penjelasan": "P1"
              }
            ]
          }
        }
        ''';
        expect(
          () => PembacaKonten.uraiModul(
            jsonModulStr,
            namaBerkas: 'modul_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'kuis.bankSoal'),
          ),
        );
      });
    });

    group('Pemeriksa Konten Laporan Rusak (Minimal 6 Kasus Galat Terstruktur)', () {
      const templateValid = '''
      {
        "versi": 1,
        "judulBagian": {
          "arusKas": "Arus kas bulan ini",
          "komposisi": "Komposisi pengeluaran",
          "anggaran": "Realisasi anggaran",
          "tujuan": "Tujuan dan dana darurat",
          "kekayaan": "Kekayaan bersih",
          "temuan": "Temuan bulan ini",
          "saran": "Saran untuk bulan depan"
        },
        "label": {
          "uangMasuk": "Uang masuk",
          "uangKeluar": "Uang keluar",
          "selisih": "Selisih",
          "perTanggal": "Per {tanggal}",
          "disembunyikan": "Disembunyikan"
        },
        "frasaSifat": {
          "kebutuhan": "kebutuhan",
          "keinginan": "keinginan",
          "tabungan": "tabungan dan dana darurat",
          "utang": "utang",
          "belumDilabeli": "pengeluaran yang belum dilabeli"
        },
        "catatanKaki": {
          "ekspor": "Dibuat dengan Funda. Ini edukasi umum, bukan nasihat keuangan.",
          "aplikasi": "Laporan ini berisi data pribadi. Bagikan hanya ke orang yang kamu percaya."
        },
        "baris": {
          "ringkasanAnggaran": "Dari {n} pos anggaran: {a} masih aman, {b} mendekati batas, {c} melewati batas.",
          "posAnggaran": {
            "normal": "{nama}: {terpakai} dari {batas} ({persen} persen)",
            "sensor": "{nama}: {persen} persen terpakai"
          },
          "posLain": "dan {n} pos lain",
          "tujuan": {
            "normal": "{nama}: {dana} dari {target} ({persen} persen)",
            "sensor": "{nama}: {persen} persen dari target"
          },
          "saldoDompet": "Saldo semua dompet {jumlah}",
          "sisaUtang": "Sisa utang {jumlah}",
          "kekayaanBersih": "Kekayaan bersih {jumlah}",
          "arusKasSensor": "Uang keluar setara {persen} persen dari uang masuk.",
          "belumAdaAnggaran": "Belum ada anggaran bulan ini.",
          "belumAdaTujuan": "Belum ada tujuan aktif.",
          "belumAdaData": "Belum ada catatan untuk bulan ini."
        },
        "temuan": {
          "posMelewati": {
            "kode": "pos_melewati",
            "normal": "Pos {nama} melewati batasnya sebesar {jumlah}. Ini bahan belajar, bukan penilaian.",
            "sensor": "Pos {nama} sudah terpakai {persen} persen dari batasnya. Ini bahan belajar, bukan penilaian."
          },
          "arusKasTanpaPemasukan": {
            "kode": "arus_kas_tanpa_pemasukan",
            "normal": "Bulan ini ada uang keluar, tetapi belum ada uang masuk yang tercatat.",
            "sensor": "Bulan ini ada uang keluar, tetapi belum ada uang masuk yang tercatat."
          },
          "arusKasNegatif": {
            "kode": "arus_kas_negatif",
            "normal": "Uang keluarmu lebih besar {jumlah} dari uang masukmu bulan ini. Ini informasi untuk membantumu memutuskan.",
            "sensor": "Uang keluarmu setara {persen} persen dari uang masukmu bulan ini. Ini informasi untuk membantumu memutuskan."
          },
          "sifatTerbesar": {
            "kode": "sifat_terbesar",
            "normal": "Bagian pengeluaran terbesarmu bulan ini ada di {sifat}: {persen} persen.",
            "sensor": "Bagian pengeluaran terbesarmu bulan ini ada di {sifat}: {persen} persen."
          },
          "arusKasPositif": {
            "kode": "arus_kas_positif",
            "normal": "Uang masukmu lebih besar {jumlah} dari uang keluar bulan ini.",
            "sensor": "Uang keluarmu setara {persen} persen dari uang masukmu bulan ini."
          },
          "dataBelumCukup": {
            "kode": "data_belum_cukup",
            "normal": "Datamu bulan ini masih sedikit. Setiap catatan membantu gambarannya makin jelas.",
            "sensor": "Datamu bulan ini masih sedikit. Setiap catatan membantu gambarannya makin jelas."
          }
        },
        "saran": {
          "buatAnggaran": {
            "kode": "buat_anggaran",
            "teks": "Buat anggaran untuk bulan depan di menu Anggaran. Mulai dari tiga kategori saja."
          },
          "tinjauPos": {
            "kode": "tinjau_pos",
            "teks": "Tinjau lagi pos {nama}: ubah batasnya atau kebiasaannya, pilih satu saja."
          },
          "beriLabel": {
            "kode": "beri_label",
            "teks": "Beri label pada kategori {nama} supaya gambaran pengeluaranmu lebih jelas."
          },
          "salinAnggaran": {
            "kode": "salin_anggaran",
            "teks": "Salin anggaran bulan ini ke bulan depan, lalu sesuaikan bagian yang perlu."
          }
        }
      }
      ''';

      test('Kasus 1: format bukan objek JSON', () {
        expect(
          () => PembacaKonten.uraiLaporan(
            '["bukan", "objek"]',
            namaBerkas: 'laporan_rusak.json',
          ),
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.berkas == 'laporan_rusak.json',
            ),
          ),
        );
      });

      test('Kasus 2: judulBagian hilang atau kosong', () {
        final rusak = templateValid.replaceAll(
          '"arusKas": "Arus kas bulan ini",',
          '',
        );
        expect(
          () => PembacaKonten.uraiLaporan(
            rusak,
            namaBerkas: 'laporan_rusak.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'laporan_rusak.json' &&
                  e.kolom == 'judulBagian.arusKas',
            ),
          ),
        );
      });

      test('Kasus 3: placeholder tidak dikenal pada baris', () {
        final rusak = templateValid.replaceAll(
          '{nama}: {terpakai}',
          '{nama_pos}: {terpakai}',
        );
        expect(
          () => PembacaKonten.uraiLaporan(
            rusak,
            namaBerkas: 'laporan_rusak.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'laporan_rusak.json' &&
                  e.kolom == 'baris.posAnggaran.normal',
            ),
          ),
        );
      });

      test('Kasus 4: kata terlarang dalam temuan', () {
        final rusak = templateValid.replaceAll(
          'Pos {nama} melewati batasnya sebesar {jumlah}. Ini bahan belajar, bukan penilaian.',
          'Kamu boros di pos {nama} sebesar {jumlah}.',
        );
        expect(
          () => PembacaKonten.uraiLaporan(
            rusak,
            namaBerkas: 'laporan_rusak.json',
          ),
          throwsA(
            predicate(
              (e) => e is GalatKonten && e.berkas == 'laporan_rusak.json',
            ),
          ),
        );
      });

      test('Kasus 5: kode temuan resmi hilang', () {
        final rusak = templateValid.replaceAll('"pos_melewati"', '"pos_lain"');
        expect(
          () => PembacaKonten.uraiLaporan(
            rusak,
            namaBerkas: 'laporan_rusak.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'laporan_rusak.json' &&
                  e.kolom!.contains('temuan'),
            ),
          ),
        );
      });

      test('Kasus 6: klaim keuangan tidak berdasar terdeteksi', () {
        final rusak = templateValid.replaceAll(
          'Buat anggaran untuk bulan depan di menu Anggaran. Mulai dari tiga kategori saja.',
          'Pasti untung jika berinvestasi di modul ini.',
        );
        expect(
          () => PembacaKonten.uraiLaporan(
            rusak,
            namaBerkas: 'laporan_rusak.json',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is GalatKonten &&
                  e.berkas == 'laporan_rusak.json' &&
                  e.kolom == 'saran.buatAnggaran.teks',
            ),
          ),
        );
      });
    });

    group('Tahap 8A: Validasi Objek Gerbang/Misi dan Kunci Umpan Balik Baru', () {
      const templatePelajaranValid = '''
      {
        "id": "tabungan_2_1",
        "modul": "tabungan",
        "judul": "Menabung Itu Soal Tujuan",
        "durasiMenit": 5,
        "status": "draf",
        "gerbang": [],
        "pemantik": "Pemantik pelajaran yang valid dan cukup panjang.",
        "kartu": [
          {"judul": "Judul 1", "isi": "Isi kartu satu"},
          {"judul": "Judul 2", "isi": "Isi kartu dua"},
          {"judul": "Judul 3", "isi": "Isi kartu tiga"}
        ],
        "contohAngka": {
          "judul": "Judul Contoh Angka",
          "baris": [
            {"label": "Baris 1", "jumlah": 100000}
          ],
          "kesimpulan": "Kesimpulan contoh angka"
        },
        "cekPaham": [
          {
            "tanya": "Pertanyaan satu?",
            "pilihan": ["Pilihan A", "Pilihan B"],
            "benar": 0,
            "penjelasan": "Penjelasan satu"
          },
          {
            "tanya": "Pertanyaan dua?",
            "pilihan": ["Pilihan A", "Pilihan B"],
            "benar": 0,
            "penjelasan": "Penjelasan dua"
          }
        ],
        "misi": {
          "tipe": "ada_data",
          "objek": "tujuan_tabungan",
          "min": 1,
          "judul": "Buat tujuan tabungan",
          "instruksi": "Instruksi misi",
          "umpanBalik": "ringkasan_tujuan_tabungan"
        },
        "tindakLanjut": "Tindak lanjut pelajaran valid."
      }
      ''';

      test('Kasus 1: objek gerbang tujuan_tabungan_salah ditolak', () {
        final jsonRusak = templatePelajaranValid.replaceAll(
          '"gerbang": []',
          '"gerbang": [{"tipe": "ada_data", "objek": "tujuan_tabungan_salah", "min": 1}]',
        );
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonRusak,
            namaBerkas: 'tabungan_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'gerbang[0].objek'),
          ),
        );
      });

      test('Kasus 2: objek gerbang tujuan_dana_darurat_salah ditolak', () {
        final jsonRusak = templatePelajaranValid.replaceAll(
          '"gerbang": []',
          '"gerbang": [{"tipe": "ada_data", "objek": "tujuan_dana_darurat_palsu", "min": 1}]',
        );
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonRusak,
            namaBerkas: 'dana_darurat_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'gerbang[0].objek'),
          ),
        );
      });

      test('Kasus 3: objek misi isi_tujuan_tabungan_palsu ditolak', () {
        final jsonRusak = templatePelajaranValid.replaceAll(
          '"objek": "tujuan_tabungan"',
          '"objek": "isi_tujuan_tabungan_palsu"',
        );
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonRusak,
            namaBerkas: 'tabungan_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'misi.objek'),
          ),
        );
      });

      test('Kasus 4: objek misi pengeluaran_kebutuhan_palsu ditolak', () {
        final jsonRusak = templatePelajaranValid.replaceAll(
          '"objek": "tujuan_tabungan"',
          '"objek": "pengeluaran_kebutuhan_typo"',
        );
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonRusak,
            namaBerkas: 'dana_darurat_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'misi.objek'),
          ),
        );
      });

      test(
        'Kasus 5: kunci umpan balik ringkasan_tujuan_tabungan_rusak ditolak',
        () {
          final jsonRusak = templatePelajaranValid.replaceAll(
            '"umpanBalik": "ringkasan_tujuan_tabungan"',
            '"umpanBalik": "ringkasan_tujuan_tabungan_rusak"',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonRusak,
              namaBerkas: 'tabungan_rusak.json',
            ),
            throwsA(
              predicate(
                (e) => e is GalatKonten && e.kolom == 'misi.umpanBalik',
              ),
            ),
          );
        },
      );

      test('Kasus 6: kunci umpan balik estimasi_tabungan_salah ditolak', () {
        final jsonRusak = templatePelajaranValid.replaceAll(
          '"umpanBalik": "ringkasan_tujuan_tabungan"',
          '"umpanBalik": "estimasi_tabungan_salah"',
        );
        expect(
          () => PembacaKonten.uraiPelajaran(
            jsonRusak,
            namaBerkas: 'tabungan_rusak.json',
          ),
          throwsA(
            predicate((e) => e is GalatKonten && e.kolom == 'misi.umpanBalik'),
          ),
        );
      });

      test(
        'Kasus 7 (pembuktian positif): 5 objek baru dan 5 kunci umpan balik baru valid',
        () {
          const objekBaru = [
            'tujuan_tabungan',
            'isi_tujuan_tabungan',
            'pengeluaran_kebutuhan',
            'tujuan_dana_darurat',
            'isi_dana_darurat',
          ];
          const umpanBalikBaru = [
            'ringkasan_tujuan_tabungan',
            'estimasi_tabungan',
            'pengeluaran_wajib_bulanan',
            'target_dana_darurat',
            'progres_dana_darurat',
          ];
          for (var i = 0; i < 5; i++) {
            final jsonUji = templatePelajaranValid
                .replaceAll('"tujuan_tabungan"', '"${objekBaru[i]}"')
                .replaceAll(
                  '"ringkasan_tujuan_tabungan"',
                  '"${umpanBalikBaru[i]}"',
                );
            expect(
              () => PembacaKonten.uraiPelajaran(
                jsonUji,
                namaBerkas: 'uji_valid_$i.json',
              ),
              returnsNormally,
            );
          }
        },
      );

      test(
        'Kasus 8: penolakan status selain "draf" dan "ditinjau" (status "rilis", "aktif", kosong ditolak)',
        () {
          final statusIlegal = ['rilis', 'aktif', 'publikasi', 'selesai', ''];
          for (final st in statusIlegal) {
            final jsonRusak = templatePelajaranValid.replaceAll(
              '"status": "draf"',
              '"status": "$st"',
            );
            expect(
              () => PembacaKonten.uraiPelajaran(
                jsonRusak,
                namaBerkas: 'tabungan_status_rusak.json',
              ),
              throwsA(
                predicate(
                  (e) =>
                      e is GalatKonten &&
                      e.kolom == 'status' &&
                      e.pesan.contains('draf') &&
                      e.pesan.contains('ditinjau'),
                ),
              ),
              reason: 'Status "$st" harus ditolak oleh pemeriksa konten',
            );
          }

          // Uji status null / hilang
          final jsonTanpaStatus = templatePelajaranValid.replaceAll(
            '"status": "draf",',
            '',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonTanpaStatus,
              namaBerkas: 'tabungan_tanpa_status.json',
            ),
            throwsA(predicate((e) => e is GalatKonten && e.kolom == 'status')),
          );
        },
      );

      test(
        'Kasus 9 (pembuktian positif): status "draf" dan "ditinjau" keduanya diterima',
        () {
          final jsonDraf = templatePelajaranValid;
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonDraf,
              namaBerkas: 'tabungan_draf.json',
            ),
            returnsNormally,
          );

          final jsonDitinjau = templatePelajaranValid.replaceAll(
            '"status": "draf"',
            '"status": "ditinjau"',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonDitinjau,
              namaBerkas: 'tabungan_ditinjau.json',
            ),
            returnsNormally,
          );
        },
      );
    });

    group(
      'Tahap 8B: Validasi Kunci Umpan Balik dan Gerbang atauPernyataan Modul 4 (Minimal 6 Kasus)',
      () {
        const templatePelajaranUtangValid = '''
      {
        "id": "utang_cicilan_4_1",
        "modul": "utang_cicilan",
        "judul": "Utang yang Membantu dan yang Menjerat",
        "durasiMenit": 5,
        "status": "draf",
        "gerbang": [],
        "pemantik": "Pemantik pelajaran yang valid dan cukup panjang tentang utang.",
        "kartu": [
          {"judul": "Judul 1", "isi": "Penjelasan konsep utang satu."},
          {"judul": "Judul 2", "isi": "Penjelasan konsep utang dua."}
        ],
        "cekPaham": [
          {
            "tanya": "Pertanyaan satu?",
            "pilihan": ["Pilihan satu", "Pilihan dua"],
            "benar": 0,
            "penjelasan": "Penjelasan satu"
          },
          {
            "tanya": "Pertanyaan dua?",
            "pilihan": ["Pilihan satu", "Pilihan dua"],
            "benar": 0,
            "penjelasan": "Penjelasan dua"
          }
        ],
        "misi": {
          "tipe": "lihat_hitungan",
          "judul": "Lihat ringkasan utangmu",
          "instruksi": "Instruksi misi",
          "umpanBalik": "ringkasan_utang"
        },
        "tindakLanjut": "Tindak lanjut pelajaran valid."
      }
      ''';

        const templateModulUtangValid = '''
      {
        "id": "utang_cicilan",
        "judul": "Utang & Cicilan",
        "tingkat": "pemula",
        "urutan": 4,
        "deskripsiSingkat": "Deskripsi singkat modul utang dan cicilan.",
        "tersedia": true,
        "gerbang": [
          {
            "tipe": "modul_selesai",
            "modulId": "dana_darurat",
            "pesan": "Selesaikan Modul 3 dulu."
          },
          {
            "tipe": "ada_data",
            "objek": "utang",
            "min": 1,
            "atauPernyataan": "tidak_punya_utang",
            "pesan": "Lalu catat utang atau cicilanmu di menu Utang."
          }
        ],
        "daftarPelajaran": [
          "utang_cicilan_4_1"
        ],
        "kuis": {
          "jumlahSoal": 1,
          "bankSoal": [
            {
              "id": "soal_4_1",
              "pelajaranId": "utang_cicilan_4_1",
              "tanya": "Tanya soal?",
              "pilihan": ["A", "B"],
              "benar": 0,
              "penjelasan": "Penjelasan"
            }
          ]
        }
      }
      ''';

        test('Kasus 1: kunci umpan balik ringkasan_utang_rusak ditolak', () {
          final jsonRusak = templatePelajaranUtangValid.replaceAll(
            '"umpanBalik": "ringkasan_utang"',
            '"umpanBalik": "ringkasan_utang_rusak"',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonRusak,
              namaBerkas: 'utang_rusak_1.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom == 'misi.umpanBalik' &&
                    e.berkas == 'utang_rusak_1.json',
              ),
            ),
          );
        });

        test('Kasus 2: kunci umpan balik biaya_pinjaman_rusak ditolak', () {
          final jsonRusak = templatePelajaranUtangValid.replaceAll(
            '"umpanBalik": "ringkasan_utang"',
            '"umpanBalik": "biaya_pinjaman_rusak"',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonRusak,
              namaBerkas: 'utang_rusak_2.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom == 'misi.umpanBalik' &&
                    e.berkas == 'utang_rusak_2.json',
              ),
            ),
          );
        });

        test('Kasus 3: kunci umpan balik rasio_cicilan_rusak ditolak', () {
          final jsonRusak = templatePelajaranUtangValid.replaceAll(
            '"umpanBalik": "ringkasan_utang"',
            '"umpanBalik": "rasio_cicilan_rusak"',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonRusak,
              namaBerkas: 'utang_rusak_3.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom == 'misi.umpanBalik' &&
                    e.berkas == 'utang_rusak_3.json',
              ),
            ),
          );
        });

        test('Kasus 4: kunci umpan balik urutan_pelunasan_rusak ditolak', () {
          final jsonRusak = templatePelajaranUtangValid.replaceAll(
            '"umpanBalik": "ringkasan_utang"',
            '"umpanBalik": "urutan_pelunasan_rusak"',
          );
          expect(
            () => PembacaKonten.uraiPelajaran(
              jsonRusak,
              namaBerkas: 'utang_rusak_4.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom == 'misi.umpanBalik' &&
                    e.berkas == 'utang_rusak_4.json',
              ),
            ),
          );
        });

        test('Kasus 5: gerbang modul atauPernyataan kosong ditolak', () {
          final jsonRusak = templateModulUtangValid.replaceAll(
            '"atauPernyataan": "tidak_punya_utang"',
            '"atauPernyataan": "   "',
          );
          expect(
            () => PembacaKonten.uraiModul(
              jsonRusak,
              namaBerkas: 'modul_utang_rusak.json',
            ),
            throwsA(
              predicate(
                (e) =>
                    e is GalatKonten &&
                    e.kolom == 'gerbang[1].atauPernyataan' &&
                    e.berkas == 'modul_utang_rusak.json',
              ),
            ),
          );
        });

        test(
          'Kasus 6: aturanPraktis: true tanpa catatanReviewer TODO-VERIFIKASI ditolak',
          () {
            final jsonRusak = templatePelajaranUtangValid.replaceAll(
              '"status": "draf",',
              '"status": "draf", "aturanPraktis": true,',
            );
            expect(
              () => PembacaKonten.uraiPelajaran(
                jsonRusak,
                namaBerkas: 'utang_4_3_rusak.json',
              ),
              throwsA(
                predicate(
                  (e) =>
                      e is GalatKonten &&
                      e.kolom == 'catatanReviewer' &&
                      e.berkas == 'utang_4_3_rusak.json',
                ),
              ),
            );
          },
        );

        test(
          'Kasus 7 (pembuktian positif): 4 kunci umpan balik baru dan gerbang atauPernyataan valid',
          () {
            const umpanBalikBaru = [
              'ringkasan_utang',
              'biaya_pinjaman_tercatat',
              'rasio_cicilan_bulan_ini',
              'urutan_pelunasan',
            ];
            for (final ub in umpanBalikBaru) {
              final jsonUji = templatePelajaranUtangValid.replaceAll(
                '"ringkasan_utang"',
                '"$ub"',
              );
              expect(
                () => PembacaKonten.uraiPelajaran(
                  jsonUji,
                  namaBerkas: 'uji_${ub}_valid.json',
                ),
                returnsNormally,
              );
            }

            expect(
              () => PembacaKonten.uraiModul(
                templateModulUtangValid,
                namaBerkas: 'modul_utang_valid.json',
              ),
              returnsNormally,
            );
          },
        );
      },
    );
  });

  group('Pemeriksa Konten Rusak Tahap 8C (Tipe Misi Baru & Sensitif Modul 5)', () {
    // Template pelajaran valid dasar untuk pengujian variasi rusak
    Map<String, dynamic> buatPelajaranDasar({
      String id = 'waspada_penipuan_5_1',
      String judul = 'Ciri Tawaran yang Mencurigakan',
      int durasiMenit = 5,
      String? catatanReviewer = 'TODO-VERIFIKASI. Catatan reviewer resmi.',
      Map<String, dynamic>? misi,
      String pemantik = 'Pemantik edukasi keuangan umum tanpa hal terlarang.',
      List<dynamic>? gerbang,
    }) {
      return {
        'id': id,
        'judul': judul,
        'durasiMenit': durasiMenit,
        'status': 'draf',
        'catatanReviewer': catatanReviewer,
        'gerbang': ?gerbang,
        'pemantik': pemantik,
        'kartu': [
          {
            'judul': 'Kartu Satu',
            'isi': 'Isi kartu edukasi yang baik dan memberdayakan.',
          },
        ],
        'cekPaham': [
          {
            'tanya': 'Pertanyaan satu?',
            'pilihan': ['Pilihan A', 'Pilihan B'],
            'benar': 0,
            'penjelasan': 'Penjelasan jawaban yang jelas.',
          },
          {
            'tanya': 'Pertanyaan dua?',
            'pilihan': ['Pilihan A', 'Pilihan B'],
            'benar': 1,
            'penjelasan': 'Penjelasan jawaban yang jelas.',
          },
        ],
        'misi':
            misi ??
            {
              'tipe': 'keputusan',
              'judul': 'Keputusan Bijak',
              'instruksi': 'Tentukan pilihanmu pada skenario berikut.',
              'skenario': {
                'pemantik':
                    'Ada tawaran menggiurkan yang meminta transfer cepat.',
                'opsi': [
                  {
                    'id': 'a',
                    'teks': 'Langsung kirim.',
                    'aman': false,
                    'umpanBalik': 'Jangan terburu-buru.',
                  },
                  {
                    'id': 'b',
                    'teks': 'Tunda dan periksa.',
                    'aman': true,
                    'umpanBalik': 'Pilihan tepat.',
                  },
                ],
              },
            },
      };
    }

    // 1. Kasus Keputusan: Opsi kurang dari 2
    test('1. Kasus Rusak: Misi keputusan dengan opsi < 2 ditolak', () {
      final data = buatPelajaranDasar(
        misi: {
          'tipe': 'keputusan',
          'judul': 'Keputusan Kurang',
          'instruksi': 'Pilih opsi',
          'skenario': {
            'pemantik': 'Skenario ada tawaran.',
            'opsi': [
              {
                'id': 'a',
                'teks': 'Hanya satu opsi',
                'aman': true,
                'umpanBalik': 'Cukup',
              },
            ],
          },
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(
          isA<GalatKonten>().having(
            (e) => e.kolom,
            'kolom',
            'misi.skenario.opsi',
          ),
        ),
      );
    });

    // 2. Kasus Keputusan: Tidak ada opsi aman: true
    test('2. Kasus Rusak: Misi keputusan tanpa opsi aman: true ditolak', () {
      final data = buatPelajaranDasar(
        misi: {
          'tipe': 'keputusan',
          'judul': 'Keputusan Tanpa Aman',
          'instruksi': 'Pilih opsi',
          'skenario': {
            'pemantik': 'Skenario ada tawaran.',
            'opsi': [
              {
                'id': 'a',
                'teks': 'Opsi bahaya 1',
                'aman': false,
                'umpanBalik': 'Jangan',
              },
              {
                'id': 'b',
                'teks': 'Opsi bahaya 2',
                'aman': false,
                'umpanBalik': 'Hindari',
              },
            ],
          },
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(
          isA<GalatKonten>().having(
            (e) => e.kolom,
            'kolom',
            'misi.skenario.opsi',
          ),
        ),
      );
    });

    // 3. Kasus Keputusan: Opsi tanpa umpanBalik
    test(
      '3. Kasus Rusak: Misi keputusan dengan opsi tanpa umpanBalik ditolak',
      () {
        final data = buatPelajaranDasar(
          misi: {
            'tipe': 'keputusan',
            'judul': 'Keputusan Tanpa Umpan Balik',
            'instruksi': 'Pilih opsi',
            'skenario': {
              'pemantik': 'Skenario ada tawaran.',
              'opsi': [
                {
                  'id': 'a',
                  'teks': 'Opsi bahaya',
                  'aman': false,
                  'umpanBalik': '',
                },
                {
                  'id': 'b',
                  'teks': 'Opsi aman',
                  'aman': true,
                  'umpanBalik': 'Bagus',
                },
              ],
            },
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_1.json',
          ),
          throwsA(
            isA<GalatKonten>().having(
              (e) => e.kolom,
              'kolom',
              'misi.skenario.opsi[0].umpanBalik',
            ),
          ),
        );
      },
    );

    // 4. Kasus Daftar Periksa: Tanpa disclaimer: true
    test(
      '4. Kasus Rusak: Misi daftar_periksa tanpa disclaimer: true ditolak',
      () {
        final data = buatPelajaranDasar(
          misi: {
            'tipe': 'daftar_periksa',
            'judul': 'Daftar Periksa Tanpa Disclaimer',
            'instruksi': 'Centang langkah berikut',
            'minimalDicentang': 3,
            'langkah': [
              {'id': 'l1', 'teks': 'Langkah 1'},
              {'id': 'l2', 'teks': 'Langkah 2'},
              {'id': 'l3', 'teks': 'Langkah 3'},
            ],
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_2.json',
          ),
          throwsA(
            isA<GalatKonten>().having(
              (e) => e.kolom,
              'kolom',
              'misi.disclaimer',
            ),
          ),
        );
      },
    );

    // 5. Kasus Daftar Periksa: Langkah < 3
    test('5. Kasus Rusak: Misi daftar_periksa dengan langkah < 3 ditolak', () {
      final data = buatPelajaranDasar(
        misi: {
          'tipe': 'daftar_periksa',
          'judul': 'Daftar Periksa Singkat',
          'instruksi': 'Centang langkah berikut',
          'disclaimer': true,
          'minimalDicentang': 1,
          'langkah': [
            {'id': 'l1', 'teks': 'Langkah 1'},
            {'id': 'l2', 'teks': 'Langkah 2'},
          ],
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_2.json',
        ),
        throwsA(
          isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.langkah'),
        ),
      );
    });

    // 6. Kasus Daftar Periksa: minimalDicentang di luar batas
    test(
      '6. Kasus Rusak: Misi daftar_periksa dengan minimalDicentang > jumlah langkah ditolak',
      () {
        final data = buatPelajaranDasar(
          misi: {
            'tipe': 'daftar_periksa',
            'judul': 'Daftar Periksa Minimal Berlebih',
            'instruksi': 'Centang langkah berikut',
            'disclaimer': true,
            'minimalDicentang': 4,
            'langkah': [
              {'id': 'l1', 'teks': 'Langkah 1'},
              {'id': 'l2', 'teks': 'Langkah 2'},
              {'id': 'l3', 'teks': 'Langkah 3'},
            ],
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_2.json',
          ),
          throwsA(
            isA<GalatKonten>().having(
              (e) => e.kolom,
              'kolom',
              'misi.minimalDicentang',
            ),
          ),
        );
      },
    );

    // 7. Kasus Daftar Periksa: Tanpa TODO-VERIFIKASI pada catatanReviewer
    test(
      '7. Kasus Rusak: Pelajaran daftar_periksa tanpa TODO-VERIFIKASI pada catatanReviewer ditolak',
      () {
        final data = buatPelajaranDasar(
          catatanReviewer: 'Catatan biasa tanpa penanda khusus.',
          misi: {
            'tipe': 'daftar_periksa',
            'judul': 'Daftar Periksa',
            'instruksi': 'Centang langkah berikut',
            'disclaimer': true,
            'minimalDicentang': 2,
            'langkah': [
              {'id': 'l1', 'teks': 'Langkah 1'},
              {'id': 'l2', 'teks': 'Langkah 2'},
              {'id': 'l3', 'teks': 'Langkah 3'},
            ],
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_2.json',
          ),
          throwsA(
            isA<GalatKonten>().having(
              (e) => e.kolom,
              'kolom',
              'catatanReviewer',
            ),
          ),
        );
      },
    );

    // 8. Sensitif Modul 5: Judul memuat label "aman" atau "bahaya"
    test(
      '8. Kasus Rusak: Judul pelajaran Modul 5 memuat kata "aman" ditolak',
      () {
        final data = buatPelajaranDasar(judul: 'Cara Aman Memilih Pinjaman');
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_1.json',
          ),
          throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'judul')),
        );
      },
    );

    test(
      '8b. Kasus Rusak: Judul pelajaran Modul 5 memuat kata "bahaya" ditolak',
      () {
        final data = buatPelajaranDasar(judul: 'Waspada Bahaya Pinjol');
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_1.json',
          ),
          throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'judul')),
        );
      },
    );

    // 9. Sensitif Modul 5: Tautan "http"
    test('9. Kasus Rusak: Teks Modul 5 memuat "http" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Buka tautan http://cek-pinjol.com untuk melihat daftar.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 10. Sensitif Modul 5: Alamat web "www"
    test('10. Kasus Rusak: Teks Modul 5 memuat "www" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Kunjungi situs www.resmi.go.id untuk memeriksa perizinan.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 11. Sensitif Modul 5: Simbol surel/sosial media "@"
    test('11. Kasus Rusak: Teks Modul 5 memuat "@" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Kirimkan laporanmu ke halo@funda.id segera.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 12. Sensitif Modul 5: Nama lembaga "OJK"
    test('12. Kasus Rusak: Teks Modul 5 menyebut lembaga "OJK" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Pastikan penyedia berizin resmi di OJK sebelum meminjam.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 13. Sensitif Modul 5: Nama lembaga "BSSN"
    test('13. Kasus Rusak: Teks Modul 5 menyebut lembaga "BSSN" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Ikuti pedoman keamanan data dari BSSN.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'waspada_penipuan_5_1.json',
        ),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 14. Sensitif Modul 5: Urutan digit >= 8 tanpa titik (nomor telepon)
    test(
      '14. Kasus Rusak: Teks Modul 5 memuat digit >= 8 tanpa titik (nomor telepon) ditolak',
      () {
        final data = buatPelajaranDasar(
          pemantik: 'Hubungi pengaduan lewat nomor 08123456789 ini.',
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'waspada_penipuan_5_1.json',
          ),
          throwsA(
            isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik'),
          ),
        );
      },
    );

    // 15. Kasus Disclaimer: Kunci tidak ada atau teks tidak sesuai lampiran
    test(
      '15. Kasus Rusak: Berkas disclaimer.json tanpa langkahDuniaNyata ditolak',
      () {
        expect(
          () => PembacaKonten.validasiBerkasDisclaimer(
            {},
            namaBerkas: 'disclaimer.json',
          ),
          throwsA(
            isA<GalatKonten>().having(
              (e) => e.kolom,
              'kolom',
              'langkahDuniaNyata',
            ),
          ),
        );
      },
    );

    test(
      '15b. Kasus Rusak: Berkas disclaimer.json dengan teks yang diubah ditolak',
      () {
        final data = {
          'langkahDuniaNyata': 'Funda hanya memberi saran umum saja.',
        };
        expect(
          () => PembacaKonten.validasiBerkasDisclaimer(
            data,
            namaBerkas: 'disclaimer.json',
          ),
          throwsA(
            isA<GalatKonten>().having(
              (e) => e.kolom,
              'kolom',
              'langkahDuniaNyata',
            ),
          ),
        );
      },
    );

    // =========================================================================
    // TAHAP 8D: Tipe Misi Refleksi & Kunci Umpan Balik Baru
    // =========================================================================
    // 16. Misi Refleksi: Kolom pertanyaan tidak ada (null)
    test('16. Kasus Rusak: Misi refleksi tanpa kolom pertanyaan ditolak', () {
      final data = buatPelajaranDasar(
        id: 'psikologi_uang_6_1',
        misi: {
          'tipe': 'refleksi',
          'judul': 'Kenali pemicu belanjamu',
          'instruksi': 'Tulis satu situasi belanjamu.',
          'minimalKarakter': 10,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'psikologi_uang_6_1.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
              .having((e) => e.kolom, 'kolom', 'misi.pertanyaan'),
        ),
      );
    });

    // 17. Misi Refleksi: Kolom pertanyaan string kosong
    test('17. Kasus Rusak: Misi refleksi dengan pertanyaan kosong ditolak', () {
      final data = buatPelajaranDasar(
        id: 'psikologi_uang_6_1',
        misi: {
          'tipe': 'refleksi',
          'judul': 'Kenali pemicu belanjamu',
          'instruksi': 'Tulis satu situasi belanjamu.',
          'pertanyaan': '   ',
          'minimalKarakter': 10,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'psikologi_uang_6_1.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
              .having((e) => e.kolom, 'kolom', 'misi.pertanyaan'),
        ),
      );
    });

    // 18. Misi Refleksi: Kolom instruksi tidak ada atau kosong
    test('18. Kasus Rusak: Misi refleksi tanpa kolom instruksi ditolak', () {
      final data = buatPelajaranDasar(
        id: 'psikologi_uang_6_1',
        misi: {
          'tipe': 'refleksi',
          'judul': 'Kenali pemicu belanjamu',
          'pertanyaan': 'Kapan kamu belanja tanpa rencana?',
          'minimalKarakter': 10,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'psikologi_uang_6_1.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
              .having((e) => e.kolom, 'kolom', 'misi.instruksi'),
        ),
      );
    });

    // 19. Misi Refleksi: minimalKarakter < 5 ditolak
    test(
      '19. Kasus Rusak: Misi refleksi dengan minimalKarakter < 5 ditolak',
      () {
        final data = buatPelajaranDasar(
          id: 'psikologi_uang_6_1',
          misi: {
            'tipe': 'refleksi',
            'judul': 'Kenali pemicu belanjamu',
            'instruksi': 'Tulis satu situasi belanjamu.',
            'pertanyaan': 'Kapan kamu belanja tanpa rencana?',
            'minimalKarakter': 4,
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'psikologi_uang_6_1.json',
          ),
          throwsA(
            isA<GalatKonten>()
                .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
                .having((e) => e.kolom, 'kolom', 'misi.minimalKarakter'),
          ),
        );
      },
    );

    // 20. Misi Refleksi: minimalKarakter > 200 ditolak
    test(
      '20. Kasus Rusak: Misi refleksi dengan minimalKarakter > 200 ditolak',
      () {
        final data = buatPelajaranDasar(
          id: 'psikologi_uang_6_1',
          misi: {
            'tipe': 'refleksi',
            'judul': 'Kenali pemicu belanjamu',
            'instruksi': 'Tulis satu situasi belanjamu.',
            'pertanyaan': 'Kapan kamu belanja tanpa rencana?',
            'minimalKarakter': 201,
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'psikologi_uang_6_1.json',
          ),
          throwsA(
            isA<GalatKonten>()
                .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
                .having((e) => e.kolom, 'kolom', 'misi.minimalKarakter'),
          ),
        );
      },
    );

    // 21. Misi Refleksi: minimalKarakter bukan integer ditolak
    test(
      '21. Kasus Rusak: Misi refleksi dengan minimalKarakter bukan integer ditolak',
      () {
        final data = buatPelajaranDasar(
          id: 'psikologi_uang_6_1',
          misi: {
            'tipe': 'refleksi',
            'judul': 'Kenali pemicu belanjamu',
            'instruksi': 'Tulis satu situasi belanjamu.',
            'pertanyaan': 'Kapan kamu belanja tanpa rencana?',
            'minimalKarakter': 'sepuluh',
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'psikologi_uang_6_1.json',
          ),
          throwsA(
            isA<GalatKonten>()
                .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
                .having((e) => e.kolom, 'kolom', 'misi.minimalKarakter'),
          ),
        );
      },
    );

    // 22. Umpan Balik: Kunci umpan balik tidak dikenal ditolak
    test('22. Kasus Rusak: Kunci umpan balik tidak terdaftar ditolak', () {
      final data = buatPelajaranDasar(
        id: 'psikologi_uang_6_2',
        misi: {
          'tipe': 'lihat_hitungan',
          'judul': 'Lihat langganan',
          'instruksi': 'Buka ringkasan',
          'umpanBalik': 'umpan_balik_tidak_dikenal_xyz',
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'psikologi_uang_6_2.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_2.json')
              .having((e) => e.kolom, 'kolom', 'misi.umpanBalik'),
        ),
      );
    });

    // 23. Tipe misi komitmen tetap ditolak
    test(
      '23. Kasus Rusak: Jenis misi komitmen tetap ditolak pada Tahap 8D',
      () {
        final data = buatPelajaranDasar(
          id: 'psikologi_uang_6_1',
          misi: {
            'tipe': 'komitmen',
            'judul': 'Komitmen Finansial',
            'instruksi': 'Tulis komitmenmu.',
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'psikologi_uang_6_1.json',
          ),
          throwsA(
            isA<GalatKonten>()
                .having((e) => e.berkas, 'berkas', 'psikologi_uang_6_1.json')
                .having((e) => e.kolom, 'kolom', 'misi.tipe'),
          ),
        );
      },
    );

    // 24. Validasi Sukses: Pelajaran dengan misi refleksi dan umpan balik baru lolos
    test(
      '24. Validasi Sukses: Misi refleksi valid dan kunci umpan balik ringkasan_langganan_dan_keinginan diterima',
      () {
        final dataRefleksi = buatPelajaranDasar(
          id: 'psikologi_uang_6_1',
          misi: {
            'tipe': 'refleksi',
            'judul': 'Kenali pemicu belanjamu',
            'instruksi':
                'Tulis satu situasi atau perasaan yang paling sering membuatmu belanja tanpa rencana. Catatan ini privat di HP-mu.',
            'pertanyaan':
                'Kapan atau dalam keadaan apa kamu paling sering membeli sesuatu tanpa rencana?',
            'petunjukInput':
                'Contoh: Saat capek pulang kuliah dan buka aplikasi belanja malam-malam.',
            'minimalKarakter': 10,
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            dataRefleksi,
            namaBerkas: 'psikologi_uang_6_1.json',
          ),
          returnsNormally,
        );

        final dataHitungan = buatPelajaranDasar(
          id: 'psikologi_uang_6_2',
          misi: {
            'tipe': 'lihat_hitungan',
            'judul': 'Lihat langganan dan keinginanmu',
            'instruksi':
                'Buka ringkasan langganan aktif dan pengeluaran keinginan bulan ini, baca isinya, lalu tekan Mengerti.',
            'umpanBalik': 'ringkasan_langganan_dan_keinginan',
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            dataHitungan,
            namaBerkas: 'psikologi_uang_6_2.json',
          ),
          returnsNormally,
        );
      },
    );

    // 25. Validasi Misi Sandbox (Tahap 9A)
    test('25.1. Misi sandbox valid lolos validasi', () {
      final data = buatPelajaranDasar(
        id: 'investasi_dasar_11_3',
        misi: {
          'tipe': 'sandbox',
          'judul': 'Coba Mode Sandbox investasi',
          'instruksi':
              'Buka Mode Sandbox, atur alokasi portofolio sesukamu, lalu majukan simulasi minimal 1 tahun untuk melihat hasilnya.',
          'disclaimer': true,
          'minimalSimulasi': 1,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'investasi_dasar_11_3.json',
        ),
        returnsNormally,
      );
    });

    test('25.2. Misi sandbox tanpa disclaimer: true ditolak', () {
      final data = buatPelajaranDasar(
        id: 'investasi_dasar_11_3',
        misi: {
          'tipe': 'sandbox',
          'judul': 'Coba Mode Sandbox investasi',
          'instruksi': 'Buka Mode Sandbox.',
          'minimalSimulasi': 1,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'investasi_dasar_11_3.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'investasi_dasar_11_3.json')
              .having((e) => e.kolom, 'kolom', 'misi.disclaimer'),
        ),
      );

      final dataFalse = buatPelajaranDasar(
        id: 'investasi_dasar_11_3',
        misi: {
          'tipe': 'sandbox',
          'judul': 'Coba Mode Sandbox investasi',
          'instruksi': 'Buka Mode Sandbox.',
          'disclaimer': false,
          'minimalSimulasi': 1,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          dataFalse,
          namaBerkas: 'investasi_dasar_11_3.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'investasi_dasar_11_3.json')
              .having((e) => e.kolom, 'kolom', 'misi.disclaimer'),
        ),
      );
    });

    test('25.3. Misi sandbox dengan minimalSimulasi tidak valid ditolak', () {
      final data = buatPelajaranDasar(
        id: 'investasi_dasar_11_3',
        misi: {
          'tipe': 'sandbox',
          'judul': 'Coba Mode Sandbox investasi',
          'instruksi': 'Buka Mode Sandbox.',
          'disclaimer': true,
          'minimalSimulasi': 0,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'investasi_dasar_11_3.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'investasi_dasar_11_3.json')
              .having((e) => e.kolom, 'kolom', 'misi.minimalSimulasi'),
        ),
      );
    });

    test('25.4. Misi sandbox tanpa instruksi ditolak', () {
      final data = buatPelajaranDasar(
        id: 'investasi_dasar_11_3',
        misi: {
          'tipe': 'sandbox',
          'judul': 'Coba Mode Sandbox investasi',
          'disclaimer': true,
          'minimalSimulasi': 1,
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(
          data,
          namaBerkas: 'investasi_dasar_11_3.json',
        ),
        throwsA(
          isA<GalatKonten>()
              .having((e) => e.berkas, 'berkas', 'investasi_dasar_11_3.json')
              .having((e) => e.kolom, 'kolom', 'misi.instruksi'),
        ),
      );
    });

    test(
      '25.5. Misi sandbox dikecualikan dari perbandingan misi vs gerbang',
      () {
        final data = buatPelajaranDasar(
          id: 'investasi_dasar_11_3',
          gerbang: [
            {'tipe': 'ada_data', 'objek': 'transaksi', 'min': 5},
          ],
          misi: {
            'tipe': 'sandbox',
            'judul': 'Coba Mode Sandbox investasi',
            'instruksi':
                'Buka Mode Sandbox, atur alokasi, jalankan minimal 1 simulasi.',
            'disclaimer': true,
            'minimalSimulasi': 1,
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'investasi_dasar_11_3.json',
          ),
          returnsNormally,
        );
      },
    );

    // 26. Validasi Kunci Umpan Balik ringkasan_proteksi_dasar (Tahap 9B)
    test(
      '26. Validasi Sukses: Misi lihat_hitungan dengan kunci ringkasan_proteksi_dasar lolos validasi',
      () {
        final data = buatPelajaranDasar(
          id: 'proteksi_dasar_10_3',
          misi: {
            'tipe': 'lihat_hitungan',
            'judul': 'Lihat gambaran beban wajib dan dana daruratmu',
            'instruksi':
                'Buka ringkasan pengeluaran wajib dan dana daruratmu saat ini, baca isinya, lalu tekan Mengerti.',
            'umpanBalik': 'ringkasan_proteksi_dasar',
          },
        );
        expect(
          () => PembacaKonten.validasiKontenPelajaran(
            data,
            namaBerkas: 'proteksi_dasar_10_3.json',
          ),
          returnsNormally,
        );
      },
    );
  });
}
