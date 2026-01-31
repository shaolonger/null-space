import 'package:flutter/foundation.dart';
import '../services/search_service.dart';

/// Provider for managing search state and operations
class SearchProvider extends ChangeNotifier {
  final SearchService _searchService;
  
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _query = '';
  List<String> _searchHistory = [];
  String? _errorMessage;

  SearchProvider({required SearchService searchService})
      : _searchService = searchService;

  // Getters
  List<SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get query => _query;
  List<String> get searchHistory => _searchHistory;
  String? get errorMessage => _errorMessage;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasQuery => _query.isNotEmpty;

  /// Perform search with the given query
  Future<void> search(String query, String indexPath, {int limit = 20}) async {
    // Trim query for consistency
    final trimmedQuery = query.trim();
    _query = trimmedQuery;
    _errorMessage = null;

    // Clear results if query is empty
    if (trimmedQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Perform the search
      _searchResults = await _searchService.search(
        query: trimmedQuery,
        indexPath: indexPath,
        limit: limit,
      );

      // Add to search history if we got results
      if (_searchResults.isNotEmpty) {
        _addToHistory(trimmedQuery);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search results and query
  void clearSearch() {
    _query = '';
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Add query to search history (max 10 items)
  void _addToHistory(String query) {
    // Remove if already exists
    _searchHistory.remove(query);
    // Add to beginning
    _searchHistory.insert(0, query);
    // Keep only last 10
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
  }

  /// Clear search history
  void clearHistory() {
    _searchHistory = [];
    notifyListeners();
  }

  /// Remove a specific item from search history
  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }
}
