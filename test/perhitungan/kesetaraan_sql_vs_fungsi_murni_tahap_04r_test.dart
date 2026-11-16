import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';

void main() {
  group('Butir A.2: Uji Kesetaraan SQL vs Fungsi Murni pada Data Acak (Tahap 4-R)', () {
    late BasisDataFunda db;
    late TransaksiRepositori repoTransaksi;
    late FotoDataRepositori repoFotoData;

    setUp(() async {
      db = BasisDataFunda(NativeDatabase.memory());
      repoTransaksi = TransaksiRepositori(db);
      repoFotoData = FotoDataRepositori(db);

      // Siapkan dompet & kategori
      await db.into(db.tabelDompet).insert(
            TabelDompetCompanion.insert(
              id: 'dmp_test',
              nama: 'Dompet Utama',
              jenis: 'tunai',
              ikon: 'wallet',
              warna: 'tintBiru',
              saldoAwalRupiah: const Value(10000000),
            ),
          );

      await db.into(db.tabelKategori).insert(
            TabelKategoriCompanion.insert(
              id: 'kat_makan',
              nama: 'Makan',
              ikon: 'utensils',
              arus: 'keluar',
              sifat: 'kebutuhan',
            ),
          );

      await db.into(db.tabelKategori).insert(
            TabelKategoriCompanion.insert(
              id: 'kat_gaji',
              nama: 'Gaji',
              ikon: 'briefcase',
              arus: 'masuk',
              sifat: 'tidak_berlaku',
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('1. Kesetaraan Arus Kas: hitungArusKas (murni) vs hitungArusKasSQL (SQL)', () async {
      final rng = Random(42);
      final waktuMulai = DateTime(2026, 3, 1, 0, 0, 0);
      final waktuSelesai = DateTime(2026, 3, 31, 23, 59, 59);

      final daftarEntitas = <EntitasTransaksi>[];

      // Masukkan 200 transaksi acak
      for (var i = 0; i < 200; i++) {
        final isMasuk = rng.nextBool();
        final nominal = (rng.nextInt(50) + 1) * 10000;
        final tglHari = rng.nextInt(30) + 1;
        final jam = rng.nextInt(24);
        final menit = rng.nextInt(60);
        final waktu = DateTime(2026, 3, tglHari, jam, menit);

        final id = 'tx_arus_$i';
        await db.into(db.tabelTransaksi).insert(
              TabelTransaksiCompanion.insert(
                id: id,
                jenis: isMasuk ? 'masuk' : 'keluar',
                jumlahRupiah: nominal,
                dompetId: 'dmp_test',
                kategoriId: Value(isMasuk ? 'kat_gaji' : 'kat_makan'),
                waktuTransaksi: waktu,
                dibuatPada: Value(waktu),
              ),
            );

        daftarEntitas.add(
          EntitasTransaksi(
            id: id,
            jenis: isMasuk ? 'masuk' : 'keluar',
            jumlahRupiah: nominal,
            dompetId: 'dmp_test',
            kategoriId: isMasuk ? 'kat_gaji' : 'kat_makan',
            biayaAdminRupiah: 0,
            waktuTransaksi: waktu,
            dibuatPada: waktu,
            diubahPada: waktu,
          ),
        );
      }

      // Hitung via fungsi murni Dart
      final hasilMurni = hitungArusKas(
        daftarTransaksi: daftarEntitas,
        mulai: waktuMulai,
        selesai: waktuSelesai,
      );

      // Hitung via agregasi SQL
      final hasilSQL = await repoTransaksi.hitungArusKasSQL(
        mulai: waktuMulai,
        selesai: waktuSelesai,
      );

      expect(hasilSQL.totalMasuk, equals(hasilMurni.totalMasuk));
      expect(hasilSQL.totalKeluar, equals(hasilMurni.totalKeluar));
      expect(hasilSQL.selisih, equals(hasilMurni.selisih));
    });

    test('2. Kesetaraan Pemasukan Rata-rata: hitungPemasukanBulananRataRata (murni) vs hitungPemasukanRataRataSQL (SQL)', () async {
      final rng = Random(123);
      final waktuSekarang = DateTime(2026, 4, 15, 12, 0); // April 2026

      final daftarEntitas = <EntitasTransaksi>[];

      // Masukkan transaksi acak dari Jan s.d. Apr 2026
      for (var i = 0; i < 300; i++) {
        final isMasuk = rng.nextInt(3) == 0; // 33% masuk
        final nominal = (rng.nextInt(20) + 1) * 50000;
        final bulan = rng.nextInt(4) + 1; // 1 to 4
        final hari = rng.nextInt(28) + 1;
        final jam = rng.nextInt(24);
        final waktu = DateTime(2026, bulan, hari, jam);

        final id = 'tx_rata_$i';
        await db.into(db.tabelTransaksi).insert(
              TabelTransaksiCompanion.insert(
                id: id,
                jenis: isMasuk ? 'masuk' : 'keluar',
                jumlahRupiah: nominal,
                dompetId: 'dmp_test',
                kategoriId: Value(isMasuk ? 'kat_gaji' : 'kat_makan'),
                waktuTransaksi: waktu,
                dibuatPada: Value(waktu),
              ),
            );

        daftarEntitas.add(
          EntitasTransaksi(
            id: id,
            jenis: isMasuk ? 'masuk' : 'keluar',
            jumlahRupiah: nominal,
            dompetId: 'dmp_test',
            kategoriId: isMasuk ? 'kat_gaji' : 'kat_makan',
            biayaAdminRupiah: 0,
            waktuTransaksi: waktu,
            dibuatPada: waktu,
            diubahPada: waktu,
          ),
        );
      }

      // Hitung via fungsi murni
      final hasilMurni = hitungPemasukanBulananRataRata(
        daftarTransaksi: daftarEntitas,
        waktuSekarang: waktuSekarang,
      );

      // Hitung via agregasi SQL
      final hasilSQL = await repoTransaksi.hitungPemasukanRataRataSQL(
        waktuSekarang: waktuSekarang,
      );

      expect(hasilSQL.nilaiRupiah, equals(hasilMurni.nilaiRupiah));
      expect(hasilSQL.dasar, equals(hasilMurni.dasar));
    });

    test('3. Kesetaraan Hari & Bulan Berbeda: Fungsi Murni vs Kueri Agregasi SQL (termasuk batas 23:30 WIB)', () async {
      final daftarWaktu = <DateTime>[];

      // Tanggal 1: 10 Maret 2026 23:30:00 WIB
      final t1 = DateTime(2026, 3, 10, 23, 30);
      // Tanggal 1 juga: 10 Maret 2026 01:15:00 WIB
      final t2 = DateTime(2026, 3, 10, 1, 15);
      // Tanggal 2: 11 Maret 2026 00:05:00 WIB (beda hari)
      final t3 = DateTime(2026, 3, 11, 0, 5);
      // Tanggal 3: 15 April 2026 14:00:00 WIB (beda bulan)
      final t4 = DateTime(2026, 4, 15, 14, 0);

      final daftar = [t1, t2, t3, t4];

      for (var i = 0; i < daftar.length; i++) {
        final w = daftar[i];
        daftarWaktu.add(w);
        await db.into(db.tabelTransaksi).insert(
              TabelTransaksiCompanion.insert(
                id: 'tx_tgl_$i',
                jenis: 'keluar',
                jumlahRupiah: 10000,
                dompetId: 'dmp_test',
                kategoriId: const Value('kat_makan'),
                waktuTransaksi: w,
                dibuatPada: Value(w),
              ),
            );
      }

      // Hitung murni
      final hariMurni = hitungHariKalenderBerbeda(daftarWaktu);
      final bulanMurni = hitungBulanKalenderBerbeda(daftarWaktu);

      expect(hariMurni, equals(3), reason: '10 Mar, 11 Mar, 15 Apr -> 3 hari berbeda');
      expect(bulanMurni, equals(2), reason: 'Maret 2026, April 2026 -> 2 bulan berbeda');

      // Hitung via SQL FotoData
      final fotoData = await repoFotoData.ambilFotoData();

      expect(fotoData.hariTransaksiBerbeda, equals(hariMurni));
      expect(fotoData.bulanTransaksiBerbeda, equals(bulanMurni));
    });
  });
}
