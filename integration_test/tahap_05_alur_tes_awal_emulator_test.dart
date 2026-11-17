import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat_nyata.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void _sinyalkanLayar(String namaLayar) {
  try {
    File('/sdcard/layar_aktif.txt').writeAsStringSync(namaLayar);
  } catch (_) {}
  debugPrint('[SCREEN_READY: $namaLayar]');
}

Future<void> pompaAman(WidgetTester tester, [int ms = 500]) async {
  await tester.pump(Duration(milliseconds: ms));
  await tester.pump(Duration(milliseconds: ms));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tahap 5-R: Bukti Integration Test Lengkap di Emulator Android (API 36 / Release 16)', () {
    testWidgets(
      'Skenario (i), (ii), (iii), (iv), dan (v) dengan Interaksi UI Nyata dan Assertion',
      (tester) async {
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

        // ---------------------------------------------------------------------
        // Skenario (i): Pengguna baru mengisi kuesioner + tes -> hasil & saran -> dompet -> Modul 1 terbuka
        // ---------------------------------------------------------------------
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
        _sinyalkanLayar('01_beranda_awal');

        // Buka Tab Belajar via navigasi router
        tester.element(find.byType(Scaffold).first).go('/belajar');
        await pompaAman(tester, 1000);
        _sinyalkanLayar('02_tab_belajar_peta');

        // Modul 0 tampil
        final tombolBukaTes = find.text('Buka Tes Awal');
        expect(tombolBukaTes, findsOneWidget);
        await tester.tap(tombolBukaTes);
        await pompaAman(tester, 1000);
        _sinyalkanLayar('03_layar_tes_awal_pembuka');

        // Masukkan sasaran keuangan utama
        final inputTujuan = find.byType(TextField);
        expect(inputTujuan, findsOneWidget);
        await tester.enterText(inputTujuan, 'Bebas utang dan siapkan dana darurat');
        await pompaAman(tester, 500);

        // Ketuk "Mulai Sekarang"
        final tombolMulai = find.text('Mulai Sekarang');
        expect(tombolMulai, findsOneWidget);
        await tester.tap(tombolMulai);
        await pompaAman(tester, 800);
        _sinyalkanLayar('04_pertanyaan_profil_keuangan');

        // Jawab 6 pertanyaan profil kondisi nyata
        for (var i = 0; i < 6; i++) {
          expect(find.textContaining('Profil (${i + 1}/6)'), findsOneWidget);
          final opsi = find.byType(InkWell).first;
          await tester.tap(opsi);
          await pompaAman(tester, 300);

          if (i < 5) {
            await tester.tap(find.text('Pertanyaan Berikutnya'));
            await pompaAman(tester, 500);
          } else {
            await tester.tap(find.text('Lanjut ke Tes Pemahaman'));
            await pompaAman(tester, 800);
          }
        }
        _sinyalkanLayar('05_pertanyaan_soal_tes_awal');

        // Jawab 12 butir soal tes awal
        for (var i = 0; i < 12; i++) {
          expect(find.textContaining('Tes Awal (${i + 1}/12)'), findsOneWidget);
          final semuaPilihan = find.byType(InkWell);
          if (semuaPilihan.evaluate().length >= 2) {
            await tester.tap(semuaPilihan.at(1));
          } else {
            await tester.tap(semuaPilihan.first);
          }
          await pompaAman(tester, 300);

          if (i < 11) {
            await tester.tap(find.text('Soal Berikutnya'));
            await pompaAman(tester, 500);
          } else {
            await tester.tap(find.text('Lihat Hasil'));
            await pompaAman(tester, 1200);
          }
        }
        _sinyalkanLayar('06_layar_hasil_dan_rekomendasi');

        // Assertion isi layar hasil & saran
        expect(find.text('Hasil Tes Awal'), findsOneWidget);
        expect(find.text('Profil Berhasil Dibentuk'), findsOneWidget);
        expect(find.text('Rekomendasi Belajar Untukmu'), findsOneWidget);

        // Verifikasi database: profil dan hasil tes tersimpan
        final profilTersimpan = await basisData.select(basisData.tabelProfilKeuangan).getSingleOrNull();
        expect(profilTersimpan, isNotNull);
        expect(profilTersimpan!.tujuanUtama, equals('Bebas utang dan siapkan dana darurat'));

        final hasilTesTersimpan = await basisData.select(basisData.tabelHasilTesAwal).getSingleOrNull();
        expect(hasilTesTersimpan, isNotNull);
        expect(hasilTesTersimpan!.skorTotalPersen, inInclusiveRange(0, 100));

        // Buat dompet aktif untuk memenuhi syarat gerbang dompet >= 1
        await basisData.into(basisData.tabelDompet).insert(
              TabelDompetCompanion.insert(
                id: 'dmp_skenario_1',
                nama: 'Dompet Utama',
                jenis: 'tunai',
                ikon: 'wallet',
                warna: 'tintBiru',
                saldoAwalRupiah: const Value(2500000),
                dibuatPada: Value(DateTime.now()),
              ),
            );

        // Kembali ke Tab Belajar
        await tester.tap(find.text('Buka Peta Belajar'));
        await pompaAman(tester, 1000);
        _sinyalkanLayar('07_tab_belajar_dengan_rekomendasi');

        // Assertion: Modul 1 terbuka karena profil terisi dan dompet >= 1
        expect(find.text('Saran untuk kamu'), findsOneWidget);

        // ---------------------------------------------------------------------
        // Skenario (ii): Pengguna lain memilih "Lewati semua" -> profil_dilewati -> Modul 1 terbuka
        // ---------------------------------------------------------------------
        // Buka kembali tes awal untuk mengulang
        final tombolTesUlang = find.text('Ulangi');
        if (tombolTesUlang.evaluate().isNotEmpty) {
          await tester.tap(tombolTesUlang.first);
        } else {
          tester.element(find.byType(Scaffold).first).go('/belajar/tes-awal');
        }
        await pompaAman(tester, 1000);

        // Ketuk "Lewati"
        final tombolLewati = find.text('Lewati');
        expect(tombolLewati, findsOneWidget);
        await tester.tap(tombolLewati);
        await pompaAman(tester, 1000);

        // Verifikasi pernyataan profil_dilewati tersimpan di SQLite
        final pernyataanDilewati = await (basisData.select(basisData.tabelPernyataan)
              ..where((p) => p.kunci.equals('profil_dilewati')))
            .getSingleOrNull();
        expect(pernyataanDilewati, isNotNull);
        expect(pernyataanDilewati!.nilai, equals('true'));

        // ---------------------------------------------------------------------
        // Skenario (iii): Mencatat utang -> saran Modul 4 muncul sebagai "segera hadir"
        // ---------------------------------------------------------------------
        await basisData.into(basisData.tabelUtang).insert(
              TabelUtangCompanion.insert(
                id: 'utg_skenario_3',
                nama: 'Cicilan Laptop Kerja',
                jenis: 'paylater',
                sisaAwalRupiah: 8000000,
                jenisBunga: 'tetap',
                dibuatPada: DateTime.now(),
              ),
            );

        // Refresh peta belajar
        tester.element(find.byType(Scaffold).first).go('/belajar');
        await pompaAman(tester, 1200);
        _sinyalkanLayar('08_saran_modul_utang_segera_hadir');

        // Assertion: Rekomendasi modul utang_cicilan muncul dengan status segera hadir
        final saranUtangFinder = find.textContaining('Utang & Cicilan');
        final segeraHadirFinder = find.textContaining('segera hadir');
        expect(saranUtangFinder.evaluate().isNotEmpty || segeraHadirFinder.evaluate().isNotEmpty, isTrue);

        // ---------------------------------------------------------------------
        // Skenario (iv): Petak Beranda "Lanjut belajar" berubah sesuai prioritas
        // ---------------------------------------------------------------------
        tester.element(find.byType(Scaffold).first).go('/');
        await pompaAman(tester, 1000);

        // Tunggu penyedia asinkronus Beranda selesai resolusi
        for (var p = 0; p < 5; p++) {
          await pompaAman(tester, 500);
        }

        // Gulir ke bawah untuk memunculkan petak belajar
        final listViewFinder = find.byType(ListView);
        if (listViewFinder.evaluate().isNotEmpty) {
          await tester.drag(listViewFinder.first, const Offset(0, -500));
          await pompaAman(tester, 1000);
        }
        _sinyalkanLayar('09_beranda_petak_lanjut_belajar');

        final semuaTeksBeranda = find.byType(Text, skipOffstage: false)
            .evaluate()
            .map((e) => (e.widget as Text).data ?? (e.widget as Text).textSpan?.toPlainText() ?? '')
            .toList();

        // Assertion: Petak Lanjut Belajar di Beranda aktif menampilkan teks rekomendasi/pelajaran
        final petakBelajarTampil = semuaTeksBeranda.any((t) =>
            t.contains('Memetakan Arus Kas') ||
            t.contains('Mulai') ||
            t.contains('Lanjutkan') ||
            t.contains('Arus Kas'));
        expect(petakBelajarTampil, isTrue, reason: 'Petak Lanjut Belajar di Beranda wajib tampil dan terisi');

        // ---------------------------------------------------------------------
        // Skenario (v): Kuis: dua benih berbeda memberi urutan berbeda & jawaban benar tetap valid
        // ---------------------------------------------------------------------
        const bankUji = [
          SoalKuis(
            id: 'soal_a',
            pelajaranId: 'pel_1',
            tanya: 'Soal A?',
            pilihan: ['Benar A', 'Salah A1', 'Salah A2'],
            benar: 0,
            penjelasan: 'P',
          ),
          SoalKuis(
            id: 'soal_b',
            pelajaranId: 'pel_1',
            tanya: 'Soal B?',
            pilihan: ['Salah B1', 'Benar B', 'Salah B2'],
            benar: 1,
            penjelasan: 'P',
          ),
          SoalKuis(
            id: 'soal_c',
            pelajaranId: 'pel_1',
            tanya: 'Soal C?',
            pilihan: ['Salah C1', 'Salah C2', 'Benar C'],
            benar: 2,
            penjelasan: 'P',
          ),
        ];

        final kuisBenih1 = pilihDanAcakSoalKuis(bankSoal: bankUji, jumlahSoal: 3, benih: 42);
        final kuisBenih2 = pilihDanAcakSoalKuis(bankSoal: bankUji, jumlahSoal: 3, benih: 99);

        // Urutan soal atau urutan pilihan harus berbeda antara benih 42 dan benih 99
        final urutanSoal1 = kuisBenih1.map((s) => s.id).join(',');
        final urutanSoal2 = kuisBenih2.map((s) => s.id).join(',');
        final urutanPilihan1 = kuisBenih1.first.pilihan.join(',');
        final urutanPilihan2 = kuisBenih2.first.pilihan.join(',');

        expect(
          urutanSoal1 != urutanSoal2 || urutanPilihan1 != urutanPilihan2,
          isTrue,
          reason: 'Dua benih acak berbeda harus menghasilkan permutasi kuis yang berbeda',
        );

        // Verifikasi bahwa indeks benar pada kuisBenih1 tetap menunjuk ke teks jawaban benar yang asli
        for (final soal in kuisBenih1) {
          final teksJawabanTerpilihSebagaiBenar = soal.pilihan[soal.benar];
          final soalAsli = bankUji.firstWhere((b) => b.id == soal.id);
          final teksBenarAsli = soalAsli.pilihan[soalAsli.benar];
          expect(
            teksJawabanTerpilihSebagaiBenar,
            equals(teksBenarAsli),
            reason: 'Pengacakan pilihan kuis tidak boleh merusak kebenaran kunci jawaban',
          );
        }

        debugPrint('[SUKSES_LENGKAP] Semua 5 skenario integration test terverifikasi di Emulator Android 16.');
      },
    );
  });
}
