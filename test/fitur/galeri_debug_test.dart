import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/aplikasi.dart';
import 'package:funda/aplikasi/rute.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Akses Galeri Komponen (kDebugMode)', () {
    test('kDebugMode bernilai true di environment pengujian/debug', () {
      expect(kDebugMode, isTrue);
    });

    test('rute /galeri terdaftar saat kDebugMode aktif', () {
      final ruteCocok = ruteFunda.configuration.routes.any(
        (rute) => rute is GoRoute && rute.path == '/galeri',
      );
      expect(ruteCocok, isTrue);
    });

    testWidgets(
      'banner pengembang galeri tampil pada LayarBeranda di mode debug',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaTotalSaldoAktif.overrideWithValue(0),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value(const []),
              ),
              penyediaSisaAnggaranBulanIni.overrideWith(
                (ref) => Future.value(0),
              ),
              penyediaTujuanTerdekat.overrideWithValue(null),
            ],
            child: const AplikasiFunda(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LayarBeranda), findsOneWidget);
        expect(
          find.textContaining('Mode Pengembang: Buka Galeri Komponen & Token'),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );

    testWidgets('kartu galeri tampil pada LayarLainnya di mode debug', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            penyediaTotalSaldoAktif.overrideWithValue(0),
            penyediaArusKasBulanIni.overrideWithValue(
              const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
            ),
            penyediaDaftarDompetAktif.overrideWith(
              (ref) => Stream.value(const []),
            ),
            penyediaSisaAnggaranBulanIni.overrideWith((ref) => Future.value(0)),
            penyediaTujuanTerdekat.overrideWithValue(null),
          ],
          child: const AplikasiFunda(),
        ),
      );
      await tester.pumpAndSettle();

      // Pindah ke tab Lainnya
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();

      expect(find.byType(LayarLainnya), findsOneWidget);
      expect(find.text('Galeri Komponen UI'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
