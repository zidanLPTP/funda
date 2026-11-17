import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_dompet.dart';
import 'package:funda/data/model/jenis_tujuan.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/dompet_repositori.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/anggaran/tampilan/layar_anggaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/catatan/tampilan/layar_catatan.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/dompet/tampilan/layar_detail_dompet.dart';
import 'package:funda/fitur/kantong/kontroler/penyedia_kantong.dart';
import 'package:funda/fitur/kantong/tampilan/layar_daftar_kantong.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_daftar_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_detail_tujuan.dart';
import 'package:funda/fitur/tujuan/tampilan/layar_form_tujuan.dart';
import 'package:funda/perhitungan/perhitungan_anggaran_tujuan.dart';
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
  });

  tearDown(() async {
    await basisData.close();
  });

  Future<void> simpanTangkapanLayar(
    WidgetTester tester,
    String namaBerkas,
  ) async {
    final elemen = find.byKey(const Key('area_tangkapan_layar'));
    final RenderRepaintBoundary boundary =
        tester.renderObject(elemen) as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      expect(byteData, isNotNull);
    });
  }

  testWidgets('Ambil Tangkapan Layar Seluruh Layar Utama Tahap 03A', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dompetBCAId = await repoDompet.buatDompet(
      nama: 'BCA Utama',
      jenis: JenisDompet.rekeningBank.kode,
      ikon: 'landmark',
      warna: 'biru',
      saldoAwalRupiah: 15000000,
    );

    final dompetGopayId = await repoDompet.buatDompet(
      nama: 'GoPay Jajan',
      jenis: JenisDompet.eWallet.kode,
      ikon: 'wallet',
      warna: 'hijau',
      saldoAwalRupiah: 750000,
    );

    final now = DateTime.now();

    final contohTujuan1 = EntitasTujuan(
      id: 'tujuan-1',
      nama: 'Dana Darurat 6 Bulan',
      jenis: JenisTujuan.danaDarurat.kode,
      targetRupiah: 30000000,
      tenggat: DateTime(now.year + 1, 12, 31),
      ikon: 'shield',
      warna: 'emas',
      status: 'aktif',
      dibuatPada: now,
    );

    final contohTujuan2 = EntitasTujuan(
      id: 'tujuan-2',
      nama: 'Laptop Kerja Baru',
      jenis: JenisTujuan.tujuanBesar.kode,
      targetRupiah: 18000000,
      tenggat: DateTime(now.year, now.month + 6, 1),
      ikon: 'laptop',
      warna: 'biru',
      status: 'aktif',
      dibuatPada: now,
    );

    final List<EntitasTujuan> daftarContohTujuan = [
      contohTujuan1,
      contohTujuan2,
    ];

    final contohKantong1 = EntitasKantong(
      id: 'kantong-1',
      nama: 'Dana Darurat (BCA)',
      dompetId: dompetBCAId,
      tujuanId: 'tujuan-1',
      ikon: 'shield',
      warna: 'emas',
      diarsipkan: false,
      dibuatPada: now,
    );

    final contohKantong2 = EntitasKantong(
      id: 'kantong-2',
      nama: 'Budget Ngopi Mingguan',
      dompetId: dompetGopayId,
      tujuanId: null,
      ikon: 'coffee',
      warna: 'jingga',
      diarsipkan: false,
      dibuatPada: now,
    );

    final contohRealisasiAnggaran = [
      const ItemRealisasiAnggaran(
        anggaranId: 'ang-1',
        kategoriId: 'kat-1',
        namaKategori: 'Makan Harian',
        sifatKategori: 'kebutuhan',
        ikonKategori: 'utensils',
        batasRupiah: 2500000,
        terpakaiRupiah: 1450000,
      ),
      const ItemRealisasiAnggaran(
        anggaranId: 'ang-2',
        kategoriId: 'kat-2',
        namaKategori: 'Transportasi & Bensin',
        sifatKategori: 'kebutuhan',
        ikonKategori: 'fuel',
        batasRupiah: 800000,
        terpakaiRupiah: 680000,
      ),
      const ItemRealisasiAnggaran(
        anggaranId: 'ang-3',
        kategoriId: 'kat-3',
        namaKategori: 'Hiburan & Hobi',
        sifatKategori: 'keinginan',
        ikonKategori: 'gamepad-2',
        batasRupiah: 500000,
        terpakaiRupiah: 550000,
      ),
    ];

    Widget buatLayarUji(Widget layar) {
      return ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          penyediaDaftarTujuanAktif.overrideWith(
            (ref) => Stream.value(daftarContohTujuan),
          ),
          penyediaDaftarSemuaTujuan.overrideWith(
            (ref) => Stream.value(daftarContohTujuan),
          ),
          penyediaDanaTujuan.overrideWith((ref, id) {
            if (id == 'tujuan-1') return Stream.value(12000000);
            return Stream.value(6000000);
          }),
          penyediaKantongDompet.overrideWith((ref, dompetId) {
            if (dompetId == dompetBCAId) return Stream.value([contohKantong1]);
            return Stream.value([contohKantong2]);
          }),
          penyediaKantongTujuan.overrideWith((ref, tujuanId) {
            if (tujuanId == 'tujuan-1') return Stream.value([contohKantong1]);
            return Stream.value([]);
          }),
          penyediaSaldoKantong.overrideWith((ref, id) {
            if (id == 'kantong-1') return Stream.value(12000000);
            return Stream.value(250000);
          }),
          penyediaSaldoBebasDompet.overrideWith((ref, dompetId) {
            if (dompetId == dompetBCAId) return 3000000;
            return 500000;
          }),
          penyediaPetaSaldoDompet.overrideWith((ref) {
            return {dompetBCAId: 15000000, dompetGopayId: 750000};
          }),
          penyediaRiwayatAlokasiTujuan.overrideWith(
            (ref, id) => Stream.value([]),
          ),
          penyediaRiwayatAlokasiKantong.overrideWith(
            (ref, id) => Stream.value([]),
          ),
          penyediaRealisasiAnggaranBulan.overrideWith(
            (ref) => Future.value(contohRealisasiAnggaran),
          ),
        ],
        child: MaterialApp(
          theme: TemaFunda.temaTerang,
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('area_tangkapan_layar'),
              child: layar,
            ),
          ),
        ),
      );
    }

    // 1. Tangkap Layar Beranda
    await tester.pumpWidget(buatLayarUji(const LayarBeranda()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '01_beranda.png');

    // 2. Tangkap Layar Anggaran
    await tester.pumpWidget(buatLayarUji(const LayarAnggaran()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '02_anggaran.png');

    // 3. Tangkap Layar Daftar Tujuan
    await tester.pumpWidget(buatLayarUji(const LayarDaftarTujuan()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '03_daftar_tujuan.png');

    // 4. Tangkap Layar Detail Tujuan
    await tester.pumpWidget(
      buatLayarUji(LayarDetailTujuan(tujuanId: 'tujuan-1')),
    );
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '04_detail_tujuan.png');

    // 5. Tangkap Layar Form Tujuan
    await tester.pumpWidget(buatLayarUji(const LayarFormTujuan()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '05_form_tujuan.png');

    // 6. Tangkap Layar Daftar Kantong
    await tester.pumpWidget(buatLayarUji(const LayarDaftarKantong()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '06_daftar_kantong.png');

    // 7. Tangkap Layar Detail Dompet dengan Kantong
    await tester.pumpWidget(
      buatLayarUji(LayarDetailDompet(dompetId: dompetBCAId)),
    );
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '07_detail_dompet_kantong.png');

    // 8. Tangkap Layar Catatan
    await tester.pumpWidget(buatLayarUji(const LayarCatatan()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '08_catatan_riwayat.png');

    // 9. Tangkap Layar Lainnya
    await tester.pumpWidget(buatLayarUji(const LayarLainnya()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '09_lainnya.png');

    // Cleanup
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
