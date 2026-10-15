import 'package:flutter/material.dart';

/// Design system color palette and theme definitions for SmartTea AIoT.
/// Primary colors required:
/// - Forest Green: #193B2B
/// - Cream: #F3EEDC
/// - Leaf Green: #B5C99B
class AppTheme {
  AppTheme._();

  // Core Palette
  static const Color forestGreen = Color(0xFF193B2B);
  static const Color cream = Color(0xFFF3EEDC);
  static const Color leafGreen = Color(0xFFB5C99B);

  // Harmonized Supporting Colors
  static const Color forestGreenDark = Color(0xFF0F241A);
  static const Color forestGreenLight = Color(0xFF26533E);
  static const Color creamLight = Color(0xFFFAF7EE);
  static const Color creamDark = Color(0xFFE2DBC7);
  static const Color leafGreenDark = Color(0xFF8BA66F);
  static const Color leafGreenLight = Color(0xFFD6E3C5);

  static const Color textDark = Color(0xFF162B20);
  static const Color textMuted = Color(0xFF53675A);
  static const Color warningAmber = Color(0xFFB46E1B);
  static const Color alertRed = Color(0xFFA33838);
  static const Color infoBlue = Color(0xFF2D6A7E);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: forestGreen,
      onPrimary: creamLight,
      primaryContainer: forestGreenLight,
      onPrimaryContainer: creamLight,
      secondary: leafGreen,
      onSecondary: forestGreenDark,
      secondaryContainer: leafGreenLight,
      onSecondaryContainer: forestGreenDark,
      surface: cream,
      onSurface: textDark,
      surfaceContainerHighest: creamDark,
      error: alertRed,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: forestGreen,
        foregroundColor: creamLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: creamLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: creamLight,
        elevation: 1,
        shadowColor: forestGreen.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: creamDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: creamLight,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: creamLight,
        indicatorColor: leafGreenLight,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: forestGreen,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: forestGreen, size: 24);
          }
          return const IconThemeData(color: textMuted, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: forestGreen,
        selectedIconTheme: const IconThemeData(color: forestGreen),
        unselectedIconTheme: const IconThemeData(color: leafGreenLight),
        indicatorColor: leafGreen,
        selectedLabelTextStyle: const TextStyle(
          color: creamLight,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: leafGreenLight,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: creamDark,
        thickness: 1,
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: creamDark,
        selectedColor: leafGreen,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: forestGreen,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
