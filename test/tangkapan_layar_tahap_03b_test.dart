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
import 'package:funda/data/repositori/kategori_repositori.dart';
import 'package:funda/data/repositori/tujuan_repositori.dart';
import 'package:funda/data/repositori/utang_repositori.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/kekayaan_bersih/tampilan/layar_kekayaan_bersih.dart';
import 'package:funda/fitur/lainnya/tampilan/layar_lainnya.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/fitur/utang/kontroler/penyedia_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_daftar_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_detail_utang.dart';
import 'package:funda/fitur/utang/tampilan/layar_form_utang.dart';
import 'package:funda/perhitungan/perhitungan_utang_dashboard.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late BasisDataFunda basisData;
  late DompetRepositori repoDompet;
  late KategoriRepositori repoKategori;
  late TujuanRepositori repoTujuan;
  late UtangRepositori repoUtang;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    basisData = BasisDataFunda(NativeDatabase.memory());
    repoDompet = DompetRepositori(basisData);
    repoKategori = KategoriRepositori(basisData);
    repoTujuan = TujuanRepositori(basisData);
    repoUtang = UtangRepositori(basisData);
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

  testWidgets('Ambil Tangkapan Layar Seluruh Layar Utama Tahap 03B', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Siapkan Dompet
    final dompetBCAId = await repoDompet.buatDompet(
      nama: 'BCA Utama',
      jenis: JenisDompet.rekeningBank.kode,
      ikon: 'landmark',
      warna: 'tintBiru',
      saldoAwalRupiah: 15000000,
    );

    await repoDompet.buatDompet(
      nama: 'GoPay',
      jenis: JenisDompet.eWallet.kode,
      ikon: 'wallet',
      warna: 'tintHijau',
      saldoAwalRupiah: 750000,
    );

    // Siapkan Kategori
    await repoKategori.tambahKategoriKustom(
      TabelKategoriCompanion.insert(
        id: 'kat_cicilan',
        nama: 'Cicilan',
        arus: 'keluar',
        sifat: 'utang',
        ikon: 'creditCard',
      ),
    );

    // Siapkan Tujuan
    await repoTujuan.buatTujuan(
      nama: 'Dana Darurat 6 Bulan',
      jenis: JenisTujuan.danaDarurat.kode,
      targetRupiah: 30000000,
      tenggat: DateTime(2027, 12, 31),
      ikon: 'shield',
      warna: 'tintAmber',
    );

    await repoTujuan.buatTujuan(
      nama: 'Liburan ke Jepang',
      jenis: JenisTujuan.tabungan.kode,
      targetRupiah: 25000000,
      tenggat: DateTime(2026, 12, 1),
      ikon: 'palmtree',
      warna: 'tintHijau',
    );

    // Siapkan Utang Aktif
    await repoUtang.buatUtang(
      nama: 'KPR BTN Subsidi',
      jenis: 'kpr',
      pemberi: 'Bank BTN',
      sisaAwalRupiah: 140000000,
      pokokAwalRupiah: 150000000,
      jenisBunga: 'anuitas',
      bungaBasisPoinPerTahun: 500,
      tenorBulan: 180,
      cicilanBulananRupiah: 1200000,
      tanggalJatuhTempoBulanan: 10,
    );

    final utangMotorId = await repoUtang.buatUtang(
      nama: 'Cicilan Motor Beat',
      jenis: 'cicilan',
      pemberi: 'FIF Group',
      sisaAwalRupiah: 8000000,
      pokokAwalRupiah: 18000000,
      jenisBunga: 'flat',
      bungaBasisPoinPerTahun: 1200,
      tenorBulan: 24,
      cicilanBulananRupiah: 950000,
      tanggalJatuhTempoBulanan: 15,
    );

    // Siapkan Utang Lunas
    final utangPaylaterId = await repoUtang.buatUtang(
      nama: 'Shopee Paylater Sepatu',
      jenis: 'paylater',
      pemberi: 'Shopee',
      sisaAwalRupiah: 450000,
      jenisBunga: 'tanpa_bunga',
    );
    await repoUtang.catatPembayaranUtang(
      utangId: utangPaylaterId,
      dompetId: dompetBCAId,
      jumlahRupiah: 450000,
      waktu: DateTime.now(),
      kategoriId: 'kat_cicilan',
      catatan: 'Pelunasan lunas sepatu kerja',
    );

    Widget bungkus(
      Widget child, {
      int saldoAktif = 15750000,
      int? kekayaanBersihCustom,
    }) {
      return ProviderScope(
        key: UniqueKey(),
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          penyediaSisaAnggaranBulanIni.overrideWith(
            (ref) => Future.value(2450000),
          ),
          penyediaTotalSaldoAktif.overrideWith((ref) => saldoAktif),
          penyediaPemasukanBulananRataRata.overrideWithValue(
            const HasilPemasukanRataRata(
              nilaiRupiah: 7500000,
              dasar: DasarPemasukanRataRata.rataRata3Bulan,
            ),
          ),
          if (kekayaanBersihCustom != null)
            penyediaKekayaanBersih.overrideWithValue(kekayaanBersihCustom),
        ],
        child: MaterialApp(
          theme: TemaFunda.temaTerang,
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('area_tangkapan_layar'),
              child: child,
            ),
          ),
        ),
      );
    }

    // 1. Tangkapan Layar: Beranda Penuh
    await tester.pumpWidget(bungkus(const LayarBeranda()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '01_beranda_penuh.png');

    // 2. Tangkapan Layar: Layar Daftar Utang
    await tester.pumpWidget(bungkus(const LayarDaftarUtang()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '02_daftar_utang.png');

    // 3. Tangkapan Layar: Form Tambah Utang
    await tester.pumpWidget(bungkus(const LayarFormUtang()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '03_form_catat_utang.png');

    // 4. Tangkapan Layar: Detail Utang Aktif
    await tester.pumpWidget(bungkus(LayarDetailUtang(utangId: utangMotorId)));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '04_detail_utang_aktif.png');

    // 5. Tangkapan Layar: Detail Utang Lunas (Pesan hangat tanpa gamifikasi)
    await tester.pumpWidget(
      bungkus(LayarDetailUtang(utangId: utangPaylaterId)),
    );
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '05_detail_utang_lunas.png');

    // 6. Tangkapan Layar: Kekayaan Bersih (Kondisi Utang > Saldo dengan Nada Menguatkan)
    await tester.pumpWidget(bungkus(const LayarKekayaanBersih()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '06_kekayaan_bersih_menguatkan.png');

    // 7. Tangkapan Layar: Kekayaan Bersih Positif
    await tester.pumpWidget(
      bungkus(
        const LayarKekayaanBersih(),
        saldoAktif: 273000000,
        kekayaanBersihCustom: 125000000,
      ),
    );
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '07_kekayaan_bersih_positif.png');

    // 8. Tangkapan Layar: Form Transaksi Hubungkan ke Utang
    await tester.pumpWidget(bungkus(const LayarFormTransaksi()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '08_form_transaksi_taut_utang.png');

    // 9. Tangkapan Layar: Layar Lainnya (Menu Utang & Kekayaan Bersih)
    await tester.pumpWidget(bungkus(const LayarLainnya()));
    await tester.pumpAndSettle();
    await simpanTangkapanLayar(tester, '09_menu_lainnya_utang.png');
  });
}
