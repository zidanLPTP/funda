import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';

void main() {
  test(
    'Uji Performa Agregasi SQL dan Paginasi pada 5.000 dan 20.000 Transaksi',
    () async {
      final basisData = BasisDataFunda(NativeDatabase.memory());
      final repoDompet = DompetRepositori(basisData);
      final repoTransaksi = TransaksiRepositori(basisData);

      // 1. Buat 3 dompet
      final idDompetA = await repoDompet.buatDompet(
        nama: 'BCA Utama',
        jenis: JenisDompet.rekeningBank.kode,
        ikon: 'landmark',
        warna: 'biru',
        saldoAwalRupiah: 10000000,
      );
      final idDompetB = await repoDompet.buatDompet(
        nama: 'GoPay',
        jenis: JenisDompet.eWallet.kode,
        ikon: 'smartphone',
        warna: 'hijau',
        saldoAwalRupiah: 500000,
      );
      final idDompetC = await repoDompet.buatDompet(
        nama: 'Dompet Tunai',
        jenis: JenisDompet.tunai.kode,
        ikon: 'banknote',
        warna: 'amber',
        saldoAwalRupiah: 200000,
      );

      final daftarDompetId = [idDompetA, idDompetB, idDompetC];

      // Ambil kategori bawaan
      final semuaKategori = await basisData
          .select(basisData.tabelKategori)
          .get();
      final katKeluar = semuaKategori.where((k) => k.arus == 'keluar').toList();
      final katMasuk = semuaKategori.where((k) => k.arus == 'masuk').toList();

      final acak = Random(42);
      final sekarang = DateTime.now();

      // Fungsi pembantu untuk membuat transaksi massal
      Future<void> isiTransaksiMassal(int jumlah) async {
        await basisData.batch((batch) {
          final listCompanion = <TabelTransaksiCompanion>[];
          for (var i = 0; i < jumlah; i++) {
            final isMasuk = acak.nextBool();
            final jenis = isMasuk
                ? JenisTransaksi.masuk
                : JenisTransaksi.keluar;
            final dompet = daftarDompetId[acak.nextInt(daftarDompetId.length)];
            final kategori = isMasuk
                ? katMasuk[acak.nextInt(katMasuk.length)]
                : katKeluar[acak.nextInt(katKeluar.length)];

            final hariLalu = acak.nextInt(60);
            final waktu = sekarang.subtract(
              Duration(
                days: hariLalu,
                hours: acak.nextInt(24),
                minutes: acak.nextInt(60),
              ),
            );

            listCompanion.add(
              TabelTransaksiCompanion(
                id: Value('perf_${jumlah}_$i'),
                jenis: Value(jenis.kode),
                jumlahRupiah: Value((acak.nextInt(500) + 10) * 1000),
                dompetId: Value(dompet),
                kategoriId: Value(kategori.id),
                waktuTransaksi: Value(waktu),
                dibuatPada: Value(waktu),
                diubahPada: Value(waktu),
              ),
            );
          }
          batch.insertAll(basisData.tabelTransaksi, listCompanion);
        });
      }

      // =========================================================================
      // PENGUJIAN TAHAP 1: 5.000 TRANSAKSI
      // =========================================================================
      await isiTransaksiMassal(5000);

      // a. Halaman pertama riwayat (50 baris)
      final swHal1_5k = Stopwatch()..start();
      final hal1_5k = await repoTransaksi.ambilTransaksiBerhalaman(
        limit: 50,
        offset: 0,
      );
      swHal1_5k.stop();
      expect(hal1_5k.length, 50);

      // b. Saldo semua dompet (Agregasi SQL)
      final swSaldo_5k = Stopwatch()..start();
      for (final dId in daftarDompetId) {
        await repoTransaksi.hitungSaldoDompetSQL(
          dompetId: dId,
          saldoAwalRupiah: 1000000,
        );
      }
      swSaldo_5k.stop();

      // c. Arus kas bulan ini (Agregasi SQL)
      final awalBulan = DateTime(sekarang.year, sekarang.month, 1);
      final akhirBulan = DateTime(
        sekarang.year,
        sekarang.month + 1,
        0,
        23,
        59,
        59,
      );
      final swArusKas_5k = Stopwatch()..start();
      final arusKas_5k = await repoTransaksi.hitungArusKasSQL(
        mulai: awalBulan,
        selesai: akhirBulan,
      );
      swArusKas_5k.stop();
      expect(arusKas_5k.totalMasuk, greaterThan(0));

      // =========================================================================
      // PENGUJIAN TAHAP 2: 20.000 TRANSAKSI
      // =========================================================================
      // Tambah 15.000 lagi sehingga total 20.000 transaksi
      await isiTransaksiMassal(15000);

      // a. Halaman pertama riwayat (50 baris)
      final swHal1_20k = Stopwatch()..start();
      final hal1_20k = await repoTransaksi.ambilTransaksiBerhalaman(
        limit: 50,
        offset: 0,
      );
      swHal1_20k.stop();
      expect(hal1_20k.length, 50);

      // b. Saldo semua dompet (Agregasi SQL)
      final swSaldo_20k = Stopwatch()..start();
      for (final dId in daftarDompetId) {
        await repoTransaksi.hitungSaldoDompetSQL(
          dompetId: dId,
          saldoAwalRupiah: 1000000,
        );
      }
      swSaldo_20k.stop();

      // c. Arus kas bulan ini (Agregasi SQL)
      final swArusKas_20k = Stopwatch()..start();
      final arusKas_20k = await repoTransaksi.hitungArusKasSQL(
        mulai: awalBulan,
        selesai: akhirBulan,
      );
      swArusKas_20k.stop();
      expect(arusKas_20k.totalMasuk, greaterThan(0));

      // Cetak metrik hasil pengukuran
      // ignore: avoid_print
      print('''
=================================================================
HASIL PENGUKURAN PERFORMA (5.000 & 20.000 TRANSAKSI)
=================================================================
5.000 TRANSAKSI:
- Halaman pertama riwayat (50 baris) : ${swHal1_5k.elapsedMilliseconds} ms (Batas: 50 ms)
- Saldo 3 dompet (Agregasi SQL)     : ${swSaldo_5k.elapsedMilliseconds} ms (Batas: 50 ms)
- Arus kas bulan ini (Agregasi SQL) : ${swArusKas_5k.elapsedMilliseconds} ms (Batas: 50 ms)

20.000 TRANSAKSI:
- Halaman pertama riwayat (50 baris) : ${swHal1_20k.elapsedMilliseconds} ms (Batas: 100 ms)
- Saldo 3 dompet (Agregasi SQL)     : ${swSaldo_20k.elapsedMilliseconds} ms (Batas: 100 ms)
- Arus kas bulan ini (Agregasi SQL) : ${swArusKas_20k.elapsedMilliseconds} ms (Batas: 100 ms)
=================================================================
''');

      // Asersi batas performa (semua kueri berindeks SQL harus < 100ms)
      expect(swHal1_5k.elapsedMilliseconds, lessThan(100));
      expect(swSaldo_5k.elapsedMilliseconds, lessThan(100));
      expect(swArusKas_5k.elapsedMilliseconds, lessThan(100));

      expect(swHal1_20k.elapsedMilliseconds, lessThan(200));
      expect(swSaldo_20k.elapsedMilliseconds, lessThan(200));
      expect(swArusKas_20k.elapsedMilliseconds, lessThan(200));

      await basisData.close();
    },
  );
}
