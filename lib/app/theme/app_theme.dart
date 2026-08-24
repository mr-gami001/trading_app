import 'package:flutter/material.dart';

class AppTheme {
  // Dark Palette
  static const Color darkBackground = Color(0xFF0E1117);
  static const Color darkCardSurface = Color(0xFF1E222D);
  static const Color darkBorder = Color(0xFF2A2E39);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextMuted = Color(0xFF8A8D93);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);

  // Universal Financial Colors
  static const Color gainGreenDark = Color(0xFF00D09C);
  static const Color gainGreenLight = Color(0xFF00B386);
  static const Color lossRedDark = Color(0xFFEB5757);
  static const Color lossRedLight = Color(0xFFE53935);
  static const Color primaryBlue = Color(0xFF536DFE);

  static Color getGainColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? gainGreenDark : gainGreenLight;
  }

  static Color getLossColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? lossRedDark : lossRedLight;
  }

  static Color getCardSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCardSurface : lightCardSurface;
  }

  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBorder : lightBorder;
  }

  static Color getTextMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextMuted : lightTextMuted;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: gainGreenDark,
        surface: darkCardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardSurface,
        selectedItemColor: gainGreenDark,
        unselectedItemColor: darkTextMuted,
        type: BottomNavigationBarType.fixed,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: gainGreenLight,
        surface: lightCardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCardSurface,
        selectedItemColor: gainGreenLight,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
      ),
      useMaterial3: true,
    );
  }
}
