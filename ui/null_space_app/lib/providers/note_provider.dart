import 'package:flutter/foundation.dart';
import '../models/note.dart';

/// Provider for managing notes
class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  Note? _selectedNote;
  String _searchQuery = '';
  List<String> _selectedTags = [];

  List<Note> get notes => _filteredNotes;
  Note? get selectedNote => _selectedNote;
  String get searchQuery => _searchQuery;
  List<String> get selectedTags => _selectedTags;

  /// Get all unique tags from all notes
  List<String> get allTags {
    final tagSet = <String>{};
    for (final note in _notes) {
      tagSet.addAll(note.tags);
    }
    return tagSet.toList()..sort();
  }

  /// Get note counts for each tag
  Map<String, int> get tagCounts {
    final counts = <String, int>{};
    for (final note in _notes) {
      for (final tag in note.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<Note> get _filteredNotes {
    var filtered = _notes;

    // Filter by selected tags (AND logic)
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((note) {
        return _selectedTags.every((tag) => note.tags.contains(tag));
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }

  void setNotes(List<Note> notes) {
    _notes = notes;
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      if (_selectedNote?.id == note.id) {
        _selectedNote = note;
      }
      notifyListeners();
    }
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((n) => n.id == noteId);
    if (_selectedNote?.id == noteId) {
      _selectedNote = null;
    }
    notifyListeners();
  }

  void selectNote(Note? note) {
    _selectedNote = note;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTags(List<String> tags) {
    _selectedTags = tags;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTags = [];
    notifyListeners();
  }
}
