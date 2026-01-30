import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/widgets/note_card.dart';

void main() {
  group('NoteCard Widget Tests', () {
    late Note testNote;
    bool tapped = false;
    bool deleted = false;

    setUp(() {
      tapped = false;
      deleted = false;
      testNote = Note(
        id: 'test-id-123',
        title: 'Test Note Title',
        content: 'This is test content for the note card widget',
        tags: ['test', 'flutter', 'widget'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        version: 1,
      );
    });

    testWidgets('displays note title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Note Title'), findsOneWidget);
    });

    testWidgets('displays "Untitled Note" when title is empty',
        (WidgetTester tester) async {
      testNote.title = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Untitled Note'), findsOneWidget);
    });

    testWidgets('displays note content preview', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(
          find.text('This is test content for the note card widget'), findsOneWidget);
    });

    testWidgets('displays tags as chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(Chip, 'test'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'flutter'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'widget'), findsOneWidget);
    });

    testWidgets('limits visible tags to 3 with +N indicator',
        (WidgetTester tester) async {
      testNote.tags = ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(Chip, 'tag1'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'tag2'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'tag3'), findsOneWidget);
      expect(find.widgetWithText(Chip, '+2'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'tag4'), findsNothing);
    });

    testWidgets('displays relative date format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Should show "3h ago" for 3 hours ago
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(tapped, false);
      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });

    testWidgets('calls onDelete when delete button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(deleted, false);
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, true);
    });

    testWidgets('shows elevated card when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NoteCard(
                  note: testNote,
                  onTap: () => tapped = true,
                  onDelete: () => deleted = true,
                  isSelected: true,
                ),
                NoteCard(
                  note: testNote,
                  onTap: () => tapped = true,
                  onDelete: () => deleted = true,
                  isSelected: false,
                ),
              ],
            ),
          ),
        ),
      );

      final selectedCards = tester.widgetList<Card>(find.byType(Card));
      expect(selectedCards.length, 2);
      // Selected card should have higher elevation
      expect(selectedCards.first.elevation, 4);
      expect(selectedCards.last.elevation, 1);
    });

    testWidgets('handles empty content gracefully', (WidgetTester tester) async {
      testNote.content = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Should still render the card without error
      expect(find.byType(NoteCard), findsOneWidget);
      expect(find.text('Test Note Title'), findsOneWidget);
    });

    testWidgets('handles empty tags gracefully', (WidgetTester tester) async {
      testNote.tags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Should still render the card without error
      expect(find.byType(NoteCard), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });
  });
}
