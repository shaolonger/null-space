import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/providers/settings_provider.dart';
import 'package:null_space_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settingsProvider = SettingsProvider();
      await settingsProvider.loadSettings();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('displays settings screen with app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays all settings sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('appearance section shows theme setting', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Appearance section should be initially expanded
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('appearance section shows font size setting', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Font Size'), findsOneWidget);
      expect(find.text('16pt'), findsOneWidget); // Default value
    });

    testWidgets('appearance section shows line spacing setting', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Line Spacing'), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget); // Default value
    });

    testWidgets('changes theme mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the theme dropdown
      final dropdown = find.byType(DropdownButton<ThemeMode>);
      expect(dropdown, findsOneWidget);

      // Initially should be system
      expect(settingsProvider.themeMode, ThemeMode.system);

      // Tap the dropdown
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Select Light theme
      await tester.tap(find.text('Light').last);
      await tester.pumpAndSettle();

      expect(settingsProvider.themeMode, ThemeMode.light);
    });

    testWidgets('changes font size with slider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find font size slider
      final sliders = find.byType(Slider);
      expect(sliders, findsAtLeastNWidgets(1));

      // Get the first slider (font size slider)
      final fontSizeSlider = sliders.first;

      // Drag slider to change font size
      await tester.drag(fontSizeSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Font size should have changed from default 16.0
      expect(settingsProvider.fontSize, isNot(16.0));
    });

    testWidgets('expands and collapses security section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Security section should not show details initially
      expect(find.text('Auto-lock Timeout'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      // Now details should be visible
      expect(find.text('Auto-lock Timeout'), findsOneWidget);
      expect(find.text('Biometric Unlock'), findsOneWidget);
      expect(find.text('Clear Clipboard After Paste'), findsOneWidget);
    });

    testWidgets('toggles biometric switch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand security section
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      // Find biometric switch
      final biometricSwitch = find.widgetWithText(SwitchListTile, 'Biometric Unlock');
      expect(biometricSwitch, findsOneWidget);

      expect(settingsProvider.biometricEnabled, false);

      // Toggle switch
      await tester.tap(biometricSwitch);
      await tester.pumpAndSettle();

      expect(settingsProvider.biometricEnabled, true);
    });

    testWidgets('toggles clear clipboard switch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand security section
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      // Find clear clipboard switch
      final clipboardSwitch = find.widgetWithText(SwitchListTile, 'Clear Clipboard After Paste');
      expect(clipboardSwitch, findsOneWidget);

      expect(settingsProvider.clearClipboard, true);

      // Toggle switch
      await tester.tap(clipboardSwitch);
      await tester.pumpAndSettle();

      expect(settingsProvider.clearClipboard, false);
    });

    testWidgets('shows editor section settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand editor section
      await tester.tap(find.text('Editor'));
      await tester.pumpAndSettle();

      expect(find.text('Default View Mode'), findsOneWidget);
      expect(find.text('Auto-save Interval'), findsOneWidget);
      expect(find.text('Spell Check'), findsOneWidget);
    });

    testWidgets('toggles spell check switch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand editor section
      await tester.tap(find.text('Editor'));
      await tester.pumpAndSettle();

      // Find spell check switch
      final spellCheckSwitch = find.widgetWithText(SwitchListTile, 'Spell Check');
      expect(spellCheckSwitch, findsOneWidget);

      expect(settingsProvider.spellCheckEnabled, true);

      // Toggle switch
      await tester.tap(spellCheckSwitch);
      await tester.pumpAndSettle();

      expect(settingsProvider.spellCheckEnabled, false);
    });

    testWidgets('shows storage section settings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand storage section
      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();

      expect(find.text('Data Directory'), findsOneWidget);
      expect(find.text('Clear Search Index'), findsOneWidget);
      expect(find.text('Export All Data'), findsOneWidget);
    });

    testWidgets('shows clear search index dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand storage section
      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.text('Clear').first);
      await tester.pumpAndSettle();

      expect(find.text('Clear Search Index'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows export data dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand storage section
      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();

      // Tap export button
      await tester.tap(find.text('Export').first);
      await tester.pumpAndSettle();

      expect(find.text('Export All Data'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows about section information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand about section
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('Licenses'), findsOneWidget);
      expect(find.text('Source Code'), findsOneWidget);
      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('shows reset settings dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand about section
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.text('Reset').first);
      await tester.pumpAndSettle();

      expect(find.text('Reset Settings'), findsOneWidget);
      expect(find.text('Are you sure you want to reset all settings to their default values?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('resets settings when confirmed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Change some settings
      await settingsProvider.setThemeMode(ThemeMode.dark);
      await settingsProvider.setFontSize(20.0);
      
      expect(settingsProvider.themeMode, ThemeMode.dark);
      expect(settingsProvider.fontSize, 20.0);

      // Expand about section
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.text('Reset').first);
      await tester.pumpAndSettle();

      // Confirm reset
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();

      // Settings should be back to defaults
      expect(settingsProvider.themeMode, ThemeMode.system);
      expect(settingsProvider.fontSize, 16.0);

      // Check for snackbar
      expect(find.text('Settings reset to defaults'), findsOneWidget);
    });

    testWidgets('does not reset settings when cancelled', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Change some settings
      await settingsProvider.setThemeMode(ThemeMode.dark);
      
      expect(settingsProvider.themeMode, ThemeMode.dark);

      // Expand about section
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.text('Reset').first);
      await tester.pumpAndSettle();

      // Cancel reset
      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();

      // Settings should not have changed
      expect(settingsProvider.themeMode, ThemeMode.dark);
    });
  });
}
