import 'package:flutter/material.dart';
import '../tema/token.dart';

/// Varian teks tipografi Funda.
enum VarianTeksFunda {
  angkaBesar,
  judulLayar,
  judulBagian,
  isi,
  isiKecil,
  label,
  catatan,
}

/// Widget teks standar aplikasi Funda yang terikat ke token tipografi.
class TeksFunda extends StatelessWidget {
  const TeksFunda(
    this.teks, {
    super.key,
    this.varian = VarianTeksFunda.isi,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  });

  /// Pintasan pembuat untuk angka besar.
  const TeksFunda.angkaBesar(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = true,
  }) : varian = VarianTeksFunda.angkaBesar;

  /// Pintasan pembuat untuk judul layar.
  const TeksFunda.judulLayar(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  }) : varian = VarianTeksFunda.judulLayar;

  /// Pintasan pembuat untuk judul bagian.
  const TeksFunda.judulBagian(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  }) : varian = VarianTeksFunda.judulBagian;

  /// Pintasan pembuat untuk isi teks biasa.
  const TeksFunda.isi(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  }) : varian = VarianTeksFunda.isi;

  /// Pintasan pembuat untuk isi kecil / keterangan.
  const TeksFunda.isiKecil(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  }) : varian = VarianTeksFunda.isiKecil;

  /// Pintasan pembuat untuk label / teks tombol.
  const TeksFunda.label(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  }) : varian = VarianTeksFunda.label;

  /// Pintasan pembuat untuk catatan kaki.
  const TeksFunda.catatan(
    this.teks, {
    super.key,
    this.warna,
    this.rataTeks,
    this.maksimalBaris,
    this.luapan,
    this.angkaTabular = false,
  }) : varian = VarianTeksFunda.catatan;

  final String teks;
  final VarianTeksFunda varian;
  final Color? warna;
  final TextAlign? rataTeks;
  final int? maksimalBaris;
  final TextOverflow? luapan;
  final bool angkaTabular;

  TextStyle _ambilGaya() {
    final gayaDasar = switch (varian) {
      VarianTeksFunda.angkaBesar => TipografiFunda.angkaBesar,
      VarianTeksFunda.judulLayar => TipografiFunda.judulLayar,
      VarianTeksFunda.judulBagian => TipografiFunda.judulBagian,
      VarianTeksFunda.isi => TipografiFunda.isi,
      VarianTeksFunda.isiKecil => TipografiFunda.isiKecil,
      VarianTeksFunda.label => TipografiFunda.label,
      VarianTeksFunda.catatan => TipografiFunda.catatan,
    };

    return gayaDasar.copyWith(
      color: warna,
      fontFeatures: angkaTabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      teks,
      style: _ambilGaya(),
      textAlign: rataTeks,
      maxLines: maksimalBaris,
      overflow: luapan,
    );
  }
}
