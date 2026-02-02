/// FFI Bridge to Rust core library
///
/// This file provides the Dart interface to the Rust core functionality.
/// It uses FFI (Foreign Function Interface) to call native Rust code.

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import '../models/note.dart';
import '../models/vault.dart';

/// Type definitions for native functions

// Initialization and cleanup
typedef NativeInit = Pointer<Void> Function();
typedef DartInit = Pointer<Void> Function();

typedef NativeFree = Void Function(Pointer<Void>);
typedef DartFree = void Function(Pointer<Void>);

typedef NativeFreeString = Void Function(Pointer<Utf8>);
typedef DartFreeString = void Function(Pointer<Utf8>);

// Salt generation
typedef NativeGenerateSalt = Pointer<Utf8> Function();
typedef DartGenerateSalt = Pointer<Utf8> Function();

// Encryption/Decryption
typedef NativeEncrypt = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef DartEncrypt = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

typedef NativeDecrypt = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef DartDecrypt = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

// Note operations
typedef NativeCreateNote = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef DartCreateNote = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

typedef NativeUpdateNote = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DartUpdateNote = Pointer<Utf8> Function(Pointer<Utf8>);

// Search
typedef NativeSearch = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef DartSearch = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, int);

// Vault operations
typedef NativeExportVault = Int32 Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef DartExportVault = int Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

typedef NativeImportVault = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>);
typedef DartImportVault = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

/// Exception thrown when FFI operations fail
class FFIException implements Exception {
  final String message;
  FFIException(this.message);

  @override
  String toString() => 'FFIException: $message';
}

/// Rust bridge interface
///
/// This class provides access to Rust core functionality via FFI.
///
/// **Thread Safety**: This class is not thread-safe and should only be accessed
/// from a single isolate. If you need to use it from multiple isolates, create
/// a separate instance in each isolate.
///
/// **Resource Management**: Always call `init()` before using any methods and
/// `dispose()` when done to prevent memory leaks. Consider using this class
/// with try-finally blocks:
/// ```dart
/// final bridge = RustBridge();
/// try {
///   bridge.init();
///   // Use bridge methods
/// } finally {
///   bridge.dispose();
/// }
/// ```
class RustBridge {
  late final DynamicLibrary _dylib;
  Pointer<Void>? _context;

  // Function pointers
  late final DartInit _init;
  late final DartFree _free;
  late final DartFreeString _freeString;
  late final DartGenerateSalt _generateSaltFunc;
  late final DartEncrypt _encryptFunc;
  late final DartDecrypt _decryptFunc;
  late final DartCreateNote _createNoteFunc;
  late final DartUpdateNote _updateNoteFunc;
  late final DartSearch _searchFunc;
  late final DartExportVault _exportVaultFunc;
  late final DartImportVault _importVaultFunc;

  RustBridge() {
    // Load the native library
    if (Platform.isAndroid || Platform.isLinux) {
      print(
          '[FFI DEBUG] Loading library for Android/Linux: libnull_space_core.so');
      _dylib = DynamicLibrary.open('libnull_space_core.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      print(
          '[FFI DEBUG] Loading library for iOS/macOS using DynamicLibrary.process()');
      _dylib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      print('[FFI DEBUG] Loading library for Windows: null_space_core.dll');
      _dylib = DynamicLibrary.open('null_space_core.dll');
    } else {
      throw UnsupportedError('Platform not supported');
    }

    print('[FFI DEBUG] Library loaded successfully');

    // Look up all function pointers
    _init = _dylib.lookupFunction<NativeInit, DartInit>('null_space_init');
    _free = _dylib.lookupFunction<NativeFree, DartFree>('null_space_free');
    _freeString = _dylib.lookupFunction<NativeFreeString, DartFreeString>(
        'null_space_free_string');
    _generateSaltFunc =
        _dylib.lookupFunction<NativeGenerateSalt, DartGenerateSalt>(
            'null_space_generate_salt');
    _encryptFunc =
        _dylib.lookupFunction<NativeEncrypt, DartEncrypt>('null_space_encrypt');
    _decryptFunc =
        _dylib.lookupFunction<NativeDecrypt, DartDecrypt>('null_space_decrypt');
    _createNoteFunc = _dylib.lookupFunction<NativeCreateNote, DartCreateNote>(
        'null_space_create_note');
    _updateNoteFunc = _dylib.lookupFunction<NativeUpdateNote, DartUpdateNote>(
        'null_space_update_note');
    _searchFunc =
        _dylib.lookupFunction<NativeSearch, DartSearch>('null_space_search');
    _exportVaultFunc =
        _dylib.lookupFunction<NativeExportVault, DartExportVault>(
            'null_space_export_vault');
    _importVaultFunc =
        _dylib.lookupFunction<NativeImportVault, DartImportVault>(
            'null_space_import_vault');

    print('[FFI DEBUG] All function pointers loaded successfully');
  }

  /// Initialize the library
  void init() {
    if (_context != null) {
      return; // Already initialized
    }
    _context = _init();
    if (_context == nullptr) {
      throw FFIException('Failed to initialize Rust library');
    }
  }

  /// Clean up library resources
  void dispose() {
    if (_context != null) {
      _free(_context!);
      _context = null;
    }
  }

  /// Convert a Dart string to a native UTF-8 string
  Pointer<Utf8> _toNativeString(String str) {
    return str.toNativeUtf8();
  }

  /// Convert a native UTF-8 string to a Dart string and free the native string
  String _fromNativeString(Pointer<Utf8> ptr, String operation) {
    if (ptr == nullptr) {
      throw FFIException('$operation failed: Received null pointer from Rust');
    }
    try {
      final str = ptr.toDartString();
      return str;
    } finally {
      _freeString(ptr);
    }
  }

  /// Translate export vault error codes to descriptive messages
  String _exportVaultErrorMessage(int errorCode) {
    switch (errorCode) {
      case -1:
        return 'Null pointer in one or more parameters';
      case -2:
        return 'Invalid vault JSON string encoding';
      case -3:
        return 'Invalid notes JSON string encoding';
      case -4:
        return 'Invalid output path string encoding';
      case -5:
        return 'Invalid password string encoding';
      case -6:
        return 'Failed to parse vault JSON';
      case -7:
        return 'Failed to parse notes JSON';
      case -8:
        return 'Failed to create encryption manager';
      case -9:
        return 'Failed to create file storage';
      case -10:
        return 'Failed to export vault';
      default:
        return 'Unknown error (code: $errorCode)';
    }
  }

  /// Generate a random salt for key derivation
  String generateSalt() {
    final saltPtr = _generateSaltFunc();
    return _fromNativeString(saltPtr, 'Generate salt');
  }

  /// Encrypt data with a password and salt
  ///
  /// Returns a base64-encoded string containing the encrypted data.
  String encrypt(String data, String password, String salt) {
    print(
        '[FFI DEBUG] encrypt called with data length: ${data.length}, password length: ${password.length}, salt length: ${salt.length}');
    print('[FFI DEBUG] salt value: "$salt"');
    final dataPtr = _toNativeString(data);
    final passwordPtr = _toNativeString(password);
    final saltPtr = _toNativeString(salt);

    print(
        '[FFI DEBUG] Pointers created: data=${dataPtr.address}, password=${passwordPtr.address}, salt=${saltPtr.address}');

    try {
      final resultPtr = _encryptFunc(dataPtr, passwordPtr, saltPtr);
      print('[FFI DEBUG] encrypt result pointer: ${resultPtr.address}');
      return _fromNativeString(resultPtr, 'Encryption');
    } finally {
      malloc.free(dataPtr);
      malloc.free(passwordPtr);
      malloc.free(saltPtr);
    }
  }

  /// Decrypt data with a password and salt
  ///
  /// Takes a base64-encoded encrypted string and returns the decrypted plaintext.
  String decrypt(String encryptedData, String password, String salt) {
    final encryptedPtr = _toNativeString(encryptedData);
    final passwordPtr = _toNativeString(password);
    final saltPtr = _toNativeString(salt);

    try {
      final resultPtr = _decryptFunc(encryptedPtr, passwordPtr, saltPtr);
      return _fromNativeString(resultPtr, 'Decryption');
    } finally {
      malloc.free(encryptedPtr);
      malloc.free(passwordPtr);
      malloc.free(saltPtr);
    }
  }

  /// Create a new note
  ///
  /// Returns a Note object with a generated UUID and timestamps.
  Note createNote(String title, String content, List<String> tags) {
    final titlePtr = _toNativeString(title);
    final contentPtr = _toNativeString(content);
    final tagsJson = jsonEncode(tags);
    final tagsPtr = _toNativeString(tagsJson);

    try {
      final resultPtr = _createNoteFunc(titlePtr, contentPtr, tagsPtr);
      final jsonString = _fromNativeString(resultPtr, 'Create note');
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw FFIException(
            'Create note failed: Expected JSON object, got ${decoded.runtimeType}');
      }
      return Note.fromJson(decoded);
    } catch (e) {
      if (e is FFIException) rethrow;
      throw FFIException('Create note failed: $e');
    } finally {
      malloc.free(titlePtr);
      malloc.free(contentPtr);
      malloc.free(tagsPtr);
    }
  }

  /// Update an existing note
  ///
  /// Takes a Note object, increments its version, and updates the timestamp.
  /// Returns the updated Note.
  Note updateNote(Note note) {
    final noteJson = jsonEncode(note.toJson());
    final notePtr = _toNativeString(noteJson);

    try {
      final resultPtr = _updateNoteFunc(notePtr);
      final jsonString = _fromNativeString(resultPtr, 'Update note');
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw FFIException(
            'Update note failed: Expected JSON object, got ${decoded.runtimeType}');
      }
      return Note.fromJson(decoded);
    } catch (e) {
      if (e is FFIException) rethrow;
      throw FFIException('Update note failed: $e');
    } finally {
      malloc.free(notePtr);
    }
  }

  /// Search notes in the index
  ///
  /// Returns a list of search results with note IDs and relevance scores.
  List<Map<String, dynamic>> search(String indexPath, String query, int limit) {
    final indexPathPtr = _toNativeString(indexPath);
    final queryPtr = _toNativeString(query);

    try {
      final resultPtr = _searchFunc(indexPathPtr, queryPtr, limit);
      final jsonString = _fromNativeString(resultPtr, 'Search');
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw FFIException(
            'Search failed: Expected JSON array, got ${decoded.runtimeType}');
      }
      // Validate that all items are maps
      final results = <Map<String, dynamic>>[];
      for (var i = 0; i < decoded.length; i++) {
        if (decoded[i] is! Map<String, dynamic>) {
          throw FFIException(
              'Search failed: Expected object at index $i, got ${decoded[i].runtimeType}');
        }
        results.add(decoded[i] as Map<String, dynamic>);
      }
      return results;
    } catch (e) {
      if (e is FFIException) rethrow;
      throw FFIException('Search failed: $e');
    } finally {
      malloc.free(indexPathPtr);
      malloc.free(queryPtr);
    }
  }

  /// Export a vault to a ZIP file
  ///
  /// Returns true on success, throws FFIException on error with detailed message.
  bool exportVault(
      Vault vault, List<Note> notes, String outputPath, String password) {
    final vaultJson = jsonEncode(vault.toJson());
    final vaultPtr = _toNativeString(vaultJson);

    final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
    final notesPtr = _toNativeString(notesJson);

    final outputPathPtr = _toNativeString(outputPath);
    final passwordPtr = _toNativeString(password);

    try {
      final result =
          _exportVaultFunc(vaultPtr, notesPtr, outputPathPtr, passwordPtr);
      if (result != 0) {
        final errorMsg = _exportVaultErrorMessage(result);
        throw FFIException('Export vault failed: $errorMsg');
      }
      return true;
    } finally {
      malloc.free(vaultPtr);
      malloc.free(notesPtr);
      malloc.free(outputPathPtr);
      malloc.free(passwordPtr);
    }
  }

  /// Import a vault from a ZIP file
  ///
  /// Returns a map containing the vault and notes.
  ///
  /// The returned map has two keys:
  /// - 'vault': A [Vault] object with the vault metadata
  /// - 'notes': A [List<Note>] containing all notes from the vault
  Map<String, dynamic> importVault(String inputPath, String password) {
    final inputPathPtr = _toNativeString(inputPath);
    final passwordPtr = _toNativeString(password);

    try {
      final resultPtr = _importVaultFunc(inputPathPtr, passwordPtr);
      final jsonString = _fromNativeString(resultPtr, 'Import vault');
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        throw FFIException(
            'Import vault failed: Expected JSON object, got ${decoded.runtimeType}');
      }

      // Validate structure
      if (!decoded.containsKey('vault')) {
        throw FFIException(
            'Import vault failed: Missing "vault" key in response');
      }
      if (!decoded.containsKey('notes')) {
        throw FFIException(
            'Import vault failed: Missing "notes" key in response');
      }

      final vaultData = decoded['vault'];
      if (vaultData is! Map<String, dynamic>) {
        throw FFIException(
            'Import vault failed: Expected vault object, got ${vaultData.runtimeType}');
      }

      final notesData = decoded['notes'];
      if (notesData is! List) {
        throw FFIException(
            'Import vault failed: Expected notes array, got ${notesData.runtimeType}');
      }

      final vault = Vault.fromJson(vaultData);
      final notes = <Note>[];
      for (var i = 0; i < notesData.length; i++) {
        if (notesData[i] is! Map<String, dynamic>) {
          throw FFIException(
              'Import vault failed: Expected note object at index $i, got ${notesData[i].runtimeType}');
        }
        notes.add(Note.fromJson(notesData[i] as Map<String, dynamic>));
      }

      return {
        'vault': vault,
        'notes': notes,
      };
    } catch (e) {
      if (e is FFIException) rethrow;
      throw FFIException('Import vault failed: $e');
    } finally {
      malloc.free(inputPathPtr);
      malloc.free(passwordPtr);
    }
  }
}
