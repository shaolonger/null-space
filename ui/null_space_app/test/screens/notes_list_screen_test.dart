import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/providers/note_provider.dart';
import 'package:null_space_app/screens/notes_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('NotesListScreen Widget Tests', () {
    late NoteProvider noteProvider;
    late List<Note> testNotes;

    setUp(() {
      noteProvider = NoteProvider();
      testNotes = [
        Note(
          id: 'note-1',
          title: 'First Note',
          content: 'Content of first note',
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
        Note(
          id: 'note-3',
          title: 'Third Note',
          content: 'Content of third note',
          tags: ['tag1', 'tag2', 'tag3'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          version: 1,
        ),
      ];
    });

    Widget createTestWidget({List<Note>? notes}) {
      if (notes != null) {
        noteProvider.setNotes(notes);
      }
      return ChangeNotifierProvider<NoteProvider>.value(
        value: noteProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: NotesListScreen(),
          ),
        ),
      );
    }

    testWidgets('displays empty state when no notes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: []));

      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Tap + to create your first note'), findsOneWidget);
      expect(find.byIcon(Icons.note_add), findsOneWidget);
    });

    testWidgets('displays list of notes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(find.text('First Note'), findsOneWidget);
      expect(find.text('Second Note'), findsOneWidget);
      expect(find.text('Third Note'), findsOneWidget);
    });

    testWidgets('displays note count', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(find.text('3 notes'), findsOneWidget);
    });

    testWidgets('displays singular "note" for one note',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: [testNotes[0]]));

      expect(find.text('1 note'), findsOneWidget);
    });

    testWidgets('displays sort button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('opens sort menu when sort button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Recently Updated'), findsOneWidget);
      expect(find.text('Recently Created'), findsOneWidget);
      expect(find.text('Title A-Z'), findsOneWidget);
      expect(find.text('Title Z-A'), findsOneWidget);
    });

    testWidgets('sorts notes by recently updated by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      // Find all note cards in the list
      final firstNote = find.text('Third Note'); // Updated 30m ago
      final secondNote = find.text('First Note'); // Updated 1h ago

      // Verify the order - Third Note should appear before First Note
      expect(
        tester.getTopLeft(firstNote).dy < tester.getTopLeft(secondNote).dy,
        true,
      );
    });

    testWidgets('sorts notes by title A-Z', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      // Open sort menu
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Select Title A-Z
      await tester.tap(find.text('Title A-Z'));
      await tester.pumpAndSettle();

      // Find all note cards
      final firstNote = find.text('First Note');
      final secondNote = find.text('Second Note');
      final thirdNote = find.text('Third Note');

      // Verify alphabetical order
      expect(
        tester.getTopLeft(firstNote).dy < tester.getTopLeft(secondNote).dy,
        true,
      );
      expect(
        tester.getTopLeft(secondNote).dy < tester.getTopLeft(thirdNote).dy,
        true,
      );
    });

    testWidgets('shows delete confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      // Find the first delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Note'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "First Note"?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('deletes note when confirmed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(noteProvider.notes.length, 3);

      // Find and tap the first delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(noteProvider.notes.length, 2);
      expect(find.text('Third Note'), findsNothing);
    });

    testWidgets('does not delete note when cancelled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(noteProvider.notes.length, 3);

      // Find and tap the first delete button
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(noteProvider.notes.length, 3);
      expect(find.text('Third Note'), findsOneWidget);
    });

    testWidgets('can swipe to delete note', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(noteProvider.notes.length, 3);

      // Swipe to delete the first note
      await tester.drag(find.text('Third Note'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm deletion in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(noteProvider.notes.length, 2);
      expect(find.text('Third Note'), findsNothing);
    });

    testWidgets('shows undo snackbar after deletion',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      // Delete a note
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Check for snackbar
      expect(find.text('Note "Third Note" deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('undoes deletion when undo is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(notes: testNotes));

      expect(noteProvider.notes.length, 3);

      // Delete a note
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(noteProvider.notes.length, 2);

      // Tap undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(noteProvider.notes.length, 3);
      expect(find.text('Third Note'), findsOneWidget);
    });
  });
}
