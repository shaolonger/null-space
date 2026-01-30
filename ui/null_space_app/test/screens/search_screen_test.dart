import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/providers/note_provider.dart';
import 'package:null_space_app/providers/search_provider.dart';
import 'package:null_space_app/services/search_service.dart';
import 'package:null_space_app/screens/search_screen.dart';
import 'package:provider/provider.dart';

// Mock SearchService for testing
class MockSearchService extends SearchService {
  MockSearchService() : super(bridge: MockRustBridge());
  
  @override
  Future<List<SearchResult>> search({
    required String query,
    required String indexPath,
    int limit = 20,
  }) async {
    // Return mock results based on query
    if (query.isEmpty) {
      return [];
    }
    
    if (query.toLowerCase().contains('important')) {
      return [
        SearchResult(
          noteId: 'note-1',
          score: 0.95,
          titleSnippet: 'First **important** Note',
          contentSnippet: 'This contains **important** information',
        ),
      ];
    }
    
    if (query.toLowerCase().contains('error')) {
      throw SearchServiceException('Mock search error');
    }
    
    return [];
  }
}

// Mock RustBridge for testing
class MockRustBridge {
  void init() {}
  void dispose() {}
  List<Map<String, dynamic>> search(String indexPath, String query, int limit) {
    return [];
  }
}

void main() {
  group('SearchScreen Widget Tests', () {
    late NoteProvider noteProvider;
    late SearchProvider searchProvider;
    late List<Note> testNotes;

    setUp(() {
      noteProvider = NoteProvider();
      searchProvider = SearchProvider(searchService: MockSearchService());
      testNotes = [
        Note(
          id: 'note-1',
          title: 'First Important Note',
          content: 'This contains important information',
          tags: ['tag1'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          version: 1,
        ),
        Note(
          id: 'note-2',
          title: 'Second Note',
          content: 'Content of second note',
          tags: ['tag2', 'tag3'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          version: 1,
        ),
      ];
      noteProvider.setNotes(testNotes);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<NoteProvider>.value(value: noteProvider),
          ChangeNotifierProvider<SearchProvider>.value(value: searchProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SearchScreen(),
          ),
        ),
      );
    }

    testWidgets('displays search input field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search notes...'), findsOneWidget);
    });

    testWidgets('displays welcome message when no query',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Search Your Notes'), findsOneWidget);
      expect(find.text('Enter keywords to find notes'), findsOneWidget);
    });

    testWidgets('displays clear button when query is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears search when clear button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // TextField should be empty
      expect(find.text('test query'), findsNothing);
    });

    testWidgets('displays loading indicator during search',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Manually set searching state
      searchProvider.search('test', '/tmp/index');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays search results when available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter search query that will return results
      await tester.enterText(find.byType(TextField), 'important');
      
      // Wait for debounce and search to complete
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Results should be displayed
      expect(find.text('First **important** Note'), findsOneWidget);
    });

    testWidgets('displays no results message when no matches found',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter search query that will return no results
      await tester.enterText(find.byType(TextField), 'nomatch');
      
      // Wait for debounce and search to complete
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('No Results Found'), findsOneWidget);
      expect(find.text('Try different keywords or check your spelling'),
          findsOneWidget);
    });

    testWidgets('displays recent searches section when history exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add search to history by performing a search
      await tester.enterText(find.byType(TextField), 'important');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Should show recent searches
      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('tapping search history item performs search',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add search to history
      await tester.enterText(find.byType(TextField), 'important');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Tap on history item
      await tester.tap(find.text('important').last);
      await tester.pumpAndSettle();

      // Should perform search again
      expect(find.text('First **important** Note'), findsOneWidget);
    });

    testWidgets('clears all search history when Clear All is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add search to history
      await tester.enterText(find.byType(TextField), 'important');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Clear all history
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Should show welcome message again
      expect(find.text('Search Your Notes'), findsOneWidget);
      expect(find.text('Recent Searches'), findsNothing);
    });

    testWidgets('removes individual item from history',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Add search to history
      await tester.enterText(find.byType(TextField), 'important');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Find and tap the close button for the history item
      final closeButtons = find.byIcon(Icons.close);
      if (closeButtons.evaluate().isNotEmpty) {
        await tester.tap(closeButtons.first);
        await tester.pumpAndSettle();

        // Should show welcome message again
        expect(find.text('Search Your Notes'), findsOneWidget);
      }
    });

    testWidgets('displays error message on search failure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter query that triggers error
      await tester.enterText(find.byType(TextField), 'error');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Search Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
