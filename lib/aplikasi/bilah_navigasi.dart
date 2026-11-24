import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../tema/token.dart';
import '../util/haptic.dart';

/// Pembungkus bilah navigasi bawah (Bottom Navigation Bar) Funda.
class PembungkusBilahNavigasi extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: cangkangNavigasi,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: WarnaFunda.garis, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: cangkangNavigasi.currentIndex,
          onDestinationSelected: _padaPilihTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.house),
              selectedIcon: Icon(LucideIcons.house, color: WarnaFunda.utama),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.receipt),
              selectedIcon: Icon(LucideIcons.receipt, color: WarnaFunda.utama),
              label: 'Catatan',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.bookOpen),
              selectedIcon: Icon(LucideIcons.bookOpen, color: WarnaFunda.utama),
              label: 'Belajar',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.ellipsis),
              selectedIcon: Icon(LucideIcons.ellipsis, color: WarnaFunda.utama),
              label: 'Lainnya',
            ),
          ],
        ),
      ),
    );
  }
}
