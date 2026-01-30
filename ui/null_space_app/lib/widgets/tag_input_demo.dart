import 'package:flutter/material.dart';
import 'tag_input_widget.dart';

/// Demo application for TagInputWidget
/// 
/// This demonstrates the tag input widget with sample data
/// and shows how it can be used in a real application.
class TagInputDemo extends StatefulWidget {
  const TagInputDemo({super.key});

  @override
  State<TagInputDemo> createState() => _TagInputDemoState();
}

class _TagInputDemoState extends State<TagInputDemo> {
  List<String> _selectedTags = [];
  
  // Sample available tags from a vault
  final List<String> _availableTags = [
    'work',
    'work/project-a',
    'work/project-a/urgent',
    'work/project-a/review',
    'work/project-b',
    'work/project-b/bug-fix',
    'personal',
    'personal/finance',
    'personal/health',
    'personal/fitness',
    'urgent',
    'review',
    'todo',
    'ideas',
    'meeting-notes',
  ];

  void _handleTagsChanged(List<String> newTags) {
    setState(() {
      _selectedTags = newTags;
    });
  }

  void _clearTags() {
    setState(() {
      _selectedTags = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Input Widget Demo'),
        actions: [
          if (_selectedTags.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearTags,
              tooltip: 'Clear all tags',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tag Input Widget Demo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This widget provides tag input with autocomplete:\n'
                      '• Type to see autocomplete suggestions\n'
                      '• Select from dropdown or press Enter\n'
                      '• Create new tags by typing and submitting\n'
                      '• Remove tags by clicking the X button\n'
                      '• Supports hierarchical tags (work/project)',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tag input widget
            Text(
              'Add Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TagInputWidget(
              availableTags: _availableTags,
              selectedTags: _selectedTags,
              onTagsChanged: _handleTagsChanged,
              maxSuggestions: 5,
              allowNewTags: true,
            ),
            const SizedBox(height: 24),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Available tags',
                      _availableTags.length.toString(),
                      Icons.label,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'Selected tags',
                      _selectedTags.length.toString(),
                      Icons.check_circle,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'Hierarchical tags',
                      _selectedTags.where((t) => t.contains('/')).length.toString(),
                      Icons.folder,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Available tags reference
            Text(
              'Available Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return Chip(
                      label: Text(tag),
                      avatar: Icon(
                        tag.contains('/') ? Icons.folder : Icons.label,
                        size: 16,
                      ),
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selected tags JSON
            if (_selectedTags.isNotEmpty) ...[
              Text(
                'Selected Tags (JSON)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    '[\n${_selectedTags.map((t) => '  "$t"').join(',\n')}\n]',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// Main function to run the demo
void main() {
  runApp(const MaterialApp(
    title: 'Tag Input Demo',
    home: TagInputDemo(),
  ));
}
