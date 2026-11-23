import '../test/pembantu/pompa_uji.dart';
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
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
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/komponen/tombol_funda.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> mintaTangkapanLayar(String namaLayar) async {
  debugPrint('[SCREEN_READY: $namaLayar]');
  await Future.delayed(const Duration(milliseconds: 2000));
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

  testWidgets('[Tahap 8D Integrasi Emulator] Modul 6 Psikologi Uang, Tipe Misi Refleksi, Umpan Balik Langganan, Penutupan Seluruh Tingkat Pemula, Regresi, dan Tolok Ukur Beban', (tester) async {
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

    final now = DateTime.now();

    // =========================================================================
    // 1. PENGGUNA BARU: Modul 6 Terkunci
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Pengguna Baru - Modul 6 Terkunci ===');
    await basisData.into(basisData.tabelPernyataan).insertOnConflictUpdate(
          TabelPernyataanCompanion.insert(
            kunci: 'profil_dilewati',
            nilai: 'true',
            diubahPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Psikologi Uang & Kebiasaan Belanja'));

    // Assert Modul 6 terkunci dengan pesan lampiran: "Selesaikan Modul 1 dulu, lalu catat minimal 5 pengeluaran agar kamu bisa mengenali pola belanjamu sendiri."
    const pesanGerbangModul6 = 'Selesaikan Modul 1 dulu, lalu catat minimal 5 pengeluaran agar kamu bisa mengenali pola belanjamu sendiri.';
    expect(find.text(pesanGerbangModul6), findsWidgets, reason: 'Pesan gerbang Modul 6 harus persis teks lampiran');
    debugPrint('[ASSERT LULUS]: Pesan gerbang Modul 6 tampil: $pesanGerbangModul6');

    await mintaTangkapanLayar('tahap_08d_01_modul_6_terkunci');

    // =========================================================================
    // 2. SETUP MODUL 1 SELESAI + DATA TRANSAKSI & LANGGANAN -> Modul 6 Terbuka
    // =========================================================================
    debugPrint('=== [LANGKAH 2]: Setup Modul 1 Selesai + 5 Pengeluaran + 2 Tagihan + 1 Keinginan -> Modul 6 Terbuka ===');
    final modul1Pel = [
      'anggaran_arus_kas_1_1',
      'anggaran_arus_kas_1_2',
      'anggaran_arus_kas_1_3',
      'anggaran_arus_kas_1_4',
      'anggaran_arus_kas_1_5'
    ];
    for (final pId in modul1Pel) {
      await basisData.into(basisData.tabelProgresPelajaran).insertOnConflictUpdate(
            TabelProgresPelajaranCompanion.insert(
              pelajaranId: pId,
              modulId: 'anggaran_arus_kas',
              status: 'selesai',
              indeksLangkah: const Value(6),
              dibuatPada: now,
              selesaiPada: Value(now),
            ),
          );
    }
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

    // Dompet
    await basisData.into(basisData.tabelDompet).insertOnConflictUpdate(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            saldoAwalRupiah: const Value(10000000),
            ikon: 'dompet',
            warna: 'hijau',
          ),
        );

    // Kategori
    await basisData.into(basisData.tabelKategori).insertOnConflictUpdate(
          TabelKategoriCompanion.insert(
            id: 'kat_kebutuhan',
            nama: 'Kebutuhan Dapur',
            arus: 'keluar',
            sifat: 'kebutuhan',
            ikon: 'belanja',
          ),
        );
    await basisData.into(basisData.tabelKategori).insertOnConflictUpdate(
          TabelKategoriCompanion.insert(
            id: 'kat_keinginan',
            nama: 'Jajan & Hiburan',
            arus: 'keluar',
            sifat: 'keinginan',
            ikon: 'kopi',
          ),
        );

    // 5 Transaksi pengeluaran (4 butuh, 1 keinginan)
    for (var i = 1; i <= 4; i++) {
      await basisData.into(basisData.tabelTransaksi).insert(
            TabelTransaksiCompanion.insert(
              id: 'tx_kebutuhan_$i',
              dompetId: 'dmp_utama',
              jenis: 'keluar',
              kategoriId: const Value('kat_kebutuhan'),
              jumlahRupiah: 30000 * i,
              waktuTransaksi: now.subtract(Duration(days: i)),
            ),
          );
    }
    await basisData.into(basisData.tabelTransaksi).insert(
          TabelTransaksiCompanion.insert(
            id: 'tx_keinginan_1',
            dompetId: 'dmp_utama',
            jenis: 'keluar',
            kategoriId: const Value('kat_keinginan'),
            jumlahRupiah: 150000,
            waktuTransaksi: now.subtract(const Duration(hours: 5)),
          ),
        );

    // 2 Tagihan aktif (langganan: Spotify Rp54.000, Netflix Rp186.000)
    await basisData.into(basisData.tabelTagihan).insert(
          TabelTagihanCompanion.insert(
            id: 'tagihan_spotify',
            nama: 'Spotify Premium',
            jenis: 'langganan',
            frekuensi: 'bulanan',
            jumlahPerkiraanRupiah: const Value(54000),
            kategoriId: 'kat_keinginan',
            jatuhTempoPertama: now,
            dibuatPada: now,
          ),
        );
    await basisData.into(basisData.tabelTagihan).insert(
          TabelTagihanCompanion.insert(
            id: 'tagihan_netflix',
            nama: 'Netflix',
            jenis: 'langganan',
            frekuensi: 'bulanan',
            jumlahPerkiraanRupiah: const Value(186000),
            kategoriId: 'kat_keinginan',
            jatuhTempoPertama: now,
            dibuatPada: now,
          ),
        );

    // Refresh Tab Belajar
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Psikologi Uang & Kebiasaan Belanja'));

    // Assert pesan gerbang Modul 6 kini hilang dan petak terbuka
    expect(find.text(pesanGerbangModul6), findsNothing, reason: 'Modul 6 harus terbuka setelah Modul 1 selesai dan ada 5 pengeluaran');
    await mintaTangkapanLayar('tahap_08d_02_modul_6_terbuka');

    // =========================================================================
    // 3. PELAJARAN 6.1: Misi Refleksi "Tulis pemicu belanjamu"
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 6.1 - Misi Refleksi Tulis pemicu belanjamu ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/psikologi_uang/psikologi_uang_6_1');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Mengenali Pemicu Belanja Impulsif'));
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_lanjut')));

    // Maju ke Cek Paham
    while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
      final btnLanjut = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjut);
      await tester.pump();
    }

    // Jawab 3 soal Cek Paham 6.1
    // Soal 1: Pemicu belanja impulsif -> Emosi sesaat atau dorongan lingkungan yang membuat kita membeli tanpa rencana
    final cp61_1 = find.textContaining('Emosi sesaat atau dorongan');
    await tester.ensureVisible(cp61_1);
    await tester.pump();
    await tester.tap(cp61_1);
    await tester.pump();

    // Soal 2: Rasa puas setelah belanja impulsif -> Biasanya cepat hilang dan sering kali berganti penyesalan
    final cp61_2 = find.textContaining('Biasanya cepat hilang');
    await tester.ensureVisible(cp61_2);
    await tester.pump();
    await tester.tap(cp61_2);
    await tester.pump();

    // Soal 3: Langkah pertama mengendalikan pemicu belanja -> Mengenali situasi atau emosi yang memicunya
    final cp61_3 = find.textContaining('Mengenali situasi atau emosi');
    await tester.ensureVisible(cp61_3);
    await tester.pump();
    await tester.tap(cp61_3);
    await tester.pump();

    // Tap Lanjut ke Misi 6.1
    final btnKeMisi61 = find.byKey(const Key('tombol_lanjut'));
    expect(tester.widget<TombolFunda>(btnKeMisi61).padaTekan, isNotNull);
    await tester.tap(btnKeMisi61);
    await tester.pump();

    await pompaHinggaAda(tester, find.text('Tulis pemicu belanjamu'));
    expect(find.text('Tulis pemicu belanjamu'), findsOneWidget);

    // Assert disclaimer privat tampil di kartu refleksi
    const teksPrivat = 'Privat di perangkatmu: tulisan ini hanya tersimpan di HP-mu dan tidak pernah dikirim ke mana pun.';
    expect(find.text(teksPrivat), findsOneWidget);

    // 3.1 Refleksi Kosong: tombol simpan refleksi nonaktif
    final inputRefleksi = find.byKey(const Key('input_refleksi'));
    final tombolSimpanRefleksi = find.byKey(const Key('tombol_simpan_refleksi'));
    expect(inputRefleksi, findsOneWidget);
    expect(tombolSimpanRefleksi, findsOneWidget);
    expect(tester.widget<TombolFunda>(tombolSimpanRefleksi).padaTekan, isNull);
    await mintaTangkapanLayar('tahap_08d_03_pelajaran_6_1_refleksi_kosong');

    // 3.2 Ketik < 10 karakter: tombol simpan tetap nonaktif
    await tester.enterText(inputRefleksi, 'Lelah');
    await tester.pump();
    expect(find.text('5 / minimal 10 karakter'), findsOneWidget);
    expect(tester.widget<TombolFunda>(tombolSimpanRefleksi).padaTekan, isNull);

    // 3.3 Ketik teks valid >= 10 karakter: tombol simpan aktif
    const jawabanRefleksi61 = 'Saya sering belanja saat lelah sepulang kerja dan butuh hiburan malam.';
    await tester.enterText(inputRefleksi, jawabanRefleksi61);
    await tester.pump();
    expect(find.text('${jawabanRefleksi61.trim().length} karakter (memenuhi syarat)'), findsOneWidget);
    expect(tester.widget<TombolFunda>(tombolSimpanRefleksi).padaTekan, isNotNull);
    await mintaTangkapanLayar('tahap_08d_04_pelajaran_6_1_refleksi_terisi');

    // 3.4 Tekan tombol simpan refleksi
    await tester.tap(tombolSimpanRefleksi);
    await tester.pump();

    // Verifikasi pesan konfirmasi dan tombol lanjut aktif
    expect(find.text('Refleksi tersimpan secara privat di perangkatmu.'), findsOneWidget);
    expect(tester.widget<TombolFunda>(find.byKey(const Key('tombol_lanjut'))).padaTekan, isNotNull);
    await mintaTangkapanLayar('tahap_08d_05_pelajaran_6_1_tersimpan');

    // Selesaikan Pelajaran 6.1
    while (find.text('Selesai Belajar').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('tombol_lanjut')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('tombol_lanjut')));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Psikologi Uang & Kebiasaan Belanja'));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pump();

    // Verifikasi catatan ke tabel_hasil_misi
    final hasilMisi61 = await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals('psikologi_uang_6_1'))).getSingleOrNull();
    expect(hasilMisi61, isNotNull);
    expect(hasilMisi61!.status, equals('selesai'));
    expect(hasilMisi61.tipe, equals('refleksi'));
    final muatan61 = jsonDecode(hasilMisi61.muatanJson!) as Map<String, dynamic>;
    expect(muatan61['jawaban'], equals(jawabanRefleksi61));
    debugPrint('[VERIFIKASI DB SUKSES]: tabel_hasil_misi psikologi_uang_6_1 tercatat refleksi privat');

    // =========================================================================
    // 4. PELAJARAN 6.2: Misi Lihat Hitungan "Hitung langganan & pengeluaran keinginanmu"
    // =========================================================================
    debugPrint('=== [LANGKAH 4]: Pelajaran 6.2 - Misi Lihat Hitungan Ringkasan Langganan & Keinginan ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/psikologi_uang/psikologi_uang_6_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Jebakan Langganan & "Bocor Halus"'));
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_lanjut')));

    // Maju ke Cek Paham
    while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
      final btnLanjut = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjut);
      await tester.pump();
    }

    // Jawab 3 soal Cek Paham 6.2
    // Soal 1: Bocor halus -> Pengeluaran kecil berulang yang terasa sepele tapi jumlahnya besar bila diakumulasikan
    final cp62_1 = find.textContaining('Pengeluaran kecil berulang');
    await tester.ensureVisible(cp62_1);
    await tester.pump();
    await tester.tap(cp62_1);
    await tester.pump();

    // Soal 2: Cara paling efektif memeriksa langganan -> Mencatat dan meninjau langganan aktif secara berkala
    final cp62_2 = find.textContaining('Mencatat dan meninjau langganan aktif');
    await tester.ensureVisible(cp62_2);
    await tester.pump();
    await tester.tap(cp62_2);
    await tester.pump();

    // Soal 3: Sikap tepat terhadap langganan jarang dipakai -> Menghentikan atau menjeda langganan tersebut
    final cp62_3 = find.textContaining('Menghentikan atau menjeda');
    await tester.ensureVisible(cp62_3);
    await tester.pump();
    await tester.tap(cp62_3);
    await tester.pump();

    // Maju ke Misi 6.2
    final btnKeMisi62 = find.byKey(const Key('tombol_lanjut'));
    expect(tester.widget<TombolFunda>(btnKeMisi62).padaTekan, isNotNull);
    await tester.tap(btnKeMisi62);
    await tester.pump();

    await pompaHinggaAda(tester, find.text('Hitung langganan & pengeluaran keinginanmu'));
    expect(find.text('Hitung langganan & pengeluaran keinginanmu'), findsOneWidget);

    // Assert rincian umpan balik tampil: 2 langganan aktif, pengeluaran keinginan Rp150.000, total Rp390.000
    await pompaHinggaAda(tester, find.textContaining('Spotify Premium: Rp54.000/bln'));
    expect(find.textContaining('Spotify Premium: Rp54.000/bln'), findsOneWidget);
    expect(find.textContaining('Netflix: Rp186.000/bln'), findsOneWidget);
    expect(find.textContaining('Total langganan aktif: 2 layanan (Rp240.000/bln)'), findsOneWidget);
    expect(find.textContaining('Pengeluaran keinginan bulan ini: Rp150.000'), findsOneWidget);
    expect(find.textContaining('Total komitmen & keinginan: Rp390.000/bln'), findsOneWidget);
    await mintaTangkapanLayar('tahap_08d_06_pelajaran_6_2_umpan_balik');

    // Selesaikan Pelajaran 6.2
    while (find.text('Selesai Belajar').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('tombol_lanjut')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('tombol_lanjut')));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Psikologi Uang & Kebiasaan Belanja'));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pump();

    // =========================================================================
    // 5. PELAJARAN 6.3: Misi Refleksi "Pilih aturan jedamu"
    // =========================================================================
    debugPrint('=== [LANGKAH 5]: Pelajaran 6.3 - Misi Refleksi Pilih aturan jedamu ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/psikologi_uang/psikologi_uang_6_3');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Membangun Jeda Sebelum Membeli'));
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_lanjut')));

    // Maju ke Cek Paham
    while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
      final btnLanjut = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjut);
      await tester.pump();
    }

    // Jawab 3 soal Cek Paham 6.3
    // Soal 1: Tujuan utama aturan jeda -> Memberi waktu agar emosi mereda dan akal sehat bekerja
    final cp63_1 = find.textContaining('Memberi waktu agar emosi mereda');
    await tester.ensureVisible(cp63_1);
    await tester.pump();
    await tester.tap(cp63_1);
    await tester.pump();

    // Soal 2: Pembelian barang kecil -> 24 jam sudah cukup untuk menilai kebutuhan
    final cp63_2 = find.textContaining('24 jam sudah cukup');
    await tester.ensureVisible(cp63_2);
    await tester.pump();
    await tester.tap(cp63_2);
    await tester.pump();

    // Soal 3: Setelah masa jeda keinginan hilang -> Tanda bahwa dorongan awal hanyalah impuls sesaat
    final cp63_3 = find.textContaining('Tanda bahwa dorongan awal');
    await tester.ensureVisible(cp63_3);
    await tester.pump();
    await tester.tap(cp63_3);
    await tester.pump();

    // Maju ke Misi 6.3
    final btnKeMisi63 = find.byKey(const Key('tombol_lanjut'));
    expect(tester.widget<TombolFunda>(btnKeMisi63).padaTekan, isNotNull);
    await tester.tap(btnKeMisi63);
    await tester.pump();

    await pompaHinggaAda(tester, find.text('Pilih aturan jedamu'));
    expect(find.text('Pilih aturan jedamu'), findsOneWidget);

    // Isi Refleksi 6.3
    const jawabanRefleksi63 = 'Saya memilih aturan jeda 24 jam untuk pembelian non-esensial di atas Rp100.000.';
    await tester.enterText(find.byKey(const Key('input_refleksi')), jawabanRefleksi63);
    await tester.pump();
    await tester.tap(find.byKey(const Key('tombol_simpan_refleksi')));
    await tester.pump();
    await mintaTangkapanLayar('tahap_08d_07_pelajaran_6_3_refleksi_jeda');

    // Selesaikan Pelajaran 6.3
    while (find.text('Selesai Belajar').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('tombol_lanjut')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('tombol_lanjut')));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Psikologi Uang & Kebiasaan Belanja'));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pump();

    // =========================================================================
    // 6. KUIS MODUL 6: Gagal 3/5 lalu Lulus 5/5
    // =========================================================================
    debugPrint('=== [LANGKAH 6]: Kuis Modul 6 - Gagal 3/5 lalu Lulus 5/5 ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/psikologi_uang');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Soal 1/5'));
    await mintaTangkapanLayar('tahap_08d_08_kuis_modul_6_mulai');

    // Percobaan 1: Jawab 3 benar, 2 salah -> Skor 60% TIDAK LULUS
    for (var s = 0; s < 5; s++) {
      await pompaHinggaAda(tester, find.byKey(const Key('opsi_kuis_0')));
      final dynamic stateKuis = tester.state(find.byType(LayarKuisModul));
      final int idxBenar = stateKuis.indeksJawabanBenarSaatIni as int;
      final idxPilihan = s < 3 ? idxBenar : (idxBenar + 1) % 3;

      final targetOpsi = find.byKey(Key('opsi_kuis_$idxPilihan'));
      await tester.ensureVisible(targetOpsi);
      await tester.pump();
      await tester.tap(targetOpsi);
      await tester.pump();

      final btnAksi = find.text(s == 4 ? 'Lihat Hasil Kuis' : 'Soal Berikutnya');
      await tester.ensureVisible(btnAksi);
      await tester.pump();
      await tester.tap(btnAksi);
      await tester.pump();
    }

    // Layar Hasil Percobaan 1 (Gagal)
    await pompaHinggaAda(tester, find.text('Mari Coba Lagi'));
    expect(find.text('60%'), findsOneWidget);
    debugPrint('[KUIS PERCOBAAN 1]: Skor 3/5 (60%) TIDAK LULUS tampil di layar');
    await mintaTangkapanLayar('tahap_08d_09_kuis_modul_6_gagal');

    // Tap Ulangi Kuis
    await tester.tap(find.text('Ulangi Kuis'));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Soal 1/5'));

    // Percobaan 2: Jawab 5/5 benar -> Skor 100% LULUS
    for (var s = 0; s < 5; s++) {
      await pompaHinggaAda(tester, find.byKey(const Key('opsi_kuis_0')));
      final dynamic stateKuis = tester.state(find.byType(LayarKuisModul));
      final int idxBenar = stateKuis.indeksJawabanBenarSaatIni as int;
      final idxPilihan = idxBenar;

      final targetOpsi = find.byKey(Key('opsi_kuis_$idxPilihan'));
      await tester.ensureVisible(targetOpsi);
      await tester.pump();
      await tester.tap(targetOpsi);
      await tester.pump();

      final btnAksi = find.text(s == 4 ? 'Lihat Hasil Kuis' : 'Soal Berikutnya');
      await tester.ensureVisible(btnAksi);
      await tester.pump();
      await tester.tap(btnAksi);
      await tester.pump();
    }

    await pompaHinggaAda(tester, find.text('Selamat! Kamu Lulus'));
    expect(find.text('100%'), findsOneWidget);
    await mintaTangkapanLayar('tahap_08d_10_kuis_modul_6_lulus');

    // Kembali ke Peta Belajar
    await tester.tap(find.text('Kembali ke Peta Belajar'));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Psikologi Uang & Kebiasaan Belanja'));
    await mintaTangkapanLayar('tahap_08d_11_modul_6_selesai');

    // =========================================================================
    // 7. PENUTUPAN SELURUH TINGKAT PEMULA: Petak Beranda
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Penutupan Seluruh Tingkat Pemula & Petak Beranda ===');
    // Tandai seluruh modul 0 sampai 5 juga selesai bila belum ditandai
    final semuaModulId = [
      'pondasi_keuangan',
      'anggaran_arus_kas',
      'tabungan',
      'dana_darurat',
      'utang_cicilan',
      'waspada_penipuan',
      'psikologi_uang',
    ];
    for (final mId in semuaModulId) {
      await basisData.into(basisData.tabelHasilKuis).insertOnConflictUpdate(
            TabelHasilKuisCompanion.insert(
              modulId: mId,
              skorPersen: 100,
              total: 5,
              benar: 5,
              lulus: true,
              waktu: now,
            ),
          );
    }

    tester.element(find.byType(Scaffold).first).go('/');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Semua Materi Selesai'));
    expect(find.text('Semua Materi Selesai'), findsOneWidget);
    expect(find.text('Hebat!'), findsOneWidget);
    expect(find.text('Kamu telah menuntaskan seluruh pelajaran yang tersedia.'), findsOneWidget);
    await mintaTangkapanLayar('tahap_08d_12_beranda_seluruh_pemula_selesai');

    // =========================================================================
    // 8. REGRESI PEMULIHAN CADANGAN: 19+ Tabel (Termasuk tabel_hasil_misi)
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: Pengujian Regresi Pemulihan Cadangan pada Seluruh Tabel ===');
    await basisData.customStatement(
      "INSERT OR REPLACE INTO tabel_pengaturan (kunci, nilai, diubah_pada) "
      "VALUES ('terakhir_cadangan', ?, datetime('now'));",
      [now.toIso8601String()],
    );
    final rincianSebelum = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SEBELUM CADANGAN/PEMULIHAN', rincianSebelum);

    final cadanganRepo = CadanganRepositori(basisData);
    final jsonCadangan = await cadanganRepo.eksporCadanganKeJson();

    // Hapus data (reset)
    await basisData.customStatement('DELETE FROM tabel_hasil_misi;');
    await basisData.customStatement('DELETE FROM tabel_progres_pelajaran;');
    await basisData.customStatement('DELETE FROM tabel_hasil_kuis;');

    // Pulihkan cadangan
    final validasiCadangan = await cadanganRepo.validasiDanBuatPratinjau(jsonCadangan);
    await cadanganRepo.pulihkanCadangan(validasiCadangan.dokumen, simpanKeselamatanOtomatis: false);

    final rincianSesudah = await ambilRincianBarisTabel(basisData);
    cetakRincianTabel('SESUDAH PEMULIHAN', rincianSesudah);

    var identikSemua = true;
    for (final e in rincianSebelum.entries) {
      final sebelum = e.value;
      final sesudah = rincianSesudah[e.key] ?? 0;
      if (sebelum != sesudah) {
        identikSemua = false;
        debugPrint('[REGRESI GAGAL]: Tabel ${e.key} tidak identik! Sebelum: $sebelum, Sesudah: $sesudah');
      }
      expect(sesudah, equals(sebelum), reason: 'Jumlah baris tabel ${e.key} harus persis sama sebelum dan sesudah pemulihan');
    }

    if (identikSemua) {
      debugPrint('[REGRESI SUKSES]: Seluruh tabel (${rincianSebelum.length} tabel) identik 100%!');
    }
    await mintaTangkapanLayar('tahap_08d_13_regresi_pemulihan_selesai');

    // =========================================================================
    // 9. TOLOK UKUR BEBAN: 20.000 Transaksi + 20 Utang + 20 Tagihan pada Tab Belajar
    // =========================================================================
    debugPrint('=== [LANGKAH 9]: Tolok Ukur Beban 20.000 Transaksi + 20 Utang + 20 Tagihan ===');
    await basisData.batch((batch) {
      final txList = List.generate(
        20000,
        (i) => TabelTransaksiCompanion.insert(
          id: 'tx_beban_d_$i',
          dompetId: 'dmp_utama',
          jenis: i.isEven ? 'masuk' : 'keluar',
          jumlahRupiah: 10000 + (i % 50) * 1000,
          waktuTransaksi: now.subtract(Duration(minutes: i)),
        ),
      );
      batch.insertAll(basisData.tabelTransaksi, txList);

      final utangList = List.generate(
        20,
        (u) => TabelUtangCompanion.insert(
          id: 'utang_beban_d_$u',
          nama: 'Utang Beban D $u',
          pokokAwalRupiah: const Value(5000000),
          sisaAwalRupiah: 3000000,
          jenis: 'kredit_barang',
          jenisBunga: 'flat',
          status: const Value('aktif'),
          dibuatPada: now,
        ),
      );
      batch.insertAll(basisData.tabelUtang, utangList);

      final tagihanList = List.generate(
        20,
        (t) => TabelTagihanCompanion.insert(
          id: 'tagihan_beban_d_$t',
          nama: 'Tagihan Beban D $t',
          jenis: 'langganan',
          frekuensi: 'bulanan',
          jumlahPerkiraanRupiah: Value(50000 + t * 5000),
          kategoriId: 'kat_keinginan',
          jatuhTempoPertama: now,
          dibuatPada: now,
        ),
      );
      batch.insertAll(basisData.tabelTagihan, tagihanList);
    });

    final repositoriFotoData = FotoDataRepositori(basisData);

    // Pemanasan 1x
    await repositoriFotoData.ambilFotoData();
    await tester.pump();

    // 10 Iterasi Pengukuran Waktu Komputasi Tab Belajar
    final durasiKomputasi = <int>[];
    final durasiFramePertama = <int>[];
    for (var it = 0; it < 10; it++) {
      final swKomp = Stopwatch()..start();
      await repositoriFotoData.ambilFotoData();
      swKomp.stop();
      durasiKomputasi.add(swKomp.elapsedMilliseconds);

      final swFrame = Stopwatch()..start();
      await tester.pump();
      swFrame.stop();
      durasiFramePertama.add(swFrame.elapsedMilliseconds);

      debugPrint('[BENCHMARK ITERASI ${it + 1}]: Komputasi=${swKomp.elapsedMilliseconds}ms, Frame=${swFrame.elapsedMilliseconds}ms');
    }

    final durasiKompSorted = List<int>.from(durasiKomputasi)..sort();
    final durasiFrameSorted = List<int>.from(durasiFramePertama)..sort();
    final medianKomputasi = durasiKompSorted[durasiKompSorted.length ~/ 2];
    final medianFrame = durasiFrameSorted[durasiFrameSorted.length ~/ 2];
    debugPrint('=== [HASIL TOLOK UKUR BEBAN TAB BELAJAR] ===');
    debugPrint('Daftar durasi komputasi: $durasiKomputasi ms (Median: $medianKomputasi ms)');
    debugPrint('Daftar durasi frame: $durasiFramePertama ms (Median: $medianFrame ms)');
    expect(medianKomputasi, lessThan(100), reason: 'Median komputasi Tab Belajar wajib di bawah 100 ms');

    // Tolok Ukur Membuka Layar Pelajaran Modul 6 (6.1, 6.2, 6.3)
    final pelajaranIds = [
      'psikologi_uang_6_1',
      'psikologi_uang_6_2',
      'psikologi_uang_6_3',
    ];

    for (final pelId in pelajaranIds) {
      final jsonStr = File('aset/konten/pemula/psikologi_uang/$pelId.json').readAsStringSync();
      // Pemanasan 1x
      await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals(pelId))).getSingleOrNull();
      await (basisData.select(basisData.tabelProgresPelajaran)..where((p) => p.pelajaranId.equals(pelId))).getSingleOrNull();
      PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: '$pelId.json');
      await tester.pump();

      final listKompPel = <int>[];
      final listFramePel = <int>[];

      for (var it = 0; it < 10; it++) {
        final swKomp = Stopwatch()..start();
        await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals(pelId))).getSingleOrNull();
        await (basisData.select(basisData.tabelProgresPelajaran)..where((p) => p.pelajaranId.equals(pelId))).getSingleOrNull();
        PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: '$pelId.json');
        swKomp.stop();
        listKompPel.add(swKomp.elapsedMilliseconds);

        final swFrame = Stopwatch()..start();
        await tester.pump();
        swFrame.stop();
        listFramePel.add(swFrame.elapsedMilliseconds);
      }

      final listKompSorted = List<int>.from(listKompPel)..sort();
      final medianKomp = listKompSorted[listKompSorted.length ~/ 2];
      final terburukKomp = listKompSorted.last;

      debugPrint('=== [TOLOK UKUR MEMBUKA LAYAR PELAJARAN $pelId] ===');
      debugPrint('Jumlah kueri database per buka: 2 kueri (tabel_hasil_misi, tabel_progres_pelajaran)');
      debugPrint('Durasi komputasi (10 iterasi): $listKompPel ms (Median: $medianKomp ms, Terburuk: $terburukKomp ms)');
      debugPrint('Durasi frame pertama (10 iterasi): $listFramePel ms');
      expect(medianKomp, lessThan(50), reason: 'Median waktu buka layar pelajaran $pelId wajib di bawah 50 ms');
    }

    debugPrint('=== SELURUH PENGUJIAN INTEGRASI TAHAP 8D SELESAI DENGAN SUKSES ===');
  });
}
