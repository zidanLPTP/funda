import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/fitur/belajar/model/registri_misi.dart';

void main() {
  group('Evaluator Misi Keputusan (Tahap 8C)', () {
    const skenario = SkenarioKeputusanMisi(
      pemantik: 'Kamu mendapat tawaran pinjaman instan via SMS dengan bunga 0.1% per hari tanpa syarat.',
      opsi: [
        OpsiKeputusanMisi(
          id: 'a',
          teks: 'Langsung balas SMS dan ajukan pinjaman.',
          aman: false,
          umpanBalik: 'Berbahaya! Tawaran pinjaman via SMS pribadi hampir pasti pinjol ilegal.',
        ),
        OpsiKeputusanMisi(
          id: 'b',
          teks: 'Abaikan dan periksa izin penyedia lewat jalur resmi.',
          aman: true,
          umpanBalik: 'Pilihan tepat! Jangan pernah merespons tawaran pinjaman via SMS atau pesan pribadi.',
        ),
        OpsiKeputusanMisi(
          id: 'c',
          teks: 'Kirimkan foto KTP dulu untuk memastikan keasliannya.',
          aman: false,
          umpanBalik: 'Jangan! Memberikan data pribadi seperti KTP ke pihak asing membuka celah pencurian identitas.',
        ),
      ],
    );

    test('Opsi aman menghasilkan evaluasi benar dan opsi tidak aman salah', () {
      final opsiAman = skenario.opsi.firstWhere((o) => o.id == 'b');
      final opsiBahaya1 = skenario.opsi.firstWhere((o) => o.id == 'a');
      final opsiBahaya2 = skenario.opsi.firstWhere((o) => o.id == 'c');

      expect(RegistriMisi.evaluasiKeputusan(opsiAman), isTrue);
      expect(RegistriMisi.evaluasiKeputusan(opsiBahaya1), isFalse);
      expect(RegistriMisi.evaluasiKeputusan(opsiBahaya2), isFalse);

      expect(opsiAman.umpanBalik, contains('Pilihan tepat'));
      expect(opsiBahaya1.umpanBalik, contains('Berbahaya'));
      expect(opsiBahaya2.umpanBalik, contains('Jangan'));
    });

    test('Urutan percobaan dicatat berurutan tanpa batas percobaan', () {
      final riwayat = <String>[];

      // Pengguna mencoba opsi a
      riwayat.add('a');
      expect(riwayat, equals(['a']));

      // Pengguna mencoba opsi c
      riwayat.add('c');
      expect(riwayat, equals(['a', 'c']));

      // Pengguna akhirnya memilih opsi aman b
      riwayat.add('b');
      expect(riwayat, equals(['a', 'c', 'b']));

      // Serialisasi muatan JSON
      final muatanJson = jsonEncode({'opsiDipilih': riwayat});
      expect(muatanJson, equals('{"opsiDipilih":["a","c","b"]}'));

      // Deserialisasi kembali
      final muatanDecoded = jsonDecode(muatanJson) as Map<String, dynamic>;
      final listPulih = (muatanDecoded['opsiDipilih'] as List).cast<String>();
      expect(listPulih, equals(['a', 'c', 'b']));
      expect(listPulih.last, equals('b'));
    });
  });

  group('Evaluator Misi Daftar Periksa (Tahap 8C)', () {
    const minDicentang = 3;

    test('Batas minimal centang: di bawah batas, pas batas, dan melebihi batas', () {
      final centang = <String>{};

      // 0 centang
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isFalse);

      // 1 centang
      centang.add('l1');
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isFalse);

      // 2 centang
      centang.add('l2');
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isFalse);

      // 3 centang (tepat di batas minimal) -> SUKSES
      centang.add('l3');
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isTrue);

      // 4 centang (melebihi batas) -> TETAP SUKSES
      centang.add('l4');
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isTrue);
    });

    test('Centang dicabut menurunkan status dari memenuhi ke belum memenuhi', () {
      final centang = <String>{'l1', 'l2', 'l3'};
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isTrue);

      // Cabut satu centang
      centang.remove('l2');
      expect(centang.length, equals(2));
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isFalse);

      // Tambahkan langkah lain
      centang.add('l4');
      expect(centang.length, equals(3));
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: centang, minimalDicentang: minDicentang), isTrue);
    });

    test('Persistensi muatan JSON daftar periksa dan pemuatan ulang', () {
      final centang = <String>{'l1', 'l3', 'l5'};
      final muatan = {'dicentang': centang.toList()};
      final muatanJson = jsonEncode(muatan);

      expect(muatanJson, equals('{"dicentang":["l1","l3","l5"]}'));

      final decode = jsonDecode(muatanJson) as Map<String, dynamic>;
      final setPulih = (decode['dicentang'] as List).cast<String>().toSet();

      expect(setPulih, equals({'l1', 'l3', 'l5'}));
      expect(RegistriMisi.evaluasiDaftarPeriksa(dicentang: setPulih, minimalDicentang: 3), isTrue);
    });
  });
}
