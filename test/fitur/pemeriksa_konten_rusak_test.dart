import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';

void main() {
  group('Pemeriksa Konten Rusak Tahap 8C (Tipe Misi Baru & Sensitif Modul 5)', () {
    // Template pelajaran valid dasar untuk pengujian variasi rusak
    Map<String, dynamic> buatPelajaranDasar({
      String id = 'waspada_penipuan_5_1',
      String judul = 'Ciri Tawaran yang Mencurigakan',
      int durasiMenit = 5,
      String? catatanReviewer = 'TODO-VERIFIKASI. Catatan reviewer resmi.',
      Map<String, dynamic>? misi,
      String pemantik = 'Pemantik edukasi keuangan umum tanpa hal terlarang.',
    }) {
      return {
        'id': id,
        'judul': judul,
        'durasiMenit': durasiMenit,
        'status': 'draf',
        'catatanReviewer': catatanReviewer,
        'pemantik': pemantik,
        'kartu': [
          {'judul': 'Kartu Satu', 'isi': 'Isi kartu edukasi yang baik dan memberdayakan.'},
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
        'misi': misi ??
            {
              'tipe': 'keputusan',
              'judul': 'Keputusan Bijak',
              'instruksi': 'Tentukan pilihanmu pada skenario berikut.',
              'skenario': {
                'pemantik': 'Ada tawaran menggiurkan yang meminta transfer cepat.',
                'opsi': [
                  {'id': 'a', 'teks': 'Langsung kirim.', 'aman': false, 'umpanBalik': 'Jangan terburu-buru.'},
                  {'id': 'b', 'teks': 'Tunda dan periksa.', 'aman': true, 'umpanBalik': 'Pilihan tepat.'},
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
              {'id': 'a', 'teks': 'Hanya satu opsi', 'aman': true, 'umpanBalik': 'Cukup'},
            ],
          },
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.skenario.opsi')),
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
              {'id': 'a', 'teks': 'Opsi bahaya 1', 'aman': false, 'umpanBalik': 'Jangan'},
              {'id': 'b', 'teks': 'Opsi bahaya 2', 'aman': false, 'umpanBalik': 'Hindari'},
            ],
          },
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.skenario.opsi')),
      );
    });

    // 3. Kasus Keputusan: Opsi tanpa umpanBalik
    test('3. Kasus Rusak: Misi keputusan dengan opsi tanpa umpanBalik ditolak', () {
      final data = buatPelajaranDasar(
        misi: {
          'tipe': 'keputusan',
          'judul': 'Keputusan Tanpa Umpan Balik',
          'instruksi': 'Pilih opsi',
          'skenario': {
            'pemantik': 'Skenario ada tawaran.',
            'opsi': [
              {'id': 'a', 'teks': 'Opsi bahaya', 'aman': false, 'umpanBalik': ''},
              {'id': 'b', 'teks': 'Opsi aman', 'aman': true, 'umpanBalik': 'Bagus'},
            ],
          },
        },
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.skenario.opsi[0].umpanBalik')),
      );
    });

    // 4. Kasus Daftar Periksa: Tanpa disclaimer: true
    test('4. Kasus Rusak: Misi daftar_periksa tanpa disclaimer: true ditolak', () {
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
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_2.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.disclaimer')),
      );
    });

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
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_2.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.langkah')),
      );
    });

    // 6. Kasus Daftar Periksa: minimalDicentang di luar batas
    test('6. Kasus Rusak: Misi daftar_periksa dengan minimalDicentang > jumlah langkah ditolak', () {
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
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_2.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'misi.minimalDicentang')),
      );
    });

    // 7. Kasus Daftar Periksa: Tanpa TODO-VERIFIKASI pada catatanReviewer
    test('7. Kasus Rusak: Pelajaran daftar_periksa tanpa TODO-VERIFIKASI pada catatanReviewer ditolak', () {
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
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_2.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'catatanReviewer')),
      );
    });

    // 8. Sensitif Modul 5: Judul memuat label "aman" atau "bahaya"
    test('8. Kasus Rusak: Judul pelajaran Modul 5 memuat kata "aman" ditolak', () {
      final data = buatPelajaranDasar(
        judul: 'Cara Aman Memilih Pinjaman',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'judul')),
      );
    });

    test('8b. Kasus Rusak: Judul pelajaran Modul 5 memuat kata "bahaya" ditolak', () {
      final data = buatPelajaranDasar(
        judul: 'Waspada Bahaya Pinjol',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'judul')),
      );
    });

    // 9. Sensitif Modul 5: Tautan "http"
    test('9. Kasus Rusak: Teks Modul 5 memuat "http" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Buka tautan http://cek-pinjol.com untuk melihat daftar.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 10. Sensitif Modul 5: Alamat web "www"
    test('10. Kasus Rusak: Teks Modul 5 memuat "www" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Kunjungi situs www.resmi.go.id untuk memeriksa perizinan.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 11. Sensitif Modul 5: Simbol surel/sosial media "@"
    test('11. Kasus Rusak: Teks Modul 5 memuat "@" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Kirimkan laporanmu ke halo@funda.id segera.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 12. Sensitif Modul 5: Nama lembaga "OJK"
    test('12. Kasus Rusak: Teks Modul 5 menyebut lembaga "OJK" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Pastikan penyedia berizin resmi di OJK sebelum meminjam.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 13. Sensitif Modul 5: Nama lembaga "BSSN"
    test('13. Kasus Rusak: Teks Modul 5 menyebut lembaga "BSSN" ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Ikuti pedoman keamanan data dari BSSN.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 14. Sensitif Modul 5: Urutan digit >= 8 tanpa titik (nomor telepon)
    test('14. Kasus Rusak: Teks Modul 5 memuat digit >= 8 tanpa titik (nomor telepon) ditolak', () {
      final data = buatPelajaranDasar(
        pemantik: 'Hubungi pengaduan lewat nomor 08123456789 ini.',
      );
      expect(
        () => PembacaKonten.validasiKontenPelajaran(data, namaBerkas: 'waspada_penipuan_5_1.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'pemantik')),
      );
    });

    // 15. Kasus Disclaimer: Kunci tidak ada atau teks tidak sesuai lampiran
    test('15. Kasus Rusak: Berkas disclaimer.json tanpa langkahDuniaNyata ditolak', () {
      expect(
        () => PembacaKonten.validasiBerkasDisclaimer({}, namaBerkas: 'disclaimer.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'langkahDuniaNyata')),
      );
    });

    test('15b. Kasus Rusak: Berkas disclaimer.json dengan teks yang diubah ditolak', () {
      final data = {
        'langkahDuniaNyata': 'Funda hanya memberi saran umum saja.',
      };
      expect(
        () => PembacaKonten.validasiBerkasDisclaimer(data, namaBerkas: 'disclaimer.json'),
        throwsA(isA<GalatKonten>().having((e) => e.kolom, 'kolom', 'langkahDuniaNyata')),
      );
    });
  });
}
