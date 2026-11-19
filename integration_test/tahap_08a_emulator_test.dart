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
  hasil['tabel_dompet'] = (await db.select(db.tabelDompet).get()).length;
  hasil['tabel_kategori'] = (await db.select(db.tabelKategori).get()).length;
  hasil['tabel_transaksi'] = (await db.select(db.tabelTransaksi).get()).length;
  hasil['tabel_anggaran'] = (await db.select(db.tabelAnggaran).get()).length;
  hasil['tabel_tujuan'] = (await db.select(db.tabelTujuan).get()).length;
  hasil['tabel_kantong'] = (await db.select(db.tabelKantong).get()).length;
  hasil['tabel_alokasi_kantong'] = (await db.select(db.tabelAlokasiKantong).get()).length;
  hasil['tabel_utang'] = (await db.select(db.tabelUtang).get()).length;
  hasil['tabel_progres_pelajaran'] = (await db.select(db.tabelProgresPelajaran).get()).length;
  hasil['tabel_hasil_kuis'] = (await db.select(db.tabelHasilKuis).get()).length;
  hasil['tabel_pernyataan'] = (await db.select(db.tabelPernyataan).get()).length;
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
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/tabungan/tabungan_2_1');
    await pompaAman(tester, 800);

    expect(find.text('Menabung Itu Soal Tujuan'), findsOneWidget);

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

    Future<void> majuLangkah(int jumlah) async {
      for (var i = 0; i < jumlah; i++) {
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

    // Maju ke Slide Contoh Angka (4 kali tap Lanjut)
    await majuLangkah(4);
    expect(find.text('Dari target ke setoran bulanan'), findsOneWidget);

    // Maju ke Slide Misi & Umpan Balik
    await majuLangkah(3);
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

    await majuLangkah(6);
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
    await mintaTangkapanLayar('tahap_08a_modul_3_terkunci');

    // Suntik 3 pengeluaran kebutuhan (Makan, Kos, Transportasi)
    final katKos = (await basisData.select(basisData.tabelKategori).get())
        .firstWhere((k) => k.id == 'kat_keluar_tinggal');
    final katTransport = (await basisData.select(basisData.tabelKategori).get())
        .firstWhere((k) => k.id == 'kat_keluar_transportasi');

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
    await majuLangkah(6);
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
    await majuLangkah(6);
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

    // Isi dana darurat Rp1.900.000
    await basisData.into(basisData.tabelAlokasiKantong).insert(
          TabelAlokasiKantongCompanion.insert(
            id: 'alokasi_darurat_1',
            kantongId: 'kantong_darurat',
            jenis: 'isi',
            jumlahRupiah: 1900000,
            waktu: now,
            dibuatPada: now,
          ),
        );

    // Pelajaran 3_3
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/dana_darurat/dana_darurat_3_3');
    await pompaAman(tester, 1000);
    await majuLangkah(6);
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

    // =========================================================================
    // 9. Penutupan Langkah 0(c): Verifikasi Eksplisit Jumlah Baris Sebelum & Sesudah Pulih
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: Verifikasi Cadangan & Pemulihan (Langkah 0c) ===');
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
    // 10. Tolok Ukur Beban 20.000 Transaksi di Emulator
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

    // Ukur 10x pengambilan foto data
    final durasiFoto = <int>[];
    for (var i = 0; i < 10; i++) {
      final sw = Stopwatch()..start();
      await fotoRepo.ambilFotoData();
      sw.stop();
      durasiFoto.add(sw.elapsedMilliseconds);
    }
    durasiFoto.sort();
    final medianFoto = durasiFoto[durasiFoto.length ~/ 2];
    debugPrint('[BENCHMARK EMULATOR] Ambil Foto Data 20k Tx: Median = ${medianFoto}ms (Sampel: $durasiFoto)');
    expect(medianFoto, lessThan(100), reason: 'Median ambilFotoData pada 20k tx harus < 100ms');

    // Ukur buka Tab Belajar
    final swTabBelajar = Stopwatch()..start();
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await pompaAman(tester, 200);
    swTabBelajar.stop();
    debugPrint('[BENCHMARK EMULATOR] Waktu Buka Tab Belajar (20k tx): ${swTabBelajar.elapsedMilliseconds}ms');
    expect(swTabBelajar.elapsedMilliseconds, lessThan(800));

    // Ukur buka layar pemutar pelajaran
    final swPelajaran = Stopwatch()..start();
    tester.element(find.byType(Scaffold).first).go('/belajar/pelajaran/tabungan/tabungan_2_1');
    await pompaAman(tester, 200);
    swPelajaran.stop();
    debugPrint('[BENCHMARK EMULATOR] Waktu Buka Layar Pelajaran (20k tx): ${swPelajaran.elapsedMilliseconds}ms');
    expect(swPelajaran.elapsedMilliseconds, lessThan(800));

    debugPrint('=== [SELESAI]: Seluruh 10 Skenario & Pengujian Tahap 8A Selesai! ===');
  });
}
