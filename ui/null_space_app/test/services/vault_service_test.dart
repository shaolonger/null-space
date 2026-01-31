/// Unit tests for VaultService
/// 
/// Tests the business logic layer for vault operations to ensure proper
/// integration between the Rust bridge, encryption, and file storage.
/// 
/// Note: These tests require the Rust library to be built and available.
/// Run `cargo build --release` in the core/null-space-core directory first.

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/services/file_storage.dart';
import 'package:null_space_app/services/vault_service.dart';

void main() {
  group('VaultService', () {
    late RustBridge bridge;
    late FileStorage storage;
    late VaultService service;
    late Directory tempDir;

    setUp(() async {
      // Initialize Rust bridge
      bridge = RustBridge();
      bridge.init();

      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('vault_service_test_');
      storage = FileStorage.withBasePath(tempDir.path);

      // Create service
      service = VaultService(bridge: bridge, storage: storage);
    });

    tearDown(() async {
      // Clean up
      bridge.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('createVault should create a new vault with unique salt', () async {
      final vault = await service.createVault(
        name: 'Test Vault',
        description: 'A test vault',
        password: 'test_password_123',
      );

      expect(vault.name, equals('Test Vault'));
      expect(vault.description, equals('A test vault'));
      expect(vault.id, isNotEmpty);
      expect(vault.salt, isNotEmpty);
      expect(vault.createdAt, isNotNull);
      expect(vault.updatedAt, isNotNull);

      // Verify vault directory structure was created
      expect(await storage.exists('vaults/${vault.id}'), isTrue);
      expect(await storage.exists('vaults/${vault.id}/notes'), isTrue);
      expect(await storage.exists('vaults/${vault.id}/index'), isTrue);

      // Verify vault metadata was saved
      expect(await storage.exists('vaults/${vault.id}/vault.json'), isTrue);

      // Verify vault was added to the list
      final vaults = await service.listVaults();
      expect(vaults.length, equals(1));
      expect(vaults[0].id, equals(vault.id));
    });

    test('createVault should create vaults with unique salts', () async {
      final vault1 = await service.createVault(
        name: 'Vault 1',
        description: 'First vault',
        password: 'password1',
      );

      final vault2 = await service.createVault(
        name: 'Vault 2',
        description: 'Second vault',
        password: 'password2',
      );

      expect(vault1.salt, isNot(equals(vault2.salt)));
      expect(vault1.id, isNot(equals(vault2.id)));
    });

    test('unlockVault should return true for correct password', () async {
      final vault = await service.createVault(
        name: 'Test Vault',
        description: 'Test',
        password: 'correct_password',
      );

      final unlocked = await service.unlockVault(
        vault: vault,
        password: 'correct_password',
      );

      expect(unlocked, isTrue);
      expect(service.isVaultUnlocked(vault.id), isTrue);
    });

    test('unlockVault should return false for incorrect password', () async {
      final vault = await service.createVault(
        name: 'Test Vault',
        description: 'Test',
        password: 'correct_password',
      );

      final unlocked = await service.unlockVault(
        vault: vault,
        password: 'wrong_password',
      );

      expect(unlocked, isFalse);
      expect(service.isVaultUnlocked(vault.id), isFalse);
    });

    test('lockVault should remove vault from unlocked list', () async {
      final vault = await service.createVault(
        name: 'Test Vault',
        description: 'Test',
        password: 'test_password',
      );

      await service.unlockVault(
        vault: vault,
        password: 'test_password',
      );

      expect(service.isVaultUnlocked(vault.id), isTrue);

      service.lockVault(vaultId: vault.id);

      expect(service.isVaultUnlocked(vault.id), isFalse);
      expect(service.getVaultPassword(vault.id), isNull);
    });

    test('getVaultPassword should return password for unlocked vault',
        () async {
      final vault = await service.createVault(
        name: 'Test Vault',
        description: 'Test',
        password: 'test_password',
      );

      await service.unlockVault(
        vault: vault,
        password: 'test_password',
      );

      final password = service.getVaultPassword(vault.id);
      expect(password, equals('test_password'));
    });

    test('listVaults should return empty list when no vaults exist', () async {
      final vaults = await service.listVaults();
      expect(vaults, isEmpty);
    });

    test('listVaults should return all created vaults', () async {
      final vault1 = await service.createVault(
        name: 'Vault 1',
        description: 'First',
        password: 'pass1',
      );

      final vault2 = await service.createVault(
        name: 'Vault 2',
        description: 'Second',
        password: 'pass2',
      );

      final vault3 = await service.createVault(
        name: 'Vault 3',
        description: 'Third',
        password: 'pass3',
      );

      final vaults = await service.listVaults();
      expect(vaults.length, equals(3));

      final vaultIds = vaults.map((v) => v.id).toList();
      expect(vaultIds, contains(vault1.id));
      expect(vaultIds, contains(vault2.id));
      expect(vaultIds, contains(vault3.id));
    });

    test('listVaults should persist across service instances', () async {
      final vault = await service.createVault(
        name: 'Persistent Vault',
        description: 'Should persist',
        password: 'password',
      );

      // Create a new service instance with the same storage
      final newService = VaultService(bridge: bridge, storage: storage);
      final vaults = await newService.listVaults();

      expect(vaults.length, equals(1));
      expect(vaults[0].id, equals(vault.id));
      expect(vaults[0].name, equals(vault.name));
    });

    test('deleteVault should remove vault and its contents', () async {
      final vault = await service.createVault(
        name: 'To Delete',
        description: 'Will be deleted',
        password: 'password',
      );

      // Verify vault exists
      expect(await storage.exists('vaults/${vault.id}'), isTrue);
      final vaultsBefore = await service.listVaults();
      expect(vaultsBefore.length, equals(1));

      // Delete vault
      await service.deleteVault(vaultId: vault.id);

      // Verify vault is gone
      expect(await storage.exists('vaults/${vault.id}'), isFalse);
      final vaultsAfter = await service.listVaults();
      expect(vaultsAfter, isEmpty);
    });

    test('deleteVault should lock vault if unlocked', () async {
      final vault = await service.createVault(
        name: 'To Delete',
        description: 'Will be deleted',
        password: 'password',
      );

      await service.unlockVault(vault: vault, password: 'password');
      expect(service.isVaultUnlocked(vault.id), isTrue);

      await service.deleteVault(vaultId: vault.id);

      expect(service.isVaultUnlocked(vault.id), isFalse);
    });

    test('exportVault should create a ZIP file', () async {
      final vault = await service.createVault(
        name: 'Export Test',
        description: 'For export',
        password: 'password',
      );

      // Create some test notes
      final notes = [
        Note(
          id: 'note1',
          title: 'Note 1',
          content: 'Content 1',
          tags: ['test'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        ),
        Note(
          id: 'note2',
          title: 'Note 2',
          content: 'Content 2',
          tags: ['test', 'export'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        ),
      ];

      final outputPath = '${tempDir.path}/export_test.zip';

      final resultPath = await service.exportVault(
        vault: vault,
        notes: notes,
        outputPath: outputPath,
        password: 'password',
      );

      expect(resultPath, equals(outputPath));
      expect(await File(outputPath).exists(), isTrue);

      // Verify the file is not empty
      final fileSize = await File(outputPath).length();
      expect(fileSize, greaterThan(0));
    });

    test('importVault should import vault and notes', () async {
      // First, create and export a vault
      final originalVault = await service.createVault(
        name: 'Original Vault',
        description: 'To be exported',
        password: 'password',
      );

      final notes = [
        Note(
          id: 'note1',
          title: 'Test Note',
          content: 'Test Content',
          tags: ['import', 'test'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        ),
      ];

      final exportPath = '${tempDir.path}/export.zip';
      await service.exportVault(
        vault: originalVault,
        notes: notes,
        outputPath: exportPath,
        password: 'password',
      );

      // Delete the original vault
      await service.deleteVault(vaultId: originalVault.id);

      // Import the vault
      final (importedVault, importedNotes) = await service.importVault(
        inputPath: exportPath,
        password: 'password',
      );

      expect(importedVault, isNotNull);
      expect(importedNotes.length, equals(1));
      expect(importedNotes[0].title, equals('Test Note'));
      expect(importedNotes[0].content, equals('Test Content'));

      // Verify vault was added to the list
      final vaults = await service.listVaults();
      expect(vaults.length, equals(1));
    });

    test('importVault should handle vault ID conflicts', () async {
      // Create and export a vault
      final vault = await service.createVault(
        name: 'Conflict Test',
        description: 'Test conflicts',
        password: 'password',
      );

      final notes = [
        Note(
          id: 'note1',
          title: 'Note',
          content: 'Content',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        ),
      ];

      final exportPath = '${tempDir.path}/conflict.zip';
      await service.exportVault(
        vault: vault,
        notes: notes,
        outputPath: exportPath,
        password: 'password',
      );

      // Import while original still exists
      final (importedVault, _) = await service.importVault(
        inputPath: exportPath,
        password: 'password',
      );

      // Should create a new vault with different ID
      expect(importedVault.id, isNot(equals(vault.id)));
      expect(importedVault.name, contains('imported'));

      // Both vaults should exist
      final vaults = await service.listVaults();
      expect(vaults.length, equals(2));
    });

    test('importVault should throw on incorrect password', () async {
      // Create and export a vault
      final vault = await service.createVault(
        name: 'Password Test',
        description: 'Test password',
        password: 'correct_password',
      );

      final notes = <Note>[];
      final exportPath = '${tempDir.path}/password_test.zip';
      await service.exportVault(
        vault: vault,
        notes: notes,
        outputPath: exportPath,
        password: 'correct_password',
      );

      // Try to import with wrong password
      expect(
        () => service.importVault(
          inputPath: exportPath,
          password: 'wrong_password',
        ),
        throwsA(isA<VaultServiceException>()),
      );
    });

    test('vault operations should handle special characters in names',
        () async {
      final vault = await service.createVault(
        name: 'Test Vault 🔐 with emojis & special chars',
        description: 'Testing special characters: <>&"\'',
        password: 'pässwörd123!@#',
      );

      expect(vault.name, equals('Test Vault 🔐 with emojis & special chars'));
      expect(vault.description, equals('Testing special characters: <>&"\''));

      // Verify it can be unlocked
      final unlocked = await service.unlockVault(
        vault: vault,
        password: 'pässwörd123!@#',
      );
      expect(unlocked, isTrue);

      // Verify it can be listed
      final vaults = await service.listVaults();
      expect(vaults[0].name, equals(vault.name));
    });

    test('vault metadata should be correctly saved and loaded', () async {
      final vault = await service.createVault(
        name: 'Metadata Test',
        description: 'Testing metadata persistence',
        password: 'password',
      );

      // Read the metadata file directly
      final metadataPath = 'vaults/${vault.id}/vault.json';
      final data = await storage.readFile(metadataPath);
      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString);

      expect(jsonData['id'], equals(vault.id));
      expect(jsonData['name'], equals('Metadata Test'));
      expect(jsonData['description'], equals('Testing metadata persistence'));
      expect(jsonData['salt'], equals(vault.salt));
      expect(jsonData['created_at'], isNotNull);
      expect(jsonData['updated_at'], isNotNull);
    });
  });
}
