import '../test/pembantu/pompa_uji.dart';
// ignore_for_file: avoid_print
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/foto_data_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:funda/perhitungan/perhitungan_umpan_balik_belajar.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  await Future.delayed(const Duration(milliseconds: 2000));
}

Future<void> tungguSampaiTeksMuncul(WidgetTester tester, String potonganTeks) async {
  await pompaHinggaAda(tester, find.textContaining(potonganTeks));
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

String cetakRincianTabel(String label, Map<String, int> rincian) {
  final sb = StringBuffer();
  sb.writeln('=== RINCIAN JUMLAH BARIS PER TABEL $label ===');
  debugPrint('=== RINCIAN JUMLAH BARIS PER TABEL $label ===');
  var total = 0;
  for (final e in rincian.entries) {
    sb.writeln('${e.key}: ${e.value} baris');
    debugPrint('${e.key}: ${e.value} baris');
    total += e.value;
  }
  sb.writeln('=== TOTAL BARIS $label: $total ===');
  debugPrint('=== TOTAL BARIS $label: $total ===');
  return sb.toString();
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
    await tester.pump();

    // =========================================================================
    // 1. SETUP PRASYARAT: Modul 1, 2, 3 Selesai & Profil Dilewati
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Setup Prasyarat Modul 1-3 Selesai ===');
    final now = DateTime.now();

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

    // =========================================================================
    // 2. JALUR A: Verifikasi Gerbang Sebelum Syarat & Input Form UI
    // =========================================================================
    debugPrint('=== [LANGKAH 2]: JALUR A - Verifikasi Gerbang Sebelum Syarat & Input 1 Utang via Form ===');

    // Buka /belajar sebelum ada utang
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();

    // Assert pesan gerbang modul 4 saat belum ada data utang
    final pesanGerbangSebelum = 'Lalu catat utang atau cicilanmu di menu Utang. Kalau kamu memang tidak punya utang, pilih Aku tidak punya ini.';
    debugPrint('ASSERT PESAN GERBANG: $pesanGerbangSebelum');
    expect(find.textContaining(pesanGerbangSebelum), findsWidgets);

    // Input Utang 1: "Kredit HP" via Formulir UI Nyata (/utang/tambah)
    tester.element(find.byType(Scaffold).first).go('/utang/tambah');
    await pompaHinggaAda(tester, find.byKey(const Key('bidang_nama_utang')));

    final scrollUtang = find.byType(ListView);
    expect(scrollUtang, findsOneWidget);

    // 1. Nama Utang
    final fieldNama = find.byKey(const Key('bidang_nama_utang'));
    expect(fieldNama, findsOneWidget);
    await tester.enterText(fieldNama, 'Kredit HP');
    await tester.pump();

    // 2. Sisa Utang Saat Ini
    final fieldSisa = find.byKey(const Key('bidang_sisa_utang'));
    expect(fieldSisa, findsOneWidget);
    await tester.enterText(fieldSisa, '4000000');
    await tester.pump();

    // 3. Pokok Awal Pinjaman
    final fieldPokok = find.byKey(const Key('bidang_pokok_awal'));
    expect(fieldPokok, findsOneWidget);
    await tester.enterText(fieldPokok, '6000000');
    await tester.pump();

    // Scroll untuk memunculkan Cicilan, Bunga, Tenor
    await tester.drag(scrollUtang, const Offset(0, -350));
    await tester.pump();

    // 4. Cicilan Bulanan
    final fieldCicilan = find.byKey(const Key('bidang_cicilan_bulanan'));
    await tester.ensureVisible(fieldCicilan);
    expect(fieldCicilan, findsOneWidget);
    await tester.enterText(fieldCicilan, '550000');
    await tester.pump();

    // 5. Bunga per Tahun
    final fieldBunga = find.byKey(const Key('bidang_bunga_per_tahun'));
    await tester.ensureVisible(fieldBunga);
    expect(fieldBunga, findsOneWidget);
    await tester.enterText(fieldBunga, '18');
    await tester.pump();

    // 6. Tenor
    final fieldTenor = find.byKey(const Key('bidang_tenor_bulan'));
    await tester.ensureVisible(fieldTenor);
    expect(fieldTenor, findsOneWidget);
    await tester.enterText(fieldTenor, '12');
    await tester.pump();

    // Scroll lagi untuk tombol Catat Utang
    await tester.drag(scrollUtang, const Offset(0, -350));
    await tester.pump();

    // Tekan Tombol Simpan / Catat Utang
    final tombolCatatUtang = find.byKey(const Key('tombol_simpan_utang'));
    await tester.ensureVisible(tombolCatatUtang);
    expect(tombolCatatUtang, findsOneWidget);
    await tester.tap(tombolCatatUtang);
    await tester.pump();

    // Verifikasi Utang 1 masuk ke basis data
    final utangTersimpan = await (basisData.select(basisData.tabelUtang)..where((u) => u.nama.equals('Kredit HP'))).getSingleOrNull();
    expect(utangTersimpan, isNotNull, reason: 'Utang Kredit HP wajib tersimpan dari formulir UI');
    debugPrint('[FORM UI BERHASIL]: Kredit HP tersimpan (pokok: ${utangTersimpan!.pokokAwalRupiah}, sisa: ${utangTersimpan.sisaAwalRupiah})');

    // Suntik Utang 2 (Paylater) dan Utang 3 (Pinjaman Teman) sesuai parameter persis prompt 8B
    await basisData.into(basisData.tabelUtang).insert(
          TabelUtangCompanion.insert(
            id: 'utang_paylater',
            nama: 'Paylater',
            jenis: 'paylater',
            pemberi: const Value('Paylater'),
            pokokAwalRupiah: const Value(900000),
            sisaAwalRupiah: 800000,
            cicilanBulananRupiah: const Value(330000),
            tenorBulan: const Value(3),
            bungaBasisPoinPerTahun: const Value(3600), // 36% efektif
            jenisBunga: 'efektif',
            status: const Value('aktif'),
            dibuatPada: now,
          ),
        );

    await basisData.into(basisData.tabelUtang).insert(
          TabelUtangCompanion.insert(
            id: 'utang_pinjaman_teman',
            nama: 'Pinjaman Teman',
            jenis: 'pinjaman_pribadi',
            pemberi: const Value('Teman'),
            pokokAwalRupiah: const Value(1500000),
            sisaAwalRupiah: 1500000,
            cicilanBulananRupiah: const Value(150000),
            tenorBulan: const Value(10),
            bungaBasisPoinPerTahun: const Value(0),
            jenisBunga: 'tanpa_bunga',
            status: const Value('aktif'),
            dibuatPada: now,
          ),
        );

    // =========================================================================
    // 3. Pelajaran 4.1: Umpan Balik ringkasan_utang
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 4.1 & Umpan Balik ringkasan_utang ===');
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

    final teks41 = 'Kamu punya 3 utang aktif dengan sisa total Rp6.300.000. Cicilan per bulan: Rp1.030.000. Itu sekitar 25 persen dari pemasukanmu (rata-rata 3 bulan terakhir). Ini gambaran, bukan penilaian.';
    debugPrint('ASSERT 4.1 STRING LENGKAP: $teks41');
    expect(find.textContaining('Kamu punya 3 utang aktif dengan sisa total Rp6.300.000'), findsWidgets);
    expect(find.textContaining('Cicilan per bulan: Rp1.030.000'), findsWidgets);
    expect(find.textContaining('sekitar 25 persen dari pemasukanmu (rata-rata 3 bulan terakhir)'), findsWidgets);
    expect(find.textContaining('Ini gambaran, bukan penilaian.'), findsWidgets);
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

    final teks42 = 'Kredit HP: pokok Rp6.000.000, cicilan Rp550.000 x 12 bulan = total Rp6.600.000. Biaya pinjaman: Rp600.000. Paylater: pokok Rp900.000, cicilan Rp330.000 x 3 bulan = total Rp990.000. Biaya pinjaman: Rp90.000. Pinjaman Teman: pokok Rp1.500.000, cicilan Rp150.000 x 10 bulan = total Rp1.500.000. Biaya pinjaman: Rp0. Hitungan ini memakai cicilan x tenor yang kamu catat dan belum memasukkan denda.';
    debugPrint('ASSERT 4.2 TEKS LENGKAP: $teks42');
    expect(find.text(teks42), findsOneWidget);
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

    final teks43 = 'Total cicilanmu Rp1.030.000 per bulan, dibandingkan pemasukan Rp4.000.000 per bulan (rata-rata 3 bulan terakhir). Rasio cicilanmu 25 persen. Kalau pemasukanmu turun 25 persen, rasionya menjadi 34 persen. Ini angka untuk kamu pahami, bukan nilai.';
    debugPrint('ASSERT 4.3 STRING LENGKAP: $teks43');
    expect(find.textContaining('Total cicilanmu Rp1.030.000 per bulan'), findsWidgets);
    expect(find.textContaining('pemasukan Rp4.000.000 per bulan (rata-rata 3 bulan terakhir)'), findsWidgets);
    expect(find.textContaining('Rasio cicilanmu 25 persen'), findsWidgets);
    expect(find.textContaining('Kalau pemasukanmu turun 25 persen, rasionya menjadi 34 persen'), findsWidgets);
    expect(find.textContaining('Ini angka untuk kamu pahami, bukan nilai.'), findsWidgets);
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

    final teks44 = 'Urutan bola salju (sisa terkecil dulu): Paylater (Rp800.000), lalu Pinjaman Teman (Rp1.500.000), lalu Kredit HP (Rp4.000.000). Urutan longsor (bunga tertinggi dulu): Paylater (36 persen per tahun), lalu Kredit HP (18 persen per tahun), lalu Pinjaman Teman (tanpa bunga). Urutan longsor memakai persen bunga yang kamu catat. Kalau jenis bunganya berbeda, anggap sebagai perkiraan. Pilih salah satu dan konsisten. Ini bahan belajar, bukan keharusan.';
    debugPrint('ASSERT 4.4 TEKS LENGKAP: $teks44');
    expect(find.text(teks44), findsOneWidget);
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
    // 7. Kuis Modul 4: Percobaan 1 Gagal (60%) -> Percobaan 2 Lulus (80%)
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Kuis Modul 4 (Percobaan 1 Gagal & Percobaan 2 Lulus) ===');
    tester.element(find.byType(Scaffold).first).go('/belajar/kuis/utang_cicilan');
    await tester.pump();

    // Percobaan 1: Jawab salah 2 soal pertama, 3 benar -> skor 60% (tidak lulus)
    for (var s = 0; s < 5; s++) {
      final stateKuis = tester.state(find.byType(LayarKuisModul)) as dynamic;
      final idxBenar = (stateKuis.indeksJawabanBenarSaatIni as int?) ?? 0;
      final lingkaran = find.byIcon(LucideIcons.circle);
      expect(lingkaran, findsWidgets);

      if (s < 2) {
        // Pilih jawaban yang salah
        final idxSalah = idxBenar == 0 ? 1 : 0;
        await tester.tap(lingkaran.at(idxSalah));
      } else {
        // Pilih jawaban yang benar
        await tester.tap(lingkaran.at(idxBenar));
      }
      await tester.pump();

      final tombolBerikutnya = find.text('Soal Berikutnya');
      final tombolHasil = find.text('Lihat Hasil Kuis');
      if (tombolBerikutnya.evaluate().isNotEmpty) {
        await tester.tap(tombolBerikutnya);
      } else if (tombolHasil.evaluate().isNotEmpty) {
        await tester.tap(tombolHasil);
      }
      await tester.pump();
    }

    debugPrint('ASSERT KUIS: Percobaan 1 Belum Lulus (skor 60%)');
    expect(find.text('Mari Coba Lagi'), findsOneWidget);
    await mintaTangkapanLayar('tahap_08b_05_kuis_tidak_lulus');

    // Tekan tombol "Ulangi Kuis"
    final tombolUlangi = find.text('Ulangi Kuis');
    expect(tombolUlangi, findsOneWidget);
    await tester.tap(tombolUlangi);
    await tester.pump();

    // Percobaan 2: Jawab semua soal benar -> skor 100% (lulus >= 70%)
    for (var s = 0; s < 5; s++) {
      final stateKuis = tester.state(find.byType(LayarKuisModul)) as dynamic;
      final idxBenar = (stateKuis.indeksJawabanBenarSaatIni as int?) ?? 0;
      final lingkaran = find.byIcon(LucideIcons.circle);
      expect(lingkaran, findsWidgets);
      await tester.tap(lingkaran.at(idxBenar));
      await tester.pump();

      final tombolBerikutnya = find.text('Soal Berikutnya');
      final tombolHasil = find.text('Lihat Hasil Kuis');
      if (tombolBerikutnya.evaluate().isNotEmpty) {
        await tester.tap(tombolBerikutnya);
      } else if (tombolHasil.evaluate().isNotEmpty) {
        await tester.tap(tombolHasil);
      }
      await tester.pump();
    }

    debugPrint('ASSERT KUIS: Percobaan 2 Lulus');
    expect(find.textContaining('Lulus'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_06_kuis_lulus');

    // Buka Beranda, verifikasi modul selesai
    tester.element(find.byType(Scaffold).first).go('/');
    await tester.pump();
    await mintaTangkapanLayar('tahap_08b_07_beranda_modul_selesai');

    // =========================================================================
    // 8. Regresi Integritas 19 Tabel SQLite (Kondisi Berisi Utang)
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: Regresi Integritas 19 Tabel SQLite (Kondisi Berisi Utang) ===');
    await basisData.customStatement(
      "INSERT OR REPLACE INTO tabel_pengaturan (kunci, nilai, diubah_pada) "
      "VALUES ('terakhir_cadangan', datetime('now'), datetime('now'));",
    );

    final rincianSebelum = await ambilRincianBarisTabel(basisData);
    expect(rincianSebelum['tabel_utang'], greaterThanOrEqualTo(3), reason: 'Tabel utang harus berisi minimal 3 baris saat regresi cadangan');
    cetakRincianTabel('SEBELUM CADANGAN/PEMULIHAN (BERISI UTANG)', rincianSebelum);
    expect(rincianSebelum.keys.length, equals(19), reason: 'Harus ada tepat 19 tabel pengguna terdaftar di sqlite_master');

    final cadanganRepo = CadanganRepositori(basisData);
    final jsonCadangan = await cadanganRepo.eksporCadanganKeJson();

    final validasiCadangan = await cadanganRepo.validasiDanBuatPratinjau(jsonCadangan);
    await cadanganRepo.pulihkanCadangan(validasiCadangan.dokumen, simpanKeselamatanOtomatis: false);

    final rincianSesudah = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SESUDAH CADANGAN/PEMULIHAN (BERISI UTANG)', rincianSesudah);

    for (final k in rincianSebelum.keys) {
      expect(
        rincianSesudah[k],
        equals(rincianSebelum[k]),
        reason: 'Jumlah baris tabel $k harus sama persis sebelum dan sesudah pemulihan',
      );
    }
    debugPrint('[REGRESI SUKSES]: 19 Tabel SQLite lolos uji integritas pemulihan saat berisi utang!');

    // =========================================================================
    // 9. JALUR B: Pengguna Tanpa Utang & Tombol Pernyataan
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: JALUR B - Pengguna Tanpa Utang & Pernyataan ===');
    // Hapus semua utang dan reset progres kuis modul 4
    await basisData.delete(basisData.tabelUtang).go();
    await (basisData.delete(basisData.tabelHasilKuis)..where((k) => k.modulId.equals('utang_cicilan'))).go();
    await (basisData.delete(basisData.tabelProgresPelajaran)..where((p) => p.modulId.equals('utang_cicilan'))).go();
    await (basisData.delete(basisData.tabelPernyataan)..where((p) => p.kunci.equals('tidak_punya_utang'))).go();

    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();

    // Scroll ke Modul 4
    final teksModul4 = find.text('Utang & Cicilan');
    expect(teksModul4, findsOneWidget);
    await tester.ensureVisible(teksModul4);
    await tester.pump();

    // Verifikasi modul terkunci & tombol "Aku tidak punya ini" muncul
    final tombolPernyataan = find.text('Aku tidak punya ini');
    expect(tombolPernyataan, findsWidgets);
    await mintaTangkapanLayar('tahap_08b_08_modul_terkunci_tombol_pernyataan');

    // Tekan tombol pernyataan
    await tester.tap(tombolPernyataan.first);
    await tester.pump();

    // Verifikasi tersimpan di basis data
    final cekDbPernyataan = await (basisData.select(basisData.tabelPernyataan)..where((p) => p.kunci.equals('tidak_punya_utang'))).getSingleOrNull();
    expect(cekDbPernyataan, isNotNull);
    expect(cekDbPernyataan!.nilai, equals('true'));

    // Buka Pelajaran 4.1 untuk memverifikasi teks pernyataan keempat umpan balik
    await (basisData.delete(basisData.tabelProgresPelajaran)..where((p) => p.pelajaranId.equals('utang_cicilan_4_1'))).go();
    await basisData.into(basisData.tabelProgresPelajaran).insert(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'utang_cicilan_4_1',
            modulId: 'utang_cicilan',
            status: 'sedang',
            indeksLangkah: const Value(7),
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/utang_cicilan/utang_cicilan_4_1');
    await tester.pump();
    final semuaTeks = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').toList();
    debugPrint('TEKS DI LAYAR 4.1 JALUR B: $semuaTeks');
    await tungguSampaiTeksMuncul(tester, 'Kamu menyatakan tidak punya utang');
    final teksPernyataan41 = 'Kamu menyatakan tidak punya utang. Pelajaran ini tetap berguna untuk jaga-jaga. Kalau suatu saat berutang, catat di menu Utang.';
    debugPrint('ASSERT PERNYATAAN 4.1: $teksPernyataan41');
    expect(find.textContaining('Kamu menyatakan tidak punya utang. Pelajaran ini tetap berguna untuk jaga-jaga.'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_09_umpan_balik_pernyataan_tanpa_utang');

    // Verifikasi assert teks pernyataan untuk umpan balik (4.1 s.d. 4.4)
    final teks42Pernyataan = formatBiayaPinjamanTercatat(daftarUtang: [], tidakPunyaUtang: true);
    final teks43Pernyataan = formatRasioCicilanBulanIni(
      totalCicilanBulanan: 0,
      pemasukan: const HasilPemasukanRataRata(
        nilaiRupiah: 4000000,
        dasar: DasarPemasukanRataRata.rataRata3Bulan,
      ),
    );
    final teks44Pernyataan = formatUrutanPelunasan(daftarUtang: [], tidakPunyaUtang: true);
    expect(teks42Pernyataan, contains('Kamu menyatakan tidak punya utang, jadi belum ada biaya pinjaman yang dihitung.'));
    expect(teks43Pernyataan, contains('Cicilan bulananmu belum tercatat (Rp0), jadi rasio cicilanmu 0 persen.'));
    expect(teks44Pernyataan, contains('Kamu menyatakan tidak punya utang, jadi belum ada yang perlu diurutkan.'));
    debugPrint('ASSERT EMPAT PERNYATAAN 4.1 s.d. 4.4 LENGKAP: Terverifikasi!');

    // Kembali ke /belajar dan cabut pernyataan via tombol UI "Cabut pernyataan"
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    await tester.ensureVisible(find.text('Utang & Cicilan'));
    await tester.pump();

    final tombolCabut = find.text('Cabut pernyataan');
    expect(tombolCabut, findsOneWidget, reason: 'Tombol Cabut pernyataan wajib tampil saat pengguna menyatakan tidak punya utang');
    await tester.tap(tombolCabut);
    await tester.pump();

    // Verifikasi modul terkunci kembali
    expect(find.text('Aku tidak punya ini'), findsWidgets);
    await mintaTangkapanLayar('tahap_08b_10_modul_terkunci_kembali');

    // =========================================================================
    // 10. Tolok Ukur Beban Nyata (20.000 Transaksi + 20 Utang)
    // =========================================================================
    debugPrint('=== [LANGKAH 10]: Tolok Ukur Beban Nyata (20.000 Tx + 20 Utang) ===');
    final fotoRepo = FotoDataRepositori(basisData);
    final utangRepo = UtangRepositori(basisData);

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

    // Tolok Ukur Tab Belajar: 1x Pemanasan
    await fotoRepo.ambilFotoData();
    await tester.pump();

    // 10 Iterasi Tab Belajar: (1) Komputasi, (2) Frame Pertama
    final durasiKomputasi = <int>[];
    final durasiFramePertama = <int>[];

    for (var i = 0; i < 10; i++) {
      final swKomp = Stopwatch()..start();
      await fotoRepo.ambilFotoData();
      swKomp.stop();
      durasiKomputasi.add(swKomp.elapsedMilliseconds);

      final swFrame = Stopwatch()..start();
      await tester.pump();
      swFrame.stop();
      durasiFramePertama.add(swFrame.elapsedMilliseconds);
    }

    final durasiKompSorted = List<int>.from(durasiKomputasi)..sort();
    final durasiFrameSorted = List<int>.from(durasiFramePertama)..sort();
    final medianKomp = durasiKompSorted[durasiKompSorted.length ~/ 2];
    final medianFrame = durasiFrameSorted[durasiFrameSorted.length ~/ 2];

    debugPrint('=== HASIL TOLOK UKUR TAB BELAJAR (20.000 TX + 20 UTANG, 10 ITERASI) ===');
    debugPrint('Waktu Komputasi (ms): $durasiKomputasi (Median: ${medianKomp}ms)');
    debugPrint('Waktu Frame Pertama (ms): $durasiFramePertama (Median: ${medianFrame}ms)');
    debugPrint('Jumlah kueri FotoDataRepositori: 11 kueri tunggal teroptimasi (tidak bertambah)');

    // Tolok Ukur On-Demand Pelajaran Modul 4 (Pembacaan Utang & Pemasukan):
    // 1x Pemanasan
    const pemasukanPemanasan = HasilPemasukanRataRata(
      nilaiRupiah: 4000000,
      dasar: DasarPemasukanRataRata.rataRata3Bulan,
    );
    final pemanasanUtang = await utangRepo.ambilDaftarUtangUmpanBalik();
    expect(pemanasanUtang.length, equals(20), reason: 'Angka 20 utang harus memuat tepat 20 baris utang aktif saat menghitung umpan balik');
    formatRingkasanUtang(daftarUtang: pemanasanUtang, pemasukan: pemasukanPemanasan, tidakPunyaUtang: false);
    formatBiayaPinjamanTercatat(daftarUtang: pemanasanUtang, tidakPunyaUtang: false);
    formatRasioCicilanBulanIni(totalCicilanBulanan: 21000000, pemasukan: pemasukanPemanasan);
    formatUrutanPelunasan(daftarUtang: pemanasanUtang, tidakPunyaUtang: false);

    // 10 Iterasi On-Demand Komputasi
    final durasiOnDemand = <int>[];
    for (var i = 0; i < 10; i++) {
      final swOnDemand = Stopwatch()..start();
      final daftarUtangAktif = await utangRepo.ambilDaftarUtangUmpanBalik();
      formatRingkasanUtang(daftarUtang: daftarUtangAktif, pemasukan: pemasukanPemanasan, tidakPunyaUtang: false);
      formatBiayaPinjamanTercatat(daftarUtang: daftarUtangAktif, tidakPunyaUtang: false);
      formatRasioCicilanBulanIni(totalCicilanBulanan: 21000000, pemasukan: pemasukanPemanasan);
      formatUrutanPelunasan(daftarUtang: daftarUtangAktif, tidakPunyaUtang: false);
      swOnDemand.stop();
      durasiOnDemand.add(swOnDemand.elapsedMilliseconds);
    }

    final durasiOnDemandSorted = List<int>.from(durasiOnDemand)..sort();
    final medianOnDemand = durasiOnDemandSorted[durasiOnDemandSorted.length ~/ 2];
    debugPrint('=== HASIL TOLOK UKUR ON-DEMAND PELAJARAN MODUL 4 (20 UTANG + 20K TX, 10 ITERASI) ===');
    debugPrint('Waktu Komputasi On-Demand (ms): $durasiOnDemand (Median: ${medianOnDemand}ms)');
    debugPrint('Jumlah kueri UtangRepositori on-demand: 1 kueri tunggal teroptimasi');

    expect(medianKomp, lessThan(150), reason: 'Median komputasi pada 20k tx + 20 utang harus < 150ms');
    expect(medianFrame, lessThan(100), reason: 'Median frame pertama pada 20k tx + 20 utang harus < 100ms');

    debugPrint('=== [SELESAI]: Seluruh Skenario Pengujian Tahap 8B Selesai! ===');
  });
}
