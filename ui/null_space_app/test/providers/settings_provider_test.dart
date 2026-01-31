import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsProvider Tests', () {
    late SettingsProvider provider;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      provider = SettingsProvider();
    });

    test('initializes with default values', () {
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.fontSize, 16.0);
      expect(provider.lineSpacing, 1.5);
      expect(provider.autoLockTimeout, const Duration(minutes: 15));
      expect(provider.biometricEnabled, false);
      expect(provider.clearClipboard, true);
      expect(provider.editorViewMode, EditorViewMode.split);
      expect(provider.autoSaveInterval, const Duration(seconds: 30));
      expect(provider.spellCheckEnabled, true);
      expect(provider.dataDirectory, '');
    });

    test('loads settings from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.index,
        'font_size': 18.0,
        'line_spacing': 2.0,
        'auto_lock_timeout': 30,
        'biometric_enabled': true,
        'clear_clipboard': false,
        'editor_view_mode': EditorViewMode.edit.index,
        'auto_save_interval': 60,
        'spell_check_enabled': false,
        'data_directory': '/custom/path',
      });

      provider = SettingsProvider();
      await provider.loadSettings();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.fontSize, 18.0);
      expect(provider.lineSpacing, 2.0);
      expect(provider.autoLockTimeout, const Duration(minutes: 30));
      expect(provider.biometricEnabled, true);
      expect(provider.clearClipboard, false);
      expect(provider.editorViewMode, EditorViewMode.edit);
      expect(provider.autoSaveInterval, const Duration(seconds: 60));
      expect(provider.spellCheckEnabled, false);
      expect(provider.dataDirectory, '/custom/path');
    });

    test('sets theme mode and persists', () async {
      await provider.setThemeMode(ThemeMode.light);

      expect(provider.themeMode, ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), ThemeMode.light.index);
    });

    test('sets font size and persists', () async {
      await provider.setFontSize(20.0);

      expect(provider.fontSize, 20.0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('font_size'), 20.0);
    });

    test('sets line spacing and persists', () async {
      await provider.setLineSpacing(2.0);

      expect(provider.lineSpacing, 2.0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('line_spacing'), 2.0);
    });

    test('sets auto-lock timeout and persists', () async {
      await provider.setAutoLockTimeout(const Duration(minutes: 5));

      expect(provider.autoLockTimeout, const Duration(minutes: 5));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('auto_lock_timeout'), 5);
    });

    test('sets biometric enabled and persists', () async {
      await provider.setBiometricEnabled(true);

      expect(provider.biometricEnabled, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('biometric_enabled'), true);
    });

    test('sets clear clipboard and persists', () async {
      await provider.setClearClipboard(false);

      expect(provider.clearClipboard, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('clear_clipboard'), false);
    });

    test('sets editor view mode and persists', () async {
      await provider.setEditorViewMode(EditorViewMode.preview);

      expect(provider.editorViewMode, EditorViewMode.preview);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('editor_view_mode'), EditorViewMode.preview.index);
    });

    test('sets auto-save interval and persists', () async {
      await provider.setAutoSaveInterval(const Duration(minutes: 1));

      expect(provider.autoSaveInterval, const Duration(minutes: 1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('auto_save_interval'), 60);
    });

    test('sets spell check enabled and persists', () async {
      await provider.setSpellCheckEnabled(false);

      expect(provider.spellCheckEnabled, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('spell_check_enabled'), false);
    });

    test('sets data directory and persists', () async {
      await provider.setDataDirectory('/new/path');

      expect(provider.dataDirectory, '/new/path');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('data_directory'), '/new/path');
    });

    test('resets to defaults and clears SharedPreferences', () async {
      // Set some non-default values
      await provider.setThemeMode(ThemeMode.dark);
      await provider.setFontSize(20.0);
      await provider.setBiometricEnabled(true);

      // Reset to defaults
      await provider.resetToDefaults();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.fontSize, 16.0);
      expect(provider.lineSpacing, 1.5);
      expect(provider.autoLockTimeout, const Duration(minutes: 15));
      expect(provider.biometricEnabled, false);
      expect(provider.clearClipboard, true);
      expect(provider.editorViewMode, EditorViewMode.split);
      expect(provider.autoSaveInterval, const Duration(seconds: 30));
      expect(provider.spellCheckEnabled, true);
      expect(provider.dataDirectory, '');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });

    test('notifies listeners on theme mode change', () async {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.setThemeMode(ThemeMode.dark);

      expect(notified, true);
    });

    test('notifies listeners on font size change', () async {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.setFontSize(20.0);

      expect(notified, true);
    });

    test('notifies listeners on reset to defaults', () async {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.resetToDefaults();

      expect(notified, true);
    });

    test('handles missing values in SharedPreferences gracefully', () async {
      // Load with empty SharedPreferences
      await provider.loadSettings();

      // Should use default values
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.fontSize, 16.0);
      expect(provider.biometricEnabled, false);
    });

    test('handles invalid theme mode index gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 999, // Invalid index
      });

      provider = SettingsProvider();
      await provider.loadSettings();

      // Should keep default value
      expect(provider.themeMode, ThemeMode.system);
    });

    test('handles invalid view mode index gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'editor_view_mode': 999, // Invalid index
      });

      provider = SettingsProvider();
      await provider.loadSettings();

      // Should keep default value
      expect(provider.editorViewMode, EditorViewMode.split);
    });
  });

  group('EditorViewMode Enum Tests', () {
    test('EditorViewMode has correct values', () {
      expect(EditorViewMode.values.length, 3);
      expect(EditorViewMode.values, contains(EditorViewMode.edit));
      expect(EditorViewMode.values, contains(EditorViewMode.preview));
      expect(EditorViewMode.values, contains(EditorViewMode.split));
    });

    test('EditorViewMode enum ordering is stable', () {
      expect(EditorViewMode.edit.index, 0);
      expect(EditorViewMode.preview.index, 1);
      expect(EditorViewMode.split.index, 2);
    });
  });
}
