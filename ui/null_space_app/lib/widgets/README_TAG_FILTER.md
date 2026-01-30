# Tag Filter Widget

A comprehensive hierarchical tag filter widget for the Null Space note-taking application.

## Overview

The `TagFilterWidget` provides a powerful, hierarchical tag filtering system that allows users to filter notes by multiple tags with AND logic. Tags are displayed in a tree structure, making it easy to navigate and select from complex tag hierarchies.

## Features

### Core Functionality
- **Hierarchical Display**: Tags are displayed in a tree structure (e.g., `work/project-a/urgent`)
- **Multi-Select Filtering**: Multiple tags can be selected simultaneously (AND logic)
- **Parent-Child Selection**: Selecting a parent tag automatically selects all its children
- **Note Count Badges**: Each tag displays the number of notes associated with it
- **Clear All Filters**: Quick button to deselect all tags
- **Alphabetical Sorting**: Tags are sorted alphabetically at each level

### UI Components
- **Folder Icons**: Parent tags (with children) display a folder icon
- **Label Icons**: Leaf tags (no children) display a label icon
- **Selection Indicators**: Checkboxes show selected/unselected state
- **Visual Feedback**: Selected tags are highlighted with primary color
- **Scroll Support**: Integrates with `DraggableScrollableSheet` for smooth scrolling

## Usage

### Basic Implementation

```dart
import 'package:null_space_app/widgets/tag_filter_widget.dart';

TagFilterWidget(
  allTags: ['work', 'personal', 'urgent'],
  selectedTags: [],
  onTagsChanged: (tags) {
    // Handle tag selection changes
    print('Selected tags: $tags');
  },
  tagCounts: {
    'work': 5,
    'personal': 3,
    'urgent': 2,
  },
)
```

### Integration with Modal Bottom Sheet

```dart
void _showTagFilter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => TagFilterWidget(
        allTags: allTags,
        selectedTags: selectedTags,
        onTagsChanged: (tags) {
          // Update your state
        },
        tagCounts: tagCounts,
        scrollController: scrollController, // Important for draggable behavior
      ),
    ),
  );
}
```

### Integration with Provider

```dart
Consumer<NoteProvider>(
  builder: (context, provider, child) => TagFilterWidget(
    allTags: provider.allTags,
    selectedTags: provider.selectedTags,
    onTagsChanged: (tags) {
      provider.setSelectedTags(tags);
    },
    tagCounts: provider.tagCounts,
  ),
)
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `allTags` | `List<String>` | Yes | List of all available tags in the system |
| `selectedTags` | `List<String>` | Yes | List of currently selected tags |
| `onTagsChanged` | `Function(List<String>)` | Yes | Callback when tag selection changes |
| `tagCounts` | `Map<String, int>?` | No | Map of tag to note count for displaying badges |
| `scrollController` | `ScrollController?` | No | Scroll controller for integration with draggable sheets |

## Tag Format

Tags should use forward slash (`/`) as a separator for hierarchical structure:

```dart
final tags = [
  'work',                      // Root level
  'work/project-a',            // Second level
  'work/project-a/urgent',     // Third level
  'work/project-a/review',     // Third level
  'work/project-b',            // Second level
  'personal',                  // Root level
  'personal/finance',          // Second level
];
```

## Selection Behavior

### AND Logic
When multiple tags are selected, only notes that have **all** selected tags are shown:
- Select `work` + `urgent` → shows notes with both tags
- Not: notes with `work` OR `urgent`

### Parent-Child Relationship
- **Selecting a parent**: Automatically selects all descendant tags
  - Select `work` → also selects `work/project-a`, `work/project-a/urgent`, etc.
- **Deselecting a parent**: Automatically deselects all descendant tags
  - Deselect `work` → also deselects all `work/*` tags

## Integration with NoteProvider

The `NoteProvider` has been enhanced to support tag filtering:

```dart
class NoteProvider extends ChangeNotifier {
  // Get all unique tags from notes
  List<String> get allTags { ... }
  
  // Get note counts per tag
  Map<String, int> get tagCounts { ... }
  
  // Current selected tags
  List<String> get selectedTags => _selectedTags;
  
  // Update selected tags
  void setSelectedTags(List<String> tags) { ... }
  
  // Clear all filters
  void clearFilters() { ... }
}
```

## Testing

Comprehensive tests are available in `test/widgets/tag_filter_widget_test.dart`:

```bash
flutter test test/widgets/tag_filter_widget_test.dart
```

Test coverage includes:
- Display of hierarchical tags
- Selection and deselection
- Parent-child relationships
- Note count badges
- Clear all functionality
- Widget updates
- Edge cases

## Demo

A demo screen is available at `lib/widgets/tag_filter_demo.dart` that showcases the widget with sample data:

```dart
import 'package:null_space_app/widgets/tag_filter_demo.dart';

// Show the demo
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => TagFilterDemo()),
);
```

## Accessibility

The widget includes:
- Proper semantic labels for icons
- Tooltip text for buttons
- High contrast between selected/unselected states
- Keyboard navigation support (through Flutter's default behavior)

## Performance

- **Efficient Tree Building**: Tags are parsed and structured only when needed
- **Minimal Rebuilds**: Uses proper state management to minimize widget rebuilds
- **Lazy Loading**: Children are only displayed when parent is visible

## Customization

While the widget uses the app's theme by default, you can customize it by:
1. Using theme-based colors (`colorScheme`)
2. Adjusting padding/spacing in the source code
3. Modifying icon choices

## Future Enhancements

Possible future improvements:
- Expand/collapse functionality for parent tags
- Search/filter within tags
- Drag-and-drop tag reordering
- Tag color coding
- Tag usage analytics

## Credits

Implemented as part of Task 4.3 in the Null Space development plan.
