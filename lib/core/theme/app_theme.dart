import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF07111B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF21C7F6),
        secondary: Color(0xFF4EE29A),
        surface: Color(0xFF0E1B2A),
        onPrimary: Color(0xFF02111B),
        onSecondary: Color(0xFF02111B),
        onSurface: Color(0xFFF4F7FB),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w800,
          height: 1.05,
          color: Color(0xFFF4F7FB),
        ),
        displayMedium: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: Color(0xFFF4F7FB),
        ),
        headlineLarge: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF4F7FB),
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF4F7FB),
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF4F7FB),
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: Color(0xFF9CB0C4),
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF9CB0C4),
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 1.4,
          color: Color(0xFF9CB0C4),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0E1B2A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFF1A3047)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF12253A),
        side: const BorderSide(color: Color(0xFF1A3047)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerColor: const Color(0xFF1A3047),
    );
  }
}
