/// Business logic layer for vault operations
/// 
/// This service handles all vault-related operations including creation,
/// unlocking, locking, import/export, and deletion. It integrates with the
/// Rust bridge for encryption/decryption and uses FileStorage for disk operations.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/models/vault.dart';
import 'package:null_space_app/services/file_storage.dart';

/// Exception thrown when vault service operations fail
class VaultServiceException implements Exception {
  final String message;
  final String? vaultId;
  final Object? cause;

  VaultServiceException(this.message, {this.vaultId, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('VaultServiceException: $message');
    if (vaultId != null) {
      buffer.write(' (vaultId: $vaultId)');
    }
    if (cause != null) {
      buffer.write(' - Caused by: $cause');
    }
    return buffer.toString();
  }
}

/// Service for managing vault operations
/// 
/// This class provides high-level operations for working with vaults,
/// including creation, unlocking, encryption, and import/export.
/// 
/// Example usage:
/// ```dart
/// final bridge = RustBridge();
/// bridge.init();
/// final storage = await FileStorage.create();
/// final service = VaultService(bridge: bridge, storage: storage);
/// 
/// final vault = await service.createVault(
///   name: 'My Vault',
///   description: 'Personal notes',
///   password: 'secure_password',
/// );
/// ```
class VaultService {
  final RustBridge _bridge;
  final FileStorage _storage;
  
  // Map of unlocked vault IDs to their passwords for session management
  final Map<String, String> _unlockedVaults = {};

  VaultService({required RustBridge bridge, required FileStorage storage})
      : _bridge = bridge,
        _storage = storage;

  /// Create a new vault
  /// 
  /// Creates a vault with a unique ID, generates a salt for encryption,
  /// and saves the vault metadata to disk.
  /// 
  /// [name] - Name of the vault
  /// [description] - Description of the vault
  /// [password] - Password for encrypting the vault
  /// 
  /// Returns the created [Vault] object.
  /// 
  /// Throws [VaultServiceException] if creation fails.
  Future<Vault> createVault({
    required String name,
    required String description,
    required String password,
  }) async {
    try {
      // Generate unique ID and salt
      final id = _generateUniqueId();
      final salt = _bridge.generateSalt();
      final now = DateTime.now();

      // Create vault object
      final vault = Vault(
        id: id,
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
        salt: salt,
      );

      // Create vault directory structure
      await _createVaultStructure(vault);

      // Save vault metadata
      await _saveVaultMetadata(vault);

      // Add to vaults list
      await _addVaultToList(vault);

      return vault;
    } catch (e) {
      throw VaultServiceException(
        'Failed to create vault',
        cause: e,
      );
    }
  }

  /// Open/unlock a vault
  /// 
  /// Validates the password by attempting to decrypt the vault metadata
  /// or a test note. If successful, marks the vault as unlocked for the session.
  /// 
  /// [vault] - The vault to unlock
  /// [password] - The password to validate
  /// 
  /// Returns true if the password is correct, false otherwise.
  /// 
  /// Throws [VaultServiceException] if validation fails for reasons other than incorrect password.
  Future<bool> unlockVault({
    required Vault vault,
    required String password,
  }) async {
    try {
      // Attempt to validate password by encrypting and decrypting test data
      final testData = 'vault_unlock_test';
      final encrypted = _bridge.encrypt(testData, password, vault.salt);
      final decrypted = _bridge.decrypt(encrypted, password, vault.salt);

      if (decrypted != testData) {
        return false;
      }

      // Store the password for this session
      _unlockedVaults[vault.id] = password;
      return true;
    } catch (e) {
      // If decryption fails, password is incorrect
      debugPrint('Password validation failed: $e');
      return false;
    }
  }

  /// Lock a vault
  /// 
  /// Removes the vault from the unlocked vaults map, requiring the user
  /// to enter the password again to access it.
  /// 
  /// [vaultId] - The ID of the vault to lock
  void lockVault({required String vaultId}) {
    _unlockedVaults.remove(vaultId);
  }

  /// Check if a vault is currently unlocked
  /// 
  /// [vaultId] - The ID of the vault to check
  /// 
  /// Returns true if the vault is unlocked, false otherwise.
  bool isVaultUnlocked(String vaultId) {
    return _unlockedVaults.containsKey(vaultId);
  }

  /// Get the password for an unlocked vault
  /// 
  /// [vaultId] - The ID of the vault
  /// 
  /// Returns the password if the vault is unlocked, null otherwise.
  String? getVaultPassword(String vaultId) {
    return _unlockedVaults[vaultId];
  }

  /// Export vault to file
  /// 
  /// Creates a ZIP file containing the vault metadata and all notes.
  /// 
  /// [vault] - The vault to export
  /// [notes] - The notes to include in the export
  /// [outputPath] - The path where the ZIP file will be saved
  /// [password] - The password for encrypting the vault
  /// 
  /// Returns the path to the exported ZIP file.
  /// 
  /// Throws [VaultServiceException] if export fails.
  Future<String> exportVault({
    required Vault vault,
    required List<Note> notes,
    required String outputPath,
    required String password,
  }) async {
    try {
      // Use Rust bridge to export the vault
      final success = _bridge.exportVault(vault, notes, outputPath, password);
      
      if (!success) {
        throw VaultServiceException(
          'Export operation failed - unable to create ZIP archive',
          vaultId: vault.id,
        );
      }

      return outputPath;
    } catch (e) {
      // Re-throw VaultServiceException with original context
      if (e is VaultServiceException) {
        rethrow;
      }
      throw VaultServiceException(
        'Failed to export vault: ${e.toString()}',
        vaultId: vault.id,
        cause: e,
      );
    }
  }

  /// Import vault from file
  /// 
  /// Reads a ZIP file, decrypts the vault metadata and notes,
  /// and saves them to disk.
  /// 
  /// [inputPath] - The path to the ZIP file to import
  /// [password] - The password for decrypting the vault
  /// 
  /// Returns a record containing the imported [Vault] and [List<Note>].
  /// 
  /// Throws [VaultServiceException] if import fails.
  Future<(Vault, List<Note>)> importVault({
    required String inputPath,
    required String password,
  }) async {
    try {
      // Use Rust bridge to import the vault (returns decrypted vault and notes)
      final result = _bridge.importVault(inputPath, password);
      
      final vault = result['vault'] as Vault;
      final notes = result['notes'] as List<Note>;

      // Check if vault already exists
      final vaults = await listVaults();
      final existingVault = vaults.where((v) => v.id == vault.id).firstOrNull;

      Vault finalVault;
      if (existingVault != null) {
        // Generate new ID to avoid conflicts
        final newId = _generateUniqueId();
        finalVault = Vault(
          id: newId,
          name: '${vault.name} (imported)',
          description: vault.description,
          createdAt: vault.createdAt,
          updatedAt: DateTime.now(),
          salt: vault.salt,
        );
      } else {
        finalVault = vault;
      }

      // Create vault and save notes
      // Note: The notes from RustBridge are already decrypted, so we need to
      // re-encrypt them with the final vault's salt for storage
      await _createVaultStructure(finalVault);
      await _saveVaultMetadata(finalVault);
      await _saveNotesToVault(finalVault, notes, password);
      await _addVaultToList(finalVault);

      return (finalVault, notes);
    } catch (e) {
      throw VaultServiceException(
        'Failed to import vault',
        cause: e,
      );
    }
  }

  /// Create vault directory structure
  /// 
  /// [vault] - The vault to create structure for
  Future<void> _createVaultStructure(Vault vault) async {
    await _storage.createDirectory('vaults/${vault.id}');
    await _storage.createDirectory('vaults/${vault.id}/notes');
    await _storage.createDirectory('vaults/${vault.id}/index');
  }

  /// Save notes to a vault
  /// 
  /// [vault] - The vault to save notes to
  /// [notes] - The notes to save (already decrypted)
  /// [password] - The password for encrypting notes
  Future<void> _saveNotesToVault(
    Vault vault,
    List<Note> notes,
    String password,
  ) async {
    for (final note in notes) {
      final notePath = 'vaults/${vault.id}/notes/${note.id}.json';
      final noteJson = jsonEncode(note.toJson());
      final encryptedJson = _bridge.encrypt(noteJson, password, vault.salt);
      final encryptedData = utf8.encode(encryptedJson);
      await _storage.writeFile(notePath, encryptedData);
    }
  }

  /// List all local vaults
  /// 
  /// Reads the vaults list file and returns all vaults.
  /// 
  /// Returns a list of [Vault] objects.
  /// 
  /// Throws [VaultServiceException] if listing fails.
  Future<List<Vault>> listVaults() async {
    try {
      final vaultsListPath = 'vaults/vaults_list.json';
      
      // Check if vaults list exists
      if (!await _storage.exists(vaultsListPath)) {
        return [];
      }

      // Read vaults list
      final data = await _storage.readFile(vaultsListPath);
      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString);

      if (jsonData is! List) {
        throw VaultServiceException('Invalid vaults list format');
      }

      final vaults = <Vault>[];
      for (final vaultData in jsonData) {
        if (vaultData is Map<String, dynamic>) {
          try {
            vaults.add(Vault.fromJson(vaultData));
          } catch (e) {
            // Log error but continue loading other vaults
            debugPrint('Warning: Failed to load vault from list: $e');
          }
        }
      }

      return vaults;
    } catch (e) {
      throw VaultServiceException(
        'Failed to list vaults',
        cause: e,
      );
    }
  }

  /// Delete a vault
  /// 
  /// Removes the vault directory and all its contents, and removes
  /// the vault from the vaults list.
  /// 
  /// [vaultId] - The ID of the vault to delete
  /// 
  /// Throws [VaultServiceException] if deletion fails.
  Future<void> deleteVault({required String vaultId}) async {
    try {
      // Remove from unlocked vaults
      lockVault(vaultId: vaultId);

      // Delete vault directory
      await _storage.deleteDirectory('vaults/$vaultId');

      // Remove from vaults list
      await _removeVaultFromList(vaultId);
    } catch (e) {
      throw VaultServiceException(
        'Failed to delete vault',
        vaultId: vaultId,
        cause: e,
      );
    }
  }

  /// Save vault metadata to disk
  /// 
  /// [vault] - The vault to save
  /// 
  /// Throws [VaultServiceException] if saving fails.
  Future<void> _saveVaultMetadata(Vault vault) async {
    try {
      final vaultPath = 'vaults/${vault.id}/vault.json';
      final vaultJson = jsonEncode(vault.toJson());
      final vaultData = utf8.encode(vaultJson);
      await _storage.writeFile(vaultPath, vaultData);
    } catch (e) {
      throw VaultServiceException(
        'Failed to save vault metadata',
        vaultId: vault.id,
        cause: e,
      );
    }
  }

  /// Add vault to the vaults list
  /// 
  /// [vault] - The vault to add
  /// 
  /// Throws [VaultServiceException] if adding fails.
  Future<void> _addVaultToList(Vault vault) async {
    try {
      final vaults = await listVaults();
      
      // Check if vault already exists in list
      final existingIndex = vaults.indexWhere((v) => v.id == vault.id);
      if (existingIndex >= 0) {
        // Update existing vault
        vaults[existingIndex] = vault;
      } else {
        // Add new vault
        vaults.add(vault);
      }

      // Save updated list
      await _saveVaultsList(vaults);
    } catch (e) {
      throw VaultServiceException(
        'Failed to add vault to list',
        vaultId: vault.id,
        cause: e,
      );
    }
  }

  /// Remove vault from the vaults list
  /// 
  /// [vaultId] - The ID of the vault to remove
  /// 
  /// Throws [VaultServiceException] if removal fails.
  Future<void> _removeVaultFromList(String vaultId) async {
    try {
      final vaults = await listVaults();
      vaults.removeWhere((v) => v.id == vaultId);
      await _saveVaultsList(vaults);
    } catch (e) {
      throw VaultServiceException(
        'Failed to remove vault from list',
        vaultId: vaultId,
        cause: e,
      );
    }
  }

  /// Save the vaults list to disk
  /// 
  /// [vaults] - The list of vaults to save
  /// 
  /// Throws [VaultServiceException] if saving fails.
  Future<void> _saveVaultsList(List<Vault> vaults) async {
    try {
      final vaultsListPath = 'vaults/vaults_list.json';
      final vaultsJson = jsonEncode(vaults.map((v) => v.toJson()).toList());
      final vaultsData = utf8.encode(vaultsJson);
      await _storage.writeFile(vaultsListPath, vaultsData);
    } catch (e) {
      throw VaultServiceException(
        'Failed to save vaults list',
        cause: e,
      );
    }
  }

  /// Generate a unique ID for a vault
  /// 
  /// Returns a unique ID string in the format "vault_{timestamp}_{microseconds}".
  /// The combination of milliseconds and microseconds ensures uniqueness even for
  /// vaults created in rapid succession.
  String _generateUniqueId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final microseconds = now.microsecondsSinceEpoch % 1000000;
    return 'vault_${timestamp}_$microseconds';
  }
}
