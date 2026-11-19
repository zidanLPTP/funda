@Timeout(Duration(seconds: 30))
library;

import '../pembantu/pompa_uji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/dompet/kontroler/penyedia_dompet.dart';
import 'package:funda/fitur/kategori/kontroler/penyedia_kategori.dart';
import 'package:funda/fitur/tagihan/kontroler/penyedia_tagihan.dart';
import 'package:funda/fitur/transaksi/kontroler/penyedia_transaksi.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/fitur/utang/kontroler/penyedia_utang.dart';
import 'package:funda/komponen/teks_funda.dart';
import 'package:funda/tema/tema.dart';

void main() {
  group(
    'Langkah 0(f): Verifikasi Skala Teks 2.0 Memperbesar Teks Secara Fisik (Bukan Menyusutkan)',
    () {
      testWidgets(
        'Tinggi render teks pada skala teks 2.0 lebih besar secara signifikan dibanding skala 1.0 di Layar Beranda',
        (tester) async {
          final skalaTeksNotifier = ValueNotifier<double>(1.0);

          final entitasDompetContoh = EntitasDompet(
            id: 'kas-1',
            nama: 'Kas Utama',
            jenis: 'tunai',
            ikon: 'cash',
            warna: 'tintHijau',
            saldoAwalRupiah: 5000000,
            urutan: 0,
            diarsipkan: false,
            dibuatPada: DateTime.now(),
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                penyediaDaftarDompetAktif.overrideWith(
                  (ref) => Stream.value([entitasDompetContoh]),
                ),
                penyediaTotalSaldoAktif.overrideWith((ref) => 5000000),
                penyediaSisaAnggaranBulanIni.overrideWith(
                  (ref) => Future.value(1500000),
                ),
                penyediaDaftarTujuanAktif.overrideWith(
                  (ref) => Stream.value([]),
                ),
                penyediaLimaTransaksiTerakhir.overrideWith(
                  (ref) => Stream.value([]),
                ),
                penyediaDaftarKategori.overrideWith((ref) => Stream.value([])),
                penyediaDaftarTransaksi.overrideWith((ref) => Stream.value([])),
                penyediaTotalSisaUtangAktif.overrideWith(
                  (ref) => Stream.value(0),
                ),
                penyediaDaftarUtangAktif.overrideWith(
                  (ref) => Stream.value([]),
                ),
                penyediaTagihanTerdekatBeranda.overrideWith(
                  (ref) => Future.value(null),
                ),
                penyediaLanjutBelajarBeranda.overrideWith(
                  (ref) => Future.value(
                    const InfoLanjutBelajar(
                      labelAksi: 'Mulai',
                      judul: 'Memetakan Arus Kas',
                      keterangan: 'Pelajaran siap dipelajari.',
                      rute: '/belajar',
                      bisaDibuka: true,
                    ),
                  ),
                ),
              ],
              child: MaterialApp(
                theme: TemaFunda.temaTerang,
                home: ValueListenableBuilder<double>(
                  valueListenable: skalaTeksNotifier,
                  builder: (context, skala, child) {
                    return MediaQuery(
                      data: MediaQueryData(
                        size: const Size(390, 844),
                        textScaler: TextScaler.linear(skala),
                      ),
                      child: Scaffold(body: child!),
                    );
                  },
                  child: const LayarBeranda(),
                ),
              ),
            ),
          );
          await pompaAman(tester);

          // 1. Ambil ukuran teks saat skala 1.0
          final finderTeks = find.byType(TeksFunda).first;
          final ukuranSkala1 = tester.getSize(finderTeks);

          // 2. Ubah skala teks menjadi 2.0 secara reaktif
          skalaTeksNotifier.value = 2.0;
          await pompaAman(tester);

          final ukuranSkala2 = tester.getSize(finderTeks);

          // Buktikan tinggi render teks pada skala 2.0 lebih tinggi daripada skala 1.0
          expect(
            ukuranSkala2.height,
            greaterThan(ukuranSkala1.height),
            reason:
                'Tinggi render teks pada skala 2.0 (${ukuranSkala2.height}) harus lebih besar dari skala 1.0 (${ukuranSkala1.height})',
          );
          expect(
            ukuranSkala2.height,
            greaterThanOrEqualTo(ukuranSkala1.height * 1.5),
            reason: 'Teks tidak boleh disusutkan oleh FittedBox',
          );

          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(milliseconds: 100));
        },
      );
    },
  );
}
