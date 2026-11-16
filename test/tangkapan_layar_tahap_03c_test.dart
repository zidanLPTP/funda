import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/frekuensi_tagihan.dart';
import 'package:funda/data/model/jenis_tagihan.dart';
import 'package:funda/data/penyedia_basis_data.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/kategori/kontroler/penyedia_kategori.dart';
import 'package:funda/fitur/pengaturan/kontroler/penyedia_pengaturan.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/fitur/tagihan/kontroler/penyedia_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_form_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_jadwal_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_semua_tagihan.dart';
import 'package:funda/fitur/transaksi/kontroler/penyedia_transaksi.dart';
import 'package:funda/fitur/transaksi/tampilan/layar_form_transaksi.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/fitur/utang/kontroler/penyedia_utang.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:funda/perhitungan/perhitungan_tagihan.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

class LayananPengingatUji implements LayananPengingat {
  @override
  Future<void> inisialisasi({
    void Function(String? rute)? padaKetukNotifikasi,
  }) async {}
  @override
  Future<bool> mintaIzin() async => true;
  @override
  Future<bool> cekStatusIzin() async => true;
  @override
  Future<void> jadwalkanPengingat(RencanaPengingat rencana) async {}
  @override
  Future<void> batalkanSemuaPengingat() async {}
  @override
  Future<void> jadwalkanDaftarRencana(
    List<RencanaPengingat> daftarRencana,
  ) async {}
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Ambil Tangkapan Layar Fitur Tahap 3C', () {
    late BasisDataFunda basisData;
    late LayananPengingatUji layananPengingat;

    setUp(() {
      basisData = BasisDataFunda(NativeDatabase.memory());
      layananPengingat = LayananPengingatUji();
    });

    tearDown(() async {
      await basisData.close();
    });

    Future<void> simpanTangkapanLayar(
      WidgetTester tester,
      String namaBerkas,
    ) async {
      final boundary =
          tester.renderObject(find.byKey(const Key('area_tangkapan_layar')))
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final folder = Directory('docs/tangkapan_layar/tahap_03c');
        if (!folder.existsSync()) {
          folder.createSync(recursive: true);
        }
        final file = File('docs/tangkapan_layar/tahap_03c/$namaBerkas');
        await file.writeAsBytes(bytes);
      });
    }

    final entitasKategoriListrik = EntitasKategori(
      id: 'kat_listrik',
      nama: 'Listrik PLN',
      arus: 'keluar',
      sifat: 'kebutuhan',
      ikon: 'zap',
      bawaan: true,
      diarsipkan: false,
    );

    final entitasKategoriInternet = EntitasKategori(
      id: 'kat_internet',
      nama: 'Internet & WiFi',
      arus: 'keluar',
      sifat: 'kebutuhan',
      ikon: 'wifi',
      bawaan: true,
      diarsipkan: false,
    );

    final entitasDompetKas = EntitasDompet(
      id: 'dompet_kas',
      nama: 'BCA Utama',
      jenis: 'rekening_bank',
      ikon: 'landmark',
      warna: 'tintBiru',
      saldoAwalRupiah: 12500000,
      urutan: 0,
      diarsipkan: false,
      dibuatPada: DateTime.now(),
    );

    final daftarTagihanContoh = [
      EntitasTagihan(
        id: 'tag_1',
        nama: 'Listrik PLN Pascabayar',
        jenis: JenisTagihan.tagihan.kode,
        jumlahPerkiraanRupiah: 450000,
        kategoriId: 'kat_listrik',
        dompetId: 'dompet_kas',
        frekuensi: FrekuensiTagihan.bulanan.kode,
        jatuhTempoPertama: DateTime(2026, 11, 20),
        berakhirPada: null,
        pengingatHariSebelum: '[0, 1, 3]',
        aktif: true,
        diarsipkan: false,
        dibuatPada: DateTime(2026, 11, 1),
      ),
      EntitasTagihan(
        id: 'tag_2',
        nama: 'IndiHome 50 Mbps',
        jenis: JenisTagihan.langganan.kode,
        jumlahPerkiraanRupiah: 385000,
        kategoriId: 'kat_internet',
        dompetId: 'dompet_kas',
        frekuensi: FrekuensiTagihan.bulanan.kode,
        jatuhTempoPertama: DateTime(2026, 11, 25),
        berakhirPada: null,
        pengingatHariSebelum: '[0, 1, 7]',
        aktif: true,
        diarsipkan: false,
        dibuatPada: DateTime(2026, 11, 1),
      ),
    ];

    final daftarJadwalContoh = [
      ItemJadwalTampilan(
        idTagihan: 'tag_1',
        nama: 'Listrik PLN Pascabayar',
        tanggalJatuhTempo: DateTime(2026, 11, 15),
        jumlahPerkiraanRupiah: 450000,
        kategoriId: 'kat_listrik',
        dompetBawaanId: 'dompet_kas',
        status: StatusKemunculan.hariIni,
        selisihHari: 0,
      ),
      ItemJadwalTampilan(
        idTagihan: 'tag_2',
        nama: 'IndiHome 50 Mbps',
        tanggalJatuhTempo: DateTime(2026, 11, 25),
        jumlahPerkiraanRupiah: 385000,
        kategoriId: 'kat_internet',
        dompetBawaanId: 'dompet_kas',
        status: StatusKemunculan.akanDatang,
        selisihHari: 10,
      ),
    ];

    Widget bungkusLayar(Widget layar) {
      return ProviderScope(
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          penyediaLayananPengingat.overrideWithValue(layananPengingat),
          penyediaDaftarKategori.overrideWith(
            (ref) =>
                Stream.value([entitasKategoriListrik, entitasKategoriInternet]),
          ),
          penyediaDaftarDompetAktif.overrideWith(
            (ref) => Stream.value([entitasDompetKas]),
          ),
          penyediaDaftarTagihan.overrideWith(
            (ref) => Stream.value(daftarTagihanContoh),
          ),
          penyediaJadwalBulanTerpilih.overrideWith(
            (ref) => Future.value(daftarJadwalContoh),
          ),
          penyediaTagihanTerdekatBeranda.overrideWith(
            (ref) => Future.value(daftarJadwalContoh.first),
          ),
          penyediaRingkasanBulanTerpilih.overrideWithValue(
            const RingkasanBulanTagihan(
              totalPerkiraanRupiah: 835000,
              sudahDibayarRupiah: 0,
              sisaPerkiraanRupiah: 835000,
              jumlahBelumDitandai: 2,
              jumlahTanpaNominal: 0,
            ),
          ),
          penyediaTotalSaldoAktif.overrideWith((ref) => 12500000),
          penyediaSisaAnggaranBulanIni.overrideWith(
            (ref) => Future.value(3500000),
          ),
          penyediaDaftarTujuanAktif.overrideWith((ref) => Stream.value([])),
          penyediaLimaTransaksiTerakhir.overrideWith((ref) => Stream.value([])),
          penyediaDaftarTransaksi.overrideWith((ref) => Stream.value([])),
          penyediaTotalSisaUtangAktif.overrideWith((ref) => Stream.value(0)),
          penyediaDaftarUtangAktif.overrideWith((ref) => Stream.value([])),
          penyediaPetaSaldoDompet.overrideWith(
            (ref) => {'dompet_kas': 12500000},
          ),
          penyediaPengingatAktif.overrideWith(
            () => PengaturanPengingatAktifNotifier(),
          ),
          penyediaLanjutBelajarBeranda.overrideWith(
            (ref) => Future.value(
              const InfoLanjutBelajar(
                labelAksi: 'Mulai',
                judul: 'Memetakan Arus Kas',
                keterangan: 'Pelajaran siap dipelajari sekarang.',
                rute: '/belajar/pelajaran/anggaran_arus_kas/anggaran_arus_kas_1_2',
                bisaDibuka: true,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: TemaFunda.temaTerang,
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('area_tangkapan_layar'),
              child: SizedBox(width: 390, height: 844, child: layar),
            ),
          ),
        ),
      );
    }

    testWidgets('1. Tangkapan Layar Jadwal Tagihan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(bungkusLayar(const LayarJadwalTagihan()));
      await tester.pumpAndSettle();

      await simpanTangkapanLayar(tester, 'layar_jadwal_tagihan.png');
    });

    testWidgets('2. Tangkapan Layar Semua Tagihan (Master)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(bungkusLayar(const LayarSemuaTagihan()));
      await tester.pumpAndSettle();

      await simpanTangkapanLayar(tester, 'layar_semua_tagihan.png');
    });

    testWidgets('3. Tangkapan Layar Form Tagihan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(bungkusLayar(const LayarFormTagihan()));
      await tester.pumpAndSettle();

      await simpanTangkapanLayar(tester, 'layar_form_tagihan.png');
    });

    testWidgets('4. Tangkapan Layar Pengaturan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(bungkusLayar(const LayarPengaturan()));
      await tester.pumpAndSettle();

      await simpanTangkapanLayar(tester, 'layar_pengaturan.png');
    });

    testWidgets('5. Tangkapan Layar Beranda Petak Tagihan Terdekat', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(bungkusLayar(const LayarBeranda()));
      await tester.pumpAndSettle();

      await simpanTangkapanLayar(tester, 'layar_beranda_petak_tagihan.png');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets(
      '6. Tangkapan Layar Form Transaksi Prefill Pembayaran Tagihan',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          bungkusLayar(
            LayarFormTransaksi(
              idTagihan: 'tag_1',
              tanggalJatuhTempoTagihan: DateTime(2026, 11, 15),
              nominalAwalRupiah: 450000,
              kategoriIdAwal: 'kat_listrik',
              dompetIdAwal: 'dompet_kas',
              catatanAwal: 'Pembayaran Listrik PLN Pascabayar',
            ),
          ),
        );
        await tester.pumpAndSettle();

        await simpanTangkapanLayar(
          tester,
          'layar_form_transaksi_bayar_tagihan.png',
        );
      },
    );
  });
}
