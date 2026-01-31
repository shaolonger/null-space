import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/vault.dart';
import 'package:null_space_app/widgets/vault_card.dart';

void main() {
  group('VaultCard Widget Tests', () {
    late Vault testVault;
    bool tapped = false;
    bool deleted = false;
    bool exported = false;
    bool renamed = false;

    setUp(() {
      tapped = false;
      deleted = false;
      exported = false;
      renamed = false;
      testVault = Vault(
        id: 'vault-123',
        name: 'Test Vault',
        description: 'A test vault for testing',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        salt: 'test-salt',
      );
    });

    testWidgets('displays vault name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Vault'), findsOneWidget);
    });

    testWidgets('displays vault description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(find.text('A test vault for testing'), findsOneWidget);
    });

    testWidgets('hides description when empty', (WidgetTester tester) async {
      testVault.description = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Vault'), findsOneWidget);
      // Description should not be displayed
      expect(find.text(''), findsWidgets);
    });

    testWidgets('displays lock icon when locked', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsNothing);
    });

    testWidgets('displays unlock icon when unlocked',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: false,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('displays note count when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
              noteCount: 42,
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.note), findsOneWidget);
    });

    testWidgets('hides note count when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      // Note icon should not be displayed without note count
      expect(find.byIcon(Icons.note), findsNothing);
    });

    testWidgets('displays relative date format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      // Should show "Updated 2h ago" for 2 hours ago
      expect(find.textContaining('Updated'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(tapped, false);
      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });

    testWidgets('shows popup menu button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('popup menu shows export option', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('popup menu shows delete option', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('popup menu shows rename option when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
              onRename: () => renamed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('popup menu hides rename option when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('calls onExport when export is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(exported, false);
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      expect(exported, true);
    });

    testWidgets('calls onRename when rename is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
              onRename: () => renamed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(renamed, false);
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      expect(renamed, true);
    });

    testWidgets('shows delete confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Vault'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete "Test Vault"?'),
        findsOneWidget,
      );
    });

    testWidgets('delete confirmation dialog has cancel button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(deleted, false);
    });

    testWidgets('calls onDelete when delete is confirmed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, false);
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(deleted, true);
    });

    testWidgets('shows elevated card when selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                VaultCard(
                  vault: testVault,
                  isLocked: true,
                  onTap: () => tapped = true,
                  onDelete: () => deleted = true,
                  onExport: () => exported = true,
                  isSelected: true,
                ),
                VaultCard(
                  vault: testVault,
                  isLocked: true,
                  onTap: () => tapped = true,
                  onDelete: () => deleted = true,
                  onExport: () => exported = true,
                  isSelected: false,
                ),
              ],
            ),
          ),
        ),
      );

      final cards = tester.widgetList<Card>(find.byType(Card));
      expect(cards.length, 2);
      // Selected card should have higher elevation
      expect(cards.first.elevation, 4);
      expect(cards.last.elevation, 1);
    });

    testWidgets('handles long vault name', (WidgetTester tester) async {
      testVault.name = 'A' * 100; // Very long name

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(VaultCard), findsOneWidget);
    });

    testWidgets('handles long description', (WidgetTester tester) async {
      testVault.description = 'B' * 200; // Very long description

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(VaultCard), findsOneWidget);
    });

    testWidgets('handles zero note count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
              noteCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('handles large note count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultCard(
              vault: testVault,
              isLocked: true,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
              onExport: () => exported = true,
              noteCount: 9999,
            ),
          ),
        ),
      );

      expect(find.text('9999'), findsOneWidget);
    });
  });
}
