import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Settings screen with various app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 2,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              _buildAppearanceSection(context, settings),
              const Divider(),
              _buildSecuritySection(context, settings),
              const Divider(),
              _buildEditorSection(context, settings),
              const Divider(),
              _buildStorageSection(context, settings),
              const Divider(),
              _buildAboutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.palette),
      title: Text(l10n.appearance),
      initiallyExpanded: true,
      children: [
        ListTile(
          title: Text(l10n.theme),
          subtitle: Text(_getThemeModeLabel(context, settings.themeMode)),
          trailing: DropdownButton<ThemeMode>(
            value: settings.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                settings.setThemeMode(mode);
              }
            },
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(l10n.system),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(l10n.light),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(l10n.dark),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.language),
          subtitle: Text(_getLanguageLabel(context, settings.locale)),
          trailing: DropdownButton<String?>(
            value: settings.locale?.toString(),
            onChanged: (String? localeCode) {
              if (localeCode == null) {
                settings.setLocale(null);
              } else if (localeCode == 'zh_Hant') {
                settings.setLocale(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
              } else {
                settings.setLocale(Locale(localeCode));
              }
            },
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.system),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(l10n.english),
              ),
              DropdownMenuItem(
                value: 'zh',
                child: Text(l10n.chineseSimplified),
              ),
              DropdownMenuItem(
                value: 'zh_Hant',
                child: Text(l10n.chineseTraditional),
              ),
              DropdownMenuItem(
                value: 'ja',
                child: Text(l10n.japanese),
              ),
              DropdownMenuItem(
                value: 'ko',
                child: Text(l10n.korean),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.fontSize),
          subtitle: Text('${settings.fontSize.toInt()}pt'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              label: '${settings.fontSize.toInt()}pt',
              onChanged: (value) {
                settings.setFontSize(value);
              },
            ),
          ),
        ),
        ListTile(
          title: Text(l10n.lineSpacing),
          subtitle: Text('${settings.lineSpacing.toStringAsFixed(1)}'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.lineSpacing,
              min: 1.0,
              max: 2.5,
              divisions: 15,
              label: settings.lineSpacing.toStringAsFixed(1),
              onChanged: (value) {
                settings.setLineSpacing(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.security),
      title: Text(l10n.security),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: Text(l10n.autoLockTimeout),
          subtitle: Text(_getAutoLockLabel(context, settings.autoLockTimeout)),
          trailing: DropdownButton<Duration>(
            value: settings.autoLockTimeout,
            onChanged: (Duration? duration) {
              if (duration != null) {
                settings.setAutoLockTimeout(duration);
              }
            },
            items: [
              DropdownMenuItem(
                value: const Duration(minutes: 1),
                child: Text(l10n.oneMinute),
              ),
              DropdownMenuItem(
                value: const Duration(minutes: 5),
                child: Text(l10n.fiveMinutes),
              ),
              DropdownMenuItem(
                value: const Duration(minutes: 15),
                child: Text(l10n.fifteenMinutes),
              ),
              DropdownMenuItem(
                value: const Duration(minutes: 30),
                child: Text(l10n.thirtyMinutes),
              ),
              DropdownMenuItem(
                value: const Duration(hours: 1),
                child: Text(l10n.oneHour),
              ),
              DropdownMenuItem(
                value: Duration.zero,
                child: Text(l10n.never),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n.biometricUnlock),
          subtitle: Text(l10n.useFingerprintOrFaceUnlock),
          value: settings.biometricEnabled,
          onChanged: (value) {
            settings.setBiometricEnabled(value);
          },
        ),
        SwitchListTile(
          title: Text(l10n.clearClipboardAfterPaste),
          subtitle: Text(l10n.automaticallyClearClipboardForSecurity),
          value: settings.clearClipboard,
          onChanged: (value) {
            settings.setClearClipboard(value);
          },
        ),
      ],
    );
  }

  Widget _buildEditorSection(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.edit),
      title: Text(l10n.editor),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: Text(l10n.defaultViewMode),
          subtitle: Text(_getViewModeLabel(context, settings.editorViewMode)),
          trailing: DropdownButton<EditorViewMode>(
            value: settings.editorViewMode,
            onChanged: (EditorViewMode? mode) {
              if (mode != null) {
                settings.setEditorViewMode(mode);
              }
            },
            items: [
              DropdownMenuItem(
                value: EditorViewMode.edit,
                child: Text(l10n.editMode),
              ),
              DropdownMenuItem(
                value: EditorViewMode.preview,
                child: Text(l10n.previewMode),
              ),
              DropdownMenuItem(
                value: EditorViewMode.split,
                child: Text(l10n.splitMode),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.autoSaveInterval),
          subtitle: Text(_getAutoSaveLabel(context, settings.autoSaveInterval)),
          trailing: DropdownButton<Duration>(
            value: settings.autoSaveInterval,
            onChanged: (Duration? interval) {
              if (interval != null) {
                settings.setAutoSaveInterval(interval);
              }
            },
            items: [
              DropdownMenuItem(
                value: const Duration(seconds: 10),
                child: Text(l10n.tenSeconds),
              ),
              DropdownMenuItem(
                value: const Duration(seconds: 30),
                child: Text(l10n.thirtySeconds),
              ),
              DropdownMenuItem(
                value: const Duration(minutes: 1),
                child: Text(l10n.oneMinute),
              ),
              DropdownMenuItem(
                value: const Duration(minutes: 5),
                child: Text(l10n.fiveMinutesInterval),
              ),
              DropdownMenuItem(
                value: Duration.zero,
                child: Text(l10n.manualOnly),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n.spellCheck),
          subtitle: Text(l10n.checkSpellingWhileTyping),
          value: settings.spellCheckEnabled,
          onChanged: (value) {
            settings.setSpellCheckEnabled(value);
          },
        ),
      ],
    );
  }

  Widget _buildStorageSection(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.storage),
      title: Text(l10n.storage),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: Text(l10n.dataDirectory),
          subtitle: Text(settings.dataDirectory.isEmpty 
            ? l10n.defaultLocation
            : settings.dataDirectory),
          trailing: IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              _showChangeDataDirectoryDialog(context, settings);
            },
          ),
        ),
        ListTile(
          title: Text(l10n.clearSearchIndex),
          subtitle: Text(l10n.rebuildSearchIndexFromScratch),
          trailing: ElevatedButton(
            onPressed: () {
              _showClearSearchIndexDialog(context);
            },
            child: Text(l10n.clear),
          ),
        ),
        ListTile(
          title: Text(l10n.exportAllData),
          subtitle: Text(l10n.exportAllVaultsAndNotes),
          trailing: ElevatedButton(
            onPressed: () {
              _showExportDataDialog(context);
            },
            child: Text(l10n.export),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.info),
      title: Text(l10n.about),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: Text(l10n.version),
          subtitle: Text(_packageInfo != null 
            ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})' 
            : l10n.loading),
        ),
        ListTile(
          title: Text(l10n.licenses),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'Null Space',
              applicationVersion: _packageInfo?.version ?? '0.1.0',
              applicationIcon: const Icon(Icons.note, size: 48),
            );
          },
        ),
        ListTile(
          title: Text(l10n.sourceCode),
          subtitle: const Text('github.com/shaolonger/null-space'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () {
            _launchUrl('https://github.com/shaolonger/null-space');
          },
        ),
        ListTile(
          title: Text(l10n.resetToDefaults),
          subtitle: Text(l10n.resetAllSettingsToDefaultValues),
          trailing: ElevatedButton(
            onPressed: () {
              _showResetSettingsDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.reset),
          ),
        ),
      ],
    );
  }

  String _getThemeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return l10n.followSystemSetting;
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
    }
  }

  String _getLanguageLabel(BuildContext context, Locale? locale) {
    final l10n = AppLocalizations.of(context)!;
    if (locale == null) {
      return l10n.system;
    }
    switch (locale.toString()) {
      case 'en':
        return l10n.english;
      case 'zh':
        return l10n.chineseSimplified;
      case 'zh_Hant':
        return l10n.chineseTraditional;
      case 'ja':
        return l10n.japanese;
      case 'ko':
        return l10n.korean;
      default:
        return locale.toString();
    }
  }

  String _getAutoLockLabel(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    if (duration == Duration.zero) {
      return l10n.neverLock;
    } else if (duration.inHours > 0) {
      return l10n.lockAfterHours(duration.inHours);
    } else {
      return l10n.lockAfterMinutes(duration.inMinutes);
    }
  }

  String _getViewModeLabel(BuildContext context, EditorViewMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case EditorViewMode.edit:
        return l10n.editOnly;
      case EditorViewMode.preview:
        return l10n.previewOnly;
      case EditorViewMode.split:
        return l10n.sideBySideEditAndPreview;
    }
  }

  String _getAutoSaveLabel(BuildContext context, Duration interval) {
    final l10n = AppLocalizations.of(context)!;
    if (interval == Duration.zero) {
      return l10n.manualSaveOnly;
    } else if (interval.inMinutes > 0) {
      if (interval.inMinutes == 1) {
        return l10n.saveEveryMinute(interval.inMinutes);
      } else {
        return l10n.saveEveryMinutes(interval.inMinutes);
      }
    } else {
      return l10n.saveEverySeconds(interval.inSeconds);
    }
  }

  void _showChangeDataDirectoryDialog(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeDataDirectory),
        content: Text(l10n.changeDataDirectoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showClearSearchIndexDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearSearchIndexTitle),
        content: Text(l10n.clearSearchIndexMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.searchIndexCleared)),
              );
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportAllDataTitle),
        content: Text(l10n.exportAllDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportFeatureComingSoon)),
              );
            },
            child: Text(l10n.export),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettingsTitle),
        content: Text(l10n.resetSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final settings = Provider.of<SettingsProvider>(context, listen: false);
              settings.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsResetToDefaults)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final l10n = AppLocalizations.of(context)!;
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotLaunchUrl(urlString))),
        );
      }
    }
  }
}
