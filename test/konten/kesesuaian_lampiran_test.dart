import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';

void main() {
  group('Uji Kesesuaian Lampiran Tahap 6-R', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};

    setUpAll(() {
      final materiFile = File('docs/materi/modul_1_anggaran_arus_kas.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_1_anggaran_arus_kas.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/pemula/anggaran_arus_kas/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 5; i++) {
        final id = 'anggaran_arus_kas_1_$i';
        final f = File('aset/konten/pemula/anggaran_arus_kas/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }
    });

    test('(a) Validasi Metadata, Gerbang, Misi, Durasi, Kartu, dan Soal sesuai Lampiran', () {
      // 1_1
      final p1 = pelajaranJson['anggaran_arus_kas_1_1']!;
      expect(p1['judul'], equals('Ke Mana Uangku Pergi?'));
      expect(p1['durasiMenit'], equals(4));
      expect(p1['gerbang'], isEmpty);
      expect(p1['misi']['tipe'], equals('ada_data'));
      expect(p1['misi']['objek'], equals('pengeluaran'));
      expect(p1['misi']['min'], equals(1));
      expect(p1['misi']['umpanBalik'], equals('catatan_pengeluaran_terbaru'));
      expect(p1['aturanPraktis'], isNull);

      // 1_2
      final p2 = pelajaranJson['anggaran_arus_kas_1_2']!;
      expect(p2['judul'], equals('Memetakan Arus Kas'));
      expect(p2['durasiMenit'], equals(5));
      expect(p2['gerbang'], hasLength(1));
      expect(p2['gerbang'][0]['tipe'], equals('ada_data'));
      expect(p2['gerbang'][0]['objek'], equals('dompet'));
      expect(p2['gerbang'][0]['min'], equals(1));
      expect(p2['misi']['tipe'], equals('ada_data'));
      expect(p2['misi']['objek'], equals('arus_kas'));
      expect(p2['misi']['min'], equals(1));
      expect(p2['misi']['umpanBalik'], equals('arus_kas_bulan_ini'));
      expect(p2['aturanPraktis'], isNull);

      // 1_3
      final p3 = pelajaranJson['anggaran_arus_kas_1_3']!;
      expect(p3['judul'], equals('Kebutuhan vs Keinginan'));
      expect(p3['durasiMenit'], equals(6));
      expect(p3['gerbang'], hasLength(1));
      expect(p3['gerbang'][0]['tipe'], equals('ada_data'));
      expect(p3['gerbang'][0]['objek'], equals('pengeluaran'));
      expect(p3['gerbang'][0]['min'], equals(3));
      expect(p3['misi']['tipe'], equals('aturan_data'));
      expect(p3['misi']['aturan'], equals('semua_kategori_berlabel'));
      expect(p3['misi']['umpanBalik'], equals('komposisi_sifat_bulan_ini'));
      expect(p3['aturanPraktis'], isNull);

      // 1_4
      final p4 = pelajaranJson['anggaran_arus_kas_1_4']!;
      expect(p4['judul'], equals('Anggaran Pertamamu'));
      expect(p4['durasiMenit'], equals(7));
      expect(p4['aturanPraktis'], isTrue);
      expect(p4['catatanReviewer'], contains('TODO-VERIFIKASI'));
      expect(p4['gerbang'], hasLength(2));
      expect(p4['gerbang'][0]['tipe'], equals('periode_data'));
      expect(p4['gerbang'][0]['objek'], equals('transaksi'));
      expect(p4['gerbang'][0]['minHari'], equals(7));
      expect(p4['gerbang'][1]['tipe'], equals('ada_data'));
      expect(p4['gerbang'][1]['objek'], equals('pemasukan'));
      expect(p4['gerbang'][1]['min'], equals(1));
      expect(p4['gerbang'][1]['pesan'], equals('Catat minimal satu pemasukan bulan ini.'));
      expect(p4['misi']['tipe'], equals('ada_data'));
      expect(p4['misi']['objek'], equals('anggaran'));
      expect(p4['misi']['min'], equals(3));
      expect(p4['misi']['umpanBalik'], equals('perbandingan_pola_anggaran'));

      // 1_5
      final p5 = pelajaranJson['anggaran_arus_kas_1_5']!;
      expect(p5['judul'], equals('Evaluasi Akhir Bulan'));
      expect(p5['durasiMenit'], equals(6));
      expect(p5['gerbang'], hasLength(2));
      expect(p5['gerbang'][0]['tipe'], equals('ada_data'));
      expect(p5['gerbang'][0]['objek'], equals('anggaran'));
      expect(p5['gerbang'][0]['min'], equals(1));
      expect(p5['gerbang'][1]['tipe'], equals('ada_data'));
      expect(p5['gerbang'][1]['objek'], equals('pengeluaran'));
      expect(p5['gerbang'][1]['min'], equals(1));
      expect(p5['gerbang'][1]['pesan'], equals('Catat minimal satu pengeluaran.'));
      expect(p5['misi']['tipe'], equals('lihat_hitungan'));
      expect(p5['misi']['umpanBalik'], equals('realisasi_anggaran_bulan_ini'));
      expect(p5['aturanPraktis'], isNull);

      // Setiap pelajaran: tepat 3 kartu, tepat 3 cekPaham, contohAngka valid, tindakLanjut
      for (final entry in pelajaranJson.entries) {
        final p = entry.value;
        final id = entry.key;
        expect((p['kartu'] as List).length, equals(3), reason: '$id harus punya 3 kartu');
        expect((p['cekPaham'] as List).length, equals(3), reason: '$id harus punya 3 cekPaham');
        expect(p['contohAngka'], isA<Map<String, dynamic>>(), reason: '$id contohAngka harus objek');
        expect(p['tindakLanjut'], isA<String>(), reason: '$id harus punya tindakLanjut');
      }

      // Kuis Modul: bankSoal 10 (2 per pelajaran), jumlahSoal 5
      expect(modulJson['kuis']['jumlahSoal'], equals(5));
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      expect(bankSoal.length, equals(10));

      final hitungPerPelajaran = <String, int>{};
      for (final soal in bankSoal) {
        final pelId = soal['pelajaranId'] as String;
        expect(pelajaranJson.containsKey(pelId), isTrue, reason: 'pelajaranId $pelId tidak valid');
        hitungPerPelajaran[pelId] = (hitungPerPelajaran[pelId] ?? 0) + 1;
      }
      for (var i = 1; i <= 5; i++) {
        final id = 'anggaran_arus_kas_1_$i';
        expect(hitungPerPelajaran[id], equals(2), reason: 'Pelajaran $id harus punya tepat 2 soal kuis');
      }
    });

    test('(b) Kesesuaian KATA PER KATA seluruh teks JSON terhadap Lampiran Markdown', () {
      const pesanDikecualikan = {
        'Catat minimal satu pemasukan bulan ini.',
        'Catat minimal satu pengeluaran.',
      };

      void cekStringMuncul(String teks, String konteks) {
        final normal = teks.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normal.isEmpty || pesanDikecualikan.contains(normal)) return;

        // Bersihkan token istilah {{...}} untuk pencocokan teks di dokumen lampiran jika lampiran tidak memakai tanda kurung ganda
        final tanpaToken = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) || isiMateriLampiran.contains(tanpaToken);
        expect(
          cocok,
          isTrue,
          reason: 'Teks pada $konteks TIDAK DITEMUKAN di lampiran materi: "$normal"',
        );
      }

      // Periksa kelima berkas pelajaran
      for (final entry in pelajaranJson.entries) {
        final id = entry.key;
        final p = entry.value;

        cekStringMuncul(p['judul'] as String, '$id.judul');
        cekStringMuncul(p['pemantik'] as String, '$id.pemantik');
        cekStringMuncul(p['tindakLanjut'] as String, '$id.tindakLanjut');

        // Gerbang
        for (final g in (p['gerbang'] as List)) {
          if (g['pesan'] != null) {
            cekStringMuncul(g['pesan'] as String, '$id.gerbang.pesan');
          }
        }

        // Kartu
        for (var i = 0; i < (p['kartu'] as List).length; i++) {
          final k = p['kartu'][i] as Map<String, dynamic>;
          cekStringMuncul(k['judul'] as String, '$id.kartu[$i].judul');
          cekStringMuncul(k['isi'] as String, '$id.kartu[$i].isi');
        }

        // Contoh Angka
        final ca = p['contohAngka'] as Map<String, dynamic>;
        cekStringMuncul(ca['judul'] as String, '$id.contohAngka.judul');
        cekStringMuncul(ca['kesimpulan'] as String, '$id.contohAngka.kesimpulan');
        for (var i = 0; i < (ca['baris'] as List).length; i++) {
          final b = ca['baris'][i] as Map<String, dynamic>;
          cekStringMuncul(b['label'] as String, '$id.contohAngka.baris[$i].label');
        }

        // Cek Paham
        for (var i = 0; i < (p['cekPaham'] as List).length; i++) {
          final cp = p['cekPaham'][i] as Map<String, dynamic>;
          cekStringMuncul(cp['tanya'] as String, '$id.cekPaham[$i].tanya');
          cekStringMuncul(cp['penjelasan'] as String, '$id.cekPaham[$i].penjelasan');
          for (final pil in (cp['pilihan'] as List)) {
            cekStringMuncul(pil as String, '$id.cekPaham[$i].pilihan');
          }
        }

        // Misi
        final m = p['misi'] as Map<String, dynamic>;
        cekStringMuncul(m['judul'] as String, '$id.misi.judul');
        cekStringMuncul(m['instruksi'] as String, '$id.misi.instruksi');
      }

      // Periksa 10 Soal Kuis
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      for (var i = 0; i < bankSoal.length; i++) {
        final s = bankSoal[i] as Map<String, dynamic>;
        cekStringMuncul(s['tanya'] as String, 'kuis.bankSoal[$i].tanya');
        cekStringMuncul(s['penjelasan'] as String, 'kuis.bankSoal[$i].penjelasan');
        for (final pil in (s['pilihan'] as List)) {
          cekStringMuncul(pil as String, 'kuis.bankSoal[$i].pilihan');
        }
      }
    });
  });

  group('Uji Kesesuaian Lampiran Modul 2 (Tabungan)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};

    setUpAll(() {
      final materiFile = File('docs/materi/modul_2_tabungan.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_2_tabungan.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/pemula/tabungan/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'tabungan_2_$i';
        final f = File('aset/konten/pemula/tabungan/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }
    });

    test('(a) Validasi Metadata, Gerbang, Misi, Durasi, Kartu, dan Soal Modul 2 sesuai Lampiran', () {
      // Gerbang Modul
      expect(modulJson['gerbang'], hasLength(2));
      expect(modulJson['gerbang'][0]['tipe'], equals('modul_selesai'));
      expect(modulJson['gerbang'][0]['modulId'], equals('anggaran_arus_kas'));
      expect(modulJson['gerbang'][1]['tipe'], equals('ada_data'));
      expect(modulJson['gerbang'][1]['objek'], equals('anggaran'));
      expect(modulJson['gerbang'][1]['min'], equals(1));

      // 2_1
      final p1 = pelajaranJson['tabungan_2_1']!;
      expect(p1['judul'], equals('Menabung Itu Soal Tujuan'));
      expect(p1['durasiMenit'], equals(5));
      expect(p1['gerbang'], isEmpty);
      expect(p1['misi']['tipe'], equals('ada_data'));
      expect(p1['misi']['objek'], equals('tujuan_tabungan'));
      expect(p1['misi']['min'], equals(1));
      expect(p1['misi']['umpanBalik'], equals('ringkasan_tujuan_tabungan'));

      // 2_2
      final p2 = pelajaranJson['tabungan_2_2']!;
      expect(p2['judul'], equals('Bayar Diri Sendiri Dulu'));
      expect(p2['durasiMenit'], equals(5));
      expect(p2['gerbang'], hasLength(1));
      expect(p2['gerbang'][0]['tipe'], equals('ada_data'));
      expect(p2['gerbang'][0]['objek'], equals('tujuan_tabungan'));
      expect(p2['gerbang'][0]['min'], equals(1));
      expect(p2['gerbang'][0]['pesan'], equals('Buat satu tujuan tabungan dulu supaya ada tempat untuk menyisihkan uangmu.'));
      expect(p2['misi']['tipe'], equals('ada_data'));
      expect(p2['misi']['objek'], equals('isi_tujuan_tabungan'));
      expect(p2['misi']['min'], equals(1));
      expect(p2['misi']['umpanBalik'], equals('ringkasan_tujuan_tabungan'));

      // 2_3
      final p3 = pelajaranJson['tabungan_2_3']!;
      expect(p3['judul'], equals('Menghitung Kecepatan Menabung'));
      expect(p3['durasiMenit'], equals(6));
      expect(p3['gerbang'], hasLength(1));
      expect(p3['gerbang'][0]['tipe'], equals('ada_data'));
      expect(p3['gerbang'][0]['objek'], equals('isi_tujuan_tabungan'));
      expect(p3['gerbang'][0]['min'], equals(1));
      expect(p3['gerbang'][0]['pesan'], equals('Isi tujuan tabunganmu minimal sekali dulu, supaya hitungannya memakai data nyatamu.'));
      expect(p3['misi']['tipe'], equals('lihat_hitungan'));
      expect(p3['misi']['umpanBalik'], equals('estimasi_tabungan'));

      // Kartu, CekPaham, ContohAngka
      for (final entry in pelajaranJson.entries) {
        final p = entry.value;
        final id = entry.key;
        expect((p['kartu'] as List).length, equals(3), reason: '$id harus punya 3 kartu');
        expect((p['cekPaham'] as List).length, equals(3), reason: '$id harus punya 3 cekPaham');
        expect(p['contohAngka'], isA<Map<String, dynamic>>(), reason: '$id contohAngka harus objek');
        expect(p['tindakLanjut'], isA<String>(), reason: '$id harus punya tindakLanjut');
      }

      // Kuis Modul 2
      expect(modulJson['kuis']['jumlahSoal'], equals(5));
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      expect(bankSoal.length, equals(10));
      for (final soal in bankSoal) {
        final pelId = soal['pelajaranId'] as String;
        expect(pelajaranJson.containsKey(pelId), isTrue, reason: 'pelajaranId $pelId tidak valid');
      }
    });

    test('(b) Kesesuaian KATA PER KATA seluruh teks JSON Modul 2 terhadap Lampiran Markdown', () {
      void cekStringMuncul(String teks, String konteks) {
        final normal = teks.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normal.isEmpty) return;

        final materiBersih = isiMateriLampiran.replaceAll('{{', '').replaceAll('}}', '');
        final teksBersih = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) ||
            isiMateriLampiran.contains(teksBersih) ||
            materiBersih.contains(teksBersih);
        expect(
          cocok,
          isTrue,
          reason: 'Teks pada $konteks TIDAK DITEMUKAN di lampiran materi: "$normal"',
        );
      }

      for (final entry in pelajaranJson.entries) {
        final id = entry.key;
        final p = entry.value;

        cekStringMuncul(p['judul'] as String, '$id.judul');
        cekStringMuncul(p['pemantik'] as String, '$id.pemantik');
        cekStringMuncul(p['tindakLanjut'] as String, '$id.tindakLanjut');

        for (final g in (p['gerbang'] as List)) {
          if (g['pesan'] != null) {
            cekStringMuncul(g['pesan'] as String, '$id.gerbang.pesan');
          }
        }

        for (var i = 0; i < (p['kartu'] as List).length; i++) {
          final k = p['kartu'][i] as Map<String, dynamic>;
          cekStringMuncul(k['judul'] as String, '$id.kartu[$i].judul');
          cekStringMuncul(k['isi'] as String, '$id.kartu[$i].isi');
        }

        final ca = p['contohAngka'] as Map<String, dynamic>;
        cekStringMuncul(ca['judul'] as String, '$id.contohAngka.judul');
        cekStringMuncul(ca['kesimpulan'] as String, '$id.contohAngka.kesimpulan');
        for (var i = 0; i < (ca['baris'] as List).length; i++) {
          final b = ca['baris'][i] as Map<String, dynamic>;
          cekStringMuncul(b['label'] as String, '$id.contohAngka.baris[$i].label');
        }

        for (var i = 0; i < (p['cekPaham'] as List).length; i++) {
          final cp = p['cekPaham'][i] as Map<String, dynamic>;
          cekStringMuncul(cp['tanya'] as String, '$id.cekPaham[$i].tanya');
          cekStringMuncul(cp['penjelasan'] as String, '$id.cekPaham[$i].penjelasan');
          for (final pil in (cp['pilihan'] as List)) {
            cekStringMuncul(pil as String, '$id.cekPaham[$i].pilihan');
          }
        }

        final m = p['misi'] as Map<String, dynamic>;
        cekStringMuncul(m['judul'] as String, '$id.misi.judul');
        cekStringMuncul(m['instruksi'] as String, '$id.misi.instruksi');
      }

      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      for (var i = 0; i < bankSoal.length; i++) {
        final s = bankSoal[i] as Map<String, dynamic>;
        cekStringMuncul(s['tanya'] as String, 'kuis.bankSoal[$i].tanya');
        cekStringMuncul(s['penjelasan'] as String, 'kuis.bankSoal[$i].penjelasan');
        for (final pil in (s['pilihan'] as List)) {
          cekStringMuncul(pil as String, 'kuis.bankSoal[$i].pilihan');
        }
      }
    });
  });

  group('Uji Kesesuaian Lampiran Modul 3 (Dana Darurat)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};

    setUpAll(() {
      final materiFile = File('docs/materi/modul_3_dana_darurat.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_3_dana_darurat.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/pemula/dana_darurat/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'dana_darurat_3_$i';
        final f = File('aset/konten/pemula/dana_darurat/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }
    });

    test('(a) Validasi Metadata, Gerbang, Misi, Durasi, Kartu, dan Soal Modul 3 sesuai Lampiran', () {
      // Gerbang Modul
      expect(modulJson['gerbang'], hasLength(2));
      expect(modulJson['gerbang'][0]['tipe'], equals('modul_selesai'));
      expect(modulJson['gerbang'][0]['modulId'], equals('tabungan'));
      expect(modulJson['gerbang'][1]['tipe'], equals('ada_data'));
      expect(modulJson['gerbang'][1]['objek'], equals('pengeluaran_kebutuhan'));
      expect(modulJson['gerbang'][1]['min'], equals(3));

      // 3_1
      final p1 = pelajaranJson['dana_darurat_3_1']!;
      expect(p1['judul'], equals('Apa Itu Dana Darurat?'));
      expect(p1['durasiMenit'], equals(5));
      expect(p1['gerbang'], isEmpty);
      expect(p1['misi']['tipe'], equals('lihat_hitungan'));
      expect(p1['misi']['umpanBalik'], equals('pengeluaran_wajib_bulanan'));

      // 3_2
      final p2 = pelajaranJson['dana_darurat_3_2']!;
      expect(p2['judul'], equals('Berapa yang Cukup untukmu?'));
      expect(p2['durasiMenit'], equals(6));
      expect(p2['aturanPraktis'], isTrue);
      expect(p2['catatanReviewer'], contains('TODO-VERIFIKASI'));
      expect(p2['gerbang'], isEmpty);
      expect(p2['misi']['tipe'], equals('ada_data'));
      expect(p2['misi']['objek'], equals('tujuan_dana_darurat'));
      expect(p2['misi']['min'], equals(1));
      expect(p2['misi']['umpanBalik'], equals('target_dana_darurat'));

      // 3_3
      final p3 = pelajaranJson['dana_darurat_3_3']!;
      expect(p3['judul'], equals('Mengisi Dana Darurat Sedikit demi Sedikit'));
      expect(p3['durasiMenit'], equals(6));
      expect(p3['gerbang'], hasLength(1));
      expect(p3['gerbang'][0]['tipe'], equals('ada_data'));
      expect(p3['gerbang'][0]['objek'], equals('tujuan_dana_darurat'));
      expect(p3['gerbang'][0]['min'], equals(1));
      expect(p3['gerbang'][0]['pesan'], equals('Buat tujuan Dana Darurat dulu supaya ada tempat untuk mengisinya.'));
      expect(p3['misi']['tipe'], equals('ada_data'));
      expect(p3['misi']['objek'], equals('isi_dana_darurat'));
      expect(p3['misi']['min'], equals(1));
      expect(p3['misi']['umpanBalik'], equals('progres_dana_darurat'));

      // Kartu, CekPaham, ContohAngka
      for (final entry in pelajaranJson.entries) {
        final p = entry.value;
        final id = entry.key;
        expect((p['kartu'] as List).length, equals(3), reason: '$id harus punya 3 kartu');
        expect((p['cekPaham'] as List).length, equals(3), reason: '$id harus punya 3 cekPaham');
        expect(p['contohAngka'], isA<Map<String, dynamic>>(), reason: '$id contohAngka harus objek');
        expect(p['tindakLanjut'], isA<String>(), reason: '$id harus punya tindakLanjut');
      }

      // Kuis Modul 3
      expect(modulJson['kuis']['jumlahSoal'], equals(5));
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      expect(bankSoal.length, equals(10));
      for (final soal in bankSoal) {
        final pelId = soal['pelajaranId'] as String;
        expect(pelajaranJson.containsKey(pelId), isTrue, reason: 'pelajaranId $pelId tidak valid');
      }
      expect(bankSoal[4]['aturanPraktis'], isTrue);
      expect(bankSoal[4]['catatanReviewer'], contains('TODO-VERIFIKASI'));
      expect(bankSoal[5]['aturanPraktis'], isTrue);
      expect(bankSoal[5]['catatanReviewer'], contains('TODO-VERIFIKASI'));
    });

    test('(b) Kesesuaian KATA PER KATA seluruh teks JSON Modul 3 terhadap Lampiran Markdown', () {
      void cekStringMuncul(String teks, String konteks) {
        final normal = teks.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normal.isEmpty) return;

        final materiBersih = isiMateriLampiran.replaceAll('{{', '').replaceAll('}}', '');
        final teksBersih = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) ||
            isiMateriLampiran.contains(teksBersih) ||
            materiBersih.contains(teksBersih);
        expect(
          cocok,
          isTrue,
          reason: 'Teks pada $konteks TIDAK DITEMUKAN di lampiran materi: "$normal"',
        );
      }

      for (final entry in pelajaranJson.entries) {
        final id = entry.key;
        final p = entry.value;

        cekStringMuncul(p['judul'] as String, '$id.judul');
        cekStringMuncul(p['pemantik'] as String, '$id.pemantik');
        cekStringMuncul(p['tindakLanjut'] as String, '$id.tindakLanjut');

        for (final g in (p['gerbang'] as List)) {
          if (g['pesan'] != null) {
            cekStringMuncul(g['pesan'] as String, '$id.gerbang.pesan');
          }
        }

        for (var i = 0; i < (p['kartu'] as List).length; i++) {
          final k = p['kartu'][i] as Map<String, dynamic>;
          cekStringMuncul(k['judul'] as String, '$id.kartu[$i].judul');
          cekStringMuncul(k['isi'] as String, '$id.kartu[$i].isi');
        }

        final ca = p['contohAngka'] as Map<String, dynamic>;
        cekStringMuncul(ca['judul'] as String, '$id.contohAngka.judul');
        cekStringMuncul(ca['kesimpulan'] as String, '$id.contohAngka.kesimpulan');
        for (var i = 0; i < (ca['baris'] as List).length; i++) {
          final b = ca['baris'][i] as Map<String, dynamic>;
          cekStringMuncul(b['label'] as String, '$id.contohAngka.baris[$i].label');
        }

        for (var i = 0; i < (p['cekPaham'] as List).length; i++) {
          final cp = p['cekPaham'][i] as Map<String, dynamic>;
          cekStringMuncul(cp['tanya'] as String, '$id.cekPaham[$i].tanya');
          cekStringMuncul(cp['penjelasan'] as String, '$id.cekPaham[$i].penjelasan');
          for (final pil in (cp['pilihan'] as List)) {
            cekStringMuncul(pil as String, '$id.cekPaham[$i].pilihan');
          }
        }

        final m = p['misi'] as Map<String, dynamic>;
        cekStringMuncul(m['judul'] as String, '$id.misi.judul');
        cekStringMuncul(m['instruksi'] as String, '$id.misi.instruksi');
      }

      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      for (var i = 0; i < bankSoal.length; i++) {
        final s = bankSoal[i] as Map<String, dynamic>;
        cekStringMuncul(s['tanya'] as String, 'kuis.bankSoal[$i].tanya');
        cekStringMuncul(s['penjelasan'] as String, 'kuis.bankSoal[$i].penjelasan');
        for (final pil in (s['pilihan'] as List)) {
          cekStringMuncul(pil as String, 'kuis.bankSoal[$i].pilihan');
        }
      }
    });

    test('(c) Kesesuaian KATA PER KATA 6 Entri Kamus Baru Modul 2 & 3', () {
      final kamusFile = File('aset/konten/kamus.json');
      expect(kamusFile.existsSync(), isTrue);
      final daftarKamus = (jsonDecode(kamusFile.readAsStringSync()) as List).cast<Map<String, dynamic>>();

      final kamusMateriFile = File('docs/materi/kamus_modul_2_3.md');
      expect(kamusMateriFile.existsSync(), isTrue);
      final isiMateriKamus = kamusMateriFile.readAsStringSync();

      final entriWajib = <String, ({String arti, String contohRupiah})>{
        'tenggat': (
          arti: 'Batas waktu yang kamu tetapkan untuk mencapai sebuah tujuan.',
          contohRupiah: 'Tenggat 12 bulan untuk target Rp6.000.000.',
        ),
        'setoran': (
          arti: 'Uang yang kamu sisihkan ke sebuah tujuan pada satu kali pengisian atau tiap bulan.',
          contohRupiah: 'Setoran Rp250.000 per bulan.',
        ),
        'kantong': (
          arti: 'Penanda bagian saldo sebuah dompet untuk tujuan tertentu. Uangnya tidak berpindah.',
          contohRupiah: 'Kantong Laptop Skripsi berisi Rp500.000 dari dompet bank.',
        ),
        'saldo bebas': (
          arti: 'Saldo dompet yang belum ditandai untuk tujuan apa pun.',
          contohRupiah: 'Saldo dompet Rp1.000.000 dengan kantong Rp200.000 berarti saldo bebas Rp800.000.',
        ),
        'pengeluaran wajib': (
          arti: 'Pengeluaran yang tetap harus dibayar saat keadaan sulit, yaitu kebutuhan pokok dan cicilan.',
          contohRupiah: 'Kos Rp900.000, makan Rp600.000, dan cicilan Rp200.000.',
        ),
        'tonggak': (
          arti: 'Target kecil di tengah jalan menuju target besar.',
          contohRupiah: 'Tonggak pertama dana darurat: satu bulan pengeluaran wajib, Rp1.900.000.',
        ),
      };

      for (final e in entriWajib.entries) {
        final istilah = e.key;
        final target = e.value;

        // Cek di aset/konten/kamus.json
        final entriJson = daftarKamus.firstWhere(
          (k) => k['istilah'] == istilah,
          orElse: () => throw Exception('Istilah "$istilah" tidak ditemukan di kamus.json'),
        );
        expect(entriJson['arti'], equals(target.arti), reason: 'Arti "$istilah" di kamus.json tidak cocok kata per kata');
        expect(entriJson['contohRupiah'], equals(target.contohRupiah), reason: 'Contoh Rupiah "$istilah" di kamus.json tidak cocok kata per kata');

        // Cek di docs/materi/kamus_modul_2_3.md
        expect(isiMateriKamus.contains(istilah), isTrue, reason: 'Istilah "$istilah" tidak ditemukan di docs/materi/kamus_modul_2_3.md');
        expect(isiMateriKamus.contains(target.arti), isTrue, reason: 'Arti "$istilah" tidak ditemukan di docs/materi/kamus_modul_2_3.md');
        expect(isiMateriKamus.contains(target.contohRupiah), isTrue, reason: 'Contoh Rupiah "$istilah" tidak ditemukan di docs/materi/kamus_modul_2_3.md');
      }
    });
  });

  group('Uji Kesesuaian Lampiran Modul 4 (Utang & Cicilan)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    late Map<String, Map<String, dynamic>> pelajaranJson;

    setUpAll(() {
      final fileLampiran = File('docs/materi/modul_4_utang_cicilan.md');
      expect(fileLampiran.existsSync(), isTrue, reason: 'Berkas lampiran docs/materi/modul_4_utang_cicilan.md harus ada');
      isiMateriLampiran = fileLampiran.readAsStringSync();

      final fileModul = File('aset/konten/pemula/utang_cicilan/modul.json');
      expect(fileModul.existsSync(), isTrue, reason: 'Berkas modul.json utang_cicilan harus ada');
      modulJson = jsonDecode(fileModul.readAsStringSync()) as Map<String, dynamic>;

      pelajaranJson = {};
      final daftarPelajaran = (modulJson['daftarPelajaran'] as List).cast<String>();
      for (final id in daftarPelajaran) {
        final f = File('aset/konten/pemula/utang_cicilan/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas pelajaran $id.json harus ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }
    });

    test('(a) Validasi Metadata, Gerbang, Misi, Durasi, Kartu, dan Soal Modul 4 sesuai Lampiran', () {
      expect(modulJson['id'], equals('utang_cicilan'));
      expect(modulJson['judul'], equals('Utang & Cicilan'));
      expect(modulJson['tingkat'], equals('pemula'));
      expect(modulJson['urutan'], equals(4));
      expect(modulJson['tersedia'], isTrue);

      // Verifikasi gerbang modul & pesan persis lampiran
      final gerbangModul = modulJson['gerbang'] as List;
      expect(gerbangModul.length, equals(2));
      expect(gerbangModul[0]['tipe'], equals('modul_selesai'));
      expect(gerbangModul[0]['modulId'], equals('dana_darurat'));
      expect(gerbangModul[0]['pesan'], equals('Selesaikan Modul 3 dulu.'));
      expect(gerbangModul[1]['tipe'], equals('ada_data'));
      expect(gerbangModul[1]['objek'], equals('utang'));
      expect(gerbangModul[1]['min'], equals(1));
      expect(gerbangModul[1]['atauPernyataan'], equals('tidak_punya_utang'));
      expect(gerbangModul[1]['pesan'], equals('Catat utang atau cicilanmu di menu Utang. Kalau kamu memang tidak punya utang, pilih Aku tidak punya ini.'));

      // Verifikasi pesan modul utuh dari lampiran dan dua pesan turunan
      final pesanUtuh = '${gerbangModul[0]['pesan']} Lalu ${gerbangModul[1]['pesan'][0].toLowerCase()}${gerbangModul[1]['pesan'].substring(1)}';
      expect(pesanUtuh, equals('Selesaikan Modul 3 dulu. Lalu catat utang atau cicilanmu di menu Utang. Kalau kamu memang tidak punya utang, pilih Aku tidak punya ini.'));

      // Verifikasi judul pelajaran Modul 4 persis lampiran
      expect(pelajaranJson['utang_cicilan_4_1']!['judul'], equals('Utang yang Membantu dan yang Menjerat'));
      expect(pelajaranJson['utang_cicilan_4_2']!['judul'], equals('Bunga dan Biaya yang Sebenarnya'));
      expect(pelajaranJson['utang_cicilan_4_3']!['judul'], equals('Rasio Cicilan terhadap Pemasukan'));
      expect(pelajaranJson['utang_cicilan_4_4']!['judul'], equals('Strategi Melunasi: Bola Salju dan Longsor'));

      // Ekstrak durasiMenit per pelajaran dari lampiran markdown secara dinamis
      for (final entry in pelajaranJson.entries) {
        final id = entry.key;
        final regDurasi = RegExp('PELAJARAN $id[\\s\\S]*?durasiMenit:\\s*(\\d+)');
        final matchDurasi = regDurasi.firstMatch(isiMateriLampiran);
        expect(matchDurasi, isNotNull, reason: 'durasiMenit untuk $id harus ada di lampiran');
        final durasiDariLampiran = int.parse(matchDurasi!.group(1)!);
        expect(entry.value['durasiMenit'], equals(durasiDariLampiran), reason: 'durasiMenit $id harus cocok dengan lampiran');
      }

      // Verifikasi spesifik durasi: 4_1=5, 4_2=6, 4_3=5, 4_4=6
      expect(pelajaranJson['utang_cicilan_4_1']!['durasiMenit'], equals(5));
      expect(pelajaranJson['utang_cicilan_4_2']!['durasiMenit'], equals(6));
      expect(pelajaranJson['utang_cicilan_4_3']!['durasiMenit'], equals(5));
      expect(pelajaranJson['utang_cicilan_4_4']!['durasiMenit'], equals(6));

      // Verifikasi gerbang pelajaran 4_1 sampai 4_4: tidak ada
      for (final p in pelajaranJson.values) {
        expect(p['gerbang'], isEmpty, reason: 'Gerbang pelajaran harus kosong (berlaku gerbang modul dan urutan)');
        expect(p['misi']['tipe'], equals('lihat_hitungan'));
      }
      expect(pelajaranJson['utang_cicilan_4_1']!['misi']['umpanBalik'], equals('ringkasan_utang'));
      expect(pelajaranJson['utang_cicilan_4_2']!['misi']['umpanBalik'], equals('biaya_pinjaman_tercatat'));
      expect(pelajaranJson['utang_cicilan_4_3']!['misi']['umpanBalik'], equals('rasio_cicilan_bulan_ini'));
      expect(pelajaranJson['utang_cicilan_4_4']!['misi']['umpanBalik'], equals('urutan_pelunasan'));

      // Verifikasi catatanReviewer dan aturanPraktis persis lampiran
      for (final id in ['utang_cicilan_4_2', 'utang_cicilan_4_3', 'utang_cicilan_4_4']) {
        final regCatatan = RegExp('PELAJARAN $id[\\s\\S]*?catatanReviewer:\\s*([\\s\\S]*?)(?=\\n\\s*gerbang pelajaran:|\\n\\s*aturanPraktis:|\\n\\s*pemantik:)');
        final matchCatatan = regCatatan.firstMatch(isiMateriLampiran);
        expect(matchCatatan, isNotNull, reason: 'catatanReviewer untuk $id harus ada di lampiran');
        final catatanLampiran = matchCatatan!.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();
        final catatanJson = (pelajaranJson[id]!['catatanReviewer'] as String).replaceAll(RegExp(r'\s+'), ' ').trim();
        expect(catatanJson, equals(catatanLampiran), reason: 'catatanReviewer $id harus persis teks lampiran');
      }
      expect(pelajaranJson['utang_cicilan_4_3']!['aturanPraktis'], isTrue);

      // Kartu, CekPaham, ContohAngka
      for (final entry in pelajaranJson.entries) {
        final p = entry.value;
        final id = entry.key;
        expect((p['kartu'] as List).length, equals(3), reason: '$id harus punya 3 kartu');
        expect((p['cekPaham'] as List).length, equals(3), reason: '$id harus punya 3 cekPaham');
        expect(p['contohAngka'], isA<Map<String, dynamic>>(), reason: '$id contohAngka harus objek');
        expect(p['tindakLanjut'], isA<String>(), reason: '$id harus punya tindakLanjut');
      }

      // Kuis Modul 4: ambang global 70% dan sebaran soal dari lampiran
      expect(modulJson['kuis']['jumlahSoal'], equals(5));
      expect(modulJson['kuis']['ambang'], isNull, reason: 'Ambang khusus modul harus null (menggunakan konstanta global ambangLulusKuis)');
      expect(ambangLulusKuis, equals(70), reason: 'Konstanta global ambangLulusKuis harus bernilai 70');

      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      expect(bankSoal.length, equals(10));

      final regSoalLampiran = RegExp(r'(\d+)\.\s*\[(utang_cicilan_4_\d)\]\s*tanya:\s*(.+?)(?=\r?\n\s*pilihan:)');
      final matchesSoal = regSoalLampiran.allMatches(isiMateriLampiran).toList();
      expect(matchesSoal.length, equals(10), reason: 'Bank soal di lampiran harus 10 butir');

      final sebaranPelajaranIdLampiran = <String, int>{};
      final sebaranPelajaranIdJson = <String, int>{};

      for (var i = 0; i < matchesSoal.length; i++) {
        final pelIdLampiran = matchesSoal[i].group(2)!;
        final pelIdJson = bankSoal[i]['pelajaranId'] as String;
        expect(pelIdJson, equals(pelIdLampiran), reason: 'pelajaranId soal ${i + 1} harus persis lampiran');
        sebaranPelajaranIdLampiran[pelIdLampiran] = (sebaranPelajaranIdLampiran[pelIdLampiran] ?? 0) + 1;
        sebaranPelajaranIdJson[pelIdJson] = (sebaranPelajaranIdJson[pelIdJson] ?? 0) + 1;
      }

      expect(sebaranPelajaranIdJson, equals(sebaranPelajaranIdLampiran));
      expect(sebaranPelajaranIdJson['utang_cicilan_4_1'], equals(3));
      expect(sebaranPelajaranIdJson['utang_cicilan_4_2'], equals(3));
      expect(sebaranPelajaranIdJson['utang_cicilan_4_3'], equals(2));
      expect(sebaranPelajaranIdJson['utang_cicilan_4_4'], equals(2));
    });

    test('(b) Kesesuaian KATA PER KATA seluruh teks JSON Modul 4 terhadap Lampiran Markdown', () {
      void cekStringMuncul(String teks, String konteks) {
        final normal = teks.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normal.isEmpty) return;

        final materiBersih = isiMateriLampiran.replaceAll('{{', '').replaceAll('}}', '');
        final teksBersih = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) ||
            isiMateriLampiran.contains(teksBersih) ||
            materiBersih.contains(teksBersih);
        expect(
          cocok,
          isTrue,
          reason: 'Teks pada $konteks TIDAK DITEMUKAN di lampiran materi: "$normal"',
        );
      }

      for (final entry in pelajaranJson.entries) {
        final id = entry.key;
        final p = entry.value;

        cekStringMuncul(p['judul'] as String, '$id.judul');
        cekStringMuncul(p['pemantik'] as String, '$id.pemantik');
        cekStringMuncul(p['tindakLanjut'] as String, '$id.tindakLanjut');

        for (final k in (p['kartu'] as List)) {
          cekStringMuncul(k['judul'] as String, '$id.kartu.judul');
          cekStringMuncul(k['isi'] as String, '$id.kartu.isi');
        }

        final ca = p['contohAngka'] as Map<String, dynamic>;
        cekStringMuncul(ca['judul'] as String, '$id.contohAngka.judul');
        cekStringMuncul(ca['kesimpulan'] as String, '$id.contohAngka.kesimpulan');
        for (final b in (ca['baris'] as List)) {
          cekStringMuncul(b['label'] as String, '$id.contohAngka.baris.label');
        }

        final cpList = p['cekPaham'] as List;
        for (var i = 0; i < cpList.length; i++) {
          final cp = cpList[i] as Map<String, dynamic>;
          cekStringMuncul(cp['tanya'] as String, '$id.cekPaham[$i].tanya');
          cekStringMuncul(cp['penjelasan'] as String, '$id.cekPaham[$i].penjelasan');
          for (final pil in (cp['pilihan'] as List)) {
            cekStringMuncul(pil as String, '$id.cekPaham[$i].pilihan');
          }
        }

        final m = p['misi'] as Map<String, dynamic>;
        cekStringMuncul(m['judul'] as String, '$id.misi.judul');
        cekStringMuncul(m['instruksi'] as String, '$id.misi.instruksi');
      }

      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      for (var i = 0; i < bankSoal.length; i++) {
        final s = bankSoal[i] as Map<String, dynamic>;
        cekStringMuncul(s['tanya'] as String, 'kuis.bankSoal[$i].tanya');
        cekStringMuncul(s['penjelasan'] as String, 'kuis.bankSoal[$i].penjelasan');
        for (final pil in (s['pilihan'] as List)) {
          cekStringMuncul(pil as String, 'kuis.bankSoal[$i].pilihan');
        }
      }
    });

    test('(c) Kesesuaian KATA PER KATA 6 Entri Kamus Baru Modul 4', () {
      final kamusFile = File('aset/konten/kamus.json');
      expect(kamusFile.existsSync(), isTrue);
      final daftarKamus = (jsonDecode(kamusFile.readAsStringSync()) as List).cast<Map<String, dynamic>>();

      final kamusMateriFile = File('docs/materi/kamus_modul_4.md');
      expect(kamusMateriFile.existsSync(), isTrue);
      final isiMateriKamus = kamusMateriFile.readAsStringSync();

      final entriWajib = <String, ({String arti, String contohRupiah})>{
        'pokok': (
          arti: 'Jumlah uang yang kamu pinjam, belum termasuk bunga dan biaya lain.',
          contohRupiah: 'Pinjam Rp12.000.000, maka pokoknya Rp12.000.000.',
        ),
        'bunga flat': (
          arti: 'Bunga yang dihitung dari pokok awal terus selama tenor, walau sisa pokok sudah menurun.',
          contohRupiah: 'Pokok Rp12.000.000 dengan bunga flat 12 persen per tahun selama 1 tahun berarti bunga Rp1.440.000.',
        ),
        'bunga efektif': (
          arti: 'Bunga yang dihitung dari sisa pokok yang terus menurun.',
          contohRupiah: 'Sisa pokok Rp10.000.000 dengan bunga efektif 1 persen per bulan berarti bunga bulan itu Rp100.000.',
        ),
        'paylater': (
          arti: 'Layanan beli sekarang bayar nanti, dengan tagihan yang muncul kemudian dan bisa disertai bunga atau denda.',
          contohRupiah: 'Belanja Rp500.000 hari ini dan membayarnya bulan depan.',
        ),
        'bola salju': (
          arti: 'Cara melunasi utang dengan mendahulukan utang yang sisanya paling kecil.',
          contohRupiah: 'Dari tiga utang, lunasi dulu yang sisanya Rp800.000.',
        ),
        'longsor': (
          arti: 'Cara melunasi utang dengan mendahulukan utang yang bunganya paling tinggi.',
          contohRupiah: 'Dari tiga utang, lunasi dulu yang bunganya 36 persen per tahun.',
        ),
      };

      for (final e in entriWajib.entries) {
        final istilah = e.key;
        final target = e.value;

        // Cek di aset/konten/kamus.json
        final entriJson = daftarKamus.firstWhere(
          (k) => k['istilah'] == istilah,
          orElse: () => throw Exception('Istilah "$istilah" tidak ditemukan di kamus.json'),
        );
        expect(entriJson['arti'], equals(target.arti), reason: 'Arti "$istilah" di kamus.json tidak cocok kata per kata');
        expect(entriJson['contohRupiah'], equals(target.contohRupiah), reason: 'Contoh Rupiah "$istilah" di kamus.json tidak cocok kata per kata');

        // Cek di docs/materi/kamus_modul_4.md
        expect(isiMateriKamus.contains(istilah), isTrue, reason: 'Istilah "$istilah" tidak ditemukan di docs/materi/kamus_modul_4.md');
        expect(isiMateriKamus.contains(target.arti), isTrue, reason: 'Arti "$istilah" tidak ditemukan di docs/materi/kamus_modul_4.md');
        expect(isiMateriKamus.contains(target.contohRupiah), isTrue, reason: 'Contoh Rupiah "$istilah" tidak ditemukan di docs/materi/kamus_modul_4.md');
      }
    });
  });

  group('Uji Kesesuaian Lampiran Modul 5 dan Disclaimer (Tahap 8C)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};
    late List<dynamic> daftarKamus;
    late String isiMateriKamus;
    late Map<String, dynamic> disclaimerJson;

    setUpAll(() {
      final materiFile = File('docs/materi/modul_5_waspada_penipuan.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_5_waspada_penipuan.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/pemula/waspada_penipuan/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'waspada_penipuan_5_$i';
        final f = File('aset/konten/pemula/waspada_penipuan/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }

      final kamusFile = File('aset/konten/kamus.json');
      expect(kamusFile.existsSync(), isTrue);
      daftarKamus = jsonDecode(kamusFile.readAsStringSync()) as List<dynamic>;

      final kamusMateriFile = File('docs/materi/kamus_modul_5.md');
      expect(kamusMateriFile.existsSync(), isTrue);
      isiMateriKamus = kamusMateriFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final disclaimerFile = File('aset/konten/disclaimer.json');
      expect(disclaimerFile.existsSync(), isTrue);
      disclaimerJson = jsonDecode(disclaimerFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('(a) Validasi Metadata Modul 5 dan Pesan Gerbang', () {
      expect(modulJson['id'], equals('waspada_penipuan'));
      expect(modulJson['judul'], equals('Waspada Penipuan & Pinjol Ilegal'));
      expect(modulJson['tingkat'], equals('pemula'));
      expect(modulJson['urutan'], equals(5));
      expect(modulJson['tersedia'], isTrue);
      expect(modulJson['daftarPelajaran'], equals([
        'waspada_penipuan_5_1',
        'waspada_penipuan_5_2',
        'waspada_penipuan_5_3',
      ]));

      // Gerbang modul
      final gerbang = modulJson['gerbang'] as List<dynamic>;
      expect(gerbang, hasLength(1));
      expect(gerbang[0]['tipe'], equals('modul_selesai'));
      expect(gerbang[0]['modulId'], equals('anggaran_arus_kas'));
      expect(gerbang[0]['pesan'], equals('Selesaikan Modul 1 dulu, lalu modul ini terbuka.'));

      // Pesan gerbang pada lampiran
      expect(isiMateriLampiran.contains('Selesaikan Modul 1 dulu, lalu modul ini terbuka.'), isTrue);
    });

    test('(b) Validasi Pelajaran 5.1 (Ciri Tawaran yang Mencurigakan & Misi Keputusan)', () {
      final p = pelajaranJson['waspada_penipuan_5_1']!;
      expect(p['judul'], equals('Ciri Tawaran yang Mencurigakan'));
      expect(p['durasiMenit'], equals(5));
      expect(p['gerbang'], isEmpty);
      expect(p['catatanReviewer'], contains('TODO-VERIFIKASI'));

      // Misi keputusan
      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('keputusan'));
      expect(misi['judul'], equals('Latih rem-mu'));
      expect(misi['instruksi'], contains('Baca skenarionya, lalu pilih langkah'));

      final skenario = misi['skenario'] as Map<String, dynamic>;
      expect(skenario['pemantik'], contains('Seseorang menelepon dan mengaku dari bank'));

      final opsi = skenario['opsi'] as List<dynamic>;
      expect(opsi, hasLength(4));
      expect(opsi[0]['id'], equals('a'));
      expect(opsi[0]['aman'], isFalse);
      expect(opsi[1]['id'], equals('b'));
      expect(opsi[1]['aman'], isTrue);
      expect(opsi[2]['id'], equals('c'));
      expect(opsi[2]['aman'], isFalse);
      expect(opsi[3]['id'], equals('d'));
      expect(opsi[3]['aman'], isFalse);

      // Verifikasi teks lampiran
      expect(isiMateriLampiran.contains('Ciri Tawaran yang Mencurigakan'), isTrue);
      expect(isiMateriLampiran.contains('Penipuan bermain di perasaan'), isTrue);
      expect(isiMateriLampiran.contains('Tiga rem sebelum bertindak'), isTrue);
    });

    test('(c) Validasi Pelajaran 5.2 (Cek Legalitas Sebelum Percaya & Misi Daftar Periksa)', () {
      final p = pelajaranJson['waspada_penipuan_5_2']!;
      expect(p['judul'], equals('Cek Legalitas Sebelum Percaya'));
      expect(p['durasiMenit'], equals(6));
      expect(p['gerbang'], isEmpty);
      expect(p['catatanReviewer'], contains('TODO-VERIFIKASI'));

      // Misi daftar periksa
      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('daftar_periksa'));
      expect(misi['disclaimer'], isTrue);
      expect(misi['minimalDicentang'], equals(3));
      expect(misi['judul'], equals('Siapkan cara cek penyedia'));

      final langkah = misi['langkah'] as List<dynamic>;
      expect(langkah, hasLength(6));
      expect(langkah[0]['id'], equals('l1'));
      expect(langkah[5]['id'], equals('l6'));

      expect(isiMateriLampiran.contains('Cek Legalitas Sebelum Percaya'), isTrue);
      expect(isiMateriLampiran.contains('Izin itu pintu pertama'), isTrue);
      expect(isiMateriLampiran.contains('Tanda aplikasi pinjaman bermasalah'), isTrue);
    });

    test('(d) Validasi Pelajaran 5.3 (Kalau Sudah Terlanjur & Misi Daftar Periksa)', () {
      final p = pelajaranJson['waspada_penipuan_5_3']!;
      expect(p['judul'], equals('Kalau Sudah Terlanjur'));
      expect(p['durasiMenit'], equals(5));
      expect(p['gerbang'], isEmpty);
      expect(p['catatanReviewer'], contains('TODO-VERIFIKASI'));

      // Misi daftar periksa
      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('daftar_periksa'));
      expect(misi['disclaimer'], isTrue);
      expect(misi['minimalDicentang'], equals(3));
      expect(misi['judul'], equals('Susun rencana daruratmu'));

      final langkah = misi['langkah'] as List<dynamic>;
      expect(langkah, hasLength(5));
      expect(langkah[0]['id'], equals('l1'));
      expect(langkah[4]['id'], equals('l5'));

      expect(isiMateriLampiran.contains('Kalau Sudah Terlanjur'), isTrue);
      expect(isiMateriLampiran.contains('Tenang dulu, lalu bertindak'), isTrue);
      expect(isiMateriLampiran.contains('Langkah pertama: amankan'), isTrue);
    });

    test('(e) Validasi Kuis Akhir Modul 5 (5 dari 10 bankSoal, sebaran 4/3/3)', () {
      final kuis = modulJson['kuis'] as Map<String, dynamic>;
      expect(kuis['jumlahSoal'], equals(5));

      final bankSoal = kuis['bankSoal'] as List<dynamic>;
      expect(bankSoal, hasLength(10));

      final sebaran = <String, int>{};
      for (final s in bankSoal) {
        final pelId = s['pelajaranId'] as String;
        sebaran[pelId] = (sebaran[pelId] ?? 0) + 1;
      }

      expect(sebaran['waspada_penipuan_5_1'], equals(4), reason: 'Pelajaran 5_1 wajib punya 4 soal');
      expect(sebaran['waspada_penipuan_5_2'], equals(3), reason: 'Pelajaran 5_2 wajib punya 3 soal');
      expect(sebaran['waspada_penipuan_5_3'], equals(3), reason: 'Pelajaran 5_3 wajib punya 3 soal');
    });

    test('(f) Validasi Enam Entri Kamus Modul 5 Kata per Kata', () {
      final entriModul5 = {
        'OTP': (
          arti: 'Kode sekali pakai yang dikirim ke HP atau e-mailmu untuk memastikan itu benar-benar kamu. Jangan dibagikan ke siapa pun.',
          contohRupiah: 'Kode 6 angka yang dikirim saat kamu mengonfirmasi transfer Rp100.000.',
        ),
        'phishing': (
          arti: 'Penipuan lewat pesan, tautan, atau situs palsu yang menyamar sebagai pihak tepercaya untuk mencuri data atau uangmu.',
          contohRupiah: 'Pesan "akunmu akan diblokir" dengan tautan palsu agar kamu memasukkan PIN.',
        ),
        'pinjol ilegal': (
          arti: 'Layanan pinjaman online yang tidak berizin dari lembaga pengawas, sehingga biaya dan cara menagihnya tidak diawasi.',
          contohRupiah: 'Pinjaman Rp3.000.000 yang hanya cair Rp2.100.000, tetapi harus dikembalikan Rp3.000.000 dalam dua minggu.',
        ),
        'biaya di muka': (
          arti: 'Biaya yang diminta dibayar lebih dulu sebelum kamu menerima sesuatu, atau dipotong dari dana yang cair.',
          contohRupiah: 'Diminta transfer Rp150.000 agar hadiah Rp5.000.000 bisa cair.',
        ),
        'verifikasi dua langkah': (
          arti: 'Pengaman tambahan saat masuk akun: selain kata sandi, kamu perlu satu langkah lain, misalnya kode.',
          contohRupiah: 'Masuk ke e-mail dengan kata sandi, lalu memasukkan kode yang dikirim ke HP.',
        ),
        'lembaga pengawas': (
          arti: 'Lembaga yang mengawasi dan memberi izin kepada penyedia layanan keuangan.',
          contohRupiah: 'Penyedia pinjaman yang berizin tercatat di lembaga pengawas keuangan.',
        ),
      };

      for (final e in entriModul5.entries) {
        final istilah = e.key;
        final target = e.value;

        // Cek di aset/konten/kamus.json
        final entriJson = daftarKamus.firstWhere(
          (k) => k['istilah'] == istilah,
          orElse: () => throw Exception('Istilah "$istilah" tidak ditemukan di kamus.json'),
        );
        expect(entriJson['arti'], equals(target.arti), reason: 'Arti "$istilah" di kamus.json tidak cocok kata per kata');
        expect(entriJson['contohRupiah'], equals(target.contohRupiah), reason: 'Contoh Rupiah "$istilah" di kamus.json tidak cocok kata per kata');

        // Cek di docs/materi/kamus_modul_5.md
        expect(isiMateriKamus.contains(istilah), isTrue, reason: 'Istilah "$istilah" tidak ditemukan di docs/materi/kamus_modul_5.md');
        expect(isiMateriKamus.contains(target.arti), isTrue, reason: 'Arti "$istilah" tidak ditemukan di docs/materi/kamus_modul_5.md');
        expect(isiMateriKamus.contains(target.contohRupiah), isTrue, reason: 'Contoh Rupiah "$istilah" tidak ditemukan di docs/materi/kamus_modul_5.md');
      }
    });

    test('(g) Validasi Berkas aset/konten/disclaimer.json Kata per Kata', () {
      expect(disclaimerJson.containsKey('langkahDuniaNyata'), isTrue);
      const teksHarapan =
          'Funda hanya memberi edukasi umum. Ini bukan ajakan membeli produk keuangan atau '
          'nasihat keuangan, hukum, maupun pajak. Keputusan dan risikonya ada padamu. '
          'Funda tidak bertanggung jawab atas kerugian dari tindakan di luar aplikasi. '
          'Pastikan penyedia berizin sebelum memakai uangmu.';
      expect(
        (disclaimerJson['langkahDuniaNyata'] as String).replaceAll(RegExp(r'\s+'), ' ').trim(),
        equals(teksHarapan.replaceAll(RegExp(r'\s+'), ' ').trim()),
      );
    });
  });

  group('Uji Kesesuaian Lampiran Tahap 8D (Modul 6 & Kamus Modul 6)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};
    late List<dynamic> daftarKamus;
    late String isiMateriKamus;

    setUpAll(() {
      final materiFile = File('docs/materi/modul_6_psikologi_uang.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_6_psikologi_uang.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/pemula/psikologi_uang/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'psikologi_uang_6_$i';
        final f = File('aset/konten/pemula/psikologi_uang/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }

      final kamusFile = File('aset/konten/kamus.json');
      expect(kamusFile.existsSync(), isTrue);
      daftarKamus = jsonDecode(kamusFile.readAsStringSync()) as List<dynamic>;

      final kamusMateriFile = File('docs/materi/kamus_modul_6.md');
      expect(kamusMateriFile.existsSync(), isTrue);
      isiMateriKamus = kamusMateriFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');
    });

    test('(a) Validasi Metadata Modul 6 dan Pesan Gerbang', () {
      expect(modulJson['id'], equals('psikologi_uang'));
      expect(modulJson['judul'], equals('Psikologi Uang & Kebiasaan Belanja'));
      expect(modulJson['tingkat'], equals('pemula'));
      expect(modulJson['urutan'], equals(6));
      expect(modulJson['tersedia'], isTrue);
      expect(modulJson['daftarPelajaran'], equals([
        'psikologi_uang_6_1',
        'psikologi_uang_6_2',
        'psikologi_uang_6_3',
      ]));

      // Gerbang modul
      final gerbang = modulJson['gerbang'] as List<dynamic>;
      expect(gerbang, hasLength(2));
      expect(gerbang[0]['tipe'], equals('modul_selesai'));
      expect(gerbang[0]['modulId'], equals('anggaran_arus_kas'));
      expect(gerbang[0]['pesan'], equals('Selesaikan Modul 1 dulu, lalu catat minimal 5 pengeluaran agar kamu bisa mengenali pola belanjamu sendiri.'));

      expect(gerbang[1]['tipe'], equals('ada_data'));
      expect(gerbang[1]['objek'], equals('pengeluaran'));
      expect(gerbang[1]['min'], equals(5));
      expect(gerbang[1]['pesan'], equals('Selesaikan Modul 1 dulu, lalu catat minimal 5 pengeluaran agar kamu bisa mengenali pola belanjamu sendiri.'));

      // Pesan gerbang pada lampiran
      expect(isiMateriLampiran.contains('Selesaikan Modul 1 dulu, lalu catat minimal 5 pengeluaran agar kamu bisa mengenali pola belanjamu sendiri.'), isTrue);

      // Kuis Modul 6: bankSoal 10 (sebaran 4/3/3), jumlahSoal 5
      expect(modulJson['kuis']['jumlahSoal'], equals(5));
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      expect(bankSoal.length, equals(10));

      final hitungPerPelajaran = <String, int>{};
      for (final soal in bankSoal) {
        final pelId = soal['pelajaranId'] as String;
        expect(pelajaranJson.containsKey(pelId), isTrue, reason: 'pelajaranId $pelId tidak valid');
        hitungPerPelajaran[pelId] = (hitungPerPelajaran[pelId] ?? 0) + 1;
      }
      expect(hitungPerPelajaran['psikologi_uang_6_1'], equals(4), reason: '6.1 harus 4 soal');
      expect(hitungPerPelajaran['psikologi_uang_6_2'], equals(3), reason: '6.2 harus 3 soal');
      expect(hitungPerPelajaran['psikologi_uang_6_3'], equals(3), reason: '6.3 harus 3 soal');
    });

    test('(b) Validasi Pelajaran 6.1 (Kenapa Kita Belanja Impulsif? & Misi Refleksi)', () {
      final p = pelajaranJson['psikologi_uang_6_1']!;
      expect(p['judul'], equals('Kenapa Kita Belanja Impulsif?'));
      expect(p['durasiMenit'], equals(5));
      expect(p['gerbang'], isEmpty);

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('refleksi'));
      expect(misi['minimalKarakter'], equals(10));
      expect(misi['judul'], equals('Kenali pemicu belanjamu'));
      expect(misi['instruksi'], contains('Tulis satu situasi'));
      expect(misi['pertanyaan'], contains('Kapan atau dalam keadaan apa'));
      expect(misi['petunjukInput'], contains('Contoh: Saat capek'));
    });

    test('(c) Validasi Pelajaran 6.2 (Langganan dan Pengeluaran Diam-Diam & Misi Lihat Hitungan)', () {
      final p = pelajaranJson['psikologi_uang_6_2']!;
      expect(p['judul'], equals('Langganan dan Pengeluaran Diam-Diam'));
      expect(p['durasiMenit'], equals(5));
      expect(p['gerbang'], isEmpty);

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('lihat_hitungan'));
      expect(misi['judul'], equals('Lihat langganan dan keinginanmu'));
      expect(misi['umpanBalik'], equals('ringkasan_langganan_dan_keinginan'));
    });

    test('(d) Validasi Pelajaran 6.3 (Aturan Jeda Sebelum Membeli & Misi Refleksi)', () {
      final p = pelajaranJson['psikologi_uang_6_3']!;
      expect(p['judul'], equals('Aturan Jeda Sebelum Membeli'));
      expect(p['durasiMenit'], equals(5));
      expect(p['aturanPraktis'], isTrue);
      const catatanReviewerEkspektasi =
          'TODO-VERIFIKASI. Aturan jeda (menunggu 24 jam atau beberapa hari sebelum membeli keinginan) adalah teknik perilaku populer di literasi keuangan; periksa kecocokan redaksinya sebagai pedoman fleksibel.';
      expect(p['catatanReviewer'], equals(catatanReviewerEkspektasi));
      expect(isiMateriLampiran, contains(catatanReviewerEkspektasi), reason: 'catatanReviewer harus persis muncul di lampiran markdown');
      expect(p['gerbang'], isEmpty);

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('refleksi'));
      expect(misi['minimalKarakter'], equals(10));
      expect(misi['judul'], equals('Tulis aturan jedamu sendiri'));
      expect(misi['instruksi'], contains('Tulis satu aturan jeda sederhana'));
      expect(misi['pertanyaan'], contains('Mulai batas nominal berapa'));
      expect(misi['petunjukInput'], contains('Contoh: Untuk keinginan di atas Rp100.000'));
    });

    test('(e) Kesesuaian KATA PER KATA seluruh teks JSON Modul 6 terhadap Lampiran Markdown', () {
      void cekStringMuncul(String teks, String konteks) {
        final normal = teks.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normal.isEmpty) return;
        final tanpaToken = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) || isiMateriLampiran.contains(tanpaToken);
        expect(
          cocok,
          isTrue,
          reason: 'Teks pada $konteks TIDAK DITEMUKAN di lampiran materi Modul 6: "$normal"',
        );
      }

      for (final entry in pelajaranJson.entries) {
        final p = entry.value;
        final id = entry.key;

        cekStringMuncul(p['judul'] as String, '$id.judul');
        cekStringMuncul(p['pemantik'] as String, '$id.pemantik');

        final kartuList = p['kartu'] as List;
        for (var k = 0; k < kartuList.length; k++) {
          final kartu = kartuList[k] as Map<String, dynamic>;
          cekStringMuncul(kartu['judul'] as String, '$id.kartu[$k].judul');
          cekStringMuncul(kartu['isi'] as String, '$id.kartu[$k].isi');
        }

        final contohAngka = p['contohAngka'] as Map<String, dynamic>;
        cekStringMuncul(contohAngka['judul'] as String, '$id.contohAngka.judul');
        cekStringMuncul(contohAngka['kesimpulan'] as String, '$id.contohAngka.kesimpulan');
        final baris = contohAngka['baris'] as List;
        for (var b = 0; b < baris.length; b++) {
          final item = baris[b] as Map<String, dynamic>;
          cekStringMuncul(item['label'] as String, '$id.contohAngka.baris[$b].label');
        }

        final cekPaham = p['cekPaham'] as List;
        for (var c = 0; c < cekPaham.length; c++) {
          final soal = cekPaham[c] as Map<String, dynamic>;
          cekStringMuncul(soal['tanya'] as String, '$id.cekPaham[$c].tanya');
          final pilihan = soal['pilihan'] as List;
          for (var pil = 0; pil < pilihan.length; pil++) {
            cekStringMuncul(pilihan[pil] as String, '$id.cekPaham[$c].pilihan[$pil]');
          }
          cekStringMuncul(soal['penjelasan'] as String, '$id.cekPaham[$c].penjelasan');
        }

        final misi = p['misi'] as Map<String, dynamic>;
        cekStringMuncul(misi['judul'] as String, '$id.misi.judul');
        cekStringMuncul(misi['instruksi'] as String, '$id.misi.instruksi');
        if (misi.containsKey('pertanyaan')) {
          cekStringMuncul(misi['pertanyaan'] as String, '$id.misi.pertanyaan');
        }
        if (misi.containsKey('petunjukInput')) {
          cekStringMuncul(misi['petunjukInput'] as String, '$id.misi.petunjukInput');
        }

        cekStringMuncul(p['tindakLanjut'] as String, '$id.tindakLanjut');
      }

      // Periksa juga soal kuis
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      for (var s = 0; s < bankSoal.length; s++) {
        final soal = bankSoal[s] as Map<String, dynamic>;
        cekStringMuncul(soal['tanya'] as String, 'kuis.bankSoal[$s].tanya');
        final pilihan = soal['pilihan'] as List;
        for (var pil = 0; pil < pilihan.length; pil++) {
          cekStringMuncul(pilihan[pil] as String, 'kuis.bankSoal[$s].pilihan[$pil]');
        }
        cekStringMuncul(soal['penjelasan'] as String, 'kuis.bankSoal[$s].penjelasan');
      }
    });

    test('(f) Validasi 4 Istilah Kamus Modul 6 di kamus.json dan kamus_modul_6.md Kata per Kata', () {
      final istilahModul6 = {
        'belanja impulsif': (
          arti: 'Membeli sesuatu secara mendadak tanpa rencana sebelumnya, sering dipicu emosi atau promo.',
          contohRupiah: 'Membeli barang Rp75.000 saat melihat promo malam hari padahal tidak sedang dicari.',
        ),
        'pemicu belanja': (
          arti: 'Situasi, waktu, atau perasaan yang sering membuatmu ingin membeli sesuatu tanpa rencana.',
          contohRupiah: 'Notifikasi diskon yang muncul saat kamu sedang lelah setelah beraktivitas.',
        ),
        'langganan': (
          arti: 'Pembayaran rutin berkala untuk memakai layanan tertentu, seperti musik, film, atau aplikasi.',
          contohRupiah: 'Membayar Rp55.000 tiap bulan untuk layanan musik.',
        ),
        'aturan jeda': (
          arti: 'Kebiasaan menunda pembayaran keinginan selama waktu tertentu agar dorongan sesaat mereda.',
          contohRupiah: 'Menunggu satu hari dulu sebelum membayar sepatu Rp350.000 di keranjang.',
        ),
      };

      for (final e in istilahModul6.entries) {
        final istilah = e.key;
        final target = e.value;

        // Cek di aset/konten/kamus.json
        final entriJson = daftarKamus.firstWhere(
          (k) => k['istilah'] == istilah,
          orElse: () => throw Exception('Istilah "$istilah" tidak ditemukan di kamus.json'),
        );
        expect(entriJson['arti'], equals(target.arti), reason: 'Arti "$istilah" di kamus.json tidak cocok kata per kata');
        expect(entriJson['contohRupiah'], equals(target.contohRupiah), reason: 'Contoh Rupiah "$istilah" di kamus.json tidak cocok kata per kata');

        // Cek di docs/materi/kamus_modul_6.md
        expect(isiMateriKamus.contains(istilah), isTrue, reason: 'Istilah "$istilah" tidak ditemukan di docs/materi/kamus_modul_6.md');
        expect(isiMateriKamus.contains(target.arti), isTrue, reason: 'Arti "$istilah" tidak ditemukan di docs/materi/kamus_modul_6.md');
        expect(isiMateriKamus.contains(target.contohRupiah), isTrue, reason: 'Contoh Rupiah "$istilah" tidak ditemukan di docs/materi/kamus_modul_6.md');
      }
    });
  });

  group('Uji Kesesuaian Lampiran Tahap 9A (Modul 11 & Kamus Modul 11)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};
    late List<dynamic> daftarKamus;
    late String isiMateriKamus;

    setUpAll(() {
      final materiFile = File('docs/materi/modul_11_investasi_dasar.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_11_investasi_dasar.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/menengah/investasi_dasar/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'investasi_dasar_11_$i';
        final f = File('aset/konten/menengah/investasi_dasar/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }

      final kamusFile = File('aset/konten/kamus.json');
      expect(kamusFile.existsSync(), isTrue);
      daftarKamus = jsonDecode(kamusFile.readAsStringSync()) as List<dynamic>;

      final kamusMateriFile = File('docs/materi/kamus_modul_11.md');
      expect(kamusMateriFile.existsSync(), isTrue);
      isiMateriKamus = kamusMateriFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');
    });

    test('(a) Validasi Metadata Modul 11 dan Pesan Gerbang', () {
      expect(modulJson['id'], equals('investasi_dasar'));
      expect(modulJson['judul'], equals('Investasi Dasar'));
      expect(modulJson['tingkat'], equals('menengah'));
      expect(modulJson['urutan'], equals(11));
      expect(modulJson['tersedia'], isTrue);
      expect(modulJson['daftarPelajaran'], equals([
        'investasi_dasar_11_1',
        'investasi_dasar_11_2',
        'investasi_dasar_11_3',
      ]));

      // Gerbang modul
      final gerbang = modulJson['gerbang'] as List<dynamic>;
      expect(gerbang, hasLength(2));
      expect(gerbang[0]['tipe'], equals('modul_selesai'));
      expect(gerbang[0]['modulId'], equals('dana_darurat'));
      const pesanGerbangEkspektasi =
          'Selesaikan Modul 3 (Dana Darurat) dan Modul 4 (Utang & Cicilan) dulu, supaya fondasimu kuat sebelum belajar investasi.';
      expect(gerbang[0]['pesan'], equals(pesanGerbangEkspektasi));

      expect(gerbang[1]['tipe'], equals('modul_selesai'));
      expect(gerbang[1]['modulId'], equals('utang_cicilan'));
      expect(gerbang[1]['pesan'], equals(pesanGerbangEkspektasi));

      expect(isiMateriLampiran.contains(pesanGerbangEkspektasi), isTrue);

      // Kuis Modul 11: bankSoal 10 (sebaran 4/3/3), jumlahSoal 5
      expect(modulJson['kuis']['jumlahSoal'], equals(5));
      final bankSoal = modulJson['kuis']['bankSoal'] as List;
      expect(bankSoal.length, equals(10));

      final hitungPerPelajaran = <String, int>{};
      for (final soal in bankSoal) {
        final pelId = soal['pelajaranId'] as String;
        expect(pelajaranJson.containsKey(pelId), isTrue, reason: 'pelajaranId $pelId tidak valid');
        hitungPerPelajaran[pelId] = (hitungPerPelajaran[pelId] ?? 0) + 1;
      }
      expect(hitungPerPelajaran['investasi_dasar_11_1'], equals(4), reason: '11.1 harus 4 soal');
      expect(hitungPerPelajaran['investasi_dasar_11_2'], equals(3), reason: '11.2 harus 3 soal');
      expect(hitungPerPelajaran['investasi_dasar_11_3'], equals(3), reason: '11.3 harus 3 soal');
    });

    test('(b) Validasi Pelajaran 11.1 (Kenapa Uang Bisa Tergerus Inflasi? & Misi Keputusan)', () {
      final p = pelajaranJson['investasi_dasar_11_1']!;
      expect(p['judul'], equals('Kenapa Uang Bisa Tergerus Inflasi?'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Angka inflasi 4 persen per tahun hanya ilustrasi edukatif, bukan proyeksi resmi.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Ilustrasi daya beli Rp10.000.000 jika harga naik 4 persen per tahun'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(10000000));
      expect(contohAngka['baris'][1]['jumlah'], equals(8219271));
      expect(contohAngka['baris'][2]['jumlah'], equals(-1780729));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('keputusan'));
      expect(misi['judul'], equals('Pilih pos uang yang tepat'));
      final skenario = misi['skenario'] as Map<String, dynamic>;
      expect(skenario['opsi'], hasLength(3));
      expect(skenario['opsi'][1]['aman'], isTrue);
    });

    test('(c) Validasi Pelajaran 11.2 (Risiko, Imbal Hasil, dan Diversifikasi & Misi Sandbox)', () {
      final p = pelajaranJson['investasi_dasar_11_2']!;
      expect(p['judul'], equals('Risiko, Imbal Hasil, dan Diversifikasi'));
      expect(p['durasiMenit'], equals(6));
      expect(p['aturanPraktis'], isTrue);
      const catatanEkspektasi =
          'TODO-VERIFIKASI. Gambaran umum karakter pasar uang, obligasi, dan saham bersifat edukatif umum; periksa kecocokannya dengan materi literasi keuangan resmi.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Ilustrasi Rp10.000.000 saat pasar saham turun 20 persen'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(8000000));
      expect(contohAngka['baris'][1]['jumlah'], equals(9150000));
      expect(contohAngka['baris'][2]['jumlah'], equals(1150000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('sandbox'));
      expect(misi['disclaimer'], isTrue);
      expect(misi['minimalSimulasi'], equals(1));
      expect(misi['judul'], equals('Coba simulasi di Mode Sandbox'));
    });

    test('(d) Validasi Pelajaran 11.3 (Mulai Kecil dan Cek Izin Penyedia & Misi Daftar Periksa)', () {
      final p = pelajaranJson['investasi_dasar_11_3']!;
      expect(p['judul'], equals('Mulai Kecil dan Cek Izin Penyedia'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Langkah persiapan sebelum memakai penyedia investasi berizin di luar aplikasi; tidak menyebut merek atau situs tertentu.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Ilustrasi menyisihkan rutin Rp200.000 per bulan selama 12 bulan'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(2400000));
      expect(contohAngka['baris'][1]['jumlah'], equals(200000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('daftar_periksa'));
      expect(misi['disclaimer'], isTrue);
      expect(misi['minimalDicentang'], equals(3));
      expect(misi['langkah'], hasLength(5));
    });

    test('(e) Validasi 8 Entri Kamus Modul 11 Cocok Persis Kata per Kata', () {
      final istilahModul11 = {
        'inflasi': (
          arti: 'Kenaikan harga barang dan jasa secara umum dari waktu ke waktu yang menurunkan daya beli uang.',
          contohRupiah: 'Makanan Rp20.000 hari ini bisa menjadi Rp22.000 beberapa tahun lagi.',
        ),
        'investasi': (
          arti: 'Menempatkan uang pada instrumen yang berpotensi tumbuh seiring waktu, dengan risiko nilai bisa naik atau turun.',
          contohRupiah: 'Menyisihkan Rp200.000 per bulan untuk tujuan 10 tahun lagi.',
        ),
        'imbal hasil': (
          arti: 'Potensi keuntungan yang diperoleh dari sebuah instrumen investasi.',
          contohRupiah: 'Nilai Rp10.000.000 tumbuh menjadi Rp10.600.000 dalam setahun berarti imbal hasil Rp600.000.',
        ),
        'risiko investasi': (
          arti: 'Kemungkinan nilai investasi turun atau hasilnya berbeda dari yang diharapkan.',
          contohRupiah: 'Nilai Rp10.000.000 bisa sementara turun menjadi Rp8.500.000 saat pasar lesu.',
        ),
        'diversifikasi': (
          arti: 'Membagi dana investasi ke beberapa jenis instrumen berbeda untuk membantu meredam guncangan.',
          contohRupiah: 'Membagi Rp10.000.000 menjadi Rp5.000.000 di pasar uang dan Rp5.000.000 di saham.',
        ),
        'pasar uang': (
          arti: 'Kelompok instrumen investasi jangka pendek yang nilainya cenderung paling stabil dengan pertumbuhan kecil.',
          contohRupiah: 'Menempatkan Rp5.000.000 di instrumen pasar uang agar nilainya relatif tenang.',
        ),
        'obligasi': (
          arti: 'Surat utang yang diterbitkan negara atau perusahaan dengan potensi imbal hasil dan risiko di tingkat menengah.',
          contohRupiah: 'Menempatkan Rp5.000.000 di obligasi sebagai penyeimbang portofolio.',
        ),
        'saham': (
          arti: 'Bukti kepemilikan atas sebagian kecil sebuah usaha yang berpotensi tumbuh tinggi tetapi nilainya mudah bergejolak.',
          contohRupiah: 'Menempatkan Rp5.000.000 di saham untuk tujuan jangka panjang.',
        ),
      };

      for (final e in istilahModul11.entries) {
        final istilah = e.key;
        final target = e.value;

        // Cek di aset/konten/kamus.json
        final entriJson = daftarKamus.firstWhere(
          (k) => k['istilah'] == istilah,
          orElse: () => throw Exception('Istilah "$istilah" tidak ditemukan di kamus.json'),
        );
        expect(entriJson['arti'], equals(target.arti), reason: 'Arti "$istilah" di kamus.json tidak cocok kata per kata');
        expect(entriJson['contohRupiah'], equals(target.contohRupiah), reason: 'Contoh Rupiah "$istilah" di kamus.json tidak cocok kata per kata');

        // Cek di docs/materi/kamus_modul_11.md
        expect(isiMateriKamus.contains(istilah), isTrue, reason: 'Istilah "$istilah" tidak ditemukan di docs/materi/kamus_modul_11.md');
        expect(isiMateriKamus.contains(target.arti), isTrue, reason: 'Arti "$istilah" tidak ditemukan di docs/materi/kamus_modul_11.md');
        expect(isiMateriKamus.contains(target.contohRupiah), isTrue, reason: 'Contoh Rupiah "$istilah" tidak ditemukan di docs/materi/kamus_modul_11.md');
      }
    });
  });

  group('Kesesuaian Lampiran Modul 7 - Paylater, Kredit & Skor Kredit', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};

    setUpAll(() {
      final materiFile = File('docs/materi/modul_7_paylater_kredit.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_7_paylater_kredit.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/menengah/paylater_kredit/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'paylater_kredit_7_$i';
        final f = File('aset/konten/menengah/paylater_kredit/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }
    });

    test('(a) Validasi Metadata Modul 7, Gerbang, dan Sebaran Kuis 4/3/3', () {
      expect(modulJson['id'], equals('paylater_kredit'));
      expect(modulJson['judul'], equals('Paylater, Kredit & Skor Kredit'));
      expect(modulJson['tingkat'], equals('menengah'));
      expect(modulJson['urutan'], equals(7));
      expect(modulJson['tersedia'], isTrue);
      expect(modulJson['daftarPelajaran'], equals([
        'paylater_kredit_7_1',
        'paylater_kredit_7_2',
        'paylater_kredit_7_3',
      ]));

      // Gerbang modul
      final gerbang = modulJson['gerbang'] as List<dynamic>;
      expect(gerbang, hasLength(1));
      expect(gerbang[0]['tipe'], equals('modul_selesai'));
      expect(gerbang[0]['modulId'], equals('utang_cicilan'));
      const pesanGerbangEkspektasi =
          'Selesaikan Modul 4 (Utang & Cicilan) dulu sebelum mempelajari cara kerja paylater dan reputasi kredit.';
      expect(gerbang[0]['pesan'], equals(pesanGerbangEkspektasi));

      // Kuis
      final kuis = modulJson['kuis'] as Map<String, dynamic>;
      expect(kuis['jumlahSoal'], equals(5));
      final bankSoal = kuis['bankSoal'] as List<dynamic>;
      expect(bankSoal, hasLength(10));

      final hitungPerPelajaran = <String, int>{};
      for (final soal in bankSoal) {
        final pId = soal['pelajaranId'] as String;
        hitungPerPelajaran[pId] = (hitungPerPelajaran[pId] ?? 0) + 1;
      }
      expect(hitungPerPelajaran['paylater_kredit_7_1'], equals(4), reason: '7.1 harus 4 soal');
      expect(hitungPerPelajaran['paylater_kredit_7_2'], equals(3), reason: '7.2 harus 3 soal');
      expect(hitungPerPelajaran['paylater_kredit_7_3'], equals(3), reason: '7.3 harus 3 soal');
    });

    test('(b) Validasi Pelajaran 7.1 (Cara Kerja Paylater di Balik Layar & Misi Keputusan)', () {
      final p = pelajaranJson['paylater_kredit_7_1']!;
      expect(p['judul'], equals('Cara Kerja Paylater di Balik Layar'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Gambaran umum biaya layanan, bunga, dan denda paylater bersifat ilustratif; periksa istilah umum terkini.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Belanja Rp1.000.000 dengan paylater 3 bulan (ilustrasi)'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(1000000));
      expect(contohAngka['baris'][1]['jumlah'], equals(95000));
      expect(contohAngka['baris'][2]['jumlah'], equals(1095000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('keputusan'));
      expect(misi['judul'], equals('Cek sebelum menekan bayar nanti'));
    });

    test('(c) Validasi Pelajaran 7.2 (Mengenal Riwayat dan Skor Kredit & Misi Keputusan)', () {
      final p = pelajaranJson['paylater_kredit_7_2']!;
      expect(p['judul'], equals('Mengenal Riwayat dan Skor Kredit'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Penjelasan umum tentang catatan riwayat kredit dan faktor yang memengaruhinya; tidak menyebut nama sistem lembaga tertentu.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Ilustrasi dampak keterlambatan pada tagihan Rp500.000'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(500000));
      expect(contohAngka['baris'][1]['jumlah'], equals(50000));
      expect(contohAngka['baris'][2]['jumlah'], equals(550000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('keputusan'));
      expect(misi['judul'], equals('Saat tagihan mendekati jatuh tempo'));
    });

    test('(d) Validasi Pelajaran 7.3 (Menjaga Reputasi Kredit Tetap Sehat & Misi Daftar Periksa)', () {
      final p = pelajaranJson['paylater_kredit_7_3']!;
      expect(p['judul'], equals('Menjaga Reputasi Kredit Tetap Sehat'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Langkah praktis menjaga reputasi kredit dan mengecek catatan riwayat kredit lewat jalur resmi; tanpa menyebut nama sistem/situs tertentu.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Membandingkan bayar penuh vs bayar minimum (tagihan Rp1.000.000)'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(0));
      expect(contohAngka['baris'][1]['jumlah'], equals(60000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('daftar_periksa'));
      expect(misi['disclaimer'], isTrue);
      expect(misi['minimalDicentang'], equals(3));
      expect(misi['langkah'], hasLength(5));
    });
  });

  group('Kesesuaian Lampiran Modul 10 - Proteksi (Asuransi & Jaminan Sosial)', () {
    late String isiMateriLampiran;
    late Map<String, dynamic> modulJson;
    final Map<String, Map<String, dynamic>> pelajaranJson = {};

    setUpAll(() {
      final materiFile = File('docs/materi/modul_10_proteksi.md');
      expect(materiFile.existsSync(), isTrue, reason: 'Berkas docs/materi/modul_10_proteksi.md wajib ada');
      isiMateriLampiran = materiFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final modulFile = File('aset/konten/menengah/proteksi_dasar/modul.json');
      expect(modulFile.existsSync(), isTrue);
      modulJson = jsonDecode(modulFile.readAsStringSync()) as Map<String, dynamic>;

      for (var i = 1; i <= 3; i++) {
        final id = 'proteksi_dasar_10_$i';
        final f = File('aset/konten/menengah/proteksi_dasar/$id.json');
        expect(f.existsSync(), isTrue, reason: 'Berkas $id.json wajib ada');
        pelajaranJson[id] = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      }
    });

    test('(a) Validasi Metadata Modul 10, Gerbang, dan Sebaran Kuis 4/3/3', () {
      expect(modulJson['id'], equals('proteksi_dasar'));
      expect(modulJson['judul'], equals('Proteksi (Asuransi & Jaminan Sosial)'));
      expect(modulJson['tingkat'], equals('menengah'));
      expect(modulJson['urutan'], equals(10));
      expect(modulJson['tersedia'], isTrue);
      expect(modulJson['daftarPelajaran'], equals([
        'proteksi_dasar_10_1',
        'proteksi_dasar_10_2',
        'proteksi_dasar_10_3',
      ]));

      // Gerbang modul
      final gerbang = modulJson['gerbang'] as List<dynamic>;
      expect(gerbang, hasLength(1));
      expect(gerbang[0]['tipe'], equals('modul_selesai'));
      expect(gerbang[0]['modulId'], equals('dana_darurat'));
      const pesanGerbangEkspektasi =
          'Selesaikan Modul 3 (Dana Darurat) dulu, supaya kamu paham bedanya bantalan harian dan proteksi risiko besar.';
      expect(gerbang[0]['pesan'], equals(pesanGerbangEkspektasi));

      // Kuis
      final kuis = modulJson['kuis'] as Map<String, dynamic>;
      expect(kuis['jumlahSoal'], equals(5));
      final bankSoal = kuis['bankSoal'] as List<dynamic>;
      expect(bankSoal, hasLength(10));

      final hitungPerPelajaran = <String, int>{};
      for (final soal in bankSoal) {
        final pId = soal['pelajaranId'] as String;
        hitungPerPelajaran[pId] = (hitungPerPelajaran[pId] ?? 0) + 1;
      }
      expect(hitungPerPelajaran['proteksi_dasar_10_1'], equals(4), reason: '10.1 harus 4 soal');
      expect(hitungPerPelajaran['proteksi_dasar_10_2'], equals(3), reason: '10.2 harus 3 soal');
      expect(hitungPerPelajaran['proteksi_dasar_10_3'], equals(3), reason: '10.3 harus 3 soal');
    });

    test('(b) Validasi Pelajaran 10.1 (Kenapa Kita Butuh Proteksi? & Misi Keputusan)', () {
      final p = pelajaranJson['proteksi_dasar_10_1']!;
      expect(p['judul'], equals('Kenapa Kita Butuh Proteksi?'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Penjelasan umum perbedaan dana darurat dan asuransi sebagai pengalihan risiko keuangan.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Ilustrasi biaya perawatan mendadak Rp25.000.000'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(25000000));
      expect(contohAngka['baris'][1]['jumlah'], equals(6000000));
      expect(contohAngka['baris'][2]['jumlah'], equals(-19000000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('keputusan'));
      expect(misi['judul'], equals('Menentukan prioritas perlindungan'));
    });

    test('(c) Validasi Pelajaran 10.2 (Mengenal Jenis Proteksi Dasar & Misi Daftar Periksa)', () {
      final p = pelajaranJson['proteksi_dasar_10_2']!;
      expect(p['judul'], equals('Mengenal Jenis Proteksi Dasar'));
      expect(p['durasiMenit'], equals(6));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Gambaran umum jaminan sosial, asuransi kesehatan, dan asuransi jiwa murni; tanpa menyebut merek atau nama program spesifik.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Memilih fokus proteksi sesuai kondisi (ilustrasi)'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(1));
      expect(contohAngka['baris'][1]['jumlah'], equals(2));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('daftar_periksa'));
      expect(misi['disclaimer'], isTrue);
      expect(misi['minimalDicentang'], equals(3));
      expect(misi['langkah'], hasLength(5));
    });

    test('(d) Validasi Pelajaran 10.3 (Menyesuaikan Proteksi dengan Anggaran & Misi Lihat Hitungan)', () {
      final p = pelajaranJson['proteksi_dasar_10_3']!;
      expect(p['judul'], equals('Menyesuaikan Proteksi dengan Anggaran'));
      expect(p['durasiMenit'], equals(5));
      const catatanEkspektasi = 'TODO-VERIFIKASI. Prinsip menyelaraskan biaya proteksi dengan pengeluaran wajib dan anggaran bulanan; bukan nasihat produk.';
      expect(p['catatanReviewer'], equals(catatanEkspektasi));
      expect(isiMateriLampiran.contains(catatanEkspektasi), isTrue);

      final contohAngka = p['contohAngka'] as Map<String, dynamic>;
      expect(contohAngka['judul'], equals('Ilustrasi iuran proteksi dasar dalam anggaran Rp3.000.000'));
      expect(isiMateriLampiran.contains(contohAngka['judul'] as String), isTrue);
      expect(contohAngka['baris'][0]['jumlah'], equals(3000000));
      expect(contohAngka['baris'][1]['jumlah'], equals(1800000));
      expect(contohAngka['baris'][2]['jumlah'], equals(150000));
      expect(contohAngka['baris'][3]['jumlah'], equals(1050000));

      final misi = p['misi'] as Map<String, dynamic>;
      expect(misi['tipe'], equals('lihat_hitungan'));
      expect(misi['umpanBalik'], equals('ringkasan_proteksi_dasar'));
      expect(misi['judul'], equals('Lihat gambaran beban wajib dan dana daruratmu'));
    });

    test('(e) Validasi 10 Entri Kamus Modul 7 & 10 Cocok Persis Kata per Kata', () {
      final kamusFile = File('aset/konten/kamus.json');
      final daftarKamus = jsonDecode(kamusFile.readAsStringSync()) as List<dynamic>;

      final kamusMateriFile = File('docs/materi/kamus_modul_7_10.md');
      expect(kamusMateriFile.existsSync(), isTrue);
      final isiMateriKamus = kamusMateriFile.readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');

      final istilahModul7dan10 = {
        'biaya layanan': (
          arti: 'Biaya tambahan yang dikenakan penyedia atas penggunaan fasilitas transaksi atau cicilan.',
          contohRupiah: 'Belanja Rp1.000.000 dengan biaya layanan Rp25.000 membuat total menjadi Rp1.025.000.',
        ),
        'denda keterlambatan': (
          arti: 'Biaya tambahan yang dikenakan bila pembayaran tagihan melewati tanggal jatuh tempo.',
          contohRupiah: 'Terlambat membayar tagihan Rp500.000 dikenai denda Rp50.000.',
        ),
        'riwayat kredit': (
          arti: 'Catatan tentang pinjaman dan ketepatan pembayaranmu pada layanan kredit berizin.',
          contohRupiah: 'Membayar cicilan Rp300.000 tepat waktu setiap bulan membentuk riwayat kredit yang baik.',
        ),
        'skor kredit': (
          arti: 'Gambaran ringkas tentang reputasi pembayaranmu berdasarkan riwayat kredit yang tercatat.',
          contohRupiah: 'Riwayat bayar tepat waktu membantu menjaga skor kredit saat mengajukan kredit rumah.',
        ),
        'asuransi': (
          arti: 'Cara mengalihkan risiko biaya besar kepada penyedia proteksi dengan membayar iuran rutin.',
          contohRupiah: 'Membayar iuran Rp150.000 per bulan untuk perlindungan biaya rawat inap.',
        ),
        'premi': (
          arti: 'Iuran berkala yang dibayarkan kepada penyedia proteksi agar perlindungan tetap aktif.',
          contohRupiah: 'Membayar premi kesehatan Rp150.000 setiap awal bulan.',
        ),
        'klaim': (
          arti: 'Pengajuan resmi kepada penyedia proteksi agar biaya risiko yang ditanggung dapat dibayarkan sesuai polis.',
          contohRupiah: 'Mengajukan klaim biaya rawat inap Rp5.000.000 sesuai ketentuan polis.',
        ),
        'polis': (
          arti: 'Dokumen perjanjian resmi yang memuat rincian manfaat, iuran, syarat klaim, dan pengecualian perlindungan.',
          contohRupiah: 'Membaca polis sebelum menyetujui iuran Rp150.000 per bulan.',
        ),
        'jaminan sosial': (
          arti: 'Program perlindungan dasar yang dikelola resmi untuk membantu masyarakat menghadapi risiko seperti kesehatan.',
          contohRupiah: 'Membayar iuran jaminan sosial kesehatan rutin setiap bulan.',
        ),
        'tanggungan': (
          arti: 'Orang yang biaya hidupnya bergantung pada penghasilanmu, seperti anak atau orang tua.',
          contohRupiah: 'Pekerja yang menanggung biaya makan dan sekolah adiknya sebesar Rp1.500.000 per bulan.',
        ),
      };

      for (final e in istilahModul7dan10.entries) {
        final istilah = e.key;
        final target = e.value;

        // Cek di aset/konten/kamus.json
        final entriJson = daftarKamus.firstWhere(
          (k) => k['istilah'] == istilah,
          orElse: () => throw Exception('Istilah "$istilah" tidak ditemukan di kamus.json'),
        );
        expect(entriJson['arti'], equals(target.arti), reason: 'Arti "$istilah" di kamus.json tidak cocok kata per kata');
        expect(entriJson['contohRupiah'], equals(target.contohRupiah), reason: 'Contoh Rupiah "$istilah" di kamus.json tidak cocok kata per kata');

        // Cek di docs/materi/kamus_modul_7_10.md
        expect(isiMateriKamus.contains(istilah), isTrue, reason: 'Istilah "$istilah" tidak ditemukan di docs/materi/kamus_modul_7_10.md');
        expect(isiMateriKamus.contains(target.arti), isTrue, reason: 'Arti "$istilah" tidak ditemukan di docs/materi/kamus_modul_7_10.md');
        expect(isiMateriKamus.contains(target.contohRupiah), isTrue, reason: 'Contoh Rupiah "$istilah" tidak ditemukan di docs/materi/kamus_modul_7_10.md');
      }
    });
  });
}
