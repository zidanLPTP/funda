import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:funda/fitur/belajar/data/peta_ilustrasi_pelajaran.dart';
import 'package:funda/komponen/ilustrasi_funda.dart';
import 'package:funda/tema/token.dart';

void main() {
  group('Peta Ilustrasi Pelajaran', () {
    test(
      'Prioritas 1: pemetaan spesifik pelajaranId dan kunciTahap menang',
      () {
        final info = selesaikanIlustrasiPelajaran(
          modulId: 'anggaran_arus_kas',
          pelajaranId: 'anggaran_arus_kas_1_1',
          tahap: TahapPelajaranVisual.pemantik,
        );

        expect(info.pathSvg, AsetIlustrasiFunda.dompet);
        expect(info.kanvas, WarnaFunda.kanvasKuning);

        final kartuKecil = selesaikanIlustrasiPelajaran(
          modulId: 'anggaran_arus_kas',
          pelajaranId: 'anggaran_arus_kas_1_1',
          tahap: TahapPelajaranVisual.kartu,
          indeksKartu: 0,
        );
        expect(
          kartuKecil.pathSvg,
          AsetIlustrasiFunda.pelajaranPengeluaranKecil,
        );
        expect(kartuKecil.kanvas, WarnaFunda.kanvasMint);

        final peringatanUtang = selesaikanIlustrasiPelajaran(
          modulId: 'utang_cicilan',
          pelajaranId: 'utang_cicilan_4_1',
          tahap: TahapPelajaranVisual.kartu,
          indeksKartu: 2,
        );
        expect(peringatanUtang.pathSvg, AsetIlustrasiFunda.waspadaPenipuan);
        expect(peringatanUtang.kanvas, WarnaFunda.kanvasKoral);

        final bantalan = selesaikanIlustrasiPelajaran(
          modulId: 'dana_darurat',
          pelajaranId: 'dana_darurat_3_1',
          tahap: TahapPelajaranVisual.pemantik,
        );
        expect(bantalan.pathSvg, AsetIlustrasiFunda.pelajaranBantalanDarurat);
        expect(bantalan.kanvas, WarnaFunda.kanvasKuning);

        final paylaterBunga = selesaikanIlustrasiPelajaran(
          modulId: 'paylater_kredit',
          pelajaranId: 'paylater_kredit_7_1',
          tahap: TahapPelajaranVisual.kartu,
          indeksKartu: 1,
        );
        expect(
          paylaterBunga.pathSvg,
          AsetIlustrasiFunda.pelajaranBungaPinjaman,
        );
        expect(paylaterBunga.kanvas, WarnaFunda.kanvasKoral);
      },
    );

    test(
      'Prioritas 2: Contoh Angka otomatis memakai laporanBulanan dan kanvasBiru',
      () {
        final info = selesaikanIlustrasiPelajaran(
          modulId: 'tabungan',
          pelajaranId: 'tabungan_2_1',
          tahap: TahapPelajaranVisual.contohAngka,
        );

        expect(info.pathSvg, AsetIlustrasiFunda.laporanBulanan);
        expect(info.kanvas, WarnaFunda.kanvasBiru);
      },
    );

    test(
      'Prioritas 2: Misi Praktik otomatis mencocokkan jenis dan objek misi',
      () {
        final misiCatat = selesaikanIlustrasiPelajaran(
          modulId: 'anggaran_arus_kas',
          pelajaranId: 'anggaran_arus_kas_1_1',
          tahap: TahapPelajaranVisual.misi,
          misiTipe: 'ada_data',
          misiObjek: 'pengeluaran',
        );
        expect(misiCatat.pathSvg, AsetIlustrasiFunda.catatTransaksi);
        expect(misiCatat.kanvas, WarnaFunda.kanvasUngu);

        final misiAnggaran = selesaikanIlustrasiPelajaran(
          modulId: 'anggaran_arus_kas',
          pelajaranId: 'anggaran_arus_kas_1_4',
          tahap: TahapPelajaranVisual.misi,
          misiTipe: 'ada_data',
          misiObjek: 'anggaran',
        );
        expect(misiAnggaran.pathSvg, AsetIlustrasiFunda.anggaranKosong);
        expect(misiAnggaran.kanvas, WarnaFunda.kanvasUngu);

        final misiSandbox = selesaikanIlustrasiPelajaran(
          modulId: 'investasi_dasar',
          pelajaranId: 'investasi_dasar_11_1',
          tahap: TahapPelajaranVisual.misi,
          misiTipe: 'sandbox',
        );
        expect(misiSandbox.pathSvg, AsetIlustrasiFunda.modeSandbox);
        expect(misiSandbox.kanvas, WarnaFunda.kanvasUngu);
      },
    );

    test('Prioritas 3: fallback ke ilustrasi modulId bila belum dipetakan', () {
      final info = selesaikanIlustrasiPelajaran(
        modulId: 'investasi_dasar',
        pelajaranId: 'investasi_dasar_belum_dipetakan',
        tahap: TahapPelajaranVisual.kartu,
        indeksKartu: 0,
      );

      expect(info.pathSvg, AsetIlustrasiFunda.investasiDasar);
      expect(info.kanvas, WarnaFunda.kanvasMint);
    });

    test('Seluruh path SVG pada petaSpesifikIlustrasiKartu ada di disk', () {
      for (final entri in petaSpesifikIlustrasiKartu.entries) {
        final berkas = File(entri.value.pathSvg);
        expect(
          berkas.existsSync(),
          isTrue,
          reason: 'Berkas SVG tidak ditemukan: ${entri.value.pathSvg}',
        );
      }
    });
  });
}
