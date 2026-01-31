import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
    return ExpansionTile(
      leading: const Icon(Icons.palette),
      title: const Text('Appearance'),
      initiallyExpanded: true,
      children: [
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeModeLabel(settings.themeMode)),
          trailing: DropdownButton<ThemeMode>(
            value: settings.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                settings.setThemeMode(mode);
              }
            },
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Font Size'),
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
          title: const Text('Line Spacing'),
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
    return ExpansionTile(
      leading: const Icon(Icons.security),
      title: const Text('Security'),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: const Text('Auto-lock Timeout'),
          subtitle: Text(_getAutoLockLabel(settings.autoLockTimeout)),
          trailing: DropdownButton<Duration>(
            value: settings.autoLockTimeout,
            onChanged: (Duration? duration) {
              if (duration != null) {
                settings.setAutoLockTimeout(duration);
              }
            },
            items: const [
              DropdownMenuItem(
                value: Duration(minutes: 1),
                child: Text('1 minute'),
              ),
              DropdownMenuItem(
                value: Duration(minutes: 5),
                child: Text('5 minutes'),
              ),
              DropdownMenuItem(
                value: Duration(minutes: 15),
                child: Text('15 minutes'),
              ),
              DropdownMenuItem(
                value: Duration(minutes: 30),
                child: Text('30 minutes'),
              ),
              DropdownMenuItem(
                value: Duration(hours: 1),
                child: Text('1 hour'),
              ),
              DropdownMenuItem(
                value: Duration.zero,
                child: Text('Never'),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('Biometric Unlock'),
          subtitle: const Text('Use fingerprint or face unlock'),
          value: settings.biometricEnabled,
          onChanged: (value) {
            settings.setBiometricEnabled(value);
          },
        ),
        SwitchListTile(
          title: const Text('Clear Clipboard After Paste'),
          subtitle: const Text('Automatically clear clipboard for security'),
          value: settings.clearClipboard,
          onChanged: (value) {
            settings.setClearClipboard(value);
          },
        ),
      ],
    );
  }

  Widget _buildEditorSection(BuildContext context, SettingsProvider settings) {
    return ExpansionTile(
      leading: const Icon(Icons.edit),
      title: const Text('Editor'),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: const Text('Default View Mode'),
          subtitle: Text(_getViewModeLabel(settings.editorViewMode)),
          trailing: DropdownButton<EditorViewMode>(
            value: settings.editorViewMode,
            onChanged: (EditorViewMode? mode) {
              if (mode != null) {
                settings.setEditorViewMode(mode);
              }
            },
            items: const [
              DropdownMenuItem(
                value: EditorViewMode.edit,
                child: Text('Edit'),
              ),
              DropdownMenuItem(
                value: EditorViewMode.preview,
                child: Text('Preview'),
              ),
              DropdownMenuItem(
                value: EditorViewMode.split,
                child: Text('Split'),
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Auto-save Interval'),
          subtitle: Text(_getAutoSaveLabel(settings.autoSaveInterval)),
          trailing: DropdownButton<Duration>(
            value: settings.autoSaveInterval,
            onChanged: (Duration? interval) {
              if (interval != null) {
                settings.setAutoSaveInterval(interval);
              }
            },
            items: const [
              DropdownMenuItem(
                value: Duration(seconds: 10),
                child: Text('10 seconds'),
              ),
              DropdownMenuItem(
                value: Duration(seconds: 30),
                child: Text('30 seconds'),
              ),
              DropdownMenuItem(
                value: Duration(minutes: 1),
                child: Text('1 minute'),
              ),
              DropdownMenuItem(
                value: Duration(minutes: 5),
                child: Text('5 minutes'),
              ),
              DropdownMenuItem(
                value: Duration.zero,
                child: Text('Manual only'),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('Spell Check'),
          subtitle: const Text('Check spelling while typing'),
          value: settings.spellCheckEnabled,
          onChanged: (value) {
            settings.setSpellCheckEnabled(value);
          },
        ),
      ],
    );
  }

  Widget _buildStorageSection(BuildContext context, SettingsProvider settings) {
    return ExpansionTile(
      leading: const Icon(Icons.storage),
      title: const Text('Storage'),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: const Text('Data Directory'),
          subtitle: Text(settings.dataDirectory.isEmpty 
            ? 'Default location' 
            : settings.dataDirectory),
          trailing: IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              _showChangeDataDirectoryDialog(context, settings);
            },
          ),
        ),
        ListTile(
          title: const Text('Clear Search Index'),
          subtitle: const Text('Rebuild search index from scratch'),
          trailing: ElevatedButton(
            onPressed: () {
              _showClearSearchIndexDialog(context);
            },
            child: const Text('Clear'),
          ),
        ),
        ListTile(
          title: const Text('Export All Data'),
          subtitle: const Text('Export all vaults and notes'),
          trailing: ElevatedButton(
            onPressed: () {
              _showExportDataDialog(context);
            },
            child: const Text('Export'),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.info),
      title: const Text('About'),
      initiallyExpanded: false,
      children: [
        ListTile(
          title: const Text('Version'),
          subtitle: Text(_packageInfo != null 
            ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})' 
            : 'Loading...'),
        ),
        ListTile(
          title: const Text('Licenses'),
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
          title: const Text('Source Code'),
          subtitle: const Text('github.com/shaolonger/null-space'),
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () {
            _launchUrl('https://github.com/shaolonger/null-space');
          },
        ),
        ListTile(
          title: const Text('Reset to Defaults'),
          subtitle: const Text('Reset all settings to default values'),
          trailing: ElevatedButton(
            onPressed: () {
              _showResetSettingsDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system setting';
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
    }
  }

  String _getAutoLockLabel(Duration duration) {
    if (duration == Duration.zero) {
      return 'Never lock automatically';
    } else if (duration.inHours > 0) {
      return 'Lock after ${duration.inHours} hour${duration.inHours > 1 ? "s" : ""}';
    } else {
      return 'Lock after ${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""}';
    }
  }

  String _getViewModeLabel(EditorViewMode mode) {
    switch (mode) {
      case EditorViewMode.edit:
        return 'Edit only';
      case EditorViewMode.preview:
        return 'Preview only';
      case EditorViewMode.split:
        return 'Side-by-side edit and preview';
    }
  }

  String _getAutoSaveLabel(Duration interval) {
    if (interval == Duration.zero) {
      return 'Manual save only';
    } else if (interval.inMinutes > 0) {
      return 'Save every ${interval.inMinutes} minute${interval.inMinutes > 1 ? "s" : ""}';
    } else {
      return 'Save every ${interval.inSeconds} seconds';
    }
  }

  void _showChangeDataDirectoryDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Data Directory'),
        content: const Text(
          'This feature allows you to change where your vaults and notes are stored. '
          'Implementation coming soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearSearchIndexDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search Index'),
        content: const Text(
          'This will clear the search index and rebuild it from scratch. '
          'This may take a few moments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search index cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export All Data'),
        content: const Text(
          'This will export all your vaults and notes to a ZIP file. '
          'You can then back up or transfer this file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final settings = Provider.of<SettingsProvider>(context, listen: false);
              settings.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }
}
