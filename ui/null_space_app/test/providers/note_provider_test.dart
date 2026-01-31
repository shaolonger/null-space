import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/providers/note_provider.dart';

void main() {
  group('NoteProvider Tests', () {
    late NoteProvider provider;
    late Note note1;
    late Note note2;
    late Note note3;

    setUp(() {
      provider = NoteProvider();
      note1 = Note(
        id: 'note-1',
        title: 'Flutter Tutorial',
        content: 'Learn Flutter basics',
        tags: ['flutter', 'tutorial', 'mobile'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        version: 1,
      );
      note2 = Note(
        id: 'note-2',
        title: 'Dart Guide',
        content: 'Dart programming fundamentals',
        tags: ['dart', 'tutorial'],
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
        version: 1,
      );
      note3 = Note(
        id: 'note-3',
        title: 'Shopping List',
        content: 'Milk, Bread, Eggs',
        tags: ['personal', 'shopping'],
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 3),
        version: 1,
      );
    });

    test('initializes with empty lists', () {
      expect(provider.notes, isEmpty);
      expect(provider.selectedNote, isNull);
      expect(provider.searchQuery, '');
      expect(provider.selectedTags, isEmpty);
      expect(provider.allTags, isEmpty);
      expect(provider.tagCounts, isEmpty);
    });

    test('setNotes updates notes list', () {
      provider.setNotes([note1, note2]);
      expect(provider.notes.length, 2);
      expect(provider.notes, contains(note1));
      expect(provider.notes, contains(note2));
    });

    test('addNote adds note to list', () {
      provider.addNote(note1);
      expect(provider.notes.length, 1);
      expect(provider.notes.first, note1);

      provider.addNote(note2);
      expect(provider.notes.length, 2);
    });

    test('updateNote updates existing note', () {
      provider.setNotes([note1, note2]);
      
      final updatedNote = Note(
        id: 'note-1',
        title: 'Updated Flutter Tutorial',
        content: 'Updated content',
        tags: ['flutter', 'updated'],
        createdAt: note1.createdAt,
        updatedAt: DateTime(2024, 1, 10),
        version: 2,
      );

      provider.updateNote(updatedNote);
      
      final foundNote = provider.notes.firstWhere((n) => n.id == 'note-1');
      expect(foundNote.title, 'Updated Flutter Tutorial');
      expect(foundNote.version, 2);
    });

    test('updateNote updates selected note if it matches', () {
      provider.setNotes([note1, note2]);
      provider.selectNote(note1);
      
      final updatedNote = Note(
        id: 'note-1',
        title: 'Updated Title',
        content: 'Updated content',
        tags: ['updated'],
        createdAt: note1.createdAt,
        updatedAt: DateTime.now(),
        version: 2,
      );

      provider.updateNote(updatedNote);
      
      expect(provider.selectedNote?.title, 'Updated Title');
    });

    test('updateNote does nothing for non-existent note', () {
      provider.setNotes([note1]);
      
      final nonExistentNote = Note(
        id: 'note-999',
        title: 'Non-existent',
        content: 'Content',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      provider.updateNote(nonExistentNote);
      
      expect(provider.notes.length, 1);
      expect(provider.notes.first, note1);
    });

    test('deleteNote removes note from list', () {
      provider.setNotes([note1, note2, note3]);
      expect(provider.notes.length, 3);

      provider.deleteNote('note-2');
      expect(provider.notes.length, 2);
      expect(provider.notes.any((n) => n.id == 'note-2'), false);
    });

    test('deleteNote clears selected note if it matches', () {
      provider.setNotes([note1, note2]);
      provider.selectNote(note1);
      
      provider.deleteNote('note-1');
      
      expect(provider.selectedNote, isNull);
    });

    test('selectNote sets selected note', () {
      provider.selectNote(note1);
      expect(provider.selectedNote, note1);
    });

    test('selectNote can be set to null', () {
      provider.selectNote(note1);
      expect(provider.selectedNote, note1);
      
      provider.selectNote(null);
      expect(provider.selectedNote, isNull);
    });

    test('allTags returns unique sorted tags', () {
      provider.setNotes([note1, note2, note3]);
      
      final tags = provider.allTags;
      expect(tags.length, 5);
      expect(tags, contains('flutter'));
      expect(tags, contains('dart'));
      expect(tags, contains('tutorial'));
      expect(tags, contains('mobile'));
      expect(tags, contains('personal'));
      expect(tags, contains('shopping'));
      
      // Check if sorted
      expect(tags, equals(tags.toList()..sort()));
    });

    test('tagCounts returns correct counts', () {
      provider.setNotes([note1, note2, note3]);
      
      final counts = provider.tagCounts;
      expect(counts['flutter'], 1);
      expect(counts['dart'], 1);
      expect(counts['tutorial'], 2); // Appears in note1 and note2
      expect(counts['mobile'], 1);
      expect(counts['personal'], 1);
      expect(counts['shopping'], 1);
    });

    test('setSearchQuery filters notes by title', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('flutter');
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Flutter Tutorial');
    });

    test('setSearchQuery filters notes by content', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('fundamentals');
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Dart Guide');
    });

    test('setSearchQuery filters notes by tags', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('shopping');
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Shopping List');
    });

    test('setSearchQuery is case insensitive', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('FLUTTER');
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Flutter Tutorial');
    });

    test('setSelectedTags filters notes by tags (AND logic)', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSelectedTags(['tutorial']);
      expect(provider.notes.length, 2); // note1 and note2
      
      provider.setSelectedTags(['flutter', 'tutorial']);
      expect(provider.notes.length, 1); // Only note1
      expect(provider.notes.first.title, 'Flutter Tutorial');
    });

    test('setSelectedTags with empty list shows all notes', () {
      provider.setNotes([note1, note2, note3]);
      provider.setSelectedTags(['tutorial']);
      expect(provider.notes.length, 2);
      
      provider.setSelectedTags([]);
      expect(provider.notes.length, 3);
    });

    test('search and tag filters work together', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSelectedTags(['tutorial']);
      provider.setSearchQuery('flutter');
      
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Flutter Tutorial');
    });

    test('clearFilters resets search and tag filters', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('flutter');
      provider.setSelectedTags(['tutorial']);
      expect(provider.notes.length, 1);
      
      provider.clearFilters();
      expect(provider.searchQuery, '');
      expect(provider.selectedTags, isEmpty);
      expect(provider.notes.length, 3);
    });

    test('notifies listeners on setNotes', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setNotes([note1]);
      expect(notified, true);
    });

    test('notifies listeners on addNote', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.addNote(note1);
      expect(notified, true);
    });

    test('notifies listeners on updateNote', () {
      provider.setNotes([note1]);
      
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updateNote(note1);
      expect(notified, true);
    });

    test('notifies listeners on deleteNote', () {
      provider.setNotes([note1]);
      
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.deleteNote('note-1');
      expect(notified, true);
    });

    test('notifies listeners on selectNote', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.selectNote(note1);
      expect(notified, true);
    });

    test('notifies listeners on setSearchQuery', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setSearchQuery('test');
      expect(notified, true);
    });

    test('notifies listeners on setSelectedTags', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setSelectedTags(['tag1']);
      expect(notified, true);
    });

    test('notifies listeners on clearFilters', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.clearFilters();
      expect(notified, true);
    });

    test('handles empty search query', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('');
      expect(provider.notes.length, 3);
    });

    test('handles search query with no matches', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSearchQuery('nonexistent');
      expect(provider.notes, isEmpty);
    });

    test('handles tag filter with no matches', () {
      provider.setNotes([note1, note2, note3]);
      
      provider.setSelectedTags(['nonexistent-tag']);
      expect(provider.notes, isEmpty);
    });

    test('allTags handles notes with duplicate tags', () {
      final noteWithDupeTags = Note(
        id: 'note-dupe',
        title: 'Dupe',
        content: 'Content',
        tags: ['flutter', 'flutter', 'dart'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );
      
      provider.setNotes([note1, noteWithDupeTags]);
      
      final tags = provider.allTags;
      // Should be deduplicated
      expect(tags.where((t) => t == 'flutter').length, 1);
      expect(tags.where((t) => t == 'dart').length, 1);
    });

    test('tagCounts handles notes with duplicate tags correctly', () {
      final noteWithDupeTags = Note(
        id: 'note-dupe',
        title: 'Dupe',
        content: 'Content',
        tags: ['flutter', 'flutter'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );
      
      provider.setNotes([note1, noteWithDupeTags]);
      
      final counts = provider.tagCounts;
      // Should count each occurrence (2 from noteWithDupeTags, 1 from note1)
      expect(counts['flutter'], 3);
    });
  });
}
