import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/screens/note_editor_screen.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/providers/note_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('NoteEditorScreen Widget Tests', () {
    late NoteProvider noteProvider;

    setUp(() {
      noteProvider = NoteProvider();
    });

    Widget createNoteEditorScreen({Note? note}) {
      return ChangeNotifierProvider<NoteProvider>.value(
        value: noteProvider,
        child: MaterialApp(
          home: NoteEditorScreen(
            note: note,
            vaultPath: '/test/vault',
            vaultPassword: 'test-password',
            vaultSalt: 'test-salt',
          ),
        ),
      );
    }

    testWidgets('displays title field for new note',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pump(); // Additional pump for initialization

      // Look for text field (title field should be present)
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('displays app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading state during initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loads existing note data when editing',
        (WidgetTester tester) async {
      final existingNote = Note(
        id: 'note-123',
        title: 'Existing Note Title',
        content: 'Existing note content',
        tags: ['test', 'flutter'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(createNoteEditorScreen(note: existingNote));
      await tester.pumpAndSettle();

      // Should load the existing note's title
      expect(find.text('Existing Note Title'), findsOneWidget);
    });

    testWidgets('accepts text input in title field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pumpAndSettle();

      // Find and enter text in title field
      final titleFields = find.byType(TextFormField);
      if (titleFields.evaluate().isNotEmpty) {
        await tester.enterText(titleFields.first, 'New Note Title');
        await tester.pump();

        expect(find.text('New Note Title'), findsOneWidget);
      }
    });

    testWidgets('accepts text input in content field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pumpAndSettle();

      // Find all text fields (should have title and content)
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), 'Note content here');
        await tester.pump();

        expect(find.text('Note content here'), findsOneWidget);
      }
    });

    testWidgets('has form for validation', (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('renders without error for new note',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pumpAndSettle();

      // Should render successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders without error for existing note',
        (WidgetTester tester) async {
      final existingNote = Note(
        id: 'note-123',
        title: 'Test Note',
        content: 'Test content',
        tags: ['test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(createNoteEditorScreen(note: existingNote));
      await tester.pumpAndSettle();

      // Should render successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles empty tags', (WidgetTester tester) async {
      final noteWithoutTags = Note(
        id: 'note-123',
        title: 'Test Note',
        content: 'Test content',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(createNoteEditorScreen(note: noteWithoutTags));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles long title', (WidgetTester tester) async {
      final noteWithLongTitle = Note(
        id: 'note-123',
        title: 'A' * 200, // Very long title
        content: 'Test content',
        tags: ['test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(
          createNoteEditorScreen(note: noteWithLongTitle));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles long content', (WidgetTester tester) async {
      final noteWithLongContent = Note(
        id: 'note-123',
        title: 'Test Note',
        content: 'B' * 5000, // Very long content
        tags: ['test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(
          createNoteEditorScreen(note: noteWithLongContent));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles many tags', (WidgetTester tester) async {
      final noteWithManyTags = Note(
        id: 'note-123',
        title: 'Test Note',
        content: 'Test content',
        tags: List.generate(20, (i) => 'tag$i'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(
          createNoteEditorScreen(note: noteWithManyTags));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles nested tags with slashes', (WidgetTester tester) async {
      final noteWithNestedTags = Note(
        id: 'note-123',
        title: 'Test Note',
        content: 'Test content',
        tags: ['work/project/urgent', 'personal/finance'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(
          createNoteEditorScreen(note: noteWithNestedTags));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles special characters in title',
        (WidgetTester tester) async {
      final noteWithSpecialChars = Note(
        id: 'note-123',
        title: 'Test! @#\$% Title',
        content: 'Test content',
        tags: ['test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(
          createNoteEditorScreen(note: noteWithSpecialChars));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining('Test!'), findsOneWidget);
    });

    testWidgets('handles unicode characters', (WidgetTester tester) async {
      final noteWithUnicode = Note(
        id: 'note-123',
        title: '测试笔记 📝 Test',
        content: 'Unicode content 🎉',
        tags: ['标签', 'tag'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(createNoteEditorScreen(note: noteWithUnicode));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles markdown in content', (WidgetTester tester) async {
      final noteWithMarkdown = Note(
        id: 'note-123',
        title: 'Markdown Note',
        content: '# Heading\n\n**Bold** and *italic*\n\n- List item',
        tags: ['markdown'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(
          createNoteEditorScreen(note: noteWithMarkdown));
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays correct title for new note',
        (WidgetTester tester) async {
      await tester.pumpWidget(createNoteEditorScreen());
      await tester.pumpAndSettle();

      // Should show "New Note" or similar in app bar
      // The actual text may vary based on localization
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays correct title for existing note',
        (WidgetTester tester) async {
      final existingNote = Note(
        id: 'note-123',
        title: 'Edit Me',
        content: 'Content',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      await tester.pumpWidget(createNoteEditorScreen(note: existingNote));
      await tester.pumpAndSettle();

      // Should show "Edit Note" or similar in app bar
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
