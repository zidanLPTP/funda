import 'package:flutter/material.dart';
import '../../../komponen/ilustrasi_funda.dart';
import '../../../tema/token.dart';

/// Tahap visual di dalam kartu Pemutar Pelajaran.
enum TahapPelajaranVisual { pemantik, kartu, contohAngka, misi, tindakLanjut }

/// Pasangan path aset SVG dan warna kanvas pastel untuk satu adegan pelajaran.
class InfoIlustrasiPelajaran {
  final String pathSvg;
  final Color kanvas;

  const InfoIlustrasiPelajaran({required this.pathSvg, required this.kanvas});
}

/// Kunci tahap standar untuk pemetaan spesifik `(pelajaranId, kunciTahap)`.
String kunciTahapVisual(TahapPelajaranVisual tahap, {int? indeksKartu}) {
  return switch (tahap) {
    TahapPelajaranVisual.pemantik => 'pemantik',
    TahapPelajaranVisual.kartu => 'kartu_${indeksKartu ?? 0}',
    TahapPelajaranVisual.contohAngka => 'contoh_angka',
    TahapPelajaranVisual.misi => 'misi',
    TahapPelajaranVisual.tindakLanjut => 'tindak_lanjut',
  };
}

/// Peta spesifik per `(pelajaranId, kunciTahap)` (Prioritas 1).
const Map<(String, String), InfoIlustrasiPelajaran> petaSpesifikIlustrasiKartu =
    {
      // Modul 1: Anggaran & Arus Kas
      ('anggaran_arus_kas_1_1', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.dompet,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('anggaran_arus_kas_1_1', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPengeluaranKecil,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_1', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.catatTransaksi,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_1', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.laporanBulanan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_2', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPetaArusKas,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('anggaran_arus_kas_1_2', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPetaArusKas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_2', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPetaArusKas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_2', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.ruangTenang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_3', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranKebutuhanVsKeinginan,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('anggaran_arus_kas_1_3', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.psikologiUang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_3', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranKebutuhanVsKeinginan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_3', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.kantongKosong,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_4', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranRencana503020,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('anggaran_arus_kas_1_4', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranRencana503020,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_4', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tabungan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_4', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranRencana503020,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_5', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.ruangTenang,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('anggaran_arus_kas_1_5', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.laporanBulanan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_5', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('anggaran_arus_kas_1_5', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.anggaranKosong,
        kanvas: WarnaFunda.kanvasMint,
      ),

      // Modul 2: Tabungan
      ('tabungan_2_1', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.dompet,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('tabungan_2_1', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranTujuanTarget,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_1', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tujuanKosong,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_1', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tujuanBesar,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_2', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPengeluaranKecil,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('tabungan_2_2', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tabungan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_2', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.kantongKosong,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_3', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranTujuanTarget,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('tabungan_2_3', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranKecepatanMenabung,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_3', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranKecepatanMenabung,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('tabungan_2_3', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasMint,
      ),

      // Modul 3: Dana Darurat
      ('dana_darurat_3_1', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBantalanDarurat,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('dana_darurat_3_1', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBantalanDarurat,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_1', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBantalanDarurat,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_1', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.kantongKosong,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_2', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('dana_darurat_3_2', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tagihanTenang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_2', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranMeteranBulanDarurat,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_2', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tujuanBesar,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_3', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tujuanKosong,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('dana_darurat_3_3', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tabungan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_3', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.catatTransaksi,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('dana_darurat_3_3', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranMeteranBulanDarurat,
        kanvas: WarnaFunda.kanvasMint,
      ),

      // Modul 4: Utang & Cicilan
      ('utang_cicilan_4_1', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.paylaterKredit,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('utang_cicilan_4_1', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.waspadaPenipuan,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('utang_cicilan_4_2', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBungaPinjaman,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('utang_cicilan_4_2', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBungaPinjaman,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('utang_cicilan_4_2', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBungaPinjaman,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('utang_cicilan_4_2', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.paylaterKredit,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('utang_cicilan_4_3', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.laporanBulanan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('utang_cicilan_4_3', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('utang_cicilan_4_4', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBolaSaljuLongsor,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('utang_cicilan_4_4', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBolaSaljuLongsor,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('utang_cicilan_4_4', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBolaSaljuLongsor,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('utang_cicilan_4_4', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.utangLunasKosong,
        kanvas: WarnaFunda.kanvasMint,
      ),

      // Modul 5: Waspada Penipuan
      ('waspada_penipuan_5_1', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.waspadaPenipuan,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('waspada_penipuan_5_1', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.psikologiUang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('waspada_penipuan_5_1', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.waspadaPenipuan,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('waspada_penipuan_5_2', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.waspadaPenipuan,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('waspada_penipuan_5_2', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('waspada_penipuan_5_3', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.ruangTenang,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('waspada_penipuan_5_3', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.ruangTenang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('waspada_penipuan_5_3', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.privasiLokal,
        kanvas: WarnaFunda.kanvasMint,
      ),

      // Modul 6: Psikologi Uang
      ('psikologi_uang_6_1', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.psikologiUang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('psikologi_uang_6_1', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('psikologi_uang_6_2', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPengeluaranKecil,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('psikologi_uang_6_2', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPengeluaranKecil,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('psikologi_uang_6_2', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranEvaluasiKompas,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('psikologi_uang_6_2', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tagihanTenang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('psikologi_uang_6_3', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranKebutuhanVsKeinginan,
        kanvas: WarnaFunda.kanvasMint,
      ),

      // Modul 7: Paylater & Kredit
      ('paylater_kredit_7_1', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.paylaterKredit,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('paylater_kredit_7_1', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.utangCicilan,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('paylater_kredit_7_1', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranBungaPinjaman,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('paylater_kredit_7_1', 'kartu_2'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranPengeluaranKecil,
        kanvas: WarnaFunda.kanvasKoral,
      ),
      ('paylater_kredit_7_2', 'pemantik'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.kprKreditBesar,
        kanvas: WarnaFunda.kanvasKuning,
      ),
      ('paylater_kredit_7_3', 'kartu_0'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.tagihanTenang,
        kanvas: WarnaFunda.kanvasMint,
      ),
      ('paylater_kredit_7_3', 'kartu_1'): InfoIlustrasiPelajaran(
        pathSvg: AsetIlustrasiFunda.pelajaranRencana503020,
        kanvas: WarnaFunda.kanvasMint,
      ),
    };

/// Mengembalikan warna kanvas default sesuai ritme peran tahap pelajaran.
Color kanvasDefaultUntukTahap(TahapPelajaranVisual tahap) {
  return switch (tahap) {
    TahapPelajaranVisual.pemantik => WarnaFunda.kanvasKuning,
    TahapPelajaranVisual.kartu => WarnaFunda.kanvasMint,
    TahapPelajaranVisual.contohAngka => WarnaFunda.kanvasBiru,
    TahapPelajaranVisual.misi => WarnaFunda.kanvasUngu,
    TahapPelajaranVisual.tindakLanjut => WarnaFunda.kanvasMint,
  };
}

/// Menentukan path SVG otomatis untuk tahap Misi Praktik berdasarkan jenis/objek misi.
String _pathSvgUntukMisi({
  required String modulId,
  String? misiTipe,
  String? misiObjek,
  String? misiAturan,
  String? misiUmpanBalik,
}) {
  if (misiTipe == 'sandbox') return AsetIlustrasiFunda.modeSandbox;

  final objek = (misiObjek ?? '').toLowerCase();
  final aturan = (misiAturan ?? '').toLowerCase();
  final umpanBalik = (misiUmpanBalik ?? '').toLowerCase();

  if (objek.contains('dompet')) return AsetIlustrasiFunda.dompet;
  if (objek.contains('dana_darurat')) return AsetIlustrasiFunda.danaDarurat;
  if (objek.contains('tujuan') || objek.contains('tabungan')) {
    return AsetIlustrasiFunda.tujuanKosong;
  }
  if (objek.contains('anggaran') || umpanBalik.contains('anggaran')) {
    return AsetIlustrasiFunda.anggaranKosong;
  }
  if (objek.contains('utang') ||
      objek.contains('cicilan') ||
      umpanBalik.contains('utang') ||
      umpanBalik.contains('cicilan') ||
      umpanBalik.contains('pelunasan')) {
    return AsetIlustrasiFunda.utangCicilan;
  }
  if (objek.contains('pengeluaran') ||
      objek.contains('pemasukan') ||
      objek.contains('transaksi') ||
      objek.contains('arus_kas') ||
      objek.contains('sumber_pemasukan') ||
      objek.contains('kategori') ||
      aturan == 'semua_kategori_berlabel') {
    return AsetIlustrasiFunda.catatTransaksi;
  }
  if (misiTipe == 'lihat_hitungan') return AsetIlustrasiFunda.laporanBulanan;
  if (misiTipe == 'keputusan' ||
      misiTipe == 'daftar_periksa' ||
      misiTipe == 'refleksi') {
    return temaVisualUntukModul(modulId).pathSvg;
  }

  return temaVisualUntukModul(modulId).pathSvg;
}

/// Menyelesaikan path SVG dan warna kanvas untuk kartu di Pemutar Pelajaran.
///
/// Urutan prioritas:
/// 1. Pemetaan spesifik `(pelajaranId, kunciTahap)`.
/// 2. Pemetaan otomatis tahap `contohAngka` & `misi`.
/// 3. Fallback ke ilustrasi utama `modulId` dengan ritme warna tahap.
InfoIlustrasiPelajaran selesaikanIlustrasiPelajaran({
  required String modulId,
  String? pelajaranId,
  TahapPelajaranVisual tahap = TahapPelajaranVisual.kartu,
  int? indeksKartu,
  String? misiTipe,
  String? misiObjek,
  String? misiAturan,
  String? misiUmpanBalik,
}) {
  // Prioritas 1: Spesifik kartu/pelajaran
  if (pelajaranId != null) {
    final kunci = kunciTahapVisual(tahap, indeksKartu: indeksKartu);
    final spesifik = petaSpesifikIlustrasiKartu[(pelajaranId, kunci)];
    if (spesifik != null) {
      return spesifik;
    }
  }

  final kanvas = kanvasDefaultUntukTahap(tahap);

  // Prioritas 2: Otomatis untuk tahap Contoh Angka & Misi Praktik
  if (tahap == TahapPelajaranVisual.contohAngka) {
    return InfoIlustrasiPelajaran(
      pathSvg: AsetIlustrasiFunda.laporanBulanan,
      kanvas: kanvas,
    );
  }
  if (tahap == TahapPelajaranVisual.misi) {
    return InfoIlustrasiPelajaran(
      pathSvg: _pathSvgUntukMisi(
        modulId: modulId,
        misiTipe: misiTipe,
        misiObjek: misiObjek,
        misiAturan: misiAturan,
        misiUmpanBalik: misiUmpanBalik,
      ),
      kanvas: kanvas,
    );
  }

  // Prioritas 3: Fallback ke ilustrasi utama modulId
  return InfoIlustrasiPelajaran(
    pathSvg: temaVisualUntukModul(modulId).pathSvg,
    kanvas: kanvas,
  );
}
