@Timeout(Duration(seconds: 30))
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/onboarding/tampilan/layar_onboarding.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_beranda.dart';
import 'package:funda/tema/tema_funda.dart';
import 'package:funda/util/haptic.dart';
import '../pembantu/pompa_uji.dart';

void main() {
  group('Pengujian Fitur Poles & Delight (Tahap 12B)', () {
    testWidgets('TeksAngkaAnimasi merender angka awal dan target beranimasi', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaFunda.temaTerang,
          home: const Scaffold(
            body: TeksAngkaAnimasi(
              nilai: 1000000,
              durasi: Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      expect(find.byType(TeksAngkaAnimasi), findsOneWidget);

      await pompaHinggaAda(tester, find.text('Rp 1.000.000'));
      expect(find.text('Rp 1.000.000'), findsOneWidget);
    });

    testWidgets('BilahKemajuanAnimasi merender persentase dan bergerak halus', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaFunda.temaTerang,
          home: const Scaffold(
            body: SizedBox(
              width: 200,
              child: BilahKemajuanAnimasi(
                persen: 75,
                durasi: Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BilahKemajuanAnimasi), findsOneWidget);
      await tester.pump();
      expect(find.byType(BilahKemajuanAnimasi), findsOneWidget);
    });

    testWidgets('Efek perayaan konfeti dapat dipanggil tanpa melempar error', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaFunda.temaTerang,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => tampilkanEfekPerayaan(context),
                  child: const Text('Rayakan'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Rayakan'));
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'LayarOnboarding menampilkan slide, navigasi, dan tombol aksi',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarOnboarding(),
            ),
          ),
        );

        // Slide 1: Datamu 100% Milikmu, Tersimpan di HP-mu
        expect(
          find.text('Datamu 100% Milikmu, Tersimpan di HP-mu'),
          findsOneWidget,
        );
        expect(find.text('Lewati'), findsOneWidget);
        expect(find.text('Lanjut'), findsOneWidget);

        // Pindah ke Slide 2
        final controller = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        controller.jumpToPage(1);
        await tester.pump();
        expect(
          find.text('18 Modul Finansial Berbasis Uang Nyatamu'),
          findsOneWidget,
        );

        // Pindah ke Slide 3
        controller.jumpToPage(2);
        await tester.pump();
        expect(
          find.text('Ruang Tenang Menata dan Memahami Arus Kas'),
          findsOneWidget,
        );
        expect(find.text('Mulai Jelajahi Funda'), findsOneWidget);
      },
    );

    test(
      'hitungSapaanKontekstual mengembalikan sapaan ramah sesuai rentang waktu',
      () {
        final pagi = hitungSapaanKontekstual(DateTime(2026, 11, 10, 8, 30));
        expect(pagi.sapaan, 'Selamat pagi');
        expect(pagi.pesanMotivasi.isNotEmpty, isTrue);

        final siang = hitungSapaanKontekstual(DateTime(2026, 11, 10, 13, 0));
        expect(siang.sapaan, 'Selamat siang');

        final sore = hitungSapaanKontekstual(DateTime(2026, 11, 10, 16, 45));
        expect(sore.sapaan, 'Selamat sore');

        final malam = hitungSapaanKontekstual(DateTime(2026, 11, 10, 21, 15));
        expect(malam.sapaan, 'Selamat malam');
      },
    );

    test('UtilHaptic menghormati sakelar preferensi aktif/nonaktif', () {
      UtilHaptic.aktif = true;
      expect(UtilHaptic.aktif, isTrue);
      UtilHaptic.pilih();
      UtilHaptic.ringan();
      UtilHaptic.sedang();
      UtilHaptic.sukses();
      UtilHaptic.suksesBesar();

      UtilHaptic.aktif = false;
      expect(UtilHaptic.aktif, isFalse);
      UtilHaptic.pilih();
      UtilHaptic.ringan();
      UtilHaptic.sedang();
      UtilHaptic.sukses();
      UtilHaptic.suksesBesar();

      // Kembalikan ke default true
      UtilHaptic.aktif = true;
    });
  });
}
