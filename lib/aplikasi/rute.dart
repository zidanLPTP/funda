import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../fitur/anggaran/tampilan/layar_anggaran.dart';
import '../fitur/belajar/tampilan/layar_belajar.dart';
import '../fitur/belajar/tampilan/layar_kuis_modul.dart';
import '../fitur/belajar/tampilan/layar_pemutar_pelajaran.dart';
import '../fitur/belajar/tampilan/layar_tes_awal.dart';
import '../fitur/beranda/tampilan/layar_beranda.dart';
import '../fitur/cadangan/tampilan/layar_cadangan.dart';
import '../fitur/catatan/tampilan/layar_catatan.dart';
import '../fitur/dompet/tampilan/layar_daftar_dompet.dart';
import '../fitur/galeri/tampilan/layar_galeri.dart';
import '../fitur/kategori/tampilan/layar_daftar_kategori.dart';
import '../fitur/kantong/tampilan/layar_daftar_kantong.dart';
import '../fitur/kekayaan_bersih/tampilan/layar_kekayaan_bersih.dart';
import '../fitur/lainnya/tampilan/layar_lainnya.dart';
import '../fitur/laporan/tampilan/layar_laporan_bulanan.dart';
import '../fitur/onboarding/tampilan/layar_onboarding.dart';
import '../fitur/pengaturan/tampilan/layar_pengaturan.dart';
import '../fitur/sandbox/tampilan/layar_sandbox.dart';
import '../fitur/tagihan/tampilan/layar_form_tagihan.dart';
import '../fitur/tagihan/tampilan/layar_jadwal_tagihan.dart';
import '../fitur/tagihan/tampilan/layar_semua_tagihan.dart';
import '../fitur/transaksi/tampilan/layar_form_transaksi.dart';
import '../fitur/tujuan/tampilan/layar_daftar_tujuan.dart';
import '../fitur/tujuan/tampilan/layar_detail_tujuan.dart';
import '../fitur/utang/tampilan/layar_daftar_utang.dart';
import '../fitur/utang/tampilan/layar_detail_utang.dart';
import '../fitur/utang/tampilan/layar_form_utang.dart';
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

    // Rute Fitur Tahap 2: Transaksi (Form Tambah Transaksi Modal)
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/transaksi/tambah',
      builder: (context, state) => const LayarFormTransaksi(),
    ),

    // Rute Fitur Tahap 3A: Anggaran, Tujuan, Kantong
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/dompet',
      builder: (context, state) => const LayarDaftarDompet(),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/anggaran',
      builder: (context, state) => const LayarAnggaran(),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/tujuan',
      builder: (context, state) => const LayarDaftarTujuan(),
      routes: [
        GoRoute(
          parentNavigatorKey: _kunciNavigatorAkar,
          path: ':id',
          builder: (context, state) =>
              LayarDetailTujuan(tujuanId: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/kantong',
      builder: (context, state) => const LayarDaftarKantong(),
    ),

    // Rute Fitur Tahap 3B: Utang & Kekayaan Bersih
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/utang',
      builder: (context, state) => const LayarDaftarUtang(),
      routes: [
        GoRoute(
          parentNavigatorKey: _kunciNavigatorAkar,
          path: 'tambah',
          builder: (context, state) => const LayarFormUtang(),
        ),
        GoRoute(
          parentNavigatorKey: _kunciNavigatorAkar,
          path: ':id',
          builder: (context, state) =>
              LayarDetailUtang(utangId: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/kekayaan-bersih',
      builder: (context, state) => const LayarKekayaanBersih(),
    ),

    // Rute Fitur Tahap 3C: Tagihan, Langganan & Pengaturan
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/tagihan',
      builder: (context, state) => const LayarJadwalTagihan(),
      routes: [
        GoRoute(
          parentNavigatorKey: _kunciNavigatorAkar,
          path: 'semua',
          builder: (context, state) => const LayarSemuaTagihan(),
        ),
        GoRoute(
          parentNavigatorKey: _kunciNavigatorAkar,
          path: 'tambah',
          builder: (context, state) => const LayarFormTagihan(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/pengaturan',
      builder: (context, state) => const LayarPengaturan(),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/kategori',
      builder: (context, state) => const LayarDaftarKategori(),
    ),

    // Rute Fitur Tahap 4: Pemutar Pelajaran & Kuis Akhir Modul
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/belajar/pelajaran/:modulId/:pelajaranId',
      builder: (context, state) => LayarPemutarPelajaran(
        key: ValueKey(state.pathParameters['pelajaranId']!),
        modulId: state.pathParameters['modulId']!,
        pelajaranId: state.pathParameters['pelajaranId']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/belajar/kuis/:modulId',
      builder: (context, state) => LayarKuisModul(
        key: ValueKey(state.pathParameters['modulId']!),
        modulId: state.pathParameters['modulId']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/belajar/tes-awal',
      builder: (context, state) => const LayarTesAwal(),
    ),

    // Rute Fitur Tahap 7: Laporan Bulanan & Cadangan Data
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/laporan',
      builder: (context, state) => const LayarLaporanBulanan(),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/cadangan',
      builder: (context, state) => const LayarCadangan(),
    ),
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/onboarding',
      builder: (context, state) => const LayarOnboarding(),
    ),

    // Rute Fitur Tahap 9A: Mode Sandbox Edukasi Investasi
    GoRoute(
      parentNavigatorKey: _kunciNavigatorAkar,
      path: '/sandbox',
      builder: (context, state) => const LayarSandbox(),
    ),

    // Rute Galeri Komponen (hanya tersedia di mode debug)
    if (kDebugMode)
      GoRoute(
        parentNavigatorKey: _kunciNavigatorAkar,
        path: '/galeri',
        builder: (context, state) => const LayarGaleri(),
      ),
  ],
);
