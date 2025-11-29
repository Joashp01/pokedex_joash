import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_joash/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial theme mode should be system', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('setThemeMode should update theme mode and notify listeners', () async {
      final provider = ThemeProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(notified, true);
    });

    test('setThemeMode should persist theme to SharedPreferences', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), ThemeMode.dark.toString());
    });

    test('toggleTheme should switch from light to dark', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.light);
      provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme should switch from dark to light', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);
      provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme should switch from system to light', () async {
      final provider = ThemeProvider();

      expect(provider.themeMode, ThemeMode.system);
      provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('lightTheme should have correct properties', () {
      final theme = ThemeProvider.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
      expect(theme.colorScheme.primary, const Color(0xFFE63946));
    });

    test('darkTheme should have correct properties', () {
      final theme = ThemeProvider.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
      expect(theme.colorScheme.primary, const Color(0xFFFF6B6B));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('lightTheme should have correct card theme', () {
      final theme = ThemeProvider.lightTheme;

      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, Colors.white);
    });

    test('darkTheme should have correct card theme', () {
      final theme = ThemeProvider.darkTheme;

      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, const Color(0xFF1E1E2E));
    });

    test('Theme should load from SharedPreferences on initialization', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.toString(),
      });

      final provider = ThemeProvider();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}
