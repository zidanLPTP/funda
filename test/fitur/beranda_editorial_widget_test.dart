@Timeout(Duration(seconds: 30))
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/cadangan/kontroler/penyedia_cadangan.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/fitur/utang/kontroler/penyedia_utang.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/perhitungan/perhitungan_keuangan.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  group('Redesain Editorial LayarBeranda', () {
    testWidgets(
      '1. Hero memuat Arus Kas, Total Saldo, Kekayaan Bersih, tombol Catat Transaksi pil gelap, 4 metrik putih, Split Card Lanjut Belajar, & banner cadangan di bawah',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final dompet = EntitasDompet(
          id: 'dmp_1',
          nama: 'Dompet Utama',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'tintHijau',
          saldoAwalRupiah: 3000000,
          urutan: 0,
          diarsipkan: false,
          dibuatPada: DateTime.now(),
        );

        const statusCadanganPerlu = StatusFiturCadangan(
          terakhirDicadangkan: null,
          adaCadanganKeselamatan: false,
          jumlahTransaksi: 12,
          hariSejakDataPertama: 15,
          ditundaSampai: null,
          perluPengingat: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value([dompet]),
              ),
              penyediaTotalSaldoAktif.overrideWithValue(3000000),
              penyediaKekayaanBersih.overrideWithValue(2500000),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(
                  totalMasuk: 5000000,
                  totalKeluar: 2000000,
                  selisih: 3000000,
                ),
              ),
              penyediaSisaAnggaranBulanIni.overrideWith(
                (ref) => Future.value(1200000),
              ),
              penyediaLanjutBelajarBeranda.overrideWith(
                (ref) => Future.value(
                  const InfoLanjutBelajar(
                    labelAksi: 'Lanjut',
                    judul: 'Memetakan Arus Kas',
                    keterangan: 'Modul 1 • 4 menit',
                    rute:
                        '/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_2',
                    bisaDibuka: true,
                  ),
                ),
              ),
              penyediaStatusCadangan.overrideWith((ref) => statusCadanganPerlu),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarBeranda(),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_lanjut_belajar_beranda')),
        );
        await tester.pump();

        // Hero atas: Arus Kas + Total Saldo + Kekayaan Bersih + tombol pil gelap Catat Transaksi
        expect(find.text('Arus Kas Bulan Ini'), findsOneWidget);
        expect(find.byKey(const Key('hero_total_saldo')), findsOneWidget);
        expect(find.byKey(const Key('hero_kekayaan_bersih')), findsOneWidget);
        expect(
          find.byKey(const Key('tombol_catat_transaksi_beranda')),
          findsOneWidget,
        );

        // Hanya tepat 1 tombol pil gelap di Beranda (Catat Transaksi), Lanjut Belajar pakai link teks
        expect(
          find.byWidgetPredicate(
            (w) => w is TombolFunda && w.varian == VarianTombolFunda.pilGelap,
          ),
          findsOneWidget,
        );

        // 4 kartu metrik putih 2x2
        expect(find.byKey(const Key('kartu_metrik_anggaran')), findsOneWidget);
        expect(
          find.byKey(const Key('kartu_metrik_dana_darurat')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('kartu_metrik_rasio_cicilan')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('kartu_metrik_tujuan')), findsOneWidget);

        // Split card Lanjut Belajar & Banner Cadangan berada di bawah Hero & Metrik
        expect(
          find.byKey(const Key('kartu_lanjut_belajar_beranda')),
          findsOneWidget,
        );
        final posisiHeroY = tester
            .getTopLeft(find.byKey(const Key('tombol_catat_transaksi_beranda')))
            .dy;
        final posisiCadanganY = tester
            .getTopLeft(
              find.byKey(const Key('banner_pengingat_cadangan_beranda')),
            )
            .dy;
        final posisiTransaksiY = tester
            .getTopLeft(find.text('5 Transaksi Terakhir'))
            .dy;
        expect(posisiCadanganY, greaterThan(posisiHeroY));
        expect(posisiTransaksiY, greaterThan(posisiCadanganY));

        await bongkarWidget(tester);
      },
    );

    testWidgets(
      '2. Ketuk tombol Catat Transaksi membuka LayarFormTransaksi tanpa error',
      (tester) async {
        final dompet = EntitasDompet(
          id: 'dmp_1',
          nama: 'Dompet Utama',
          jenis: 'tunai',
          ikon: 'wallet',
          warna: 'tintHijau',
          saldoAwalRupiah: 1000000,
          urutan: 0,
          diarsipkan: false,
          dibuatPada: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaBasisData.overrideWithValue(db),
              penyediaTanpaAnimasi.overrideWithValue(true),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value([dompet]),
              ),
              penyediaTotalSaldoAktif.overrideWithValue(1000000),
              penyediaArusKasBulanIni.overrideWithValue(
                const HasilArusKas(totalMasuk: 0, totalKeluar: 0, selisih: 0),
              ),
              penyediaSisaAnggaranBulanIni.overrideWith(
                (ref) => Future.value(0),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarBeranda(),
            ),
          ),
        );
        await pompaHinggaAda(
          tester,
          find.byKey(const Key('kartu_lanjut_belajar_beranda')),
        );
        await tester.pump();

        await tester.tap(
          find.byKey(const Key('tombol_catat_transaksi_beranda')),
        );
        await pompaHinggaAda(tester, find.byType(LayarFormTransaksi));
        expect(find.byType(LayarFormTransaksi), findsOneWidget);

        expect(tester.takeException(), isNull);
        await bongkarWidget(tester);
      },
    );
  });
}
