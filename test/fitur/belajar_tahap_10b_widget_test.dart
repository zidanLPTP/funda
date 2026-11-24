@Timeout(Duration(seconds: 30))
library;

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  group('Pengujian Widget Belajar Tahap 10B (Modul 12 Tujuan Besar & Perencanaan)', () {
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
      final f = File('aset/konten/menengah/$modulId/$pelajaranId.json');
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return PelajaranKonten.fromJson(data);
    }

    ModulKonten muatModulLocal(String modulId) {
      final f = File('aset/konten/menengah/$modulId/modul.json');
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return ModulKonten.fromJson(data);
    }

    testWidgets('1. Status Modul 12 pada Peta Belajar: Terkunci vs Terbuka', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul12 = muatModulLocal('tujuan_besar');
      final pel12_1 = muatPelajaranLocal('tujuan_besar', 'tujuan_besar_12_1');

      // Kasus A: Terkunci (belum ada modul selesai tabungan dan belum ada tujuan)
      final fotoDataTerkunci = FotoDataPengguna.kosong();
      final statusTerkunci = tentukanStatusModul(modul: modul12, fotoData: fotoDataTerkunci);
      expect(statusTerkunci.status, equals(StatusBelajar.terkunci));

      // Kasus B: Terbuka (modul tabungan selesai dan ada minimal 1 tujuan)
      final fotoDataTerbuka = FotoDataPengguna.kosong().copyWith(
        jumlahTujuanAktif: 1,
        hasilKuisTerbaik: {
          'tabungan': const HasilKuisSnapshot(
            skorPersen: 100,
            lulus: true,
          ),
        },
      );
      final statusTerbuka = tentukanStatusModul(modul: modul12, fotoData: fotoDataTerbuka);
      expect(statusTerbuka.status, equals(StatusBelajar.terbuka));

      final statusPel = tentukanStatusPelajaran(
        pelajaran: pel12_1,
        posisiIndeks: 0,
        daftarPelajaranModul: [pel12_1],
        gerbangModul: modul12.gerbang,
        fotoData: fotoDataTerbuka,
      );

      final itemModul12 = ItemPetaModul(
        modul: modul12,
        statusModul: statusTerbuka,
        daftarPelajaran: [(pel12_1, statusPel)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(fotoDataTerbuka)),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
            penyediaPetaBelajar.overrideWith((ref) => Future.value([itemModul12])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const Scaffold(
              body: LayarBelajar(),
            ),
          ),
        ),
      );
      await tester.pump();
      await pompaHinggaAda(tester, find.text('Tujuan Besar & Perencanaan'));

      expect(find.text('Tujuan Besar & Perencanaan'), findsOneWidget);
      await bongkarWidget(tester);
    });

    testWidgets('2. Misi Pelajaran 12.1 (Keputusan: Menyelaraskan target dengan kemampuan)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('tujuan_besar', 'tujuan_besar_12_1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'tujuan_besar',
              pelajaranId: 'tujuan_besar_12_1',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju ke Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 12.1
      final opsi1 = find.textContaining('Agar lebih mudah diukur');
      await tester.ensureVisible(opsi1);
      await tester.pump();
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Rp1.500.000');
      await tester.ensureVisible(opsi2);
      await tester.pump();
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Memperpanjang tenggat');
      await tester.ensureVisible(opsi3);
      await tester.pump();
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi Keputusan
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Menyelaraskan target dengan kemampuan'));
      expect(find.text('Menyelaraskan target dengan kemampuan'), findsOneWidget);

      // Pilih Opsi A (aman)
      final opsiAman = find.textContaining('Perpanjang tenggat menjadi sekitar 40 bulan');
      await tester.ensureVisible(opsiAman);
      await tester.tap(opsiAman);
      await tester.pump();

      expect(find.textContaining('Rencana yang realistis lebih mungkin bertahan'), findsOneWidget);

      // Verifikasi rekaman ke basis data
      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('tujuan_besar_12_1')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('keputusan'));

      await bongkarWidget(tester);
    });

    testWidgets('3. Umpan Balik Pelajaran 12.2 (ringkasan_tujuan_besar)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('tujuan_besar', 'tujuan_besar_12_2');

      // Masukkan 1 tujuan besar di database
      final now = DateTime.now();
      final tenggat = DateTime(now.year + 2, now.month, now.day);
      await db.into(db.tabelTujuan).insert(
        TabelTujuanCompanion.insert(
          id: 'tujuan_kuliah',
          nama: 'Biaya Kuliah',
          jenis: 'tujuan_besar',
          targetRupiah: 36000000,
          tenggat: Value(tenggat),
          ikon: 'school',
          warna: 'biru',
          status: 'aktif',
          dibuatPada: now,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'tujuan_besar',
              pelajaranId: 'tujuan_besar_12_2',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju ke Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 12.2
      final opsi1 = find.textContaining('biaya barang dan jasa cenderung naik');
      await tester.ensureVisible(opsi1);
      await tester.pump();
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Meninjau ulang target dan setoran');
      await tester.ensureVisible(opsi2);
      await tester.pump();
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Perkiraan angka keuangan di masa depan');
      await tester.ensureVisible(opsi3);
      await tester.pump();
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Lihat proyeksi tujuan besarmu'));
      expect(find.text('Lihat proyeksi tujuan besarmu'), findsOneWidget);

      // Tap Lanjut ke Kartu Umpan Balik Nyata
      final btnLanjutKeUmpanBalik = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeUmpanBalik);
      await tester.pump();

      // Umpan balik nyata muncul
      await pompaHinggaAda(tester, find.text('Umpan Balik Nyata'));
      expect(find.text('Umpan Balik Nyata'), findsOneWidget);

      // Verifikasi teks ringkasan_tujuan_besar
      expect(find.textContaining('Tujuan besarmu: Biaya Kuliah (target Rp36.000.000, terkumpul Rp0).'), findsOneWidget);
      expect(find.textContaining('Fokus pada satu atau dua tujuan utama lebih mudah dijalankan'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets('4. Misi Pelajaran 12.3 (Refleksi: Tentukan prioritas utamamu)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel = muatPelajaranLocal('tujuan_besar', 'tujuan_besar_12_3');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: LayarPemutarPelajaran(
              modulId: 'tujuan_besar',
              pelajaranId: 'tujuan_besar_12_3',
              pelajaranOverride: pel,
            ),
          ),
        ),
      );
      await tester.pump();

      // Maju ke Cek Paham
      while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
        final btnLanjut = find.byKey(const Key('tombol_lanjut'));
        expect(btnLanjut, findsOneWidget);
        await tester.tap(btnLanjut);
        await tester.pump();
      }

      // Jawab 3 soal Cek Paham 12.3
      final opsi1 = find.textContaining('Agar tiap tujuan lebih cepat tercapai');
      await tester.ensureVisible(opsi1);
      await tester.pump();
      await tester.tap(opsi1);
      await tester.pump();

      final opsi2 = find.textContaining('Pilihan lain yang dilepaskan');
      await tester.ensureVisible(opsi2);
      await tester.pump();
      await tester.tap(opsi2);
      await tester.pump();

      final opsi3 = find.textContaining('Alihkan ritme setoran bulanan yang sama');
      await tester.ensureVisible(opsi3);
      await tester.pump();
      await tester.tap(opsi3);
      await tester.pump();

      // Tap Lanjut ke Misi Refleksi
      final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
      await tester.tap(btnLanjutKeMisi);
      await tester.pump();

      await pompaHinggaAda(tester, find.text('Tentukan prioritas utamamu'));
      expect(find.text('Tentukan prioritas utamamu'), findsOneWidget);

      // Input teks refleksi
      final inputRefleksi = find.byKey(const Key('input_refleksi'));
      expect(inputRefleksi, findsOneWidget);
      await tester.enterText(
        inputRefleksi,
        'Prioritas utamaku dana pendidikan S2 dalam 3 tahun karena ingin meningkatkan karier.',
      );
      await tester.pump();

      // Tombol Simpan Refleksi
      final tombolSimpan = find.byKey(const Key('tombol_simpan_refleksi'));
      expect(tombolSimpan, findsOneWidget);
      await tester.tap(tombolSimpan);
      await tester.pump();

      // Verifikasi rekaman ke basis data
      final hasilMisi = await (db.select(db.tabelHasilMisi)
            ..where((m) => m.misiId.equals('tujuan_besar_12_3')))
          .getSingleOrNull();
      expect(hasilMisi, isNotNull);
      expect(hasilMisi!.status, equals('selesai'));
      expect(hasilMisi.tipe, equals('refleksi'));

      final muatan = jsonDecode(hasilMisi.muatanJson!) as Map<String, dynamic>;
      expect(muatan['jawaban'], contains('Prioritas utamaku dana pendidikan S2'));

      await bongkarWidget(tester);
    });

    testWidgets('5. Kuis Modul 12: Tampilan kuis berjalan lancar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final modul12 = muatModulLocal('tujuan_besar');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul12])),
          ],
          child: MaterialApp(
            theme: TemaFunda.temaTerang,
            home: const LayarKuisModul(
              modulId: 'tujuan_besar',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Kuis'), findsWidgets);
      await bongkarWidget(tester);
    });

    testWidgets('6. Aksesibilitas Skala Teks 2.0 pada 360x640: Bebas RenderFlex Overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pel12 = muatPelajaranLocal('tujuan_besar', 'tujuan_besar_12_1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaBasisData.overrideWithValue(db),
            penyediaFotoData.overrideWith((ref) => Future.value(FotoDataPengguna.kosong())),
            penyediaKamus.overrideWith((ref) => Future.value(<String, IstilahKamus>{})),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              disableAnimations: true,
            ),
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: LayarPemutarPelajaran(
                modulId: 'tujuan_besar',
                pelajaranId: 'tujuan_besar_12_1',
                pelajaranOverride: pel12,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      await bongkarWidget(tester);
    });
  });
}
