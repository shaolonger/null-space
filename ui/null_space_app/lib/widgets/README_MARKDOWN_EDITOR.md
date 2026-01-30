# Markdown Editor Widget

A comprehensive Markdown editor widget with live preview for Flutter applications.

## Features

- **Three View Modes**:
  - **Edit Mode**: Full-screen text editor
  - **Preview Mode**: Full-screen rendered Markdown preview
  - **Split Mode**: Side-by-side editor and preview

- **Rich Toolbar**:
  - Bold (Ctrl+B)
  - Italic (Ctrl+I)
  - Headers (H1-H6)
  - Bullet list
  - Numbered list
  - Link (Ctrl+K)
  - Code block
  - Quote

- **Keyboard Shortcuts**:
  - `Ctrl+B` / `Cmd+B`: Bold
  - `Ctrl+I` / `Cmd+I`: Italic
  - `Ctrl+K` / `Cmd+K`: Insert link

- **Smart Text Wrapping**: When text is selected, formatting buttons wrap the selection instead of inserting placeholders

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:null_space_app/widgets/markdown_editor.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Markdown Editor')),
      body: MarkdownEditor(
        controller: _controller,
        onChanged: (value) {
          print('Content changed: $value');
        },
      ),
    );
  }
}
```

### Advanced Usage

```dart
MarkdownEditor(
  controller: _controller,
  initialMode: MarkdownViewMode.split,  // Start in split view
  showToolbar: true,                     // Show formatting toolbar
  showModeToggle: true,                  // Show mode toggle buttons
  maxLines: null,                        // Unlimited lines
  hintText: 'Write your note...',        // Custom hint text
  enabled: true,                         // Enable/disable editor
  onChanged: (value) {
    // Handle text changes
  },
)
```

### With Custom FocusNode

```dart
class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownEditor(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (value) {
        // Handle changes
      },
    );
  }
}
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController` | required | Controller for the text editor |
| `onChanged` | `ValueChanged<String>?` | null | Callback when text changes |
| `initialMode` | `MarkdownViewMode` | `MarkdownViewMode.edit` | Initial view mode |
| `showToolbar` | `bool` | `true` | Whether to show the formatting toolbar |
| `showModeToggle` | `bool` | `true` | Whether to show view mode toggle buttons |
| `maxLines` | `int?` | `null` | Maximum lines in editor (null for unlimited) |
| `hintText` | `String?` | `'Write your note in Markdown...'` | Hint text for empty editor |
| `enabled` | `bool` | `true` | Whether the editor is enabled |
| `focusNode` | `FocusNode?` | `null` | Custom focus node (auto-created if null) |

## View Modes

### Edit Mode (`MarkdownViewMode.edit`)
Shows only the text editor. Best for focused writing.

### Preview Mode (`MarkdownViewMode.preview`)
Shows only the rendered Markdown. Best for reviewing content.

### Split Mode (`MarkdownViewMode.split`)
Shows both editor and preview side-by-side. Best for live editing with instant feedback.

## Toolbar Actions

### Text Formatting
- **Bold**: Wraps text in `**text**`
- **Italic**: Wraps text in `*text*`

### Headers
Menu with options for H1-H6:
- H1: `# `
- H2: `## `
- H3: `### `
- And so on...

### Lists
- **Bullet List**: Inserts `- `
- **Numbered List**: Inserts `1. `

### Links and Code
- **Link**: Wraps text in `[text](url)`
- **Code Block**: Wraps text in ` ```\ntext\n``` `
- **Quote**: Inserts `> `

## Keyboard Shortcuts

The editor supports common Markdown keyboard shortcuts:

- **Ctrl+B** (Cmd+B on Mac): Bold the selected text
- **Ctrl+I** (Cmd+I on Mac): Italicize the selected text
- **Ctrl+K** (Cmd+K on Mac): Insert a link

## Implementation Details

### Smart Text Insertion

When a formatting button is clicked:
1. If text is selected, it wraps the selection
2. If no text is selected, it inserts a placeholder
3. The cursor is positioned for convenient continuation

### Preview Rendering

The preview uses `flutter_markdown` package to render Markdown with:
- Syntax highlighting for code blocks
- Proper heading hierarchy
- List formatting
- Link detection
- And all standard Markdown features

### Responsive Layout

- In Edit and Preview modes, the content takes full width
- In Split mode, the editor and preview share equal width
- The toolbar scrolls horizontally on narrow screens

## Testing

The widget includes comprehensive tests covering:
- View mode switching
- Toolbar actions
- Text insertion and wrapping
- Keyboard shortcuts
- Edge cases and error handling

Run tests with:
```bash
flutter test test/widgets/markdown_editor_test.dart
```

## Integration with Note Editor

To integrate with the existing `NoteEditorScreen`, replace the current `TextFormField` with the `MarkdownEditor` widget:

```dart
// Instead of:
TextFormField(
  controller: _contentController,
  decoration: const InputDecoration(...),
  maxLines: 15,
)

// Use:
MarkdownEditor(
  controller: _contentController,
  hintText: 'Write your note in Markdown...',
  onChanged: (value) {
    // Handle changes if needed
  },
)
```

## Dependencies

The widget requires:
- `flutter_markdown` for rendering Markdown preview
- Flutter SDK 3.0 or higher

## License

MIT License - Part of the Null Space project
