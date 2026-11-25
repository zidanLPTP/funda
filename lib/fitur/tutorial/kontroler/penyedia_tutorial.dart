import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/penyedia_basis_data.dart';

/// Kunci pengaturan penyimpanan status tutorial interaktif Beranda.
const String kunciTutorialBerandaSelesai = 'tutorial_beranda_selesai';

/// Penampung GlobalKey target sorotan tutorial Beranda (terisolasi per ProviderScope).
class KunciTargetTutorialBeranda {
  final GlobalKey ringkasanKeuangan = GlobalKey(
    debugLabel: 'sorotan_ringkasan_keuangan',
  );
  final GlobalKey tabCatatan = GlobalKey(debugLabel: 'sorotan_tab_catatan');
  final GlobalKey tabBelajar = GlobalKey(debugLabel: 'sorotan_tab_belajar');
  final GlobalKey tabLainnya = GlobalKey(debugLabel: 'sorotan_tab_lainnya');
}

final penyediaKunciTutorialBeranda = Provider<KunciTargetTutorialBeranda>((
  ref,
) {
  return KunciTargetTutorialBeranda();
});

/// Notifier reaktif penentu apakah Lapisan Tutorial Beranda perlu ditampilkan.
class TutorialBerandaNotifier extends Notifier<bool> {
  @override
  bool build() {
    _muatStatusAwal();
    return false;
  }

  Future<void> _muatStatusAwal() async {
    try {
      final db = ref.read(penyediaBasisData);
      final nilai = await db.bacaPengaturan(kunciTutorialBerandaSelesai);
      if (!ref.mounted) return;
      state = nilai != 'true';
    } catch (_) {
      // Aman pada environment uji tanpa plugin penyimpanan platform
    }
  }

  /// Menandai tutorial sudah dilihat dan menyimpannya ke tabel_pengaturan.
  Future<void> selesaikanTutorial() async {
    state = false;
    try {
      final db = ref.read(penyediaBasisData);
      await db.simpanPengaturan(kunciTutorialBerandaSelesai, 'true');
    } catch (_) {}
  }

  /// Mengaktifkan kembali tutorial Beranda dari awal atas permintaan pengguna.
  Future<void> ulangiTutorial() async {
    try {
      final db = ref.read(penyediaBasisData);
      await db.simpanPengaturan(kunciTutorialBerandaSelesai, 'false');
    } catch (_) {}
    state = true;
  }
}

final penyediaTutorialBeranda = NotifierProvider<TutorialBerandaNotifier, bool>(
  TutorialBerandaNotifier.new,
);
