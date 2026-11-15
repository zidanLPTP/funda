import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';

void main() {
  late BasisDataFunda basisData;

  setUp(() {
    // Gunakan in-memory database untuk setiap test
    basisData = BasisDataFunda(NativeDatabase.memory());
  });

  tearDown(() async {
    await basisData.close();
  });

  group('BasisDataFunda & TabelPengaturan', () {
    test('skema versi 2 terdaftar pada basis data', () async {
      expect(basisData.schemaVersion, equals(2));

      final nilaiAwal = await basisData.bacaPengaturan('sudah_onboarding');
      expect(nilaiAwal, isNull);

      await basisData.simpanPengaturan('sudah_onboarding', 'true');
      final nilaiSetelahSimpan = await basisData.bacaPengaturan(
        'sudah_onboarding',
      );
      expect(nilaiSetelahSimpan, equals('true'));
    });

    test(
      'memperbarui pengaturan yang sudah ada (insertOnConflictUpdate)',
      () async {
        await basisData.simpanPengaturan('tema', 'terang');
        expect(await basisData.bacaPengaturan('tema'), equals('terang'));

        await basisData.simpanPengaturan('tema', 'gelap');
        expect(await basisData.bacaPengaturan('tema'), equals('gelap'));

        final semua = await basisData.ambilSemuaPengaturan();
        expect(semua.where((p) => p.kunci == 'tema').length, equals(1));
      },
    );

    test('menghapus pengaturan berdasarkan kunci', () async {
      await basisData.simpanPengaturan('kunci_hapus', 'nilai');
      final jumlahTerhapus = await basisData.hapusPengaturan('kunci_hapus');
      expect(jumlahTerhapus, equals(1));
      expect(await basisData.bacaPengaturan('kunci_hapus'), isNull);
    });
  });

  group('Kategori Bawaan & Inisialisasi', () {
    test(
      'kategori bawaan otomatis ter-seed saat inisialisasi basis data',
      () async {
        final daftar = await basisData.select(basisData.tabelKategori).get();

        // Total ada 25 kategori bawaan (5 masuk, 8 kebutuhan, 3 keinginan, 4 belum dilabeli, 2 tabungan, 3 utang)
        expect(daftar.length, equals(25));

        // Verifikasi kategori masuk sifatnya tidak_berlaku
        final kategoriMasuk = daftar.where((k) => k.arus == 'masuk');
        expect(kategoriMasuk.length, equals(5));
        for (final k in kategoriMasuk) {
          expect(k.sifat, equals('tidak_berlaku'));
          expect(k.bawaan, isTrue);
        }

        // Verifikasi kategori keluar memiliki sifat yang valid
        final kategoriKeluar = daftar.where((k) => k.arus == 'keluar');
        expect(kategoriKeluar.length, equals(20));
        for (final k in kategoriKeluar) {
          expect([
            'kebutuhan',
            'keinginan',
            'tabungan',
            'utang',
            'belum_dilabeli',
          ], contains(k.sifat));
        }
      },
    );
  });

  group('Migrasi Bertingkat Skema v1 -> v2', () {
    test(
      'migrasi dari versi 1 ke versi 2 aman dan tidak menghapus data pengaturan',
      () async {
        // Simulasikan database dengan pengaturan awal
        await basisData.simpanPengaturan('pengguna_nama', 'Fathin');
        await basisData.simpanPengaturan('versi_aplikasi', '0.1.0');

        // Jalankan onUpgrade dari versi 1 ke versi 2
        final migrator = Migrator(basisData);
        await basisData.migration.onUpgrade(migrator, 1, 2);

        // Pastikan data v1 tidak hilang
        expect(
          await basisData.bacaPengaturan('pengguna_nama'),
          equals('Fathin'),
        );
        expect(
          await basisData.bacaPengaturan('versi_aplikasi'),
          equals('0.1.0'),
        );

        // Pastikan kategori bawaan tersedia
        final daftarKategori = await basisData
            .select(basisData.tabelKategori)
            .get();
        expect(daftarKategori.length, equals(25));
      },
    );

    test(
      'migrasi aman diulang berkali-kali tanpa duplikasi kategori (idempoten)',
      () async {
        final migrator = Migrator(basisData);

        // Panggil onUpgrade beberapa kali
        await basisData.migration.onUpgrade(migrator, 1, 2);
        await basisData.migration.onUpgrade(migrator, 1, 2);
        await basisData.migration.onUpgrade(migrator, 2, 2);

        final daftarKategori = await basisData
            .select(basisData.tabelKategori)
            .get();
        expect(daftarKategori.length, equals(25));
      },
    );
  });
}
