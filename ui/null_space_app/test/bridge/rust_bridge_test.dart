/// Unit tests for RustBridge FFI implementation
/// 
/// Note: These tests require the Rust library to be built and available.
/// Run `cargo build --release` in the core/null-space-core directory first.

import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';

void main() {
  group('RustBridge', () {
    late RustBridge bridge;

    setUp(() {
      // Note: In real tests, you may need to provide a path to the library
      // or ensure it's in the system library path
      bridge = RustBridge();
      bridge.init();
    });

    tearDown(() {
      bridge.dispose();
    });

    test('generateSalt should return a non-empty string', () {
      final salt = bridge.generateSalt();
      expect(salt, isNotEmpty);
      expect(salt.length, greaterThan(0));
    });

    test('encrypt and decrypt should round-trip successfully', () {
      final salt = bridge.generateSalt();
      final password = 'test_password';
      final data = 'Hello, World!';

      final encrypted = bridge.encrypt(data, password, salt);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(data)));

      final decrypted = bridge.decrypt(encrypted, password, salt);
      expect(decrypted, equals(data));
    });

    test('createNote should return a valid Note object', () {
      final title = 'Test Note';
      final content = 'This is test content';
      final tags = ['tag1', 'tag2', 'test'];

      final note = bridge.createNote(title, content, tags);

      expect(note.title, equals(title));
      expect(note.content, equals(content));
      expect(note.tags, equals(tags));
      expect(note.id, isNotEmpty);
      expect(note.version, equals(1));
      expect(note.createdAt, isNotNull);
      expect(note.updatedAt, isNotNull);
    });

    test('updateNote should increment version and update timestamp', () async {
      // Create a note first
      final note = bridge.createNote('Original', 'Content', ['tag']);
      final originalVersion = note.version;
      final originalUpdatedAt = note.updatedAt;

      // Wait a bit to ensure timestamp changes
      await Future.delayed(Duration(milliseconds: 10));

      // Modify and update the note
      note.title = 'Updated Title';
      note.content = 'Updated content';
      note.tags = ['tag', 'updated'];

      final updatedNote = bridge.updateNote(note);

      expect(updatedNote.title, equals('Updated Title'));
      expect(updatedNote.content, equals('Updated content'));
      expect(updatedNote.tags, equals(['tag', 'updated']));
      expect(updatedNote.version, equals(originalVersion + 1));
      expect(updatedNote.updatedAt.isAfter(originalUpdatedAt), isTrue);
      expect(updatedNote.id, equals(note.id));
    });

    test('search should return results', () {
      // Note: This test requires a search index to exist
      // In a real test, you would set up an index first
      final results = bridge.search('/tmp/test_index', 'test query', 10);
      expect(results, isList);
      // Results may be empty if no index exists, which is okay for this test
    });

    test('FFIException should be thrown on invalid operations', () {
      expect(
        () => bridge.decrypt('invalid_base64!@#', 'password', 'salt'),
        throwsA(isA<FFIException>()),
      );
    });

    test('encrypt with wrong password should not decrypt correctly', () {
      final salt = bridge.generateSalt();
      final data = 'Secret data';
      final encrypted = bridge.encrypt(data, 'password1', salt);

      expect(
        () => bridge.decrypt(encrypted, 'wrong_password', salt),
        throwsA(isA<FFIException>()),
      );
    });
  });

  group('RustBridge Error Handling', () {
    test('should provide meaningful error messages', () {
      final bridge = RustBridge();
      bridge.init();

      try {
        bridge.decrypt('not_valid_base64', 'password', 'salt');
        fail('Should have thrown FFIException');
      } catch (e) {
        expect(e, isA<FFIException>());
        final exception = e as FFIException;
        expect(exception.message, contains('Decryption'));
        expect(exception.toString(), contains('FFIException'));
      } finally {
        bridge.dispose();
      }
    });
  });

  group('RustBridge Lifecycle', () {
    test('init and dispose should work correctly', () {
      final bridge = RustBridge();
      
      // Should be able to initialize
      expect(() => bridge.init(), returnsNormally);
      
      // Should be able to use after init
      expect(() => bridge.generateSalt(), returnsNormally);
      
      // Should be able to dispose
      expect(() => bridge.dispose(), returnsNormally);
    });

    test('calling init twice should be safe', () {
      final bridge = RustBridge();
      
      bridge.init();
      bridge.init(); // Should not throw
      
      expect(() => bridge.generateSalt(), returnsNormally);
      
      bridge.dispose();
    });
  });
}
