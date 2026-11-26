@Timeout(Duration(seconds: 30))
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../pembantu/pompa_uji.dart';

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

  Widget bungkusUji(Widget child, {double skalaTeks = 1.0, Size? ukuran}) {
    final lebar = ukuran?.width ?? 412;
    final tinggi = ukuran?.height ?? 915;
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaTanpaAnimasi.overrideWithValue(true),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: Size(lebar, tinggi),
          textScaler: TextScaler.linear(skalaTeks),
        ),
        child: MaterialApp(theme: TemaFunda.temaTerang, home: child),
      ),
    );
  }

  group('Redesain Editorial Tab Lainnya', () {
    testWidgets(
      '1. Header pil Pengaturan, 2 kartu kanvas bersebelahan, 3 grup kartu putih tanpa jargon Aset & tanpa duplikasi',
      (tester) async {
        await tester.pumpWidget(bungkusUji(const LayarLainnya()));
        await tester.pump();

        expect(find.text('Lainnya'), findsOneWidget);
        expect(
          find.byKey(const Key('tombol_pengaturan_header_lainnya')),
          findsOneWidget,
        );
        expect(find.text('Pengaturan'), findsOneWidget);

        // Dua kartu kanvas sorotan
        expect(find.byKey(const Key('kartu_sorotan_laporan')), findsOneWidget);
        expect(find.byKey(const Key('kartu_sorotan_sandbox')), findsOneWidget);
        expect(find.text('Laporan Bulanan'), findsOneWidget);
        expect(find.text('Mode Sandbox'), findsOneWidget);

        // Posisi horizontal berdampingan saat skala normal
        final posLaporan = tester.getTopLeft(
          find.byKey(const Key('kartu_sorotan_laporan')),
        );
        final posSandbox = tester.getTopLeft(
          find.byKey(const Key('kartu_sorotan_sandbox')),
        );
        expect(posLaporan.dy, equals(posSandbox.dy));
        expect(posSandbox.dx, greaterThan(posLaporan.dx));

        // Tiga grup menu kartu putih berpemisah tipis
        expect(find.byKey(const Key('kartu_grup_perencanaan')), findsOneWidget);
        expect(
          find.byKey(const Key('kartu_grup_dompet_kekayaan')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('kartu_grup_aplikasi_data')),
          findsOneWidget,
        );
        expect(find.text('Perencanaan & Tagihan'), findsOneWidget);
        expect(find.text('Dompet & Kekayaan'), findsOneWidget);
        expect(find.text('Aplikasi & Data'), findsOneWidget);

        // Pastikan tidak ada jargon "Aset" atau fitur debug UI
        expect(find.textContaining('Aset'), findsNothing);
        expect(find.text('Galeri Komponen UI'), findsNothing);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. Bottom sheet Privasi & Keamanan dan Tentang Funda tampil bersih dengan TombolFunda.pilGelap',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(bungkusUji(const LayarLainnya()));
        await tester.pump();

        // Buka bottom sheet Privasi & Keamanan
        await tester.ensureVisible(find.text('Privasi & Keamanan'));
        await tester.tap(find.text('Privasi & Keamanan'));
        await pompaHinggaAda(tester, find.text('Tersimpan Lokal di HP'));

        expect(find.text('Tanpa Akun, Server, & Pelacak'), findsOneWidget);
        expect(find.text('Kendali Penuh Lewat Cadangan'), findsOneWidget);

        Navigator.of(tester.element(find.text('Tersimpan Lokal di HP'))).pop();
        await pompaHinggaHilang(tester, find.text('Tersimpan Lokal di HP'));

        // Buka bottom sheet Tentang Funda
        await tester.ensureVisible(find.text('Tentang Funda'));
        await tester.tap(find.text('Tentang Funda'));
        await pompaHinggaAda(tester, find.text('100% Offline & Privat'));

        Navigator.of(tester.element(find.text('100% Offline & Privat'))).pop();
        await pompaHinggaHilang(tester, find.text('100% Offline & Privat'));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Skala teks 2.0 pada 360x640 menumpuk kartu kanvas secara vertikal & bebas overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          bungkusUji(
            const LayarLainnya(),
            skalaTeks: 2.0,
            ukuran: const Size(360, 640),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);

        // Kartu kanvas menumpuk vertikal saat textScale > 1.3
        final posLaporan = tester.getTopLeft(
          find.byKey(const Key('kartu_sorotan_laporan')),
        );
        final posSandbox = tester.getTopLeft(
          find.byKey(const Key('kartu_sorotan_sandbox')),
        );
        expect(posSandbox.dy, greaterThan(posLaporan.dy));

        await bongkarWidget(tester);
      },
    );
  });
}
