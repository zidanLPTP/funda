import 'package:flutter/services.dart';

/// Utilitas getaran haptic mikro untuk pengalaman taktil pengguna yang menyenangkan.
abstract final class UtilHaptic {
  /// Ketukan seleksi ringan (pemilihan tab, opsi, chip)
  static void pilih() {
    HapticFeedback.selectionClick();
  }

  /// Ketukan fisik ringan (tekan tombol biasa)
  static void ringan() {
    HapticFeedback.lightImpact();
  }

  /// Ketukan fisik sedang (simpan data, centang tugas)
  static void sedang() {
    HapticFeedback.mediumImpact();
  }

  /// Getaran sukses (selesai pelajaran / simpan transaksi)
  static void sukses() {
    HapticFeedback.mediumImpact();
  }

  /// Getaran perayaan besar (lulus kuis / capai target)
  static void suksesBesar() {
    HapticFeedback.heavyImpact();
  }
}
