import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/perhitungan/perhitungan_tes_awal_personalisasi.dart';

void main() {
  group('1. Pengujian Fungsi Murni hitungSkorTesAwal', () {
    final daftar12Soal = [
      const SoalTesAwalKonten(id: 's1', modulId: 'anggaran_arus_kas', tanya: 'T1', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's2', modulId: 'anggaran_arus_kas', tanya: 'T2', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 0, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's3', modulId: 'tabungan', tanya: 'T3', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's4', modulId: 'tabungan', tanya: 'T4', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 0, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's5', modulId: 'dana_darurat', tanya: 'T5', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's6', modulId: 'dana_darurat', tanya: 'T6', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's7', modulId: 'utang_cicilan', tanya: 'T7', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 0, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's8', modulId: 'utang_cicilan', tanya: 'T8', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's9', modulId: 'waspada_penipuan', tanya: 'T9', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 0, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's10', modulId: 'waspada_penipuan', tanya: 'T10', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's11', modulId: 'psikologi_uang', tanya: 'T11', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 1, penjelasan: 'P'),
      const SoalTesAwalKonten(id: 's12', modulId: 'psikologi_uang', tanya: 'T12', pilihan: ['A', 'B', 'C', 'Belum tahu, nggak apa-apa'], benar: 0, penjelasan: 'P'),
    ];

    test('Semua jawaban benar menghasilkan skor 100% di semua modul dan skor total 100%', () {
      final jawaban = {
        's1': 1, 's2': 0,
        's3': 1, 's4': 0,
        's5': 1, 's6': 1,
        's7': 0, 's8': 1,
        's9': 0, 's10': 1,
        's11': 1, 's12': 0,
      };

      final hasil = hitungSkorTesAwal(jawabanPengguna: jawaban, daftarSoal: daftar12Soal);
      expect(hasil.totalBenar, equals(12));
      expect(hasil.totalSoal, equals(12));
      expect(hasil.skorTotalPersen, equals(100));
      for (final m in ['anggaran_arus_kas', 'tabungan', 'dana_darurat', 'utang_cicilan', 'waspada_penipuan', 'psikologi_uang']) {
        expect(hasil.skorPerModul[m], equals(100));
      }
    });

    test('Semua memilih "Belum tahu, nggak apa-apa" (indeks 3) menghasilkan skor 0%', () {
      final jawaban = {
        for (var i = 1; i <= 12; i++) 's$i': 3,
      };

      final hasil = hitungSkorTesAwal(jawabanPengguna: jawaban, daftarSoal: daftar12Soal);
      expect(hasil.totalBenar, equals(0));
      expect(hasil.totalSoal, equals(12));
      expect(hasil.skorTotalPersen, equals(0));
      for (final m in ['anggaran_arus_kas', 'tabungan', 'dana_darurat', 'utang_cicilan', 'waspada_penipuan', 'psikologi_uang']) {
        expect(hasil.skorPerModul[m], equals(0));
      }
    });

    test('Benar 1 dari 2 soal menghasilkan skor 50% untuk modul tersebut', () {
      final jawaban = {
        's1': 1, 's2': 3, // anggaran_arus_kas: benar 1 -> 50%
        's3': 1, 's4': 0, // tabungan: benar 2 -> 100%
        's5': 3, 's6': 3, // dana_darurat: benar 0 -> 0%
        's7': 0, 's8': 3, // utang_cicilan: benar 1 -> 50%
        's9': 3, 's10': 3, // waspada_penipuan: benar 0 -> 0%
        's11': 1, 's12': 0, // psikologi_uang: benar 2 -> 100%
      };
      // Total benar: 1 + 2 + 0 + 1 + 0 + 2 = 6 dari 12 (50%)
      final hasil = hitungSkorTesAwal(jawabanPengguna: jawaban, daftarSoal: daftar12Soal);
      expect(hasil.totalBenar, equals(6));
      expect(hasil.skorTotalPersen, equals(50));
      expect(hasil.skorPerModul['anggaran_arus_kas'], equals(50));
      expect(hasil.skorPerModul['tabungan'], equals(100));
      expect(hasil.skorPerModul['dana_darurat'], equals(0));
    });
  });

  group('2. Pengujian Fungsi Murni bangunProfil', () {
    test('Validasi profil berhasil dengan input enum yang sah', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'ya',
          'dana_darurat': 'sedikit',
          'menabung': 'kadang',
          'investasi': 'belum',
          'mencatat_keuangan': 'rutin',
        },
        tujuanUtama: 'Ingin bebas dari utang dan punya tabungan.',
      );

      expect(profil.punyaPenghasilan, equals('rutin'));
      expect(profil.punyaUtang, equals('ya'));
      expect(profil.tujuanUtama, equals('Ingin bebas dari utang dan punya tabungan.'));
    });

    test('Tujuan utama yang melebihi 100 karakter dipotong aman (truncate)', () {
      final teksPanjang = 'A' * 150;
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'tidak',
          'dana_darurat': 'sudah',
          'menabung': 'rutin',
          'investasi': 'aktif',
          'mencatat_keuangan': 'rutin',
        },
        tujuanUtama: teksPanjang,
      );

      expect(profil.tujuanUtama?.length, equals(100));
    });

    test('Nilai enum tidak dikenal otomatis disetel ke default fallback aman', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'nilai_ngawur',
          'punya_utang': 'ngawur',
          'dana_darurat': 'ngawur',
          'menabung': 'ngawur',
          'investasi': 'ngawur',
          'mencatat_keuangan': 'ngawur',
        },
      );

      expect(profil.punyaPenghasilan, equals('belum'));
      expect(profil.punyaUtang, equals('tidak_yakin'));
      expect(profil.danaDarurat, equals('belum'));
    });
  });

  group('3. Pengujian Fungsi Murni rekomendasiModul', () {
    test('Pengguna punya utang memprioritaskan modul utang_cicilan', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'ya',
          'dana_darurat': 'sudah',
          'menabung': 'rutin',
          'investasi': 'aktif',
          'mencatat_keuangan': 'rutin',
        },
      );

      final hasilRekomendasi = rekomendasiModul(
        profil: profil,
        skorPerModul: {
          'anggaran_arus_kas': 100,
          'tabungan': 100,
          'dana_darurat': 100,
          'utang_cicilan': 50,
          'waspada_penipuan': 100,
          'psikologi_uang': 100,
        },
        modulSelesai: {},
      );

      expect(hasilRekomendasi.isNotEmpty, isTrue);
      expect(hasilRekomendasi.first.modulId, equals('utang_cicilan'));
      expect(hasilRekomendasi.first.kodeAlasan, equals('ada_utang'));
    });

    test('Pengguna dana darurat belum memprioritaskan modul dana_darurat', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'tidak',
          'dana_darurat': 'belum',
          'menabung': 'belum',
          'investasi': 'belum',
          'mencatat_keuangan': 'belum',
        },
      );

      final hasilRekomendasi = rekomendasiModul(
        profil: profil,
        skorPerModul: {
          'anggaran_arus_kas': 100,
          'tabungan': 100,
          'dana_darurat': 50,
          'utang_cicilan': 100,
          'waspada_penipuan': 100,
          'psikologi_uang': 100,
        },
        modulSelesai: {},
      );

      final ids = hasilRekomendasi.map((r) => r.modulId).toList();
      expect(ids.contains('dana_darurat'), isTrue);
    });

    test('Maksimal menghasilkan 3 modul rekomendasi unik', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'ya',
          'dana_darurat': 'belum',
          'menabung': 'belum',
          'investasi': 'belum',
          'mencatat_keuangan': 'belum',
        },
      );

      final hasilRekomendasi = rekomendasiModul(
        profil: profil,
        skorPerModul: {
          'anggaran_arus_kas': 0,
          'tabungan': 0,
          'dana_darurat': 0,
          'utang_cicilan': 0,
          'waspada_penipuan': 0,
          'psikologi_uang': 0,
        },
        modulSelesai: {},
      );

      expect(hasilRekomendasi.length, lessThanOrEqualTo(3));
      final ids = hasilRekomendasi.map((r) => r.modulId).toSet();
      expect(ids.length, equals(hasilRekomendasi.length), reason: 'Rekomendasi tidak boleh duplikat');
    });

    test('Modul yang sudah selesai tidak direkomendasikan lagi', () {
      final profil = bangunProfil(
        jawabanProfil: {
          'punya_penghasilan': 'rutin',
          'punya_utang': 'ya',
          'dana_darurat': 'sudah',
          'menabung': 'rutin',
          'investasi': 'aktif',
          'mencatat_keuangan': 'rutin',
        },
      );

      final hasilRekomendasi = rekomendasiModul(
        profil: profil,
        skorPerModul: {
          'anggaran_arus_kas': 100,
          'tabungan': 100,
          'dana_darurat': 100,
          'utang_cicilan': 50,
          'waspada_penipuan': 100,
          'psikologi_uang': 100,
        },
        modulSelesai: {'utang_cicilan'}, // Sudah selesai
      );

      final ids = hasilRekomendasi.map((r) => r.modulId).toList();
      expect(ids.contains('utang_cicilan'), isFalse);
    });
  });

  group('4. Pengujian Fungsi Murni Prioritas Lanjut Belajar di Beranda', () {
    test('Pelajaran yang berstatus sedang memiliki prioritas tertinggi', () {
      final target = tentukanTargetLanjutBelajar(
        pelajaranSedang: 'anggaran_arus_kas_1_2',
        modulSedang: 'anggaran_arus_kas',
        rekomendasiTerbuka: [
          const RekomendasiTargetBelajar(modulId: 'dana_darurat', pelajaranId: 'dana_darurat_1_1'),
        ],
        modulTerbukaPertama: 'tabungan',
        pelajaranTerbukaPertama: 'tabungan_1_1',
      );

      expect(target.modulId, equals('anggaran_arus_kas'));
      expect(target.pelajaranId, equals('anggaran_arus_kas_1_2'));
      expect(target.alasan, equals(AlasanTargetBelajar.sedangBerjalan));
    });

    test('Jika tidak ada yang sedang berjalan, ambil pelajaran dari rekomendasi pertama yang terbuka', () {
      final target = tentukanTargetLanjutBelajar(
        pelajaranSedang: null,
        modulSedang: null,
        rekomendasiTerbuka: [
          const RekomendasiTargetBelajar(modulId: 'dana_darurat', pelajaranId: 'dana_darurat_1_1'),
        ],
        modulTerbukaPertama: 'anggaran_arus_kas',
        pelajaranTerbukaPertama: 'anggaran_arus_kas_1_2',
      );

      expect(target.modulId, equals('dana_darurat'));
      expect(target.pelajaranId, equals('dana_darurat_1_1'));
      expect(target.alasan, equals(AlasanTargetBelajar.rekomendasi));
    });

    test('Jika tidak ada rekomendasi terbuka, fallback ke modul dan pelajaran terbuka pertama', () {
      final target = tentukanTargetLanjutBelajar(
        pelajaranSedang: null,
        modulSedang: null,
        rekomendasiTerbuka: [],
        modulTerbukaPertama: 'anggaran_arus_kas',
        pelajaranTerbukaPertama: 'anggaran_arus_kas_1_2',
      );

      expect(target.modulId, equals('anggaran_arus_kas'));
      expect(target.pelajaranId, equals('anggaran_arus_kas_1_2'));
      expect(target.alasan, equals(AlasanTargetBelajar.terbukaPertama));
    });
  });
}
