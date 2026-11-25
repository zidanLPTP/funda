import 'package:flutter/material.dart';
import '../tema/token.dart';

/// Memetakan kunci nama token tint ke objek Color.
Color ambilWarnaTint(String kunci) {
  return switch (kunci) {
    'tintHijau' => WarnaFunda.tintHijau,
    'tintBiru' => WarnaFunda.tintBiru,
    'tintUngu' => WarnaFunda.tintUngu,
    'tintAmber' => WarnaFunda.tintAmber,
    'tintMawar' => WarnaFunda.tintMawar,
    'tintNetral' => WarnaFunda.tintNetral,
    _ => WarnaFunda.tintNetral,
  };
}

/// Memetakan kunci nama token tint ke warna aksen ikon yang kontras dan serasi.
Color ambilWarnaAksenTint(String kunci) {
  return switch (kunci) {
    'tintHijau' => WarnaFunda.utama,
    'tintBiru' => WarnaFunda.sifatKebutuhan,
    'tintUngu' => WarnaFunda.sifatKeinginan,
    'tintAmber' => WarnaFunda.sifatUtang,
    'tintMawar' => WarnaFunda.pengeluaran,
    _ => WarnaFunda.utama,
  };
}

/// Memetakan kunci nama token tint ke warna batas kartu yang serasi.
Color ambilWarnaBatasTint(String kunci) {
  return switch (kunci) {
    'tintHijau' => WarnaFunda.batasHijau,
    'tintBiru' => WarnaFunda.batasBiru,
    'tintUngu' => WarnaFunda.batasUngu,
    'tintAmber' => WarnaFunda.batasAmber,
    'tintMawar' => WarnaFunda.batasMawar,
    _ => WarnaFunda.batasNetral,
  };
}

/// Daftar pilihan tint untuk pemilihan warna dompet.
const List<Map<String, dynamic>> daftarPilihanTint = [
  {'kunci': 'tintHijau', 'label': 'Hijau', 'warna': WarnaFunda.tintHijau},
  {'kunci': 'tintBiru', 'label': 'Biru', 'warna': WarnaFunda.tintBiru},
  {'kunci': 'tintUngu', 'label': 'Ungu', 'warna': WarnaFunda.tintUngu},
  {'kunci': 'tintAmber', 'label': 'Amber', 'warna': WarnaFunda.tintAmber},
  {'kunci': 'tintNetral', 'label': 'Netral', 'warna': WarnaFunda.tintNetral},
];
