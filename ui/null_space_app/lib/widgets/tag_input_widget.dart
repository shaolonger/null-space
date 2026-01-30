import 'package:flutter/material.dart';

/// A widget for inputting tags with autocomplete suggestions
/// 
/// Features:
/// - Text input field with autocomplete dropdown
/// - Hierarchical tag suggestions (work/project)
/// - Display selected tags as removable chips
/// - Support for creating new tags
/// - Keyboard navigation and submission
class TagInputWidget extends StatefulWidget {
  /// List of all available tags for autocomplete
  final List<String> availableTags;
  
  /// Currently selected tags
  final List<String> selectedTags;
  
  /// Callback when tags are changed (add/remove)
  final Function(List<String>) onTagsChanged;
  
  /// Placeholder text for the input field
  final String? hintText;
  
  /// Maximum number of suggestions to show
  final int maxSuggestions;
  
  /// Whether to allow creating new tags
  final bool allowNewTags;

  const TagInputWidget({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagsChanged,
    this.hintText,
    this.maxSuggestions = 5,
    this.allowNewTags = true,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle text input changes to update suggestions
  void _onTextChanged() {
    final text = _controller.text.trim();
    
    if (text.isEmpty) {
      _hideSuggestions();
      return;
    }

    _updateSuggestions(text);
  }

  /// Handle focus changes
  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _hideSuggestions();
    }
  }

  /// Update suggestion list based on input text
  void _updateSuggestions(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Filter available tags that match the query and aren't already selected
    final matches = widget.availableTags
        .where((tag) =>
            tag.toLowerCase().contains(lowerQuery) &&
            !widget.selectedTags.contains(tag))
        .toList();

    // Sort by relevance (exact match > starts with > contains)
    matches.sort((a, b) {
      final aLower = a.toLowerCase();
      final bLower = b.toLowerCase();
      
      if (aLower == lowerQuery) return -1;
      if (bLower == lowerQuery) return 1;
      
      if (aLower.startsWith(lowerQuery) && !bLower.startsWith(lowerQuery)) {
        return -1;
      }
      if (bLower.startsWith(lowerQuery) && !aLower.startsWith(lowerQuery)) {
        return 1;
      }
      
      return a.compareTo(b);
    });

    setState(() {
      _suggestions = matches.take(widget.maxSuggestions).toList();
      _showSuggestions = _suggestions.isNotEmpty;
    });

    if (_showSuggestions) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  /// Show the autocomplete overlay
  void _showOverlay() {
    _removeOverlay();

    // Ensure widget is laid out before showing overlay
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: renderBox.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final tag = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _isHierarchicalTag(tag) ? Icons.folder : Icons.label,
                      size: 20,
                    ),
                    title: Text(
                      tag,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () => _selectTag(tag),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Remove the autocomplete overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Hide suggestions
  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _removeOverlay();
  }

  /// Check if a tag is hierarchical (contains /)
  bool _isHierarchicalTag(String tag) {
    return tag.contains('/');
  }

  /// Select a tag from suggestions
  void _selectTag(String tag) {
    _addTag(tag);
    _controller.clear();
    _hideSuggestions();
    _focusNode.requestFocus();
  }

  /// Add a new tag
  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    
    if (trimmedTag.isEmpty) return;
    if (widget.selectedTags.contains(trimmedTag)) return;

    final newTags = List<String>.from(widget.selectedTags)..add(trimmedTag);
    widget.onTagsChanged(newTags);
  }

  /// Remove a tag
  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.selectedTags)..remove(tag);
    widget.onTagsChanged(newTags);
  }

  /// Handle submit (Enter key)
  void _handleSubmit() {
    final text = _controller.text.trim();
    
    if (text.isEmpty) return;

    // If there are suggestions and user hasn't selected one, use the first suggestion
    if (_suggestions.isNotEmpty) {
      _selectTag(_suggestions.first);
      return;
    }

    // Create new tag if allowed
    if (widget.allowNewTags) {
      _addTag(text);
      _controller.clear();
      _hideSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tag input field with autocomplete
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Add tag (e.g., work/project)',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: _handleSubmit,
                      tooltip: 'Add tag',
                    )
                  : null,
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
        ),
        
        // Selected tags as chips
        if (widget.selectedTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
