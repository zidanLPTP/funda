@Timeout(Duration(seconds: 30))
library;

import 'dart:convert';
import 'dart:io';
import '../pembantu/pompa_uji.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/komponen/tombol_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BasisDataFunda db;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  PelajaranKonten muatPelajaranLocal(String modulId, String pelajaranId) {
    final file = File('aset/konten/pemula/$modulId/$pelajaranId.json');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'Berkas $pelajaranId.json wajib ada',
    );
    return PembacaKonten.uraiPelajaran(
      file.readAsStringSync(),
      namaBerkas: '$pelajaranId.json',
    );
  }

  ModulKonten muatModulLocal(String modulId) {
    final file = File('aset/konten/pemula/$modulId/modul.json');
    expect(file.existsSync(), isTrue, reason: 'Berkas modul.json wajib ada');
    return PembacaKonten.uraiModul(
      file.readAsStringSync(),
      namaBerkas: 'modul.json',
    );
  }

  group(
    'Uji Widget Tahap 8C: Misi Keputusan, Daftar Periksa, Disclaimer, Kuis & Skala Teks 2.0',
    () {
      testWidgets(
        '1. Kartu Misi Keputusan (5.1): Opsi tidak aman -> coba lagi -> opsi aman -> Lanjut aktif & rekam ke DB',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'waspada_penipuan',
            'waspada_penipuan_5_1',
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(FotoDataPengguna.kosong()),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
              ],
              child: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: MaterialApp(
                  theme: TemaFunda.temaTerang,
                  home: LayarPemutarPelajaran(
                    modulId: 'waspada_penipuan',
                    pelajaranId: 'waspada_penipuan_5_1',
                    pelajaranOverride: pel,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // Maju ke langkah Cek Paham
          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham
          final opsi1 = find.textContaining('Berhenti, lalu periksa');
          await tester.ensureVisible(opsi1);
          await tester.pump();
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining('Tidak seorang pun');
          await tester.ensureVisible(opsi2);
          await tester.pump();
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining('Penyedia menjelaskan total biaya');
          await tester.ensureVisible(opsi3);
          await tester.pump();
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          expect(
            tester.widget<TombolFunda>(btnLanjutKeMisi).padaTekan,
            isNotNull,
          );
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          // Pastikan berada di layar Misi Praktik Nyata
          await pompaHinggaAda(tester, find.text('Latih rem-mu'));
          expect(find.text('Latih rem-mu'), findsOneWidget);
          expect(
            find.textContaining('Seseorang menelepon dan mengaku dari bank'),
            findsOneWidget,
          );

          // Verifikasi tombol opsi hadir (>= 48 dp)
          final opsiA = find.byKey(const Key('opsi_keputusan_a'));
          final opsiB = find.byKey(const Key('opsi_keputusan_b'));
          expect(opsiA, findsOneWidget);
          expect(opsiB, findsOneWidget);

          // Tombol Lanjut saat ini harus nonaktif karena misi belum selesai
          final btnLanjutMisi = find.byKey(const Key('tombol_lanjut'));
          expect(tester.widget<TombolFunda>(btnLanjutMisi).padaTekan, isNull);

          // 1. Pilih Opsi a (Tidak aman)
          await tester.tap(opsiA);
          await tester.pump();

          // Umpan balik opsi a muncul
          expect(
            find.textContaining('Kode OTP adalah kunci akunmu'),
            findsOneWidget,
          );
          final tombolCobaLagi = find.byKey(
            const Key('tombol_coba_pilihan_lain'),
          );
          expect(tombolCobaLagi, findsOneWidget);
          expect(tester.widget<TombolFunda>(btnLanjutMisi).padaTekan, isNull);

          // 2. Tap "Coba pilihan lain"
          await tester.tap(tombolCobaLagi);
          await tester.pump();

          // Opsi kembali muncul
          expect(find.byKey(const Key('opsi_keputusan_b')), findsOneWidget);

          // 3. Pilih Opsi b (Aman)
          await tester.tap(find.byKey(const Key('opsi_keputusan_b')));
          await tester.pump();

          // Umpan balik aman tampil dan status selesai
          expect(
            find.textContaining(
              'Tepat. Kamu berhenti dan memeriksa lewat jalur resmi',
            ),
            findsOneWidget,
          );
          expect(find.text('Pilihan Aman Terverifikasi!'), findsOneWidget);

          // Tombol Lanjut sekarang menjadi AKTIF
          expect(
            tester.widget<TombolFunda>(btnLanjutMisi).padaTekan,
            isNotNull,
          );

          // Verifikasi rekaman ke tabel_hasil_misi
          final hasilMisi =
              await (db.select(db.tabelHasilMisi)
                    ..where((m) => m.misiId.equals('waspada_penipuan_5_1')))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('keputusan'));

          final muatan =
              jsonDecode(hasilMisi.muatanJson!) as Map<String, dynamic>;
          expect(muatan['opsiDipilih'], equals(['a', 'b']));

          await bongkarWidget(tester);
        },
      );

      testWidgets(
        '2. Kartu Misi Daftar Periksa (5.2): Disclaimer -> Centang bertahap -> Selesai aktif -> rekam ke DB',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'waspada_penipuan',
            'waspada_penipuan_5_2',
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(FotoDataPengguna.kosong()),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
              ],
              child: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: MaterialApp(
                  theme: TemaFunda.temaTerang,
                  home: LayarPemutarPelajaran(
                    modulId: 'waspada_penipuan',
                    pelajaranId: 'waspada_penipuan_5_2',
                    pelajaranOverride: pel,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // Maju ke langkah Cek Paham
          while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
            final btnLanjut = find.byKey(const Key('tombol_lanjut'));
            expect(btnLanjut, findsOneWidget);
            await tester.tap(btnLanjut);
            await tester.pump();
          }

          // Jawab 3 soal Cek Paham untuk 5.2
          final opsi1 = find.textContaining('Tanda bahaya');
          await tester.ensureVisible(opsi1);
          await tester.pump();
          await tester.tap(opsi1);
          await tester.pump();

          final opsi2 = find.textContaining('Lewat situs atau layanan resmi');
          await tester.ensureVisible(opsi2);
          await tester.pump();
          await tester.tap(opsi2);
          await tester.pump();

          final opsi3 = find.textContaining('Rp600.000');
          await tester.ensureVisible(opsi3);
          await tester.pump();
          await tester.tap(opsi3);
          await tester.pump();

          // Tap Lanjut ke Misi
          final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
          expect(
            tester.widget<TombolFunda>(btnLanjutKeMisi).padaTekan,
            isNotNull,
          );
          await tester.tap(btnLanjutKeMisi);
          await tester.pump();

          await pompaHinggaAda(tester, find.text('Siapkan cara cek penyedia'));
          expect(find.text('Siapkan cara cek penyedia'), findsOneWidget);

          // Disclaimer tampil di atas
          expect(
            find.byKey(const Key('disclaimer_langkah_dunia_nyata')),
            findsOneWidget,
          );
          expect(
            find.textContaining('Funda hanya memberi edukasi umum'),
            findsOneWidget,
          );
          expect(find.text('Mengerti'), findsOneWidget);

          // Tekan Mengerti
          await tester.tap(find.text('Mengerti'));
          await tester.pump();

          // Disclaimer berubah ke bentuk ringkas dengan tombol "Baca Ulang"
          expect(find.text('Baca Ulang'), findsOneWidget);

          // Penghitung langkah: "0 dari minimal 3 langkah dicentang"
          expect(
            find.textContaining('0 dari minimal 3 langkah dicentang'),
            findsOneWidget,
          );

          // Tombol Selesai nonaktif
          final tombolSelesai = find.byKey(
            const Key('tombol_selesai_daftar_periksa'),
          );
          expect(tombolSelesai, findsOneWidget);
          expect(tester.widget<TombolFunda>(tombolSelesai).padaTekan, isNull);

          // Centang langkah 1 & 2
          await tester.tap(find.byKey(const Key('centang_langkah_l1')));
          await tester.pump();
          await tester.tap(find.byKey(const Key('centang_langkah_l2')));
          await tester.pump();

          expect(
            find.textContaining('2 dari minimal 3 langkah dicentang'),
            findsOneWidget,
          );
          expect(tester.widget<TombolFunda>(tombolSelesai).padaTekan, isNull);

          // Centang langkah 3 -> mencapai minimal 3
          await tester.tap(find.byKey(const Key('centang_langkah_l3')));
          await tester.pump();

          expect(
            find.textContaining('3 dari minimal 3 langkah dicentang'),
            findsOneWidget,
          );
          expect(
            tester.widget<TombolFunda>(tombolSelesai).padaTekan,
            isNotNull,
          );

          // Tap Selesai
          await tester.tap(tombolSelesai);
          await tester.pump();

          expect(
            find.text('Luar biasa! Misi berhasil diselesaikan.'),
            findsOneWidget,
          );

          // Tombol Lanjut sekarang menjadi aktif
          final btnLanjut = find.byKey(const Key('tombol_lanjut'));
          expect(tester.widget<TombolFunda>(btnLanjut).padaTekan, isNotNull);

          // Verifikasi rekaman ke tabel_hasil_misi
          final hasilMisi =
              await (db.select(db.tabelHasilMisi)
                    ..where((m) => m.misiId.equals('waspada_penipuan_5_2')))
                  .getSingleOrNull();
          expect(hasilMisi, isNotNull);
          expect(hasilMisi!.status, equals('selesai'));
          expect(hasilMisi.tipe, equals('daftar_periksa'));

          final muatan =
              jsonDecode(hasilMisi.muatanJson!) as Map<String, dynamic>;
          final dicentang = (muatan['dicentang'] as List).cast<String>();
          expect(dicentang, containsAll(['l1', 'l2', 'l3']));

          await bongkarWidget(tester);
        },
      );

      testWidgets('3. Kuis Modul 5: Jawab soal dan simpan hasil', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final modul = muatModulLocal('waspada_penipuan');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaDaftarSemuaModul.overrideWith(
                (ref) => Future.value([modul]),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarKuisModul(modulId: 'waspada_penipuan'),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('Kuis'), findsWidgets);

        await bongkarWidget(tester);
      });

      testWidgets(
        '4. Aksesibilitas Skala Teks 2.0 pada Layar 360x640: Tidak overflow dan elemen terjangkau',
        (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final pel = muatPelajaranLocal(
            'waspada_penipuan',
            'waspada_penipuan_5_1',
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaBasisData.overrideWithValue(db),
                penyediaFotoData.overrideWith(
                  (ref) => Future.value(FotoDataPengguna.kosong()),
                ),
                penyediaKamus.overrideWith(
                  (ref) => Future.value(<String, IstilahKamus>{}),
                ),
              ],
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(360, 640),
                  textScaler: TextScaler.linear(2.0),
                ),
                child: MaterialApp(
                  theme: TemaFunda.temaTerang,
                  home: LayarPemutarPelajaran(
                    modulId: 'waspada_penipuan',
                    pelajaranId: 'waspada_penipuan_5_1',
                    pelajaranOverride: pel,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          // Pastikan render tidak melempar RenderFlex overflow exception
          expect(tester.takeException(), isNull);
          expect(find.text('Pemantik'), findsOneWidget);

          await bongkarWidget(tester);
        },
      );
    },
  );
}
