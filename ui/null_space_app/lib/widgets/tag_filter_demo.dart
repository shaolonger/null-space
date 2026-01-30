import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:null_space_app/models/note.dart';
import 'package:null_space_app/providers/note_provider.dart';
import 'package:null_space_app/widgets/tag_filter_widget.dart';

/// Demo screen to showcase the TagFilterWidget functionality
/// This demonstrates how the widget works with sample data
class TagFilterDemo extends StatelessWidget {
  const TagFilterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteProvider()..setNotes(_getSampleNotes()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tag Filter Widget Demo'),
        ),
        body: Column(
          children: [
            // Tag Filter Widget
            Expanded(
              flex: 3,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Consumer<NoteProvider>(
                  builder: (context, provider, child) => TagFilterWidget(
                    allTags: provider.allTags,
                    selectedTags: provider.selectedTags,
                    onTagsChanged: (tags) {
                      provider.setSelectedTags(tags);
                    },
                    tagCounts: provider.tagCounts,
                  ),
                ),
              ),
            ),
            // Filtered Notes Count
            Consumer<NoteProvider>(
              builder: (context, provider, child) {
                final filteredCount = provider.notes.length;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Showing $filteredCount notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (provider.selectedTags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: provider.selectedTags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      onDeleted: () {
                                        final newTags = List<String>.from(
                                            provider.selectedTags)
                                          ..remove(tag);
                                        provider.setSelectedTags(newTags);
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            // Sample Notes List
            Expanded(
              flex: 2,
              child: Consumer<NoteProvider>(
                builder: (context, provider, child) {
                  final notes = provider.notes;
                  if (notes.isEmpty) {
                    return const Center(
                      child: Text('No notes match the selected filters'),
                    );
                  }
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.tags.join(', ')),
                        trailing: const Icon(Icons.note),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Note> _getSampleNotes() {
    final now = DateTime.now();
    return [
      Note(
        id: '1',
        title: 'Project Alpha Kickoff',
        content: 'Initial meeting notes for Project Alpha',
        tags: ['work/project-a/urgent', 'work/project-a/review'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        version: 1,
      ),
      Note(
        id: '2',
        title: 'Budget Review Q1',
        content: 'Financial review for Q1',
        tags: ['work/project-a/review', 'personal/finance'],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 2)),
        version: 1,
      ),
      Note(
        id: '3',
        title: 'Health Checkup Reminder',
        content: 'Schedule annual health checkup',
        tags: ['personal/health', 'urgent'],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        version: 1,
      ),
      Note(
        id: '4',
        title: 'Project Beta Documentation',
        content: 'Documentation for Project Beta',
        tags: ['work/project-b', 'work/project-b/documentation'],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 3)),
        version: 1,
      ),
      Note(
        id: '5',
        title: 'Meeting Notes - Team Sync',
        content: 'Weekly team sync meeting notes',
        tags: ['work', 'meetings'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        version: 1,
      ),
      Note(
        id: '6',
        title: 'Personal Goals 2026',
        content: 'Goals and aspirations for 2026',
        tags: ['personal', 'goals'],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 4)),
        version: 1,
      ),
      Note(
        id: '7',
        title: 'Code Review - Feature X',
        content: 'Review notes for Feature X implementation',
        tags: ['work/project-a/review', 'urgent'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 8)),
        version: 1,
      ),
      Note(
        id: '8',
        title: 'Investment Strategy',
        content: 'Investment plans and strategies',
        tags: ['personal/finance', 'personal/finance/investments'],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
        version: 1,
      ),
    ];
  }
}
