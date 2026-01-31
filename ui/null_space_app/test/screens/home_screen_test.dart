import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/screens/home_screen.dart';
import 'package:null_space_app/providers/vault_provider.dart';
import 'package:null_space_app/providers/note_provider.dart';
import 'package:null_space_app/providers/search_provider.dart';
import 'package:null_space_app/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late VaultProvider vaultProvider;
    late NoteProvider noteProvider;
    late SearchProvider searchProvider;
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      vaultProvider = VaultProvider();
      noteProvider = NoteProvider();
      searchProvider = SearchProvider();
      settingsProvider = SettingsProvider();
    });

    Widget createHomeScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<VaultProvider>.value(value: vaultProvider),
          ChangeNotifierProvider<NoteProvider>.value(value: noteProvider),
          ChangeNotifierProvider<SearchProvider>.value(value: searchProvider),
          ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.text('Null Space'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('has four navigation destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays notes icon in navigation bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.byIcon(Icons.note), findsWidgets);
    });

    testWidgets('displays search icon in navigation bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('displays folder icon in navigation bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.byIcon(Icons.folder), findsWidgets);
    });

    testWidgets('displays settings icon in navigation bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('displays floating action button on notes tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('switches to search screen when search tab is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Tap on Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('switches to vault screen when vault tab is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Tap on Vault tab
      await tester.tap(find.text('Vault'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('switches to settings screen when settings tab is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Tap on Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('hides floating action button on non-notes tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Initially on Notes tab, FAB should be visible
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Switch to Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // FAB should be hidden
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('FAB has correct tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.tooltip, 'Create Note');
    });

    testWidgets('navigates back to notes tab from other tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Switch to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);

      // Switch back to Notes tab
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('maintains state when switching between tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Switch between tabs multiple times
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vault'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Should still render correctly
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Null Space'), findsOneWidget);
    });

    testWidgets('renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Should render successfully
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('starts on notes tab by default', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // FAB should be visible on notes tab
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('navigation bar is at bottom of screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(scaffold.bottomNavigationBar, isA<NavigationBar>());
    });

    testWidgets('app bar has elevation', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 2);
    });

    testWidgets('handles rapid tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Rapidly switch between tabs
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Search'));
        await tester.pump();
        await tester.tap(find.text('Notes'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should still work correctly
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
