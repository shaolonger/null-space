/// Unit tests for NoteService
/// 
/// Tests the business logic layer for note operations to ensure proper
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
import 'package:null_space_app/services/note_service.dart';

void main() {
  group('NoteService', () {
    late RustBridge bridge;
    late FileStorage storage;
    late NoteService service;
    late Directory tempDir;
    late String vaultPassword;
    late String vaultSalt;

    setUp(() async {
      // Initialize Rust bridge
      bridge = RustBridge();
      bridge.init();

      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('note_service_test_');
      storage = FileStorage.withBasePath(tempDir.path);

      // Create service
      service = NoteService(bridge: bridge, storage: storage);

      // Use test credentials
      vaultPassword = 'test_password_123';
      vaultSalt = bridge.generateSalt();
    });

    tearDown(() async {
      // Clean up
      bridge.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('createNote should create and save encrypted note', () async {
      final note = await service.createNote(
        title: 'Test Note',
        content: 'This is test content',
        tags: ['test', 'unit-test'],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(note.title, equals('Test Note'));
      expect(note.content, equals('This is test content'));
      expect(note.tags, equals(['test', 'unit-test']));
      expect(note.id, isNotEmpty);
      expect(note.version, equals(1));

      // Verify the note was saved to disk
      final notePath = 'vaults/default/notes/${note.id}.json';
      expect(await storage.exists(notePath), isTrue);

      // Verify the note is encrypted on disk
      final encryptedData = await storage.readFile(notePath);
      final encryptedJson = utf8.decode(encryptedData);
      
      // The encrypted data should not contain the plain text
      expect(encryptedJson, isNot(contains('Test Note')));
      expect(encryptedJson, isNot(contains('test content')));
    });

    test('updateNote should update and save note with incremented version',
        () async {
      // Create a note first
      final note = await service.createNote(
        title: 'Original Title',
        content: 'Original content',
        tags: ['original'],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      final originalVersion = note.version;

      // Modify the note
      note.title = 'Updated Title';
      note.content = 'Updated content';
      note.tags = ['updated', 'test'];

      // Update the note
      final updatedNote = await service.updateNote(
        note: note,
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(updatedNote.title, equals('Updated Title'));
      expect(updatedNote.content, equals('Updated content'));
      expect(updatedNote.tags, equals(['updated', 'test']));
      expect(updatedNote.version, equals(originalVersion + 1));
      expect(updatedNote.id, equals(note.id));

      // Verify the note was updated on disk
      final notePath = 'vaults/default/notes/${note.id}.json';
      expect(await storage.exists(notePath), isTrue);
    });

    test('deleteNote should remove note from disk', () async {
      // Create a note first
      final note = await service.createNote(
        title: 'To Delete',
        content: 'This will be deleted',
        tags: ['delete'],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      final notePath = 'vaults/default/notes/${note.id}.json';
      expect(await storage.exists(notePath), isTrue);

      // Delete the note
      await service.deleteNote(
        noteId: note.id,
        vaultPath: 'vaults/default',
      );

      // Verify the note was deleted
      expect(await storage.exists(notePath), isFalse);
    });

    test('saveNoteToDisk should encrypt and save note', () async {
      final note = bridge.createNote('Test', 'Content', ['tag']);

      await service.saveNoteToDisk(
        note: note,
        vaultPath: 'vaults/test',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      final notePath = 'vaults/test/notes/${note.id}.json';
      expect(await storage.exists(notePath), isTrue);

      // Read and verify the encrypted content
      final encryptedData = await storage.readFile(notePath);
      final encryptedJson = utf8.decode(encryptedData);

      // Decrypt and verify
      final decryptedJson = bridge.decrypt(encryptedJson, vaultPassword, vaultSalt);
      final decryptedNote = Note.fromJson(jsonDecode(decryptedJson));

      expect(decryptedNote.id, equals(note.id));
      expect(decryptedNote.title, equals('Test'));
      expect(decryptedNote.content, equals('Content'));
    });

    test('loadNotes should load and decrypt all notes from vault', () async {
      // Create multiple notes
      final note1 = await service.createNote(
        title: 'Note 1',
        content: 'Content 1',
        tags: ['tag1'],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      final note2 = await service.createNote(
        title: 'Note 2',
        content: 'Content 2',
        tags: ['tag2'],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      // Load all notes
      final notes = await service.loadNotes(
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(notes.length, equals(2));
      
      final ids = notes.map((n) => n.id).toSet();
      expect(ids, contains(note1.id));
      expect(ids, contains(note2.id));

      final titles = notes.map((n) => n.title).toSet();
      expect(titles, contains('Note 1'));
      expect(titles, contains('Note 2'));
    });

    test('loadNotes should return empty list for empty vault', () async {
      final notes = await service.loadNotes(
        vaultPath: 'vaults/empty',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(notes, isEmpty);
    });

    test('loadNoteById should load specific note', () async {
      // Create a note
      final createdNote = await service.createNote(
        title: 'Specific Note',
        content: 'Specific content',
        tags: ['specific'],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      // Load the note by ID
      final loadedNote = await service.loadNoteById(
        noteId: createdNote.id,
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(loadedNote, isNotNull);
      expect(loadedNote!.id, equals(createdNote.id));
      expect(loadedNote.title, equals('Specific Note'));
      expect(loadedNote.content, equals('Specific content'));
    });

    test('loadNoteById should return null for non-existent note', () async {
      final note = await service.loadNoteById(
        noteId: 'non-existent-id',
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(note, isNull);
    });

    test('indexNote should create index directory', () async {
      final note = bridge.createNote('Test', 'Content', ['tag']);

      await service.indexNote(
        note: note,
        indexPath: 'vaults/test/index',
      );

      // Verify the index directory was created
      final indexDir = Directory('${tempDir.path}/vaults/test/index');
      expect(await indexDir.exists(), isTrue);
    });

    test('error handling works properly with empty values', () async {
      // This test verifies that the service handles empty values properly
      final note = await service.createNote(
        title: '',
        content: '',
        tags: [],
        vaultPath: 'vaults/default',
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      expect(note.title, equals(''));
      expect(note.content, equals(''));
      expect(note.tags, isEmpty);
      expect(note.id, isNotEmpty);
    });
  });

  group('NoteServiceException', () {
    test('toString should include message', () {
      final exception = NoteServiceException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('toString should include noteId if provided', () {
      final exception = NoteServiceException('Test error', noteId: 'note-123');
      final str = exception.toString();
      expect(str, contains('Test error'));
      expect(str, contains('note-123'));
    });

    test('toString should include cause if provided', () {
      final cause = Exception('Underlying error');
      final exception = NoteServiceException('Test error', cause: cause);
      final str = exception.toString();
      expect(str, contains('Test error'));
      expect(str, contains('Caused by'));
    });
  });
}
