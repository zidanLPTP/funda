import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';

void main() {
  group(
    'Langkah 0(d): Uji Migrasi Beruntun Bertingkat (v1 -> v2 -> v3 -> v4 -> v5 -> v6 -> v7 -> v8 -> v9)',
    () {
      late BasisDataFunda basisData;
      late Migrator migrator;

      setUp(() {
        basisData = BasisDataFunda(NativeDatabase.memory());
        migrator = Migrator(basisData);
      });

      tearDown(() async {
        await basisData.close();
      });

      test(
        'Semua data dari setiap versi lama tetap utuh saat migrasi bertingkat dijalankan berurutan',
        () async {
          // -------------------------------------------------------------
          // 1. TAHAP SKEMA v1
          // -------------------------------------------------------------
          await migrator.createTable(basisData.tabelPengaturan);
          await basisData.simpanPengaturan('pengguna_nama', 'Budi Santoso');
          await basisData.simpanPengaturan('versi_pertama', '1.0.0');

          expect(
            await basisData.bacaPengaturan('pengguna_nama'),
            equals('Budi Santoso'),
          );

          // -------------------------------------------------------------
          // 2. MIGRASI v1 -> v2
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 1, 2);

          // Isi data v2 (dompet & transaksi)
          final waktuV2 = DateTime(2026, 1, 15, 10, 0);
          await basisData
              .into(basisData.tabelDompet)
              .insert(
                TabelDompetCompanion.insert(
                  id: 'dmp_v2',
                  nama: 'BCA Tabungan',
                  jenis: 'rekening_bank',
                  ikon: 'bank',
                  warna: 'tintBiru',
                  saldoAwalRupiah: const Value(5000000),
                  dibuatPada: Value(waktuV2),
                ),
              );

          final daftarKategori = await basisData
              .select(basisData.tabelKategori)
              .get();
          expect(
            daftarKategori.length,
            equals(25),
            reason: 'Kategori bawaan harus otomatis ter-seed di v2',
          );

          final katMakan = daftarKategori
              .firstWhere((k) => k.arus == 'keluar')
              .id;
          await basisData
              .into(basisData.tabelTransaksi)
              .insert(
                TabelTransaksiCompanion.insert(
                  id: 'tx_v2',
                  jenis: 'keluar',
                  jumlahRupiah: 50000,
                  dompetId: 'dmp_v2',
                  kategoriId: Value(katMakan),
                  waktuTransaksi: waktuV2,
                  dibuatPada: Value(waktuV2),
                  diubahPada: Value(waktuV2),
                ),
              );

          // -------------------------------------------------------------
          // 3. MIGRASI v2 -> v3
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 2, 3);

          // Isi data v3 (tujuan finansial & kantong dompet)
          final waktuV3 = DateTime(2026, 2, 1, 12, 0);
          await basisData
              .into(basisData.tabelTujuan)
              .insert(
                TabelTujuanCompanion.insert(
                  id: 'tuj_v3',
                  nama: 'Dana Liburan',
                  jenis: 'tabungan',
                  targetRupiah: 10000000,
                  status: 'aktif',
                  ikon: 'plane',
                  warna: 'tintHijau',
                  dibuatPada: waktuV3,
                ),
              );
          await basisData
              .into(basisData.tabelKantong)
              .insert(
                TabelKantongCompanion.insert(
                  id: 'ktg_v3',
                  nama: 'Pos Liburan',
                  dompetId: 'dmp_v2',
                  tujuanId: const Value('tuj_v3'),
                  ikon: 'plane',
                  warna: 'tintHijau',
                  dibuatPada: waktuV3,
                ),
              );

          // -------------------------------------------------------------
          // 4. MIGRASI v3 -> v4
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 3, 4);

          // Isi data v4 (utang)
          final waktuV4 = DateTime(2026, 3, 1, 9, 0);
          await basisData
              .into(basisData.tabelUtang)
              .insert(
                TabelUtangCompanion.insert(
                  id: 'utg_v4',
                  nama: 'Cicilan Laptop Kerja',
                  jenis: 'paylater',
                  sisaAwalRupiah: 12000000,
                  pokokAwalRupiah: const Value(12000000),
                  jenisBunga: 'tetap',
                  tenorBulan: const Value(12),
                  cicilanBulananRupiah: const Value(1000000),
                  tanggalJatuhTempoBulanan: const Value(10),
                  dibuatPada: waktuV4,
                ),
              );

          // -------------------------------------------------------------
          // 5. MIGRASI v4 -> v5
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 4, 5);

          // Isi data v5 (tagihan & langganan)
          final waktuV5 = DateTime(2026, 4, 1, 8, 0);
          await basisData
              .into(basisData.tabelTagihan)
              .insert(
                TabelTagihanCompanion.insert(
                  id: 'tag_v5',
                  nama: 'Internet Rumah Indihome',
                  jenis: 'tagihan',
                  kategoriId: katMakan,
                  dompetId: const Value('dmp_v2'),
                  frekuensi: 'bulanan',
                  jatuhTempoPertama: waktuV5,
                  dibuatPada: waktuV5,
                ),
              );

          // -------------------------------------------------------------
          // 6. MIGRASI v5 -> v6 (Tahap 3C-R: Jatuh Tempo Pertama, Berakhir Pada, Opsional Nominal)
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 5, 6);

          // Masukkan tagihan v6 dengan nominal fluktuatif (null) dan batas berakhir
          final waktuV6 = DateTime(2026, 4, 1);
          final batasAkhirV6 = DateTime(2026, 12, 31);
          await basisData
              .into(basisData.tabelTagihan)
              .insert(
                TabelTagihanCompanion.insert(
                  id: 'tag_v6',
                  nama: 'Listrik Pasca Bayar',
                  jenis: 'tagihan',
                  jumlahPerkiraanRupiah: const Value(null),
                  kategoriId: katMakan,
                  frekuensi: 'bulanan',
                  jatuhTempoPertama: waktuV6,
                  berakhirPada: Value(batasAkhirV6),
                  dibuatPada: waktuV6,
                ),
              );

          // -------------------------------------------------------------
          // 7. MIGRASI v6 -> v7 (Tahap 4 - Mesin Belajar)
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 6, 7);

          final waktuV7 = DateTime(2026, 4, 1, 9, 0);
          await basisData.into(basisData.tabelProgresPelajaran).insert(
                TabelProgresPelajaranCompanion.insert(
                  pelajaranId: 'anggaran_arus_kas_1_2',
                  modulId: 'anggaran_arus_kas',
                  status: 'selesai',
                  indeksLangkah: const Value(3),
                  dibuatPada: waktuV7,
                  selesaiPada: Value(waktuV7.add(const Duration(minutes: 5))),
                ),
              );

          await basisData.into(basisData.tabelHasilMisi).insert(
                TabelHasilMisiCompanion.insert(
                  misiId: 'anggaran_arus_kas_1_2',
                  pelajaranId: 'anggaran_arus_kas_1_2',
                  tipe: 'ada_data',
                  status: 'selesai',
                  selesaiPada: waktuV7.add(const Duration(minutes: 4)),
                ),
              );

          await basisData.into(basisData.tabelHasilKuis).insert(
                TabelHasilKuisCompanion.insert(
                  modulId: 'anggaran_arus_kas',
                  benar: 4,
                  total: 5,
                  skorPersen: 80,
                  lulus: true,
                  waktu: waktuV7.add(const Duration(minutes: 10)),
                ),
              );

          await basisData.into(basisData.tabelPernyataan).insert(
                TabelPernyataanCompanion.insert(
                  kunci: 'tidak_punya_utang',
                  nilai: 'true',
                  diubahPada: waktuV7,
                ),
              );

          // -------------------------------------------------------------
          // 8. MIGRASI v7 -> v8 (Optimasi Indeks Kueri)
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 7, 8);

          // Verifikasi indeks baru v8 berhasil terbuat
          final indexRes = await basisData.customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_transaksi_%';",
          ).get();
          final daftarIndex = indexRes.map((r) => r.read<String>('name')).toSet();
          expect(daftarIndex.contains('idx_transaksi_jenis'), isTrue);
          expect(daftarIndex.contains('idx_transaksi_jenis_kategori'), isTrue);
          expect(daftarIndex.contains('idx_transaksi_waktu_id'), isTrue);
          expect(daftarIndex.contains('idx_transaksi_waktu_jenis'), isTrue);

          // -------------------------------------------------------------
          // 9. MIGRASI v8 -> v9 (Tahap 5 - Profil Keuangan & Hasil Tes Awal)
          // -------------------------------------------------------------
          await basisData.migration.onUpgrade(migrator, 8, 9);

          // Isi data v9
          final waktuV9 = DateTime(2026, 3, 15, 14, 0);
          await basisData.into(basisData.tabelProfilKeuangan).insert(
                TabelProfilKeuanganCompanion.insert(
                  punyaPenghasilan: 'rutin',
                  punyaUtang: 'ya',
                  danaDarurat: 'sedikit',
                  menabung: 'kadang',
                  investasi: 'belum',
                  mencatatKeuangan: 'rutin',
                  tujuanUtama: const Value('Membeli rumah impian'),
                  diisiPada: waktuV9,
                  diperbaruiPada: waktuV9,
                ),
              );

          await basisData.into(basisData.tabelHasilTesAwal).insert(
                TabelHasilTesAwalCompanion.insert(
                  waktu: waktuV9,
                  jawabanJson: '{"soal_1": 1}',
                  skorPerModulJson: '{"anggaran_arus_kas": 100}',
                  skorTotalPersen: 85,
                ),
              );

          // Verifikasi indeks baru v9
          final indexTesAwalRes = await basisData.customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name = 'idx_hasil_tes_awal_waktu';",
          ).get();
          expect(indexTesAwalRes.length, equals(1));

          // -------------------------------------------------------------
          // VERIFIKASI KEUTUHAN DATA KESELURUHAN SETELAH v9
          // -------------------------------------------------------------

          // 1. Data v1 (pengaturan) utuh
          expect(
            await basisData.bacaPengaturan('pengguna_nama'),
            equals('Budi Santoso'),
          );
          expect(
            await basisData.bacaPengaturan('versi_pertama'),
            equals('1.0.0'),
          );

          // 2. Data v2 (dompet & transaksi) utuh
          final dompet = await (basisData.select(
            basisData.tabelDompet,
          )..where((d) => d.id.equals('dmp_v2'))).getSingleOrNull();
          expect(dompet, isNotNull);
          expect(dompet!.nama, equals('BCA Tabungan'));
          expect(dompet.saldoAwalRupiah, equals(5000000));

          final transaksi = await (basisData.select(
            basisData.tabelTransaksi,
          )..where((t) => t.id.equals('tx_v2'))).getSingleOrNull();
          expect(transaksi, isNotNull);
          expect(transaksi!.jumlahRupiah, equals(50000));

          // 3. Data v3 (tujuan & kantong) utuh
          final tujuan = await (basisData.select(
            basisData.tabelTujuan,
          )..where((t) => t.id.equals('tuj_v3'))).getSingleOrNull();
          expect(tujuan, isNotNull);
          expect(tujuan!.nama, equals('Dana Liburan'));

          final kantong = await (basisData.select(
            basisData.tabelKantong,
          )..where((k) => k.id.equals('ktg_v3'))).getSingleOrNull();
          expect(kantong, isNotNull);
          expect(kantong!.nama, equals('Pos Liburan'));

          // 4. Data v4 (utang) utuh
          final utang = await (basisData.select(
            basisData.tabelUtang,
          )..where((u) => u.id.equals('utg_v4'))).getSingleOrNull();
          expect(utang, isNotNull);
          expect(utang!.nama, equals('Cicilan Laptop Kerja'));
          expect(utang.sisaAwalRupiah, equals(12000000));

          // 5. Data v5 (tagihan & pengaturan bawaan pengingat) utuh
          final tagihanV5 = await (basisData.select(
            basisData.tabelTagihan,
          )..where((t) => t.id.equals('tag_v5'))).getSingleOrNull();
          expect(tagihanV5, isNotNull);
          expect(tagihanV5!.nama, equals('Internet Rumah Indihome'));
          expect(tagihanV5.jatuhTempoPertama, equals(waktuV5));

          // 6. Data v6 tersimpan dengan baik
          final tagihanV6 = await (basisData.select(
            basisData.tabelTagihan,
          )..where((t) => t.id.equals('tag_v6'))).getSingleOrNull();
          expect(tagihanV6, isNotNull);
          expect(tagihanV6!.nama, equals('Listrik Pasca Bayar'));
          expect(tagihanV6.jumlahPerkiraanRupiah, isNull);
          expect(tagihanV6.berakhirPada, equals(batasAkhirV6));

          // 7. Data v7 (progres pelajaran, misi, kuis, pernyataan) tersimpan utuh
          final progres = await (basisData.select(basisData.tabelProgresPelajaran)
                ..where((p) => p.pelajaranId.equals('anggaran_arus_kas_1_2')))
              .getSingleOrNull();
          expect(progres, isNotNull);
          expect(progres!.status, equals('selesai'));
          expect(progres.indeksLangkah, equals(3));

          final misi = await (basisData.select(basisData.tabelHasilMisi)
                ..where((m) => m.misiId.equals('anggaran_arus_kas_1_2')))
              .getSingleOrNull();
          expect(misi, isNotNull);
          expect(misi!.status, equals('selesai'));

          final kuisList = await (basisData.select(basisData.tabelHasilKuis)
                ..where((k) => k.modulId.equals('anggaran_arus_kas')))
              .get();
          expect(kuisList.length, equals(1));
          expect(kuisList.first.skorPersen, equals(80));
          expect(kuisList.first.lulus, isTrue);

          final pernyataan = await (basisData.select(basisData.tabelPernyataan)
                ..where((p) => p.kunci.equals('tidak_punya_utang')))
              .getSingleOrNull();
          expect(pernyataan, isNotNull);
          expect(pernyataan!.nilai, equals('true'));

          // Verifikasi pengaturan default pengingat terinisialisasi di v5/v6
          expect(
            await basisData.bacaPengaturan('pengingat_aktif'),
            equals('false'),
          );
          expect(
            await basisData.bacaPengaturan('jam_pengingat'),
            equals('09:00'),
          );
          expect(
            await basisData.bacaPengaturan('tampilkan_nominal_di_pengingat'),
            equals('false'),
          );

          // 8. Data v9 (profil keuangan & hasil tes awal) utuh
          final profil = await basisData
              .select(basisData.tabelProfilKeuangan)
              .getSingleOrNull();
          expect(profil, isNotNull);
          expect(profil!.punyaPenghasilan, equals('rutin'));
          expect(profil.punyaUtang, equals('ya'));
          expect(profil.tujuanUtama, equals('Membeli rumah impian'));

          final hasilTes = await basisData
              .select(basisData.tabelHasilTesAwal)
              .getSingleOrNull();
          expect(hasilTes, isNotNull);
          expect(hasilTes!.skorTotalPersen, equals(85));
          expect(hasilTes.skorPerModulJson, contains('anggaran_arus_kas'));
        },
      );
    },
  );
}
