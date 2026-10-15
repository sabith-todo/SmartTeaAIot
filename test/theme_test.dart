import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tea_aiot/core/theme/app_theme.dart';

void main() {
  group('AppTheme Palette Tests', () {
    test('Verifies required theme color hex values', () {
      expect(AppTheme.forestGreen, const Color(0xFF193B2B));
      expect(AppTheme.cream, const Color(0xFFF3EEDC));
      expect(AppTheme.leafGreen, const Color(0xFFB5C99B));
    });

    test('Verifies ThemeData configuration', () {
      final theme = AppTheme.lightTheme();
      expect(theme.colorScheme.primary, AppTheme.forestGreen);
      expect(theme.scaffoldBackgroundColor, AppTheme.cream);
      expect(theme.colorScheme.secondary, AppTheme.leafGreen);
      expect(theme.useMaterial3, isTrue);
    });
  });
}
