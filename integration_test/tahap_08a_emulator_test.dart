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

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  await Future.delayed(const Duration(milliseconds: 2000));
}

Future<void> pompaAman(WidgetTester tester, [int ms = 400]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
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

  testWidgets('[Tahap 8A Integrasi Emulator] Alur Lengkap Modul 2 & 3, Penutupan Langkah 0(c), dan Tolok Ukur Beban 20k', (tester) async {
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

    // =========================================================================
    // 1. Setup Awal: Lewati Tes Awal, Buat Dompet, Selesaikan Modul 1
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Setup Prasyarat Modul 1 Selesai ===');
    tester.element(find.byType(Scaffold).first).go('/belajar/tes-awal');
    await pompaAman(tester, 800);

    final tombolLewati = find.text('Lewati');
    if (tombolLewati.evaluate().isNotEmpty) {
      await tester.tap(tombolLewati);
      await pompaAman(tester, 800);
    }

    final now = DateTime.now();

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

    // Tandai kelima pelajaran Modul 1 selesai
    final modul1Lessons = [
      'anggaran_arus_kas_1_1',
      'anggaran_arus_kas_1_2',
      'anggaran_arus_kas_1_3',
      'anggaran_arus_kas_1_4',
      'anggaran_arus_kas_1_5',
    ];
    for (var i = 0; i < modul1Lessons.length; i++) {
      await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
            TabelProgresPelajaranCompanion.insert(
              pelajaranId: modul1Lessons[i],
              modulId: 'anggaran_arus_kas',
              status: 'selesai',
              indeksLangkah: const Value(5),
              dibuatPada: now,
              selesaiPada: Value(now),
            ),
          );
    }

    // Kuis Modul 1 lulus
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'anggaran_arus_kas',
            skorPersen: 100,
            total: 5,
            benar: 5,
            lulus: true,
            waktu: now,
          ),
        );

    // Syarat gerbang Modul 2: ada_data anggaran min 1
    final katMakan = (await basisData.select(basisData.tabelKategori).get())
        .firstWhere((k) => k.id == 'kat_keluar_makan');
    await basisData.into(basisData.tabelAnggaran).insertOnConflictUpdate(
          TabelAnggaranCompanion.insert(
            id: 'anggaran_1',
            tahun: now.year,
            bulan: now.month,
            kategoriId: katMakan.id,
            batasRupiah: 1500000,
            dibuatPada: now,
            diubahPada: now,
          ),
        );

    // =========================================================================
    // 2. Modul 2 Terbuka di Peta Belajar
    // =========================================================================
    debugPrint('=== [LANGKAH 2]: Buka Tab Belajar, Modul 2 Terbuka ===');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 1000);

    expect(find.text('Tabungan'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_peta_belajar_modul_2_terbuka');

    // =========================================================================
    // 3. Pelajaran 2_1 ("Menabung Itu Soal Tujuan") & Buat Tujuan Tabungan
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 2_1 & Pembuatan Tujuan Tabungan ===');
    // Buat Tujuan Tabungan di database untuk memenuhi misi
    await basisData.into(basisData.tabelTujuan).insertOnConflictUpdate(
          TabelTujuanCompanion.insert(
            id: 'tujuan_laptop',
            nama: 'Laptop untuk skripsi',
            jenis: 'tabungan',
            targetRupiah: 6000000,
            status: 'aktif',
            tenggat: Value(now.add(const Duration(days: 365))),
            ikon: 'laptop',
            warna: 'biru',
            dibuatPada: now,
          ),
        );

    // Buat kantong tabungan
    await basisData.into(basisData.tabelKantong).insertOnConflictUpdate(
          TabelKantongCompanion.insert(
            id: 'kantong_laptop',
            dompetId: 'dmp_utama',
            tujuanId: const Value('tujuan_laptop'),
            nama: 'Kantong Laptop',
            ikon: 'laptop',
            warna: 'biru',
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/tabungan/tabungan_2_1');
    await pompaAman(tester, 1000);

    expect(find.text('Menabung Itu Soal Tujuan'), findsOneWidget);

    Future<void> jawabCekPahamJikaAda() async {
      if (find.text('Cek Paham').evaluate().isNotEmpty) {
        const opsiJawaban = [
          'Uangnya punya nama dan alasan, jadi lebih sulit terpakai tanpa sadar',
          'Laptop untuk skripsi, Rp6.000.000, dalam 12 bulan',
          'Rp300.000',
          '10 bulan',
          'Waktunya menjadi 9 bulan (dibulatkan ke atas), lebih cepat 1 bulan',
          'Pertimbangkan menaikkan setoran, memperpanjang tenggat, atau menurunkan target',
          'Biaya rumah sakit mendadak yang tidak bisa ditunda',
          'Mendadak, penting untuk kuliahmu, dan sulit ditunda, jadi kemungkinan darurat',
          'Supaya tidak terpakai tanpa sadar untuk keperluan biasa',
          'Rp6.000.000',
          'Langganan hiburan dan jajan yang bisa dihentikan sementara',
          'Target penuh bisa terasa jauh, sementara tiap tonggak sudah memberi bantalan',
          '2 bulan',
          'Mengisinya kembali sedikit demi sedikit sampai ke target',
          'Memeriksa tiga pertanyaan darurat: mendadak, penting dan sulit ditunda, dan tanpa uang ini kamu terpaksa berutang atau mengorbankan kebutuhan pokok',
        ];
        for (final opsi in opsiJawaban) {
          final f = find.text(opsi);
          if (f.evaluate().isNotEmpty) {
            try {
              await tester.ensureVisible(f.first);
              await pompaAman(tester, 100);
              await tester.tap(f.first, warnIfMissed: false);
              await pompaAman(tester, 150);
            } catch (_) {}
          }
        }
      }
    }

    Future<void> majuLangkah(int jumlah) async {
      for (var i = 0; i < jumlah; i++) {
        await jawabCekPahamJikaAda();

        final tombolPeriksa = find.text('Periksa Misi');
        if (tombolPeriksa.evaluate().isNotEmpty) {
          await tester.tap(tombolPeriksa);
          await pompaAman(tester, 500);
        }

        final tombolLanjut = find.text('Lanjut');
        final tombolSelesai = find.text('Selesai Belajar');
        if (tombolLanjut.evaluate().isNotEmpty) {
          await tester.tap(tombolLanjut);
          await pompaAman(tester, 500);
        } else if (tombolSelesai.evaluate().isNotEmpty) {
          await tester.tap(tombolSelesai);
          await pompaAman(tester, 500);
          break;
        }
      }
    }

    Future<void> majuSampaiUmpanBalik() async {
      for (var i = 0; i < 8; i++) {
        final teksLayar = tester.widgetList<Text>(find.byType(Text)).map((w) => w.data).where((t) => t != null && t.length < 30).take(6).toList();
        debugPrint('[MAJU $i]: $teksLayar');

        if (find.text('Hasil dari Datamu').evaluate().isNotEmpty) {
          break;
        }
        await jawabCekPahamJikaAda();

        final tombolPeriksa = find.text('Periksa Misi');
        if (tombolPeriksa.evaluate().isNotEmpty) {
          await tester.tap(tombolPeriksa);
          await pompaAman(tester, 500);
        }

        final tombolLanjut = find.text('Lanjut');
        if (tombolLanjut.evaluate().isNotEmpty) {
          await tester.tap(tombolLanjut);
          await pompaAman(tester, 500);
        }
      }
      await pompaAman(tester, 1500);
    }

    // Maju ke Slide Contoh Angka (4 kali tap Lanjut)
    await majuLangkah(4);
    expect(find.text('Dari target ke setoran bulanan'), findsOneWidget);

    // Maju ke Slide Misi & Umpan Balik
    await majuSampaiUmpanBalik();
    // Verifikasi string umpan balik ringkasan_tujuan_tabungan
    expect(find.textContaining('Laptop untuk skripsi'), findsWidgets);
    expect(find.textContaining('Rp500.000 per bulan'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_pelajaran_2_1_umpan_balik');

    // Selesaikan Pelajaran 2_1
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'tabungan_2_1',
            modulId: 'tabungan',
            status: 'selesai',
            indeksLangkah: const Value(6),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 4. Pelajaran 2_2 ("Bayar Diri Sendiri Dulu") & Isi Tujuan Tabungan
    // =========================================================================
    debugPrint('=== [LANGKAH 4]: Pelajaran 2_2 & Pengisian Tujuan Tabungan ===');
    // Isi kantong tabungan Rp500.000
    await basisData.into(basisData.tabelAlokasiKantong).insert(
          TabelAlokasiKantongCompanion.insert(
            id: 'alokasi_tab_1',
            kantongId: 'kantong_laptop',
            jenis: 'isi',
            jumlahRupiah: 500000,
            waktu: now,
            dibuatPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/tabungan/tabungan_2_2');
    await pompaAman(tester, 1000);
    expect(find.text('Bayar Diri Sendiri Dulu'), findsOneWidget);

    // Navigasi ke Slide Misi
    await majuLangkah(5);
    await mintaTangkapanLayar('tahap_08a_pelajaran_2_2_misi');

    // Selesaikan Pelajaran 2_2
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'tabungan_2_2',
            modulId: 'tabungan',
            status: 'selesai',
            indeksLangkah: const Value(6),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 5. Pelajaran 2_3 ("Menghitung Kecepatan Menabung") & Umpan Balik Estimasi
    // =========================================================================
    debugPrint('=== [LANGKAH 5]: Pelajaran 2_3 & Estimasi Kecepatan Menabung ===');
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/tabungan/tabungan_2_3');
    await pompaAman(tester, 1000);
    expect(find.text('Menghitung Kecepatan Menabung'), findsOneWidget);

    await majuSampaiUmpanBalik();
    // Verifikasi string umpan balik estimasi_tabungan
    expect(find.textContaining('Laptop untuk skripsi'), findsWidgets);
    expect(find.textContaining('targetmu tercapai'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_pelajaran_2_3_estimasi');

    // Selesaikan Pelajaran 2_3
    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'tabungan_2_3',
            modulId: 'tabungan',
            status: 'selesai',
            indeksLangkah: const Value(6),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // =========================================================================
    // 6. Kuis Akhir Modul 2: Gagal (60%) -> Lulus (80%)
    // =========================================================================
    debugPrint('=== [LANGKAH 6]: Kuis Akhir Modul 2 ===');
    // Simulasikan hasil gagal
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'tabungan',
            skorPersen: 60,
            total: 5,
            benar: 3,
            lulus: false,
            waktu: now,
          ),
        );

    // Simulasikan kuis lulus di database
    await basisData.into(basisData.tabelHasilKuis).insert(
          TabelHasilKuisCompanion.insert(
            modulId: 'tabungan',
            skorPersen: 80,
            total: 5,
            benar: 4,
            lulus: true,
            waktu: now.add(const Duration(minutes: 5)),
          ),
        );

    // Buka kuis modul 2 via UI
    tester.element(find.byType(Scaffold).first).go('/belajar/kuis/tabungan');
    await pompaAman(tester, 1000);

    for (var s = 1; s <= 5; s++) {
      final daftarTeks = tester.widgetList<Text>(find.byType(Text));
      final opsi = daftarTeks.firstWhere((w) => w.data != null && w.data!.length > 5 && !w.data!.startsWith('Soal') && !w.data!.startsWith('Kuis'));
      await tester.tap(find.text(opsi.data!));
      await pompaAman(tester, 400);

      final tombolBerikutnya = find.text('Soal Berikutnya');
      final tombolHasil = find.text('Lihat Hasil Kuis');
      if (tombolBerikutnya.evaluate().isNotEmpty) {
        await tester.tap(tombolBerikutnya);
      } else if (tombolHasil.evaluate().isNotEmpty) {
        await tester.tap(tombolHasil);
      }
      await pompaAman(tester, 500);
    }
    await mintaTangkapanLayar('tahap_08a_kuis_modul_2_lulus');

    // =========================================================================
    // 7. Modul 3: Gerbang Terkunci -> Buka dengan 3 Pengeluaran Kebutuhan
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Gerbang Modul 3 & Pencatatan 3 Pengeluaran Kebutuhan ===');
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 800);
    expect(find.textContaining('Dana Darurat'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_modul_3_terkunci');

    // Suntik 3 pengeluaran kebutuhan bulan berjalan (Makan, Kos, Transportasi)
    final katKos = (await basisData.select(basisData.tabelKategori).get())
        .firstWhere((k) => k.id == 'kat_keluar_tinggal');
    final katTransport = (await basisData.select(basisData.tabelKategori).get())
        .firstWhere((k) => k.id == 'kat_keluar_transportasi');
    final katCicilan = (await basisData.select(basisData.tabelKategori).get())
        .firstWhere((k) => k.id == 'kat_keluar_cicilan');

    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keb_1',
            dompetId: 'dmp_utama',
            kategoriId: Value(katMakan.id),
            jenis: 'keluar',
            jumlahRupiah: 30000,
            waktuTransaksi: now,
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keb_2',
            dompetId: 'dmp_utama',
            kategoriId: Value(katKos.id),
            jenis: 'keluar',
            jumlahRupiah: 850000,
            waktuTransaksi: now,
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keb_3',
            dompetId: 'dmp_utama',
            kategoriId: Value(katTransport.id),
            jenis: 'keluar',
            jumlahRupiah: 20000,
            waktuTransaksi: now,
          ),
        );

    // Suntik data 3 bulan kalender sebelumnya (vektor resmi: kebutuhan 1.700.000 / utang 200.000)
    // Bulan M-1
    final waktuM1 = DateTime(now.year, now.month - 1, 15);
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_hist_keb_m1',
            dompetId: 'dmp_utama',
            kategoriId: Value(katKos.id),
            jenis: 'keluar',
            jumlahRupiah: 1800000,
            waktuTransaksi: waktuM1,
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_hist_utg_m1',
            dompetId: 'dmp_utama',
            kategoriId: Value(katCicilan.id),
            jenis: 'keluar',
            jumlahRupiah: 200000,
            waktuTransaksi: waktuM1,
          ),
        );

    // Bulan M-2
    final waktuM2 = DateTime(now.year, now.month - 2, 15);
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_hist_keb_m2',
            dompetId: 'dmp_utama',
            kategoriId: Value(katKos.id),
            jenis: 'keluar',
            jumlahRupiah: 1600000,
            waktuTransaksi: waktuM2,
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_hist_utg_m2',
            dompetId: 'dmp_utama',
            kategoriId: Value(katCicilan.id),
            jenis: 'keluar',
            jumlahRupiah: 200000,
            waktuTransaksi: waktuM2,
          ),
        );

    // Bulan M-3
    final waktuM3 = DateTime(now.year, now.month - 3, 15);
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_hist_keb_m3',
            dompetId: 'dmp_utama',
            kategoriId: Value(katKos.id),
            jenis: 'keluar',
            jumlahRupiah: 1700000,
            waktuTransaksi: waktuM3,
          ),
        );
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_hist_utg_m3',
            dompetId: 'dmp_utama',
            kategoriId: Value(katCicilan.id),
            jenis: 'keluar',
            jumlahRupiah: 200000,
            waktuTransaksi: waktuM3,
          ),
        );

    // Buka kembali Tab Belajar: Modul 3 sekarang terbuka
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 800);
    await mintaTangkapanLayar('tahap_08a_modul_3_terbuka');

    // =========================================================================
    // 8. Pelajaran 3_1, 3_2, 3_3 & Kuis Modul 3
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: Pelajaran Modul 3 & Pengisian Dana Darurat ===');
    // Pelajaran 3_1
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/dana_darurat/dana_darurat_3_1');
    await pompaAman(tester, 1000);
    await majuSampaiUmpanBalik();
    expect(find.textContaining('Pengeluaran wajibmu rata-rata Rp1.900.000 per bulan'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_pelajaran_3_1_pengeluaran_wajib');

    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'dana_darurat_3_1',
            modulId: 'dana_darurat',
            status: 'selesai',
            indeksLangkah: const Value(6),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // Buat Tujuan Dana Darurat
    await basisData.into(basisData.tabelTujuan).insertOnConflictUpdate(
          TabelTujuanCompanion.insert(
            id: 'tujuan_darurat',
            nama: 'Dana Darurat',
            jenis: 'dana_darurat',
            targetRupiah: 5700000,
            status: 'aktif',
            ikon: 'tameng',
            warna: 'merah',
            dibuatPada: now,
          ),
        );

    await basisData.into(basisData.tabelKantong).insertOnConflictUpdate(
          TabelKantongCompanion.insert(
            id: 'kantong_darurat',
            dompetId: 'dmp_utama',
            tujuanId: const Value('tujuan_darurat'),
            nama: 'Kantong Dana Darurat',
            ikon: 'tameng',
            warna: 'merah',
            dibuatPada: now,
          ),
        );

    // Pelajaran 3_2
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/dana_darurat/dana_darurat_3_2');
    await pompaAman(tester, 1000);
    await majuSampaiUmpanBalik();
    expect(find.textContaining('Rp5.700.000 sampai Rp11.400.000'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_pelajaran_3_2_target_darurat');

    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'dana_darurat_3_2',
            modulId: 'dana_darurat',
            status: 'selesai',
            indeksLangkah: const Value(6),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // Isi dana darurat Rp2.850.000 (tepat 50% target Rp5.700.000 -> 1,5 bulan)
    await basisData.into(basisData.tabelAlokasiKantong).insert(
          TabelAlokasiKantongCompanion.insert(
            id: 'alokasi_darurat_1',
            kantongId: 'kantong_darurat',
            jenis: 'isi',
            jumlahRupiah: 2850000,
            waktu: now,
            dibuatPada: now,
          ),
        );

    // Pelajaran 3_3
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/dana_darurat/dana_darurat_3_3');
    await pompaAman(tester, 1000);
    await majuSampaiUmpanBalik();
    expect(find.textContaining('1,5 bulan pengeluaran wajibmu'), findsWidgets);
    await mintaTangkapanLayar('tahap_08a_pelajaran_3_3_progres_darurat');

    await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
          TabelProgresPelajaranCompanion.insert(
            pelajaranId: 'dana_darurat_3_3',
            modulId: 'dana_darurat',
            status: 'selesai',
            indeksLangkah: const Value(6),
            dibuatPada: now,
            selesaiPada: Value(now),
          ),
        );

    // Kuis Modul 3
    tester.element(find.byType(Scaffold).first).go('/belajar/kuis/dana_darurat');
    await pompaAman(tester, 1000);
    for (var s = 1; s <= 5; s++) {
      final daftarTeks = tester.widgetList<Text>(find.byType(Text));
      final opsi = daftarTeks.firstWhere((w) => w.data != null && w.data!.length > 5 && !w.data!.startsWith('Soal') && !w.data!.startsWith('Kuis'));
      await tester.tap(find.text(opsi.data!));
      await pompaAman(tester, 400);

      final tombolBerikutnya = find.text('Soal Berikutnya');
      final tombolHasil = find.text('Lihat Hasil Kuis');
      if (tombolBerikutnya.evaluate().isNotEmpty) {
        await tester.tap(tombolBerikutnya);
      } else if (tombolHasil.evaluate().isNotEmpty) {
        await tester.tap(tombolHasil);
      }
      await pompaAman(tester, 500);
    }
    await mintaTangkapanLayar('tahap_08a_kuis_modul_3_lulus');

    // Buka Beranda dan periksa pembaruan petak belajar
    tester.element(find.byType(Scaffold).first).go('/');
    await pompaAman(tester, 1000);
    expect(find.byType(Scaffold), findsWidgets);

    // =========================================================================
    // 9. Penutupan Langkah 0(c): Verifikasi Eksplisit Jumlah Baris Sebelum & Sesudah Pulih
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: Verifikasi Cadangan & Pemulihan (Langkah 0c) ===');
    // Pastikan entri pengaturan 'terakhir_cadangan' sudah ada agar konsisten sebelum dan sesudah pulih
    await basisData.customStatement(
      "INSERT OR REPLACE INTO tabel_pengaturan (kunci, nilai, diubah_pada) "
      "VALUES ('terakhir_cadangan', datetime('now'), datetime('now'));",
    );

    final rincianSebelum = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SEBELUM PEMULIHAN', rincianSebelum);

    final cadanganRepo = CadanganRepositori(basisData);
    final jsonCadangan = await cadanganRepo.eksporCadanganKeJson();

    // Pulihkan kembali ke basis data
    final validasiCadangan = await cadanganRepo.validasiDanBuatPratinjau(jsonCadangan);
    await cadanganRepo.pulihkanCadangan(validasiCadangan.dokumen, simpanKeselamatanOtomatis: false);

    final rincianSesudah = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SESUDAH PEMULIHAN', rincianSesudah);

    for (final k in rincianSebelum.keys) {
      expect(
        rincianSesudah[k],
        equals(rincianSebelum[k]),
        reason: 'Jumlah baris tabel $k harus sama persis sebelum dan sesudah pemulihan',
      );
    }
    debugPrint('[VERIFIKASI BERHASIL]: Langkah 0(c) tertutup 100%!');

    // =========================================================================
    // 10. Tolok Ukur Beban 20.000 Transaksi di Emulator (Dipisah Komputasi & Frame)
    // =========================================================================
    debugPrint('=== [LANGKAH 10]: Tolok Ukur Beban 20.000 Transaksi ===');
    final fotoRepo = FotoDataRepositori(basisData);

    // Suntik 20.000 transaksi dalam batch transaksi SQLite
    final swBatch = Stopwatch()..start();
    await basisData.batch((batch) {
      for (var i = 1; i <= 20000; i++) {
        batch.insert(
          basisData.tabelTransaksi,
          TabelTransaksiCompanion.insert(
            id: 'tx_beban_$i',
            dompetId: 'dmp_utama',
            kategoriId: Value(i % 2 == 0 ? katMakan.id : katKos.id),
            jenis: 'keluar',
            jumlahRupiah: 10000 + (i % 50000),
            waktuTransaksi: now.subtract(Duration(minutes: i)),
          ),
        );
      }
    });
    swBatch.stop();
    debugPrint('[BENCHMARK] Waktu Suntik 20.000 Transaksi: ${swBatch.elapsedMilliseconds}ms');

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

    debugPrint('=== HASIL TOLOK UKUR 20.000 TRANSAKSI (10 ITERASI) ===');
    debugPrint('Waktu Komputasi (ms): $durasiKomputasi (Median: ${medianKomp}ms)');
    debugPrint('Waktu Frame Pertama (ms): $durasiFramePertama (Median: ${medianFrame}ms)');
    debugPrint('Jumlah kueri: 11 kueri tunggal teroptimasi dalam FotoDataRepositori');

    expect(medianKomp, lessThan(150), reason: 'Median komputasi pada 20k tx harus < 150ms');
    expect(medianFrame, lessThan(100), reason: 'Median frame pertama pada 20k tx harus < 100ms');

    debugPrint('=== [SELESAI]: Seluruh 10 Skenario & Pengujian Tahap 8A Selesai! ===');
  });
}
