import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable Markdown formatting toolbar widget
/// 
/// Provides common Markdown formatting buttons that insert syntax at the
/// cursor position or wrap selected text. Can be used independently or
/// integrated with any text editor that uses a TextEditingController.
/// 
/// Features:
/// - Bold, Italic formatting with keyboard shortcuts (Ctrl+B, Ctrl+I)
/// - Headers (H1-H6) via dropdown menu
/// - Lists (bullet and numbered)
/// - Links with Ctrl+K shortcut
/// - Code blocks
/// - Quotes
/// - Smart text insertion (wraps selection or adds placeholder)
/// - Proper cursor positioning after insertion
/// - Enabled/disabled state support
/// - Optional focus node for keyboard shortcut integration
class MarkdownToolbar extends StatelessWidget {
  /// Controller for the text editor
  final TextEditingController controller;
  
  /// Callback when the text content changes
  final VoidCallback? onChanged;
  
  /// Whether the toolbar is enabled (default: true)
  final bool enabled;
  
  /// Optional focus node for keyboard shortcut handling
  /// If provided, keyboard shortcuts will be registered with this focus node
  final FocusNode? focusNode;
  
  /// Icon size for toolbar buttons (default: 20)
  final double iconSize;
  
  /// Whether to show dividers between button groups (default: true)
  final bool showDividers;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.iconSize = 20,
    this.showDividers = true,
  });

  /// Insert markdown syntax around the current selection or at cursor position
  void _insertMarkdown(String before, String after, {String? placeholder}) {
    final text = controller.text;
    final selection = controller.selection;
    
    // Validate selection
    if (!selection.isValid || selection.start < 0 || selection.end > text.length) {
      return;
    }
    
    String selectedText = '';
    if (selection.start != selection.end) {
      // Wrap selected text
      selectedText = text.substring(selection.start, selection.end);
    } else if (placeholder != null) {
      // Use placeholder if no selection
      selectedText = placeholder;
    }
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$before$selectedText$after',
    );
    
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + before.length + selectedText.length,
      ),
    );
    
    focusNode?.requestFocus();
    onChanged?.call();
  }
  
  /// Insert text at the current cursor position
  void _insertText(String text, {int cursorOffset = 0}) {
    final currentText = controller.text;
    final selection = controller.selection;
    
    // Validate selection
    if (!selection.isValid || selection.start < 0 || selection.end > currentText.length) {
      return;
    }
    
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length + cursorOffset,
      ),
    );
    
    focusNode?.requestFocus();
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Bold
          IconButton(
            icon: const Icon(Icons.format_bold),
            tooltip: 'Bold (Ctrl+B)',
            iconSize: iconSize,
            onPressed: enabled 
                ? () => _insertMarkdown('**', '**', placeholder: 'bold text')
                : null,
          ),
          
          // Italic
          IconButton(
            icon: const Icon(Icons.format_italic),
            tooltip: 'Italic (Ctrl+I)',
            iconSize: iconSize,
            onPressed: enabled
                ? () => _insertMarkdown('*', '*', placeholder: 'italic text')
                : null,
          ),
          
          if (showDividers) const VerticalDivider(),
          
          // Headers
          PopupMenuButton<String>(
            icon: const Icon(Icons.title),
            tooltip: 'Heading',
            iconSize: iconSize,
            enabled: enabled,
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
          
          if (showDividers) const VerticalDivider(),
          
          // Bullet list
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: 'Bullet List',
            iconSize: iconSize,
            onPressed: enabled
                ? () => _insertText('- ', cursorOffset: 0)
                : null,
          ),
          
          // Numbered list
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            tooltip: 'Numbered List',
            iconSize: iconSize,
            onPressed: enabled
                ? () => _insertText('1. ', cursorOffset: 0)
                : null,
          ),
          
          if (showDividers) const VerticalDivider(),
          
          // Link
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Link (Ctrl+K)',
            iconSize: iconSize,
            onPressed: enabled
                ? () => _insertMarkdown('[', '](url)', placeholder: 'link text')
                : null,
          ),
          
          // Code block
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Code Block',
            iconSize: iconSize,
            onPressed: enabled
                ? () => _insertMarkdown('```\n', '\n```', placeholder: 'code')
                : null,
          ),
          
          // Quote
          IconButton(
            icon: const Icon(Icons.format_quote),
            tooltip: 'Quote',
            iconSize: iconSize,
            onPressed: enabled
                ? () => _insertText('> ', cursorOffset: 0)
                : null,
          ),
        ],
      ),
    );
  }
}

/// Helper widget that wraps a TextField with MarkdownToolbar and keyboard shortcuts
/// 
/// This is a convenience widget that combines a MarkdownToolbar with a TextField
/// and automatically handles keyboard shortcuts (Ctrl+B, Ctrl+I, Ctrl+K).
/// 
/// Example:
/// ```dart
/// MarkdownToolbarField(
///   controller: _controller,
///   hintText: 'Write your markdown here...',
///   maxLines: 10,
///   onChanged: (value) => print('Content changed'),
/// )
/// ```
class MarkdownToolbarField extends StatefulWidget {
  /// Controller for the text editor
  final TextEditingController controller;
  
  /// Callback when the text content changes
  final ValueChanged<String>? onChanged;
  
  /// Whether the editor is enabled (default: true)
  final bool enabled;
  
  /// Maximum number of lines (default: null for unlimited)
  final int? maxLines;
  
  /// Hint text for the editor
  final String? hintText;
  
  /// Decoration for the text field
  final InputDecoration? decoration;
  
  /// Icon size for toolbar buttons (default: 20)
  final double toolbarIconSize;
  
  /// Whether to show dividers in toolbar (default: true)
  final bool showToolbarDividers;

  const MarkdownToolbarField({
    super.key,
    required this.controller,
    this.onChanged,
    this.enabled = true,
    this.maxLines,
    this.hintText,
    this.decoration,
    this.toolbarIconSize = 20,
    this.showToolbarDividers = true,
  });

  @override
  State<MarkdownToolbarField> createState() => _MarkdownToolbarFieldState();
}

class _MarkdownToolbarFieldState extends State<MarkdownToolbarField> {
  late FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
  
  void _insertMarkdown(String before, String after, {String? placeholder}) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
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
    
    _focusNode.requestFocus();
    widget.onChanged?.call(newText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
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
          child: MarkdownToolbar(
            controller: widget.controller,
            onChanged: () => widget.onChanged?.call(widget.controller.text),
            enabled: widget.enabled,
            focusNode: _focusNode,
            iconSize: widget.toolbarIconSize,
            showDividers: widget.showToolbarDividers,
          ),
        ),
        
        // Text field
        Expanded(
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: TextField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              decoration: widget.decoration ?? InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
