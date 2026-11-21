import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/repositori/anggaran_repositori.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Butir E: Profiling 10 Iterasi Bersih Beranda & Tab Belajar pada 5k & 20k Transaksi di Emulator', (tester) async {
    await initializeDateFormatting('id_ID', null);

    // Fungsi pembantu untuk membuat dan menginisialisasi basis data bersih berisi data transaksi
    Future<BasisDataFunda> buatBasisDataBersih(int totalTransaksi) async {
      final db = BasisDataFunda(NativeDatabase.memory());
      final repoDompet = DompetRepositori(db);
      final repoKategori = KategoriRepositori(db);
      final repoUtang = UtangRepositori(db);
      final repoAnggaran = AnggaranRepositori(db, TransaksiRepositori(db));
      final repoTujuan = TujuanRepositori(db);

      // Kategori
      final daftarKat = await repoKategori.ambilSemuaKategori();
      final katKeluar = daftarKat.firstWhere((k) => k.arus == 'keluar').id;
      final katMasuk = daftarKat.firstWhere((k) => k.arus == 'masuk').id;

      // 5 Dompet
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

      // 20 Utang
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

      // 20 Tagihan
      for (var i = 1; i <= 20; i++) {
        await db.into(db.tabelTagihan).insert(
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

      // 5 Anggaran & 5 Tujuan
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

      // Distribusi tanggal yang proporsional:
      // Separuh transaksi berada di bulan Maret 2026 (bulan uji), separuhnya di luar bulan Maret.
      // Dengan demikian, pada 20k ada 10k transaksi di bulan berjalan (4x lipat dari 2.500 transaksi pada 5k).
      final transaksiBulanIni = totalTransaksi ~/ 2;
      final transaksiLuarBulan = totalTransaksi - transaksiBulanIni;

      final awalMaret = DateTime(2026, 3, 1);
      final awalJanuari = DateTime(2026, 1, 1);

      // Suntik transaksi bulan Maret 2026 (batch 500)
      for (var b = 0; b < transaksiBulanIni ~/ 500; b++) {
        await db.batch((batch) {
          for (var i = 0; i < 500; i++) {
            final idx = b * 500 + i;
            final isMasuk = idx % 5 == 0;
            batch.insert(
              db.tabelTransaksi,
              TabelTransaksiCompanion.insert(
                id: 'tx_mrt_${totalTransaksi}_$idx',
                jenis: isMasuk ? 'masuk' : 'keluar',
                jumlahRupiah: (idx % 10 + 1) * 25000,
                dompetId: daftarDompetId[idx % daftarDompetId.length],
                kategoriId: Value(isMasuk ? katMasuk : katKeluar),
                waktuTransaksi: awalMaret.add(Duration(minutes: (idx * 43) % (30 * 24 * 60))),
                catatan: Value('Catatan maret $idx'),
                dibuatPada: Value(awalMaret),
              ),
            );
          }
        });
      }

      // Suntik transaksi luar bulan (Januari - Februari 2026)
      for (var b = 0; b < transaksiLuarBulan ~/ 500; b++) {
        await db.batch((batch) {
          for (var i = 0; i < 500; i++) {
            final idx = b * 500 + i;
            final isMasuk = idx % 5 == 0;
            batch.insert(
              db.tabelTransaksi,
              TabelTransaksiCompanion.insert(
                id: 'tx_luar_${totalTransaksi}_$idx',
                jenis: isMasuk ? 'masuk' : 'keluar',
                jumlahRupiah: (idx % 10 + 1) * 20000,
                dompetId: daftarDompetId[idx % daftarDompetId.length],
                kategoriId: Value(isMasuk ? katMasuk : katKeluar),
                waktuTransaksi: awalJanuari.add(Duration(minutes: (idx * 37) % (59 * 24 * 60))),
                catatan: Value('Catatan luar $idx'),
                dibuatPada: Value(awalJanuari),
              ),
            );
          }
        });
      }

      return db;
    }

    // Fungsi ukur kueri Beranda (9 kueri paralel)
    Future<double> ukurKueriBeranda(BasisDataFunda db, DateTime waktu) async {
      final repoTransaksi = TransaksiRepositori(db);
      final repoDompet = DompetRepositori(db);
      final repoUtang = UtangRepositori(db);
      final repoAnggaran = AnggaranRepositori(db, repoTransaksi);
      final repoTujuan = TujuanRepositori(db);
      final repoTagihan = TagihanRepositori(db);

      final awalBulan = DateTime(waktu.year, waktu.month, 1);
      final akhirBulan = DateTime(waktu.year, waktu.month + 1, 0, 23, 59, 59);

      final sw = Stopwatch()..start();
      await Future.wait([
        repoTransaksi.hitungArusKasSQL(mulai: awalBulan, selesai: akhirBulan),
        repoDompet.ambilSemuaDompet(),
        repoUtang.hitungTotalSisaUtangAktifSQL(),
        (db.select(db.tabelUtang)..where((u) => u.status.equals('aktif'))).get(),
        repoAnggaran.ambilRealisasiAnggaranBulan(tahun: waktu.year, bulan: waktu.month),
        repoTujuan.pantauTujuanAktif().first,
        repoTagihan.ambilJadwalGabungan(mulai: awalBulan, selesai: akhirBulan),
        repoTransaksi.ambilTransaksiBerhalaman(limit: 5, offset: 0),
        repoTransaksi.hitungPemasukanRataRataSQL(waktuSekarang: waktu),
      ]);
      sw.stop();
      return sw.elapsedMicroseconds / 1000.0;
    }

    // Fungsi ukur waktu sampai data tampil (kueri + widget dipompa di tester)
    Future<double> ukurDataTampilBeranda(WidgetTester tester, BasisDataFunda db, DateTime waktu) async {
      final sw = Stopwatch()..start();
      await ukurKueriBeranda(db, waktu);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Beranda Siap ${waktu.toIso8601String()}'),
            ),
          ),
        ),
      );
      await tester.pump();
      sw.stop();
      return sw.elapsedMicroseconds / 1000.0;
    }

    // Fungsi ukur Tab Belajar Siklus Lengkap (5 kueri SQL + Pemuatan 19 Modul + 2 Pelajaran + Evaluasi Gerbang)
    Future<double> ukurTabBelajarSiklusLengkap(BasisDataFunda db) async {
      final repoFotoData = FotoDataRepositori(db);
      final sw = Stopwatch()..start();

      // 1. Kueri Foto Data Pengguna (5 kueri SQL)
      final fotoData = await repoFotoData.ambilFotoData();

      // 2. Baca Kamus
      final kamusStr = await rootBundle.loadString('aset/konten/kamus.json');
      final petaKamus = PembacaKonten.uraiKamus(kamusStr, namaBerkas: 'kamus.json');
      final istilahKamus = petaKamus.keys.toSet();

      // 3. Muat 19 Modul dari aset
      const daftarFolderModul = [
        ('pemula', 'anggaran_arus_kas'),
        ('pemula', 'dana_darurat'),
        ('pemula', 'mulai_tes_awal'),
        ('pemula', 'psikologi_uang'),
        ('pemula', 'tabungan'),
        ('pemula', 'utang_cicilan'),
        ('pemula', 'waspada_penipuan'),
        ('menengah', 'investasi_dasar'),
        ('menengah', 'pajak_dasar'),
        ('menengah', 'paylater_kredit'),
        ('menengah', 'penghasilan_tambahan'),
        ('menengah', 'proteksi_dasar'),
        ('menengah', 'tujuan_besar'),
        ('lanjutan', 'investasi_lanjutan'),
        ('lanjutan', 'keuangan_usaha_kecil'),
        ('lanjutan', 'kpr_kredit_besar'),
        ('lanjutan', 'pajak_lanjutan'),
        ('lanjutan', 'pensiun_kebebasan_finansial'),
        ('lanjutan', 'proteksi_keluarga_warisan'),
      ];

      final daftarModul = <ModulKonten>[];
      for (final item in daftarFolderModul) {
        final path = 'aset/konten/${item.$1}/${item.$2}/modul.json';
        final str = await rootBundle.loadString(path);
        final modul = PembacaKonten.uraiModul(str, namaBerkas: path);
        daftarModul.add(modul);
      }

      // 4. Muat 2 Pelajaran contoh
      const path12 = 'aset/konten/pemula/anggaran_arus_kas/anggaran_arus_kas_1_2.json';
      const path13 = 'aset/konten/pemula/anggaran_arus_kas/anggaran_arus_kas_1_3.json';
      final pel12Str = await rootBundle.loadString(path12);
      final pel13Str = await rootBundle.loadString(path13);
      final pel12 = PembacaKonten.uraiPelajaran(pel12Str, namaBerkas: path12, daftarIstilahKamus: istilahKamus);
      final pel13 = PembacaKonten.uraiPelajaran(pel13Str, namaBerkas: path13, daftarIstilahKamus: istilahKamus);

      // 5. Evaluasi seluruh gerbang modul dan pelajaran
      for (final m in daftarModul) {
        tentukanStatusModul(modul: m, fotoData: fotoData);
      }
      tentukanStatusPelajaran(
        pelajaran: pel12,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel12, pel13],
        gerbangModul: daftarModul.first.gerbang,
        fotoData: fotoData,
      );
      tentukanStatusPelajaran(
        pelajaran: pel13,
        posisiIndeks: 1,
        daftarPelajaranModul: [pel12, pel13],
        gerbangModul: daftarModul.first.gerbang,
        fotoData: fotoData,
      );

      sw.stop();
      return sw.elapsedMicroseconds / 1000.0;
    }

    final waktuUji = DateTime(2026, 3, 15);

    debugPrint('================================================================================');
    debugPrint('[PENGUKURAN ULANG 10 ITERASI: BERANDA & TAB BELAJAR]');
    debugPrint('================================================================================');

    // -------------------------------------------------------------------------
    // 1. PENGUKURAN 10 ITERASI PADA 5.000 TRANSAKSI (Koneksi Bersih per Iterasi)
    // -------------------------------------------------------------------------
    final kueriBeranda5k = <double>[];
    final tampilBeranda5k = <double>[];
    final siklusBelajar5k = <double>[];

    debugPrint('--> Mengukur 5.000 Transaksi (10 Iterasi Bersih)...');
    for (var iter = 1; iter <= 10; iter++) {
      final db = await buatBasisDataBersih(5000);

      final wKueri = await ukurKueriBeranda(db, waktuUji);
      final wTampil = await ukurDataTampilBeranda(tester, db, waktuUji);
      final wBelajar = await ukurTabBelajarSiklusLengkap(db);

      kueriBeranda5k.add(wKueri);
      tampilBeranda5k.add(wTampil);
      siklusBelajar5k.add(wBelajar);

      await db.close();
      debugPrint('    Iterasi $iter (5k): Kueri Beranda=${wKueri.toStringAsFixed(2)} ms, Tampil Beranda=${wTampil.toStringAsFixed(2)} ms, Tab Belajar=${wBelajar.toStringAsFixed(2)} ms');
    }

    // -------------------------------------------------------------------------
    // 2. PENGUKURAN 10 ITERASI PADA 20.000 TRANSAKSI (Koneksi Bersih per Iterasi)
    // -------------------------------------------------------------------------
    final kueriBeranda20k = <double>[];
    final tampilBeranda20k = <double>[];
    final siklusBelajar20k = <double>[];

    debugPrint('--> Mengukur 20.000 Transaksi (10 Iterasi Bersih)...');
    for (var iter = 1; iter <= 10; iter++) {
      final db = await buatBasisDataBersih(20000);

      final wKueri = await ukurKueriBeranda(db, waktuUji);
      final wTampil = await ukurDataTampilBeranda(tester, db, waktuUji);
      final wBelajar = await ukurTabBelajarSiklusLengkap(db);

      kueriBeranda20k.add(wKueri);
      tampilBeranda20k.add(wTampil);
      siklusBelajar20k.add(wBelajar);

      await db.close();
      debugPrint('    Iterasi $iter (20k): Kueri Beranda=${wKueri.toStringAsFixed(2)} ms, Tampil Beranda=${wTampil.toStringAsFixed(2)} ms, Tab Belajar=${wBelajar.toStringAsFixed(2)} ms');
    }

    // Hitung statistik median dan terburuk
    double hitungMedian(List<double> list) {
      final sorted = List<double>.from(list)..sort();
      return (sorted[4] + sorted[5]) / 2.0;
    }

    double hitungTerburuk(List<double> list) {
      final sorted = List<double>.from(list)..sort();
      return sorted.last;
    }

    debugPrint('================================================================================');
    debugPrint('[HASIL REKAPITULASI 10 ITERASI]');
    debugPrint('JUMLAH KUERI:');
    debugPrint('  - Beranda     : 9 kueri (Arus Kas, Dompet, Sisa Utang, Cicilan, Anggaran, Tujuan, Tagihan, 5 Tx, Pemasukan Rata-rata)');
    debugPrint('  - Tab Belajar : 5 kueri (Agregasi Objek, Kategori Keluar Sifat, Pernyataan, Progres Pelajaran, Hasil Kuis)');
    debugPrint('--------------------------------------------------------------------------------');
    debugPrint('SEMUA NILAI ITERASI (ms):');
    debugPrint('Iterasi | Kueri 5k  | Kueri 20k | Tampil 5k | Tampil 20k| Belajar 5k| Belajar 20k');
    for (var i = 0; i < 10; i++) {
      debugPrint(
        '#${(i + 1).toString().padLeft(2)}     | '
        '${kueriBeranda5k[i].toStringAsFixed(2).padLeft(7)} ms | '
        '${kueriBeranda20k[i].toStringAsFixed(2).padLeft(7)} ms | '
        '${tampilBeranda5k[i].toStringAsFixed(2).padLeft(7)} ms | '
        '${tampilBeranda20k[i].toStringAsFixed(2).padLeft(7)} ms | '
        '${siklusBelajar5k[i].toStringAsFixed(2).padLeft(7)} ms | '
        '${siklusBelajar20k[i].toStringAsFixed(2).padLeft(7)} ms',
      );
    }
    debugPrint('--------------------------------------------------------------------------------');
    final medKueri5k = hitungMedian(kueriBeranda5k);
    final medKueri20k = hitungMedian(kueriBeranda20k);
    final terKueri5k = hitungTerburuk(kueriBeranda5k);
    final terKueri20k = hitungTerburuk(kueriBeranda20k);

    final medTampil5k = hitungMedian(tampilBeranda5k);
    final medTampil20k = hitungMedian(tampilBeranda20k);
    final terTampil5k = hitungTerburuk(tampilBeranda5k);
    final terTampil20k = hitungTerburuk(tampilBeranda20k);

    final medBelajar5k = hitungMedian(siklusBelajar5k);
    final medBelajar20k = hitungMedian(siklusBelajar20k);
    final terBelajar5k = hitungTerburuk(siklusBelajar5k);
    final terBelajar20k = hitungTerburuk(siklusBelajar20k);

    final kenaikanKueri = ((medKueri20k - medKueri5k) / medKueri5k) * 100.0;
    final kenaikanTampil = ((medTampil20k - medTampil5k) / medTampil5k) * 100.0;
    final kenaikanBelajar = ((medBelajar20k - medBelajar5k) / medBelajar5k) * 100.0;

    debugPrint('RINGKASAN STATISTIK:');
    debugPrint('KUERI BERANDA:');
    debugPrint('  5.000 Transaksi : Median = ${medKueri5k.toStringAsFixed(2)} ms, Terburuk = ${terKueri5k.toStringAsFixed(2)} ms');
    debugPrint('  20.000 Transaksi: Median = ${medKueri20k.toStringAsFixed(2)} ms, Terburuk = ${terKueri20k.toStringAsFixed(2)} ms');
    debugPrint('  Kenaikan Waktu  : ${kenaikanKueri.toStringAsFixed(1)}%');
    debugPrint('SAMPAI DATA TAMPIL BERANDA:');
    debugPrint('  5.000 Transaksi : Median = ${medTampil5k.toStringAsFixed(2)} ms, Terburuk = ${terTampil5k.toStringAsFixed(2)} ms');
    debugPrint('  20.000 Transaksi: Median = ${medTampil20k.toStringAsFixed(2)} ms, Terburuk = ${terTampil20k.toStringAsFixed(2)} ms');
    debugPrint('  Kenaikan Waktu  : ${kenaikanTampil.toStringAsFixed(1)}%');
    debugPrint('TAB BELAJAR SIKLUS PENUH:');
    debugPrint('  5.000 Transaksi : Median = ${medBelajar5k.toStringAsFixed(2)} ms, Terburuk = ${terBelajar5k.toStringAsFixed(2)} ms');
    debugPrint('  20.000 Transaksi: Median = ${medBelajar20k.toStringAsFixed(2)} ms, Terburuk = ${terBelajar20k.toStringAsFixed(2)} ms');
    debugPrint('  Kenaikan Waktu  : ${kenaikanBelajar.toStringAsFixed(1)}%');
    debugPrint('================================================================================');

    expect(kueriBeranda5k.length, equals(10));
    expect(kueriBeranda20k.length, equals(10));
  });
}
