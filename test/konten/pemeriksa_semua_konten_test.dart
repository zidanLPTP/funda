// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';

void main() {
  group('Butir C.2: Pemeriksa Seluruh Konten di aset/konten/', () {
    test('Validasi SEMUA berkas modul, pelajaran, kamus, bahasa, dan evaluator misi', () {
      final dirKonten = Directory('aset/konten');
      expect(dirKonten.existsSync(), isTrue, reason: 'Folder aset/konten wajib ada');

      // 1. Baca kamus.json
      final berkasKamus = File('aset/konten/kamus.json');
      expect(berkasKamus.existsSync(), isTrue, reason: 'berkas kamus.json wajib ada');

      final kontenKamusStr = berkasKamus.readAsStringSync();
      final petaKamus = PembacaKonten.uraiKamus(kontenKamusStr, namaBerkas: 'kamus.json');
      expect(petaKamus.isNotEmpty, isTrue);

      final daftarIstilahKamus = petaKamus.keys.toSet();
      final istilahTerpakai = <String>{};

      final daftarPeringatan = <String>[];
      final berkasPelajaranDitemukan = <File>[];
      final berkasModulDitemukan = <File>[];

      // Kumpulkan seluruh berkas JSON
      for (final entitas in dirKonten.listSync(recursive: true)) {
        if (entitas is File && entitas.path.endsWith('.json')) {
          final nama = entitas.uri.pathSegments.last;
          if (nama == 'kamus.json') continue;
          if (nama == 'modul.json') {
            berkasModulDitemukan.add(entitas);
          } else {
            berkasPelajaranDitemukan.add(entitas);
          }
        }
      }

      print('Ditemukan ${berkasModulDitemukan.length} berkas modul.json dan ${berkasPelajaranDitemukan.length} berkas pelajaran.');

      // 2. Validasi setiap modul.json
      for (final fileModul in berkasModulDitemukan) {
        final relPath = fileModul.path;
        final jsonStr = fileModul.readAsStringSync();
        final modul = PembacaKonten.uraiModul(jsonStr, namaBerkas: relPath);

        expect(modul.id.isNotEmpty, isTrue);
        expect(modul.judul.isNotEmpty, isTrue);
        if (modul.tersedia) {
          expect(modul.daftarPelajaran.isNotEmpty, isTrue);
        }

        // Cek bahasa pada judul dan deskripsi
        PembacaKonten.periksaBahasaTeks(modul.judul, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);
        PembacaKonten.periksaBahasaTeks(modul.deskripsiSingkat, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);

        // Cek soal kuis jika tersedia
        if (modul.kuis.jumlahSoal > 0) {
          expect(modul.kuis.bankSoal.isNotEmpty, isTrue);
          for (final soal in modul.kuis.bankSoal) {
            expect(soal.pilihan.length, greaterThanOrEqualTo(2));
            expect(soal.benar, inInclusiveRange(0, soal.pilihan.length - 1));
            PembacaKonten.periksaBahasaTeks(soal.tanya, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);
            PembacaKonten.periksaBahasaTeks(soal.penjelasan, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);
          }
        }
      }

      // 3. Validasi setiap berkas pelajaran
      for (final filePelajaran in berkasPelajaranDitemukan) {
        final relPath = filePelajaran.path;
        final jsonStr = filePelajaran.readAsStringSync();

        final pelajaran = PembacaKonten.uraiPelajaran(
          jsonStr,
          namaBerkas: relPath,
          daftarIstilahKamus: daftarIstilahKamus,
          daftarPeringatan: daftarPeringatan,
        );

        // Catat istilah yang terpakai
        for (final kartu in pelajaran.kartu) {
          final matches = RegExp(r'\{\{([^}]+)\}\}').allMatches(kartu.isi);
          for (final m in matches) {
            final ist = m.group(1)?.toLowerCase().trim();
            if (ist != null) {
              istilahTerpakai.add(ist);
            }
          }
        }

        // Cek bahasa pemantik & kartu
        PembacaKonten.periksaBahasaTeks(pelajaran.pemantik, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);
        for (final kartu in pelajaran.kartu) {
          PembacaKonten.periksaBahasaTeks(kartu.judul, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);
          PembacaKonten.periksaBahasaTeks(kartu.isi, namaBerkas: relPath, daftarPeringatan: daftarPeringatan);
        }

        // Cek evaluator misi tersedia!
        final tipeMisi = pelajaran.misi.tipe;
        final evaluatorAda = RegistriMisi.jenisMisiDidukung.contains(tipeMisi);
        expect(
          evaluatorAda,
          isTrue,
          reason: 'Berkas $relPath memiliki misi bertipe "$tipeMisi" tetapi evaluator belum ada di RegistriMisi!',
        );
      }

      // 4. Periksa istilah kamus yang tidak pernah dipakai
      final istilahTakTerpakai = daftarIstilahKamus.difference(istilahTerpakai);
      if (istilahTakTerpakai.isNotEmpty) {
        for (final ist in istilahTakTerpakai) {
          daftarPeringatan.add('Peringatan: Istilah kamus "$ist" tidak dipakai di berkas pelajaran mana pun.');
        }
      }

      // Cetak semua peringatan (kalimat > 25 kata & istilah kamus tak terpakai)
      print('=== HASIL PEMERIKSAAN KONTEN & PERINGATAN ===');
      for (final p in daftarPeringatan) {
        print(p);
      }
      print('Total berkas valid: ${berkasModulDitemukan.length} modul, ${berkasPelajaranDitemukan.length} pelajaran.');
      print('Total peringatan: ${daftarPeringatan.length}');
      print('=============================================');
    });

    test('Buktikan misi dengan tipe tanpa evaluator di RegistriMisi ditolak', () {
      const misiTanpaEvaluator = MisiKonten(
        tipe: 'tipe_ajaib_belum_ada',
        judul: 'Misi Belum Ada Evaluator',
        deskripsi: 'Deskripsi',
        perkiraanMenit: 2,
      );

      final hasil = RegistriMisi.evaluasi(
        misi: misiTanpaEvaluator,
        fotoData: FotoDataPengguna.kosong(),
      );

      // Verifikasi: didukung == false, selesai == false
      expect(hasil.didukung, isFalse);
      expect(hasil.selesai, isFalse);
      expect(hasil.statusTeks, contains('belum didukung'));
    });
  });
}
