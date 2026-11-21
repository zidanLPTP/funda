@Timeout(Duration(seconds: 30))
library;

import '../pembantu/pompa_uji.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/anggaran/tampilan/layar_anggaran.dart';
import 'package:funda/fitur/dompet/tampilan/layar_detail_dompet.dart';
import 'package:funda/fitur/kantong/kontroler/penyedia_kantong.dart';
import 'package:funda/fitur/kantong/tampilan/layar_daftar_kantong.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_daftar_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_form_tujuan.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
    // Buat satu dompet awal
    await repoDompet.buatDompet(
      nama: 'BCA Utama',
      jenis: JenisDompet.rekeningBank.kode,
      ikon: 'landmark',
      warna: 'biru',
      saldoAwalRupiah: 5000000,
    );
  });

  tearDown(() async {
    await basisData.close();
  });

  Widget buatAplikasiUji(Widget layar, {double skalaTeks = 1.0}) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(basisData),
        penyediaDaftarTujuanAktif.overrideWith((ref) => Stream.value([])),
        penyediaRealisasiAnggaranBulan.overrideWith((ref) => Future.value([])),
        penyediaKantongDompet.overrideWith((ref, dompetId) => Stream.value([])),
        penyediaSaldoKantong.overrideWith((ref, id) => Stream.value(0)),
      ],
      child: MaterialApp(
        theme: TemaFunda.temaTerang,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(skalaTeks)),
          child: layar,
        ),
      ),
    );
  }

  group('Uji Widget Layar Anggaran', () {
    testWidgets(
      'Layar Anggaran menampilkan navigasi bulan dan keadaan kosong awal',
      (tester) async {
        await tester.pumpWidget(buatAplikasiUji(const LayarAnggaran()));
        await tester.pump();

        expect(find.text('Anggaran Bulanan'), findsOneWidget);
        expect(find.text('Total Anggaran'), findsOneWidget);
        expect(find.text('Belum Ada Anggaran'), findsOneWidget);
        expect(find.text('Atur Anggaran Sekarang'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      'Layar Anggaran lolos uji aksesibilitas skala teks 2.0 tanpa overflow',
      (tester) async {
        await tester.pumpWidget(
          buatAplikasiUji(const LayarAnggaran(), skalaTeks: 2.0),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );
  });

  group('Uji Widget Layar Tujuan', () {
    testWidgets('Layar Daftar Tujuan menampilkan judul dan tombol tambah', (
      tester,
    ) async {
      await tester.pumpWidget(buatAplikasiUji(const LayarDaftarTujuan()));
      await tester.pump();

      expect(find.text('Tujuan Keuangan'), findsOneWidget);
      expect(find.text('Belum Ada Tujuan'), findsOneWidget);
      expect(find.text('Buat Tujuan Pertamamu'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets('Layar Form Tujuan validasi nama dan target dana', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buatAplikasiUji(const LayarFormTujuan()));
      await tester.pump();

      expect(find.text('Tambah Tujuan'), findsOneWidget);

      // Coba tekan simpan tanpa mengisi
      await tester.tap(find.text('Buat Tujuan'));
      await tester.pump();

      expect(find.text('Nama tujuan wajib diisi'), findsOneWidget);

      await bongkarWidget(tester);
    });

    testWidgets(
      'Layar Form Tujuan lolos uji aksesibilitas skala teks 2.0 tanpa overflow',
      (tester) async {
        await tester.pumpWidget(
          buatAplikasiUji(const LayarFormTujuan(), skalaTeks: 2.0),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );
  });

  group('Uji Widget Layar Kantong & Detail Dompet', () {
    testWidgets(
      'Layar Daftar Kantong menampilkan teks edukasi bantuan yang tenang',
      (tester) async {
        await tester.pumpWidget(buatAplikasiUji(const LayarDaftarKantong()));
        await tester.pump();

        expect(find.text('Kantong Dompet'), findsOneWidget);
        expect(
          find.text(
            'Ini hanya penandaan. Uangmu tidak berpindah antar rekening.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Saldo Bebas (Uang Belum Terkunci Kantong)'),
          findsOneWidget,
        );

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      'Layar Detail Dompet menampilkan saldo bebas dan riwayat transaksi',
      (tester) async {
        final daftarDompet = await repoDompet.ambilSemuaDompet();
        final dompetId = daftarDompet.first.id;

        await tester.pumpWidget(
          buatAplikasiUji(LayarDetailDompet(dompetId: dompetId)),
        );
        await tester.pump();

        expect(find.text('BCA Utama'), findsWidgets);
        expect(find.text('Saldo Bebas:'), findsOneWidget);
        expect(find.text('Kantong di Dompet Ini'), findsOneWidget);
        expect(find.text('Riwayat Transaksi Dompet Ini'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      'Layar Detail Dompet lolos uji aksesibilitas skala teks 2.0 tanpa overflow',
      (tester) async {
        final daftarDompet = await repoDompet.ambilSemuaDompet();
        final dompetId = daftarDompet.first.id;

        await tester.pumpWidget(
          buatAplikasiUji(
            LayarDetailDompet(dompetId: dompetId),
            skalaTeks: 2.0,
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);

        await bongkarWidget(tester);
      },
    );
  });
}
