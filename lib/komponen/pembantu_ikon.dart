import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    'wifi' => LucideIcons.wifi,
    'zap' => LucideIcons.zap,
    'heartPulse' => LucideIcons.heartPulse,
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
    'shieldAlert' => LucideIcons.shieldAlert,
    'calendarClock' => LucideIcons.calendarClock,
    'receiptText' => LucideIcons.receiptText,
    'archive' => LucideIcons.archive,
    'arrowLeftRight' => LucideIcons.arrowLeftRight,
    _ => LucideIcons.circleDot,
  };
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
    'kunci': 'briefcase',
    'label': 'Kerja / Bisnis',
    'ikon': LucideIcons.briefcase,
  },
];
