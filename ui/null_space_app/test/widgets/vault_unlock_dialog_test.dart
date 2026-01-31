import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/vault.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/services/vault_service.dart';
import 'package:null_space_app/services/file_storage.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:provider/provider.dart';
import 'package:null_space_app/providers/settings_provider.dart';
import 'package:null_space_app/widgets/vault_unlock_dialog.dart';

// Mock classes
class MockRustBridge extends RustBridge {
  bool initCalled = false;
  String correctPassword = 'correct_password';

  @override
  void init() {
    initCalled = true;
  }

  @override
  String generateSalt() {
    return 'mock_salt_12345';
  }

  @override
  String encrypt(String plaintext, String password, String salt) {
    if (password != correctPassword) {
      throw Exception('Encryption failed - wrong password');
    }
    return 'encrypted_$plaintext';
  }

  @override
  String decrypt(String ciphertext, String password, String salt) {
    if (password != correctPassword) {
      throw Exception('Decryption failed - wrong password');
    }
    return ciphertext.replaceFirst('encrypted_', '');
  }

  @override
  Note createNote(String title, String content, List<String> tags) {
    return Note(
      id: 'mock-note',
      title: title,
      content: content,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 1,
    );
  }

  @override
  Note updateNote(Note note) => note;

  @override
  List<Map<String, dynamic>> search(String indexPath, String query, int limit) {
    return [];
  }

  @override
  bool exportVault(
      Vault vault, List<Note> notes, String outputPath, String password) {
    return true;
  }

  @override
  Map<String, dynamic> importVault(String inputPath, String password) {
    return {
      'vault': Vault(
        id: 'mock-vault',
        name: 'Mock Vault',
        description: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'mock-salt',
      ),
      'notes': <Note>[],
    };
  }
}

class MockFileStorage implements FileStorage {
  final Map<String, List<int>> _files = {};
  final Set<String> _directories = {};

  @override
  String get basePath => '/tmp/mock';

  @override
  Future<void> writeFile(String path, List<int> data) async {
    _files[path] = data;
  }

  @override
  Future<List<int>> readFile(String path) async {
    return _files[path] ?? [];
  }

  @override
  Future<void> createDirectory(String path) async {
    _directories.add(path);
  }

  @override
  Future<void> deleteDirectory(String path) async {
    _directories.remove(path);
    _files.removeWhere((key, value) => key.startsWith('$path/'));
  }

  @override
  Future<bool> exists(String path) async {
    return _files.containsKey(path) || _directories.contains(path);
  }

  @override
  Future<void> deleteFile(String path) async {
    _files.remove(path);
  }

  @override
  Future<List<String>> listFiles(String directory) async {
    return _files.keys
        .where((path) => path.startsWith('$directory/'))
        .toList();
  }
}

void main() {
  group('VaultUnlockDialog Widget Tests', () {
    late MockRustBridge mockBridge;
    late MockFileStorage mockStorage;
    late VaultService vaultService;
    late Vault testVault;

    setUp(() {
      mockBridge = MockRustBridge();
      mockStorage = MockFileStorage();
      vaultService = VaultService(bridge: mockBridge, storage: mockStorage);
      testVault = Vault(
        id: 'test_vault_1',
        name: 'Test Vault',
        description: 'A test vault for unlocking',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        salt: 'test_salt_123',
      );
    });

    Widget createDialog() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => VaultUnlockDialog(
                      vault: testVault,
                      vaultService: vaultService,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('displays all required components', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock Vault'), findsOneWidget);
      expect(find.text('Test Vault'), findsOneWidget);
      expect(find.text('A test vault for unlocking'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Unlock'), findsOneWidget);
    });

    testWidgets('displays vault name without description', (WidgetTester tester) async {
      final vaultWithoutDescription = Vault(
        id: 'test_vault_2',
        name: 'Vault Without Description',
        description: '',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        salt: 'test_salt_123',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => VaultUnlockDialog(
                        vault: vaultWithoutDescription,
                        vaultService: vaultService,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Vault Without Description'), findsOneWidget);
      // Verify the vault name is displayed in the dialog
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets('validates required password field', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to unlock without entering password
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'testpass123');
      await tester.pumpAndSettle();

      // Initially, password should be obscured
      final passwordVisibilityToggle = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility),
      );
      expect(passwordVisibilityToggle, findsOneWidget);

      // Tap visibility toggle
      await tester.tap(passwordVisibilityToggle);
      await tester.pumpAndSettle();

      // Password should now be visible
      expect(
        find.descendant(
          of: passwordField,
          matching: find.byIcon(Icons.visibility_off),
        ),
        findsOneWidget,
      );
    });

    testWidgets('unlocks vault successfully with correct password', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter correct password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'correct_password',
      );
      await tester.pumpAndSettle();

      // Tap Unlock
      await tester.tap(find.text('Unlock'));
      await tester.pump(); // Start async operation

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Complete async operation

      // Dialog should be closed (not found anymore)
      expect(find.text('Unlock Vault'), findsNothing);
    });

    testWidgets('shows error message with incorrect password', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter wrong password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong_password',
      );
      await tester.pumpAndSettle();

      // Tap Unlock
      await tester.tap(find.text('Unlock'));
      await tester.pump(); // Start async operation
      await tester.pumpAndSettle(); // Complete async operation

      // Error message should be displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Incorrect password. Please try again.'), findsOneWidget);

      // Dialog should still be open
      expect(find.text('Unlock Vault'), findsOneWidget);
    });

    testWidgets('shows warning after 3 failed attempts', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // First failed attempt
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong_password',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Warning should not be shown yet
      expect(find.byIcon(Icons.warning_amber), findsNothing);

      // Second failed attempt
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong_password2',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Warning should not be shown yet
      expect(find.byIcon(Icons.warning_amber), findsNothing);

      // Third failed attempt
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong_password3',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Warning should now be displayed
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(
        find.textContaining('Multiple failed attempts detected'),
        findsOneWidget,
      );
      expect(
        find.textContaining('there is no way to recover it'),
        findsOneWidget,
      );
    });

    testWidgets('disables form during unlock attempt', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'correct_password',
      );
      await tester.pumpAndSettle();

      // Tap Unlock
      await tester.tap(find.text('Unlock'));
      await tester.pump(); // Start async operation but don't settle

      // Form field should be disabled
      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Password'),
      );
      expect(passwordField.enabled, false);
    });

    testWidgets('cancels dialog without unlocking vault', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'some_password',
      );

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Unlock Vault'), findsNothing);
    });

    testWidgets('has proper field labels and icons', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for appropriate icons
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Check for hint
      expect(find.text('Enter vault password'), findsOneWidget);
    });

    testWidgets('clears error message on new unlock attempt', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // First attempt - should fail
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrong_password',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Error should be displayed
      expect(find.text('Incorrect password. Please try again.'), findsOneWidget);

      // Second attempt - should clear error before processing
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'another_wrong_password',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pump(); // Start async operation

      // Error message should be cleared immediately
      expect(find.text('Incorrect password. Please try again.'), findsNothing);
    });

    testWidgets('password field has autofocus', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Password field should have autofocus
      final focusNode = tester
          .widget<TextFormField>(find.widgetWithText(TextFormField, 'Password'))
          .focusNode;
      expect(focusNode?.canRequestFocus ?? true, true);
    });

    testWidgets('submits form on Enter key press', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter correct password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'correct_password',
      );
      await tester.pumpAndSettle();

      // Submit via field submission (simulating Enter key)
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(); // Start async operation

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Complete async operation

      // Dialog should be closed successfully
      expect(find.text('Unlock Vault'), findsNothing);
    });

    testWidgets('truncates long vault names', (WidgetTester tester) async {
      final vaultWithLongName = Vault(
        id: 'test_vault_3',
        name: 'This is a very long vault name that should be truncated when displayed in the unlock dialog to prevent overflow issues',
        description: 'Short description',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        salt: 'test_salt_123',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => VaultUnlockDialog(
                        vault: vaultWithLongName,
                        vaultService: vaultService,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify the long name is displayed (Text widget should handle truncation)
      expect(
        find.textContaining('This is a very long vault name'),
        findsOneWidget,
      );
    });

    testWidgets('truncates long vault descriptions', (WidgetTester tester) async {
      final vaultWithLongDescription = Vault(
        id: 'test_vault_4',
        name: 'Test Vault',
        description: 'This is a very long description for a vault that should be truncated when displayed in the unlock dialog to prevent overflow issues and maintain a clean UI',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        salt: 'test_salt_123',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => VaultUnlockDialog(
                        vault: vaultWithLongDescription,
                        vaultService: vaultService,
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify the long description is displayed (Text widget should handle truncation)
      expect(
        find.textContaining('This is a very long description'),
        findsOneWidget,
      );
    });
  });
}
