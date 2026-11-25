@Timeout(Duration(seconds: 30))
library;

import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/aplikasi/konfigurasi_debug.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/dompet/tampilan/layar_daftar_dompet.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/onboarding/tampilan/layar_onboarding.dart';
import 'package:funda/fitur/tutorial/tampilan/lapisan_tutorial_beranda.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:funda/tema/token.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../pembantu/pompa_uji.dart';

void main() {
  late BasisDataFunda db;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    db = BasisDataFunda(NativeDatabase.memory());
    await db.simpanPengaturan('tutorial_beranda_selesai', 'true');
  });

  tearDown(() async {
    await db.close();
  });

  Widget bungkusUji(
    Widget child, {
    double skalaTeks = 1.0,
    Size ukuran = const Size(412, 915),
    List<dynamic> overridesTambahan = const [],
  }) {
    return ProviderScope(
      key: UniqueKey(),
      overrides: [
        penyediaBasisData.overrideWithValue(db),
        penyediaTanpaAnimasi.overrideWithValue(true),
        ...overridesTambahan.cast(),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: ukuran,
          textScaler: TextScaler.linear(skalaTeks),
          disableAnimations: true,
        ),
        child: MaterialApp(theme: TemaFunda.temaTerang, home: child),
      ),
    );
  }

  group('Ilustrasi SVG & Pembaruan Visual Editorial Tahap 14', () {
    test('1. Seluruh 19 modul & aset khusus terpetakan ke file SVG valid', () {
      const daftarIdModul = [
        'mulai_tes_awal',
        'anggaran_arus_kas',
        'tabungan',
        'dana_darurat',
        'utang_cicilan',
        'waspada_penipuan',
        'psikologi_uang',
        'paylater_kredit',
        'penghasilan_tambahan',
        'pajak_dasar',
        'proteksi_dasar',
        'investasi_dasar',
        'tujuan_besar',
        'investasi_lanjutan',
        'kpr_kredit_besar',
        'pajak_lanjutan',
        'pensiun_kebebasan_finansial',
        'keuangan_usaha_kecil',
        'proteksi_keluarga_warisan',
      ];

      final semuaPath = <String>{};
      for (final id in daftarIdModul) {
        final path = temaVisualUntukModul(id).pathSvg;
        expect(path, startsWith('aset/gambar/ilustrasi/'));
        expect(File(path).existsSync(), isTrue, reason: '$path harus ada');
        semuaPath.add(path);
      }
      expect(semuaPath.length, equals(19));

      for (final path in [
        AsetIlustrasiFunda.dompet,
        AsetIlustrasiFunda.belumAdaDompet,
        AsetIlustrasiFunda.laporanBulanan,
        AsetIlustrasiFunda.modeSandbox,
      ]) {
        expect(File(path).existsSync(), isTrue, reason: '$path harus ada');
      }
    });

    testWidgets(
      '2. LayarBeranda kosong memakai dompet.svg, LayarDaftarDompet kosong memakai belum-ada-dompet.svg, & LayarLainnya memakai laporan + sandbox SVG',
      (tester) async {
        await tester.pumpWidget(
          bungkusUji(
            const LayarBeranda(),
            overridesTambahan: [
              penyediaDaftarDompetAktif.overrideWith((ref) => Stream.value([])),
            ],
          ),
        );
        await pompaHinggaAda(tester, find.text('Selamat Datang di Funda'));

        final svgBerandaKosong = tester.widget<IlustrasiSvgFunda>(
          find.byType(IlustrasiSvgFunda).first,
        );
        expect(svgBerandaKosong.pathAset, AsetIlustrasiFunda.dompet);
        await bongkarWidget(tester);

        await tester.pumpWidget(
          bungkusUji(
            const LayarDaftarDompet(),
            overridesTambahan: [
              penyediaDaftarDompetAktif.overrideWith((ref) => Stream.value([])),
              penyediaDaftarDompet.overrideWith((ref) => Stream.value([])),
            ],
          ),
        );
        await pompaHinggaAda(tester, find.text('Belum Ada Dompet'));

        final svgDompetKosong = tester.widget<IlustrasiSvgFunda>(
          find.byType(IlustrasiSvgFunda).first,
        );
        expect(svgDompetKosong.pathAset, AsetIlustrasiFunda.belumAdaDompet);
        await bongkarWidget(tester);

        await tester.pumpWidget(bungkusUji(const LayarLainnya()));
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_sorotan_laporan')),
        );
        final semuaSvgLainnya = tester
            .widgetList<IlustrasiSvgFunda>(find.byType(IlustrasiSvgFunda))
            .map((w) => w.pathAset)
            .toList();
        expect(semuaSvgLainnya, contains(AsetIlustrasiFunda.laporanBulanan));
        expect(semuaSvgLainnya, contains(AsetIlustrasiFunda.modeSandbox));
        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '3. LayarBelajar menampilkan SVG di hero & daftar modul dengan jarak lega ke tombol Buka Modul Ini',
      (tester) async {
        await db
            .into(db.tabelProfilKeuangan)
            .insert(
              TabelProfilKeuanganCompanion.insert(
                id: const drift.Value(1),
                punyaPenghasilan: 'rutin',
                punyaUtang: 'tidak',
                danaDarurat: 'belum',
                menabung: 'rutin',
                investasi: 'belum',
                mencatatKeuangan: 'rutin',
                diisiPada: DateTime.now(),
                diperbaruiPada: DateTime.now(),
              ),
            );

        const modulContoh = ModulKonten(
          id: 'anggaran_arus_kas',
          judul: 'Anggaran dan Arus Kas',
          tingkat: 'pemula',
          urutan: 1,
          deskripsiSingkat: 'Kelola arus kas bulananmu dengan terukur.',
          tersedia: true,
          gerbang: [],
          daftarPelajaran: [],
          kuis: KuisKonten(jumlahSoal: 5, bankSoal: []),
        );
        const statusTersedia = HasilStatusBelajar(
          status: StatusBelajar.sedang,
          apaYangKurang: [],
        );
        final peta = [
          const ItemPetaModul(
            modul: modulContoh,
            daftarPelajaran: [],
            statusModul: statusTersedia,
          ),
        ];
        const rekList = [
          InfoRekomendasiModul(
            modul: modulContoh,
            statusModul: statusTersedia,
            judulAlasan: 'Rekomendasi Utama',
            deskripsiAlasan: 'Mulai tata arus kas bulananmu dengan rapi.',
          ),
        ];

        await tester.pumpWidget(
          bungkusUji(
            const LayarBelajar(),
            overridesTambahan: [
              penyediaPetaBelajar.overrideWith((ref) => Future.value(peta)),
              penyediaDaftarRekomendasiModul.overrideWith(
                (ref) => Future.value(rekList),
              ),
            ],
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_sorotan_rekomendasi')),
        );

        final daftarSvg = tester
            .widgetList<IlustrasiSvgFunda>(find.byType(IlustrasiSvgFunda))
            .toList();
        expect(daftarSvg.length, greaterThanOrEqualTo(2));
        expect(
          daftarSvg.first.pathAset,
          equals(AsetIlustrasiFunda.anggaranArusKas),
        );

        // Pastikan tombol Buka Modul Ini berjarak bersih dari kanvas ilustrasi atas
        final tombol = find.widgetWithText(TombolFunda, 'Buka Modul Ini');
        expect(tombol, findsOneWidget);
        final svgHeroTopBottom = tester.getBottomLeft(
          find.byType(IlustrasiSvgFunda).first,
        );
        final tombolTop = tester.getTopLeft(tombol);
        expect(tombolTop.dy - svgHeroTopBottom.dy, greaterThanOrEqualTo(16));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '4. LapisanTutorialBeranda 4/4 & LayarOnboarding Nilai Dasar memakai style editorial dan aman skala teks 2.0',
      (tester) async {
        // Uji LapisanTutorialBeranda skala normal
        await tester.pumpWidget(
          bungkusUji(
            Scaffold(
              body: Stack(
                children: [
                  LapisanTutorialBeranda(
                    daftarLangkah: const [
                      ItemSorotanTutorial(
                        judul: 'Ringkasan Keuangan',
                        deskripsi: 'Pantau arus kas & total saldo.',
                        ikon: LucideIcons.wallet,
                        pathSvg: AsetIlustrasiFunda.dompet,
                        warnaAksen: WarnaFunda.utama,
                        warnaLatarIkon: WarnaFunda.kanvasMint,
                      ),
                    ],
                    padaSelesai: () {},
                    padaLewati: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(IlustrasiSvgFunda), findsOneWidget);
        final tombolTutorial = tester.widget<TombolFunda>(
          find.byKey(const Key('tombol_lanjut_tutorial')),
        );
        expect(tombolTutorial.varian, equals(VarianTombolFunda.pilGelap));
        await bongkarWidget(tester);

        // Uji LayarOnboarding pada skala normal & 2.0 di 360x640
        await tester.pumpWidget(bungkusUji(const LayarOnboarding()));
        await tester.pump();
        expect(find.byType(IlustrasiSvgFunda), findsOneWidget);
        final tombolOnboarding = tester.widget<TombolFunda>(
          find.byKey(const Key('tombol_aksi_onboarding')),
        );
        expect(tombolOnboarding.varian, equals(VarianTombolFunda.pilGelap));
        await bongkarWidget(tester);

        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());
        await tester.pumpWidget(
          bungkusUji(
            const LayarOnboarding(),
            skalaTeks: 2.0,
            ukuran: const Size(360, 640),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(aktifkanFiturDebugUi, isFalse);
        await bongkarWidget(tester);
      },
    );
  });
}
