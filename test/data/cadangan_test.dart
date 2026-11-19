import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/cadangan/format_cadangan.dart';
import 'package:funda/data/cadangan/peningkat_cadangan.dart';
import 'package:funda/perhitungan/perhitungan_pengingat_cadangan.dart';

void main() {
  late BasisDataFunda db;
  late CadanganRepositori repositori;
  late Directory tempDir;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = BasisDataFunda(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('funda_test_cadangan_');
    repositori = CadanganRepositori(db, direktoriPenyimpananUji: tempDir);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Cadangan & Pemulihan Basis Data (Tahap 7)', () {
    test('1. UJI PENJAGA TABEL: Semua tabel_ pada skema SQLite ikut diserialisasi', () async {
      final tabelSkema = await repositori.dapatkanDaftarTabelSkema();
      expect(tabelSkema.isNotEmpty, isTrue);

      final doc = await repositori.eksporCadangan();
      final tabelDisimpan = doc.tabel.keys.toSet();

      for (final namaTabel in tabelSkema) {
        if (CadanganRepositori.tabelDikecualikan.contains(namaTabel)) continue;
        expect(
          tabelDisimpan.contains(namaTabel),
          isTrue,
          reason: 'Tabel skema "$namaTabel" tidak ditemukan pada berkas ekspor cadangan!',
        );
      }
    });

    test('2. UJI PENJAGA REGISTRI PENINGKAT: Setiap versi skema dari pertama sampai schemaVersion - 1 terdaftar', () {
      expect(RegistriPeningkatCadangan.versiSkemaCadanganPertama, equals(10));
      for (var v = RegistriPeningkatCadangan.versiSkemaCadanganPertama; v < db.schemaVersion; v++) {
        expect(
          RegistriPeningkatCadangan.adaPeningkat(v),
          isTrue,
          reason: 'Fungsi peningkat skema dari versi $v ke ${v + 1} belum terdaftar di RegistriPeningkatCadangan!',
        );
      }
    });

    test('3. Deterministik Checksum: Bentuk kanonik menghasilkan hash SHA-256 yang identik', () {
      final tabel1 = {
        'tabel_b': [
          {'z': 1, 'a': 'teks'},
        ],
        'tabel_a': [
          {'id': 1, 'nama': 'Dompet'},
        ],
      };

      final tabel2 = {
        'tabel_a': [
          {'nama': 'Dompet', 'id': 1},
        ],
        'tabel_b': [
          {'a': 'teks', 'z': 1},
        ],
      };

      final checksum1 = hitungChecksumTabel(tabel1);
      final checksum2 = hitungChecksumTabel(tabel2);
      expect(checksum1, equals(checksum2));
    });

    test('4. Uji Bolak-Balik (Round-Trip): Ekspor -> Kosongkan DB -> Impor -> Bandingkan SEMUA baris identik', () async {
      // 1. Masukkan data dummy dompet dan transaksi
      final sekarang = DateTime.now().toUtc();
      await db.customStatement(
        "INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) "
        "VALUES ('dompet-1', 'Dompet Utama', 'tunai', 'wallet', 'tintHijau', 500000, 0, 0, '${sekarang.toIso8601String()}');",
      );

      await db.customStatement(
        "INSERT INTO tabel_transaksi (id, dompet_id, jenis, jumlah_rupiah, waktu_transaksi, dibuat_pada) "
        "VALUES ('tx-1', 'dompet-1', 'keluar', 50000, '${sekarang.toIso8601String()}', '${sekarang.toIso8601String()}');",
      );

      // 2. Ekspor cadangan
      final docEkspor = await repositori.eksporCadangan(waktuDibuat: sekarang);
      final jsonStr = await repositori.eksporCadanganKeJson(waktuDibuat: sekarang);

      // 3. Kosongkan database
      final tabelSkema = await repositori.dapatkanDaftarTabelSkema();
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON;');
        for (final t in tabelSkema) {
          await db.customStatement('DELETE FROM $t;');
        }
      });

      // Pastikan kosong
      final cekDompetKosong = await db.customSelect('SELECT count(*) as c FROM tabel_dompet;').getSingle();
      expect(cekDompetKosong.read<int>('c'), equals(0));

      // 4. Impor cadangan
      final validasi = await repositori.validasiDanBuatPratinjau(jsonStr);
      await repositori.pulihkanCadangan(validasi.dokumen, simpanKeselamatanOtomatis: false);

      // 5. Bandingkan setiap baris di semua tabel
      for (final t in tabelSkema) {
        final rowsDb = await db.customSelect('SELECT * FROM $t ORDER BY rowid;').get();
        final rowsExpected = docEkspor.tabel[t] ?? [];
        if (t == 'tabel_pengaturan') {
          expect(rowsDb.length, equals(rowsExpected.length + 1), reason: 'tabel_pengaturan memuat baris asli + terakhir_cadangan');
          final kunciCadangan = await db.customSelect("SELECT * FROM tabel_pengaturan WHERE kunci = 'terakhir_cadangan';").getSingle();
          expect(kunciCadangan.read<String>('nilai'), equals(docEkspor.dibuatPada.toIso8601String()));
        } else {
          expect(rowsDb.length, equals(rowsExpected.length), reason: 'Jumlah baris pada tabel $t tidak cocok setelah pemulihan!');
        }
      }

      // Pastikan dompet-1 dan tx-1 kembali utuh
      final dompetPulih = await db.customSelect("SELECT * FROM tabel_dompet WHERE id = 'dompet-1';").getSingle();
      expect(dompetPulih.read<String>('nama'), equals('Dompet Utama'));
      expect(dompetPulih.read<int>('saldo_awal_rupiah'), equals(500000));
    });

    test('5. Checksum rusak ditolak', () async {
      final jsonStr = await repositori.eksporCadanganKeJson();
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      map['checksum'] = 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
      final rusakJson = jsonEncode(map);

      expect(
        () => repositori.validasiDanBuatPratinjau(rusakJson),
        throwsA(isA<GalatCadangan>().having((e) => e.pesan, 'pesan', contains('checksum tidak cocok'))),
      );
    });

    test('6. Berkas dipotong (JSON rusak) ditolak', () async {
      final jsonStr = await repositori.eksporCadanganKeJson();
      final terpotong = jsonStr.substring(0, jsonStr.length ~/ 2);

      expect(
        () => repositori.validasiDanBuatPratinjau(terpotong),
        throwsA(isA<GalatCadangan>().having((e) => e.pesan, 'pesan', contains('bukan berkas JSON'))),
      );
    });

    test('7. Versi skema lebih baru ditolak dengan pesan ramah', () async {
      final doc = await repositori.eksporCadangan();
      final map = doc.toJson();
      map['versiSkema'] = db.schemaVersion + 1; // Versi masa depan
      map['checksum'] = hitungChecksumTabel(doc.tabel);
      final jsonBaru = jsonEncode(map);

      expect(
        () => repositori.validasiDanBuatPratinjau(jsonBaru),
        throwsA(isA<GalatCadangan>().having((e) => e.pesan, 'pesan', contains('versi Funda yang lebih baru'))),
      );
    });

    test('8. Tabel dan kolom asing diabaikan tanpa galat', () async {
      final doc = await repositori.eksporCadangan();
      final tabelCopy = Map<String, List<Map<String, dynamic>>>.from(doc.tabel);

      // Tambahkan tabel asing
      tabelCopy['tabel_asing_tak_dikenal'] = [
        {'id': 1, 'data': 'rahasia'},
      ];

      // Tambahkan kolom asing pada tabel_dompet
      final dompetBaris = List<Map<String, dynamic>>.from(tabelCopy['tabel_dompet'] ?? []);
      dompetBaris.add({
        'id': 'dompet-asing',
        'nama': 'Dompet Asing',
        'jenis': 'tunai',
        'ikon': 'wallet',
        'warna': 'tintHijau',
        'saldo_awal_rupiah': 100000,
        'kolom_ajaib_baru': 'nilai_tak_dikenal',
      });
      tabelCopy['tabel_dompet'] = dompetBaris;

      final checksumBaru = hitungChecksumTabel(tabelCopy);
      final map = doc.toJson();
      map['tabel'] = tabelCopy;
      map['checksum'] = checksumBaru;

      final validasi = await repositori.validasiDanBuatPratinjau(jsonEncode(map));
      await repositori.pulihkanCadangan(validasi.dokumen, simpanKeselamatanOtomatis: false);

      // Verifikasi dompet-asing berhasil masuk dengan kolom sah saja
      final cek = await db.customSelect("SELECT * FROM tabel_dompet WHERE id = 'dompet-asing';").getSingle();
      expect(cek.read<String>('nama'), equals('Dompet Asing'));
    });

    test('9. Rollback saat gagal: kegagalan di tengah transaksi menjaga data lama tetap utuh', () async {
      // 1. Masukkan data asli
      await db.customStatement(
        "INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) "
        "VALUES ('dompet-asli', 'Dompet Asli', 'tunai', 'wallet', 'tintHijau', 999000, 0, 0, datetime('now'));",
      );

      final doc = await repositori.eksporCadangan();

      // Coba pulihkan dengan kegagalan yang disuntik
      expect(
        () => repositori.pulihkanCadangan(
          doc,
          simpanKeselamatanOtomatis: false,
          kegagalanSuntikanUntukUji: () {
            throw Exception('Simulasi crash di tengah transaksi pemulihan');
          },
        ),
        throwsA(isA<Exception>()),
      );

      // Verifikasi data asli tetap utuh di database
      final cek = await db.customSelect("SELECT * FROM tabel_dompet WHERE id = 'dompet-asli';").getSingle();
      expect(cek.read<int>('saldo_awal_rupiah'), equals(999000));
    });

    test('10. Foreign key violation menyebabkan rollback seluruhnya', () async {
      final doc = await repositori.eksporCadangan();
      final tabelCopy = Map<String, List<Map<String, dynamic>>>.from(doc.tabel);

      // Tambahkan transaksi yang mereferensikan dompet_id yang tidak ada
      final txList = List<Map<String, dynamic>>.from(tabelCopy['tabel_transaksi'] ?? []);
      txList.add({
        'id': 'tx-rusak-fk',
        'dompet_id': 'dompet_fiktif_tidak_ada',
        'jenis': 'keluar',
        'jumlah_rupiah': 10000,
        'waktu_transaksi': DateTime.now().toIso8601String(),
        'dibuat_pada': DateTime.now().toIso8601String(),
      });
      tabelCopy['tabel_transaksi'] = txList;

      final checksum = hitungChecksumTabel(tabelCopy);
      final map = doc.toJson();
      map['tabel'] = tabelCopy;
      map['checksum'] = checksum;

      final validasi = await repositori.validasiDanBuatPratinjau(jsonEncode(map));

      expect(
        () => repositori.pulihkanCadangan(validasi.dokumen, simpanKeselamatanOtomatis: false),
        throwsA(isA<GalatCadangan>().having((e) => e.pesan, 'pesan', contains('foreign key'))),
      );
    });

    test('11. Logika Murni Perhitungan Pengingat Cadangan (semua cabang)', () {
      final t0 = DateTime(2026, 11, 1, 10, 0);

      // Kasus A: Sedang ditunda
      final ditunda = t0.add(const Duration(days: 14));
      expect(
        perluIngatkanCadangan(
          sekarang: t0.add(const Duration(days: 5)),
          terakhirCadangan: null,
          jumlahTransaksi: 30,
          hariSejakDataPertama: 10,
          ditundaSampai: ditunda,
        ),
        isFalse,
      );

      // Kasus B: Belum pernah dicadangkan, transaksi >= 20 -> Ya
      expect(
        perluIngatkanCadangan(
          sekarang: t0,
          terakhirCadangan: null,
          jumlahTransaksi: 20,
          hariSejakDataPertama: 2,
        ),
        isTrue,
      );

      // Kasus C: Belum pernah dicadangkan, hari >= 7 -> Ya
      expect(
        perluIngatkanCadangan(
          sekarang: t0,
          terakhirCadangan: null,
          jumlahTransaksi: 5,
          hariSejakDataPertama: 7,
        ),
        isTrue,
      );

      // Kasus D: Belum pernah dicadangkan, data masih sedikit (<20 tx dan <7 hari) -> Tidak
      expect(
        perluIngatkanCadangan(
          sekarang: t0,
          terakhirCadangan: null,
          jumlahTransaksi: 10,
          hariSejakDataPertama: 4,
        ),
        isFalse,
      );

      // Kasus E: Pernah dicadangkan > 30 hari lalu dan ada transaksi baru -> Ya
      expect(
        perluIngatkanCadangan(
          sekarang: t0.add(const Duration(days: 35)),
          terakhirCadangan: t0,
          jumlahTransaksi: 50,
          hariSejakDataPertama: 40,
          adaTransaksiBaruSejakCadangan: true,
        ),
        isTrue,
      );

      // Kasus F: Pernah dicadangkan > 30 hari lalu tapi TIDAK ADA transaksi baru -> Tidak
      expect(
        perluIngatkanCadangan(
          sekarang: t0.add(const Duration(days: 35)),
          terakhirCadangan: t0,
          jumlahTransaksi: 50,
          hariSejakDataPertama: 40,
          adaTransaksiBaruSejakCadangan: false,
        ),
        isFalse,
      );

      // Kasus G: Pernah dicadangkan baru 10 hari lalu -> Tidak
      expect(
        perluIngatkanCadangan(
          sekarang: t0.add(const Duration(days: 10)),
          terakhirCadangan: t0,
          jumlahTransaksi: 50,
          hariSejakDataPertama: 20,
          adaTransaksiBaruSejakCadangan: true,
        ),
        isFalse,
      );
    });

    test('12. Berkas lebih dari 50 MB ditolak dengan galat ramah', () async {
      // Buat string dummy berukuran 51 MB secara efisien (atau tirukan string panjang)
      // Karena string 50MB di memori butuh ~100MB RAM, buat string buffer 50MB + 10 byte
      final buffer = StringBuffer('{"format": "');
      buffer.write('A' * (50 * 1024 * 1024 + 10));
      buffer.write('"}');
      final stringBesar = buffer.toString();

      expect(
        () => repositori.validasiDanBuatPratinjau(stringBesar),
        throwsA(isA<GalatCadangan>().having((e) => e.pesan, 'pesan', contains('melebihi batas maksimum 50 MB'))),
      );
    });

    test('13. Kategori bawaan tidak ganda setelah pemulihan', () async {
      // Hitung jumlah kategori awal sebelum ekspor
      final countAwal = (await db.customSelect('SELECT count(*) as c FROM tabel_kategori;').getSingle()).read<int>('c');
      expect(countAwal, greaterThan(0));

      final jsonStr = await repositori.eksporCadanganKeJson();
      final validasi = await repositori.validasiDanBuatPratinjau(jsonStr);

      // Pulihkan
      await repositori.pulihkanCadangan(validasi.dokumen, simpanKeselamatanOtomatis: false);

      // Hitung jumlah kategori setelah pemulihan
      final countAkhir = (await db.customSelect('SELECT count(*) as c FROM tabel_kategori;').getSingle()).read<int>('c');
      expect(countAkhir, equals(countAwal), reason: 'Kategori bawaan tidak boleh berganda setelah pemulihan!');
    });

    test('14. Pemulihan dari cadangan keselamatan otomatis (sebelum_pemulihan.json)', () async {
      // 1. Masukkan dompet Awal
      await db.customStatement(
        "INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) "
        "VALUES ('dompet-awal', 'Dompet Awal', 'tunai', 'wallet', 'tintHijau', 777000, 0, 0, datetime('now'));",
      );

      // Buat cadangan baru yang hanya memuat 'dompet-baru'
      final docBaru = await repositori.eksporCadangan();
      final tabelCopy = Map<String, List<Map<String, dynamic>>>.from(docBaru.tabel);
      tabelCopy['tabel_dompet'] = [
        {
          'id': 'dompet-baru',
          'nama': 'Dompet Baru',
          'jenis': 'tunai',
          'ikon': 'wallet',
          'warna': 'tintBiru',
          'saldo_awal_rupiah': 100000,
          'urutan': 0,
          'diarsipkan': 0,
          'dibuat_pada': DateTime.now().toIso8601String(),
        }
      ];
      final docModif = DokumenCadanganFunda(
        versiSkema: docBaru.versiSkema,
        versiAplikasi: docBaru.versiAplikasi,
        dibuatPada: DateTime.now().toUtc(),
        jumlahBaris: {'tabel_dompet': 1},
        checksum: hitungChecksumTabel(tabelCopy),
        tabel: tabelCopy,
      );

      // Eksekusi pemulihan dengan simpanKeselamatanOtomatis = true
      await repositori.pulihkanCadangan(docModif, simpanKeselamatanOtomatis: true);

      // Pastikan dompet-baru ada di DB
      final dompetBaruCek = await db.customSelect("SELECT * FROM tabel_dompet WHERE id = 'dompet-baru';").getSingle();
      expect(dompetBaruCek.read<String>('nama'), equals('Dompet Baru'));

      // Berkas keselamatan harus ada di tempDir
      final berkasKeselamatan = File('${tempDir.path}/sebelum_pemulihan.json');
      expect(berkasKeselamatan.existsSync(), isTrue);

      // Pulihkan KEMBALI dari berkas keselamatan
      final jsonKeselamatan = berkasKeselamatan.readAsStringSync();
      final validasiKeselamatan = await repositori.validasiDanBuatPratinjau(jsonKeselamatan);
      await repositori.pulihkanCadangan(validasiKeselamatan.dokumen, simpanKeselamatanOtomatis: false);

      // Dompet Awal harus kembali pulih!
      final dompetAwalPulih = await db.customSelect("SELECT * FROM tabel_dompet WHERE id = 'dompet-awal';").getSingle();
      expect(dompetAwalPulih.read<String>('nama'), equals('Dompet Awal'));
    });

    test('15. Deterministik terhadap urutan penyisipan (ORDER BY Primary Key)', () async {
      // Buat database 1 dengan insert urutan [id-3, id-1, id-2]
      final db1 = BasisDataFunda(NativeDatabase.memory());
      final repo1 = CadanganRepositori(db1);
      final t = DateTime.utc(2026, 11, 1, 10, 0);

      await db1.customStatement("INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) VALUES ('d-3', 'Dompet 3', 'tunai', 'wallet', 'tintHijau', 0, 0, 0, '${t.toIso8601String()}');");
      await db1.customStatement("INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) VALUES ('d-1', 'Dompet 1', 'tunai', 'wallet', 'tintHijau', 0, 0, 0, '${t.toIso8601String()}');");
      await db1.customStatement("INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) VALUES ('d-2', 'Dompet 2', 'tunai', 'wallet', 'tintHijau', 0, 0, 0, '${t.toIso8601String()}');");

      // Buat database 2 dengan insert urutan berbeda [id-1, id-2, id-3]
      final db2 = BasisDataFunda(NativeDatabase.memory());
      final repo2 = CadanganRepositori(db2);

      await db2.customStatement("INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) VALUES ('d-1', 'Dompet 1', 'tunai', 'wallet', 'tintHijau', 0, 0, 0, '${t.toIso8601String()}');");
      await db2.customStatement("INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) VALUES ('d-2', 'Dompet 2', 'tunai', 'wallet', 'tintHijau', 0, 0, 0, '${t.toIso8601String()}');");
      await db2.customStatement("INSERT INTO tabel_dompet (id, nama, jenis, ikon, warna, saldo_awal_rupiah, urutan, diarsipkan, dibuat_pada) VALUES ('d-3', 'Dompet 3', 'tunai', 'wallet', 'tintHijau', 0, 0, 0, '${t.toIso8601String()}');");

      final doc1 = await repo1.eksporCadangan(waktuDibuat: t);
      final doc2 = await repo2.eksporCadangan(waktuDibuat: t);

      // Checksum harus persis sama karena ORDER BY primary key
      expect(doc1.checksum, equals(doc2.checksum));

      await db1.close();
      await db2.close();
    });
  });
}
