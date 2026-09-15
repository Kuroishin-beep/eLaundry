import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const primary = MaterialColor(0xFF006768, <int, Color>{
    100: Color(0xFFCCE1E1),
    200: Color(0xFF99C2C3),
    300: Color(0xFF66A4A4),
    400: Color(0xFF338586),
    500: Color(0xFF006768),
    600: Color(0xFF005253),
    700: Color(0xFF003E3E),
    800: Color(0xFF00292A),
    900: Color(0xFF001A1A),
  });

  static const secondary = MaterialColor(0xFF717473, <int, Color>{
    100: Color(0xFFE3E3E3),
    200: Color(0xFFC6C7C7),
    300: Color(0xFFAAACAB),
    400: Color(0xFF8D908F),
    500: Color(0xFF717473),
    600: Color(0xFF5A5D5C),
    700: Color(0xFF444645),
    800: Color(0xFF2D2E2E),
    900: Color(0xFF1C1D1D),
  });

  static const tertiary = MaterialColor(0xFF114251, <int, Color>{
    100: Color(0xFFCFD9DC),
    200: Color(0xFFA0B3B9),
    300: Color(0xFF708E97),
    400: Color(0xFF416874),
    500: Color(0xFF114251),
    600: Color(0xFF0E3541),
    700: Color(0xFF0A2831),
    800: Color(0xFF071A20),
    900: Color(0xFF041014),
  });

  static const neutral = MaterialColor(0xFFEAEAEA, <int, Color>{
    100: Color(0xFFFBFBFB),
    200: Color(0xFFF7F7F7),
    300: Color(0xFFF2F2F2),
    400: Color(0xFFEEEEEE),
    500: Color(0xFFEAEAEA),
    600: Color(0xFFBBBBBB),
    700: Color(0xFF8C8C8C),
    800: Color(0xFF5E5E5E),
    900: Color(0xFF3A3A3A),
  });

  static const accent = MaterialColor(0xFF9D0233, <int, Color>{
    100: Color(0xFFEBCCD6),
    200: Color(0xFFD89AAD),
    300: Color(0xFFC46785),
    400: Color(0xFFB1355C),
    500: Color(0xFF9D0233),
    600: Color(0xFF7E0229),
    700: Color(0xFF5E011F),
    800: Color(0xFF3F0114),
    900: Color(0xFF27000D),
  });

  static const success = MaterialColor(0xFF10B981, <int, Color>{
    100: Color(0xFFCFF1E6),
    200: Color(0xFF9FE3CD),
    300: Color(0xFF70D5B3),
    400: Color(0xFF40C79A),
    500: Color(0xFF10B981),
    600: Color(0xFF0D9467),
    700: Color(0xFF0A6F4D),
    800: Color(0xFF064A34),
    900: Color(0xFF042E20),
  });

  static const warning = MaterialColor(0xFFFB8501, <int, Color>{
    100: Color(0xFFFEE7CC),
    200: Color(0xFFFDCE99),
    300: Color(0xFFFDB667),
    400: Color(0xFFFC9D34),
    500: Color(0xFFFB8501),
    600: Color(0xFFC96A01),
    700: Color(0xFF975001),
    800: Color(0xFF643500),
    900: Color(0xFF3F2100),
  });

  static const error = MaterialColor(0xFFEF4444, <int, Color>{
    100: Color(0xFFFCDADA),
    200: Color(0xFFF9B4B4),
    300: Color(0xFFF58F8F),
    400: Color(0xFFF26969),
    500: Color(0xFFEF4444),
    600: Color(0xFFBF3636),
    700: Color(0xFF8F2929),
    800: Color(0xFF601B1B),
    900: Color(0xFF3C1111),
  });

  static const disabled = MaterialColor(0xFF808080, <int, Color>{
    100: Color(0xFFE6E6E6),
    200: Color(0xFFCCCCCC),
    300: Color(0xFFB3B3B3),
    400: Color(0xFF999999),
    500: Color(0xFF808080),
    600: Color(0xFF666666),
    700: Color(0xFF4D4D4D),
    800: Color(0xFF333333),
    900: Color(0xFF202020),
  });
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary[100],
      onPrimaryContainer: AppColors.primary[900],
      secondary: AppColors.tertiary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.tertiary[100],
      onSecondaryContainer: AppColors.tertiary[900],
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accent[100],
      onTertiaryContainer: AppColors.accent[900],
      error: AppColors.error,
      surface: AppColors.neutral[100],
      onSurface: AppColors.secondary[900],
      outline: AppColors.neutral[700],
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.museoModerno(fontSize: 32),
      headlineLarge: GoogleFonts.museoModerno(fontSize: 32),
      titleLarge: GoogleFonts.museoModerno(fontSize: 20),
      bodyLarge: GoogleFonts.poppins(fontSize: 16),
      bodyMedium: GoogleFonts.poppins(fontSize: 16),
      bodySmall: GoogleFonts.poppins(fontSize: 12),
      labelLarge: GoogleFonts.poppins(fontSize: 16),
      labelMedium: GoogleFonts.poppins(fontSize: 12),
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.neutral[100],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral[100],
        foregroundColor: AppColors.primary[900],
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.neutral[500]!),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      dividerTheme: DividerThemeData(color: AppColors.neutral[500]),
    );
  }
}
