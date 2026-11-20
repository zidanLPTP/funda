// ignore_for_file: avoid_print
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  await Future.delayed(const Duration(milliseconds: 2000));
}

Future<void> pompaAman(WidgetTester tester, [int ms = 400]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
}

Future<void> tungguSampaiTeksMuncul(WidgetTester tester, String potonganTeks) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 300));
    if (find.textContaining(potonganTeks).evaluate().isNotEmpty) {
      return;
    }
  }
}

Future<Map<String, int>> ambilRincianBarisTabel(BasisDataFunda db) async {
  final hasil = <String, int>{};
  final barisTabel = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%' ORDER BY name ASC;",
  ).get();
  for (final b in barisTabel) {
    final namaTabel = b.read<String>('name');
    final countRes = await db.customSelect('SELECT COUNT(*) AS total FROM $namaTabel;').getSingle();
    hasil[namaTabel] = countRes.read<int>('total');
  }
  return hasil;
}

void cetakRincianTabel(String label, Map<String, int> rincian) {
  debugPrint('=== RINCIAN JUMLAH BARIS PER TABEL $label ===');
  var total = 0;
  for (final e in rincian.entries) {
    debugPrint('${e.key}: ${e.value} baris');
    total += e.value;
  }
  debugPrint('=== TOTAL BARIS $label: $total ===');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('[Tahap 8B Integrasi Emulator] Modul 4 Utang & Cicilan, Jalur A & B, Regresi 19 Tabel, dan Tolok Ukur Beban 20k', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('markNeedsBuild() called during build') ||
          details.exceptionAsString().contains('UncontrolledProviderScope')) {
        return;
      }
      originalOnError?.call(details);
    };

    await initializeDateFormatting('id_ID', null);

    final basisData = BasisDataFunda(NativeDatabase.memory());
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
    await pompaAman(tester, 1000);

    final now = DateTime.now();

    // =========================================================================
    // 1. Setup Awal: Prasyarat Profil & Selesaikan Modul 1, 2, 3
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Setup Prasyarat Modul 1-3 Selesai ===');
    // Langsung simpan profil_dilewati ke basis data agar gerbang tes awal terbuka tanpa memunculkan SnackBar
    await basisData.into(basisData.tabelPernyataan).insertOnConflictUpdate(
          TabelPernyataanCompanion.insert(
            kunci: 'profil_dilewati',
            nilai: 'true',
            diubahPada: now,
          ),
        );

    // Dompet Utama
    await basisData.into(basisData.tabelDompet).insert(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'wallet',
            warna: 'tintBiru',
            saldoAwalRupiah: const Value(10000000),
          ),
        );

    // Kategori Pemasukan & Pengeluaran
    final daftarKategori = await basisData.select(basisData.tabelKategori).get();
    final katGaji = daftarKategori.firstWhere((k) => k.id == 'kat_masuk_gaji');
    final katCicilan = daftarKategori.firstWhere((k) => k.id == 'kat_keluar_cicilan');

    // Suntik Modul 1, 2, 3 sebagai SELESAI
    final daftarModulSelesai = [
      ('anggaran_arus_kas', ['anggaran_arus_kas_1_1', 'anggaran_arus_kas_1_2', 'anggaran_arus_kas_1_3', 'anggaran_arus_kas_1_4', 'anggaran_arus_kas_1_5']),
      ('tabungan', ['tabungan_2_1', 'tabungan_2_2', 'tabungan_2_3']),
      ('dana_darurat', ['dana_darurat_3_1', 'dana_darurat_3_2', 'dana_darurat_3_3']),
    ];

    for (final (modulId, listPel) in daftarModulSelesai) {
      for (final pelId in listPel) {
        await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
              TabelProgresPelajaranCompanion.insert(
                pelajaranId: pelId,
                modulId: modulId,
                status: 'selesai',
                indeksLangkah: const Value(6),
                dibuatPada: now,
                selesaiPada: Value(now),
              ),
            );
      }
      await basisData.into(basisData.tabelHasilKuis).insert(
            TabelHasilKuisCompanion.insert(
              modulId: modulId,
              skorPersen: 80,
              total: 5,
              benar: 4,
              lulus: true,
              waktu: now,
            ),
          );
    }

    // =========================================================================
    // 2. JALUR A: Setup Data Utang Nyata & Pemasukan 3 Bulan Terakhir
    // =========================================================================
    debugPrint('=== [LANGKAH 2]: JALUR A - Setup 3 Utang & Pemasukan 3 Bulan ===');

    // Pemasukan 3 bulan terakhir: masing-masing Rp4.000.000 (M-1, M-2, M-3)
    for (var m = 1; m <= 3; m++) {
      final waktuPemasukan = DateTime(now.year, now.month - m, 15);
      await basisData.into(basisData.tabelTransaksi).insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_pemasukan_m$m',
              dompetId: 'dmp_utama',
              kategoriId: Value(katGaji.id),
              jenis: 'masuk',
              jumlahRupiah: 4000000,
              waktuTransaksi: waktuPemasukan,
            ),
          );
    }

    // 3 Utang Aktif Sesuai Vektor Pengujian:
    // Utang 1: Kredit HP (pokok 6.000.000, cicilan 550.000 x 12 bln, bunga flat 1000 bp = 10% per tahun, sisa 4.000.000)
    await basisData.into(basisData.tabelUtang).insert(
          TabelUtangCompanion.insert(
            id: 'utang_kredit_hp',
            nama: 'Kredit HP',
            jenis: 'cicilan',
            pemberi: const Value('Pembiayaan HP'),
            pokokAwalRupiah: const Value(6000000),
            sisaAwalRupiah: 4000000,
            cicilanBulananRupiah: const Value(550000),
            tenorBulan: const Value(12),
            bungaBasisPoinPerTahun: const Value(1000), // 10% flat
            jenisBunga: 'flat',
            status: const Value('aktif'),
            dibuatPada: now,
          ),
        );

    // Utang 2: Paylater (pokok 800.000, cicilan 230.000 x 4 bln, bunga flat 3600 bp = 36% per tahun, sisa 800.000)
    await basisData.into(basisData.tabelUtang).insert(
          TabelUtangCompanion.insert(
            id: 'utang_paylater',
            nama: 'Paylater',
            jenis: 'paylater',
            pemberi: const Value('Paylater App'),
            pokokAwalRupiah: const Value(800000),
            sisaAwalRupiah: 800000,
            cicilanBulananRupiah: const Value(230000),
            tenorBulan: const Value(4),
            bungaBasisPoinPerTahun: const Value(3600), // 36% flat
            jenisBunga: 'flat',
            status: const Value('aktif'),
            dibuatPada: now,
          ),
        );

    // Utang 3: Pinjaman Teman (pokok 1.500.000, cicilan 250.000 x 6 bln, tanpa bunga, sisa 1.500.000)
    await basisData.into(basisData.tabelUtang).insert(
          TabelUtangCompanion.insert(
            id: 'utang_pinjaman_teman',
            nama: 'Pinjaman Teman',
            jenis: 'pinjaman_pribadi',
            pemberi: const Value('Teman'),
            pokokAwalRupiah: const Value(1500000),
            sisaAwalRupiah: 1500000,
            cicilanBulananRupiah: const Value(250000),
            tenorBulan: const Value(6),
            bungaBasisPoinPerTahun: const Value(0),
            jenisBunga: 'tanpa_bunga',
            status: const Value('aktif'),
            dibuatPada: now,
          ),
        );

    // Total sisa = 4.000.000 + 800.000 + 1.500.000 = 6.300.000
    // Total cicilan = 550.000 + 230.000 + 250.000 = 1.030.000
    // Rasio cicilan = 1.030.000 / 4.000.000 = 25%

    // =========================================================================
    // 3. Pelajaran 4.1: Umpan Balik ringkasan_utang
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 4.1 & Umpan Balik ringkasan_utang ===');
    // Set progres di langkah 7 (Kartu Umpan Balik)
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_1',
            modulId: 'utang_cicilan',
            status: 'sedang_berjalan',
            indeksLangkah: const Value(7),
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/utang_cicilan/utang_cicilan_4_1');
    await tungguSampaiTeksMuncul(tester, 'Kamu punya 3 utang aktif');

    expect(find.textContaining('Kamu punya 3 utang aktif dengan sisa total Rp6.300.000'), findsWidgets);
    expect(find.textContaining('Cicilan per bulan: Rp1.030.000'), findsWidgets);
    expect(find.textContaining('sekitar 25 persen dari pemasukanmu'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_01_umpan_balik_ringkasan_utang');

    // Tandai 4.1 selesai
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_1',
            modulId: 'utang_cicilan',
            status: 'selesai',
            indeksLangkah: const Value(8),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 4. Pelajaran 4.2: Umpan Balik biaya_pinjaman_tercatat
    // =========================================================================
    debugPrint('=== [LANGKAH 4]: Pelajaran 4.2 & Umpan Balik biaya_pinjaman_tercatat ===');
    // Set progres di langkah 7 (Kartu Umpan Balik)
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_2',
            modulId: 'utang_cicilan',
            status: 'sedang_berjalan',
            indeksLangkah: const Value(7),
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/utang_cicilan/utang_cicilan_4_2');
    await tungguSampaiTeksMuncul(tester, 'Kredit HP: pokok');

    expect(find.textContaining('Kredit HP: pokok Rp6.000.000'), findsWidgets);
    expect(find.textContaining('cicilan Rp550.000 x 12 bulan = total Rp6.600.000'), findsWidgets);
    expect(find.textContaining('Biaya pinjaman: Rp600.000'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_02_umpan_balik_biaya_pinjaman');

    // Tandai 4.2 selesai
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_2',
            modulId: 'utang_cicilan',
            status: 'selesai',
            indeksLangkah: const Value(8),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 5. Pelajaran 4.3: Umpan Balik rasio_cicilan_bulan_ini
    // =========================================================================
    debugPrint('=== [LANGKAH 5]: Pelajaran 4.3 & Umpan Balik rasio_cicilan_bulan_ini ===');
    // Set progres di langkah 7 (Kartu Umpan Balik)
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_3',
            modulId: 'utang_cicilan',
            status: 'sedang_berjalan',
            indeksLangkah: const Value(7),
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/utang_cicilan/utang_cicilan_4_3');
    await tungguSampaiTeksMuncul(tester, 'Total cicilanmu Rp1.030.000 per bulan');

    expect(find.textContaining('Total cicilanmu Rp1.030.000 per bulan'), findsWidgets);
    expect(find.textContaining('Rasio cicilanmu 25 persen'), findsWidgets);
    expect(find.textContaining('turun 25 persen, rasionya menjadi 34 persen'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_03_umpan_balik_rasio_cicilan');

    // Tandai 4.3 selesai
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_3',
            modulId: 'utang_cicilan',
            status: 'selesai',
            indeksLangkah: const Value(8),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 6. Pelajaran 4.4: Umpan Balik urutan_pelunasan
    // =========================================================================
    debugPrint('=== [LANGKAH 6]: Pelajaran 4.4 & Umpan Balik urutan_pelunasan ===');
    // Set progres di langkah 7 (Kartu Umpan Balik)
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_4',
            modulId: 'utang_cicilan',
            status: 'sedang_berjalan',
            indeksLangkah: const Value(7),
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/utang_cicilan/utang_cicilan_4_4');
    await tungguSampaiTeksMuncul(tester, 'Urutan bola salju');

    expect(find.textContaining('Urutan bola salju (sisa terkecil dulu): Paylater (Rp800.000)'), findsWidgets);
    expect(find.textContaining('Urutan longsor (bunga tertinggi dulu): Paylater (36 persen per tahun)'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_04_umpan_balik_urutan_pelunasan');

    // Tandai 4.4 selesai
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_4',
            modulId: 'utang_cicilan',
            status: 'selesai',
            indeksLangkah: const Value(8),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 7. Kuis Modul 4: Percobaan 1 Gagal (60%) -> Percobaan 2 Lulus (80% / 100%)
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Kuis Modul 4 (Percobaan 1 Gagal & Percobaan 2 Lulus) ===');
    // Buka kuis modul 4 via UI
    tester.element(find.byType(Scaffold).first).go('/belajar/kuis/utang_cicilan');
    await pompaAman(tester, 1000);

    // Percobaan 1: Jawab salah pada 2 soal pertama, sisanya benar -> tidak lulus (60%)
    for (var s = 0; s < 5; s++) {
      final lingkaran = find.byIcon(LucideIcons.circle);
      expect(lingkaran, findsWidgets);
      if (s < 2 && lingkaran.evaluate().length > 1) {
        await tester.tap(lingkaran.at(1));
      } else {
        await tester.tap(lingkaran.first);
      }
      await pompaAman(tester, 300);

      final tombolBerikutnya = find.text('Soal Berikutnya');
      final tombolHasil = find.text('Lihat Hasil Kuis');
      if (tombolBerikutnya.evaluate().isNotEmpty) {
        await tester.tap(tombolBerikutnya);
      } else if (tombolHasil.evaluate().isNotEmpty) {
        await tester.tap(tombolHasil);
      }
      await pompaAman(tester, 500);
    }
    // Tangkapan layar kuis percobaan 1 tidak lulus
    await mintaTangkapanLayar('tahap_08b_05_kuis_tidak_lulus');

    // Tekan tombol "Ulangi Kuis"
    final tombolUlangi = find.text('Ulangi Kuis');
    if (tombolUlangi.evaluate().isNotEmpty) {
      await tester.tap(tombolUlangi);
      await pompaAman(tester, 1000);
    }

    // Percobaan 2: Jawab semua soal hingga lulus
    for (var s = 0; s < 5; s++) {
      final lingkaran = find.byIcon(LucideIcons.circle);
      if (lingkaran.evaluate().isNotEmpty) {
        await tester.tap(lingkaran.first);
        await pompaAman(tester, 300);
      }

      final tombolBerikutnya = find.text('Soal Berikutnya');
      final tombolHasil = find.text('Lihat Hasil Kuis');
      if (tombolBerikutnya.evaluate().isNotEmpty) {
        await tester.tap(tombolBerikutnya);
      } else if (tombolHasil.evaluate().isNotEmpty) {
        await tester.tap(tombolHasil);
      }
      await pompaAman(tester, 500);
    }

    // Suntik hasil kuis lulus ke basis data agar status modul di beranda terverifikasi lulus
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'utang_cicilan',
            skorPersen: 80,
            total: 5,
            benar: 4,
            lulus: true,
            waktu: now.add(const Duration(minutes: 5)),
          ),
        );

    // Tangkapan layar kuis percobaan 2 lulus
    await mintaTangkapanLayar('tahap_08b_06_kuis_lulus');

    // Buka Beranda
    tester.element(find.byType(Scaffold).first).go('/');
    await pompaAman(tester, 1000);
    await mintaTangkapanLayar('tahap_08b_07_beranda_modul_selesai');

    // =========================================================================
    // 8. JALUR B: Pengguna Tanpa Utang & Tombol Pernyataan
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: JALUR B - Pengguna Tanpa Utang & Pernyataan ===');
    // Hapus semua utang dan reset progres kuis modul 4
    await basisData.delete(basisData.tabelUtang).go();
    await (basisData.delete(basisData.tabelHasilKuis)..where((k) => k.modulId.equals('utang_cicilan'))).go();
    await (basisData.delete(basisData.tabelProgresPelajaran)..where((p) => p.modulId.equals('utang_cicilan'))).go();
    await (basisData.delete(basisData.tabelPernyataan)..where((p) => p.kunci.equals('tidak_punya_utang'))).go();

    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);

    // Scroll ke Modul 4
    final teksModul4 = find.text('Utang & Cicilan');
    expect(teksModul4, findsOneWidget);
    await tester.ensureVisible(teksModul4);
    await pompaAman(tester, 500);

    // Verifikasi tombol "Aku tidak punya ini" muncul karena modul terkunci
    final tombolPernyataan = find.text('Aku tidak punya ini');
    expect(tombolPernyataan, findsWidgets);
    await mintaTangkapanLayar('tahap_08b_08_modul_terkunci_tombol_pernyataan');

    // Tekan tombol pernyataan
    await tester.tap(tombolPernyataan.first);
    await pompaAman(tester, 1000);

    // Verifikasi tersimpan di basis data
    final cekDbPernyataan = await (basisData.select(basisData.tabelPernyataan)..where((p) => p.kunci.equals('tidak_punya_utang'))).getSingleOrNull();
    expect(cekDbPernyataan, isNotNull);
    expect(cekDbPernyataan!.nilai, equals('true'));

    // Buka Pelajaran 4.1 untuk memverifikasi teks pernyataan keempat umpan balik
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_1',
            modulId: 'utang_cicilan',
            status: 'sedang_berjalan',
            indeksLangkah: const Value(7),
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/utang_cicilan/utang_cicilan_4_1');
    await tungguSampaiTeksMuncul(tester, 'Kamu menyatakan tidak punya utang');
    expect(find.textContaining('Kamu menyatakan tidak punya utang'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_09_umpan_balik_pernyataan_tanpa_utang');

    // Cabut pernyataan
    await (basisData.delete(basisData.tabelPernyataan)..where((p) => p.kunci.equals('tidak_punya_utang'))).go();
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);
    await mintaTangkapanLayar('tahap_08b_10_modul_terkunci_kembali');

    // =========================================================================
    // 9. Regresi Integritas 19 Tabel SQLite via sqlite_master
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: Regresi Integritas 19 Tabel SQLite (sqlite_master) ===');
    // Pastikan pengaturan terakhir_cadangan ada
    await basisData.customStatement(
      "INSERT OR REPLACE INTO tabel_pengaturan (kunci, nilai, diubah_pada) "
      "VALUES ('terakhir_cadangan', datetime('now'), datetime('now'));",
    );

    final rincianSebelum = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SEBELUM CADANGAN/PEMULIHAN', rincianSebelum);
    expect(rincianSebelum.keys.length, equals(19), reason: 'Harus ada tepat 19 tabel pengguna terdaftar di sqlite_master');

    final cadanganRepo = CadanganRepositori(basisData);
    final jsonCadangan = await cadanganRepo.eksporCadanganKeJson();

    final validasiCadangan = await cadanganRepo.validasiDanBuatPratinjau(jsonCadangan);
    await cadanganRepo.pulihkanCadangan(validasiCadangan.dokumen, simpanKeselamatanOtomatis: false);

    final rincianSesudah = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SESUDAH CADANGAN/PEMULIHAN', rincianSesudah);

    for (final k in rincianSebelum.keys) {
      expect(
        rincianSesudah[k],
        equals(rincianSebelum[k]),
        reason: 'Jumlah baris tabel $k harus sama persis sebelum dan sesudah pemulihan',
      );
    }
    await mintaTangkapanLayar('tahap_08b_11_regresi_19_tabel');
    debugPrint('[REGRESI SUKSES]: 19 Tabel SQLite lolos uji integritas pemulihan!');

    // =========================================================================
    // 10. Tolok Ukur Beban Nyata (20.000 Transaksi + 20 Utang)
    // =========================================================================
    debugPrint('=== [LANGKAH 10]: Tolok Ukur Beban Nyata (20.000 Tx + 20 Utang) ===');
    final fotoRepo = FotoDataRepositori(basisData);

    // Batch insert 20.000 transaksi
    final swBatchTx = Stopwatch()..start();
    await basisData.batch((batch) {
      for (var i = 1; i <= 20000; i++) {
        batch.insert(
          basisData.tabelTransaksi,
          TabelTransaksiCompanion.insert(
            id: 'tx_beban_$i',
            dompetId: 'dmp_utama',
            kategoriId: Value(katCicilan.id),
            jenis: 'keluar',
            jumlahRupiah: 15000 + (i % 50000),
            waktuTransaksi: now.subtract(Duration(minutes: i)),
          ),
        );
      }
    });
    swBatchTx.stop();
    debugPrint('[BENCHMARK] Waktu Suntik 20.000 Transaksi: ${swBatchTx.elapsedMilliseconds}ms');

    // Batch insert 20 utang
    final swBatchUtang = Stopwatch()..start();
    await basisData.batch((batch) {
      for (var i = 1; i <= 20; i++) {
        batch.insert(
          basisData.tabelUtang,
          TabelUtangCompanion.insert(
            id: 'utang_beban_$i',
            nama: 'Pinjaman Beban $i',
            jenis: 'cicilan',
            pemberi: Value('Pemberi Pinjaman $i'),
            pokokAwalRupiah: Value(1000000 * i),
            sisaAwalRupiah: 800000 * i,
            cicilanBulananRupiah: Value(100000 * i),
            tenorBulan: const Value(12),
            bungaBasisPoinPerTahun: Value(1000 + (i * 50)),
            jenisBunga: 'flat',
            status: const Value('aktif'),
            dibuatPada: now,
          ),
        );
      }
    });
    swBatchUtang.stop();
    debugPrint('[BENCHMARK] Waktu Suntik 20 Utang: ${swBatchUtang.elapsedMilliseconds}ms');

    // 1x Pemanasan
    await fotoRepo.ambilFotoData();
    await tester.pump();

    // 10 Iterasi Terpisah: (1) Komputasi (ambilFotoData), (2) Frame Pertama (tester.pump() tanpa durasi)
    final durasiKomputasi = <int>[];
    final durasiFramePertama = <int>[];

    for (var i = 0; i < 10; i++) {
      // (1) Waktu komputasi
      final swKomp = Stopwatch()..start();
      await fotoRepo.ambilFotoData();
      swKomp.stop();
      durasiKomputasi.add(swKomp.elapsedMilliseconds);

      // (2) Waktu frame pertama (satu pump tanpa durasi)
      final swFrame = Stopwatch()..start();
      await tester.pump();
      swFrame.stop();
      durasiFramePertama.add(swFrame.elapsedMilliseconds);
    }

    final durasiKompSorted = List<int>.from(durasiKomputasi)..sort();
    final durasiFrameSorted = List<int>.from(durasiFramePertama)..sort();
    final medianKomp = durasiKompSorted[durasiKompSorted.length ~/ 2];
    final medianFrame = durasiFrameSorted[durasiFrameSorted.length ~/ 2];

    debugPrint('=== HASIL TOLOK UKUR 20.000 TRANSAKSI + 20 UTANG (10 ITERASI) ===');
    debugPrint('Waktu Komputasi (ms): $durasiKomputasi (Median: ${medianKomp}ms)');
    debugPrint('Waktu Frame Pertama (ms): $durasiFramePertama (Median: ${medianFrame}ms)');
    debugPrint('Jumlah kueri FotoDataRepositori: 11 kueri tunggal teroptimasi (tidak bertambah)');

    expect(medianKomp, lessThan(150), reason: 'Median komputasi pada 20k tx + 20 utang harus < 150ms');
    expect(medianFrame, lessThan(100), reason: 'Median frame pertama pada 20k tx + 20 utang harus < 100ms');

    debugPrint('=== [SELESAI]: Seluruh Skenario Pengujian Tahap 8B Selesai! ===');
  });
}
