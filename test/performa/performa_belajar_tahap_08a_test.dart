// ignore_for_file: avoid_print
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';

void main() {
  group('Performa & Kesetaraan Agregasi SQL Tahap 8A (Modul 2 & 3)', () {
    late BasisDataFunda db;
    late FotoDataRepositori repo;

    setUp(() async {
      db = BasisDataFunda(NativeDatabase.memory());
      repo = FotoDataRepositori(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> isiDataDummy(DateTime now) async {
      // 1. Data Dompet
      await db
          .into(db.tabelDompet)
          .insert(
            TabelDompetCompanion.insert(
              id: 'dompet_1',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'dompet',
              warna: 'hijau',
            ),
          );

      // 2. Data Kategori (Kebutuhan & Keinginan)
      await db
          .into(db.tabelKategori)
          .insert(
            TabelKategoriCompanion.insert(
              id: 'kat_makan',
              nama: 'Makan',
              arus: 'keluar',
              sifat: 'kebutuhan',
              ikon: 'makan',
            ),
          );
      await db
          .into(db.tabelKategori)
          .insert(
            TabelKategoriCompanion.insert(
              id: 'kat_kos',
              nama: 'Kos',
              arus: 'keluar',
              sifat: 'kebutuhan',
              ikon: 'rumah',
            ),
          );
      await db
          .into(db.tabelKategori)
          .insert(
            TabelKategoriCompanion.insert(
              id: 'kat_jajan',
              nama: 'Jajan',
              arus: 'keluar',
              sifat: 'keinginan',
              ikon: 'jajan',
            ),
          );

      // 3. Data Transaksi Pengeluaran
      await db
          .into(db.tabelTransaksi)
          .insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_1',
              dompetId: 'dompet_1',
              kategoriId: const Value('kat_makan'),
              jenis: 'keluar',
              jumlahRupiah: 50000,
              waktuTransaksi: now,
            ),
          );
      await db
          .into(db.tabelTransaksi)
          .insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_2',
              dompetId: 'dompet_1',
              kategoriId: const Value('kat_kos'),
              jenis: 'keluar',
              jumlahRupiah: 800000,
              waktuTransaksi: now.subtract(const Duration(hours: 1)),
            ),
          );
      await db
          .into(db.tabelTransaksi)
          .insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_3',
              dompetId: 'dompet_1',
              kategoriId: const Value(
                'kat_jajan',
              ), // Keinginan -> tidak dihitung sebagai kebutuhan
              jenis: 'keluar',
              jumlahRupiah: 25000,
              waktuTransaksi: now.subtract(const Duration(hours: 2)),
            ),
          );
      await db
          .into(db.tabelTransaksi)
          .insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_4',
              dompetId: 'dompet_1',
              kategoriId: const Value('kat_makan'),
              jenis: 'keluar',
              jumlahRupiah: 30000,
              waktuTransaksi: now.subtract(const Duration(hours: 3)),
            ),
          );

      // 4. Data Tujuan (Tabungan & Dana Darurat)
      await db
          .into(db.tabelTujuan)
          .insert(
            TabelTujuanCompanion.insert(
              id: 'tujuan_tab_1',
              nama: 'Laptop Skripsi',
              jenis: 'tabungan',
              status: 'aktif',
              targetRupiah: 6000000,
              ikon: 'laptop',
              warna: 'biru',
              dibuatPada: now,
            ),
          );
      await db
          .into(db.tabelTujuan)
          .insert(
            TabelTujuanCompanion.insert(
              id: 'tujuan_tab_2',
              nama: 'Liburan',
              jenis: 'tabungan',
              status: 'tercapai',
              targetRupiah: 2000000,
              ikon: 'koper',
              warna: 'kuning',
              dibuatPada: now.subtract(const Duration(days: 10)),
            ),
          );
      await db
          .into(db.tabelTujuan)
          .insert(
            TabelTujuanCompanion.insert(
              id: 'tujuan_tab_batal',
              nama: 'Tujuan Batal',
              jenis: 'tabungan',
              status: 'dibatalkan', // Tidak boleh dihitung
              targetRupiah: 1000000,
              ikon: 'silang',
              warna: 'abu',
              dibuatPada: now.subtract(const Duration(days: 20)),
            ),
          );
      await db
          .into(db.tabelTujuan)
          .insert(
            TabelTujuanCompanion.insert(
              id: 'tujuan_darurat_1',
              nama: 'Dana Darurat Utama',
              jenis: 'dana_darurat',
              status: 'aktif',
              targetRupiah: 5700000,
              ikon: 'tameng',
              warna: 'merah',
              dibuatPada: now,
            ),
          );

      // 5. Data Kantong & Alokasi
      await db
          .into(db.tabelKantong)
          .insert(
            TabelKantongCompanion.insert(
              id: 'kantong_tab_1',
              nama: 'Kantong Laptop',
              dompetId: 'dompet_1',
              tujuanId: const Value('tujuan_tab_1'),
              ikon: 'kantong',
              warna: 'biru',
              dibuatPada: now,
            ),
          );
      await db
          .into(db.tabelKantong)
          .insert(
            TabelKantongCompanion.insert(
              id: 'kantong_darurat_1',
              nama: 'Kantong Darurat',
              dompetId: 'dompet_1',
              tujuanId: const Value('tujuan_darurat_1'),
              ikon: 'tameng',
              warna: 'merah',
              dibuatPada: now,
            ),
          );

      // Alokasi isi tabungan (2 isi, 1 ambil)
      await db
          .into(db.tabelAlokasiKantong)
          .insert(
            TabelAlokasiKantongCompanion.insert(
              id: 'alokasi_1',
              kantongId: 'kantong_tab_1',
              jenis: 'isi',
              jumlahRupiah: 500000,
              waktu: now,
              dibuatPada: now,
            ),
          );
      await db
          .into(db.tabelAlokasiKantong)
          .insert(
            TabelAlokasiKantongCompanion.insert(
              id: 'alokasi_2',
              kantongId: 'kantong_tab_1',
              jenis: 'isi',
              jumlahRupiah: 300000,
              waktu: now,
              dibuatPada: now,
            ),
          );
      await db
          .into(db.tabelAlokasiKantong)
          .insert(
            TabelAlokasiKantongCompanion.insert(
              id: 'alokasi_3',
              kantongId: 'kantong_tab_1',
              jenis: 'ambil', // Tidak dihitung sebagai isi
              jumlahRupiah: 100000,
              waktu: now,
              dibuatPada: now,
            ),
          );

      // Alokasi isi dana darurat (1 isi)
      await db
          .into(db.tabelAlokasiKantong)
          .insert(
            TabelAlokasiKantongCompanion.insert(
              id: 'alokasi_darurat_1',
              kantongId: 'kantong_darurat_1',
              jenis: 'isi',
              jumlahRupiah: 1000000,
              waktu: now,
              dibuatPada: now,
            ),
          );
    }

    test(
      'Kesetaraan Agregasi SQL FotoDataRepositori vs Komputasi Murni Dart untuk 5 Objek Baru',
      () async {
        final now = DateTime.now();
        await isiDataDummy(now);

        // Ambil foto data via SQL agregasi
        final foto = await repo.ambilFotoData();

        // Hitung manual dengan kueri murni Dart
        final semuaTujuan = await db.select(db.tabelTujuan).get();
        final hitungTujuanTabungan = semuaTujuan
            .where(
              (t) =>
                  t.jenis == 'tabungan' &&
                  (t.status == 'aktif' || t.status == 'tercapai'),
            )
            .length;
        final hitungTujuanDarurat = semuaTujuan
            .where(
              (t) =>
                  t.jenis == 'dana_darurat' &&
                  (t.status == 'aktif' || t.status == 'tercapai'),
            )
            .length;

        final semuaAlokasi = await db.select(db.tabelAlokasiKantong).get();
        final semuaKantong = await db.select(db.tabelKantong).get();
        final petaKantongKeTujuan = {
          for (final k in semuaKantong) k.id: k.tujuanId,
        };
        final petaTujuanJenis = {for (final t in semuaTujuan) t.id: t.jenis};

        var hitungIsiTabungan = 0;
        var hitungIsiDarurat = 0;
        for (final a in semuaAlokasi) {
          if (a.jenis == 'isi') {
            final tId = petaKantongKeTujuan[a.kantongId];
            final jenis = petaTujuanJenis[tId];
            if (jenis == 'tabungan') hitungIsiTabungan++;
            if (jenis == 'dana_darurat') hitungIsiDarurat++;
          }
        }

        final semuaTx = await db.select(db.tabelTransaksi).get();
        final semuaKat = await db.select(db.tabelKategori).get();
        final petaKatSifat = {for (final k in semuaKat) k.id: k.sifat};
        var hitungKebutuhan = 0;
        for (final tx in semuaTx) {
          if (tx.jenis == 'keluar' &&
              petaKatSifat[tx.kategoriId] == 'kebutuhan') {
            hitungKebutuhan++;
          }
        }

        // Verifikasi kesetaraan 100%
        expect(
          foto.jumlahTujuanTabungan,
          equals(hitungTujuanTabungan),
          reason: 'jumlahTujuanTabungan harus sama persis',
        );
        expect(foto.jumlahTujuanTabungan, equals(2));

        expect(
          foto.jumlahIsiTujuanTabungan,
          equals(hitungIsiTabungan),
          reason: 'jumlahIsiTujuanTabungan harus sama persis',
        );
        expect(foto.jumlahIsiTujuanTabungan, equals(2));

        expect(
          foto.jumlahPengeluaranKebutuhan,
          equals(hitungKebutuhan),
          reason: 'jumlahPengeluaranKebutuhan harus sama persis',
        );
        expect(foto.jumlahPengeluaranKebutuhan, equals(3));

        expect(
          foto.jumlahTujuanDanaDarurat,
          equals(hitungTujuanDarurat),
          reason: 'jumlahTujuanDanaDarurat harus sama persis',
        );
        expect(foto.jumlahTujuanDanaDarurat, equals(1));

        expect(
          foto.jumlahIsiDanaDarurat,
          equals(hitungIsiDarurat),
          reason: 'jumlahIsiDanaDarurat harus sama persis',
        );
        expect(foto.jumlahIsiDanaDarurat, equals(1));
      },
    );

    test(
      'Tujuan tabungan dan dana darurat berstatus "tercapai" tetap dihitung dan membuka gerbang 3.3',
      () async {
        final now = DateTime.now();
        await isiDataDummy(now);

        // Ubah status tujuan dana darurat menjadi tercapai
        await (db.update(db.tabelTujuan)
              ..where((t) => t.id.equals('tujuan_darurat_1')))
            .write(const TabelTujuanCompanion(status: Value('tercapai')));

        final foto = await repo.ambilFotoData();

        // (i) Tujuan tabungan tercapai tetap dihitung
        expect(foto.jumlahTujuanTabungan, equals(2)); // 1 aktif + 1 tercapai

        // (ii) Tujuan dana darurat tercapai tetap dihitung
        expect(foto.jumlahTujuanDanaDarurat, equals(1)); // 1 tercapai

        // (iii) Gerbang pelajaran 3.3 tetap terbuka
        const syaratPelajaran33 = SyaratGerbangData(
          tipe: 'ada_data',
          objek: 'tujuan_dana_darurat',
          min: 1,
          pesan: 'Buat minimal 1 tujuan dana darurat',
        );
        final hasilEvaluasi = evaluasiSyarat(syaratPelajaran33, foto);
        expect(
          hasilEvaluasi.terpenuhi,
          isTrue,
          reason:
              'Pelajaran 3.3 wajib terbuka saat tujuan dana darurat berstatus tercapai',
        );

        // (iv) isi_* tidak bergantung pada status tujuan
        expect(foto.jumlahIsiDanaDarurat, equals(1));
        expect(foto.jumlahIsiTujuanTabungan, equals(2));
      },
    );

    test('EXPLAIN QUERY PLAN untuk 5 subkueri baru Foto Data Pengguna', () async {
      Future<List<String>> explain(String sql) async {
        final rows = await db.customSelect('EXPLAIN QUERY PLAN $sql').get();
        return rows.map((r) => r.read<String>('detail')).toList();
      }

      final eqp1 = await explain(
        "SELECT COUNT(*) FROM tabel_tujuan WHERE jenis = 'tabungan' AND status IN ('aktif', 'tercapai')",
      );
      print('EQP jml_tujuan_tabungan: ${eqp1.join(" | ")}');

      final eqp2 = await explain(
        "SELECT COUNT(*) FROM tabel_alokasi_kantong a JOIN tabel_kantong k ON a.kantong_id = k.id JOIN tabel_tujuan t ON k.tujuan_id = t.id WHERE a.jenis = 'isi' AND t.jenis = 'tabungan'",
      );
      print('EQP jml_isi_tujuan_tabungan: ${eqp2.join(" | ")}');

      final eqp3 = await explain(
        "SELECT COUNT(*) FROM tabel_transaksi t JOIN tabel_kategori k ON t.kategori_id = k.id WHERE t.jenis = 'keluar' AND k.sifat = 'kebutuhan'",
      );
      print('EQP jml_pengeluaran_kebutuhan: ${eqp3.join(" | ")}');

      final eqp4 = await explain(
        "SELECT COUNT(*) FROM tabel_tujuan WHERE jenis = 'dana_darurat' AND status IN ('aktif', 'tercapai')",
      );
      print('EQP jml_tujuan_dana_darurat: ${eqp4.join(" | ")}');

      final eqp5 = await explain(
        "SELECT COUNT(*) FROM tabel_alokasi_kantong a JOIN tabel_kantong k ON a.kantong_id = k.id JOIN tabel_tujuan t ON k.tujuan_id = t.id WHERE a.jenis = 'isi' AND t.jenis = 'dana_darurat'",
      );
      print('EQP jml_isi_dana_darurat: ${eqp5.join(" | ")}');

      expect(eqp1, isNotEmpty);
      expect(eqp2, isNotEmpty);
      expect(eqp3, isNotEmpty);
      expect(eqp4, isNotEmpty);
      expect(eqp5, isNotEmpty);
    });
  });
}
