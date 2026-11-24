import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/hasil_misi_repositori.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';

void main() {
  group('Evaluator Misi Refleksi (Tahap 8D)', () {
    test('1. Di bawah minimal karakter menghasilkan evaluasi false', () {
      // Minimal karakter default = 10
      const teks9 = '123456789';
      expect(
        RegistriMisi.evaluasiRefleksi(teks9, minimalKarakter: 10),
        isFalse,
      );

      const teks4 = 'Halo';
      expect(RegistriMisi.evaluasiRefleksi(teks4, minimalKarakter: 5), isFalse);
    });

    test('2. Tepat pas minimal karakter menghasilkan evaluasi true', () {
      // 10 karakter pas
      const teks10 = '1234567890';
      expect(
        RegistriMisi.evaluasiRefleksi(teks10, minimalKarakter: 10),
        isTrue,
      );

      // 5 karakter pas
      const teks5 = 'Malam';
      expect(RegistriMisi.evaluasiRefleksi(teks5, minimalKarakter: 5), isTrue);
    });

    test('3. Spasi saja ditolak (panjang trim() = 0)', () {
      const spasi = '          ';
      expect(
        RegistriMisi.evaluasiRefleksi(spasi, minimalKarakter: 10),
        isFalse,
      );

      const spasiDenganTab = '   \t  \n   ';
      expect(
        RegistriMisi.evaluasiRefleksi(spasiDenganTab, minimalKarakter: 10),
        isFalse,
      );

      // Teks 8 karakter dengan 10 spasi di depan dan belakang tetap di bawah 10
      const teksTrimPendek = '   12345678   ';
      expect(
        RegistriMisi.evaluasiRefleksi(teksTrimPendek, minimalKarakter: 10),
        isFalse,
      );
    });

    test('4. Teks valid melebihi minimal karakter', () {
      const teksPanjang =
          'Saat capek pulang kuliah dan buka aplikasi belanja malam-malam.';
      expect(
        RegistriMisi.evaluasiRefleksi(teksPanjang, minimalKarakter: 10),
        isTrue,
      );
    });

    test('5. Evaluasi umum RegistriMisi.evaluasi untuk tipe refleksi', () {
      const misi = MisiKonten(
        tipe: 'refleksi',
        judul: 'Kenali pemicu belanjamu',
        deskripsi: 'Catatan ini privat di HP-mu',
        instruksi: 'Tulis satu situasi',
        perkiraanMenit: 2,
        pertanyaan: 'Kapan kamu belanja tanpa rencana?',
        minimalKarakter: 10,
      );

      final hasil = RegistriMisi.evaluasi(
        misi: misi,
        fotoData: FotoDataPengguna.kosong(),
      );

      expect(hasil.didukung, isTrue);
      expect(hasil.selesai, isFalse);
      expect(hasil.statusTeks, equals('Tulis refleksimu pada kolom di atas.'));
    });
  });

  group('Persistensi & Muat Ulang Hasil Misi Refleksi (Tahap 8D)', () {
    late BasisDataFunda db;
    late HasilMisiRepositori repo;

    setUp(() {
      db = BasisDataFunda(NativeDatabase.memory());
      repo = HasilMisiRepositori(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Simpan refleksi ke tabel_hasil_misi, muat ulang, dan ubah jawaban',
      () async {
        const pelajaranId = 'psikologi_uang_6_1';
        const jawabanAwal =
            'Saat lelah lembur kerja dan melihat promo makanan manis.';

        // 1. Simpan jawaban awal
        await repo.simpanHasilMisi(
          misiId: pelajaranId,
          pelajaranId: pelajaranId,
          tipe: 'refleksi',
          status: 'selesai',
          muatanJson: jsonEncode({'jawaban': jawabanAwal}),
        );

        // 2. Ambil kembali
        final hasilTersimpan = await repo.ambilHasilMisi(pelajaranId);
        expect(hasilTersimpan, isNotNull);
        expect(hasilTersimpan!.status, equals('selesai'));
        expect(hasilTersimpan.tipe, equals('refleksi'));

        final muatan =
            jsonDecode(hasilTersimpan.muatanJson!) as Map<String, dynamic>;
        expect(muatan['jawaban'], equals(jawabanAwal));

        // 3. Pelajaran dibuka ulang dan jawaban diubah
        const jawabanRevisi =
            'Melihat notifikasi diskon kilat tengah malam saat belum tidur.';
        await repo.simpanHasilMisi(
          misiId: pelajaranId,
          pelajaranId: pelajaranId,
          tipe: 'refleksi',
          status: 'selesai',
          muatanJson: jsonEncode({'jawaban': jawabanRevisi}),
        );

        // 4. Verifikasi jawaban terbarui di database
        final hasilTerbaru = await repo.ambilHasilMisi(pelajaranId);
        expect(hasilTerbaru, isNotNull);
        final muatanTerbaru =
            jsonDecode(hasilTerbaru!.muatanJson!) as Map<String, dynamic>;
        expect(muatanTerbaru['jawaban'], equals(jawabanRevisi));
      },
    );

    test(
      'Semua 6 tipe misi (termasuk refleksi) mencatat status selesai di tabel_hasil_misi',
      () async {
        final daftarMisi = [
          (
            'misi_ada_data',
            'pel_1_1',
            'ada_data',
            '{"min": 1, "objek": "transaksi"}',
          ),
          (
            'misi_aturan_data',
            'pel_1_3',
            'aturan_data',
            '{"aturan": "semua_kategori_berlabel"}',
          ),
          (
            'misi_lihat_hitungan',
            'pel_2_1',
            'lihat_hitungan',
            '{"objek": "ringkasan_tujuan_tabungan"}',
          ),
          (
            'misi_keputusan',
            'waspada_penipuan_5_1',
            'keputusan',
            '{"opsiDipilih": ["a", "c", "b"]}',
          ),
          (
            'misi_daftar_periksa',
            'waspada_penipuan_5_2',
            'daftar_periksa',
            '{"dicentang": ["l1", "l2", "l3"]}',
          ),
          (
            'misi_refleksi',
            'psikologi_uang_6_1',
            'refleksi',
            '{"jawaban": "Refleksi belanjaku"}',
          ),
        ];

        for (final (misiId, pelId, tipe, muatan) in daftarMisi) {
          await repo.simpanHasilMisi(
            misiId: misiId,
            pelajaranId: pelId,
            tipe: tipe,
            status: 'selesai',
            muatanJson: muatan,
          );
        }

        final seluruhHasil = await db.select(db.tabelHasilMisi).get();
        expect(seluruhHasil.length, equals(6));

        for (final (misiId, pelId, tipe, muatan) in daftarMisi) {
          final hasil = seluruhHasil.firstWhere((h) => h.misiId == misiId);
          expect(hasil.pelajaranId, equals(pelId));
          expect(hasil.tipe, equals(tipe));
          expect(hasil.status, equals('selesai'));
          expect(hasil.muatanJson, equals(muatan));
          expect(hasil.selesaiPada, isNotNull);
        }
      },
    );
  });
}
