import 'package:flutter/material.dart';
import '../tema/token.dart';
import '../util/format_rupiah.dart';

/// Widget animasi angka integer (Rupiah / persen) yang bertransisi halus saat nilai berubah.
class TeksAngkaAnimasi extends StatelessWidget {
  final int nilai;
  final TextStyle? gaya;
  final Duration durasi;
  final String Function(int nilai)? pemformat;
  final TextAlign rataTeks;

  const TeksAngkaAnimasi({
    super.key,
    required this.nilai,
    this.gaya,
    this.durasi = const Duration(milliseconds: 500),
    this.pemformat,
    this.rataTeks = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: nilai.toDouble()),
      duration: durasi,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final angkaBulat = val.round();
        final teks = pemformat != null
            ? pemformat!(angkaBulat)
            : formatRupiah(angkaBulat);
        return Text(teks, style: gaya, textAlign: rataTeks);
      },
    );
  }
}

/// Bilah kemajuan (Progress Bar) yang menganimasikan lebar pengisian secara mulus.
class BilahKemajuanAnimasi extends StatelessWidget {
  final int persen;
  final Color warna;
  final Color warnaLatar;
  final double tinggi;
  final double radius;
  final Duration durasi;

  const BilahKemajuanAnimasi({
    super.key,
    required this.persen,
    this.warna = WarnaFunda.utama,
    this.warnaLatar = WarnaFunda.garis,
    this.tinggi = 8,
    this.radius = SudutFunda.pil,
    this.durasi = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = persen.clamp(0, 100);
    final targetFraction = clamped / 100.0;

    return Container(
      height: tinggi,
      width: double.infinity,
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: targetFraction),
            duration: durasi,
            curve: Curves.easeOutCubic,
            builder: (context, fraction, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: totalWidth * fraction,
                  height: tinggi,
                  decoration: BoxDecoration(
                    color: warna,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
