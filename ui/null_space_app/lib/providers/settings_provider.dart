import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// View mode options for the Markdown editor
enum EditorViewMode {
  edit,     // Edit only mode
  preview,  // Preview only mode
  split,    // Side-by-side edit and preview
}

/// Provider for managing app settings
///
/// All setter methods persist changes to SharedPreferences before updating
/// the in-memory state and notifying listeners. This ensures atomicity -
/// if persistence fails, the state remains unchanged and listeners are not
/// notified. This prevents UI/state inconsistencies where the UI shows a
/// setting as changed but the change isn't actually saved to disk.
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
  Locale? _locale; // null means system default

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
  static const String _localeKey = 'locale';

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
  Locale? get locale => _locale;

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

    // Load locale
    final localeString = prefs.getString(_localeKey);
    if (localeString != null && localeString.isNotEmpty) {
      // Handle script codes (e.g., zh_Hant for Traditional Chinese)
      if (localeString == 'zh_Hant') {
        _locale = const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
      } else {
        final parts = localeString.split('_');
        _locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);
      }
    }

    notifyListeners();
  }

  /// Set theme mode
  ///
  /// Throws an exception if persistence fails.
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    
    _themeMode = mode;
    notifyListeners();
  }

  /// Set font size
  ///
  /// Throws an exception if persistence fails.
  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
    
    _fontSize = size;
    notifyListeners();
  }

  /// Set line spacing
  ///
  /// Throws an exception if persistence fails.
  Future<void> setLineSpacing(double spacing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineSpacingKey, spacing);
    
    _lineSpacing = spacing;
    notifyListeners();
  }

  /// Set auto-lock timeout
  ///
  /// Throws an exception if persistence fails.
  Future<void> setAutoLockTimeout(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockTimeoutKey, duration.inMinutes);
    
    _autoLockTimeout = duration;
    notifyListeners();
  }

  /// Set biometric enabled
  ///
  /// Throws an exception if persistence fails.
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    
    _biometricEnabled = enabled;
    notifyListeners();
  }

  /// Set clear clipboard
  ///
  /// Throws an exception if persistence fails.
  Future<void> setClearClipboard(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clearClipboardKey, enabled);
    
    _clearClipboard = enabled;
    notifyListeners();
  }

  /// Set editor view mode
  ///
  /// Throws an exception if persistence fails.
  Future<void> setEditorViewMode(EditorViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_editorViewModeKey, mode.index);
    
    _editorViewMode = mode;
    notifyListeners();
  }

  /// Set auto-save interval
  ///
  /// Throws an exception if persistence fails.
  Future<void> setAutoSaveInterval(Duration interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoSaveIntervalKey, interval.inSeconds);
    
    _autoSaveInterval = interval;
    notifyListeners();
  }

  /// Set spell check enabled
  ///
  /// Throws an exception if persistence fails.
  Future<void> setSpellCheckEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_spellCheckEnabledKey, enabled);
    
    _spellCheckEnabled = enabled;
    notifyListeners();
  }

  /// Set data directory
  ///
  /// Throws an exception if persistence fails.
  Future<void> setDataDirectory(String directory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataDirectoryKey, directory);
    
    _dataDirectory = directory;
    notifyListeners();
  }

  /// Set locale
  ///
  /// Pass null to use system default. Throws an exception if persistence fails.
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      // Handle script codes (e.g., Traditional Chinese)
      String localeString;
      if (locale.scriptCode != null) {
        localeString = '${locale.languageCode}_${locale.scriptCode}';
      } else if (locale.countryCode != null) {
        localeString = '${locale.languageCode}_${locale.countryCode}';
      } else {
        localeString = locale.languageCode;
      }
      await prefs.setString(_localeKey, localeString);
    }
    
    _locale = locale;
    notifyListeners();
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
    _locale = null;
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
