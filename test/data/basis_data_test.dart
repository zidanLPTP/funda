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
    test(
      'skema versi 1 menginisialisasi tabel_pengaturan dengan benar',
      () async {
        expect(basisData.schemaVersion, equals(1));

        // Cek baca pengaturan yang belum ada
        final nilaiAwal = await basisData.bacaPengaturan('sudah_onboarding');
        expect(nilaiAwal, isNull);

        // Simpan pengaturan baru
        await basisData.simpanPengaturan('sudah_onboarding', 'true');
        final nilaiSetelahSimpan = await basisData.bacaPengaturan(
          'sudah_onboarding',
        );
        expect(nilaiSetelahSimpan, equals('true'));
      },
    );

    test(
      'memperbarui pengaturan yang sudah ada (insertOnConflictUpdate)',
      () async {
        await basisData.simpanPengaturan('tema', 'terang');
        expect(await basisData.bacaPengaturan('tema'), equals('terang'));

        // Ubah nilai dengan kunci yang sama
        await basisData.simpanPengaturan('tema', 'gelap');
        expect(await basisData.bacaPengaturan('tema'), equals('gelap'));

        // Pastikan baris data tidak berduplikasi
        final semua = await basisData.ambilSemuaPengaturan();
        expect(semua.where((p) => p.kunci == 'tema').length, equals(1));
      },
    );

    test('menghapus pengaturan berdasarkan kunci', () async {
      await basisData.simpanPengaturan('kunci_hapus', 'nilai');
      expect(await basisData.bacaPengaturan('kunci_hapus'), equals('nilai'));

      final jumlahTerhapus = await basisData.hapusPengaturan('kunci_hapus');
      expect(jumlahTerhapus, equals(1));
      expect(await basisData.bacaPengaturan('kunci_hapus'), isNull);
    });
  });

  group('Migrasi Bertingkat', () {
    test('migrasi onUpgrade aman dijalankan dan data tidak hilang', () async {
      // Simpan data di versi 1
      await basisData.simpanPengaturan('versi_db', '1.0');
      await basisData.simpanPengaturan('pengguna_nama', 'Fathin');

      // Simulasikan pemicuan onUpgrade
      final migrator = Migrator(basisData);
      await basisData.migration.onUpgrade(migrator, 1, 1);

      // Pastikan data tetap utuh setelah onUpgrade
      expect(await basisData.bacaPengaturan('versi_db'), equals('1.0'));
      expect(await basisData.bacaPengaturan('pengguna_nama'), equals('Fathin'));
    });

    test('migrasi aman diulang berkali-kali tanpa menimbulkan galat', () async {
      await basisData.simpanPengaturan('kunci_ulang', 'aman');

      final migrator = Migrator(basisData);
      // Ulangi panggilan upgrade beberapa kali
      await basisData.migration.onUpgrade(migrator, 1, 1);
      await basisData.migration.onUpgrade(migrator, 1, 1);
      await basisData.migration.onUpgrade(migrator, 1, 1);

      expect(await basisData.bacaPengaturan('kunci_ulang'), equals('aman'));
    });
  });
}
