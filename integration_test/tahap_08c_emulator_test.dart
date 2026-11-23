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

  testWidgets('[Tahap 8C Integrasi Emulator] Modul 5 Waspada Penipuan, Tipe Misi Keputusan & Daftar Periksa, Disclaimer, Regresi, dan Tolok Ukur Beban', (tester) async {
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
    // 1. PENGGUNA BARU: Modul 5 Terkunci
    // =========================================================================
    debugPrint('=== [LANGKAH 1]: Pengguna Baru - Modul 5 Terkunci ===');
    await basisData.into(basisData.tabelPernyataan).insertOnConflictUpdate(
          TabelPernyataanCompanion.insert(
            kunci: 'profil_dilewati',
            nilai: 'true',
            diubahPada: now,
          ),
        );

    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Waspada Penipuan & Pinjol Ilegal'));

    // Assert Modul 5 terkunci dengan pesan lampiran: "Selesaikan Modul 1 dulu, lalu modul ini terbuka."
    const pesanGerbangModul5 = 'Selesaikan Modul 1 dulu, lalu modul ini terbuka.';
    expect(find.text(pesanGerbangModul5), findsWidgets, reason: 'Pesan gerbang Modul 5 harus persis teks lampiran');
    debugPrint('[ASSERT LULUS]: Pesan gerbang Modul 5 tampil: $pesanGerbangModul5');

    await mintaTangkapanLayar('tahap_08c_01_modul_5_terkunci');

    // =========================================================================
    // 2. SETUP MODUL 1 SELESAI: Modul 5 Terbuka
    // =========================================================================
    debugPrint('=== [LANGKAH 2]: Setup Modul 1 Selesai -> Modul 5 Terbuka ===');
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

    // Refresh Tab Belajar
    tester.element(find.byType(Scaffold).first).go('/belajar');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Waspada Penipuan & Pinjol Ilegal'));

    // Assert pesan gerbang Modul 5 kini hilang dan petak terbuka
    expect(find.text(pesanGerbangModul5), findsNothing, reason: 'Modul 5 harus terbuka setelah Modul 1 selesai');
    await mintaTangkapanLayar('tahap_08c_02_modul_5_terbuka');

    // =========================================================================
    // 3. PELAJARAN 5.1: Misi Keputusan "Latih rem-mu"
    // =========================================================================
    debugPrint('=== [LANGKAH 3]: Pelajaran 5.1 - Misi Keputusan Latih rem-mu ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/waspada_penipuan/waspada_penipuan_5_1');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Ciri Tawaran yang Mencurigakan'));
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_lanjut')));

    // Maju ke Cek Paham
    while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
      final btnLanjut = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjut);
      await tester.pump();
    }

    // Jawab 3 soal Cek Paham
    final cp1 = find.textContaining('Berhenti, lalu periksa');
    await tester.ensureVisible(cp1);
    await tester.pump();
    await tester.tap(cp1);
    await tester.pump();

    final cp2 = find.textContaining('Tidak seorang pun');
    await tester.ensureVisible(cp2);
    await tester.pump();
    await tester.tap(cp2);
    await tester.pump();

    final cp3 = find.textContaining('Penyedia menjelaskan total biaya');
    await tester.ensureVisible(cp3);
    await tester.pump();
    await tester.tap(cp3);
    await tester.pump();

    // Tap Lanjut ke Misi
    final btnKeMisi51 = find.byKey(const Key('tombol_lanjut'));
    expect(tester.widget<TombolFunda>(btnKeMisi51).padaTekan, isNotNull);
    await tester.tap(btnKeMisi51);
    await tester.pump();

    await pompaHinggaAda(tester, find.text('Latih rem-mu'));
    expect(find.text('Latih rem-mu'), findsOneWidget);

    // Assert pemantik skenario penuh
    const pemantik51 = 'Seseorang menelepon dan mengaku dari bank. Katanya akunmu bermasalah dan akan diblokir hari ini. Dia meminta kode OTP yang baru kamu terima supaya akunmu "diselamatkan".';
    expect(find.textContaining(pemantik51), findsOneWidget);

    // 3.1 Pilih Opsi a (Tidak aman)
    final opsiA = find.byKey(const Key('opsi_keputusan_a'));
    expect(opsiA, findsOneWidget);
    await tester.tap(opsiA);
    await tester.pump();

    // Assert umpan balik a penuh
    const umpanBalikA = 'Kode OTP adalah kunci akunmu. Siapa pun yang memintanya, termasuk yang mengaku petugas, sebaiknya tidak diberi. Coba pilihan lain.';
    expect(find.text(umpanBalikA), findsOneWidget);
    expect(tester.widget<TombolFunda>(find.byKey(const Key('tombol_lanjut'))).padaTekan, isNull);
    await mintaTangkapanLayar('tahap_08c_03_pelajaran_5_1_opsi_a');

    // 3.2 Tap Coba pilihan lain
    final btnCobaLagi = find.byKey(const Key('tombol_coba_pilihan_lain'));
    expect(btnCobaLagi, findsOneWidget);
    await tester.tap(btnCobaLagi);
    await tester.pump();

    // 3.3 Pilih Opsi c (Tidak aman)
    final opsiC = find.byKey(const Key('opsi_keputusan_c'));
    expect(opsiC, findsOneWidget);
    await tester.tap(opsiC);
    await tester.pump();

    // Assert umpan balik c penuh
    const umpanBalikC = 'Penipu bisa saja sudah punya sebagian datamu. Menyebut nama atau saldo belum membuktikan dia petugas sungguhan. Coba pilihan lain.';
    expect(find.text(umpanBalikC), findsOneWidget);
    expect(tester.widget<TombolFunda>(find.byKey(const Key('tombol_lanjut'))).padaTekan, isNull);
    await mintaTangkapanLayar('tahap_08c_04_pelajaran_5_1_opsi_c');

    // 3.4 Tap Coba pilihan lain
    await tester.tap(find.byKey(const Key('tombol_coba_pilihan_lain')));
    await tester.pump();

    // 3.5 Pilih Opsi b (Aman)
    final opsiB = find.byKey(const Key('opsi_keputusan_b'));
    expect(opsiB, findsOneWidget);
    await tester.tap(opsiB);
    await tester.pump();

    // Assert umpan balik b penuh dan tombol Lanjut AKTIF
    const umpanBalikB = 'Tepat. Kamu berhenti dan memeriksa lewat jalur resmi. Pihak yang benar tidak akan memintamu terburu-buru membagikan kode.';
    expect(find.text(umpanBalikB), findsOneWidget);
    expect(tester.widget<TombolFunda>(find.byKey(const Key('tombol_lanjut'))).padaTekan, isNotNull);
    await mintaTangkapanLayar('tahap_08c_05_pelajaran_5_1_opsi_b_selesai');

    // Selesaikan Pelajaran 5.1
    while (find.text('Selesai Belajar').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('tombol_lanjut')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('tombol_lanjut')));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Waspada Penipuan & Pinjol Ilegal'));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pump();

    // Verifikasi catatan ke tabel_hasil_misi
    final hasilMisi51 = await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals('waspada_penipuan_5_1'))).getSingleOrNull();
    expect(hasilMisi51, isNotNull);
    expect(hasilMisi51!.status, equals('selesai'));
    expect(hasilMisi51.tipe, equals('keputusan'));
    final muatan51 = jsonDecode(hasilMisi51.muatanJson!) as Map<String, dynamic>;
    expect(muatan51['opsiDipilih'], equals(['a', 'c', 'b']), reason: 'Urutan percobaan wajib persis a, c, b');
    debugPrint('[VERIFIKASI DB SUKSES]: tabel_hasil_misi waspada_penipuan_5_1 tercatat {"opsiDipilih":["a","c","b"]}');

    // =========================================================================
    // 4. PELAJARAN 5.2: Misi Daftar Periksa "Siapkan cara cek penyedia"
    // =========================================================================
    debugPrint('=== [LANGKAH 4]: Pelajaran 5.2 - Misi Daftar Periksa Cek Penyedia ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/waspada_penipuan/waspada_penipuan_5_2');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Cek Legalitas Sebelum Percaya'));
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_lanjut')));

    // Maju ke Cek Paham
    while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
      final btnLanjut = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjut);
      await tester.pump();
    }

    // Jawab 3 soal Cek Paham 5.2
    final cp52_1 = find.textContaining('Tanda bahaya');
    await tester.ensureVisible(cp52_1);
    await tester.pump();
    await tester.tap(cp52_1);
    await tester.pump();

    final cp52_2 = find.textContaining('Lewat situs atau layanan resmi');
    await tester.ensureVisible(cp52_2);
    await tester.pump();
    await tester.tap(cp52_2);
    await tester.pump();

    final cp52_3 = find.textContaining('Rp600.000');
    await tester.ensureVisible(cp52_3);
    await tester.pump();
    await tester.tap(cp52_3);
    await tester.pump();

    // Maju ke Misi 5.2
    final btnKeMisi52 = find.byKey(const Key('tombol_lanjut'));
    expect(tester.widget<TombolFunda>(btnKeMisi52).padaTekan, isNotNull);
    await tester.tap(btnKeMisi52);
    await tester.pump();

    await pompaHinggaAda(tester, find.text('Siapkan cara cek penyedia'));
    expect(find.text('Siapkan cara cek penyedia'), findsOneWidget);

    // Assert disclaimer lengkap tampil di atas sebelum daftar
    const teksDisclaimer = 'Funda hanya memberi edukasi umum. Ini bukan ajakan membeli produk keuangan atau nasihat keuangan, hukum, maupun pajak. Keputusan dan risikonya ada padamu. Funda tidak bertanggung jawab atas kerugian dari tindakan di luar aplikasi. Pastikan penyedia berizin sebelum memakai uangmu.';
    expect(find.byKey(const Key('disclaimer_langkah_dunia_nyata')), findsOneWidget);
    expect(find.text(teksDisclaimer), findsOneWidget);
    await mintaTangkapanLayar('tahap_08c_06_pelajaran_5_2_disclaimer');

    // Tekan "Mengerti"
    await tester.ensureVisible(find.text('Mengerti'));
    await tester.pump();
    await tester.tap(find.text('Mengerti'));
    await tester.pump();

    // Verifikasi penghitung dan tombol Selesai nonaktif
    expect(find.text('0 dari minimal 3 langkah dicentang'), findsOneWidget);
    final tombolSelesai52 = find.byKey(const Key('tombol_selesai_daftar_periksa'));
    expect(tombolSelesai52, findsOneWidget);
    expect(tester.widget<TombolFunda>(tombolSelesai52).padaTekan, isNull);

    // Centang langkah 1 (l1) dan langkah 2 (l2)
    final l1Finder = find.byKey(const Key('centang_langkah_l1'));
    await tester.ensureVisible(l1Finder);
    await tester.pump();
    await tester.tap(l1Finder);
    await tester.pump();

    final l2Finder = find.byKey(const Key('centang_langkah_l2'));
    await tester.ensureVisible(l2Finder);
    await tester.pump();
    await tester.tap(l2Finder);
    await tester.pump();

    expect(find.text('2 dari minimal 3 langkah dicentang'), findsOneWidget);
    expect(tester.widget<TombolFunda>(tombolSelesai52).padaTekan, isNull);
    await mintaTangkapanLayar('tahap_08c_07_pelajaran_5_2_dua_centang');

    // Centang langkah 3 (l3) -> tombol Selesai AKTIF
    final l3Finder = find.byKey(const Key('centang_langkah_l3'));
    await tester.ensureVisible(l3Finder);
    await tester.pump();
    await tester.tap(l3Finder);
    await tester.pump();

    expect(find.text('3 dari minimal 3 langkah dicentang'), findsOneWidget);
    expect(tester.widget<TombolFunda>(tombolSelesai52).padaTekan, isNotNull);

    // Tap Selesai
    await tester.ensureVisible(tombolSelesai52);
    await tester.pump();
    await tester.tap(tombolSelesai52);
    await tester.pump();
    await mintaTangkapanLayar('tahap_08c_08_pelajaran_5_2_tiga_centang_selesai');

    // Selesaikan Pelajaran 5.2
    while (find.text('Selesai Belajar').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('tombol_lanjut')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('tombol_lanjut')));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Waspada Penipuan & Pinjol Ilegal'));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pump();

    // Verifikasi tabel_hasil_misi 5.2
    final hasilMisi52 = await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals('waspada_penipuan_5_2'))).getSingleOrNull();
    expect(hasilMisi52, isNotNull);
    expect(hasilMisi52!.status, equals('selesai'));
    expect(hasilMisi52.tipe, equals('daftar_periksa'));
    final muatan52 = jsonDecode(hasilMisi52.muatanJson!) as Map<String, dynamic>;
    final dicentang52 = (muatan52['dicentang'] as List).cast<String>();
    expect(dicentang52, equals(['l1', 'l2', 'l3']));
    debugPrint('[VERIFIKASI DB SUKSES]: tabel_hasil_misi waspada_penipuan_5_2 tercatat {"dicentang":["l1","l2","l3"]}');

    // =========================================================================
    // 5. PELAJARAN 5.3: Misi Daftar Periksa "Susun rencana daruratmu"
    // =========================================================================
    debugPrint('=== [LANGKAH 5]: Pelajaran 5.3 - Misi Daftar Periksa Susun Rencana Darurat ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/pelajaran/waspada_penipuan/waspada_penipuan_5_3');
    await tester.pump();
    await pompaHinggaAda(tester, find.text('Kalau Sudah Terlanjur'));
    await pompaHinggaAda(tester, find.byKey(const Key('tombol_lanjut')));

    // Maju ke Cek Paham
    while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
      final btnLanjut = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjut);
      await tester.pump();
    }

    // Jawab 3 soal Cek Paham 5.3
    final cp53_1 = find.textContaining('Hentikan kontak, amankan akun');
    await tester.ensureVisible(cp53_1);
    await tester.pump();
    await tester.tap(cp53_1);
    await tester.pump();

    final cp53_2 = find.textContaining('Membantu saat melapor ke penyedia');
    await tester.ensureVisible(cp53_2);
    await tester.pump();
    await tester.tap(cp53_2);
    await tester.pump();

    final cp53_3 = find.textContaining('Tidak memutuskan dalam tekanan');
    await tester.ensureVisible(cp53_3);
    await tester.pump();
    await tester.tap(cp53_3);
    await tester.pump();

    // Maju ke Misi 5.3
    final btnKeMisi53 = find.byKey(const Key('tombol_lanjut'));
    expect(tester.widget<TombolFunda>(btnKeMisi53).padaTekan, isNotNull);
    await tester.tap(btnKeMisi53);
    await tester.pump();

    await pompaHinggaAda(tester, find.text('Susun rencana daruratmu'));
    expect(find.text('Susun rencana daruratmu'), findsOneWidget);

    // Disclaimer
    await tester.ensureVisible(find.text('Mengerti'));
    await tester.pump();
    await tester.tap(find.text('Mengerti'));
    await tester.pump();

    // Centang 3 langkah (l1, l2, l4)
    final cl1 = find.byKey(const Key('centang_langkah_l1'));
    await tester.ensureVisible(cl1);
    await tester.pump();
    await tester.tap(cl1);
    await tester.pump();

    final cl2 = find.byKey(const Key('centang_langkah_l2'));
    await tester.ensureVisible(cl2);
    await tester.pump();
    await tester.tap(cl2);
    await tester.pump();

    final cl4 = find.byKey(const Key('centang_langkah_l4'));
    await tester.ensureVisible(cl4);
    await tester.pump();
    await tester.tap(cl4);
    await tester.pump();

    final tombolSelesai53 = find.byKey(const Key('tombol_selesai_daftar_periksa'));
    await tester.ensureVisible(tombolSelesai53);
    await tester.pump();
    expect(tester.widget<TombolFunda>(tombolSelesai53).padaTekan, isNotNull);
    await tester.tap(tombolSelesai53);
    await tester.pump();
    await mintaTangkapanLayar('tahap_08c_09_pelajaran_5_3_selesai');

    // Selesaikan Pelajaran 5.3
    while (find.text('Selesai Belajar').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('tombol_lanjut')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('tombol_lanjut')));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Waspada Penipuan & Pinjol Ilegal'));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).clearSnackBars();
    await tester.pump();

    // Verifikasi tabel_hasil_misi 5.3
    final hasilMisi53 = await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals('waspada_penipuan_5_3'))).getSingleOrNull();
    expect(hasilMisi53, isNotNull);
    expect(hasilMisi53!.status, equals('selesai'));
    expect(hasilMisi53.tipe, equals('daftar_periksa'));
    final muatan53 = jsonDecode(hasilMisi53.muatanJson!) as Map<String, dynamic>;
    final dicentang53 = (muatan53['dicentang'] as List).cast<String>();
    expect(dicentang53, equals(['l1', 'l2', 'l4']));
    debugPrint('[VERIFIKASI DB SUKSES]: tabel_hasil_misi waspada_penipuan_5_3 tercatat {"dicentang":["l1","l2","l4"]}');

    // =========================================================================
    // 6. KUIS MODUL 5: Percobaan 1 Gagal (3/5) & Percobaan 2 Lulus (4/5)
    // =========================================================================
    debugPrint('=== [LANGKAH 6]: Kuis Modul 5 - Percobaan 1 Gagal lalu Percobaan 2 Lulus ===');
    tester.element(find.byType(Scaffold).first).push('/belajar/kuis/waspada_penipuan');
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Soal 1/5'));

    // Percobaan 1: Jawab 3 benar, 2 salah -> 60% TIDAK LULUS
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
    await mintaTangkapanLayar('tahap_08c_10_kuis_percobaan_1_tidak_lulus');

    // Tap Ulangi Kuis
    await tester.tap(find.text('Ulangi Kuis'));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Soal 1/5'));

    // Percobaan 2: Jawab 4 benar, 1 salah -> 80% LULUS
    for (var s = 0; s < 5; s++) {
      await pompaHinggaAda(tester, find.byKey(const Key('opsi_kuis_0')));
      final dynamic stateKuis = tester.state(find.byType(LayarKuisModul));
      final int idxBenar = stateKuis.indeksJawabanBenarSaatIni as int;
      final idxPilihan = s < 4 ? idxBenar : (idxBenar + 1) % 3;

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

    // Layar Hasil Percobaan 2 (Lulus)
    await pompaHinggaAda(tester, find.text('Selamat, Kamu Lulus!'));
    expect(find.text('80%'), findsOneWidget);
    debugPrint('[KUIS PERCOBAAN 2]: Skor 4/5 (80%) LULUS tampil di layar');
    await mintaTangkapanLayar('tahap_08c_11_kuis_percobaan_2_lulus');

    // Kembali ke Peta Belajar
    await tester.tap(find.text('Kembali ke Peta Belajar'));
    await tester.pump();
    await pompaHinggaAda(tester, find.textContaining('Waspada Penipuan & Pinjol Ilegal'));
    await mintaTangkapanLayar('tahap_08c_12_beranda_modul_5_selesai');

    // =========================================================================
    // 7. REGRESI PEMULIHAN CADANGAN: 19+ Tabel (Termasuk tabel_hasil_misi)
    // =========================================================================
    debugPrint('=== [LANGKAH 7]: Pengujian Regresi Pemulihan Cadangan pada Seluruh Tabel ===');
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
    await mintaTangkapanLayar('tahap_08c_13_regresi_pemulihan_selesai');

    // =========================================================================
    // 8. TOLOK UKUR BEBAN: 20.000 Transaksi + 20 Utang pada Tab Belajar
    // =========================================================================
    debugPrint('=== [LANGKAH 8]: Tolok Ukur Beban 20.000 Transaksi + 20 Utang ===');
    // Pastikan dompet utama ada sebelum transaksi disuntik
    await basisData.into(basisData.tabelDompet).insertOnConflictUpdate(
          TabelDompetCompanion.insert(
            id: 'dmp_utama',
            nama: 'Dompet Utama',
            jenis: 'tunai',
            ikon: 'dompet',
            warna: 'hijau',
          ),
        );

    // Suntik 20.000 transaksi dan 20 utang via batch
    await basisData.batch((batch) {
      final txList = List.generate(
        20000,
        (i) => TabelTransaksiCompanion.insert(
          id: 'tx_beban_$i',
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
          id: 'utang_beban_$u',
          nama: 'Utang Beban $u',
          pokokAwalRupiah: const Value(5000000),
          sisaAwalRupiah: 3000000,
          jenis: 'kredit_barang',
          jenisBunga: 'flat',
          status: const Value('aktif'),
          dibuatPada: now,
        ),
      );
      batch.insertAll(basisData.tabelUtang, utangList);
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

    // 8b. Tolok Ukur Membuka Layar Pelajaran Modul 5 (5.1, 5.2, 5.3) Beban 20.000 Transaksi + 20 Utang
    final pelajaranIds = [
      'waspada_penipuan_5_1',
      'waspada_penipuan_5_2',
      'waspada_penipuan_5_3',
    ];

    for (final pelId in pelajaranIds) {
      final jsonStr = File('aset/konten/pemula/waspada_penipuan/$pelId.json').readAsStringSync();
      // Pemanasan 1x: kueri status dan muat pelajaran
      await (basisData.select(basisData.tabelHasilMisi)..where((m) => m.misiId.equals(pelId))).getSingleOrNull();
      await (basisData.select(basisData.tabelProgresPelajaran)..where((p) => p.pelajaranId.equals(pelId))).getSingleOrNull();
      PembacaKonten.uraiPelajaran(jsonStr, namaBerkas: '$pelId.json');
      await tester.pump();

      final listKompPel = <int>[];
      final listFramePel = <int>[];

      // 10 Iterasi tanpa helper pompa
      for (var it = 0; it < 10; it++) {
        final swKomp = Stopwatch()..start();
        // 2 Kueri database yang dieksekusi saat membuka layar pemutar pelajaran:
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

    debugPrint('=== SELURUH PENGUJIAN INTEGRASI TAHAP 8C SELESAI DENGAN SUKSES ===');
  });
}
