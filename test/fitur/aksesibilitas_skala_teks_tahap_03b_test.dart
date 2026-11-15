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
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/catatan/tampilan/layar_catatan.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/dompet/tampilan/layar_daftar_dompet.dart';
import 'package:funda/fitur/kantong/tampilan/layar_daftar_kantong.dart';
import 'package:funda/fitur/kategori/tampilan/layar_daftar_kategori.dart';
import 'package:funda/fitur/kekayaan_bersih/tampilan/layar_kekayaan_bersih.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_detail_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_form_tujuan.dart';
import 'package:funda/fitur/utang/tampilan/layar_daftar_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_detail_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_form_utang.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;
  late TujuanRepositori repoTujuan;
  late UtangRepositori repoUtang;
  late String utangId;
  late String tujuanId;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
    repoTujuan = TujuanRepositori(basisData);
    repoUtang = UtangRepositori(basisData);

    await repoDompet.buatDompet(
      nama: 'BCA Utama',
      jenis: JenisDompet.rekeningBank.kode,
      ikon: 'building2',
      warna: 'tintBiru',
      saldoAwalRupiah: 10000000,
    );

    utangId = await repoUtang.buatUtang(
      nama: 'KPR Rumah Tipe 36',
      jenis: 'kpr',
      pemberi: 'Bank Mandiri',
      sisaAwalRupiah: 240000000,
      pokokAwalRupiah: 300000000,
      jenisBunga: 'anuitas',
      bungaBasisPoinPerTahun: 750,
      tenorBulan: 120,
      cicilanBulananRupiah: 3500000,
      tanggalJatuhTempoBulanan: 10,
    );

    tujuanId = await repoTujuan.buatTujuan(
      nama: 'Dana Liburan',
      jenis: JenisTujuan.tabungan.kode,
      targetRupiah: 15000000,
      ikon: 'palmtree',
      warna: 'tintHijau',
    );
  });

  tearDown(() async {
    await basisData.close();
  });

  Widget bungkusAplikasiUji(Widget layar, {double skalaTeks = 2.0}) {
    return ProviderScope(
      overrides: [
        penyediaBasisData.overrideWithValue(basisData),
        penyediaSisaAnggaranBulanIni.overrideWith(
          (ref) => Future.value(1500000),
        ),
        penyediaRealisasiAnggaranBulan.overrideWith((ref) => Future.value([])),
        penyediaTotalSaldoAktif.overrideWith((ref) => 10000000),
      ],
      child: MaterialApp(
        theme: TemaFunda.temaTerang,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(skalaTeks),
          ),
          child: layar,
        ),
      ),
    );
  }

  group('Uji Aksesibilitas Skala Teks 2.0 Tanpa Overflow', () {
    testWidgets('1. Layar Form Catat Transaksi bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarFormTransaksi()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('2. Layar Catatan Riwayat Transaksi bebas overflow', (
      tester,
    ) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarCatatan()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('3. Layar Daftar Dompet bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarDaftarDompet()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('4. Layar Daftar Kategori bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarDaftarKategori()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('5. Layar Form Tujuan bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarFormTujuan()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('6. Layar Detail Tujuan bebas overflow', (tester) async {
      await tester.pumpWidget(
        bungkusAplikasiUji(LayarDetailTujuan(tujuanId: tujuanId)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('7. Layar Daftar Kantong bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarDaftarKantong()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('8. Layar Daftar Utang bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarDaftarUtang()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('9. Layar Form Utang bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarFormUtang()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('10. Layar Detail Utang bebas overflow', (tester) async {
      await tester.pumpWidget(
        bungkusAplikasiUji(LayarDetailUtang(utangId: utangId)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('11. Layar Kekayaan Bersih bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarKekayaanBersih()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('12. Layar Beranda Penuh bebas overflow', (tester) async {
      await tester.pumpWidget(bungkusAplikasiUji(const LayarBeranda()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
