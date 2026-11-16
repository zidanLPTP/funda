import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/anggaran_repositori.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Butir A: Profiling Waktu Per Kueri, Beranda, dan Tab Belajar pada 5k & 20k Transaksi di Emulator', (tester) async {
    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());
    final repoTransaksi = TransaksiRepositori(basisData);
    final repoDompet = DompetRepositori(basisData);
    final repoKategori = KategoriRepositori(basisData);
    final repoUtang = UtangRepositori(basisData);
    final repoAnggaran = AnggaranRepositori(basisData, repoTransaksi);
    final repoTujuan = TujuanRepositori(basisData);
    final repoTagihan = TagihanRepositori(basisData);
    final repoFotoData = FotoDataRepositori(basisData);

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

    // Fungsi pengukur waktu per kueri secara rinci
    Future<Map<String, double>> ukurWaktuPerKueri(DateTime waktu) async {
      final awalBulan = DateTime(waktu.year, waktu.month, 1);
      final akhirBulan = DateTime(waktu.year, waktu.month + 1, 0, 23, 59, 59);
      final hasil = <String, double>{};

      // Kueri 1: Arus kas bulan ini (agregasi SQL)
      final sw1 = Stopwatch()..start();
      await repoTransaksi.hitungArusKasSQL(mulai: awalBulan, selesai: akhirBulan);
      sw1.stop();
      hasil['1_arus_kas_sql'] = sw1.elapsedMicroseconds / 1000.0;

      // Kueri 2: Total saldo aktif
      final sw2 = Stopwatch()..start();
      await repoDompet.ambilSemuaDompet();
      sw2.stop();
      hasil['2_saldo_aktif'] = sw2.elapsedMicroseconds / 1000.0;

      // Kueri 3: Total sisa utang aktif (agregasi SQL)
      final sw3 = Stopwatch()..start();
      await repoUtang.hitungTotalSisaUtangAktifSQL();
      sw3.stop();
      hasil['3_sisa_utang_sql'] = sw3.elapsedMicroseconds / 1000.0;

      // Kueri 4: Cicilan bulanan aktif (kueri utang aktif)
      final sw4 = Stopwatch()..start();
      final daftarUtang = await (basisData.select(basisData.tabelUtang)..where((u) => u.status.equals('aktif'))).get();
      hitungTotalCicilanBulanan(daftarUtang.map((u) => u.cicilanBulananRupiah).toList());
      sw4.stop();
      hasil['4_cicilan_bulanan'] = sw4.elapsedMicroseconds / 1000.0;

      // Kueri 5: Sisa anggaran bulan ini (agregasi SQL realisasi)
      final sw5 = Stopwatch()..start();
      await repoAnggaran.ambilRealisasiAnggaranBulan(tahun: waktu.year, bulan: waktu.month);
      sw5.stop();
      hasil['5_anggaran_realisasi'] = sw5.elapsedMicroseconds / 1000.0;

      // Kueri 6: Tujuan aktif (dana darurat & terdekat)
      final sw6 = Stopwatch()..start();
      await repoTujuan.pantauTujuanAktif().first;
      sw6.stop();
      hasil['6_tujuan_aktif'] = sw6.elapsedMicroseconds / 1000.0;

      // Kueri 7: Tagihan terdekat (jadwal gabungan)
      final sw7 = Stopwatch()..start();
      await repoTagihan.ambilJadwalGabungan(mulai: awalBulan, selesai: akhirBulan);
      sw7.stop();
      hasil['7_tagihan_jadwal'] = sw7.elapsedMicroseconds / 1000.0;

      // Kueri 8: 5 Transaksi terakhir (LIMIT 5 dengan indeks waktu_id)
      final sw8 = Stopwatch()..start();
      await repoTransaksi.ambilTransaksiBerhalaman(limit: 5, offset: 0);
      sw8.stop();
      hasil['8_lima_transaksi'] = sw8.elapsedMicroseconds / 1000.0;

      // Kueri 9: Pemasukan bulanan rata-rata (agregasi SQL 3 bulan)
      final sw9 = Stopwatch()..start();
      await repoTransaksi.hitungPemasukanRataRataSQL(waktuSekarang: waktu);
      sw9.stop();
      hasil['9_pemasukan_rata2_sql'] = sw9.elapsedMicroseconds / 1000.0;

      // Kueri 10: Foto Data Pengguna (agregasi SQL lengkap)
      final sw10 = Stopwatch()..start();
      await repoFotoData.ambilFotoData();
      sw10.stop();
      hasil['10_foto_data_sql'] = sw10.elapsedMicroseconds / 1000.0;

      return hasil;
    }

    // Fungsi total eksekusi Beranda (seluruh kueri petak Beranda dieksekusi paralel)
    Future<double> eksekusiTotalBeranda(DateTime waktu) async {
      final awalBulan = DateTime(waktu.year, waktu.month, 1);
      final akhirBulan = DateTime(waktu.year, waktu.month + 1, 0, 23, 59, 59);

      final sw = Stopwatch()..start();
      await Future.wait([
        repoTransaksi.hitungArusKasSQL(mulai: awalBulan, selesai: akhirBulan),
        repoDompet.ambilSemuaDompet(),
        repoUtang.hitungTotalSisaUtangAktifSQL(),
        (basisData.select(basisData.tabelUtang)..where((u) => u.status.equals('aktif'))).get(),
        repoAnggaran.ambilRealisasiAnggaranBulan(tahun: waktu.year, bulan: waktu.month),
        repoTujuan.pantauTujuanAktif().first,
        repoTagihan.ambilJadwalGabungan(mulai: awalBulan, selesai: akhirBulan),
        repoTransaksi.ambilTransaksiBerhalaman(limit: 5, offset: 0),
        repoTransaksi.hitungPemasukanRataRataSQL(waktuSekarang: waktu),
      ]);
      sw.stop();
      return sw.elapsedMicroseconds / 1000.0;
    }

    // Fungsi ukur Tab Belajar (memuat peta belajar 19 modul)
    Future<double> eksekusiTabBelajar(ProviderContainer container) async {
      final sw = Stopwatch()..start();
      await container.read(penyediaPetaBelajar.future);
      sw.stop();
      return sw.elapsedMicroseconds / 1000.0;
    }

    // -------------------------------------------------------------------------
    // A. SUNTIKKAN 5.000 TRANSAKSI
    // -------------------------------------------------------------------------
    debugPrint('[PROFILING] Menyuntikkan 5.000 transaksi...');
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

    final waktuUji = DateTime(2026, 3, 15);

    // Profil kueri 5k
    final profil5k = await ukurWaktuPerKueri(waktuUji);

    // Pemanasan 1x Beranda 5k
    await eksekusiTotalBeranda(waktuUji);

    // 5 Iterasi Beranda 5k
    final list5k = <double>[];
    for (var iter = 1; iter <= 5; iter++) {
      list5k.add(await eksekusiTotalBeranda(waktuUji));
    }
    list5k.sort();
    final median5k = list5k[2];
    final terburuk5k = list5k.last;

    // Tab Belajar 5k
    final container5k = ProviderContainer(
      overrides: [penyediaBasisData.overrideWithValue(basisData)],
    );
    addTearDown(container5k.dispose);
    await eksekusiTabBelajar(container5k); // Pemanasan 1x

    final listBelajar5k = <double>[];
    for (var iter = 1; iter <= 5; iter++) {
      listBelajar5k.add(await eksekusiTabBelajar(container5k));
    }
    listBelajar5k.sort();
    final medianBelajar5k = listBelajar5k[2];
    final terburukBelajar5k = listBelajar5k.last;

    // -------------------------------------------------------------------------
    // B. SUNTIKKAN 15.000 LAGI (TOTAL 20.000 TRANSAKSI)
    // -------------------------------------------------------------------------
    debugPrint('[PROFILING] Menambah 15.000 transaksi hingga 20.000...');
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

    // Profil kueri 20k
    final profil20k = await ukurWaktuPerKueri(waktuUji);

    // Pemanasan 1x Beranda 20k
    await eksekusiTotalBeranda(waktuUji);

    // 5 Iterasi Beranda 20k
    final list20k = <double>[];
    for (var iter = 1; iter <= 5; iter++) {
      list20k.add(await eksekusiTotalBeranda(waktuUji));
    }
    list20k.sort();
    final median20k = list20k[2];
    final terburuk20k = list20k.last;

    // Tab Belajar 20k
    final container20k = ProviderContainer(
      overrides: [penyediaBasisData.overrideWithValue(basisData)],
    );
    addTearDown(container20k.dispose);
    await eksekusiTabBelajar(container20k); // Pemanasan 1x

    final listBelajar20k = <double>[];
    for (var iter = 1; iter <= 5; iter++) {
      listBelajar20k.add(await eksekusiTabBelajar(container20k));
    }
    listBelajar20k.sort();
    final medianBelajar20k = listBelajar20k[2];
    final terburukBelajar20k = listBelajar20k.last;

    final persentaseKenaikanBeranda = ((median20k - median5k) / median5k) * 100.0;
    final persentaseKenaikanBelajar = ((medianBelajar20k - medianBelajar5k) / medianBelajar5k) * 100.0;

    debugPrint('================================================================================');
    debugPrint('[HASIL_PROFILING_LENGKAP_TAHAP_04R]');
    debugPrint('TABEL WAKTU PER KUERI (ms):');
    debugPrint('Nama Kueri                  | 5.000 Transaksi | 20.000 Transaksi');
    debugPrint('----------------------------------------------------------------');
    for (final k in profil5k.keys) {
      final t5 = profil5k[k]!.toStringAsFixed(2).padLeft(7);
      final t20 = profil20k[k]!.toStringAsFixed(2).padLeft(7);
      final nama = k.padRight(27);
      debugPrint('$nama |   $t5 ms    |   $t20 ms');
    }
    debugPrint('----------------------------------------------------------------');
    debugPrint('BERANDA (Waktu Eksekusi Kueri Petak Beranda Paralel):');
    debugPrint('  5.000 Transaksi : Median = ${median5k.toStringAsFixed(2)} ms, Terburuk = ${terburuk5k.toStringAsFixed(2)} ms');
    debugPrint('  20.000 Transaksi: Median = ${median20k.toStringAsFixed(2)} ms, Terburuk = ${terburuk20k.toStringAsFixed(2)} ms');
    debugPrint('  Kenaikan Waktu  : ${persentaseKenaikanBeranda.toStringAsFixed(1)}% (Target < 25%)');
    debugPrint('  Status Target   : ${median20k < 60.0 ? "MEMENUHI TARGET (<60ms)" : "EVALUASI"}');
    debugPrint('----------------------------------------------------------------');
    debugPrint('TAB BELAJAR (19 Modul + Peta Belajar Lengkap):');
    debugPrint('  5.000 Transaksi : Median = ${medianBelajar5k.toStringAsFixed(2)} ms, Terburuk = ${terburukBelajar5k.toStringAsFixed(2)} ms');
    debugPrint('  20.000 Transaksi: Median = ${medianBelajar20k.toStringAsFixed(2)} ms, Terburuk = ${terburukBelajar20k.toStringAsFixed(2)} ms');
    debugPrint('  Kenaikan Waktu  : ${persentaseKenaikanBelajar.toStringAsFixed(1)}% (Target < 50ms & konstan)');
    debugPrint('================================================================================');

    expect(profil5k.length, equals(10));
    expect(profil20k.length, equals(10));
  });
}
