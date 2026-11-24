@Timeout(Duration(seconds: 30))
library;

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
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/fitur/sandbox/kontroler/penyedia_sandbox.dart';
import 'package:funda/fitur/sandbox/tampilan/layar_sandbox.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';

void main() {
  late BasisDataFunda db;

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buatLayarUji(Widget anak, {double skalaTeks = 1.0}) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaFotoData.overrideWith(
          (ref) => Future.value(FotoDataPengguna.kosong()),
        ),
        penyediaKamus.overrideWith(
          (ref) => Future.value(<String, IstilahKamus>{}),
        ),
      ],
      child: MaterialApp(
        theme: TemaFunda.temaTerang,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(skalaTeks)),
          child: anak,
        ),
      ),
    );
  }

  group('Uji Widget Mode Sandbox (Tahap 9A)', () {
    testWidgets('1. Banner Mode Sandbox dan Disclaimer tampil di atas', (
      tester,
    ) async {
      await tester.pumpWidget(buatLayarUji(const LayarSandbox()));
      await pompaHinggaAda(
        tester,
        find.byKey(const Key('banner_mode_sandbox')),
      );

      // Verifikasi teks banner persis
      expect(
        find.text('Mode Sandbox — Uang Fiktif (Simulasi, bukan prediksi)'),
        findsOneWidget,
      );

      // Verifikasi disclaimer tampil dan tombol Mengerti dapat dilipat
      expect(find.byType(LayarSandbox), findsOneWidget);
      final tombolMengerti = find.text('Mengerti');
      if (tombolMengerti.evaluate().isNotEmpty) {
        await tester.tap(tombolMengerti);
        await tester.pump();
      }

      // Verifikasi modal awal default Rp10.000.000 dan Tahun 0
      expect(find.text('Rp10.000.000'), findsWidgets);
      expect(find.text('Tahun 0 (Awal)'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets(
      '2. Slider alokasi != 100% menonaktifkan tombol Majukan 1 Tahun',
      (tester) async {
        await tester.pumpWidget(buatLayarUji(const LayarSandbox()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('tombol_majukan_sandbox')),
        );

        // Awalnya alokasi 40/30/30 = 100% (tombol aktif)
        final tombolMajukanFinder = find.byKey(
          const Key('tombol_majukan_sandbox'),
        );
        var tombolMajukan = tester.widget<ElevatedButton>(tombolMajukanFinder);
        expect(tombolMajukan.onPressed, isNotNull);

        // Ubah alokasi via notifier menjadi tidak 100% (misal 50/30/30 = 110%)
        final container = ProviderScope.containerOf(
          tester.element(find.byType(LayarSandbox)),
        );
        container
            .read(penyediaSandbox.notifier)
            .ubahAlokasi(persenPasarUang: 50);
        await tester.pump();

        // Verifikasi total alokasi 110% dan tombol dinonaktifkan
        expect(find.text('Total: 110%'), findsOneWidget);
        tombolMajukan = tester.widget<ElevatedButton>(tombolMajukanFinder);
        expect(tombolMajukan.onPressed, isNull);

        // Kembalikan ke 100% (40/30/30)
        container
            .read(penyediaSandbox.notifier)
            .ubahAlokasi(persenPasarUang: 40);
        await tester.pump();
        tombolMajukan = tester.widget<ElevatedButton>(tombolMajukanFinder);
        expect(tombolMajukan.onPressed, isNotNull);

        await bongkarWidget(tester);
      },
    );

    testWidgets('3. Majukan 1 tahun memperbarui portofolio dan riwayat', (
      tester,
    ) async {
      await tester.pumpWidget(buatLayarUji(const LayarSandbox()));
      await pompaHinggaAda(
        tester,
        find.byKey(const Key('tombol_majukan_sandbox')),
      );

      // Pastikan tombol terlihat sebelum ditekan
      final tombolFinder = find.byKey(const Key('tombol_majukan_sandbox'));
      await tester.ensureVisible(tombolFinder);
      await tester.pump();

      // Tekan tombol majukan 1 tahun
      await tester.tap(tombolFinder);
      await tester.pump();
      await pompaHinggaAda(tester, find.text('Tahun 1'));

      // Verifikasi portofolio berubah ke Tahun 1 (skenario normal: 10.640.000, selisih +640.000)
      expect(find.text('Tahun 1'), findsOneWidget);
      expect(find.text('Rp10.640.000'), findsWidgets);
      expect(find.text('+Rp640.000'), findsWidgets);

      // Riwayat muncul
      expect(find.text('Riwayat Simulasi'), findsOneWidget);
      expect(find.text('Tahun 1 (normal)'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets('4. Tombol Reset mengembalikan modal awal dan menghapus sesi', (
      tester,
    ) async {
      await tester.pumpWidget(buatLayarUji(const LayarSandbox()));
      await pompaHinggaAda(
        tester,
        find.byKey(const Key('tombol_majukan_sandbox')),
      );

      final tombolFinder = find.byKey(const Key('tombol_majukan_sandbox'));
      await tester.ensureVisible(tombolFinder);
      await tester.pump();

      // Majukan dulu 1 tahun
      await tester.tap(tombolFinder);
      await tester.pump();
      await pompaHinggaAda(tester, find.text('Tahun 1'));
      expect(find.text('Tahun 1'), findsOneWidget);

      // Tekan tombol Reset di AppBar
      await tester.tap(find.byKey(const Key('tombol_reset_sandbox')));
      await tester.pump();
      await pompaHinggaAda(
        tester,
        find.byKey(const Key('konfirmasi_reset_sandbox')),
      );

      // Dialog konfirmasi muncul, tekan konfirmasi reset
      await tester.tap(find.byKey(const Key('konfirmasi_reset_sandbox')));
      await tester.pump();
      await pompaHinggaAda(tester, find.text('Tahun 0 (Awal)'));

      // Kembali ke Tahun 0 dan Rp10.000.000
      expect(find.text('Tahun 0 (Awal)'), findsOneWidget);
      expect(find.text('Rp10.000.000'), findsWidgets);

      await bongkarWidget(tester);
    });

    testWidgets(
      '5. Aksesibilitas: Bebas overflow pada layar 360x640 dengan skala teks 2.0',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buatLayarUji(const LayarSandbox(), skalaTeks: 2.0),
        );
        await tester.pump();

        // Pastikan tidak ada exception overflow yang dilempar
        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '6. Kartu Misi Sandbox pada Pelajaran 11.2 (investasi_dasar_11_2)',
      (tester) async {
        final f = File(
          'aset/konten/menengah/investasi_dasar/investasi_dasar_11_2.json',
        );
        expect(f.existsSync(), isTrue);
        final pel = PembacaKonten.uraiPelajaran(
          f.readAsStringSync(),
          namaBerkas: 'investasi_dasar_11_2.json',
        );

        await tester.pumpWidget(
          buatLayarUji(
            LayarPemutarPelajaran(
              modulId: 'investasi_dasar',
              pelajaranId: 'investasi_dasar_11_2',
              pelajaranOverride: pel,
            ),
          ),
        );
        await tester.pump();

        // Maju melewati pemantik dan 3 kartu konsep serta contoh angka
        while (find.text('Uji Pemahaman Singkat').evaluate().isEmpty) {
          final btnLanjut = find.byKey(const Key('tombol_lanjut'));
          expect(btnLanjut, findsOneWidget);
          await tester.tap(btnLanjut);
          await tester.pump();
        }

        // Jawab 3 soal Cek Paham 11.2
        final opsi1 = find.textContaining(
          'Makin tinggi potensi imbal hasil, umumnya makin besar',
        );
        await tester.ensureVisible(opsi1);
        await tester.pump();
        await tester.tap(opsi1);
        await tester.pump();

        final opsi2 = find.textContaining(
          'Meredam guncangan dengan membagi dana',
        );
        await tester.ensureVisible(opsi2);
        await tester.pump();
        await tester.tap(opsi2);
        await tester.pump();

        final opsi3 = find.textContaining('Saham');
        await tester.ensureVisible(opsi3.first);
        await tester.pump();
        await tester.tap(opsi3.first);
        await tester.pump();

        // Tap Lanjut ke Misi
        final btnLanjutKeMisi = find.byKey(const Key('tombol_lanjut'));
        expect(
          tester.widget<TombolFunda>(btnLanjutKeMisi).padaTekan,
          isNotNull,
        );
        await tester.tap(btnLanjutKeMisi);
        await tester.pump();

        // Verifikasi tombol Buka Mode Sandbox & Periksa Misi tampil
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('tombol_buka_sandbox')),
        );
        expect(find.byKey(const Key('tombol_buka_sandbox')), findsOneWidget);
        expect(
          find.byKey(const Key('tombol_periksa_misi_sandbox')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('tombol_lewati_misi')), findsOneWidget);

        // Tekan lewati misi
        await tester.tap(find.byKey(const Key('tombol_lewati_misi')));
        await tester.pump();
        expect(find.text('Misi ini kamu lewati.'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );
  });
}
