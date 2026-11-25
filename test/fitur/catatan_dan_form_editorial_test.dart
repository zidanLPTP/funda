@Timeout(Duration(seconds: 30))
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_transaksi.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/transaksi_repositori.dart';
import 'package:funda/fitur/catatan/tampilan/layar_catatan.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/tema/tema.dart';
import 'package:funda/tema/token.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;
  late DompetRepositori repoDompet;
  late KategoriRepositori repoKategori;
  late TransaksiRepositori repoTransaksi;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    db = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(db);
    repoKategori = KategoriRepositori(db);
    repoTransaksi = TransaksiRepositori(db);

    await repoDompet.tambahDompet(
      const TabelDompetCompanion(
        id: Value('d_tunai'),
        nama: Value('Dompet Tunai'),
        jenis: Value('tunai'),
        ikon: Value('wallet'),
        warna: Value('tintHijau'),
        saldoAwalRupiah: Value(500000),
      ),
    );
    await repoDompet.tambahDompet(
      const TabelDompetCompanion(
        id: Value('d_bank'),
        nama: Value('Rekening Bank'),
        jenis: Value('bank'),
        ikon: Value('landmark'),
        warna: Value('tintBiru'),
        saldoAwalRupiah: Value(2000000),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget bungkusUji(Widget child) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaTanpaAnimasi.overrideWithValue(true),
        penyediaDompetRepositori.overrideWithValue(repoDompet),
        penyediaKategoriRepositori.overrideWithValue(repoKategori),
        penyediaTransaksiRepositori.overrideWithValue(repoTransaksi),
      ],
      child: MaterialApp(theme: TemaFunda.temaTerang, home: child),
    );
  }

  group('Redesain Editorial LayarCatatan & LayarFormTransaksi', () {
    testWidgets(
      '1. Form Transaksi: warna kanvas berubah dinamis (Koral / Mint / Biru), chip dompet cepat & transfer sheet dengan tukar arah',
      (tester) async {
        await tester.pumpWidget(bungkusUji(const LayarFormTransaksi()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('daftar_chip_dompet_cepat')),
        );

        // Default Pengeluaran -> kanvasKoral + chip dompet horizontal langsung tampil
        var headerBox =
            tester
                    .widget<Container>(
                      find.byKey(const Key('header_kanvas_form_transaksi')),
                    )
                    .decoration
                as BoxDecoration;
        expect(headerBox.color, equals(WarnaFunda.kanvasKoral));
        expect(
          find.byKey(const Key('daftar_chip_dompet_cepat')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('chip_dompet_d_tunai')), findsOneWidget);
        expect(find.byKey(const Key('chip_dompet_d_bank')), findsOneWidget);

        // Pindah ke Pemasukan -> kanvasMint
        await tester.tap(find.text('Pemasukan'));
        await tester.pump();
        headerBox =
            tester
                    .widget<Container>(
                      find.byKey(const Key('header_kanvas_form_transaksi')),
                    )
                    .decoration
                as BoxDecoration;
        expect(headerBox.color, equals(WarnaFunda.kanvasMint));

        // Pindah ke Transfer -> kanvasBiru + alur asal -> tujuan + modal pilih dompet + tukar arah
        await tester.tap(find.text('Transfer'));
        await tester.pump();
        headerBox =
            tester
                    .widget<Container>(
                      find.byKey(const Key('header_kanvas_form_transaksi')),
                    )
                    .decoration
                as BoxDecoration;
        expect(headerBox.color, equals(WarnaFunda.kanvasBiru));
        expect(
          find.byKey(const Key('pemilih_dompet_asal_transfer')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('pemilih_dompet_tujuan_transfer')),
          findsOneWidget,
        );

        // Pilih dompet tujuan lewat bottom sheet
        await tester.tap(
          find.byKey(const Key('pemilih_dompet_tujuan_transfer')),
        );
        await pompaHinggaAda(tester, find.text('Pilih Dompet Tujuan'));
        await tester.tap(find.text('Rekening Bank'));
        await pompaHinggaHilang(tester, find.text('Pilih Dompet Tujuan'));

        expect(find.textContaining('Rekening Bank'), findsOneWidget);

        // Ketuk Tukar -> dompet asal menjadi Rekening Bank, tujuan menjadi Dompet Tunai
        await tester.tap(find.byKey(const Key('tombol_tukar_dompet_transfer')));
        await tester.pump();
        final teksAsal = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const Key('pemilih_dompet_asal_transfer')),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data ?? '')
            .join(' ');
        expect(teksAsal, contains('Rekening Bank'));

        // Sticky CTA simpan pakai TombolFunda.pilGelap
        expect(
          find.byKey(const Key('tombol_simpan_transaksi')),
          findsOneWidget,
        );
        final tombolSimpan = tester.widget<TombolFunda>(
          find.byKey(const Key('tombol_simpan_transaksi')),
        );
        expect(tombolSimpan.varian, equals(VarianTombolFunda.pilGelap));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. LayarCatatan menampilkan tombol pil Catat header dan menggabungkan transaksi 1 hari ke dalam 1 kartu putih',
      (tester) async {
        final semuaKat = await db.select(db.tabelKategori).get();
        final katMakan = semuaKat.firstWhere((k) => k.nama == 'Makan Harian');
        final katGaji = semuaKat.firstWhere((k) => k.nama == 'Gaji');
        final kini = DateTime.now();

        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: const Value('tx1'),
            jenis: Value(JenisTransaksi.keluar.kode),
            jumlahRupiah: const Value(25000),
            dompetId: const Value('d_tunai'),
            kategoriId: Value(katMakan.id),
            catatan: const Value('Sarapan'),
            waktuTransaksi: Value(kini),
          ),
        );
        await repoTransaksi.tambahTransaksi(
          TabelTransaksiCompanion(
            id: const Value('tx2'),
            jenis: Value(JenisTransaksi.masuk.kode),
            jumlahRupiah: const Value(500000),
            dompetId: const Value('d_bank'),
            kategoriId: Value(katGaji.id),
            catatan: const Value('Bonus'),
            waktuTransaksi: Value(kini),
          ),
        );

        await tester.pumpWidget(bungkusUji(const LayarCatatan()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_harian_catatan_0')),
        );

        expect(
          find.byKey(const Key('tombol_catat_header_catatan')),
          findsOneWidget,
        );
        // Kedua transaksi dalam 1 hari berada di dalam 1 kartu harian tunggal
        expect(find.byKey(const Key('kartu_harian_catatan_0')), findsOneWidget);
        expect(find.byKey(const Key('kartu_harian_catatan_1')), findsNothing);
        expect(find.textContaining('Sarapan'), findsOneWidget);
        expect(find.textContaining('Bonus'), findsOneWidget);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Skala teks 2.0 pada 360x640 bebas overflow di LayarCatatan & LayarFormTransaksi',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaDompetRepositori.overrideWithValue(repoDompet),
              penyediaKategoriRepositori.overrideWithValue(repoKategori),
              penyediaTransaksiRepositori.overrideWithValue(repoTransaksi),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarFormTransaksi(),
              ),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('daftar_chip_dompet_cepat')),
        );
        expect(
          find.byKey(const Key('tombol_simpan_transaksi')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await bongkarWidget(tester);

        await tester.pumpWidget(
          ProviderScope(
            key: UniqueKey(),
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaDompetRepositori.overrideWithValue(repoDompet),
              penyediaKategoriRepositori.overrideWithValue(repoKategori),
              penyediaTransaksiRepositori.overrideWithValue(repoTransaksi),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(2.0),
              ),
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: const LayarCatatan(),
              ),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('tombol_catat_header_catatan')),
        );
        expect(tester.takeException(), isNull);
        await bongkarWidget(tester);
      },
    );
  });
}
