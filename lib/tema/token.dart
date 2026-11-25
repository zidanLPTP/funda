import 'package:flutter/material.dart';

/// Token warna Funda sesuai panduan gaya (styleguide.md).
/// Semua token menggunakan penamaan bahasa Indonesia.
abstract final class WarnaFunda {
  // Palet dasar
  static const utama = Color(0xFF0F766E);
  static const utamaGelap = Color(0xFF0E5133);
  static const utamaTipis = Color(0xFFBDF5E8);
  static const latar = Color(0xFFF6FAF8);
  static const permukaan = Color(0xFFFFFFFF);
  static const putih = Color(0xFFFFFFFF);
  static const teksPutih = Color(0xFFFFFFFF);
  static const teksPutihRedup = Color(0xB3FFFFFF);
  static const garis = Color(0xFFD8E3DF);
  static const teks = Color(0xFF0F1F1D);
  static const teksRedup = Color(0xFF475855);
  static const aksen = Color(0xFFF59E0B);

  // Warna semantik / makna (tegas, ramah, tetap menjaga kontras >= 4.5:1)
  static const pemasukan = Color(0xFF047857);
  static const pengeluaran = Color(0xFFD9480F);
  static const bahaya = Color(0xFFB91C1C);
  static const peringatan = Color(0xFFB45309);
  static const sukses = Color(0xFF047857);
  static const info = Color(0xFF1D4ED8);

  // Warna sifat pengeluaran (inti konsep aplikasi)
  static const sifatKebutuhan = Color(0xFF2563EB);
  static const sifatKeinginan = Color(0xFF7C3AED);
  static const sifatTabungan = Color(0xFF0F766E);
  static const sifatUtang = Color(0xFFB45309);

  // Tint latar petak bento (pastel lebih hidup & jenuh, kontras teks >= 4.5:1)
  static const tintHijau = Color(0xFFD5F5EA);
  static const batasHijau = Color(0xFFA7E8D4);
  static const tintBiru = Color(0xFFDBEAFE);
  static const batasBiru = Color(0xFFBFDBFE);
  static const tintUngu = Color(0xFFEDE2FE);
  static const batasUngu = Color(0xFFDDD6FE);
  static const tintAmber = Color(0xFFFEF0C7);
  static const batasAmber = Color(0xFFFDE68A);
  static const tintNetral = Color(0xFFEEF4F2);
  static const batasNetral = Color(0xFFDCE7E3);
  static const tintMawar = Color(0xFFFCE0EC);
  static const batasMawar = Color(0xFFFBCFE8);

  // Utilitas & Kartu Khusus
  static const transparan = Colors.transparent;
  static const hitam = Color(0xFF000000);
  static const bayangan = Color(0x0A000000);
  static const bayanganKartu = Color(0x120F1F1D);
  static const tintLaporan = Color(0xFFE0F2FE);
  static const garisLaporan = Color(0xFFBAE6FD);
  static const teksLaporan = Color(0xFF0369A1);
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
