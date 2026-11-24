import 'package:flutter/services.dart';

/// Utilitas getaran haptic mikro untuk pengalaman taktil pengguna yang menyenangkan.
abstract final class UtilHaptic {
  /// Status sakelar preferensi pengguna terhadap getaran haptik
  static bool aktif = true;

  /// Ketukan seleksi ringan (pemilihan tab, opsi, chip)
  static void pilih() {
    if (!aktif) return;
    HapticFeedback.selectionClick();
  }

  /// Ketukan fisik ringan (tekan tombol biasa)
  static void ringan() {
    if (!aktif) return;
    HapticFeedback.lightImpact();
  }

  /// Ketukan fisik sedang (simpan data, centang tugas)
  static void sedang() {
    if (!aktif) return;
    HapticFeedback.mediumImpact();
  }

  /// Getaran sukses (selesai pelajaran / simpan transaksi)
  static void sukses() {
    if (!aktif) return;
    HapticFeedback.mediumImpact();
  }

  /// Getaran perayaan besar (lulus kuis / capai target)
  static void suksesBesar() {
    if (!aktif) return;
    HapticFeedback.heavyImpact();
  }
}
