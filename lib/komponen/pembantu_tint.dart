import 'package:flutter/material.dart';
import '../tema/token.dart';

/// Memetakan kunci nama token tint ke objek Color.
Color ambilWarnaTint(String kunci) {
  return switch (kunci) {
    'tintHijau' => WarnaFunda.tintHijau,
    'tintBiru' => WarnaFunda.tintBiru,
    'tintUngu' => WarnaFunda.tintUngu,
    'tintAmber' => WarnaFunda.tintAmber,
    'tintNetral' => WarnaFunda.tintNetral,
    _ => WarnaFunda.tintNetral,
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
