import 'package:flutter/material.dart';
import 'package:null_space_app/widgets/markdown_editor.dart';

/// Demo screen showing the MarkdownEditor widget in action
/// 
/// This demonstrates:
/// - Basic usage of MarkdownEditor
/// - Integration in a full screen
/// - Saving/loading content
class MarkdownEditorDemo extends StatefulWidget {
  const MarkdownEditorDemo({super.key});

  @override
  State<MarkdownEditorDemo> createState() => _MarkdownEditorDemoState();
}

class _MarkdownEditorDemoState extends State<MarkdownEditorDemo> {
  final TextEditingController _controller = TextEditingController();
  String _savedContent = '';

  @override
  void initState() {
    super.initState();
    // Initialize with sample content
    _controller.text = '''# Welcome to Markdown Editor

This is a demo of the **Markdown Editor** widget.

## Features

- **Bold** and *italic* text
- Headers (H1-H6)
- Lists (bullet and numbered)
- [Links](https://example.com)
- Code blocks
- And more!

## Try it out

1. Click the toolbar buttons to format text
2. Use keyboard shortcuts (Ctrl+B for bold, Ctrl+I for italic)
3. Switch between Edit, Preview, and Split views
4. Type your own content

> This is a quote block

```dart
// This is a code block
void main() {
  print('Hello, Markdown!');
}
```

Enjoy writing in Markdown! ✨
''';
    _savedContent = _controller.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveContent() {
    setState(() {
      _savedContent = _controller.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetContent() {
    setState(() {
      _controller.text = _savedContent;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content reset to last saved version'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Content'),
        content: const Text('Are you sure you want to clear all content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = _controller.text != _savedContent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Editor Demo'),
        actions: [
          // Clear button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
            onPressed: _clearContent,
          ),
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: hasChanges ? _resetContent : null,
          ),
          // Save button
          IconButton(
            icon: Icon(
              hasChanges ? Icons.save : Icons.check_circle,
              color: hasChanges ? null : Colors.green,
            ),
            tooltip: hasChanges ? 'Save' : 'Saved',
            onPressed: hasChanges ? _saveContent : null,
          ),
        ],
      ),
      body: MarkdownEditor(
        controller: _controller,
        initialMode: MarkdownViewMode.split,
        onChanged: (value) {
          // Trigger rebuild to update hasChanges indicator
          setState(() {});
        },
      ),
    );
  }
}
