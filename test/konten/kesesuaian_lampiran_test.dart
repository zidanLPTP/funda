import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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

        final tanpaToken = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) || isiMateriLampiran.contains(tanpaToken);
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

        final tanpaToken = normal.replaceAll('{{', '').replaceAll('}}', '');
        final cocok = isiMateriLampiran.contains(normal) || isiMateriLampiran.contains(tanpaToken);
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
}
