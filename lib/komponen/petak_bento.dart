import 'package:flutter/material.dart';
import '../tema/token.dart';

/// Pilihan warna tint latar untuk Petak Bento.
enum TintPetakBento {
  hijau(WarnaFunda.tintHijau),
  biru(WarnaFunda.tintBiru),
  ungu(WarnaFunda.tintUngu),
  amber(WarnaFunda.tintAmber),
  netral(WarnaFunda.tintNetral),
  mawar(WarnaFunda.tintMawar),
  putih(WarnaFunda.permukaan);

  const TintPetakBento(this.warna);
  final Color warna;
}

/// Ukuran kisi petak bento.
enum UkuranPetakBento {
  /// Ukuran 1x1 (setengah lebar layar pada grid 2 kolom)
  petak1x1,

  /// Ukuran 2x1 (lebar penuh 2 kolom)
  petak2x1,
}

/// Komponen Petak Bento dengan sudut membulat 24dp, latar tint pastel,
/// dan efek mikro-animasi saat ditekan jika interaktif.
class PetakBento extends StatefulWidget {
  const PetakBento({
    super.key,
    required this.anak,
    this.ukuran = UkuranPetakBento.petak2x1,
    this.tint = TintPetakBento.netral,
    this.warnaKustom,
    this.padaKetuk,
    this.labelAkses,
    this.padding,
    this.tinggi,
  });

  /// Pintasan petak 1x1.
  const PetakBento.ukuran1x1({
    super.key,
    required this.anak,
    this.tint = TintPetakBento.netral,
    this.warnaKustom,
    this.padaKetuk,
    this.labelAkses,
    this.padding,
    this.tinggi,
  }) : ukuran = UkuranPetakBento.petak1x1;

  /// Pintasan petak 2x1 (lebar penuh).
  const PetakBento.ukuran2x1({
    super.key,
    required this.anak,
    this.tint = TintPetakBento.netral,
    this.warnaKustom,
    this.padaKetuk,
    this.labelAkses,
    this.padding,
    this.tinggi,
  }) : ukuran = UkuranPetakBento.petak2x1;

  final Widget anak;
  final UkuranPetakBento ukuran;
  final TintPetakBento tint;
  final Color? warnaKustom;
  final VoidCallback? padaKetuk;
  final String? labelAkses;
  final EdgeInsetsGeometry? padding;
  final double? tinggi;

  @override
  State<PetakBento> createState() => _PetakBentoState();
}

class _PetakBentoState extends State<PetakBento> {
  bool _sedangDitekan = false;

  void _aturTekan(bool nilai) {
    if (widget.padaKetuk == null) return;
    setState(() => _sedangDitekan = nilai);
  }

  @override
  Widget build(BuildContext context) {
    final warnaLatar = widget.warnaKustom ?? widget.tint.warna;
    final paddingDalam = widget.padding ?? const EdgeInsets.all(SpasiFunda.l);

    final dekorasi = BoxDecoration(
      color: warnaLatar,
      borderRadius: BorderRadius.circular(SudutFunda.petak),
      border: Border.all(color: WarnaFunda.garis, width: 1),
    );

    Widget konten = AnimatedScale(
      scale: _sedangDitekan ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        height: widget.tinggi,
        padding: paddingDalam,
        decoration: dekorasi,
        child: widget.anak,
      ),
    );

    if (widget.padaKetuk != null) {
      konten = GestureDetector(
        onTapDown: (_) => _aturTekan(true),
        onTapUp: (_) => _aturTekan(false),
        onTapCancel: () => _aturTekan(false),
        onTap: widget.padaKetuk,
        behavior: HitTestBehavior.opaque,
        child: konten,
      );
    }

    return Semantics(
      button: widget.padaKetuk != null,
      label: widget.labelAkses,
      child: konten,
    );
  }
}
