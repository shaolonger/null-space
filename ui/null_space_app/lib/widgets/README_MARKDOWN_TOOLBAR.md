# Markdown Toolbar Widget

A reusable, standalone Markdown formatting toolbar widget for Flutter applications. Provides common Markdown formatting buttons that insert syntax at the cursor position or wrap selected text.

## Features

- **Standalone Widget**: Can be used independently with any `TextEditingController`
- **All Common Markdown Formats**: Bold, Italic, Headers (H1-H6), Lists, Links, Code, Quotes
- **Smart Text Insertion**: Wraps selected text or inserts placeholder text
- **Keyboard Shortcuts**: Ctrl+B (Bold), Ctrl+I (Italic), Ctrl+K (Link)
- **Proper Cursor Management**: Cursor position updates correctly after insertions
- **Enabled/Disabled State**: Full support for disabled state
- **Customizable**: Icon size, dividers, and focus node can be configured
- **Convenience Widget**: `MarkdownToolbarField` combines toolbar with TextField

## Widgets

### MarkdownToolbar

The core toolbar widget that provides formatting buttons.

### MarkdownToolbarField

A convenience widget that combines a `MarkdownToolbar` with a `TextField` and automatically handles keyboard shortcuts.

## Quick Start

### Basic Usage with MarkdownToolbar

```dart
import 'package:null_space_app/widgets/markdown_toolbar.dart';

class MyEditor extends StatefulWidget {
  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MarkdownToolbar(
          controller: _controller,
          onChanged: () {
            print('Content: ${_controller.text}');
          },
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
```

### Using MarkdownToolbarField

```dart
import 'package:null_space_app/widgets/markdown_toolbar.dart';

class SimpleEditor extends StatefulWidget {
  @override
  State<SimpleEditor> createState() => _SimpleEditorState();
}

class _SimpleEditorState extends State<SimpleEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownToolbarField(
      controller: _controller,
      hintText: 'Write your markdown here...',
      maxLines: 10,
      onChanged: (value) {
        print('Content changed: $value');
      },
    );
  }
}
```

## Property Reference

### MarkdownToolbar Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController` | required | Controller for the text editor |
| `onChanged` | `VoidCallback?` | `null` | Callback when text content changes |
| `enabled` | `bool` | `true` | Whether the toolbar is enabled |
| `focusNode` | `FocusNode?` | `null` | Optional focus node for keyboard shortcuts |
| `iconSize` | `double` | `20` | Icon size for toolbar buttons |
| `showDividers` | `bool` | `true` | Whether to show dividers between button groups |

### MarkdownToolbarField Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController` | required | Controller for the text editor |
| `onChanged` | `ValueChanged<String>?` | `null` | Callback when text content changes |
| `enabled` | `bool` | `true` | Whether the editor is enabled |
| `maxLines` | `int?` | `null` | Maximum number of lines (null = unlimited) |
| `hintText` | `String?` | `null` | Hint text for the editor |
| `decoration` | `InputDecoration?` | `null` | Custom decoration for the text field |
| `toolbarIconSize` | `double` | `20` | Icon size for toolbar buttons |
| `showToolbarDividers` | `bool` | `true` | Whether to show dividers in toolbar |

## Toolbar Buttons

| Button | Icon | Action | Markdown Syntax | Keyboard Shortcut |
|--------|------|--------|-----------------|-------------------|
| Bold | `format_bold` | Wrap selection with `**` | `**text**` | Ctrl+B |
| Italic | `format_italic` | Wrap selection with `*` | `*text*` | Ctrl+I |
| H1-H6 | `title` | Insert `#` at cursor | `# text` | - |
| Bullet List | `format_list_bulleted` | Insert `- ` at cursor | `- text` | - |
| Numbered List | `format_list_numbered` | Insert `1. ` at cursor | `1. text` | - |
| Link | `link` | Wrap selection | `[text](url)` | Ctrl+K |
| Code | `code` | Wrap with code block | `` ```\ncode\n``` `` | - |
| Quote | `format_quote` | Insert `> ` at cursor | `> text` | - |

## Usage Examples

### Example 1: Custom Icon Size and No Dividers

```dart
MarkdownToolbar(
  controller: _controller,
  iconSize: 24,
  showDividers: false,
  onChanged: () {
    _saveContent();
  },
)
```

### Example 2: With Focus Node for Keyboard Shortcuts

```dart
class MyEditor extends StatefulWidget {
  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MarkdownToolbar(
          controller: _controller,
          focusNode: _focusNode,
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
```

### Example 3: Disabled State

```dart
MarkdownToolbar(
  controller: _controller,
  enabled: false, // Toolbar buttons are disabled
)
```

### Example 4: Custom TextField Decoration

```dart
MarkdownToolbarField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Note Content',
    border: OutlineInputBorder(),
    hintText: 'Start typing...',
  ),
  maxLines: 20,
)
```

### Example 5: Integration with Form

```dart
class NoteForm extends StatefulWidget {
  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _hasChanges = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Save the content
      print('Saving: ${_controller.text}');
      setState(() => _hasChanges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: MarkdownToolbarField(
              controller: _controller,
              hintText: 'Write your note...',
              onChanged: (value) {
                setState(() => _hasChanges = true);
              },
            ),
          ),
          ElevatedButton(
            onPressed: _hasChanges ? _save : null,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

## How It Works

### Text Selection Handling

The toolbar smartly handles text in two ways:

1. **Selected Text**: If text is selected, it wraps the selection with the markdown syntax
   - Example: Select "bold" → Click Bold → `**bold**`

2. **No Selection**: If no text is selected, it inserts placeholder text
   - Example: Cursor at position → Click Bold → `**bold text**`

### Cursor Positioning

After insertion, the cursor is positioned:
- **For wrapping formats** (bold, italic, link, code): After the wrapped text
- **For prefix formats** (headers, lists, quotes): After the inserted prefix

Examples:
- Bold "test" → `**test**|` (cursor after second `**`)
- Insert H1 → `# |` (cursor after space)

### Keyboard Shortcuts

When using `MarkdownToolbarField`, keyboard shortcuts are automatically handled:
- **Ctrl+B** or **Cmd+B**: Bold
- **Ctrl+I** or **Cmd+I**: Italic
- **Ctrl+K** or **Cmd+K**: Link

For `MarkdownToolbar` alone, you need to implement keyboard handling separately using the `focusNode` property.

## Implementation Details

### Architecture

```
MarkdownToolbar (StatelessWidget)
├── Formatting methods
│   ├── _insertMarkdown() - Wraps selected text
│   └── _insertText() - Inserts at cursor
└── Toolbar buttons
    ├── Bold, Italic (wrap)
    ├── Headers (prefix)
    ├── Lists (prefix)
    ├── Link (wrap)
    ├── Code (wrap)
    └── Quote (prefix)

MarkdownToolbarField (StatefulWidget)
├── FocusNode management
├── Keyboard shortcut handling
├── MarkdownToolbar
└── TextField
```

### State Management

- `MarkdownToolbar` is stateless and operates directly on the `TextEditingController`
- `MarkdownToolbarField` is stateful to manage focus and keyboard events
- Changes are immediately reflected in the controller
- Optional `onChanged` callback for external state management

### Text Manipulation

The widget uses Flutter's `TextEditingValue` to ensure:
- Atomic text updates
- Proper selection management
- Undo/redo compatibility

Example from code:
```dart
controller.value = TextEditingValue(
  text: newText,
  selection: TextSelection.collapsed(offset: newPosition),
);
```

## Integration with Existing Editors

### Replace Existing TextField

```dart
// Before
TextField(
  controller: _controller,
  maxLines: null,
)

// After
MarkdownToolbarField(
  controller: _controller,
)
```

### Add Toolbar to Existing Editor

```dart
Column(
  children: [
    // Add toolbar above existing editor
    MarkdownToolbar(
      controller: _existingController,
    ),
    // Keep existing editor
    Expanded(
      child: YourExistingEditor(
        controller: _existingController,
      ),
    ),
  ],
)
```

## Testing

The widget includes comprehensive tests covering:
- All toolbar button actions
- Text wrapping vs placeholder insertion
- Cursor position updates
- Keyboard shortcuts
- Enabled/disabled states
- Multiple sequential actions
- Edge cases (empty text, cursor at end, etc.)

Run tests with:
```bash
cd ui/null_space_app
flutter test test/widgets/markdown_toolbar_test.dart
```

## Best Practices

1. **Always dispose the controller**:
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

2. **Use MarkdownToolbarField for simple cases**: It handles keyboard shortcuts automatically

3. **Use MarkdownToolbar + custom editor for complex cases**: More control over layout and behavior

4. **Provide feedback on changes**: Use the `onChanged` callback to update UI state

5. **Consider disabled state**: Disable toolbar when content is read-only or loading

## Comparison with MarkdownEditor

The `MarkdownEditor` widget (from Task 5.1) is a comprehensive editor with:
- View modes (Edit, Preview, Split)
- Integrated toolbar
- Live Markdown preview
- All-in-one solution

The `MarkdownToolbar` widget is:
- Standalone toolbar component
- Can be used with any text editor
- More flexible and reusable
- Lighter weight (no preview rendering)

**When to use which:**
- Use `MarkdownEditor` when you need a complete editing solution with preview
- Use `MarkdownToolbar` when you want to add Markdown formatting to existing editors
- Use `MarkdownToolbarField` when you need a simple Markdown editor without preview

## Dependencies

- `flutter/material.dart` - UI components
- `flutter/services.dart` - Keyboard event handling

No external dependencies required!

## Browser/Platform Support

Works on all Flutter-supported platforms:
- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Accessibility

- All buttons have tooltips
- Keyboard shortcuts for common actions
- Respects system text scaling
- Compatible with screen readers
- Focus management for keyboard navigation

## License

Part of the Null Space note-taking application.

## See Also

- [MarkdownEditor Widget](README_MARKDOWN_EDITOR.md) - Full editor with preview
- [Flutter Markdown](https://pub.dev/packages/flutter_markdown) - Markdown rendering
- [Markdown Guide](https://www.markdownguide.org/) - Markdown syntax reference
