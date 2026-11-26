@Timeout(Duration(seconds: 30))
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/jenis_tagihan.dart';
import 'package:funda/data/model/frekuensi_tagihan.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/kategori/kontroler/penyedia_kategori.dart';
import 'package:funda/fitur/pengaturan/kontroler/penyedia_pengaturan.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/fitur/tagihan/kontroler/penyedia_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_form_tagihan.dart';
import 'package:funda/komponen/komponen_funda.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_jadwal_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_semua_tagihan.dart';
import 'package:funda/layanan/pengingat/layanan_pengingat.dart';
import 'package:funda/layanan/pengingat/penyedia_layanan_pengingat.dart';
import 'package:funda/perhitungan/perhitungan_tagihan.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

class LayananPengingatUji implements LayananPengingat {
  bool izinDiberikan = true;
  final List<RencanaPengingat> rencanaTersimpan = [];

  @override
  Future<void> inisialisasi({
    void Function(String? rute)? padaKetukNotifikasi,
  }) async {}

  @override
  Future<bool> mintaIzin() async => izinDiberikan;

  @override
  Future<bool> cekStatusIzin() async => izinDiberikan;

  @override
  Future<void> jadwalkanPengingat(RencanaPengingat rencana) async {
    rencanaTersimpan.add(rencana);
  }

  @override
  Future<void> batalkanSemuaPengingat() async {
    rencanaTersimpan.clear();
  }

  @override
  Future<void> jadwalkanDaftarRencana(
    List<RencanaPengingat> daftarRencana,
  ) async {
    rencanaTersimpan
      ..clear()
      ..addAll(daftarRencana);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Pengujian Widget Fitur Tagihan & Pengaturan (Tahap 3C)', () {
    late LayananPengingatUji layananPengingat;

    setUp(() {
      layananPengingat = LayananPengingatUji();
    });

    final entitasKategoriContoh = EntitasKategori(
      id: 'kat_listrik',
      nama: 'Listrik & Utilitas',
      arus: 'keluar',
      sifat: 'kebutuhan',
      ikon: 'zap',
      bawaan: true,
      diarsipkan: false,
    );

    final entitasDompetContoh = EntitasDompet(
      id: 'dompet_kas',
      nama: 'Kas Utama',
      jenis: 'tunai',
      ikon: 'cash',
      warna: 'tintHijau',
      saldoAwalRupiah: 5000000,
      urutan: 0,
      diarsipkan: false,
      dibuatPada: DateTime.now(),
    );

    final entitasTagihanContoh = EntitasTagihan(
      id: 'tag_pln',
      nama: 'Listrik PLN Pascabayar',
      jenis: JenisTagihan.tagihan.kode,
      jumlahPerkiraanRupiah: 250000,
      kategoriId: 'kat_listrik',
      dompetId: 'dompet_kas',
      frekuensi: FrekuensiTagihan.bulanan.kode,
      jatuhTempoPertama: DateTime(2026, 11, 20),
      berakhirPada: null,
      pengingatHariSebelum: '[0, 1, 3]',
      aktif: true,
      diarsipkan: false,
      dibuatPada: DateTime(2026, 11, 1),
    );

    final itemJadwalContoh = ItemJadwalTampilan(
      idTagihan: 'tag_pln',
      nama: 'Listrik PLN Pascabayar',
      tanggalJatuhTempo: DateTime(2026, 11, 20),
      jumlahPerkiraanRupiah: 250000,
      kategoriId: 'kat_listrik',
      dompetBawaanId: 'dompet_kas',
      status: StatusKemunculan.hariIni,
      selisihHari: 0,
    );

    testWidgets(
      'Layar Form Tagihan memvalidasi input wajib dan menampilkan field secara benar',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaDaftarKategori.overrideWith(
                (ref) => Stream.value([entitasKategoriContoh]),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value([entitasDompetContoh]),
              ),
              penyediaLayananPengingat.overrideWithValue(layananPengingat),
              penyediaPengingatAktif.overrideWith(
                () => PengaturanPengingatAktifNotifier(),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarFormTagihan(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Nama Tagihan / Layanan *'), findsOneWidget);
        expect(find.text('Perkiraan Nominal (Opsional)'), findsOneWidget);
        expect(
          find.widgetWithText(TombolFunda, 'Tambah Tagihan'),
          findsOneWidget,
        );

        // Coba submit kosong
        await tester.tap(find.widgetWithText(TombolFunda, 'Tambah Tagihan'));
        await tester.pump();

        expect(find.text('Nama tagihan wajib diisi.'), findsOneWidget);
      },
    );

    testWidgets(
      'Layar Semua Tagihan menampilkan master tagihan dan opsi menu',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaDaftarTagihan.overrideWith(
                (ref) => Stream.value([entitasTagihanContoh]),
              ),
              penyediaDaftarKategori.overrideWith(
                (ref) => Stream.value([entitasKategoriContoh]),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value([entitasDompetContoh]),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarSemuaTagihan(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Listrik PLN Pascabayar'), findsOneWidget);
        expect(find.textContaining('Tagihan • Bulanan'), findsOneWidget);
        expect(find.text('Rp 250.000'), findsOneWidget);
      },
    );

    testWidgets(
      'Layar Jadwal Tagihan menampilkan ringkasan bulan dan daftar kartu jadwal',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaJadwalBulanTerpilih.overrideWith(
                (ref) => Future.value([itemJadwalContoh]),
              ),
              penyediaDaftarKategori.overrideWith(
                (ref) => Stream.value([entitasKategoriContoh]),
              ),
              penyediaDaftarDompetAktif.overrideWith(
                (ref) => Stream.value([entitasDompetContoh]),
              ),
              penyediaRingkasanBulanTerpilih.overrideWithValue(
                const RingkasanBulanTagihan(
                  totalPerkiraanRupiah: 250000,
                  sudahDibayarRupiah: 0,
                  sisaPerkiraanRupiah: 250000,
                  jumlahBelumDitandai: 1,
                  jumlahTanpaNominal: 0,
                ),
              ),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarJadwalTagihan(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Listrik PLN Pascabayar'), findsOneWidget);
        expect(find.text('Jatuh tempo hari ini'), findsOneWidget);
        expect(find.text('Bayar'), findsOneWidget);
        expect(find.byTooltip('Lewati periode ini'), findsOneWidget);
      },
    );

    testWidgets(
      'Layar Pengaturan memungkinkan mengubah saklar pengingat lokal',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              penyediaLayananPengingat.overrideWithValue(layananPengingat),
            ],
            child: MaterialApp(
              theme: TemaFunda.temaTerang,
              home: const LayarPengaturan(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Nyalakan Pengingat Lokal'), findsOneWidget);
        expect(find.text('Panduan & Profil Keuangan'), findsOneWidget);
      },
    );
  });
}
