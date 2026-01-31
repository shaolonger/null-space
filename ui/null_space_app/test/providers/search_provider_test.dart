import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/providers/search_provider.dart';
import 'package:null_space_app/services/search_service.dart';
import 'package:null_space_app/bridge/rust_bridge.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/models/vault.dart';

// Mock SearchService for testing
class MockSearchService extends SearchService {
  MockSearchService() : super(bridge: MockRustBridge());
  
  bool shouldFail = false;
  List<SearchResult> mockResults = [];
  
  @override
  Future<List<SearchResult>> search({
    required String query,
    required String indexPath,
    int limit = 20,
  }) async {
    if (shouldFail) {
      throw SearchServiceException('Mock search error');
    }
    return mockResults;
  }
}

// Mock RustBridge
class MockRustBridge extends RustBridge {
  @override
  void init() {}

  @override
  void dispose() {}

  @override
  List<Map<String, dynamic>> search(String indexPath, String query, int limit) {
    return [];
  }

  @override
  String generateSalt() => 'mock-salt';

  @override
  String encrypt(String data, String password, String salt) => data;

  @override
  String decrypt(String encryptedData, String password, String salt) =>
      encryptedData;

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

void main() {
  group('SearchProvider Tests', () {
    late MockSearchService mockService;
    late SearchProvider provider;

    setUp(() {
      mockService = MockSearchService();
      provider = SearchProvider(searchService: mockService);
    });

    test('initializes with empty state', () {
      expect(provider.searchResults, isEmpty);
      expect(provider.isSearching, false);
      expect(provider.query, isEmpty);
      expect(provider.searchHistory, isEmpty);
      expect(provider.errorMessage, isNull);
      expect(provider.hasResults, false);
      expect(provider.hasQuery, false);
    });

    test('clears results for empty query', () async {
      // Set up some initial results
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];
      await provider.search('test', '/tmp/index');
      
      expect(provider.hasResults, true);
      
      // Search with empty query
      await provider.search('', '/tmp/index');
      
      expect(provider.searchResults, isEmpty);
      expect(provider.hasResults, false);
    });

    test('performs search and updates results', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test Note',
          contentSnippet: 'Test Content',
        ),
        SearchResult(
          noteId: 'note-2',
          score: 0.8,
          titleSnippet: 'Another Note',
          contentSnippet: 'More content',
        ),
      ];

      await provider.search('test query', '/tmp/index');

      expect(provider.searchResults.length, 2);
      expect(provider.query, 'test query');
      expect(provider.hasResults, true);
      expect(provider.hasQuery, true);
      expect(provider.isSearching, false);
    });

    test('adds successful searches to history', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      await provider.search('test query', '/tmp/index');

      expect(provider.searchHistory, contains('test query'));
      expect(provider.searchHistory.length, 1);
    });

    test('does not add failed searches to history', () async {
      mockService.shouldFail = true;

      await provider.search('test query', '/tmp/index');

      expect(provider.searchHistory, isEmpty);
      expect(provider.errorMessage, isNotNull);
    });

    test('limits search history to 10 items', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      // Add 15 searches
      for (int i = 0; i < 15; i++) {
        await provider.search('query $i', '/tmp/index');
      }

      expect(provider.searchHistory.length, 10);
      // Most recent should be first
      expect(provider.searchHistory.first, 'query 14');
      // Oldest should be dropped
      expect(provider.searchHistory, isNot(contains('query 0')));
    });

    test('moves existing query to top of history', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      // Add multiple searches
      await provider.search('query 1', '/tmp/index');
      await provider.search('query 2', '/tmp/index');
      await provider.search('query 3', '/tmp/index');
      
      expect(provider.searchHistory.first, 'query 3');
      
      // Search for query 1 again
      await provider.search('query 1', '/tmp/index');
      
      // query 1 should be at top now
      expect(provider.searchHistory.first, 'query 1');
      expect(provider.searchHistory.length, 3); // Should not duplicate
    });

    test('clears search results and query', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      await provider.search('test', '/tmp/index');
      expect(provider.hasResults, true);
      expect(provider.hasQuery, true);

      provider.clearSearch();

      expect(provider.searchResults, isEmpty);
      expect(provider.query, isEmpty);
      expect(provider.errorMessage, isNull);
      expect(provider.hasResults, false);
      expect(provider.hasQuery, false);
    });

    test('clears search history', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      await provider.search('query 1', '/tmp/index');
      await provider.search('query 2', '/tmp/index');
      
      expect(provider.searchHistory.length, 2);

      provider.clearHistory();

      expect(provider.searchHistory, isEmpty);
    });

    test('removes individual item from history', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      await provider.search('query 1', '/tmp/index');
      await provider.search('query 2', '/tmp/index');
      await provider.search('query 3', '/tmp/index');
      
      expect(provider.searchHistory.length, 3);

      provider.removeFromHistory('query 2');

      expect(provider.searchHistory.length, 2);
      expect(provider.searchHistory, isNot(contains('query 2')));
      expect(provider.searchHistory, contains('query 1'));
      expect(provider.searchHistory, contains('query 3'));
    });

    test('handles search errors gracefully', () async {
      mockService.shouldFail = true;

      await provider.search('test', '/tmp/index');

      expect(provider.searchResults, isEmpty);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Mock search error'));
      expect(provider.isSearching, false);
    });

    test('clears previous error on new search', () async {
      // First search fails
      mockService.shouldFail = true;
      await provider.search('fail', '/tmp/index');
      expect(provider.errorMessage, isNotNull);

      // Second search succeeds
      mockService.shouldFail = false;
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];
      await provider.search('success', '/tmp/index');

      expect(provider.errorMessage, isNull);
      expect(provider.hasResults, true);
    });

    test('trims whitespace from query', () async {
      mockService.mockResults = [
        SearchResult(
          noteId: 'note-1',
          score: 0.9,
          titleSnippet: 'Test',
          contentSnippet: 'Content',
        ),
      ];

      await provider.search('  test query  ', '/tmp/index');

      expect(provider.searchHistory.first, 'test query');
    });
  });
}
