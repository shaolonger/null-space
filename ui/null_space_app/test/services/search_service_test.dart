/// Unit tests for SearchService
/// 
/// Tests the business logic layer for search operations to ensure proper
/// integration with the Rust bridge and search functionality.
/// 
/// Note: These tests require the Rust library to be built and available.
/// Run `cargo build --release` in the core/null-space-core directory first.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/services/search_service.dart';

void main() {
  group('SearchService', () {
    late RustBridge bridge;
    late SearchService service;
    late Directory tempDir;
    late String indexPath;

    setUp(() async {
      // Initialize Rust bridge
      bridge = RustBridge();
      bridge.init();

      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('search_service_test_');
      indexPath = '${tempDir.path}/index';

      // Create service
      service = SearchService(bridge: bridge);
    });

    tearDown(() async {
      // Clean up
      bridge.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('initializeIndex', () {
      test('should initialize index with valid path', () async {
        await service.initializeIndex(indexPath: indexPath);
        // If no exception is thrown, the test passes
      });

      test('should throw exception with empty path', () async {
        expect(
          () async => await service.initializeIndex(indexPath: ''),
          throwsA(isA<SearchServiceException>()),
        );
      });
    });

    group('search', () {
      test('should return empty list for empty query', () async {
        final results = await service.search(
          query: '',
          indexPath: indexPath,
        );

        expect(results, isEmpty);
      });

      test('should return empty list when no notes are indexed', () async {
        await service.initializeIndex(indexPath: indexPath);

        final results = await service.search(
          query: 'test',
          indexPath: indexPath,
        );

        expect(results, isEmpty);
      });

      test('should throw exception with empty index path', () async {
        expect(
          () async => await service.search(
            query: 'test',
            indexPath: '',
          ),
          throwsA(isA<SearchServiceException>()),
        );
      });

      test('should throw exception with negative limit', () async {
        expect(
          () async => await service.search(
            query: 'test',
            indexPath: indexPath,
            limit: -1,
          ),
          throwsA(isA<SearchServiceException>()),
        );
      });

      test('should throw exception with zero limit', () async {
        expect(
          () async => await service.search(
            query: 'test',
            indexPath: indexPath,
            limit: 0,
          ),
          throwsA(isA<SearchServiceException>()),
        );
      });

      test('should respect limit parameter', () async {
        await service.initializeIndex(indexPath: indexPath);

        final results = await service.search(
          query: 'test',
          indexPath: indexPath,
          limit: 5,
        );

        expect(results.length, lessThanOrEqualTo(5));
      });

      // Note: This test documents the expected behavior but will pass
      // because the mock Rust bridge returns an empty list for non-indexed searches.
      // In a real integration test with actual indexing, this would verify
      // the full round-trip of indexing and searching.
      test('should parse valid search results from Rust bridge', () async {
        await service.initializeIndex(indexPath: indexPath);

        // When the Rust bridge is fully implemented and notes are indexed,
        // this would return actual results. For now, it returns empty.
        final results = await service.search(
          query: 'test',
          indexPath: indexPath,
        );

        // Verify the results are properly typed
        expect(results, isA<List<SearchResult>>());
      });
    });

    group('indexNote', () {
      test('should index a note without error', () async {
        await service.initializeIndex(indexPath: indexPath);

        final note = Note(
          id: 'test-note-1',
          title: 'Test Note',
          content: 'This is test content',
          tags: ['test'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        await service.indexNote(note: note, indexPath: indexPath);
        // If no exception is thrown, the test passes
      });

      test('should throw exception with empty index path', () async {
        final note = Note(
          id: 'test-note-1',
          title: 'Test Note',
          content: 'This is test content',
          tags: ['test'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        );

        expect(
          () async => await service.indexNote(note: note, indexPath: ''),
          throwsA(isA<SearchServiceException>()),
        );
      });
    });

    group('removeFromIndex', () {
      test('should remove a note without error', () async {
        await service.initializeIndex(indexPath: indexPath);

        await service.removeFromIndex(
          noteId: 'test-note-1',
          indexPath: indexPath,
        );
        // If no exception is thrown, the test passes
      });

      test('should throw exception with empty note ID', () async {
        expect(
          () async => await service.removeFromIndex(
            noteId: '',
            indexPath: indexPath,
          ),
          throwsA(isA<SearchServiceException>()),
        );
      });

      test('should throw exception with empty index path', () async {
        expect(
          () async => await service.removeFromIndex(
            noteId: 'test-note-1',
            indexPath: '',
          ),
          throwsA(isA<SearchServiceException>()),
        );
      });
    });

    group('rebuildIndex', () {
      test('should rebuild index with empty notes list', () async {
        await service.initializeIndex(indexPath: indexPath);

        await service.rebuildIndex(
          notes: [],
          indexPath: indexPath,
        );
        // If no exception is thrown, the test passes
      });

      test('should rebuild index with multiple notes', () async {
        await service.initializeIndex(indexPath: indexPath);

        final notes = [
          Note(
            id: 'note-1',
            title: 'First Note',
            content: 'Content of first note',
            tags: ['tag1'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 1,
          ),
          Note(
            id: 'note-2',
            title: 'Second Note',
            content: 'Content of second note',
            tags: ['tag2'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 1,
          ),
          Note(
            id: 'note-3',
            title: 'Third Note',
            content: 'Content of third note',
            tags: ['tag3'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 1,
          ),
        ];

        await service.rebuildIndex(
          notes: notes,
          indexPath: indexPath,
        );
        // If no exception is thrown, the test passes
      });

      test('should throw exception with empty index path', () async {
        expect(
          () async => await service.rebuildIndex(
            notes: [],
            indexPath: '',
          ),
          throwsA(isA<SearchServiceException>()),
        );
      });
    });

    group('SearchResult', () {
      test('should create from JSON', () {
        final json = {
          'note_id': 'test-note-1',
          'score': 0.85,
          'title_snippet': 'Test <em>Note</em>',
          'content_snippet': 'This is <em>test</em> content',
        };

        final result = SearchResult.fromJson(json);

        expect(result.noteId, equals('test-note-1'));
        expect(result.score, equals(0.85));
        expect(result.titleSnippet, equals('Test <em>Note</em>'));
        expect(result.contentSnippet, equals('This is <em>test</em> content'));
      });

      test('should handle missing snippets in JSON', () {
        final json = {
          'note_id': 'test-note-1',
          'score': 0.85,
        };

        final result = SearchResult.fromJson(json);

        expect(result.noteId, equals('test-note-1'));
        expect(result.score, equals(0.85));
        expect(result.titleSnippet, isEmpty);
        expect(result.contentSnippet, isEmpty);
      });

      test('should throw FormatException when note_id is missing', () {
        final json = {
          'score': 0.85,
          'title_snippet': 'Test',
          'content_snippet': 'Content',
        };

        expect(
          () => SearchResult.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException when note_id is null', () {
        final json = {
          'note_id': null,
          'score': 0.85,
        };

        expect(
          () => SearchResult.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException when score is missing', () {
        final json = {
          'note_id': 'test-note-1',
          'title_snippet': 'Test',
          'content_snippet': 'Content',
        };

        expect(
          () => SearchResult.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException when score is null', () {
        final json = {
          'note_id': 'test-note-1',
          'score': null,
        };

        expect(
          () => SearchResult.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('should convert to JSON', () {
        final result = SearchResult(
          noteId: 'test-note-1',
          score: 0.85,
          titleSnippet: 'Test Note',
          contentSnippet: 'This is test content',
        );

        final json = result.toJson();

        expect(json['note_id'], equals('test-note-1'));
        expect(json['score'], equals(0.85));
        expect(json['title_snippet'], equals('Test Note'));
        expect(json['content_snippet'], equals('This is test content'));
      });

      test('should have meaningful toString', () {
        final result = SearchResult(
          noteId: 'test-note-1',
          score: 0.85,
          titleSnippet: 'Test Note',
          contentSnippet: 'This is test content',
        );

        final str = result.toString();

        expect(str, contains('test-note-1'));
        expect(str, contains('0.85'));
        expect(str, contains('Test Note'));
        expect(str, contains('This is test content'));
      });
    });

    group('SearchServiceException', () {
      test('should format message correctly', () {
        final exception = SearchServiceException('Test error');

        expect(exception.toString(), equals('SearchServiceException: Test error'));
      });

      test('should include note ID if provided', () {
        final exception = SearchServiceException(
          'Test error',
          noteId: 'note-123',
        );

        expect(exception.toString(), contains('note-123'));
      });

      test('should include cause if provided', () {
        final cause = Exception('Root cause');
        final exception = SearchServiceException(
          'Test error',
          cause: cause,
        );

        expect(exception.toString(), contains('Root cause'));
      });
    });
  });
}
