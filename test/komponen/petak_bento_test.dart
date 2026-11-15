import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/komponen/petak_bento.dart';
import 'package:funda/tema/tema.dart';

void main() {
  Widget bungkusDenganTema(Widget child) {
    return MaterialApp(
      theme: TemaFunda.temaTerang,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('PetakBento Widget Test', () {
    testWidgets('menampilkan konten anak dan merespons ketukan', (
      tester,
    ) async {
      var diketuk = false;

      await tester.pumpWidget(
        bungkusDenganTema(
          PetakBento.ukuran2x1(
            padaKetuk: () => diketuk = true,
            labelAkses: 'Petak Arus Kas',
            anak: const Text('Isi Petak Bento'),
          ),
        ),
      );

      expect(find.text('Isi Petak Bento'), findsOneWidget);

      await tester.tap(find.byType(PetakBento));
      await tester.pumpAndSettle();

      expect(diketuk, isTrue);
    });

    testWidgets('memiliki border radius 24dp sesuai token SudutFunda.petak', (
      tester,
    ) async {
      await tester.pumpWidget(
        bungkusDenganTema(
          const PetakBento.ukuran1x1(
            tint: TintPetakBento.biru,
            anak: Text('Petak 1x1'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PetakBento),
          matching: find.byType(Container),
        ),
      );

      final dekorasi = container.decoration as BoxDecoration;
      expect(dekorasi.borderRadius, equals(BorderRadius.circular(24.0)));
    });

    testWidgets('mengaktifkan Semantics button bila bisa diketuk', (
      tester,
    ) async {
      await tester.pumpWidget(
        bungkusDenganTema(
          PetakBento.ukuran2x1(
            labelAkses: 'Label Akses Bento',
            padaKetuk: () {},
            anak: const Text('Bisa diketuk'),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == 'Label Akses Bento',
        ),
        findsOneWidget,
      );
    });
  });
}
