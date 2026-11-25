import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../fitur/tutorial/kontroler/penyedia_tutorial.dart';
import '../fitur/tutorial/tampilan/lapisan_tutorial_beranda.dart';
import '../komponen/ilustrasi_funda.dart';
import '../tema/token.dart';
import '../util/haptic.dart';

/// Pembungkus bilah navigasi bawah (Bottom Navigation Bar) Funda.
class PembungkusBilahNavigasi extends ConsumerWidget {
  const PembungkusBilahNavigasi({super.key, required this.cangkangNavigasi});

  final StatefulNavigationShell cangkangNavigasi;

  void _padaPilihTab(int indeks) {
    if (indeks != cangkangNavigasi.currentIndex) {
      UtilHaptic.pilih();
    }
    cangkangNavigasi.goBranch(
      indeks,
      initialLocation: indeks == cangkangNavigasi.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kunciTutorial = ref.watch(penyediaKunciTutorialBeranda);
    final tutorialAktif = ref.watch(penyediaTutorialBeranda);
    final tampilkanTutorial =
        tutorialAktif && cangkangNavigasi.currentIndex == 0;

    return Stack(
      children: [
        Scaffold(
          body: cangkangNavigasi,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: WarnaFunda.garis, width: 1),
              ),
            ),
            child: NavigationBar(
              selectedIndex: cangkangNavigasi.currentIndex,
              onDestinationSelected: _padaPilihTab,
              destinations: [
                const NavigationDestination(
                  icon: Icon(LucideIcons.house),
                  selectedIcon: Icon(
                    LucideIcons.house,
                    color: WarnaFunda.utama,
                  ),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  key: kunciTutorial.tabCatatan,
                  icon: const Icon(LucideIcons.receipt),
                  selectedIcon: const Icon(
                    LucideIcons.receipt,
                    color: WarnaFunda.utama,
                  ),
                  label: 'Catatan',
                ),
                NavigationDestination(
                  key: kunciTutorial.tabBelajar,
                  icon: const Icon(LucideIcons.bookOpen),
                  selectedIcon: const Icon(
                    LucideIcons.bookOpen,
                    color: WarnaFunda.utama,
                  ),
                  label: 'Belajar',
                ),
                NavigationDestination(
                  key: kunciTutorial.tabLainnya,
                  icon: const Icon(LucideIcons.ellipsis),
                  selectedIcon: const Icon(
                    LucideIcons.ellipsis,
                    color: WarnaFunda.utama,
                  ),
                  label: 'Lainnya',
                ),
              ],
            ),
          ),
        ),
        if (tampilkanTutorial)
          LapisanTutorialBeranda(
            daftarLangkah: [
              ItemSorotanTutorial(
                kunciTarget: kunciTutorial.ringkasanKeuangan,
                ikon: LucideIcons.wallet,
                pathSvg: AsetIlustrasiFunda.dompet,
                warnaAksen: WarnaFunda.utama,
                warnaLatarIkon: WarnaFunda.kanvasMint,
                judul: 'Ringkasan Keuangan',
                deskripsi:
                    'Pantau arus kas masuk & keluar serta total saldo seluruh dompetmu langsung di Beranda.',
              ),
              ItemSorotanTutorial(
                kunciTarget: kunciTutorial.tabCatatan,
                ikon: LucideIcons.receipt,
                pathSvg: AsetIlustrasiFunda.catatTransaksi,
                warnaAksen: WarnaFunda.sifatKebutuhan,
                warnaLatarIkon: WarnaFunda.kanvasBiru,
                judul: 'Tab Catatan',
                deskripsi:
                    'Tempat mencatat uang masuk, pengeluaran harian, dan transfer antar dompet dengan rapi.',
              ),
              ItemSorotanTutorial(
                kunciTarget: kunciTutorial.tabBelajar,
                ikon: LucideIcons.bookOpen,
                pathSvg: AsetIlustrasiFunda.mulaiTesAwal,
                warnaAksen: WarnaFunda.sifatKeinginan,
                warnaLatarIkon: WarnaFunda.kanvasUngu,
                judul: 'Tab Belajar',
                deskripsi:
                    '18 modul keuangan dari pemula hingga lanjutan yang langsung dipraktikkan memakai datamu sendiri.',
              ),
              ItemSorotanTutorial(
                kunciTarget: kunciTutorial.tabLainnya,
                ikon: LucideIcons.layoutGrid,
                pathSvg: AsetIlustrasiFunda.tutorialFiturLengkap,
                warnaAksen: WarnaFunda.sifatUtang,
                warnaLatarIkon: WarnaFunda.kanvasKuning,
                judul: 'Tab Lainnya',
                deskripsi:
                    'Kelola dompet, anggaran bulanan, tujuan, utang, laporan keuangan, dan cadangan data di sini.',
              ),
            ],
            padaSelesai: () =>
                ref.read(penyediaTutorialBeranda.notifier).selesaikanTutorial(),
            padaLewati: () =>
                ref.read(penyediaTutorialBeranda.notifier).selesaikanTutorial(),
          ),
      ],
    );
  }
}
