import 'package:flutter/material.dart';
import '../tema/token.dart';
import '../util/haptic.dart';
import 'indikator_memuat.dart';

/// Jenis varian tampilan tombol Funda.
enum VarianTombolFunda { primer, sekunder, teks, pilGelap }

/// Tombol standar aplikasi Funda dengan tinggi minimal 48dp dan bentuk pil.
class TombolFunda extends StatelessWidget {
  const TombolFunda({
    super.key,
    required this.teks,
    this.padaTekan,
    this.varian = VarianTombolFunda.primer,
    this.memuat = false,
    this.ikon,
    this.lebarPenuh = false,
    this.labelAkses,
  });

  /// Pintasan untuk tombol primer.
  const TombolFunda.primer({
    super.key,
    required this.teks,
    this.padaTekan,
    this.memuat = false,
    this.ikon,
    this.lebarPenuh = false,
    this.labelAkses,
  }) : varian = VarianTombolFunda.primer;

  /// Pintasan untuk tombol sekunder (garis luar).
  const TombolFunda.sekunder({
    super.key,
    required this.teks,
    this.padaTekan,
    this.memuat = false,
    this.ikon,
    this.lebarPenuh = false,
    this.labelAkses,
  }) : varian = VarianTombolFunda.sekunder;

  /// Pintasan untuk tombol teks tanpa latar.
  const TombolFunda.teks({
    super.key,
    required this.teks,
    this.padaTekan,
    this.memuat = false,
    this.ikon,
    this.lebarPenuh = false,
    this.labelAkses,
  }) : varian = VarianTombolFunda.teks;

  /// Pintasan untuk tombol pil warna hijau hutan gelap kontras tinggi.
  const TombolFunda.pilGelap({
    super.key,
    required this.teks,
    this.padaTekan,
    this.memuat = false,
    this.ikon,
    this.lebarPenuh = true,
    this.labelAkses,
  }) : varian = VarianTombolFunda.pilGelap;

  final String teks;
  final VoidCallback? padaTekan;
  final VarianTombolFunda varian;
  final bool memuat;
  final Widget? ikon;
  final bool lebarPenuh;
  final String? labelAkses;

  bool get _aktif => padaTekan != null && !memuat;

  VoidCallback? get _padaTekanDenganHaptic {
    if (!_aktif || padaTekan == null) return null;
    return () {
      UtilHaptic.ringan();
      padaTekan!();
    };
  }

  @override
  Widget build(BuildContext context) {
    final isiKonten = _bangunIsi();

    Widget tombol = switch (varian) {
      VarianTombolFunda.primer => _bangunTombolPrimer(isiKonten),
      VarianTombolFunda.sekunder => _bangunTombolSekunder(isiKonten),
      VarianTombolFunda.teks => _bangunTombolTeks(isiKonten),
      VarianTombolFunda.pilGelap => _bangunTombolPilGelap(isiKonten),
    };

    if (lebarPenuh) {
      tombol = SizedBox(width: double.infinity, child: tombol);
    }

    return Semantics(
      button: true,
      enabled: _aktif,
      label: labelAkses ?? teks,
      child: tombol,
    );
  }

  Widget _bangunIsi() {
    if (memuat) {
      final warnaIndikator = switch (varian) {
        VarianTombolFunda.primer ||
        VarianTombolFunda.pilGelap => WarnaFunda.putih,
        VarianTombolFunda.sekunder => WarnaFunda.utama,
        VarianTombolFunda.teks => WarnaFunda.utama,
      };

      return IndikatorMemuat(ukuran: 20, ketebalan: 2.5, warna: warnaIndikator);
    }

    final warnaTeks = switch (varian) {
      VarianTombolFunda.primer || VarianTombolFunda.pilGelap =>
        _aktif ? WarnaFunda.teksPutih : WarnaFunda.teksRedup,
      VarianTombolFunda.sekunder =>
        _aktif ? WarnaFunda.utama : WarnaFunda.teksRedup,
      VarianTombolFunda.teks =>
        _aktif ? WarnaFunda.utama : WarnaFunda.teksRedup,
    };

    final widgetTeks = Text(
      teks,
      style: TipografiFunda.label.copyWith(color: warnaTeks),
      textAlign: TextAlign.center,
    );

    if (ikon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ikon!,
          const SizedBox(width: SpasiFunda.s),
          Flexible(child: widgetTeks),
        ],
      );
    }

    return widgetTeks;
  }

  Widget _bangunTombolPrimer(Widget isi) {
    return FilledButton(
      onPressed: _aktif ? _padaTekanDenganHaptic : null,
      style: FilledButton.styleFrom(
        backgroundColor: WarnaFunda.utama,
        foregroundColor: WarnaFunda.teksPutih,
        disabledBackgroundColor: WarnaFunda.garis,
        disabledForegroundColor: WarnaFunda.teksRedup,
        minimumSize: const Size(0, SpasiFunda.xxxl),
        padding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.xl,
          vertical: SpasiFunda.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SudutFunda.pil),
        ),
        elevation: 0,
      ),
      child: isi,
    );
  }

  Widget _bangunTombolSekunder(Widget isi) {
    return OutlinedButton(
      onPressed: _aktif ? _padaTekanDenganHaptic : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: WarnaFunda.utama,
        disabledForegroundColor: WarnaFunda.teksRedup,
        side: BorderSide(
          color: _aktif ? WarnaFunda.utama : WarnaFunda.garis,
          width: 1.5,
        ),
        minimumSize: const Size(0, SpasiFunda.xxxl),
        padding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.xl,
          vertical: SpasiFunda.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SudutFunda.pil),
        ),
      ),
      child: isi,
    );
  }

  Widget _bangunTombolTeks(Widget isi) {
    return TextButton(
      onPressed: _aktif ? _padaTekanDenganHaptic : null,
      style: TextButton.styleFrom(
        foregroundColor: WarnaFunda.utama,
        disabledForegroundColor: WarnaFunda.teksRedup,
        minimumSize: const Size(0, SpasiFunda.xxxl),
        padding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.l,
          vertical: SpasiFunda.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SudutFunda.pil),
        ),
      ),
      child: isi,
    );
  }

  Widget _bangunTombolPilGelap(Widget isi) {
    return FilledButton(
      onPressed: _aktif ? _padaTekanDenganHaptic : null,
      style: FilledButton.styleFrom(
        backgroundColor: WarnaFunda.tombolGelap,
        foregroundColor: WarnaFunda.teksPutih,
        disabledBackgroundColor: WarnaFunda.garis,
        disabledForegroundColor: WarnaFunda.teksRedup,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: SpasiFunda.xl,
          vertical: SpasiFunda.m,
        ),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      child: isi,
    );
  }
}
