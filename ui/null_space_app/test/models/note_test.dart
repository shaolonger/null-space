import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/note.dart';

void main() {
  group('Note Model Tests', () {
    late Note testNote;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 30);
      testUpdatedAt = DateTime(2024, 1, 16, 14, 45);
      testNote = Note(
        id: 'test-note-123',
        title: 'Test Note',
        content: 'This is test content',
        tags: ['flutter', 'dart', 'testing'],
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        version: 1,
      );
    });

    test('creates note with all properties', () {
      expect(testNote.id, 'test-note-123');
      expect(testNote.title, 'Test Note');
      expect(testNote.content, 'This is test content');
      expect(testNote.tags, ['flutter', 'dart', 'testing']);
      expect(testNote.createdAt, testCreatedAt);
      expect(testNote.updatedAt, testUpdatedAt);
      expect(testNote.version, 1);
    });

    test('toJson serializes note correctly', () {
      final json = testNote.toJson();

      expect(json['id'], 'test-note-123');
      expect(json['title'], 'Test Note');
      expect(json['content'], 'This is test content');
      expect(json['tags'], ['flutter', 'dart', 'testing']);
      expect(json['created_at'], testCreatedAt.toIso8601String());
      expect(json['updated_at'], testUpdatedAt.toIso8601String());
      expect(json['version'], 1);
    });

    test('fromJson deserializes note correctly', () {
      final json = {
        'id': 'note-456',
        'title': 'Deserialized Note',
        'content': 'Content from JSON',
        'tags': ['json', 'test'],
        'created_at': '2024-02-01T09:00:00.000',
        'updated_at': '2024-02-02T10:30:00.000',
        'version': 2,
      };

      final note = Note.fromJson(json);

      expect(note.id, 'note-456');
      expect(note.title, 'Deserialized Note');
      expect(note.content, 'Content from JSON');
      expect(note.tags, ['json', 'test']);
      expect(note.createdAt, DateTime.parse('2024-02-01T09:00:00.000'));
      expect(note.updatedAt, DateTime.parse('2024-02-02T10:30:00.000'));
      expect(note.version, 2);
    });

    test('serialization and deserialization round trip', () {
      final json = testNote.toJson();
      final deserializedNote = Note.fromJson(json);

      expect(deserializedNote.id, testNote.id);
      expect(deserializedNote.title, testNote.title);
      expect(deserializedNote.content, testNote.content);
      expect(deserializedNote.tags, testNote.tags);
      expect(
        deserializedNote.createdAt.toIso8601String(),
        testNote.createdAt.toIso8601String(),
      );
      expect(
        deserializedNote.updatedAt.toIso8601String(),
        testNote.updatedAt.toIso8601String(),
      );
      expect(deserializedNote.version, testNote.version);
    });

    test('handles empty title', () {
      final note = Note(
        id: 'note-empty-title',
        title: '',
        content: 'Content',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      expect(note.title, '');
      final json = note.toJson();
      expect(json['title'], '');
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.title, '');
    });

    test('handles empty content', () {
      final note = Note(
        id: 'note-empty-content',
        title: 'Title',
        content: '',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      expect(note.content, '');
      final json = note.toJson();
      expect(json['content'], '');
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.content, '');
    });

    test('handles empty tags', () {
      final note = Note(
        id: 'note-no-tags',
        title: 'Title',
        content: 'Content',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      expect(note.tags, []);
      final json = note.toJson();
      expect(json['tags'], []);
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.tags, []);
    });

    test('handles multiple tags', () {
      final note = Note(
        id: 'note-many-tags',
        title: 'Title',
        content: 'Content',
        tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      expect(note.tags.length, 5);
      final json = note.toJson();
      expect(json['tags'].length, 5);
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.tags.length, 5);
      expect(deserializedNote.tags, ['tag1', 'tag2', 'tag3', 'tag4', 'tag5']);
    });

    test('title is mutable', () {
      testNote.title = 'Updated Title';
      expect(testNote.title, 'Updated Title');
    });

    test('content is mutable', () {
      testNote.content = 'Updated content';
      expect(testNote.content, 'Updated content');
    });

    test('tags is mutable', () {
      testNote.tags = ['new', 'tags'];
      expect(testNote.tags, ['new', 'tags']);
    });

    test('updatedAt is mutable', () {
      final newDate = DateTime(2024, 2, 1, 12, 0);
      testNote.updatedAt = newDate;
      expect(testNote.updatedAt, newDate);
    });

    test('version is mutable', () {
      testNote.version = 2;
      expect(testNote.version, 2);
    });

    test('handles nested tags with slashes', () {
      final note = Note(
        id: 'note-nested-tags',
        title: 'Title',
        content: 'Content',
        tags: ['work/project/urgent', 'personal/finance'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      expect(note.tags, ['work/project/urgent', 'personal/finance']);
      final json = note.toJson();
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.tags, ['work/project/urgent', 'personal/finance']);
    });

    test('handles special characters in content', () {
      final note = Note(
        id: 'note-special-chars',
        title: 'Special Title! @#\$%',
        content: 'Content with "quotes" and \'apostrophes\' and \n newlines',
        tags: ['tag-with-dash', 'tag_with_underscore'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      final json = note.toJson();
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.title, note.title);
      expect(deserializedNote.content, note.content);
      expect(deserializedNote.tags, note.tags);
    });

    test('handles very large version numbers', () {
      final note = Note(
        id: 'note-large-version',
        title: 'Title',
        content: 'Content',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 999999,
      );

      expect(note.version, 999999);
      final json = note.toJson();
      expect(json['version'], 999999);
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.version, 999999);
    });

    test('handles very long content', () {
      final longContent = List.filled(10000, 'A').join(); // 10,000 characters
      final note = Note(
        id: 'note-long-content',
        title: 'Title',
        content: longContent,
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );

      expect(note.content.length, 10000);
      final json = note.toJson();
      final deserializedNote = Note.fromJson(json);
      expect(deserializedNote.content.length, 10000);
      expect(deserializedNote.content, longContent);
    });

    test('preserves datetime precision', () {
      final preciseDate = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);
      final note = Note(
        id: 'note-precise-date',
        title: 'Title',
        content: 'Content',
        tags: [],
        createdAt: preciseDate,
        updatedAt: preciseDate,
        version: 1,
      );

      final json = note.toJson();
      final deserializedNote = Note.fromJson(json);
      // DateTime.parse may not preserve microseconds, but should preserve milliseconds
      expect(
        deserializedNote.createdAt.millisecondsSinceEpoch,
        preciseDate.millisecondsSinceEpoch,
      );
    });
  });
}
