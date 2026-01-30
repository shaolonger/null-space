/// Business logic layer for search operations
/// 
/// This service handles all search-related operations including index initialization,
/// note indexing, search queries, and index rebuilding. It integrates with the Rust
/// bridge for full-text search using Tantivy.

import 'package:flutter/foundation.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/models/note.dart';

/// Exception thrown when search service operations fail
class SearchServiceException implements Exception {
  final String message;
  final String? noteId;
  final Object? cause;

  SearchServiceException(this.message, {this.noteId, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('SearchServiceException: $message');
    if (noteId != null) {
      buffer.write(' (noteId: $noteId)');
    }
    if (cause != null) {
      buffer.write(' - Caused by: $cause');
    }
    return buffer.toString();
  }
}

/// Result from a search query
/// 
/// Contains information about a matched note including its ID, relevance score,
/// and snippets of matched text for display.
class SearchResult {
  /// The unique identifier of the note
  final String noteId;
  
  /// Relevance score (higher is more relevant)
  final double score;
  
  /// Snippet from the title with highlighted matches
  final String titleSnippet;
  
  /// Snippet from the content with highlighted matches
  final String contentSnippet;

  SearchResult({
    required this.noteId,
    required this.score,
    required this.titleSnippet,
    required this.contentSnippet,
  });

  /// Create a SearchResult from JSON data returned by Rust bridge
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (!json.containsKey('note_id') || json['note_id'] == null) {
      throw FormatException('SearchResult missing required field: note_id');
    }
    if (!json.containsKey('score') || json['score'] == null) {
      throw FormatException('SearchResult missing required field: score');
    }

    return SearchResult(
      noteId: json['note_id'] as String,
      score: (json['score'] as num).toDouble(),
      titleSnippet: json['title_snippet'] as String? ?? '',
      contentSnippet: json['content_snippet'] as String? ?? '',
    );
  }

  /// Convert this SearchResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'note_id': noteId,
      'score': score,
      'title_snippet': titleSnippet,
      'content_snippet': contentSnippet,
    };
  }

  @override
  String toString() {
    return 'SearchResult(noteId: $noteId, score: $score, '
        'titleSnippet: "$titleSnippet", contentSnippet: "$contentSnippet")';
  }
}

/// Service for managing search operations
/// 
/// This class provides high-level operations for full-text search of notes
/// using the Tantivy search engine through the Rust bridge.
/// 
/// Example usage:
/// ```dart
/// final bridge = RustBridge();
/// bridge.init();
/// final service = SearchService(bridge: bridge);
/// 
/// final indexPath = 'vaults/my-vault/index';
/// 
/// // Initialize search index
/// await service.initializeIndex(indexPath: indexPath);
/// 
/// // Search for notes
/// final results = await service.search(
///   query: 'important meeting',
///   indexPath: indexPath,
///   limit: 10,
/// );
/// for (final result in results) {
///   print('Found note ${result.noteId} with score ${result.score}');
/// }
/// ```
class SearchService {
  final RustBridge _bridge;

  SearchService({required RustBridge bridge}) : _bridge = bridge;

  /// Initialize the search index
  /// 
  /// Validates the index path and prepares it for use in search operations.
  /// The actual index initialization in Tantivy happens automatically when
  /// the first search or index operation is performed on the Rust side.
  /// 
  /// This method is optional but recommended to call early to validate the
  /// index path configuration and catch any path-related errors before
  /// attempting search operations.
  /// 
  /// [indexPath] - The file system path where the index is stored
  /// 
  /// Throws [SearchServiceException] if the index path is invalid.
  Future<void> initializeIndex({required String indexPath}) async {
    try {
      // Validate the index path is not empty
      if (indexPath.isEmpty) {
        throw SearchServiceException('Index path cannot be empty');
      }
      
      // Note: The actual index initialization happens lazily in the Rust side
      // when the first search or index operation is performed. This method
      // exists primarily for early validation and to maintain consistency
      // with the development plan's API design.
      debugPrint('Search index path validated: $indexPath');
    } catch (e) {
      if (e is SearchServiceException) {
        rethrow;
      }
      throw SearchServiceException(
        'Failed to initialize search index',
        cause: e,
      );
    }
  }

  /// Search notes in the index
  /// 
  /// Performs a full-text search on the indexed notes and returns ranked results.
  /// 
  /// [query] - The search query string
  /// [limit] - Maximum number of results to return (default: 20)
  /// [indexPath] - The file system path where the index is stored
  /// 
  /// Returns a list of [SearchResult] objects sorted by relevance (highest score first).
  /// 
  /// Throws [SearchServiceException] if the search fails.
  Future<List<SearchResult>> search({
    required String query,
    required String indexPath,
    int limit = 20,
  }) async {
    try {
      // Validate inputs
      if (query.isEmpty) {
        return [];
      }
      
      if (indexPath.isEmpty) {
        throw SearchServiceException('Index path cannot be empty');
      }
      
      if (limit <= 0) {
        throw SearchServiceException('Limit must be positive');
      }

      // Call Rust bridge to perform the search
      final rawResults = _bridge.search(indexPath, query, limit);
      
      // Convert raw results to SearchResult objects
      final results = <SearchResult>[];
      for (var i = 0; i < rawResults.length; i++) {
        try {
          final result = SearchResult.fromJson(rawResults[i]);
          results.add(result);
        } catch (e) {
          // Fail fast on malformed results to alert developers to API contract violations
          throw SearchServiceException(
            'Failed to parse search result at index $i: ${e.toString()}',
            cause: e,
          );
        }
      }
      
      return results;
    } catch (e) {
      if (e is SearchServiceException) {
        rethrow;
      }
      throw SearchServiceException(
        'Search failed for query "$query"',
        cause: e,
      );
    }
  }

  /// Index a single note
  /// 
  /// Adds or updates a note in the search index. If the note already exists
  /// in the index, it will be updated.
  /// 
  /// [note] - The note to index
  /// [indexPath] - The file system path where the index is stored
  /// 
  /// Throws [SearchServiceException] if indexing fails.
  Future<void> indexNote({
    required Note note,
    required String indexPath,
  }) async {
    try {
      // Validate inputs
      if (indexPath.isEmpty) {
        throw SearchServiceException('Index path cannot be empty');
      }

      // TODO: Implement actual note indexing using Rust bridge
      // For now, this is a placeholder that validates inputs.
      // In the future, this should call a Rust FFI function to add the note
      // to the Tantivy index with the following fields:
      // - id: note.id
      // - title: note.title
      // - content: note.content
      // - tags: note.tags (as searchable text)
      // - created_at: note.createdAt (as timestamp)
      // - updated_at: note.updatedAt (as timestamp)
      
      debugPrint('Indexing note ${note.id} at $indexPath (placeholder)');
    } catch (e) {
      if (e is SearchServiceException) {
        rethrow;
      }
      throw SearchServiceException(
        'Failed to index note',
        noteId: note.id,
        cause: e,
      );
    }
  }

  /// Remove a note from the search index
  /// 
  /// Deletes a note from the index when it is deleted from the vault.
  /// 
  /// [noteId] - The ID of the note to remove
  /// [indexPath] - The file system path where the index is stored
  /// 
  /// Throws [SearchServiceException] if removal fails.
  Future<void> removeFromIndex({
    required String noteId,
    required String indexPath,
  }) async {
    try {
      // Validate inputs
      if (noteId.isEmpty) {
        throw SearchServiceException('Note ID cannot be empty');
      }
      
      if (indexPath.isEmpty) {
        throw SearchServiceException('Index path cannot be empty');
      }

      // TODO: Implement actual note removal using Rust bridge
      // For now, this is a placeholder that validates inputs.
      // In the future, this should call a Rust FFI function to remove the
      // note from the Tantivy index by its ID.
      
      debugPrint('Removing note $noteId from index at $indexPath (placeholder)');
    } catch (e) {
      if (e is SearchServiceException) {
        rethrow;
      }
      throw SearchServiceException(
        'Failed to remove note from index',
        noteId: noteId,
        cause: e,
      );
    }
  }

  /// Rebuild the entire search index from scratch
  /// 
  /// Clears the existing index and re-indexes all provided notes.
  /// This is useful for recovering from index corruption or after
  /// significant changes to the search schema.
  /// 
  /// [notes] - List of all notes to index
  /// [indexPath] - The file system path where the index is stored
  /// 
  /// Throws [SearchServiceException] if rebuild fails.
  Future<void> rebuildIndex({
    required List<Note> notes,
    required String indexPath,
  }) async {
    try {
      // Validate inputs
      if (indexPath.isEmpty) {
        throw SearchServiceException('Index path cannot be empty');
      }

      // TODO: Implement actual index rebuild using Rust bridge
      // For now, this is a placeholder that validates inputs.
      // In the future, this should:
      // 1. Call a Rust FFI function to clear the existing index
      // 2. Call indexNote for each note in the list
      // This operation should be atomic to avoid leaving the index in
      // an inconsistent state.
      
      debugPrint('Rebuilding index at $indexPath with ${notes.length} notes (placeholder)');
      
      // Placeholder: Index each note sequentially
      for (final note in notes) {
        await indexNote(note: note, indexPath: indexPath);
      }
    } catch (e) {
      if (e is SearchServiceException) {
        rethrow;
      }
      throw SearchServiceException(
        'Failed to rebuild search index',
        cause: e,
      );
    }
  }
}
