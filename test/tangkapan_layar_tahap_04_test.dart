import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funda/data/basis_data.dart';
import 'package:funda/data/penyedia_data.dart';
import 'package:funda/fitur/anggaran/kontroler/penyedia_anggaran.dart';
import 'package:funda/fitur/belajar/kontroler/penyedia_belajar.dart';
import 'package:funda/fitur/belajar/model/pembaca_konten.dart';
import 'package:funda/fitur/belajar/tampilan/layar_belajar.dart';
import 'package:funda/fitur/belajar/tampilan/layar_kuis_modul.dart';
import 'package:funda/fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import 'package:funda/fitur/beranda/tampilan/layar_beranda.dart';
import 'package:funda/fitur/tagihan/kontroler/penyedia_tagihan.dart';
import 'package:funda/fitur/tujuan/kontroler/penyedia_tujuan.dart';
import 'package:funda/fitur/utang/kontroler/penyedia_utang.dart';
import 'package:funda/perhitungan/perhitungan_belajar.dart';
import 'package:funda/tema/tema.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Pengambilan 10 Tangkapan Layar Tahap 4 (Mesin Belajar)', () {
    late BasisDataFunda basisData;

    setUp(() {
      basisData = BasisDataFunda(NativeDatabase.memory());
    });

    tearDown(() async {
      await basisData.close();
    });

    Future<void> simpanTangkapanLayar(WidgetTester tester, String namaBerkas) async {
      final boundary = tester.renderObject(find.byKey(const Key('area_tangkapan_layar'))) as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        expect(byteData, isNotNull);
      });
    }

    Widget bungkusLayar(Widget layar, {List<dynamic> overrides = const []}) {
      return ProviderScope(
        key: UniqueKey(),
        overrides: [
          penyediaBasisData.overrideWithValue(basisData),
          ...overrides.cast(),
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

    testWidgets('Ambil Seluruh 10 Tangkapan Layar Tahap 4 Sekaligus', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Muat Modul 1
      final modul1 = await PembacaKonten.muatModulDariAset(
        rootBundle,
        tingkat: 'pemula',
        modulId: 'anggaran_arus_kas',
      );

      // 1. 01_tab_belajar_peta.png
      debugPrint('MULAI 1');
      await tester.pumpWidget(bungkusLayar(const LayarBelajar()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '01_tab_belajar_peta.png');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));

      // 2. 02_pelajaran_terkunci_apa_yang_kurang.png
      debugPrint('MULAI 2');
      final pelKunci = PelajaranKonten(
        id: 'anggaran_arus_kas_1_3',
        modulId: 'anggaran_arus_kas',
        judul: 'Kebutuhan vs Keinginan',
        durasiMenit: 4,
        status: 'draf',
        gerbang: const [
          SyaratGerbangData(
            tipe: 'ada_data',
            objek: 'transaksi',
            min: 3,
            pesan: 'Catat minimal 3 pengeluaran nyata untuk membedakan pos kebutuhan.',
            atauPernyataan: 'tidak_punya_pengeluaran',
          ),
        ],
        pemantik: 'Pemantik',
        kartu: const [],
        contohAngka: 100000,
        cekPaham: const [],
        misi: const MisiKonten(
          tipe: 'ada_data',
          objek: 'transaksi',
          min: 1,
          judul: 'Misi',
          deskripsi: 'Deskripsi',
          perkiraanMenit: 2,
          umpanBalik: 'arus_kas_bulan_ini',
        ),
      );

      final itemModul = ItemPetaModul(
        modul: ModulKonten(
          id: 'anggaran_arus_kas',
          judul: 'Anggaran & Arus Kas',
          tingkat: 'pemula',
          urutan: 1,
          deskripsiSingkat: 'Fondasi penting arus kas.',
          tersedia: true,
          gerbang: const [],
          daftarPelajaran: const ['anggaran_arus_kas_1_3'],
          kuis: const KuisKonten(jumlahSoal: 0, bankSoal: []),
        ),
        statusModul: const HasilStatusBelajar(status: StatusBelajar.sedang, apaYangKurang: []),
        daftarPelajaran: [
          (
            pelKunci,
            const HasilStatusBelajar(
              status: StatusBelajar.terkunci,
              apaYangKurang: ['Catat minimal 3 pengeluaran nyata untuk membedakan pos kebutuhan.'],
              ruteAksi: '/catatan',
              daftarAtauPernyataan: ['tidak_punya_pengeluaran'],
            )
          ),
        ],
      );

      await tester.pumpWidget(
        bungkusLayar(
          const LayarBelajar(),
          overrides: [
            penyediaPetaBelajar.overrideWith((ref) => Future.value([itemModul])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '02_pelajaran_terkunci_apa_yang_kurang.png');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));

      // 3. 03_pemutar_pemantik.png
      await tester.pumpWidget(
        bungkusLayar(
          const LayarPemutarPelajaran(
            modulId: 'anggaran_arus_kas',
            pelajaranId: 'anggaran_arus_kas_1_2',
          ),
          overrides: [
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul1])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '03_pemutar_pemantik.png');

      // 4. 04_pemutar_kartu_konsep_tooltip.png
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      final listRich = tester.widgetList<RichText>(find.byType(RichText));
      for (final r in listRich) {
        final span = r.text as TextSpan;
        var opened = false;
        span.visitChildren((child) {
          if (child is TextSpan && (child.text?.toLowerCase().contains('arus kas') ?? false)) {
            final tapRec = child.recognizer as TapGestureRecognizer?;
            tapRec?.onTap?.call();
            opened = true;
            return false;
          }
          return true;
        });
        if (opened) break;
      }
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '04_pemutar_kartu_konsep_tooltip.png');

      // Tutup dialog tooltip jika terbuka
      if (find.text('Mengerti').evaluate().isNotEmpty) {
        await tester.tap(find.text('Mengerti'));
        await tester.pumpAndSettle();
      }

      // 5. 05_pemutar_cek_paham.png
      // Dari kartu konsep 2 -> konsep 3 -> contoh angka -> cek paham (3x tap Lanjut)
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '05_pemutar_cek_paham.png');

      // 6. 06_pemutar_kartu_misi.png
      await tester.tap(find.text('Arus kas negatif dan saldo berkurang'));
      await tester.pumpAndSettle();
      final soal2 = find.text('Mencatat pemasukan dan pengeluaran apa adanya');
      await tester.ensureVisible(soal2);
      await tester.pumpAndSettle();
      await tester.tap(soal2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '06_pemutar_kartu_misi.png');

      // 7. 07_pemutar_umpan_balik.png
      await tester.tap(find.text('Belum relevan buat aku'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '07_pemutar_umpan_balik.png');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));

      // 8. 08_kuis_soal.png
      await tester.pumpWidget(
        bungkusLayar(
          const LayarKuisModul(modulId: 'anggaran_arus_kas'),
          overrides: [
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modul1])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '08_kuis_soal.png');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));

      // 9. 09_kuis_hasil_lulus.png
      final modulKuisLulus = ModulKonten(
        id: 'modul_kuis_lulus',
        judul: 'Modul Lulus',
        tingkat: 'pemula',
        urutan: 1,
        deskripsiSingkat: 'Deskripsi',
        tersedia: true,
        gerbang: const [],
        daftarPelajaran: const [],
        kuis: const KuisKonten(
          jumlahSoal: 1,
          bankSoal: [
            SoalKuis(
              id: 's1',
              pelajaranId: 'pel_1',
              tanya: 'Uji satu soal lulus?',
              pilihan: ['Benar', 'Salah'],
              benar: 0,
              penjelasan: 'Jawaban benar.',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        bungkusLayar(
          const LayarKuisModul(modulId: 'modul_kuis_lulus'),
          overrides: [
            penyediaDaftarSemuaModul.overrideWith((ref) => Future.value([modulKuisLulus])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Benar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat Hasil Kuis'));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '09_kuis_hasil_lulus.png');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));

      // 10. 10_beranda_lanjut_belajar.png
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
        bungkusLayar(
          const LayarBeranda(),
          overrides: [
            penyediaDaftarDompetAktif.overrideWith((ref) => Stream.value([entitasDompetContoh])),
            penyediaTotalSaldoAktif.overrideWith((ref) => 5000000),
            penyediaSisaAnggaranBulanIni.overrideWith((ref) => Future.value(1500000)),
            penyediaDaftarTujuanAktif.overrideWith((ref) => Stream.value([])),
            penyediaLimaTransaksiTerakhir.overrideWith((ref) => Stream.value([])),
            penyediaDaftarKategori.overrideWith((ref) => Stream.value([])),
            penyediaDaftarTransaksi.overrideWith((ref) => Stream.value([])),
            penyediaTotalSisaUtangAktif.overrideWith((ref) => Stream.value(0)),
            penyediaDaftarUtangAktif.overrideWith((ref) => Stream.value([])),
            penyediaTagihanTerdekatBeranda.overrideWith((ref) => Future.value(null)),
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
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await simpanTangkapanLayar(tester, '10_beranda_lanjut_belajar.png');

      // Bersihkan widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
