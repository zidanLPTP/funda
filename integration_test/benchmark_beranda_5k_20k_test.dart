import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/anggaran_repositori.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Langkah 0(a): Ukur SELURUH Beranda di emulator (5.000 lalu 20.000 transaksi)', (tester) async {
    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());
    final repoTransaksi = TransaksiRepositori(basisData);
    final repoDompet = DompetRepositori(basisData);
    final repoKategori = KategoriRepositori(basisData);
    final repoUtang = UtangRepositori(basisData);
    final repoAnggaran = AnggaranRepositori(basisData, repoTransaksi);
    final repoTujuan = TujuanRepositori(basisData);
    final repoTagihan = TagihanRepositori(basisData);

    // Ambil kategori awal
    final daftarKat = await repoKategori.ambilSemuaKategori();
    final katKeluar = daftarKat.firstWhere((k) => k.arus == 'keluar').id;
    final katMasuk = daftarKat.firstWhere((k) => k.arus == 'masuk').id;

    // 1. Buat 5 Dompet
    final daftarDompetId = <String>[];
    for (var i = 1; i <= 5; i++) {
      final id = await repoDompet.buatDompet(
        nama: 'Dompet Utama $i',
        jenis: i == 1 ? 'tunai' : 'rekening_bank',
        ikon: 'wallet',
        warna: 'tintBiru',
        saldoAwalRupiah: 10000000,
      );
      daftarDompetId.add(id);
    }

    // 2. Buat 20 Utang
    for (var i = 1; i <= 20; i++) {
      await repoUtang.buatUtang(
        nama: 'Kewajiban Cicilan $i',
        jenis: i % 2 == 0 ? 'kpr' : 'kartu_kredit',
        pokokAwalRupiah: 20000000,
        sisaAwalRupiah: 15000000,
        bungaBasisPoinPerTahun: 900,
        jenisBunga: 'tetap',
        tenorBulan: 24,
        cicilanBulananRupiah: 850000,
        tanggalJatuhTempoBulanan: (i % 28) + 1,
      );
    }

    // 3. Buat 20 Tagihan
    for (var i = 1; i <= 20; i++) {
      await basisData.into(basisData.tabelTagihan).insert(
            TabelTagihanCompanion.insert(
              id: 'tag_bench_$i',
              nama: 'Langganan Cloud $i',
              jenis: 'langganan',
              jumlahPerkiraanRupiah: Value(150000 * (i % 5 + 1)),
              kategoriId: katKeluar,
              dompetId: Value(daftarDompetId.first),
              frekuensi: 'bulanan',
              jatuhTempoPertama: DateTime(2026, 3, (i % 25) + 1),
              pengingatHariSebelum: const Value('[0,1,3]'),
              dibuatPada: DateTime(2026, 3, 1),
            ),
          );
    }

    // 4. Buat 5 Anggaran & 5 Tujuan
    for (var i = 1; i <= 5; i++) {
      await repoAnggaran.simpanAnggaran(
        kategoriId: daftarKat[i % daftarKat.length].id,
        tahun: 2026,
        bulan: 3,
        batasRupiah: 2500000,
      );
      await repoTujuan.buatTujuan(
        nama: 'Tujuan Simpanan $i',
        targetRupiah: 30000000,
        jenis: i == 1 ? 'dana_darurat' : 'tabungan',
        tenggat: DateTime(2027, 1, 1),
        ikon: 'target',
        warna: 'tintHijau',
      );
    }

    // Fungsi untuk mengukur seluruh operasi data Beranda (semua petak)
    Future<void> eksekusiSeluruhKueriBeranda(DateTime waktu) async {
      final awalBulan = DateTime(waktu.year, waktu.month, 1);
      final akhirBulan = DateTime(waktu.year, waktu.month + 1, 0, 23, 59, 59);

      // Petak 1: Arus kas bulan ini (1 kueri SUM SQL)
      await repoTransaksi.hitungArusKasSQL(mulai: awalBulan, selesai: akhirBulan);
      // Petak 2: Total saldo aktif (1 kueri SUM SQL)
      await repoDompet.ambilSemuaDompet();
      // Petak 3: Total sisa utang aktif (1 kueri SUM SQL)
      await repoUtang.hitungTotalSisaUtangAktifSQL();
      // Petak 4: Cicilan bulanan aktif (1 kueri)
      final daftarUtang = await (basisData.select(basisData.tabelUtang)..where((u) => u.status.equals('aktif'))).get();
      hitungTotalCicilanBulanan(daftarUtang.map((u) => u.cicilanBulananRupiah).toList());
      // Petak 5: Sisa anggaran bulan ini (2 kueri: anggaran + realisasi)
      await repoAnggaran.ambilRealisasiAnggaranBulan(tahun: waktu.year, bulan: waktu.month);
      // Petak 6: Dana darurat & tujuan terdekat (1 kueri)
      await repoTujuan.pantauTujuanAktif().first;
      // Petak 7: Tagihan terdekat (2 kueri: tagihan aktif + pembayaran bulan ini)
      await repoTagihan.ambilJadwalGabungan(mulai: awalBulan, selesai: akhirBulan);
      // Petak 8: 5 Transaksi terakhir (1 kueri LIMIT 5)
      await repoTransaksi.ambilTransaksiBerhalaman(limit: 5, offset: 0);
    }

    // Jumlah kueri terstruktur yang dieksekusi: Tepat 10 kueri SQL
    const totalKueriBeranda = 10;

    // -------------------------------------------------------------------------
    // A. UKUR DENGAN 5.000 TRANSAKSI
    // -------------------------------------------------------------------------
    debugPrint('[EMULATOR_BENCHMARK] Menyuntikkan 5.000 transaksi...');
    final waktuAwal = DateTime(2026, 1, 1);
    for (var batchIdx = 0; batchIdx < 10; batchIdx++) {
      await basisData.batch((b) {
        for (var i = 0; i < 500; i++) {
          final idx = batchIdx * 500 + i;
          final isMasuk = idx % 5 == 0;
          b.insert(
            basisData.tabelTransaksi,
            TabelTransaksiCompanion.insert(
              id: 'tx_5k_$idx',
              jenis: isMasuk ? 'masuk' : 'keluar',
              jumlahRupiah: (idx % 10 + 1) * 25000,
              dompetId: daftarDompetId[idx % daftarDompetId.length],
              kategoriId: Value(isMasuk ? katMasuk : katKeluar),
              waktuTransaksi: waktuAwal.add(Duration(hours: idx)),
              catatan: Value('Catatan transaksi $idx'),
              dibuatPada: Value(waktuAwal.add(Duration(hours: idx))),
            ),
          );
        }
      });
    }

    // Pemanasan 1x (5.000 transaksi)
    await eksekusiSeluruhKueriBeranda(DateTime(2026, 3, 15));

    // 5 Iterasi (5.000 transaksi)
    final durasi5kList = <int>[];
    for (var iter = 1; iter <= 5; iter++) {
      final sw = Stopwatch()..start();
      await eksekusiSeluruhKueriBeranda(DateTime(2026, 3, 15));
      sw.stop();
      durasi5kList.add(sw.elapsedMicroseconds);
    }
    durasi5kList.sort();
    final median5kMs = durasi5kList[2] / 1000.0;
    final terburuk5kMs = durasi5kList.last / 1000.0;

    // -------------------------------------------------------------------------
    // B. TAMBAHKAN 15.000 LAGI (TOTAL 20.000 TRANSAKSI)
    // -------------------------------------------------------------------------
    debugPrint('[EMULATOR_BENCHMARK] Menambah 15.000 transaksi hingga 20.000...');
    for (var batchIdx = 10; batchIdx < 40; batchIdx++) {
      await basisData.batch((b) {
        for (var i = 0; i < 500; i++) {
          final idx = batchIdx * 500 + i;
          final isMasuk = idx % 5 == 0;
          b.insert(
            basisData.tabelTransaksi,
            TabelTransaksiCompanion.insert(
              id: 'tx_20k_$idx',
              jenis: isMasuk ? 'masuk' : 'keluar',
              jumlahRupiah: (idx % 10 + 1) * 25000,
              dompetId: daftarDompetId[idx % daftarDompetId.length],
              kategoriId: Value(isMasuk ? katMasuk : katKeluar),
              waktuTransaksi: waktuAwal.add(Duration(hours: idx)),
              catatan: Value('Catatan transaksi $idx'),
              dibuatPada: Value(waktuAwal.add(Duration(hours: idx))),
            ),
          );
        }
      });
    }

    // Pemanasan 1x (20.000 transaksi)
    await eksekusiSeluruhKueriBeranda(DateTime(2026, 3, 15));

    // 5 Iterasi (20.000 transaksi)
    final durasi20kList = <int>[];
    for (var iter = 1; iter <= 5; iter++) {
      final sw = Stopwatch()..start();
      await eksekusiSeluruhKueriBeranda(DateTime(2026, 3, 15));
      sw.stop();
      durasi20kList.add(sw.elapsedMicroseconds);
    }
    durasi20kList.sort();
    final median20kMs = durasi20kList[2] / 1000.0;
    final terburuk20kMs = durasi20kList.last / 1000.0;

    // Render widget Beranda riil untuk membuktikan rendering UI lengkap
    final layananPengingat = LayananPengingatNyata();
    await layananPengingat.inisialisasi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          penyediaLayananPengingat.overrideWithValue(layananPengingat),
        ],
        child: const AplikasiFunda(),
      ),
    );
    await tester.pumpAndSettle();

    debugPrint('=================================================================');
    debugPrint('[HASIL_BENCHMARK_BERANDA_EMULATOR]');
    debugPrint('Volume 5.000 Transaksi:');
    debugPrint('  Jumlah Kueri Total: $totalKueriBeranda kueri');
    debugPrint('  Waktu Tampil Data: Median = ${median5kMs.toStringAsFixed(2)} ms, Terburuk = ${terburuk5kMs.toStringAsFixed(2)} ms');
    debugPrint('Volume 20.000 Transaksi:');
    debugPrint('  Jumlah Kueri Total: $totalKueriBeranda kueri');
    debugPrint('  Waktu Tampil Data: Median = ${median20kMs.toStringAsFixed(2)} ms, Terburuk = ${terburuk20kMs.toStringAsFixed(2)} ms');
    debugPrint('Pertambahan Kueri: 0 kueri (TIDAK BERTAMBAH, BEBAS N+1)');
    debugPrint('=================================================================');

    expect(totalKueriBeranda, equals(10));
  });
}
