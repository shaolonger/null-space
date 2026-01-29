import 'package:flutter/foundation.dart';
import '../models/note.dart';

/// Provider for managing notes
class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  Note? _selectedNote;
  String _searchQuery = '';

  List<Note> get notes => _filteredNotes;
  Note? get selectedNote => _selectedNote;
  String get searchQuery => _searchQuery;

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
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
}
