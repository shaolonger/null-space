# TagInputWidget Documentation

## Overview

The `TagInputWidget` is a reusable Flutter widget that provides tag input functionality with autocomplete suggestions. It's designed for the Null Space note-taking application to manage tags efficiently.

## Features

- ✅ Text input field with autocomplete dropdown
- ✅ Hierarchical tag suggestions (work/project/urgent)
- ✅ Display selected tags as removable chips
- ✅ Support for creating new tags
- ✅ Keyboard navigation and submission (Enter key)
- ✅ Smart autocomplete filtering and sorting
- ✅ Duplicate prevention
- ✅ Whitespace trimming
- ✅ Hierarchical tag detection (folder icon vs label icon)

## Usage

### Basic Usage

```dart
import 'package:null_space_app/widgets/tag_input_widget.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<String> _selectedTags = [];
  final List<String> _availableTags = ['work', 'personal', 'urgent'];

  @override
  Widget build(BuildContext context) {
    return TagInputWidget(
      availableTags: _availableTags,
      selectedTags: _selectedTags,
      onTagsChanged: (newTags) {
        setState(() {
          _selectedTags = newTags;
        });
      },
    );
  }
}
```

### With Provider Integration

```dart
import 'package:provider/provider.dart';
import 'package:null_space_app/widgets/tag_input_widget.dart';
import 'package:null_space_app/providers/note_provider.dart';

Widget build(BuildContext context) {
  final noteProvider = context.watch<NoteProvider>();
  
  return TagInputWidget(
    availableTags: noteProvider.allTags,
    selectedTags: _currentNoteTags,
    onTagsChanged: (newTags) {
      setState(() {
        _currentNoteTags = newTags;
      });
    },
  );
}
```

### Advanced Usage with Custom Configuration

```dart
TagInputWidget(
  availableTags: _availableTags,
  selectedTags: _selectedTags,
  onTagsChanged: (newTags) {
    setState(() {
      _selectedTags = newTags;
    });
  },
  hintText: 'Type to add tags...',
  maxSuggestions: 10,
  allowNewTags: true,
)
```

## API Reference

### Constructor Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `availableTags` | `List<String>` | ✓ | - | List of all available tags for autocomplete |
| `selectedTags` | `List<String>` | ✓ | - | Currently selected tags |
| `onTagsChanged` | `Function(List<String>)` | ✓ | - | Callback when tags are added or removed |
| `hintText` | `String?` | ✗ | "Add tag (e.g., work/project)" | Placeholder text for input field |
| `maxSuggestions` | `int` | ✗ | 5 | Maximum number of suggestions to show |
| `allowNewTags` | `bool` | ✗ | true | Whether to allow creating new tags |

### Callbacks

#### onTagsChanged(List<String> newTags)

Called whenever tags are added or removed. The callback receives the complete updated list of selected tags.

```dart
onTagsChanged: (newTags) {
  print('Tags updated: $newTags');
  // Update your state
}
```

## Tag Format

### Flat Tags
Simple tags without hierarchy:
- `work`
- `urgent`
- `personal`

### Hierarchical Tags
Tags organized in a hierarchy using forward slashes (`/`):
- `work/project-a`
- `work/project-a/urgent`
- `personal/finance/budget`

The widget automatically detects hierarchical tags and displays a folder icon (📁) instead of a label icon (🏷️) in the autocomplete suggestions.

## Autocomplete Behavior

### Filtering Logic

The autocomplete dropdown filters available tags based on:
1. **Contains match**: Tag contains the input text (case-insensitive)
2. **Not already selected**: Tags already selected are excluded
3. **Sorted by relevance**:
   - Exact matches first
   - Starts-with matches second
   - Contains matches last
   - Alphabetical within each category

### Example

Available tags: `['work', 'work/project', 'urgent/work', 'personal']`

Input: `"work"`

Suggestions (in order):
1. `work` (exact match)
2. `work/project` (starts with)
3. `urgent/work` (contains)

### Selection Behavior

Users can select tags in multiple ways:
1. **Click on suggestion**: Select from dropdown
2. **Press Enter**: 
   - If suggestions exist: Select first suggestion
   - If no suggestions and `allowNewTags` is true: Create new tag
3. **Click add button**: Same as pressing Enter

## Tag Management

### Adding Tags

1. Type in the input field
2. Autocomplete suggestions appear
3. Select from dropdown or press Enter
4. Tag is added and input is cleared
5. Focus returns to input field

### Removing Tags

Each tag chip has a delete button (X icon). Click it to remove the tag.

### Duplicate Prevention

The widget automatically prevents duplicate tags:
- Already selected tags don't appear in suggestions
- Attempting to add an existing tag is silently ignored

### Whitespace Handling

All tags are automatically trimmed:
- Input: `"  work  "` → Added as: `"work"`
- Empty or whitespace-only inputs are ignored

## Styling

The widget uses Material Design components and respects the app's theme:

- **TextField**: Standard Material TextField with outline border
- **Chips**: Material Chip with delete icon
- **Dropdown**: Material elevated card with rounded corners
- **Icons**: Material icons (folder, label, add, close)

### Customization

To customize the appearance, wrap the widget or modify your app's theme:

```dart
Theme(
  data: Theme.of(context).copyWith(
    chipTheme: ChipThemeData(
      backgroundColor: Colors.blue[100],
      deleteIconColor: Colors.red,
    ),
  ),
  child: TagInputWidget(...),
)
```

## Integration with Note Editor

Replace the basic tag input in `note_editor_screen.dart`:

### Before
```dart
Row(
  children: [
    Expanded(
      child: TextField(
        controller: _tagController,
        decoration: const InputDecoration(
          hintText: 'Add tag (e.g., work/project)',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: _addTag,
      ),
    ),
    const SizedBox(width: 8),
    ElevatedButton(
      onPressed: () => _addTag(_tagController.text),
      child: const Text('Add'),
    ),
  ],
),
const SizedBox(height: 8),
if (_tags.isNotEmpty)
  Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _tags.map((tag) {
      return Chip(
        label: Text(tag),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () => _removeTag(tag),
      );
    }).toList(),
  ),
```

### After
```dart
Consumer<NoteProvider>(
  builder: (context, noteProvider, _) {
    return TagInputWidget(
      availableTags: noteProvider.allTags,
      selectedTags: _tags,
      onTagsChanged: (newTags) {
        setState(() {
          _tags = newTags;
          _hasUnsavedChanges = true;
        });
      },
    );
  },
),
```

## Testing

### Running Tests

```bash
cd ui/null_space_app
flutter test test/widgets/tag_input_widget_test.dart
```

### Test Coverage

The widget includes comprehensive tests covering:
- Empty state rendering
- Tag display as chips
- Tag removal functionality
- Tag addition (via submit and button)
- Autocomplete filtering
- Duplicate prevention
- Whitespace trimming
- Hierarchical tag support
- Custom configuration options
- Multiple tag operations

### Example Test

```dart
testWidgets('adds new tag on submit', (WidgetTester tester) async {
  List<String> tags = [];
  
  await tester.pumpWidget(createWidget(
    allowNewTags: true,
    onTagsChanged: (newTags) {
      tags = newTags;
    },
  ));

  await tester.enterText(find.byType(TextField), 'newtag');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  expect(tags, contains('newtag'));
});
```

## Demo Application

Run the standalone demo to see the widget in action:

```bash
cd ui/null_space_app
flutter run lib/widgets/tag_input_demo.dart
```

The demo showcases:
- Autocomplete functionality
- Tag selection and removal
- Hierarchical tag support
- Available tags display
- Real-time statistics
- JSON output of selected tags

## Performance Considerations

### Efficiency

- **Autocomplete**: Filters and sorts in O(n log n) where n = available tags
- **Overlay**: Created on-demand, disposed when hidden
- **State updates**: Minimal rebuilds using local state
- **Memory**: O(n) for available tags + O(m) for selected tags

### Optimization Tips

1. **Limit suggestions**: Use `maxSuggestions` to cap dropdown size
2. **Debounce input**: For large tag lists, consider debouncing text input
3. **Virtual scrolling**: Autocomplete dropdown uses ListView for efficient rendering

### Recommended Limits

- Available tags: Up to 1,000 tags perform well
- Max suggestions: 5-10 for optimal UX
- Selected tags: No practical limit (renders as wrapped chips)

## Accessibility

### Keyboard Navigation

- **Tab**: Focus input field
- **Type**: Enter text and see suggestions
- **Enter**: Select first suggestion or create new tag
- **Escape**: Clear input (browser default)

### Screen Readers

The TextField includes proper semantic hints for accessibility. Chips announce deletion action, and autocomplete items are focusable.

### Touch Targets

All interactive elements meet minimum touch target size (48x48 logical pixels):
- Add button: IconButton with standard size
- Chip delete buttons: Standard Material chip delete
- Autocomplete items: ListTile with dense: true

## Troubleshooting

### Autocomplete not showing

**Problem**: Dropdown doesn't appear when typing

**Solutions**:
- Ensure `availableTags` is not empty
- Verify input matches at least one tag
- Check that matching tags aren't already selected

### Tags not saving

**Problem**: Tags disappear after adding

**Solutions**:
- Ensure `onTagsChanged` callback updates state properly
- Use `setState()` in StatefulWidget
- Check that parent widget rebuilds with new tags

### Overlay position incorrect

**Problem**: Dropdown appears in wrong location

**Solutions**:
- Ensure widget has proper layout constraints
- Verify parent isn't using transforms or complex layouts
- Widget should not be inside scrolling containers without proper handling

## Best Practices

### State Management

✅ **Do**: Use local state in parent widget
```dart
List<String> _tags = [];
onTagsChanged: (newTags) {
  setState(() {
    _tags = newTags;
  });
}
```

❌ **Don't**: Mutate selectedTags directly
```dart
// Wrong - creates binding issues
selectedTags.add('newtag');
```

### Available Tags

✅ **Do**: Provide comprehensive tag list
```dart
final allTags = noteProvider.allTags; // All tags in vault
```

❌ **Don't**: Use only current note's tags
```dart
// Wrong - limits autocomplete usefulness
final allTags = currentNote.tags;
```

### Creating New Tags

✅ **Do**: Allow new tags for flexibility
```dart
allowNewTags: true, // Users can create tags
```

❌ **Don't**: Restrict unless required
```dart
// Only use when tag list must be controlled
allowNewTags: false,
```

## Version History

### v1.0.0 (Current)
- Initial implementation
- Basic autocomplete functionality
- Hierarchical tag support
- Comprehensive tests
- Demo application
- Full documentation

## Related Components

- **TagFilterWidget**: Filter notes by tags
- **NoteProvider**: Manages note state and tags
- **Note Model**: Contains tags array

## Contributing

When modifying the widget:
1. Update tests for new functionality
2. Update this documentation
3. Run all tests: `flutter test`
4. Update demo if needed
5. Self-review code before committing

## License

Part of the Null Space application. See LICENSE file in repository root.
