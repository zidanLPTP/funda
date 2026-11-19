import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pengatur animasi pengujian.
/// Ketika true (misalnya pada pengujian widget), indikator menggunakan nilai statis
/// agar tidak memicu animasi berkelanjutan yang menyebabkan pumpAndSettle menggantung.
final penyediaTanpaAnimasi = Provider<bool>((ref) => false);

/// Komponen indikator memuat terpusat Funda.
///
/// Seluruh layar dan komponen wajib menggunakan komponen ini alih-alih
/// memanggil CircularProgressIndicator atau LinearProgressIndicator secara langsung.
class IndikatorMemuat extends StatelessWidget {
  final Color? warna;
  final Color? warnaLatar;
  final double? nilai;
  final double ukuran;
  final double ketebalan;
  final bool garis;
  final BorderRadius? sudut;

  const IndikatorMemuat({
    super.key,
    this.warna,
    this.warnaLatar,
    this.nilai,
    this.ukuran = 36.0,
    this.ketebalan = 4.0,
  })  : garis = false,
        sudut = null;

  const IndikatorMemuat.lingkar({
    super.key,
    this.warna,
    this.warnaLatar,
    this.nilai,
    this.ukuran = 36.0,
    this.ketebalan = 4.0,
  })  : garis = false,
        sudut = null;

  const IndikatorMemuat.garis({
    super.key,
    this.warna,
    this.warnaLatar,
    this.nilai,
    double? tinggi,
    this.sudut,
  })  : garis = true,
        ukuran = tinggi ?? 4.0,
        ketebalan = 4.0;

  @override
  Widget build(BuildContext context) {
    bool tanpaAnimasi = false;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      tanpaAnimasi = container.read(penyediaTanpaAnimasi);
    } catch (_) {
      tanpaAnimasi = false;
    }

    if (garis) {
      return LinearProgressIndicator(
        value: tanpaAnimasi ? (nilai ?? 0.5) : nilai,
        color: warna,
        backgroundColor: warnaLatar,
        borderRadius: sudut,
        minHeight: ukuran,
      );
    }

    final double? effectiveValue = tanpaAnimasi ? (nilai ?? 0.5) : nilai;

    return SizedBox(
      width: ukuran,
      height: ukuran,
      child: CircularProgressIndicator(
        value: effectiveValue,
        color: warna,
        backgroundColor: warnaLatar,
        strokeWidth: ketebalan,
      ),
    );
  }
}
