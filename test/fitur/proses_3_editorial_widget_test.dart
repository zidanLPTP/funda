@Timeout(Duration(seconds: 30))
library;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/frekuensi_tagihan.dart';
import 'package:funda/data/model/jenis_bunga.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_tagihan.dart';
import 'package:funda/data/model/jenis_utang.dart';
import 'package:funda/data/model/sifat_kategori.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/fitur/kategori/tampilan/layar_daftar_kategori.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_form_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_jadwal_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_semua_tagihan.dart';
import 'package:funda/fitur/utang/tampilan/layar_daftar_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_detail_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_form_utang.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;
  late String dompetId;
  late String utangId;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    db = BasisDataFunda(NativeDatabase.memory());
    final repoDompet = DompetRepositori(db);
    final repoKategori = KategoriRepositori(db);
    final repoUtang = UtangRepositori(db);
    final repoTagihan = TagihanRepositori(db);

    await repoKategori.tambahKategoriKustom(
      TabelKategoriCompanion(
        id: const drift.Value('kat_tagihan_uji'),
        nama: const drift.Value('Listrik & Internet'),
        arus: const drift.Value('keluar'),
        sifat: drift.Value(SifatKategori.kebutuhan.kode),
        ikon: const drift.Value('zap'),
        bawaan: const drift.Value(false),
        diarsipkan: const drift.Value(false),
      ),
    );

    dompetId = await repoDompet.buatDompet(
      nama: 'BCA Utama',
      jenis: JenisDompet.rekeningBank.kode,
      ikon: 'building2',
      warna: 'tintBiru',
      saldoAwalRupiah: 5000000,
    );

    utangId = await repoUtang.buatUtang(
      nama: 'Cicilan Laptop Kerja',
      jenis: JenisUtang.cicilan.kode,
      pemberi: 'Bank Mandiri',
      sisaAwalRupiah: 6000000,
      pokokAwalRupiah: 12000000,
      jenisBunga: JenisBunga.tanpaBunga.kode,
      tenorBulan: 12,
      cicilanBulananRupiah: 1000000,
      tanggalJatuhTempoBulanan: 15,
    );

    await repoTagihan.buatTagihan(
      nama: 'Internet Rumah',
      jenis: JenisTagihan.tagihan.kode,
      jumlahPerkiraanRupiah: 350000,
      kategoriId: 'kat_tagihan_uji',
      dompetId: dompetId,
      frekuensi: FrekuensiTagihan.bulanan.kode,
      jatuhTempoPertama: DateTime.now(),
      pengingatHariSebelum: const [0, 1, 3],
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

  group('Proses 3 Editorial: Utang, Tagihan, Kategori & Pengaturan', () {
    testWidgets(
      '1. Target sentuh tombol kembali bulat >= 48x48dp di ke-8 layar Proses 3',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarLayar = <Widget>[
          const LayarDaftarUtang(),
          LayarDetailUtang(utangId: utangId),
          const LayarFormUtang(),
          const LayarJadwalTagihan(),
          const LayarSemuaTagihan(),
          const LayarFormTagihan(),
          const LayarDaftarKategori(),
          const LayarPengaturan(),
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

        await tester.pumpWidget(bungkusUji(const LayarDaftarUtang()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_daftar_utang_aktif')),
        );
        expect(
          find.byKey(const Key('hero_kanvas_daftar_utang')),
          findsOneWidget,
        );
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(LayarDetailUtang(utangId: utangId)));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('hero_kanvas_detail_utang')),
        );
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarFormUtang()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('tombol_simpan_utang')),
        );
        final tombolUtang = tester.widget<TombolFunda>(
          find.byKey(const Key('tombol_simpan_utang')),
        );
        expect(tombolUtang.varian, equals(VarianTombolFunda.pilGelap));
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarJadwalTagihan()));
        await pompaHinggaAda(tester, find.text('Internet Rumah'));
        expect(
          find.byKey(const Key('hero_kanvas_jadwal_tagihan')),
          findsOneWidget,
        );
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarSemuaTagihan()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_master_tagihan')),
        );
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarFormTagihan()));
        await pompaHinggaAda(
          tester,
          find.widgetWithText(TombolFunda, 'Tambah Tagihan'),
        );
        final tombolTagihan = tester.widget<TombolFunda>(
          find.widgetWithText(TombolFunda, 'Tambah Tagihan'),
        );
        expect(tombolTagihan.varian, equals(VarianTombolFunda.pilGelap));
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Skala teks 2.0 pada 360x640 bebas overflow di ke-8 layar Proses 3',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarLayar = <Widget>[
          const LayarDaftarUtang(),
          LayarDetailUtang(utangId: utangId),
          const LayarFormUtang(),
          const LayarJadwalTagihan(),
          const LayarSemuaTagihan(),
          const LayarFormTagihan(),
          const LayarDaftarKategori(),
          const LayarPengaturan(),
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
