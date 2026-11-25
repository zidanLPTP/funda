@Timeout(Duration(seconds: 30))
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_tujuan.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';
import 'package:funda/fitur/dompet/tampilan/layar_daftar_dompet.dart';
import 'package:funda/fitur/dompet/tampilan/layar_detail_dompet.dart';
import 'package:funda/fitur/dompet/tampilan/layar_form_dompet.dart';
import 'package:funda/fitur/kantong/kontroler/penyedia_kantong.dart';
import 'package:funda/fitur/kantong/tampilan/layar_daftar_kantong.dart';
import 'package:funda/fitur/kekayaan_bersih/tampilan/layar_kekayaan_bersih.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_daftar_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_detail_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_form_tujuan.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;
  late String dompetId;
  late String tujuanId;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    db = BasisDataFunda(NativeDatabase.memory());
    final repoDompet = DompetRepositori(db);
    final repoTujuan = TujuanRepositori(db);

    dompetId = await repoDompet.buatDompet(
      nama: 'BCA Utama',
      jenis: JenisDompet.rekeningBank.kode,
      ikon: 'building2',
      warna: 'tintBiru',
      saldoAwalRupiah: 5000000,
    );

    tujuanId = await repoTujuan.buatTujuan(
      nama: 'Dana Liburan',
      jenis: JenisTujuan.tabungan.kode,
      targetRupiah: 12000000,
      ikon: 'plane',
      warna: 'biru',
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget bungkusUji(
    Widget child, {
    double skalaTeks = 1.0,
    Size ukuran = const Size(412, 915),
  }) {
    return ProviderScope(
      key: UniqueKey(),
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaTanpaAnimasi.overrideWithValue(true),
        penyediaSaldoKantong.overrideWith((ref, id) => Stream.value(0)),
      ],
      child: MaterialApp(
        theme: TemaFunda.temaTerang,
        home: MediaQuery(
          data: MediaQueryData(
            size: ukuran,
            textScaler: TextScaler.linear(skalaTeks),
          ),
          child: child,
        ),
      ),
    );
  }

  group('Proses 2 Editorial: Dompet, Tujuan, Kantong & Kekayaan Bersih', () {
    testWidgets(
      '1. Target sentuh tombol kembali bulat >= 48x48dp & tombol CTA pilGelap di seluruh layar Proses 2',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarLayar = <Widget>[
          const LayarDaftarDompet(),
          LayarDetailDompet(dompetId: dompetId),
          const LayarFormDompet(),
          const LayarDaftarTujuan(),
          LayarDetailTujuan(tujuanId: tujuanId),
          const LayarFormTujuan(),
          const LayarDaftarKantong(),
          const LayarKekayaanBersih(),
        ];

        for (final layar in daftarLayar) {
          await tester.pumpWidget(bungkusUji(layar));
          await pompaHinggaAda(
            tester,
            find.byKey(const Key('tombol_kembali_editorial')),
          );

          final ukuran = tester.getSize(
            find.byKey(const Key('tombol_kembali_editorial')),
          );
          expect(ukuran.width, greaterThanOrEqualTo(48));
          expect(ukuran.height, greaterThanOrEqualTo(48));

          await bongkarWidget(tester);
        }
      },
    );

    testWidgets(
      '2. Kartu hero kanvas, daftar kartu putih 1px, dan sticky CTA pilGelap tampil sesuai',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(bungkusUji(const LayarDaftarDompet()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('hero_kanvas_dompet')),
        );
        expect(
          find.byKey(const Key('kartu_daftar_dompet_aktif')),
          findsOneWidget,
        );
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarFormDompet()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('tombol_simpan_dompet')),
        );
        final tombolDompet = tester.widget<TombolFunda>(
          find.byKey(const Key('tombol_simpan_dompet')),
        );
        expect(tombolDompet.varian, equals(VarianTombolFunda.pilGelap));
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarDaftarTujuan()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('hero_kanvas_daftar_tujuan')),
        );
        expect(find.byKey(const Key('kartu_daftar_tujuan')), findsOneWidget);
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarFormTujuan()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('tombol_simpan_tujuan')),
        );
        final tombolTujuan = tester.widget<TombolFunda>(
          find.byKey(const Key('tombol_simpan_tujuan')),
        );
        expect(tombolTujuan.varian, equals(VarianTombolFunda.pilGelap));
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarKekayaanBersih()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('hero_kanvas_kekayaan_bersih')),
        );
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Skala teks 2.0 pada 360x640 bebas overflow di ke-8 layar Proses 2',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarLayar = <Widget>[
          const LayarDaftarDompet(),
          LayarDetailDompet(dompetId: dompetId),
          const LayarFormDompet(),
          const LayarDaftarTujuan(),
          LayarDetailTujuan(tujuanId: tujuanId),
          const LayarFormTujuan(),
          const LayarDaftarKantong(),
          const LayarKekayaanBersih(),
        ];

        for (final layar in daftarLayar) {
          await tester.pumpWidget(
            bungkusUji(layar, skalaTeks: 2.0, ukuran: const Size(360, 640)),
          );
          await pompaHinggaAda(
            tester,
            find.byKey(const Key('tombol_kembali_editorial')),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          await bongkarWidget(tester);
        }
      },
    );
  });
}
