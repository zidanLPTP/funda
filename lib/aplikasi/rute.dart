import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../fitur/belajar/tampilan/layar_belajar.dart';
import '../fitur/beranda/tampilan/layar_beranda.dart';
import '../fitur/catatan/tampilan/layar_catatan.dart';
import '../fitur/galeri/tampilan/layar_galeri.dart';
import '../fitur/lainnya/tampilan/layar_lainnya.dart';
import 'bilah_navigasi.dart';

final GlobalKey<NavigatorState> _kunciNavigatorAkar = GlobalKey<NavigatorState>(
  debugLabel: 'akar',
);

/// Konfigurasi rute navigasi aplikasi Funda berbasis GoRouter.
final ruteFunda = GoRouter(
  navigatorKey: _kunciNavigatorAkar,
  initialLocation: '/',
  routes: [
    // Rute utama dengan bilah navigasi bawah 4 tab
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PembungkusBilahNavigasi(cangkangNavigasi: navigationShell);
      },
      branches: [
        // Tab 1: Beranda
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const LayarBeranda(),
            ),
          ],
        ),

        // Tab 2: Catatan
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catatan',
              builder: (context, state) => const LayarCatatan(),
            ),
          ],
        ),

        // Tab 3: Belajar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/belajar',
              builder: (context, state) => const LayarBelajar(),
            ),
          ],
        ),

        // Tab 4: Lainnya
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lainnya',
              builder: (context, state) => const LayarLainnya(),
            ),
          ],
        ),
      ],
    ),

    // Rute Galeri Komponen (khusus pengembang, tidak tampil di bilah tab)
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/galeri',
      builder: (context, state) => const LayarGaleri(),
    ),
  ],
);
