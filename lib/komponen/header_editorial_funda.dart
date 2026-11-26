import 'package:flutter/material.dart';
import '../tema/token.dart';
import 'ilustrasi_funda.dart';
import 'teks_funda.dart';

/// Tombol kembali bulat bergaya editorial dengan target sentuh >= 48x48dp
/// (lingkaran visual 42x42dp di dalam area sentuh 48x48dp sesuai styleguide).
class TombolKembaliEditorial extends StatelessWidget {
  const TombolKembaliEditorial({super.key, this.padaTekan});

  final VoidCallback? padaTekan;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali',
      child: Material(
        color: WarnaFunda.transparan,
        child: InkWell(
          key: const Key('tombol_kembali_editorial'),
          onTap: padaTekan ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(SudutFunda.pil),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: WarnaFunda.permukaan,
                  shape: BoxShape.circle,
                  border: Border.all(color: WarnaFunda.garis, width: 1.0),
                ),
                child: const Center(
                  child: IkonUiFunda(
                    pathAset: AsetIkonUiFunda.arrowLeft,
                    ukuran: 18,
                    warna: WarnaFunda.teks,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header sub-layar bergaya editorial bersih: tombol kembali >= 48x48dp, judul,
/// dan slot aksi kanan opsional yang membungkus aman pada skala teks besar.
class HeaderSubLayarEditorial extends StatelessWidget {
  const HeaderSubLayarEditorial({
    super.key,
    required this.judul,
    this.subjudul,
    this.aksiKanan = const [],
    this.padaKembali,
    this.tampilkanKembali = true,
  });

  final String judul;
  final String? subjudul;
  final List<Widget> aksiKanan;
  final VoidCallback? padaKembali;
  final bool tampilkanKembali;

  @override
  Widget build(BuildContext context) {
    final isTeksBesar = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final tampilTombolKembali = tampilkanKembali;

    final blokJudul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TeksFunda.judulBagian(judul),
        if (subjudul != null) ...[
          const SizedBox(height: 2),
          TeksFunda.catatan(subjudul!, warna: WarnaFunda.teksRedup),
        ],
      ],
    );

    if (isTeksBesar && aksiKanan.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (tampilTombolKembali) ...[
                TombolKembaliEditorial(padaTekan: padaKembali),
                const SizedBox(width: SpasiFunda.s),
              ],
              Expanded(child: blokJudul),
            ],
          ),
          const SizedBox(height: SpasiFunda.s),
          Wrap(
            spacing: SpasiFunda.s,
            runSpacing: SpasiFunda.s,
            children: aksiKanan,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (tampilTombolKembali) ...[
          TombolKembaliEditorial(padaTekan: padaKembali),
          const SizedBox(width: SpasiFunda.s),
        ],
        Expanded(child: blokJudul),
        if (aksiKanan.isNotEmpty) ...[
          const SizedBox(width: SpasiFunda.s),
          Row(mainAxisSize: MainAxisSize.min, children: aksiKanan),
        ],
      ],
    );
  }
}

/// Tombol pil aksi header berborder 1px dengan tinggi minimal 48dp untuk aksesibilitas.
class TombolPilHeaderEditorial extends StatelessWidget {
  const TombolPilHeaderEditorial({
    super.key,
    required this.teks,
    required this.padaTekan,
    this.ikon,
    this.warnaTeks = WarnaFunda.teks,
    this.warnaLatar = WarnaFunda.permukaan,
    this.warnaBatas = WarnaFunda.garis,
  });

  final String teks;
  final VoidCallback padaTekan;
  final IconData? ikon;
  final Color warnaTeks;
  final Color warnaLatar;
  final Color warnaBatas;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: teks,
      child: Material(
        color: WarnaFunda.transparan,
        child: InkWell(
          onTap: padaTekan,
          borderRadius: BorderRadius.circular(SudutFunda.pil),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: SpasiFunda.m,
              vertical: SpasiFunda.s,
            ),
            decoration: BoxDecoration(
              color: warnaLatar,
              borderRadius: BorderRadius.circular(SudutFunda.pil),
              border: Border.all(color: warnaBatas, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ikon != null) ...[
                  ikonUiDariLucide(ikon!, ukuran: 16, warna: warnaTeks),
                  const SizedBox(width: SpasiFunda.xs),
                ],
                Flexible(
                  child: Text(
                    teks,
                    style: TextStyle(
                      fontFamily: TipografiFunda.namaKeluargaFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: warnaTeks,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
