@Timeout(Duration(seconds: 30))
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/cadangan/cadangan_repositori.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/anggaran/tampilan/layar_anggaran.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/cadangan/kontroler/penyedia_cadangan.dart';
import 'package:funda/fitur/cadangan/tampilan/layar_cadangan.dart';
import 'package:funda/fitur/laporan/kontroler/penyedia_laporan.dart';
import 'package:funda/fitur/laporan/tampilan/layar_laporan_bulanan.dart';
import 'package:funda/fitur/sandbox/tampilan/layar_sandbox.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_anggaran_tujuan.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;
  late Directory tempDir;
  late CadanganRepositori cadanganRepo;
  late KontenLaporan kontenLaporan;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    db = BasisDataFunda(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('funda_proses1_editorial_');
    cadanganRepo = CadanganRepositori(db, direktoriPenyimpananUji: tempDir);
    kontenLaporan = PembacaKonten.uraiLaporan(
      File('aset/konten/laporan.json').readAsStringSync(),
    );
  });

  tearDown(() async {
    await db.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  Widget bungkusUji(
    Widget child, {
    double skalaTeks = 1.0,
    List<dynamic> overrides = const [],
    Size ukuran = const Size(412, 915),
  }) {
    return ProviderScope(
      key: UniqueKey(),
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaTanpaAnimasi.overrideWithValue(true),
        penyediaCadanganRepositori.overrideWithValue(cadanganRepo),
        penyediaKontenLaporan.overrideWith(
          (ref) => Future.value(kontenLaporan),
        ),
        ...overrides,
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

  group('Proses 1 Editorial: Laporan, Anggaran, Cadangan & Sandbox', () {
    testWidgets(
      '1. Target sentuh tombol kembali bulat >= 48x48dp di keempat layar Proses 1',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarLayar = <Widget>[
          const LayarLaporanBulanan(),
          const LayarAnggaran(),
          const LayarCadangan(),
          const LayarSandbox(),
        ];

        for (final layar in daftarLayar) {
          await tester.pumpWidget(
            bungkusUji(
              layar,
              overrides: [
                penyediaRealisasiAnggaranBulan.overrideWith(
                  (ref) => Future.value([]),
                ),
                penyediaStatusCadangan.overrideWith(
                  (ref) => const StatusFiturCadangan(
                    terakhirDicadangkan: null,
                    adaCadanganKeselamatan: false,
                    jumlahTransaksi: 0,
                    hariSejakDataPertama: 0,
                    ditundaSampai: null,
                    perluPengingat: false,
                  ),
                ),
              ],
            ),
          );
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
      '2. Anggaran Bulanan: status pos memakai ikon + teks + warna dan tombol Salin dari bulan lalu mudah diakses',
      (tester) async {
        const daftarItem = [
          ItemRealisasiAnggaran(
            anggaranId: 'ang_1',
            kategoriId: 'kat_makan',
            namaKategori: 'Makan Harian',
            sifatKategori: 'kebutuhan',
            ikonKategori: 'utensils',
            batasRupiah: 1000000,
            terpakaiRupiah: 850000,
          ),
          ItemRealisasiAnggaran(
            anggaranId: 'ang_2',
            kategoriId: 'kat_hiburan',
            namaKategori: 'Hiburan',
            sifatKategori: 'keinginan',
            ikonKategori: 'film',
            batasRupiah: 500000,
            terpakaiRupiah: 600000,
          ),
        ];

        await tester.pumpWidget(
          bungkusUji(
            const LayarAnggaran(),
            overrides: [
              penyediaRealisasiAnggaranBulan.overrideWith(
                (ref) => Future.value(daftarItem),
              ),
            ],
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_daftar_anggaran')),
        );

        expect(
          find.byKey(const Key('tombol_salin_anggaran_bulan_lalu')),
          findsOneWidget,
        );
        expect(find.text('Salin dari bulan lalu'), findsOneWidget);
        expect(find.text('Mendekati batas'), findsOneWidget);
        expect(find.text('Melebihi batas'), findsOneWidget);
        expect(find.byIcon(LucideIcons.triangleAlert), findsOneWidget);
        expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. Cadangan & Pemulihan menampilkan peringatan privasi & tombol kembalikan data bila cadangan keselamatan ada',
      (tester) async {
        await tester.pumpWidget(
          bungkusUji(
            const LayarCadangan(),
            overrides: [
              penyediaStatusCadangan.overrideWith(
                (ref) => StatusFiturCadangan(
                  terakhirDicadangkan: DateTime(2026, 11, 20),
                  adaCadanganKeselamatan: true,
                  jumlahTransaksi: 12,
                  hariSejakDataPertama: 15,
                  ditundaSampai: null,
                  perluPengingat: false,
                ),
              ),
            ],
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('hero_kanvas_cadangan')),
        );

        expect(
          find.text('Kembalikan Data Sebelum Pemulihan Terakhir'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'tidak dienkripsi. Simpan hanya di tempat yang aman.',
          ),
          findsOneWidget,
        );
        expect(find.byType(TombolFunda), findsWidgets);

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '4. Skala teks 2.0 pada 360x640 bebas overflow di Laporan, Anggaran, Cadangan & Sandbox',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final daftarLayar = <Widget>[
          const LayarLaporanBulanan(),
          const LayarAnggaran(),
          const LayarCadangan(),
          const LayarSandbox(),
        ];

        for (final layar in daftarLayar) {
          await tester.pumpWidget(
            bungkusUji(
              layar,
              skalaTeks: 2.0,
              ukuran: const Size(360, 640),
              overrides: [
                penyediaRealisasiAnggaranBulan.overrideWith(
                  (ref) => Future.value([]),
                ),
                penyediaStatusCadangan.overrideWith(
                  (ref) => const StatusFiturCadangan(
                    terakhirDicadangkan: null,
                    adaCadanganKeselamatan: true,
                    jumlahTransaksi: 0,
                    hariSejakDataPertama: 0,
                    ditundaSampai: null,
                    perluPengingat: false,
                  ),
                ),
              ],
            ),
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
