import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'ilustrasi_funda.dart';

/// Memetakan kunci string ikon ke IconData dari pustaka Lucide.
IconData ambilIkonLucide(String kunci) {
  return switch (kunci) {
    'wallet' => LucideIcons.wallet,
    'walletCards' => LucideIcons.walletCards,
    'building2' || 'bank' => LucideIcons.building2,
    'creditCard' => LucideIcons.creditCard,
    'coins' => LucideIcons.coins,
    'handCoins' => LucideIcons.handCoins,
    'briefcase' => LucideIcons.briefcase,
    'trendingUp' => LucideIcons.trendingUp,
    'gift' => LucideIcons.gift,
    'utensils' => LucideIcons.utensils,
    'home' => LucideIcons.home,
    'bus' => LucideIcons.bus,
    'car' => LucideIcons.car,
    'plane' => LucideIcons.plane,
    'laptop' => LucideIcons.laptop,
    'wifi' => LucideIcons.wifi,
    'zap' => LucideIcons.zap,
    'heart' => LucideIcons.heart,
    'heartPulse' => LucideIcons.heartPulse,
    'heartHandshake' => LucideIcons.heartHandshake,
    'graduationCap' => LucideIcons.graduationCap,
    'shoppingBag' => LucideIcons.shoppingBag,
    'clapperboard' => LucideIcons.clapperboard,
    'palmtree' => LucideIcons.palmtree,
    'gamepad2' => LucideIcons.gamepad2,
    'coffee' => LucideIcons.coffee,
    'shoppingCart' => LucideIcons.shoppingCart,
    'tv' => LucideIcons.tv,
    'receipt' => LucideIcons.receipt,
    'piggyBank' => LucideIcons.piggyBank,
    'shield' => LucideIcons.shield,
    'shieldAlert' => LucideIcons.shieldAlert,
    'calendarClock' => LucideIcons.calendarClock,
    'receiptText' => LucideIcons.receiptText,
    'layers' => LucideIcons.layers,
    'target' => LucideIcons.target,
    'archive' => LucideIcons.archive,
    'arrowLeftRight' => LucideIcons.arrowLeftRight,
    _ => LucideIcons.circleDot,
  };
}

/// Memetakan kunci ikon kategori / entitas ke aset SVG custom bila tersedia.
String? pathSvgUntukIkonKategori(String kunci) {
  return switch (kunci) {
    'utensils' || 'makan' => AsetIkonFunda.katMakan,
    'home' || 'rumah' => AsetIkonFunda.katRumah,
    'bus' || 'transportasi' => AsetIkonFunda.katTransportasi,
    'car' => AsetIkonFunda.tujuanKendaraan,
    'plane' => AsetIkonFunda.tujuanLiburan,
    'laptop' => AsetIkonFunda.tujuanLaptop,
    'wifi' || 'internet' => AsetIkonFunda.katInternet,
    'zap' || 'listrik' => AsetIkonFunda.katListrik,
    'heartPulse' || 'heart' || 'kesehatan' => AsetIkonFunda.katKesehatan,
    'graduationCap' || 'pendidikan' => AsetIkonFunda.katPendidikan,
    'shoppingCart' || 'shoppingBag' || 'belanja' => AsetIkonFunda.katBelanja,
    'clapperboard' ||
    'palmtree' ||
    'gamepad2' ||
    'tv' ||
    'hiburan' => AsetIkonFunda.katHiburan,
    'coffee' || 'kopi' => AsetIkonFunda.katKopi,
    'briefcase' || 'gaji' => AsetIkonFunda.katGaji,
    'wallet' || 'walletCards' => AsetIkonFunda.menuDompet,
    'building2' || 'bank' => AsetIkonFunda.dompetBank,
    'layers' => AsetIkonFunda.menuKantong,
    'target' => AsetIkonFunda.metrikTujuan,
    'handCoins' ||
    'trendingUp' ||
    'gift' ||
    'coins' ||
    'bonus' => AsetIkonFunda.katBonus,
    'heartHandshake' || 'donasi' => AsetIkonFunda.katDonasi,
    'piggyBank' => AsetIkonFunda.sifatTabungan,
    'shield' || 'shieldAlert' => AsetIkonFunda.metrikDanaDarurat,
    'calendarClock' ||
    'receiptText' ||
    'creditCard' => AsetIkonFunda.sifatUtang,
    'receipt' || 'tag' || 'lainnya' => AsetIkonFunda.katLainnya,
    _ => null,
  };
}

/// Widget ikon kategori / entitas: menampilkan SVG custom Funda jika tersedia, fallback Lucide.
class IkonKategoriFunda extends StatelessWidget {
  final String kunciIkon;
  final double ukuran;
  final Color? warnaFallback;

  const IkonKategoriFunda({
    super.key,
    required this.kunciIkon,
    this.ukuran = 20,
    this.warnaFallback,
  });

  @override
  Widget build(BuildContext context) {
    final pathSvg = pathSvgUntukIkonKategori(kunciIkon);
    if (pathSvg != null) {
      return IkonSvgFunda(pathAset: pathSvg, ukuran: ukuran);
    }
    return Icon(ambilIkonLucide(kunciIkon), size: ukuran, color: warnaFallback);
  }
}

/// Widget ikon dompet: memprioritaskan jenis dompet (`rekening_bank`, `e_wallet`, `tunai`)
/// dan menggunakan `ic_menu_dompet` / kategori SVG bila berjenis `lainnya`.
class IkonDompetFunda extends StatelessWidget {
  final String? kodeJenis;
  final String? kunciIkonFallback;
  final double ukuran;
  final Color? warnaFallback;

  const IkonDompetFunda({
    super.key,
    this.kodeJenis,
    this.kunciIkonFallback,
    this.ukuran = 22,
    this.warnaFallback,
  });

  @override
  Widget build(BuildContext context) {
    if (kodeJenis != null) {
      final pathJenis = pathSvgUntukJenisDompet(kodeJenis!);
      if (pathJenis != null) {
        return IkonSvgFunda(pathAset: pathJenis, ukuran: ukuran);
      }
    }
    final kunci = kunciIkonFallback ?? 'wallet';
    return IkonKategoriFunda(
      kunciIkon: kunci,
      ukuran: ukuran,
      warnaFallback: warnaFallback,
    );
  }
}

/// Daftar pilihan ikon yang dapat dipilih pengguna saat membuat dompet atau kategori kustom.
const List<Map<String, dynamic>> daftarPilihanIkon = [
  {'kunci': 'wallet', 'label': 'Dompet', 'ikon': LucideIcons.wallet},
  {'kunci': 'building2', 'label': 'Bank', 'ikon': LucideIcons.building2},
  {
    'kunci': 'creditCard',
    'label': 'Kartu / E-Wallet',
    'ikon': LucideIcons.creditCard,
  },
  {'kunci': 'coins', 'label': 'Koin / Kas', 'ikon': LucideIcons.coins},
  {'kunci': 'utensils', 'label': 'Makanan', 'ikon': LucideIcons.utensils},
  {
    'kunci': 'shoppingCart',
    'label': 'Belanja',
    'ikon': LucideIcons.shoppingCart,
  },
  {'kunci': 'coffee', 'label': 'Kopi / Jajan', 'ikon': LucideIcons.coffee},
  {'kunci': 'bus', 'label': 'Transportasi', 'ikon': LucideIcons.bus},
  {'kunci': 'home', 'label': 'Rumah', 'ikon': LucideIcons.home},
  {'kunci': 'gift', 'label': 'Hadiah', 'ikon': LucideIcons.gift},
  {
    'kunci': 'heartHandshake',
    'label': 'Donasi / Berbagi',
    'ikon': LucideIcons.heartHandshake,
  },
  {
    'kunci': 'briefcase',
    'label': 'Kerja / Bisnis',
    'ikon': LucideIcons.briefcase,
  },
];
