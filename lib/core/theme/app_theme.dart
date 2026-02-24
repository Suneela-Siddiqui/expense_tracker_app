import 'package:flutter/material.dart';

class AppTheme {
  static const raspberry = Color(0xFFEE005A); // #EE005A
  static const deepSpace = Color(0xFF012641); // #012641

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,

    // Brand
    primary: raspberry,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFD6E4),
    onPrimaryContainer: Color(0xFF3A001A),

    // Structural (Deep Space)
    secondary: deepSpace,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD7E9FF),
    onSecondaryContainer: Color(0xFF001B33),

    tertiary: Color(0xFF0E4C77),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFCFEAFF),
    onTertiaryContainer: Color(0xFF001B2A),

    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),

    // Premium light surfaces
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0B1A2A), // deep-ish (ties to Deep Space)
    surfaceContainerHighest: Color(0xFFF6F7FB),
    onSurfaceVariant: Color(0xFF5B6472),

    outline: Color(0xFFB7C0CC),
    outlineVariant: Color(0xFFE6EAF0),

    shadow: Colors.black,
    scrim: Colors.black,

    inverseSurface: Color(0xFF0F172A),
    onInverseSurface: Color(0xFFF8FAFC),
    inversePrimary: Color(0xFFFF5A95),
  );

  static ThemeData light() {
    final base = ThemeData.from(colorScheme: lightScheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // ✅ pure white

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: deepSpace, // ✅ structural
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: deepSpace,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),

      iconTheme: const IconThemeData(color: deepSpace),

      cardTheme: const CardThemeData().copyWith(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightScheme.surfaceContainerHighest.withValues(alpha: 0.75), // ✅ more premium
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: raspberry, width: 1.6),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepSpace,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        actionTextColor: raspberry,
      ),
    );
  }

  // keep your dark() as you had, or I’ll tune it later to match
  static ThemeData dark() => ThemeData.from(colorScheme: ColorScheme.fromSeed(
    seedColor: raspberry,
    brightness: Brightness.dark,
  ), useMaterial3: true);
}