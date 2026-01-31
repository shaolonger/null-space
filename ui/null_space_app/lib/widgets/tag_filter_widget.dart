import 'package:flutter/material.dart';

/// A hierarchical tag structure node for the tree view
class TagNode {
  final String name;
  final String fullPath;
  final List<TagNode> children;
  int noteCount;
  bool isSelected;

  TagNode({
    required this.name,
    required this.fullPath,
    List<TagNode>? children,
    this.noteCount = 0,
    this.isSelected = false,
  }) : children = children ?? [];
}

/// Tag filter widget with hierarchical tag display and multi-select filtering
class TagFilterWidget extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final Map<String, int>? tagCounts;
  final ScrollController? scrollController;

  const TagFilterWidget({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagsChanged,
    this.tagCounts,
    this.scrollController,
  });

  @override
  State<TagFilterWidget> createState() => _TagFilterWidgetState();
}

class _TagFilterWidgetState extends State<TagFilterWidget> {
  late List<String> _selectedTags;
  List<TagNode> _tagTree = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
    _buildTagTree();
  }

  @override
  void didUpdateWidget(TagFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allTags != widget.allTags ||
        oldWidget.selectedTags != widget.selectedTags ||
        oldWidget.tagCounts != widget.tagCounts) {
      _selectedTags = List.from(widget.selectedTags);
      _buildTagTree();
    }
  }

  void _buildTagTree() {
    final Map<String, TagNode> nodeMap = {};

    // Build nodes for all tags
    for (final tag in widget.allTags) {
      final parts = tag.split('/');
      String currentPath = '';

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        final parentPath = currentPath;
        currentPath = currentPath.isEmpty ? part : '$currentPath/$part';

        if (!nodeMap.containsKey(currentPath)) {
          final node = TagNode(
            name: part,
            fullPath: currentPath,
            children: [],
            noteCount: widget.tagCounts?[currentPath] ?? 0,
            isSelected: _selectedTags.contains(currentPath),
          );
          nodeMap[currentPath] = node;

          // Add to parent's children
          if (parentPath.isNotEmpty && nodeMap.containsKey(parentPath)) {
            final parent = nodeMap[parentPath]!;
            if (!parent.children.any((c) => c.fullPath == currentPath)) {
              parent.children.add(node);
            }
          }
        } else {
          // Update existing node
          nodeMap[currentPath]!.noteCount =
              widget.tagCounts?[currentPath] ?? nodeMap[currentPath]!.noteCount;
          nodeMap[currentPath]!.isSelected = _selectedTags.contains(currentPath);
        }
      }
    }

    // Build root level tags (no parent)
    _tagTree = nodeMap.values
        .where((node) => !node.fullPath.contains('/'))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Sort children recursively
    _sortChildren(_tagTree);
  }

  void _sortChildren(List<TagNode> nodes) {
    for (final node in nodes) {
      node.children.sort((a, b) => a.name.compareTo(b.name));
      _sortChildren(node.children);
    }
  }

  void _toggleTag(TagNode node) {
    setState(() {
      if (node.isSelected) {
        // Deselect this tag and all its children
        _deselectTagAndChildren(node);
      } else {
        // Select this tag and all its children
        _selectTagAndChildren(node);
      }
      widget.onTagsChanged(_selectedTags);
    });
  }

  void _selectTagAndChildren(TagNode node) {
    if (!_selectedTags.contains(node.fullPath)) {
      _selectedTags.add(node.fullPath);
    }
    node.isSelected = true;

    for (final child in node.children) {
      _selectTagAndChildren(child);
    }
  }

  void _deselectTagAndChildren(TagNode node) {
    _selectedTags.remove(node.fullPath);
    node.isSelected = false;

    for (final child in node.children) {
      _deselectTagAndChildren(child);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTags.clear();
      _buildTagTree();
      widget.onTagsChanged(_selectedTags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.allTags.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No tags available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedTags.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
        // Selected tags count
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_selectedTags.length} tag${_selectedTags.length == 1 ? '' : 's'} selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Tag tree
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: _tagTree.map((node) => _buildTagItem(node, 0)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagItem(TagNode node, int depth) {
    final theme = Theme.of(context);
    final isSelected = node.isSelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleTag(node),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0 * depth + 8,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              children: [
                // Selection indicator
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                // Expand/collapse indicator for parent tags
                if (node.children.isNotEmpty)
                  Icon(
                    Icons.folder,
                    size: 18,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  )
                else
                  Icon(
                    Icons.label,
                    size: 18,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                const SizedBox(width: 8),
                // Tag name
                Expanded(
                  child: Text(
                    node.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                // Note count badge
                if (node.noteCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${node.noteCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Children tags
        ...node.children.map((child) => _buildTagItem(child, depth + 1)),
      ],
    );
  }
}
