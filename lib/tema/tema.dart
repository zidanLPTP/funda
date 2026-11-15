import 'package:flutter/material.dart';
import 'token.dart';

/// Pembangun tema Material 3 aplikasi Funda.
abstract final class TemaFunda {
  /// Tema terang utama untuk aplikasi Funda.
  static ThemeData get temaTerang {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: WarnaFunda.utama,
      onPrimary: WarnaFunda.putih,
      primaryContainer: WarnaFunda.utamaTipis,
      onPrimaryContainer: WarnaFunda.utamaGelap,
      secondary: WarnaFunda.utamaGelap,
      onSecondary: WarnaFunda.putih,
      surface: WarnaFunda.permukaan,
      onSurface: WarnaFunda.teks,
      error: WarnaFunda.bahaya,
      onError: WarnaFunda.putih,
      outline: WarnaFunda.garis,
    );

    final textTheme =
        const TextTheme(
          displayLarge: TipografiFunda.angkaBesar,
          headlineMedium: TipografiFunda.judulLayar,
          titleLarge: TipografiFunda.judulBagian,
          bodyLarge: TipografiFunda.isi,
          bodyMedium: TipografiFunda.isiKecil,
          labelLarge: TipografiFunda.label,
          bodySmall: TipografiFunda.catatan,
        ).apply(
          fontFamily: TipografiFunda.namaKeluargaFont,
          bodyColor: WarnaFunda.teks,
          displayColor: WarnaFunda.teks,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: TipografiFunda.namaKeluargaFont,
      scaffoldBackgroundColor: WarnaFunda.latar,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: WarnaFunda.latar,
        foregroundColor: WarnaFunda.teks,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TipografiFunda.judulBagian,
      ),
      cardTheme: CardThemeData(
        color: WarnaFunda.permukaan,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SudutFunda.kartu),
          side: const BorderSide(color: WarnaFunda.garis),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: WarnaFunda.garis,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: WarnaFunda.permukaan,
        elevation: 0,
        indicatorColor: WarnaFunda.utamaTipis,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TipografiFunda.catatan.copyWith(
              fontWeight: FontWeight.w600,
              color: WarnaFunda.utama,
            );
          }
          return TipografiFunda.catatan.copyWith(color: WarnaFunda.teksRedup);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: WarnaFunda.utama, size: 24);
          }
          return const IconThemeData(color: WarnaFunda.teksRedup, size: 24);
        }),
      ),
    );
  }
}
