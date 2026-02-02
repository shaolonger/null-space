import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:null_space_app/l10n/app_localizations.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/vault_provider.dart';
import '../services/vault_service.dart';
import '../widgets/note_card.dart';
import '../widgets/tag_filter_widget.dart';
import 'note_editor_screen.dart';

/// Notes list screen with sorting, filtering, and management
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  SortOption _sortOption = SortOption.updatedDesc;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final notes = _sortNotes(noteProvider.notes);

        if (notes.isEmpty) {
          return _buildEmptyState(l10n);
        }

        return Column(
          children: [
            _buildSortBar(l10n),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Dismissible(
                      key: Key(note.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _confirmDelete(note),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: NoteCard(
                        note: note,
                        onTap: () => _openNoteEditor(note),
                        onDelete: () => _deleteNote(note),
                        isSelected: noteProvider.selectedNote?.id == note.id,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotesYet,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              final count = noteProvider.notes.length;
              return Text(
                '$count ${count == 1 ? 'note' : 'notes'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              );
            },
          ),
          Row(
            children: [
              // Tag filter button
              Consumer<NoteProvider>(
                builder: (context, noteProvider, child) {
                  final hasFilters = noteProvider.selectedTags.isNotEmpty;
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: hasFilters,
                      label: Text('${noteProvider.selectedTags.length}'),
                      child: Icon(
                        hasFilters
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                      ),
                    ),
                    tooltip: l10n.filterByTags,
                    onPressed: () => _showTagFilter(context),
                  );
                },
              ),
              // Sort button
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                tooltip: l10n.sortBy,
                onSelected: (option) {
                  setState(() {
                    _sortOption = option;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortOption.updatedDesc,
                    child: Row(
                      children: [
                        Icon(
                          _sortOption == SortOption.updatedDesc
                              ? Icons.check
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.recentlyUpdated),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortOption.createdDesc,
                    child: Row(
                      children: [
                        Icon(
                          _sortOption == SortOption.createdDesc
                              ? Icons.check
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.recentlyCreated),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortOption.titleAsc,
                    child: Row(
                      children: [
                        Icon(
                          _sortOption == SortOption.titleAsc
                              ? Icons.check
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.titleAZ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortOption.titleDesc,
                    child: Row(
                      children: [
                        Icon(
                          _sortOption == SortOption.titleDesc
                              ? Icons.check
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.titleZA),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Note> _sortNotes(List<Note> notes) {
    final sortedNotes = List<Note>.from(notes);

    switch (_sortOption) {
      case SortOption.updatedDesc:
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.createdDesc:
        sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.titleAsc:
        final l10n = AppLocalizations.of(context)!;
        sortedNotes.sort((a, b) {
          final titleA = a.title.isEmpty ? l10n.untitledNote : a.title;
          final titleB = b.title.isEmpty ? l10n.untitledNote : b.title;
          return titleA.toLowerCase().compareTo(titleB.toLowerCase());
        });
        break;
      case SortOption.titleDesc:
        final l10n = AppLocalizations.of(context)!;
        sortedNotes.sort((a, b) {
          final titleA = a.title.isEmpty ? l10n.untitledNote : a.title;
          final titleB = b.title.isEmpty ? l10n.untitledNote : b.title;
          return titleB.toLowerCase().compareTo(titleA.toLowerCase());
        });
        break;
    }

    return sortedNotes;
  }

  Future<void> _onRefresh() async {
    // Placeholder for refresh functionality
    // In a production app, this would reload notes from encrypted storage
    // For now, just provide visual feedback to the user
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _openNoteEditor(Note note) async {
    context.read<NoteProvider>().selectNote(note);

    final vaultProvider = context.read<VaultProvider>();
    final currentVault = vaultProvider.currentVault;

    if (currentVault == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please unlock a vault first')),
      );
      return;
    }

    final vaultService = context.read<VaultService>();

    final vaultPassword = vaultService.getVaultPassword(currentVault.id);
    if (vaultPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vault is locked. Please unlock it first')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          vaultPath: 'vaults/${currentVault.id}',
          vaultPassword: vaultPassword,
          vaultSalt: currentVault.salt,
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await _confirmDelete(note);
    if (confirmed == true) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final noteProvider = context.read<NoteProvider>();
        noteProvider.deleteNote(note.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDeleted),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Note: Undo adds the note back to the list, which may not preserve
                // the original position. Since the list is sorted, this is acceptable behavior.
                noteProvider.addNote(note);
              },
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _confirmDelete(Note note) {
    final l10n = AppLocalizations.of(context)!;
    final noteTitle = note.title.isEmpty ? l10n.untitledNote : note.title;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirmation(noteTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer<NoteProvider>(
          builder: (context, provider, child) => TagFilterWidget(
            allTags: provider.allTags,
            selectedTags: provider.selectedTags,
            onTagsChanged: (tags) {
              provider.setSelectedTags(tags);
            },
            tagCounts: provider.tagCounts,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }
}

/// Sort options for notes list
enum SortOption {
  updatedDesc,
  createdDesc,
  titleAsc,
  titleDesc,
}
