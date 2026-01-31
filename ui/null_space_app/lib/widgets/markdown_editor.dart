import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// View mode for the Markdown Editor
enum MarkdownViewMode {
  /// Edit mode - only show text editor
  edit,
  
  /// Preview mode - only show rendered markdown
  preview,
  
  /// Split mode - show both editor and preview side by side
  split,
}

/// A comprehensive Markdown editor widget with live preview
/// 
/// Features:
/// - Three view modes: Edit, Preview, and Split view
/// - Markdown toolbar with common formatting actions
/// - Keyboard shortcuts (Ctrl+B for bold, Ctrl+I for italic, etc.)
/// - Live preview using flutter_markdown
/// - Customizable toolbar actions
class MarkdownEditor extends StatefulWidget {
  /// Controller for the text editor
  final TextEditingController controller;
  
  /// Callback when the text content changes
  final ValueChanged<String>? onChanged;
  
  /// Initial view mode (default: edit)
  final MarkdownViewMode initialMode;
  
  /// Whether to show the toolbar (default: true)
  final bool showToolbar;
  
  /// Whether to show the view mode toggle buttons (default: true)
  final bool showModeToggle;
  
  /// Maximum number of lines in edit mode (default: null for unlimited)
  final int? maxLines;
  
  /// Hint text for the editor
  final String? hintText;
  
  /// Whether the editor is enabled (default: true)
  final bool enabled;
  
  /// Focus node for the text editor
  final FocusNode? focusNode;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.onChanged,
    this.initialMode = MarkdownViewMode.edit,
    this.showToolbar = true,
    this.showModeToggle = true,
    this.maxLines,
    this.hintText,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late MarkdownViewMode _currentMode;
  late FocusNode _internalFocusNode;
  
  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _internalFocusNode = widget.focusNode ?? FocusNode();
    // Listen to controller changes to update preview
    widget.controller.addListener(_onControllerChanged);
  }
  
  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update focus node if it changed
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode.dispose();
      }
      _internalFocusNode = widget.focusNode ?? FocusNode();
    }
    // Update controller listener if it changed
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }
  
  /// Handle controller text changes
  void _onControllerChanged() {
    // Rebuild to update preview
    if (mounted) {
      setState(() {});
    }
  }
  
  /// Toggle between view modes
  void _setMode(MarkdownViewMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }
  
  /// Insert markdown syntax at cursor position
  void _insertMarkdown(String before, String after, {String? placeholder}) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    // Validate selection
    if (!selection.isValid || selection.start < 0 || selection.end > text.length) {
      return;
    }
    
    String selectedText = '';
    if (selection.start != selection.end) {
      selectedText = text.substring(selection.start, selection.end);
    } else if (placeholder != null) {
      selectedText = placeholder;
    }
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$selectedText$after',
    );
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + before.length + selectedText.length,
      ),
    );
    
    _internalFocusNode.requestFocus();
    widget.onChanged?.call(newText);
  }
  
  /// Insert text at cursor position
  void _insertText(String text, {int cursorOffset = 0}) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    
    // Validate selection
    if (!selection.isValid || selection.start < 0 || selection.end > currentText.length) {
      return;
    }
    
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length + cursorOffset,
      ),
    );
    
    _internalFocusNode.requestFocus();
    widget.onChanged?.call(newText);
  }
  
  /// Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    
    // Don't handle shortcuts if editor is disabled
    if (!widget.enabled) return KeyEventResult.ignored;
    
    final isControlPressed = HardwareKeyboard.instance.isControlPressed || 
                            HardwareKeyboard.instance.isMetaPressed;
    
    if (!isControlPressed) return KeyEventResult.ignored;
    
    if (event.logicalKey == LogicalKeyboardKey.keyB) {
      _insertMarkdown('**', '**', placeholder: 'bold text');
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
      _insertMarkdown('*', '*', placeholder: 'italic text');
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyK) {
      _insertMarkdown('[', '](url)', placeholder: 'link text');
      return KeyEventResult.handled;
    }
    
    return KeyEventResult.ignored;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // View mode toggle and toolbar
        if (widget.showModeToggle || widget.showToolbar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                // View mode toggle
                if (widget.showModeToggle) ...[
                  SegmentedButton<MarkdownViewMode>(
                    segments: const [
                      ButtonSegment(
                        value: MarkdownViewMode.edit,
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Edit'),
                      ),
                      ButtonSegment(
                        value: MarkdownViewMode.preview,
                        icon: Icon(Icons.visibility, size: 18),
                        label: Text('Preview'),
                      ),
                      ButtonSegment(
                        value: MarkdownViewMode.split,
                        icon: Icon(Icons.vertical_split, size: 18),
                        label: Text('Split'),
                      ),
                    ],
                    selected: {_currentMode},
                    onSelectionChanged: (Set<MarkdownViewMode> newSelection) {
                      _setMode(newSelection.first);
                    },
                  ),
                  const SizedBox(width: 16),
                ],
                
                // Toolbar
                if (widget.showToolbar && _currentMode != MarkdownViewMode.preview)
                  Expanded(
                    child: _buildToolbar(),
                  ),
              ],
            ),
          ),
        
        // Editor and preview area
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }
  
  Widget _buildToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Bold
          IconButton(
            icon: const Icon(Icons.format_bold),
            tooltip: 'Bold (Ctrl+B)',
            iconSize: 20,
            onPressed: widget.enabled 
                ? () => _insertMarkdown('**', '**', placeholder: 'bold text')
                : null,
          ),
          
          // Italic
          IconButton(
            icon: const Icon(Icons.format_italic),
            tooltip: 'Italic (Ctrl+I)',
            iconSize: 20,
            onPressed: widget.enabled
                ? () => _insertMarkdown('*', '*', placeholder: 'italic text')
                : null,
          ),
          
          const VerticalDivider(),
          
          // Headers
          PopupMenuButton<String>(
            icon: const Icon(Icons.title),
            tooltip: 'Heading',
            iconSize: 20,
            enabled: widget.enabled,
            onSelected: (String value) {
              _insertText('$value ', cursorOffset: 0);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: '#', child: Text('Heading 1')),
              const PopupMenuItem(value: '##', child: Text('Heading 2')),
              const PopupMenuItem(value: '###', child: Text('Heading 3')),
              const PopupMenuItem(value: '####', child: Text('Heading 4')),
              const PopupMenuItem(value: '#####', child: Text('Heading 5')),
              const PopupMenuItem(value: '######', child: Text('Heading 6')),
            ],
          ),
          
          const VerticalDivider(),
          
          // Bullet list
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: 'Bullet List',
            iconSize: 20,
            onPressed: widget.enabled
                ? () => _insertText('- ', cursorOffset: 0)
                : null,
          ),
          
          // Numbered list
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            tooltip: 'Numbered List',
            iconSize: 20,
            onPressed: widget.enabled
                ? () => _insertText('1. ', cursorOffset: 0)
                : null,
          ),
          
          const VerticalDivider(),
          
          // Link
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Link (Ctrl+K)',
            iconSize: 20,
            onPressed: widget.enabled
                ? () => _insertMarkdown('[', '](url)', placeholder: 'link text')
                : null,
          ),
          
          // Code block
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Code Block',
            iconSize: 20,
            onPressed: widget.enabled
                ? () => _insertMarkdown('```\n', '\n```', placeholder: 'code')
                : null,
          ),
          
          // Quote
          IconButton(
            icon: const Icon(Icons.format_quote),
            tooltip: 'Quote',
            iconSize: 20,
            onPressed: widget.enabled
                ? () => _insertText('> ', cursorOffset: 0)
                : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    switch (_currentMode) {
      case MarkdownViewMode.edit:
        return _buildEditor();
      case MarkdownViewMode.preview:
        return _buildPreview();
      case MarkdownViewMode.split:
        return _buildSplitView();
    }
  }
  
  Widget _buildEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Focus(
        focusNode: _internalFocusNode,
        onKeyEvent: _handleKeyEvent,
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Write your note in Markdown...',
            border: InputBorder.none,
          ),
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: widget.controller.text.isEmpty
          ? Center(
              child: Text(
                'No content to preview',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : Markdown(
              data: widget.controller.text,
              selectable: true,
            ),
    );
  }
  
  Widget _buildSplitView() {
    return Row(
      children: [
        // Editor pane
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: _buildEditor(),
          ),
        ),
        
        // Preview pane
        Expanded(
          child: _buildPreview(),
        ),
      ],
    );
  }
}
