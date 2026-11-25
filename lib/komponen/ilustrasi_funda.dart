import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../tema/token.dart';

/// Kumpulan path aset SVG ilustrasi resmi Funda di `aset/gambar/ilustrasi/`.
abstract final class AsetIlustrasiFunda {
  static const dompet = 'aset/gambar/ilustrasi/dompet.svg';
  static const belumAdaDompet = 'aset/gambar/ilustrasi/belum-ada-dompet.svg';
  static const laporanBulanan = 'aset/gambar/ilustrasi/laporan_bulanan.svg';
  static const modeSandbox = 'aset/gambar/ilustrasi/mode_sandbox.svg';
  static const iconFunda = 'aset/gambar/ilustrasi/icon-funda.svg';

  static const mulaiTesAwal = 'aset/gambar/ilustrasi/mulai-tes-awal.svg';
  static const anggaranArusKas =
      'aset/gambar/ilustrasi/anggaran-dan-arus-kas.svg';
  static const tabungan = 'aset/gambar/ilustrasi/tabungan.svg';
  static const danaDarurat = 'aset/gambar/ilustrasi/dana-darurat.svg';
  static const utangCicilan = 'aset/gambar/ilustrasi/utang_cicilan.svg';
  static const waspadaPenipuan = 'aset/gambar/ilustrasi/waspada_penipuan.svg';
  static const psikologiUang = 'aset/gambar/ilustrasi/psikologi_uang.svg';

  static const investasiDasar = 'aset/gambar/ilustrasi/investasi_dasar.svg';
  static const pajakDasar = 'aset/gambar/ilustrasi/pajak_dasar.svg';
  static const paylaterKredit = 'aset/gambar/ilustrasi/paylater_kredit.svg';
  static const penghasilanTambahan =
      'aset/gambar/ilustrasi/penghasilan_tambahan.svg';
  static const tujuanBesar = 'aset/gambar/ilustrasi/tujuan_besar.svg';
  static const proteksiDasar = 'aset/gambar/ilustrasi/proteksi_dasar.svg';

  static const investasiLanjutan =
      'aset/gambar/ilustrasi/investasi_lanjutan.svg';
  static const kprKreditBesar = 'aset/gambar/ilustrasi/kpr_kredit_besar.svg';
  static const pajakLanjutan = 'aset/gambar/ilustrasi/pajak_lanjutan.svg';
  static const pensiunKebebasanFinansial =
      'aset/gambar/ilustrasi/pensiun_kebebasan_finansial.svg';
  static const keuanganUsahaKecil =
      'aset/gambar/ilustrasi/keuangan_usaha_kecil.svg';
  static const proteksiKeluargaWarisan =
      'aset/gambar/ilustrasi/proteksi_keluarga_warisan.svg';
}

/// Widget perender ilustrasi SVG lokal dari aset Funda.
class IlustrasiSvgFunda extends StatelessWidget {
  final String pathAset;
  final double? lebar;
  final double tinggi;
  final BoxFit fit;
  final String? labelAkses;

  const IlustrasiSvgFunda({
    super.key,
    required this.pathAset,
    this.lebar,
    this.tinggi = 96,
    this.fit = BoxFit.contain,
    this.labelAkses,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      pathAset,
      width: lebar,
      height: tinggi,
      fit: fit,
      excludeFromSemantics: labelAkses == null,
      semanticsLabel: labelAkses,
    );
  }
}

/// Jenis ilustrasi vektor geometris buatan sendiri untuk modul & layar belajar Funda.
enum JenisIlustrasiFunda {
  kompas,
  neraca,
  celengan,
  rantaiKalender,
  perisai,
  pikiran,
  pajak,
  tunas,
  sasaran,
}

/// Pasangan warna kanvas solid cerah, aset SVG, & aksen kontras untuk modul.
class TemaVisualModul {
  final Color kanvas;
  final Color aksen;
  final Color warnaIkon;
  final IconData ikonGaris;
  final JenisIlustrasiFunda ilustrasi;
  final String pathSvg;

  const TemaVisualModul({
    required this.kanvas,
    required this.aksen,
    required this.warnaIkon,
    required this.ikonGaris,
    required this.ilustrasi,
    required this.pathSvg,
  });
}

/// Mengembalikan pasangan warna kanvas, aset SVG, aksen ilustrasi, dan ikon per modul.
TemaVisualModul temaVisualUntukModul(String modulId) {
  return switch (modulId) {
    'mulai_tes_awal' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.compass,
      ilustrasi: JenisIlustrasiFunda.kompas,
      pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
    ),
    'anggaran_arus_kas' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.sifatKebutuhan,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.scale,
      ilustrasi: JenisIlustrasiFunda.neraca,
      pathSvg: AsetIlustrasiFunda.anggaranArusKas,
    ),
    'tabungan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.piggyBank,
      ilustrasi: JenisIlustrasiFunda.celengan,
      pathSvg: AsetIlustrasiFunda.tabungan,
    ),
    'dana_darurat' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKuning,
      aksen: WarnaFunda.peringatan,
      warnaIkon: WarnaFunda.aksenIkonKuning,
      ikonGaris: LucideIcons.umbrella,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.danaDarurat,
    ),
    'utang_cicilan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKoral,
      aksen: WarnaFunda.pengeluaran,
      warnaIkon: WarnaFunda.aksenIkonKoral,
      ikonGaris: LucideIcons.calendarClock,
      ilustrasi: JenisIlustrasiFunda.rantaiKalender,
      pathSvg: AsetIlustrasiFunda.utangCicilan,
    ),
    'waspada_penipuan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKoral,
      aksen: WarnaFunda.bahaya,
      warnaIkon: WarnaFunda.aksenIkonKoral,
      ikonGaris: LucideIcons.shieldAlert,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.waspadaPenipuan,
    ),
    'psikologi_uang' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasUngu,
      aksen: WarnaFunda.sifatKeinginan,
      warnaIkon: WarnaFunda.aksenIkonUngu,
      ikonGaris: LucideIcons.brain,
      ilustrasi: JenisIlustrasiFunda.pikiran,
      pathSvg: AsetIlustrasiFunda.psikologiUang,
    ),
    'paylater_kredit' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKuning,
      aksen: WarnaFunda.peringatan,
      warnaIkon: WarnaFunda.aksenIkonKuning,
      ikonGaris: LucideIcons.creditCard,
      ilustrasi: JenisIlustrasiFunda.rantaiKalender,
      pathSvg: AsetIlustrasiFunda.paylaterKredit,
    ),
    'penghasilan_tambahan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.pemasukan,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.briefcase,
      ilustrasi: JenisIlustrasiFunda.neraca,
      pathSvg: AsetIlustrasiFunda.penghasilanTambahan,
    ),
    'pajak_dasar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.info,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.fileSpreadsheet,
      ilustrasi: JenisIlustrasiFunda.pajak,
      pathSvg: AsetIlustrasiFunda.pajakDasar,
    ),
    'pajak_lanjutan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.info,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.fileSpreadsheet,
      ilustrasi: JenisIlustrasiFunda.pajak,
      pathSvg: AsetIlustrasiFunda.pajakLanjutan,
    ),
    'proteksi_dasar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.sifatKebutuhan,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.shieldCheck,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.proteksiDasar,
    ),
    'proteksi_keluarga_warisan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasBiru,
      aksen: WarnaFunda.sifatKebutuhan,
      warnaIkon: WarnaFunda.aksenIkonBiru,
      ikonGaris: LucideIcons.shieldCheck,
      ilustrasi: JenisIlustrasiFunda.perisai,
      pathSvg: AsetIlustrasiFunda.proteksiKeluargaWarisan,
    ),
    'investasi_dasar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utamaGelap,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.sprout,
      ilustrasi: JenisIlustrasiFunda.tunas,
      pathSvg: AsetIlustrasiFunda.investasiDasar,
    ),
    'investasi_lanjutan' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utamaGelap,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.sprout,
      ilustrasi: JenisIlustrasiFunda.tunas,
      pathSvg: AsetIlustrasiFunda.investasiLanjutan,
    ),
    'tujuan_besar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasUngu,
      aksen: WarnaFunda.sifatKeinginan,
      warnaIkon: WarnaFunda.aksenIkonUngu,
      ikonGaris: LucideIcons.target,
      ilustrasi: JenisIlustrasiFunda.sasaran,
      pathSvg: AsetIlustrasiFunda.tujuanBesar,
    ),
    'kpr_kredit_besar' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasUngu,
      aksen: WarnaFunda.sifatKeinginan,
      warnaIkon: WarnaFunda.aksenIkonUngu,
      ikonGaris: LucideIcons.target,
      ilustrasi: JenisIlustrasiFunda.sasaran,
      pathSvg: AsetIlustrasiFunda.kprKreditBesar,
    ),
    'pensiun_kebebasan_finansial' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKuning,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonKuning,
      ikonGaris: LucideIcons.sun,
      ilustrasi: JenisIlustrasiFunda.tunas,
      pathSvg: AsetIlustrasiFunda.pensiunKebebasanFinansial,
    ),
    'keuangan_usaha_kecil' => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasKoral,
      aksen: WarnaFunda.pengeluaran,
      warnaIkon: WarnaFunda.aksenIkonKoral,
      ikonGaris: LucideIcons.store,
      ilustrasi: JenisIlustrasiFunda.neraca,
      pathSvg: AsetIlustrasiFunda.keuanganUsahaKecil,
    ),
    _ => const TemaVisualModul(
      kanvas: WarnaFunda.kanvasMint,
      aksen: WarnaFunda.utama,
      warnaIkon: WarnaFunda.aksenIkonMint,
      ikonGaris: LucideIcons.bookOpen,
      ilustrasi: JenisIlustrasiFunda.sasaran,
      pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
    ),
  };
}

/// Kanvas ilustrasi persegi panjang membulat besar berlatar pastel solid cerah
/// untuk kepala kartu di Pemutar Pelajaran.
class KanvasIlustrasiPelajaran extends StatelessWidget {
  final String modulId;
  final double tinggi;

  const KanvasIlustrasiPelajaran({
    super.key,
    required this.modulId,
    this.tinggi = 164,
  });

  @override
  Widget build(BuildContext context) {
    final tema = temaVisualUntukModul(modulId);
    return Container(
      width: double.infinity,
      height: tinggi,
      decoration: BoxDecoration(
        color: tema.kanvas,
        borderRadius: BorderRadius.circular(SudutFunda.petak),
      ),
      child: Center(
        child: IlustrasiSvgFunda(pathAset: tema.pathSvg, tinggi: tinggi * 0.78),
      ),
    );
  }
}

/// Ilustrasi vektor geometris murni yang digambar menggunakan CustomPainter
/// dengan palet Funda dan garis bersih tanpa dependensi gambar luar.
class IlustrasiGeometrisFunda extends StatelessWidget {
  final JenisIlustrasiFunda jenis;
  final Color warnaAksen;
  final double ukuran;

  const IlustrasiGeometrisFunda({
    super.key,
    required this.jenis,
    required this.warnaAksen,
    this.ukuran = 108,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ukuran,
      height: ukuran,
      child: CustomPaint(
        painter: _PelukisIlustrasiGeometris(
          jenis: jenis,
          warnaAksen: warnaAksen,
        ),
      ),
    );
  }
}

class _PelukisIlustrasiGeometris extends CustomPainter {
  final JenisIlustrasiFunda jenis;
  final Color warnaAksen;

  const _PelukisIlustrasiGeometris({
    required this.jenis,
    required this.warnaAksen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.42;

    final catIsiLembut = Paint()
      ..color = WarnaFunda.permukaan.withAlpha(220)
      ..style = PaintingStyle.fill;
    final catAksenIsi = Paint()
      ..color = warnaAksen
      ..style = PaintingStyle.fill;
    final catAksenLembut = Paint()
      ..color = warnaAksen.withAlpha(55)
      ..style = PaintingStyle.fill;
    final catGaris = Paint()
      ..color = WarnaFunda.tombolGelap
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final catGarisAksen = Paint()
      ..color = warnaAksen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (jenis) {
      case JenisIlustrasiFunda.sasaran:
        canvas.drawCircle(Offset(cx, cy), r, catIsiLembut);
        canvas.drawCircle(Offset(cx, cy), r, catGarisAksen);
        canvas.drawCircle(Offset(cx, cy), r * 0.64, catAksenLembut);
        canvas.drawCircle(Offset(cx, cy), r * 0.64, catGarisAksen);
        canvas.drawCircle(Offset(cx, cy), r * 0.28, catAksenIsi);
        // Panah diagonal bersih masuk tepat ke pusat sasaran
        final ujung = Offset(cx + r * 0.92, cy - r * 0.92);
        canvas.drawLine(Offset(cx, cy), ujung, catGaris);
        canvas.drawLine(ujung, Offset(ujung.dx - r * 0.24, ujung.dy), catGaris);
        canvas.drawLine(ujung, Offset(ujung.dx, ujung.dy + r * 0.24), catGaris);
      case JenisIlustrasiFunda.neraca:
        // Pilar & alas timbangan seimbang
        final alas = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + r * 0.72),
            width: r * 1.15,
            height: r * 0.2,
          ),
          Radius.circular(r * 0.1),
        );
        canvas.drawRRect(alas, catAksenIsi);
        canvas.drawLine(
          Offset(cx, cy + r * 0.62),
          Offset(cx, cy - r * 0.68),
          catGaris,
        );
        // Lengan timbangan
        canvas.drawLine(
          Offset(cx - r * 0.85, cy - r * 0.42),
          Offset(cx + r * 0.85, cy - r * 0.42),
          catGaris,
        );
        // Dua piringan seimbang
        final kiri = Offset(cx - r * 0.78, cy + r * 0.16);
        final kanan = Offset(cx + r * 0.78, cy + r * 0.16);
        canvas.drawLine(
          Offset(cx - r * 0.78, cy - r * 0.42),
          kiri,
          catGarisAksen,
        );
        canvas.drawLine(
          Offset(cx + r * 0.78, cy - r * 0.42),
          kanan,
          catGarisAksen,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kiri, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catIsiLembut,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kiri, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catGaris,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kanan, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catAksenLembut,
        );
        canvas.drawArc(
          Rect.fromCenter(center: kanan, width: r * 0.66, height: r * 0.42),
          0,
          math.pi,
          true,
          catGaris,
        );
        canvas.drawCircle(Offset(cx, cy - r * 0.72), r * 0.14, catAksenIsi);
      case JenisIlustrasiFunda.celengan:
        // Koin di atas & kotak tabungan membulat
        final badan = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + r * 0.16),
            width: r * 1.55,
            height: r * 1.05,
          ),
          Radius.circular(r * 0.48),
        );
        canvas.drawRRect(badan, catIsiLembut);
        canvas.drawRRect(badan, catGaris);
        // Celah koin
        canvas.drawLine(
          Offset(cx - r * 0.25, cy - r * 0.16),
          Offset(cx + r * 0.25, cy - r * 0.16),
          catGaris,
        );
        // Koin masuk
        canvas.drawCircle(Offset(cx, cy - r * 0.62), r * 0.3, catAksenIsi);
        canvas.drawCircle(Offset(cx, cy - r * 0.62), r * 0.3, catGaris);
        canvas.drawCircle(
          Offset(cx + r * 0.42, cy + r * 0.05),
          r * 0.08,
          catAksenIsi,
        );
      case JenisIlustrasiFunda.perisai:
        final perisai = Path()
          ..moveTo(cx, cy - r * 0.92)
          ..lineTo(cx + r * 0.78, cy - r * 0.56)
          ..quadraticBezierTo(cx + r * 0.78, cy + r * 0.36, cx, cy + r * 0.92)
          ..quadraticBezierTo(
            cx - r * 0.78,
            cy + r * 0.36,
            cx - r * 0.78,
            cy - r * 0.56,
          )
          ..close();
        canvas.drawPath(perisai, catIsiLembut);
        canvas.drawPath(perisai, catGarisAksen);
        final centang = Path()
          ..moveTo(cx - r * 0.28, cy + r * 0.02)
          ..lineTo(cx - r * 0.05, cy + r * 0.26)
          ..lineTo(cx + r * 0.34, cy - r * 0.22);
        canvas.drawPath(centang, catGaris);
      case JenisIlustrasiFunda.tunas:
        // Batang diagram + daun tunas tumbuh ke atas
        final lebarBar = r * 0.28;
        final batang1 = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.72, cy + r * 0.2, lebarBar, r * 0.6),
          Radius.circular(r * 0.08),
        );
        final batang2 = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.14, cy - r * 0.1, lebarBar, r * 0.9),
          Radius.circular(r * 0.08),
        );
        final batang3 = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + r * 0.44, cy - r * 0.45, lebarBar, r * 1.25),
          Radius.circular(r * 0.08),
        );
        canvas.drawRRect(batang1, catIsiLembut);
        canvas.drawRRect(batang1, catGaris);
        canvas.drawRRect(batang2, catAksenLembut);
        canvas.drawRRect(batang2, catGaris);
        canvas.drawRRect(batang3, catAksenIsi);
        canvas.drawRRect(batang3, catGaris);
        // Garis panah naik
        final jalur = Path()
          ..moveTo(cx - r * 0.72, cy - r * 0.1)
          ..lineTo(cx - r * 0.02, cy - r * 0.45)
          ..lineTo(cx + r * 0.68, cy - r * 0.85);
        canvas.drawPath(jalur, catGarisAksen);
      case JenisIlustrasiFunda.kompas:
        canvas.drawCircle(Offset(cx, cy), r * 0.88, catIsiLembut);
        canvas.drawCircle(Offset(cx, cy), r * 0.88, catGaris);
        final jarumAtas = Path()
          ..moveTo(cx, cy - r * 0.56)
          ..lineTo(cx + r * 0.2, cy)
          ..lineTo(cx - r * 0.2, cy)
          ..close();
        final jarumBawah = Path()
          ..moveTo(cx, cy + r * 0.56)
          ..lineTo(cx + r * 0.2, cy)
          ..lineTo(cx - r * 0.2, cy)
          ..close();
        canvas.drawPath(jarumAtas, catAksenIsi);
        canvas.drawPath(jarumBawah, catAksenLembut);
        canvas.drawPath(jarumAtas, catGaris);
        canvas.drawCircle(Offset(cx, cy), r * 0.1, catIsiLembut);
      case JenisIlustrasiFunda.rantaiKalender:
        final kalender = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + r * 0.08),
            width: r * 1.48,
            height: r * 1.32,
          ),
          Radius.circular(r * 0.24),
        );
        canvas.drawRRect(kalender, catIsiLembut);
        canvas.drawRRect(kalender, catGaris);
        final pitaAtas = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.74, cy - r * 0.58, r * 1.48, r * 0.36),
          Radius.circular(r * 0.18),
        );
        canvas.drawRRect(pitaAtas, catAksenIsi);
        canvas.drawLine(
          Offset(cx - r * 0.38, cy - r * 0.72),
          Offset(cx - r * 0.38, cy - r * 0.42),
          catGaris,
        );
        canvas.drawLine(
          Offset(cx + r * 0.38, cy - r * 0.72),
          Offset(cx + r * 0.38, cy - r * 0.42),
          catGaris,
        );
        canvas.drawCircle(
          Offset(cx - r * 0.28, cy + r * 0.18),
          r * 0.12,
          catAksenLembut,
        );
        canvas.drawCircle(
          Offset(cx + r * 0.24, cy + r * 0.18),
          r * 0.12,
          catAksenIsi,
        );
      case JenisIlustrasiFunda.pikiran:
        canvas.drawCircle(Offset(cx - r * 0.24, cy), r * 0.62, catIsiLembut);
        canvas.drawCircle(Offset(cx - r * 0.24, cy), r * 0.62, catGaris);
        canvas.drawCircle(Offset(cx + r * 0.26, cy), r * 0.62, catAksenLembut);
        canvas.drawCircle(Offset(cx + r * 0.26, cy), r * 0.62, catGarisAksen);
        canvas.drawCircle(Offset(cx, cy), r * 0.16, catAksenIsi);
      case JenisIlustrasiFunda.pajak:
        final kertas = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: r * 1.34,
            height: r * 1.62,
          ),
          Radius.circular(r * 0.2),
        );
        canvas.drawRRect(kertas, catIsiLembut);
        canvas.drawRRect(kertas, catGaris);
        canvas.drawLine(
          Offset(cx - r * 0.38, cy - r * 0.36),
          Offset(cx + r * 0.38, cy - r * 0.36),
          catGaris,
        );
        canvas.drawLine(
          Offset(cx - r * 0.38, cy - r * 0.04),
          Offset(cx + r * 0.22, cy - r * 0.04),
          catGarisAksen,
        );
        canvas.drawCircle(
          Offset(cx + r * 0.2, cy + r * 0.42),
          r * 0.24,
          catAksenIsi,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _PelukisIlustrasiGeometris oldDelegate) {
    return oldDelegate.jenis != jenis || oldDelegate.warnaAksen != warnaAksen;
  }
}
