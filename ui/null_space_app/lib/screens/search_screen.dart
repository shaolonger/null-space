import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:null_space_app/l10n/app_localizations.dart';
import '../providers/search_provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../services/search_service.dart';
import 'note_editor_screen.dart';

/// Full-featured search screen with debounced input and results
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Debounce delay in milliseconds
  static const int _debounceDelay = 300;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debounced search
    _debounceTimer = Timer(const Duration(milliseconds: _debounceDelay), () {
      // TODO: Replace with actual index path from VaultProvider
      // The index path should be obtained from the active vault's configuration
      // Example: context.read<VaultProvider>().activeVault?.indexPath ?? '/tmp/search-index'
      final indexPath = '/tmp/search-index';
      context.read<SearchProvider>().search(query, indexPath);
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<SearchProvider>().clearSearch();
  }

  void _onSearchHistoryTap(String query) {
    _searchController.text = query;
    _onSearchChanged(query);
  }

  void _onResultTap(SearchResult result, List<Note> notes) {
    // Find the note in the provider
    final note = notes.firstWhere(
      (n) => n.id == result.noteId,
      orElse: () => Note(
        id: result.noteId,
        title: 'Note not found',
        content: '',
        tags: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      ),
    );

    // TODO: Replace with actual vault credentials from VaultProvider
    // SECURITY WARNING: These hard-coded credentials are for DEVELOPMENT ONLY
    // In production, vault credentials must be obtained from VaultProvider
    // Example: final vault = context.read<VaultProvider>().activeVault;
    // assert(vault != null, 'No active vault for opening note');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          vaultPath: '/tmp/default-vault',
          vaultPassword: 'development',
          vaultSalt: 'development-salt',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchProvider = context.watch<SearchProvider>();
    final noteProvider = context.watch<NoteProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search input field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchNotes,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchProvider.hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _onClearSearch,
                      tooltip: l10n.clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content area
          Expanded(
            child: _buildContent(searchProvider, noteProvider, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    SearchProvider searchProvider,
    NoteProvider noteProvider,
    ColorScheme colorScheme,
  ) {
    // Show loading state
    if (searchProvider.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error message if present
    if (searchProvider.errorMessage != null) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              searchProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ],
        ),
      );
    }

    // Show results if we have a query and results
    if (searchProvider.hasQuery && searchProvider.hasResults) {
      return _buildResultsList(searchProvider, noteProvider.notes);
    }

    // Show no results message if we have a query but no results
    if (searchProvider.hasQuery && !searchProvider.hasResults) {
      return _buildEmptyResults();
    }

    // Show search history or welcome message
    return _buildSearchHistory(searchProvider);
  }

  Widget _buildResultsList(SearchProvider searchProvider, List<Note> notes) {
    return ListView.builder(
      itemCount: searchProvider.searchResults.length,
      itemBuilder: (context, index) {
        final result = searchProvider.searchResults[index];
        return _SearchResultCard(
          result: result,
          onTap: () => _onResultTap(result, notes),
        );
      },
    );
  }

  Widget _buildEmptyResults() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryDifferentKeywords,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(SearchProvider searchProvider) {
    final l10n = AppLocalizations.of(context)!;
    if (searchProvider.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.searchYourNotes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterKeywords,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: searchProvider.clearHistory,
              child: Text(l10n.clear),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: searchProvider.searchHistory.length,
            itemBuilder: (context, index) {
              final query = searchProvider.searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => searchProvider.removeFromHistory(query),
                  tooltip: l10n.clear,
                ),
                onTap: () => _onSearchHistoryTap(query),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Card widget to display a single search result
class _SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with highlight
              _buildHighlightedText(
                result.titleSnippet.isNotEmpty
                    ? result.titleSnippet
                    : l10n.untitledNote,
                context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                colorScheme,
              ),
              const SizedBox(height: 8),

              // Content snippet with highlight
              if (result.contentSnippet.isNotEmpty)
                _buildHighlightedText(
                  result.contentSnippet,
                  context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  colorScheme,
                ),

              // Relevance score (for debugging/development)
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Score: ${result.score.toStringAsFixed(2)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text with highlighted search terms
  /// This is a simple implementation that highlights text between ** markers
  Widget _buildHighlightedText(
    String text,
    TextStyle? baseStyle,
    ColorScheme colorScheme,
  ) {
    // Simple highlighting: assuming the Rust bridge returns text with ** markers
    // Example: "This is **important** text"
    final spans = <TextSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Normal text
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      } else {
        // Highlighted text
        spans.add(TextSpan(
          text: parts[i],
          style: baseStyle?.copyWith(
            backgroundColor: colorScheme.primaryContainer,
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Extension to access text theme directly from BuildContext
extension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
