import 'package:flutter/material.dart';

/// Token warna Funda sesuai panduan gaya (styleguide.md).
/// Semua token menggunakan penamaan bahasa Indonesia.
abstract final class WarnaFunda {
  // Palet dasar
  static const utama = Color(0xFF0F766E);
  static const utamaGelap = Color(0xFF115E59);
  static const utamaTipis = Color(0xFFCCFBF1);
  static const latar = Color(0xFFF8FAF9);
  static const permukaan = Color(0xFFFFFFFF);
  static const putih = Color(0xFFFFFFFF);
  static const teksPutih = Color(0xFFFFFFFF);
  static const teksPutihRedup = Color(0xB3FFFFFF);
  static const garis = Color(0xFFE2E8E6);
  static const teks = Color(0xFF0F1F1D);
  static const teksRedup = Color(0xFF5B6B68);
  static const aksen = Color(0xFFF59E0B);

  // Warna semantik / makna
  static const pemasukan = Color(0xFF15803D);
  static const pengeluaran = Color(0xFFC2410C);
  static const bahaya = Color(0xFFB91C1C);
  static const peringatan = Color(0xFFB45309);
  static const sukses = Color(0xFF15803D);
  static const info = Color(0xFF1D4ED8);

  // Warna sifat pengeluaran (inti konsep aplikasi)
  static const sifatKebutuhan = Color(0xFF2563EB);
  static const sifatKeinginan = Color(0xFF7C3AED);
  static const sifatTabungan = Color(0xFF0F766E);
  static const sifatUtang = Color(0xFFB45309);

  // Tint latar petak bento
  static const tintHijau = Color(0xFFE6F4F1);
  static const tintBiru = Color(0xFFE8F0FE);
  static const tintUngu = Color(0xFFF1EBFD);
  static const tintAmber = Color(0xFFFEF3E2);
  static const tintNetral = Color(0xFFF1F5F4);
  static const tintMawar = Color(0xFFFCE7F3);

  // Utilitas & Kartu Khusus
  static const transparan = Colors.transparent;
  static const hitam = Color(0xFF000000);
  static const bayangan = Color(0x0A000000);
  static const tintLaporan = Color(0xFFEBF6FA);
  static const garisLaporan = Color(0xFFC7E5F0);
  static const teksLaporan = Color(0xFF006684);
}

/// Token spasi Funda berbasis grid 4dp.
abstract final class SpasiFunda {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Jarak standar antar petak pada tata letak bento
  static const double jarakPetak = 12;

  /// Margin standar tepi layar
  static const double marginLayar = 16;

  /// Margin untuk layar membaca pelajaran
  static const double marginPelajaran = 24;
}

/// Token kelengkungan sudut (border radius).
abstract final class SudutFunda {
  static const double kecil = 8;
  static const double kartu = 16;
  static const double petak = 24;
  static const double lembar = 28;
  static const double pil = 999;
}

/// Token tipografi Funda berbasis Plus Jakarta Sans.
abstract final class TipografiFunda {
  static const String namaKeluargaFont = 'PlusJakartaSans';

  static const angkaBesar = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: WarnaFunda.teks,
  );

  static const judulLayar = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: WarnaFunda.teks,
  );

  static const judulBagian = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
    color: WarnaFunda.teks,
  );

  static const isi = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: WarnaFunda.teks,
  );

  static const isiKecil = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: WarnaFunda.teksRedup,
  );

  static const label = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    color: WarnaFunda.teks,
  );

  static const catatan = TextStyle(
    fontFamily: namaKeluargaFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: WarnaFunda.teksRedup,
  );
}
