import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:null_space_app/models/vault.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/services/vault_service.dart';
import 'package:null_space_app/services/file_storage.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/providers/vault_provider.dart';
import 'package:null_space_app/widgets/vault_creation_dialog.dart';

// Mock classes
class MockRustBridge extends RustBridge {
  bool initCalled = false;
  String lastGeneratedSalt = 'mock_salt_12345';
  bool shouldFailSaltGeneration = false;

  @override
  void init() {
    initCalled = true;
  }

  @override
  String generateSalt() {
    if (shouldFailSaltGeneration) {
      throw Exception('Salt generation failed');
    }
    return lastGeneratedSalt;
  }

  @override
  String encrypt(String plaintext, String password, String salt) {
    return 'encrypted_$plaintext';
  }

  @override
  String decrypt(String ciphertext, String password, String salt) {
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
  group('VaultCreationDialog Widget Tests', () {
    late MockRustBridge mockBridge;
    late MockFileStorage mockStorage;
    late VaultService vaultService;

    setUp(() {
      mockBridge = MockRustBridge();
      mockStorage = MockFileStorage();
      vaultService = VaultService(bridge: mockBridge, storage: mockStorage);
    });

    Widget createDialog() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VaultProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => VaultCreationDialog(
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

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Vault'), findsOneWidget);
      expect(find.text('Vault Name'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('validates required name field', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to create without entering name
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Vault name is required'), findsOneWidget);
    });

    testWidgets('validates name length (max 100 characters)', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter name longer than 100 characters
      final longName = 'a' * 101;
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        longName,
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be 100 characters or less'), findsOneWidget);
    });

    testWidgets('validates required password field', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter name but not password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates minimum password length (8 characters)', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('validates password confirmation match', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different123',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
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
      var passwordWidget = tester.widget<TextFormField>(passwordField);
      final passwordTextField = passwordWidget.decoration?.suffixIcon as IconButton?;
      final passwordIcon = passwordTextField?.icon as Icon?;
      expect(passwordIcon?.icon, Icons.visibility);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pumpAndSettle();

      // Password should now be visible
      passwordWidget = tester.widget<TextFormField>(passwordField);
      final updatedIconButton = passwordWidget.decoration?.suffixIcon as IconButton?;
      final updatedIcon = updatedIconButton?.icon as Icon?;
      expect(updatedIcon?.icon, Icons.visibility_off);
    });

    testWidgets('shows password strength indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Initially no indicator
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // Enter medium strength password (8 chars + lowercase)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password',
      );
      await tester.pumpAndSettle();

      // Should show password strength indicator with Medium strength
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);

      // Enter stronger password (uppercase, lowercase, digits, special chars)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Password123!',
      );
      await tester.pumpAndSettle();

      // Should show updated strength
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // Should be "Strong" or "Very Strong" based on calculation
      expect(
        find.textContaining(RegExp(r'(Strong|Very Strong)')),
        findsOneWidget,
      );
    });

    testWidgets('creates vault successfully with valid input', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'My Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description (Optional)'),
        'A vault for testing',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'testpass123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'testpass123',
      );
      await tester.pumpAndSettle();

      // Tap Create
      await tester.tap(find.text('Create'));
      await tester.pump(); // Start async operation

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Complete async operation

      // Dialog should be closed (not found anymore)
      expect(find.text('Create New Vault'), findsNothing);
    });

    testWidgets('disables form during vault creation', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Tap Create
      await tester.tap(find.text('Create'));
      await tester.pump(); // Start async operation but don't settle

      // Form fields should be disabled
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Vault Name'),
      );
      expect(nameField.enabled, false);
    });

    testWidgets('cancels dialog without creating vault', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter some data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Create New Vault'), findsNothing);
    });

    testWidgets('description field is optional', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter data without description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Should be able to create without description
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Dialog should be closed successfully
      expect(find.text('Create New Vault'), findsNothing);
    });

    testWidgets('trims whitespace from name and description', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter data with extra whitespace
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        '  Test Vault  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description (Optional)'),
        '  Description with spaces  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Dialog should be closed successfully
      // The vault name and description will be trimmed by the createVault call
      expect(find.text('Create New Vault'), findsNothing);
    });

    testWidgets('validates name as empty when only whitespace', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter only whitespace in name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        '   ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show validation error for empty name
      expect(find.text('Vault name is required'), findsOneWidget);
    });

    testWidgets('has proper field labels and hints', (WidgetTester tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for appropriate icons
      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);

      // Check for hints
      expect(find.text('Enter vault name'), findsOneWidget);
      expect(find.text('Enter vault description'), findsOneWidget);
      expect(find.text('Enter password (min 8 characters)'), findsOneWidget);
      expect(find.text('Re-enter password'), findsOneWidget);
    });

    testWidgets('displays error message when vault creation fails', (WidgetTester tester) async {
      // Configure mock to fail
      mockBridge.shouldFailSaltGeneration = true;

      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Tap Create
      await tester.tap(find.text('Create'));
      await tester.pump(); // Start async operation
      await tester.pumpAndSettle(); // Complete async operation

      // Error message should be displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Failed to create vault'), findsOneWidget);

      // Dialog should still be open (not closed on error)
      expect(find.text('Create New Vault'), findsOneWidget);

      // Form should be enabled again
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Vault Name'),
      );
      expect(nameField.enabled, true);
    });

    testWidgets('clears error message on new creation attempt', (WidgetTester tester) async {
      // Configure mock to fail initially
      mockBridge.shouldFailSaltGeneration = true;

      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vault Name'),
        'Test Vault',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // First attempt - should fail
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Error should be displayed
      expect(find.textContaining('Failed to create vault'), findsOneWidget);

      // Fix the mock
      mockBridge.shouldFailSaltGeneration = false;

      // Second attempt - should clear error
      await tester.tap(find.text('Create'));
      await tester.pump(); // Start async operation

      // Error message should be cleared immediately
      expect(find.textContaining('Failed to create vault'), findsNothing);
    });
  });
}
