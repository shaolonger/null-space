/// Business logic layer for note operations
/// 
/// This service handles all note-related operations including creation, updates,
/// deletion, loading, and search indexing. It integrates with the Rust bridge
/// for encryption/decryption and uses FileStorage for disk operations.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/services/file_storage.dart';

/// Exception thrown when note service operations fail
class NoteServiceException implements Exception {
  final String message;
  final String? noteId;
  final Object? cause;

  NoteServiceException(this.message, {this.noteId, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('NoteServiceException: $message');
    if (noteId != null) {
      buffer.write(' (noteId: $noteId)');
    }
    if (cause != null) {
      buffer.write(' - Caused by: $cause');
    }
    return buffer.toString();
  }
}

/// Service for managing note operations
/// 
/// This class provides high-level operations for working with notes,
/// including encryption, storage, and search indexing.
/// 
/// Example usage:
/// ```dart
/// final bridge = RustBridge();
/// bridge.init();
/// final storage = await FileStorage.create();
/// final service = NoteService(bridge: bridge, storage: storage);
/// 
/// final note = await service.createNote(
///   title: 'My Note',
///   content: 'Note content',
///   tags: ['personal'],
///   vaultPath: 'vaults/my-vault',
///   vaultPassword: 'password',
///   vaultSalt: 'salt',
/// );
/// ```
class NoteService {
  final RustBridge _bridge;
  final FileStorage _storage;

  NoteService({required RustBridge bridge, required FileStorage storage})
      : _bridge = bridge,
        _storage = storage;

  /// Create a new note
  /// 
  /// Creates a note with a generated UUID and timestamps, encrypts it,
  /// and saves it to disk. The note is also indexed for search.
  /// 
  /// [title] - Note title
  /// [content] - Note content in Markdown format
  /// [tags] - List of hierarchical tags (e.g., "work/project/urgent")
  /// [vaultPath] - The path to the vault where the note will be stored
  /// [vaultPassword] - Password for encrypting the note
  /// [vaultSalt] - Salt used for key derivation
  /// 
  /// Returns the created [Note] object.
  /// 
  /// Throws [NoteServiceException] if creation fails.
  Future<Note> createNote({
    required String title,
    required String content,
    required List<String> tags,
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  }) async {
    try {
      // Create the note using the Rust bridge
      final note = _bridge.createNote(title, content, tags);

      // Save the note to disk (encrypted)
      await saveNoteToDisk(
        note: note,
        vaultPath: vaultPath,
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      // Index the note for search
      await indexNote(note: note, indexPath: '$vaultPath/index');

      return note;
    } catch (e) {
      throw NoteServiceException(
        'Failed to create note',
        cause: e,
      );
    }
  }

  /// Update an existing note
  /// 
  /// Updates the note's version and timestamp, encrypts it, and saves
  /// it to disk. The search index is also updated.
  /// 
  /// [note] - The note to update (with modified fields)
  /// [vaultPath] - The path to the vault containing the note
  /// [vaultPassword] - Password for encrypting the note
  /// [vaultSalt] - Salt used for key derivation
  /// 
  /// Returns the updated [Note] object with incremented version and timestamp.
  /// 
  /// Throws [NoteServiceException] if update fails.
  Future<Note> updateNote({
    required Note note,
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  }) async {
    try {
      // Update the note using the Rust bridge (increments version and timestamp)
      final updatedNote = _bridge.updateNote(note);

      // Save the updated note to disk (encrypted)
      await saveNoteToDisk(
        note: updatedNote,
        vaultPath: vaultPath,
        vaultPassword: vaultPassword,
        vaultSalt: vaultSalt,
      );

      // Update the search index
      await indexNote(note: updatedNote, indexPath: '$vaultPath/index');

      return updatedNote;
    } catch (e) {
      throw NoteServiceException(
        'Failed to update note',
        noteId: note.id,
        cause: e,
      );
    }
  }

  /// Delete a note
  /// 
  /// Removes the note file from disk. The note is also removed from the
  /// search index (if applicable).
  /// 
  /// [noteId] - The ID of the note to delete
  /// [vaultPath] - The path to the vault containing the note
  /// 
  /// Throws [NoteServiceException] if deletion fails.
  Future<void> deleteNote({
    required String noteId,
    required String vaultPath,
  }) async {
    try {
      final notePath = '$vaultPath/notes/$noteId.json';
      await _storage.deleteFile(notePath);
    } catch (e) {
      throw NoteServiceException(
        'Failed to delete note',
        noteId: noteId,
        cause: e,
      );
    }
  }

  /// Load all notes from a vault
  /// 
  /// Reads all note files from the vault directory, decrypts them,
  /// and returns them as a list.
  /// 
  /// [vaultPath] - The path to the vault
  /// [vaultPassword] - Password for decrypting notes
  /// [vaultSalt] - Salt used for key derivation
  /// 
  /// Returns a list of [Note] objects.
  /// 
  /// Throws [NoteServiceException] if loading fails.
  Future<List<Note>> loadNotes({
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  }) async {
    try {
      // Get all note files in the vault
      final notesPath = '$vaultPath/notes';
      final fileList = await _storage.listFiles(notesPath);

      final notes = <Note>[];
      for (final filePath in fileList) {
        try {
          // Read the encrypted note file
          final encryptedData = await _storage.readFile(filePath);
          final encryptedJson = utf8.decode(encryptedData);

          // Decrypt the note
          final decryptedJson =
              _bridge.decrypt(encryptedJson, vaultPassword, vaultSalt);

          // Parse the note
          final noteData = jsonDecode(decryptedJson);
          if (noteData is Map<String, dynamic>) {
            final note = Note.fromJson(noteData);
            notes.add(note);
          }
        } catch (e) {
          // Log error but continue loading other notes
          // In a production app, you might want to handle this differently
          debugPrint('Warning: Failed to load note from $filePath: $e');
        }
      }

      return notes;
    } catch (e) {
      throw NoteServiceException(
        'Failed to load notes',
        cause: e,
      );
    }
  }

  /// Save a note to disk (encrypted)
  /// 
  /// Encrypts the note and writes it to the vault's notes directory.
  /// Creates the directory if it doesn't exist.
  /// 
  /// [note] - The note to save
  /// [vaultPath] - The path to the vault
  /// [vaultPassword] - Password for encrypting the note
  /// [vaultSalt] - Salt used for key derivation
  /// 
  /// Throws [NoteServiceException] if saving fails.
  Future<void> saveNoteToDisk({
    required Note note,
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  }) async {
    try {
      // Convert note to JSON
      final noteJson = jsonEncode(note.toJson());

      // Encrypt the note
      final encryptedJson =
          _bridge.encrypt(noteJson, vaultPassword, vaultSalt);

      // Write to disk
      final notePath = '$vaultPath/notes/${note.id}.json';
      final encryptedData = utf8.encode(encryptedJson);
      await _storage.writeFile(notePath, encryptedData);
    } catch (e) {
      throw NoteServiceException(
        'Failed to save note to disk',
        noteId: note.id,
        cause: e,
      );
    }
  }

  /// Index a note for search
  /// 
  /// Adds or updates the note in the search index. This allows the note
  /// to be found through full-text search.
  /// 
  /// Note: This is a placeholder implementation. The actual indexing
  /// should use the Tantivy search engine through the Rust bridge.
  /// For now, this method just ensures the index directory exists.
  /// 
  /// [note] - The note to index
  /// [indexPath] - The path to the search index
  /// 
  /// Throws [NoteServiceException] if indexing fails.
  Future<void> indexNote({
    required Note note,
    required String indexPath,
  }) async {
    try {
      // Ensure the index directory exists
      await _storage.createDirectory(indexPath);

      // TODO: Implement actual indexing using Tantivy through Rust bridge
      // For now, this is a placeholder that just ensures the directory exists
      // In the future, this should call a Rust FFI function to add the note
      // to the Tantivy index for full-text search capabilities.
    } catch (e) {
      throw NoteServiceException(
        'Failed to index note',
        noteId: note.id,
        cause: e,
      );
    }
  }

  /// Load a single note by ID
  /// 
  /// [noteId] - The ID of the note to load
  /// [vaultPath] - The path to the vault containing the note
  /// [vaultPassword] - Password for decrypting the note
  /// [vaultSalt] - Salt used for key derivation
  /// 
  /// Returns the [Note] object if found, null otherwise.
  /// 
  /// Throws [NoteServiceException] if loading fails.
  Future<Note?> loadNoteById({
    required String noteId,
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  }) async {
    try {
      final notePath = '$vaultPath/notes/$noteId.json';

      // Check if the note file exists
      if (!await _storage.exists(notePath)) {
        return null;
      }

      // Read the encrypted note file
      final encryptedData = await _storage.readFile(notePath);
      final encryptedJson = utf8.decode(encryptedData);

      // Decrypt the note
      final decryptedJson =
          _bridge.decrypt(encryptedJson, vaultPassword, vaultSalt);

      // Parse the note
      final noteData = jsonDecode(decryptedJson);
      if (noteData is Map<String, dynamic>) {
        return Note.fromJson(noteData);
      }

      return null;
    } catch (e) {
      throw NoteServiceException(
        'Failed to load note by ID',
        noteId: noteId,
        cause: e,
      );
    }
  }
}
