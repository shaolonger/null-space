import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// View mode options for the Markdown editor
enum EditorViewMode {
  edit,     // Edit only mode
  preview,  // Preview only mode
  split,    // Side-by-side edit and preview
}

/// Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  // Private fields
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 16.0;
  double _lineSpacing = 1.5;
  Duration _autoLockTimeout = const Duration(minutes: 15);
  bool _biometricEnabled = false;
  bool _clearClipboard = true;
  EditorViewMode _editorViewMode = EditorViewMode.split;
  Duration _autoSaveInterval = const Duration(seconds: 30);
  bool _spellCheckEnabled = true;
  String _dataDirectory = '';

  // Keys for SharedPreferences
  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _lineSpacingKey = 'line_spacing';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _clearClipboardKey = 'clear_clipboard';
  static const String _editorViewModeKey = 'editor_view_mode';
  static const String _autoSaveIntervalKey = 'auto_save_interval';
  static const String _spellCheckEnabledKey = 'spell_check_enabled';
  static const String _dataDirectoryKey = 'data_directory';

  // Getters
  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  double get lineSpacing => _lineSpacing;
  Duration get autoLockTimeout => _autoLockTimeout;
  bool get biometricEnabled => _biometricEnabled;
  bool get clearClipboard => _clearClipboard;
  EditorViewMode get editorViewMode => _editorViewMode;
  Duration get autoSaveInterval => _autoSaveInterval;
  bool get spellCheckEnabled => _spellCheckEnabled;
  String get dataDirectory => _dataDirectory;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    // Load font size
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;

    // Load line spacing
    _lineSpacing = prefs.getDouble(_lineSpacingKey) ?? 1.5;

    // Load auto-lock timeout (stored in minutes)
    final autoLockMinutes = prefs.getInt(_autoLockTimeoutKey) ?? 15;
    _autoLockTimeout = Duration(minutes: autoLockMinutes);

    // Load biometric enabled
    _biometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;

    // Load clear clipboard
    _clearClipboard = prefs.getBool(_clearClipboardKey) ?? true;

    // Load editor view mode
    final viewModeIndex = prefs.getInt(_editorViewModeKey);
    if (viewModeIndex != null && viewModeIndex < EditorViewMode.values.length) {
      _editorViewMode = EditorViewMode.values[viewModeIndex];
    }

    // Load auto-save interval (stored in seconds)
    final autoSaveSeconds = prefs.getInt(_autoSaveIntervalKey) ?? 30;
    _autoSaveInterval = Duration(seconds: autoSaveSeconds);

    // Load spell check enabled
    _spellCheckEnabled = prefs.getBool(_spellCheckEnabledKey) ?? true;

    // Load data directory
    _dataDirectory = prefs.getString(_dataDirectoryKey) ?? '';

    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Set font size
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  /// Set line spacing
  Future<void> setLineSpacing(double spacing) async {
    _lineSpacing = spacing;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineSpacingKey, spacing);
  }

  /// Set auto-lock timeout
  Future<void> setAutoLockTimeout(Duration duration) async {
    _autoLockTimeout = duration;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockTimeoutKey, duration.inMinutes);
  }

  /// Set biometric enabled
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Set clear clipboard
  Future<void> setClearClipboard(bool enabled) async {
    _clearClipboard = enabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clearClipboardKey, enabled);
  }

  /// Set editor view mode
  Future<void> setEditorViewMode(EditorViewMode mode) async {
    _editorViewMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_editorViewModeKey, mode.index);
  }

  /// Set auto-save interval
  Future<void> setAutoSaveInterval(Duration interval) async {
    _autoSaveInterval = interval;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoSaveIntervalKey, interval.inSeconds);
  }

  /// Set spell check enabled
  Future<void> setSpellCheckEnabled(bool enabled) async {
    _spellCheckEnabled = enabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_spellCheckEnabledKey, enabled);
  }

  /// Set data directory
  Future<void> setDataDirectory(String directory) async {
    _dataDirectory = directory;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataDirectoryKey, directory);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _fontSize = 16.0;
    _lineSpacing = 1.5;
    _autoLockTimeout = const Duration(minutes: 15);
    _biometricEnabled = false;
    _clearClipboard = true;
    _editorViewMode = EditorViewMode.split;
    _autoSaveInterval = const Duration(seconds: 30);
    _spellCheckEnabled = true;
    _dataDirectory = '';
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
