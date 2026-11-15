import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/komponen/tombol_funda.dart';
import 'package:funda/tema/tema.dart';

void main() {
  Widget bungkusDenganTema(Widget child) {
    return MaterialApp(
      theme: TemaFunda.temaTerang,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('TombolFunda Widget Test', () {
    testWidgets('menampilkan teks tombol dan merespons ketukan', (
      tester,
    ) async {
      var ditekan = false;

      await tester.pumpWidget(
        bungkusDenganTema(
          TombolFunda.primer(
            teks: 'Simpan Catatan',
            padaTekan: () => ditekan = true,
          ),
        ),
      );

      expect(find.text('Simpan Catatan'), findsOneWidget);

      await tester.tap(find.byType(TombolFunda));
      await tester.pump();

      expect(ditekan, isTrue);
    });

    testWidgets('tombol nonaktif tidak merespons ketukan', (tester) async {
      await tester.pumpWidget(
        bungkusDenganTema(
          const TombolFunda.primer(teks: 'Tombol Mati', padaTekan: null),
        ),
      );

      final tombol = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(tombol.onPressed, isNull);
    });

    testWidgets('menampilkan indikator memuat saat memuat: true', (
      tester,
    ) async {
      await tester.pumpWidget(
        bungkusDenganTema(
          TombolFunda.primer(teks: 'Proses', memuat: true, padaTekan: () {}),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Proses'), findsNothing);
    });

    testWidgets('memastikan ukuran target sentuh tinggi minimal 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(
        bungkusDenganTema(
          TombolFunda.primer(teks: 'Aksi Minimal 48', padaTekan: () {}),
        ),
      );

      final ukuran = tester.getSize(find.byType(TombolFunda));
      expect(ukuran.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('memiliki label semantik aksesibilitas', (tester) async {
      await tester.pumpWidget(
        bungkusDenganTema(
          TombolFunda.sekunder(
            teks: 'Batal',
            labelAkses: 'Batalkan transaksi',
            padaTekan: () {},
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Batalkan transaksi',
        ),
        findsOneWidget,
      );
    });
  });
}
