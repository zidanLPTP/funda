import 'package:drift/drift.dart' hide isNull, isNotNull;
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
    test('skema versi 7 terdaftar pada basis data', () async {
      expect(basisData.schemaVersion, equals(7));

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

  group('Migrasi Bertingkat Skema v2 -> v3 (Tahap 3A)', () {
    test(
      'migrasi dari versi 2 ke versi 3 aman, membuat tabel baru, dan tidak menghapus data v2',
      () async {
        // Simulasikan data v2 (dompet)
        await basisData.tabelDompet.insertOne(
          TabelDompetCompanion.insert(
            id: 'dompet_v2',
            nama: 'Dompet Lama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: 'tintHijau',
            saldoAwalRupiah: const Value(100000),
            dibuatPada: Value(DateTime.now()),
          ),
        );

        // Jalankan migrasi v2 -> v3
        final migrator = Migrator(basisData);
        await basisData.migration.onUpgrade(migrator, 2, 3);

        // Verifikasi data dompet v2 tetap utuh
        final dompetLama = await (basisData.select(
          basisData.tabelDompet,
        )..where((d) => d.id.equals('dompet_v2'))).getSingleOrNull();
        expect(dompetLama, isNotNull);
        expect(dompetLama!.nama, equals('Dompet Lama'));

        // Verifikasi tabel baru (anggaran, tujuan, kantong, alokasi) bisa diakses
        final daftarAnggaran = await basisData
            .select(basisData.tabelAnggaran)
            .get();
        final daftarTujuan = await basisData
            .select(basisData.tabelTujuan)
            .get();
        final daftarKantong = await basisData
            .select(basisData.tabelKantong)
            .get();
        final daftarAlokasi = await basisData
            .select(basisData.tabelAlokasiKantong)
            .get();

        expect(daftarAnggaran, isEmpty);
        expect(daftarTujuan, isEmpty);
        expect(daftarKantong, isEmpty);
        expect(daftarAlokasi, isEmpty);
      },
    );

    test('migrasi v2 -> v3 aman diulang berkali-kali (idempoten)', () async {
      final migrator = Migrator(basisData);

      await basisData.migration.onUpgrade(migrator, 2, 3);
      await basisData.migration.onUpgrade(migrator, 2, 3);
      await basisData.migration.onUpgrade(migrator, 3, 3);

      final daftarTujuan = await basisData.select(basisData.tabelTujuan).get();
      expect(daftarTujuan, isEmpty);
    });
  });

  group('Migrasi Bertingkat Skema v3 -> v4 (Tahap 3B)', () {
    test(
      'migrasi dari versi 3 ke versi 4 aman, membuat tabel utang, pembayaran, dan penyesuaian tanpa menghapus data v3',
      () async {
        // Simulasikan data v3 (tujuan)
        await basisData.tabelTujuan.insertOne(
          TabelTujuanCompanion.insert(
            id: 'tujuan_v3',
            nama: 'Laptop Kerja',
            jenis: 'tujuan_besar',
            targetRupiah: 15000000,
            ikon: 'laptop',
            warna: 'biru',
            status: 'aktif',
            dibuatPada: DateTime.now(),
          ),
        );

        // Jalankan migrasi v3 -> v4
        final migrator = Migrator(basisData);
        await basisData.migration.onUpgrade(migrator, 3, 4);

        // Verifikasi data v3 tetap utuh
        final tujuanLama = await (basisData.select(
          basisData.tabelTujuan,
        )..where((t) => t.id.equals('tujuan_v3'))).getSingleOrNull();
        expect(tujuanLama, isNotNull);
        expect(tujuanLama!.nama, equals('Laptop Kerja'));

        // Verifikasi tabel baru v4 (utang, pembayaran_utang, penyesuaian_utang) bisa diakses
        final daftarUtang = await basisData.select(basisData.tabelUtang).get();
        final daftarPembayaran = await basisData
            .select(basisData.tabelPembayaranUtang)
            .get();
        final daftarPenyesuaian = await basisData
            .select(basisData.tabelPenyesuaianUtang)
            .get();

        expect(daftarUtang, isEmpty);
        expect(daftarPembayaran, isEmpty);
        expect(daftarPenyesuaian, isEmpty);
      },
    );

    test('migrasi v3 -> v4 aman diulang berkali-kali (idempoten)', () async {
      final migrator = Migrator(basisData);

      await basisData.migration.onUpgrade(migrator, 3, 4);
      await basisData.migration.onUpgrade(migrator, 3, 4);
      await basisData.migration.onUpgrade(migrator, 4, 4);

      final daftarUtang = await basisData.select(basisData.tabelUtang).get();
      expect(daftarUtang, isEmpty);
    });

    test(
      'Migrasi Bertingkat Skema v5 -> v6 aman, idempoten, dan menjaga data tagihan',
      () async {
        final migrator = Migrator(basisData);
        // Buat tabel sampai v5
        await migrator.createTable(basisData.tabelDompet);
        await migrator.createTable(basisData.tabelKategori);
        await basisData.migration.onUpgrade(migrator, 4, 5);

        // Masukkan data tagihan di v5
        final daftarKat = await basisData.select(basisData.tabelKategori).get();
        final katId = daftarKat.first.id;
        final waktuDibuat = DateTime(2026, 3, 10);
        await basisData
            .into(basisData.tabelTagihan)
            .insert(
              TabelTagihanCompanion.insert(
                id: 'tag_test_v5',
                nama: 'Spotify Premium',
                jenis: 'langganan',
                jumlahPerkiraanRupiah: const Value(54990),
                kategoriId: katId,
                frekuensi: 'bulanan',
                jatuhTempoPertama: waktuDibuat,
                dibuatPada: waktuDibuat,
              ),
            );

        // Jalankan migrasi v5 -> v6
        await basisData.migration.onUpgrade(migrator, 5, 6);

        // Verifikasi data tagihan v5 tetap utuh
        final tagihan = await (basisData.select(
          basisData.tabelTagihan,
        )..where((t) => t.id.equals('tag_test_v5'))).getSingleOrNull();
        expect(tagihan, isNotNull);
        expect(tagihan!.nama, equals('Spotify Premium'));
        expect(tagihan.jumlahPerkiraanRupiah, equals(54990));
        expect(tagihan.jatuhTempoPertama, equals(waktuDibuat));

        // Jalankan lagi (idempoten)
        await basisData.migration.onUpgrade(migrator, 5, 6);
      },
    );

    test(
      'Migrasi Bertingkat Skema v6 -> v7 aman, idempoten, dan membuat tabel belajar',
      () async {
        final migrator = Migrator(basisData);

        // Jalankan migrasi v6 -> v7
        await basisData.migration.onUpgrade(migrator, 6, 7);

        // Uji insert pada tabel progres pelajaran
        final waktu = DateTime.now();
        await basisData.into(basisData.tabelProgresPelajaran).insert(
              TabelProgresPelajaranCompanion.insert(
                pelajaranId: 'anggaran_arus_kas_1_2',
                modulId: 'anggaran_arus_kas',
                status: 'selesai',
                indeksLangkah: const Value(2),
                dibuatPada: waktu,
                selesaiPada: Value(waktu),
              ),
            );

        final hasilProgres = await (basisData.select(basisData.tabelProgresPelajaran)
              ..where((p) => p.pelajaranId.equals('anggaran_arus_kas_1_2')))
            .getSingleOrNull();
        expect(hasilProgres, isNotNull);
        expect(hasilProgres!.status, equals('selesai'));

        // Jalankan lagi (idempoten)
        await basisData.migration.onUpgrade(migrator, 6, 7);
      },
    );
  });
}
