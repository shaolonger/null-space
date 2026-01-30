import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/vault.dart';
import 'package:null_space_app/providers/vault_provider.dart';
import 'package:null_space_app/screens/vault_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('VaultScreen Widget Tests', () {
    late VaultProvider vaultProvider;

    setUp(() {
      vaultProvider = VaultProvider();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<VaultProvider>.value(
        value: vaultProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: VaultScreen(),
          ),
        ),
      );
    }

    testWidgets('displays loading indicator during initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Wait for initialization
      await tester.pumpAndSettle();

      // Check for action buttons
      expect(find.text('Create Vault'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
    });

    testWidgets('displays empty state when no vaults', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Wait for initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show empty state
      expect(find.text('No Vaults'), findsAny);
      expect(find.text('Create a new vault to get started'), findsAny);
    });

    testWidgets('create vault button is present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Wait for initialization
      await tester.pumpAndSettle();

      // Check for create button
      expect(find.widgetWithIcon(ElevatedButton, Icons.add), findsOneWidget);
    });

    testWidgets('import button is present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Wait for initialization
      await tester.pumpAndSettle();

      // Check for import button
      expect(find.widgetWithIcon(ElevatedButton, Icons.upload), findsOneWidget);
    });

    testWidgets('retry button appears on initialization error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Wait for initialization to fail (service initialization will fail in test environment)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check for retry button on error state
      expect(find.text('Retry'), findsAny);
    });
  });

  group('VaultProvider Integration', () {
    late VaultProvider vaultProvider;

    setUp(() {
      vaultProvider = VaultProvider();
    });

    testWidgets('updates when vaults are added to provider',
        (WidgetTester tester) async {
      final widget = ChangeNotifierProvider<VaultProvider>.value(
        value: vaultProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: VaultScreen(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Add a vault to the provider
      final testVault = Vault(
        id: 'test-vault-1',
        name: 'Test Vault',
        description: 'Test vault description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'test-salt',
      );

      vaultProvider.addVault(testVault);
      await tester.pumpAndSettle();

      // Note: Actual vault display requires VaultService initialization
      // which won't work in test environment, so we just verify the provider
      expect(vaultProvider.vaults.length, 1);
      expect(vaultProvider.vaults.first.name, 'Test Vault');
    });

    testWidgets('removes vault from provider', (WidgetTester tester) async {
      final widget = ChangeNotifierProvider<VaultProvider>.value(
        value: vaultProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: VaultScreen(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Add and then remove a vault
      final testVault = Vault(
        id: 'test-vault-1',
        name: 'Test Vault',
        description: 'Test vault description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'test-salt',
      );

      vaultProvider.addVault(testVault);
      await tester.pumpAndSettle();

      expect(vaultProvider.vaults.length, 1);

      vaultProvider.removeVault(testVault.id);
      await tester.pumpAndSettle();

      expect(vaultProvider.vaults.length, 0);
    });
  });
}
