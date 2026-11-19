@Timeout(Duration(seconds: 30))
library;

import '../pembantu/pompa_uji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/model/frekuensi_tagihan.dart';
import 'package:funda/data/model/jenis_tagihan.dart';
import 'package:funda/data/repositori/tagihan_repositori.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/kategori/kontroler/penyedia_kategori.dart';
import 'package:funda/fitur/pengaturan/kontroler/penyedia_pengaturan.dart';
import 'package:funda/fitur/pengaturan/tampilan/layar_pengaturan.dart';
import 'package:funda/fitur/tagihan/kontroler/penyedia_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_form_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_jadwal_tagihan.dart';
import 'package:funda/fitur/tagihan/tampilan/layar_semua_tagihan.dart';
import 'package:funda/perhitungan/perhitungan_tagihan.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Aksesibilitas Skala Teks 2.0 Seluruh Layar Baru Tahap 3C', () {
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

    Widget bungkusSkala2(Widget layar) {
      return ProviderScope(
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
          penyediaJadwalBulanTerpilih.overrideWith(
            (ref) => Future.value([itemJadwalContoh]),
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
          penyediaPengingatAktif.overrideWith(
            () => PengaturanPengingatAktifNotifier(),
          ),
        ],
        child: MaterialApp(
          theme: TemaFunda.temaTerang,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2.0),
            ),
            child: layar,
          ),
        ),
      );
    }

    testWidgets('Layar Form Tagihan bebas overflow pada skala teks 2.0', (
      tester,
    ) async {
      await tester.pumpWidget(bungkusSkala2(const LayarFormTagihan()));
      await pompaAman(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Jenis Tagihan'), findsOneWidget);
    });

    testWidgets('Layar Semua Tagihan bebas overflow pada skala teks 2.0', (
      tester,
    ) async {
      await tester.pumpWidget(bungkusSkala2(const LayarSemuaTagihan()));
      await pompaAman(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Listrik PLN Pascabayar'), findsOneWidget);
    });

    testWidgets('Layar Jadwal Tagihan bebas overflow pada skala teks 2.0', (
      tester,
    ) async {
      await tester.pumpWidget(bungkusSkala2(const LayarJadwalTagihan()));
      await pompaAman(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Listrik PLN Pascabayar'), findsOneWidget);
    });

    testWidgets('Layar Pengaturan bebas overflow pada skala teks 2.0', (
      tester,
    ) async {
      await tester.pumpWidget(bungkusSkala2(const LayarPengaturan()));
      await pompaAman(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Nyalakan Pengingat Lokal'), findsOneWidget);
    });
  });
}
