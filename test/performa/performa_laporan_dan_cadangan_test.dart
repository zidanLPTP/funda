import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/layanan/laporan/pembuat_pdf_laporan.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:funda/perhitungan/perhitungan_laporan_bulanan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BasisDataFunda basisData;
  late CadanganRepositori cadanganRepo;
  late TransaksiRepositori transaksiRepo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('funda_bench_');
    basisData = BasisDataFunda(NativeDatabase.memory());
    cadanganRepo = CadanganRepositori(basisData, direktoriPenyimpananUji: tempDir);
    transaksiRepo = TransaksiRepositori(basisData);
  });

  tearDown(() async {
    await basisData.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  test('Uji Tolok Ukur Beban Nyata: 20.000 Transaksi, 20 Utang, 20 Tagihan', () async {
    // 1. Seed 3 Dompet
    for (int i = 1; i <= 3; i++) {
      await basisData.into(basisData.tabelDompet).insert(
            TabelDompetCompanion.insert(
              id: 'dmp_$i',
              nama: 'Dompet Rekening $i',
              jenis: 'bank',
              ikon: 'wallet',
              warna: '#006C4C',
              saldoAwalRupiah: const drift.Value(10000000),
            ),
          );
    }

    // 2. Seed 2 Kategori
    await basisData.into(basisData.tabelKategori).insert(
          TabelKategoriCompanion.insert(
            id: 'kat_makan',
            nama: 'Makan & Minum',
            arus: 'keluar',
            sifat: 'kebutuhan',
            ikon: 'utensils',
          ),
        );
    await basisData.into(basisData.tabelKategori).insert(
          TabelKategoriCompanion.insert(
            id: 'kat_gaji',
            nama: 'Gaji Pokok',
            arus: 'masuk',
            sifat: 'kebutuhan',
            ikon: 'briefcase',
          ),
        );

    // 3. Seed 20 Utang
    for (int i = 1; i <= 20; i++) {
      await basisData.into(basisData.tabelUtang).insert(
            TabelUtangCompanion.insert(
              id: 'utg_$i',
              nama: 'Utang Elektronik $i',
              pemberi: const drift.Value('Bank ABC'),
              jenis: 'pinjaman_bank',
              pokokAwalRupiah: const drift.Value(5000000),
              sisaAwalRupiah: 4000000,
              jenisBunga: 'flat',
              cicilanBulananRupiah: const drift.Value(500000),
              tanggalJatuhTempoBulanan: const drift.Value(15),
              dibuatPada: DateTime(2026, 1, 1),
            ),
          );
    }

    // 4. Seed 20 Tagihan
    for (int i = 1; i <= 20; i++) {
      await basisData.into(basisData.tabelTagihan).insert(
            TabelTagihanCompanion.insert(
              id: 'tgh_$i',
              nama: 'Tagihan Rutin $i',
              jenis: 'tagihan',
              frekuensi: 'bulanan',
              jatuhTempoPertama: DateTime(2026, 1, 1),
              dibuatPada: DateTime(2026, 1, 1),
              jumlahPerkiraanRupiah: const drift.Value(150000),
              kategoriId: 'kat_makan',
              dompetId: const drift.Value('dmp_1'),
            ),
          );
    }

    // 5. Seed 20.000 Transaksi via batch
    final sekarang = DateTime(2026, 11, 15);
    final rng = Random(42);
    final daftarTx = <TabelTransaksiCompanion>[];
    for (int i = 0; i < 20000; i++) {
      final jenis = (i % 5 == 0) ? 'masuk' : 'keluar';
      final waktu = sekarang.subtract(Duration(minutes: i * 15));
      daftarTx.add(
        TabelTransaksiCompanion.insert(
          id: 'tx_$i',
          dompetId: 'dmp_${(i % 3) + 1}',
          kategoriId: drift.Value(jenis == 'masuk' ? 'kat_gaji' : 'kat_makan'),
          jumlahRupiah: 10000 + (rng.nextInt(200) * 1000),
          jenis: jenis,
          catatan: drift.Value('Catatan pengeluaran ke-$i'),
          waktuTransaksi: waktu,
        ),
      );
    }

    await basisData.batch((batch) {
      batch.insertAll(basisData.tabelTransaksi, daftarTx);
    });

    final totalTx = await basisData.customSelect('SELECT COUNT(*) AS total FROM tabel_transaksi;').getSingle();
    expect(totalTx.read<int>('total'), equals(20000));

    // A. UKUR EKSPOR CADANGAN
    final swEkspor = Stopwatch()..start();
    final jsonCadangan = await cadanganRepo.eksporCadanganKeJson();
    swEkspor.stop();
    final waktuEksporMs = swEkspor.elapsedMilliseconds;
    final ukuranJsonBytes = utf8.encode(jsonCadangan).length;
    final ukuranJsonKB = ukuranJsonBytes / 1024.0;
    final ukuranJsonMB = ukuranJsonKB / 1024.0;

    // ignore: avoid_print
    print('=== TOLOK UKUR CADANGAN DATA (20.000 TRANSAKSI + 20 UTANG + 20 TAGIHAN) ===');
    // ignore: avoid_print
    print('Waktu Ekspor Cadangan: ${waktuEksporMs}ms');
    // ignore: avoid_print
    print('Ukuran Berkas Cadangan: $ukuranJsonBytes bytes (${ukuranJsonKB.toStringAsFixed(1)} KB / ${ukuranJsonMB.toStringAsFixed(2)} MB)');

    // B. UKUR PEMULIHAN CADANGAN
    final validasi = await cadanganRepo.validasiDanBuatPratinjau(jsonCadangan);
    final swPulih = Stopwatch()..start();
    await cadanganRepo.pulihkanCadangan(validasi.dokumen, simpanKeselamatanOtomatis: false);
    swPulih.stop();
    final waktuPulihMs = swPulih.elapsedMilliseconds;

    // ignore: avoid_print
    print('Waktu Pemulihan Cadangan: ${waktuPulihMs}ms');

    // Verifikasi data setelah pulih
    final totalTxSetelahPulih = await basisData.customSelect('SELECT COUNT(*) AS total FROM tabel_transaksi;').getSingle();
    expect(totalTxSetelahPulih.read<int>('total'), equals(20000));

    // C. UKUR PERFORMA BUKA / PENYUSUNAN LAPORAN BULANAN (Warm-up + 10 Iterasi)
    final awalBulan = DateTime(2026, 11, 1);
    final akhirBulan = DateTime(2026, 11, 30, 23, 59, 59, 999);
    final jsonKonten = await File('aset/konten/laporan.json').readAsString();
    final kontenLaporan = PembacaKonten.uraiLaporan(jsonKonten);

    Future<LaporanBulanan> jalankanKueriLaporan() async {
      final arusKas = await transaksiRepo.hitungArusKasSQL(mulai: awalBulan, selesai: akhirBulan);

      const sqlKomposisi = '''
        SELECT 
          COALESCE(k.sifat, 'belum_dilabeli') AS sifat,
          COALESCE(k.nama, 'Tanpa Kategori') AS nama_kategori,
          COALESCE(SUM(t.jumlah_rupiah), 0) AS total
        FROM tabel_transaksi t
        LEFT JOIN tabel_kategori k ON t.kategori_id = k.id
        WHERE t.waktu_transaksi >= ? AND t.waktu_transaksi <= ? AND t.jenis = 'keluar'
        GROUP BY COALESCE(k.sifat, 'belum_dilabeli'), COALESCE(k.nama, 'Tanpa Kategori');
      ''';
      final rowsKomposisi = await basisData.customSelect(
        sqlKomposisi,
        variables: [
          drift.Variable.withDateTime(awalBulan),
          drift.Variable.withDateTime(akhirBulan),
        ],
      ).get();

      final perSifat = <String, int>{
        'kebutuhan': 0,
        'keinginan': 0,
        'tabungan': 0,
        'utang': 0,
        'belum_dilabeli': 0,
      };

      for (final r in rowsKomposisi) {
        final sifat = r.read<String>('sifat');
        final total = r.read<int>('total');
        final sifatNormal = perSifat.containsKey(sifat) ? sifat : 'belum_dilabeli';
        perSifat[sifatNormal] = (perSifat[sifatNormal] ?? 0) + total;
      }

      final dompetAktif = await (basisData.select(basisData.tabelDompet)..where((t) => t.diarsipkan.equals(false))).get();
      var totalSaldoDompet = 0;
      for (final d in dompetAktif) {
        totalSaldoDompet += await transaksiRepo.hitungSaldoDompetSQL(
          dompetId: d.id,
          saldoAwalRupiah: d.saldoAwalRupiah,
        );
      }

      final masukan = MasukanLaporanBulanan(
        bulan: awalBulan,
        waktuDibuat: DateTime(2026, 11, 30),
        uangMasukRupiah: arusKas.totalMasuk,
        uangKeluarRupiah: arusKas.totalKeluar,
        pengeluaranPerSifat: perSifat,
        daftarPosAnggaran: const [],
        daftarTujuanAktif: const [],
        saldoDompetAktifRupiah: totalSaldoDompet,
        sisaUtangAktifRupiah: 80000000,
        kategoriBelumDilabeliTerpakai: const [],
      );

      return susunLaporanBulanan(masukan, konten: kontenLaporan);
    }

    // Warm-up 1x
    final laporanContoh = await jalankanKueriLaporan();

    // 10 Iterasi
    final durasiList = <int>[];
    for (int i = 0; i < 10; i++) {
      final sw = Stopwatch()..start();
      await jalankanKueriLaporan();
      sw.stop();
      durasiList.add(sw.elapsedMilliseconds);
    }

    final rataRataKueriMs = durasiList.reduce((a, b) => a + b) / durasiList.length;
    // ignore: avoid_print
    print('=== TOLOK UKUR WAKTU SUSUN LAPORAN (20.000 TRANSAKSI) ===');
    // ignore: avoid_print
    print('Waktu Susun Laporan (10 iterasi): $durasiList');
    // ignore: avoid_print
    print('Rata-rata Waktu Susun Laporan: ${rataRataKueriMs.toStringAsFixed(1)}ms');

    // D. UKUR EKSPOR PDF
    final pembuatPdf = await PembuatPdfLaporan.muatDariAset();
    final swPdf = Stopwatch()..start();
    final bytesPdf = await pembuatPdf.buatPdf(laporan: laporanContoh, konten: kontenLaporan, sensor: false);
    swPdf.stop();
    final waktuPdfMs = swPdf.elapsedMilliseconds;

    // ignore: avoid_print
    print('=== TOLOK UKUR EKSPOR DOKUMEN LAPORAN ===');
    // ignore: avoid_print
    print('Waktu Render PDF: ${waktuPdfMs}ms (Ukuran: ${bytesPdf.length} bytes / ${(bytesPdf.length / 1024).toStringAsFixed(1)} KB)');

    expect(waktuEksporMs, lessThan(3000));
    expect(waktuPulihMs, lessThan(3000));
    expect(rataRataKueriMs, lessThan(500));
    expect(bytesPdf.isNotEmpty, isTrue);
  });

  test('Uji Kesetaraan Agregasi SQL vs Fungsi Murni Dart pada Komposisi dan Saldo Dompet', () async {
    final awal = DateTime(2026, 11, 1);
    final akhir = DateTime(2026, 11, 30, 23, 59, 59, 999);

    // Siapkan data dompet, kategori, dan transaksi uji
    await basisData.into(basisData.tabelDompet).insert(
          TabelDompetCompanion.insert(
            id: 'd1',
            nama: 'Dompet 1',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: '#006C4C',
            saldoAwalRupiah: const drift.Value(200000),
          ),
        );

    await basisData.into(basisData.tabelKategori).insert(
          TabelKategoriCompanion.insert(
            id: 'k_butuh',
            nama: 'Kebutuhan',
            arus: 'keluar',
            sifat: 'kebutuhan',
            ikon: 'coffee',
          ),
        );
    await basisData.into(basisData.tabelKategori).insert(
          TabelKategoriCompanion.insert(
            id: 'k_ingin',
            nama: 'Keinginan',
            arus: 'keluar',
            sifat: 'keinginan',
            ikon: 'gamepad',
          ),
        );

    // 10 transaksi masuk dan keluar
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 't1',
            dompetId: 'd1',
            jumlahRupiah: 100000,
            jenis: 'masuk',
            waktuTransaksi: DateTime(2026, 11, 5),
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 't2',
            dompetId: 'd1',
            kategoriId: const drift.Value('k_butuh'),
            jumlahRupiah: 40000,
            jenis: 'keluar',
            waktuTransaksi: DateTime(2026, 11, 10),
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 't3',
            dompetId: 'd1',
            kategoriId: const drift.Value('k_ingin'),
            jumlahRupiah: 25000,
            jenis: 'keluar',
            waktuTransaksi: DateTime(2026, 11, 15),
          ),
        );

    // 1. Uji kesetaraan Saldo Dompet: SQL vs Dart
    final semuaTx = await basisData.select(basisData.tabelTransaksi).get();
    final saldoDart = hitungSaldoDompet(
      dompetId: 'd1',
      saldoAwalRupiah: 200000,
      daftarTransaksi: semuaTx,
    );
    final saldoSql = await transaksiRepo.hitungSaldoDompetSQL(
      dompetId: 'd1',
      saldoAwalRupiah: 200000,
    );
    expect(saldoSql, equals(saldoDart));
    expect(saldoSql, equals(200000 + 100000 - 40000 - 25000));

    // 2. Uji kesetaraan Komposisi Per Sifat: SQL vs Dart
    final perSifatDart = <String, int>{
      'kebutuhan': 0,
      'keinginan': 0,
    };
    final semuaKat = await basisData.select(basisData.tabelKategori).get();
    final petaKat = {for (final k in semuaKat) k.id: k};
    for (final tx in semuaTx) {
      if (tx.jenis == 'keluar') {
        final sifat = tx.kategoriId != null ? petaKat[tx.kategoriId]?.sifat : null;
        if (sifat != null && perSifatDart.containsKey(sifat)) {
          perSifatDart[sifat] = perSifatDart[sifat]! + tx.jumlahRupiah;
        }
      }
    }

    const sqlKomposisi = '''
      SELECT 
        COALESCE(k.sifat, 'belum_dilabeli') AS sifat,
        COALESCE(SUM(t.jumlah_rupiah), 0) AS total
      FROM tabel_transaksi t
      LEFT JOIN tabel_kategori k ON t.kategori_id = k.id
      WHERE t.waktu_transaksi >= ? AND t.waktu_transaksi <= ? AND t.jenis = 'keluar'
      GROUP BY COALESCE(k.sifat, 'belum_dilabeli');
    ''';
    final rowsSql = await basisData.customSelect(
      sqlKomposisi,
      variables: [
        drift.Variable.withDateTime(awal),
        drift.Variable.withDateTime(akhir),
      ],
    ).get();
    final perSifatSql = <String, int>{};
    for (final r in rowsSql) {
      perSifatSql[r.read<String>('sifat')] = r.read<int>('total');
    }

    expect(perSifatSql['kebutuhan'], equals(perSifatDart['kebutuhan']));
    expect(perSifatSql['keinginan'], equals(perSifatDart['keinginan']));
  });
}
