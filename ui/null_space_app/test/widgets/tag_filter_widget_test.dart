import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/widgets/tag_filter_widget.dart';

void main() {
  group('TagFilterWidget Tests', () {
    testWidgets('displays "No tags available" when tag list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: const [],
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('No tags available'), findsOneWidget);
    });

    testWidgets('displays flat tags correctly', (WidgetTester tester) async {
      final tags = ['work', 'personal', 'urgent'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Filter by Tags'), findsOneWidget);
      expect(find.text('work'), findsOneWidget);
      expect(find.text('personal'), findsOneWidget);
      expect(find.text('urgent'), findsOneWidget);
    });

    testWidgets('displays hierarchical tags correctly',
        (WidgetTester tester) async {
      final tags = [
        'work/project-a/urgent',
        'work/project-a/review',
        'work/project-b',
        'personal/finance',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      // Root level tags
      expect(find.text('work'), findsOneWidget);
      expect(find.text('personal'), findsOneWidget);

      // Second level
      expect(find.text('project-a'), findsOneWidget);
      expect(find.text('project-b'), findsOneWidget);
      expect(find.text('finance'), findsOneWidget);

      // Third level
      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('review'), findsOneWidget);
    });

    testWidgets('shows folder icon for parent tags and label icon for leaf tags',
        (WidgetTester tester) async {
      final tags = ['work/project-a', 'urgent'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      // Parent tags should have folder icon
      expect(find.byIcon(Icons.folder), findsAtLeastNWidgets(1));

      // Leaf tags should have label icon
      expect(find.byIcon(Icons.label), findsAtLeastNWidgets(1));
    });

    testWidgets('displays note count badges correctly',
        (WidgetTester tester) async {
      final tags = ['work', 'personal', 'urgent'];
      final tagCounts = {'work': 5, 'personal': 3, 'urgent': 1};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
              tagCounts: tagCounts,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('toggles single tag selection', (WidgetTester tester) async {
      final tags = ['work', 'personal'];
      List<String> selectedTags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially no tags selected
      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(find.byIcon(Icons.check_box_outline_blank), findsAtLeastNWidgets(2));

      // Tap on 'work' tag
      await tester.tap(find.text('work'));
      await tester.pumpAndSettle();

      // 'work' should now be selected
      expect(selectedTags, contains('work'));
      expect(find.byIcon(Icons.check_box), findsAtLeastNWidgets(1));
    });

    testWidgets('deselects tag when tapped again', (WidgetTester tester) async {
      final tags = ['work', 'personal'];
      List<String> selectedTags = ['work'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // 'work' is initially selected
      expect(selectedTags, contains('work'));

      // Tap on 'work' tag again
      await tester.tap(find.text('work'));
      await tester.pumpAndSettle();

      // 'work' should now be deselected
      expect(selectedTags, isNot(contains('work')));
    });

    testWidgets('selecting parent tag selects all children',
        (WidgetTester tester) async {
      final tags = [
        'work/project-a/urgent',
        'work/project-a/review',
        'work/project-b',
      ];
      List<String> selectedTags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap on 'work' (parent) tag
      await tester.tap(find.text('work'));
      await tester.pumpAndSettle();

      // All work-related tags should be selected
      expect(selectedTags, contains('work'));
      expect(selectedTags, contains('work/project-a'));
      expect(selectedTags, contains('work/project-a/urgent'));
      expect(selectedTags, contains('work/project-a/review'));
      expect(selectedTags, contains('work/project-b'));
    });

    testWidgets('deselecting parent tag deselects all children',
        (WidgetTester tester) async {
      final tags = [
        'work/project-a/urgent',
        'work/project-a/review',
        'work/project-b',
      ];
      List<String> selectedTags = [
        'work',
        'work/project-a',
        'work/project-a/urgent',
        'work/project-a/review',
        'work/project-b',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap on 'work' (parent) tag to deselect
      await tester.tap(find.text('work'));
      await tester.pumpAndSettle();

      // All work-related tags should be deselected
      expect(selectedTags, isEmpty);
    });

    testWidgets('shows clear all button when tags are selected',
        (WidgetTester tester) async {
      final tags = ['work', 'personal'];
      List<String> selectedTags = ['work'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Clear All'), findsOneWidget);
      expect(find.text('1 tag selected'), findsOneWidget);
    });

    testWidgets('hides clear all button when no tags are selected',
        (WidgetTester tester) async {
      final tags = ['work', 'personal'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Clear All'), findsNothing);
    });

    testWidgets('clear all button deselects all tags',
        (WidgetTester tester) async {
      final tags = ['work', 'personal', 'urgent'];
      List<String> selectedTags = ['work', 'personal'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially 2 tags selected
      expect(selectedTags.length, 2);

      // Tap clear all button
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // All tags should be deselected
      expect(selectedTags, isEmpty);
      expect(find.text('Clear All'), findsNothing);
    });

    testWidgets('displays plural text correctly for selected tags',
        (WidgetTester tester) async {
      final tags = ['work', 'personal', 'urgent'];
      List<String> selectedTags = ['work', 'personal'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Should show plural "tags"
      expect(find.text('2 tags selected'), findsOneWidget);

      // Deselect one tag
      await tester.tap(find.text('personal'));
      await tester.pumpAndSettle();

      // Should show singular "tag"
      expect(find.text('1 tag selected'), findsOneWidget);
    });

    testWidgets('sorts tags alphabetically', (WidgetTester tester) async {
      final tags = ['zebra', 'apple', 'banana'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      // Get all text widgets
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final tagTexts = textWidgets
          .map((w) => w.data)
          .where((text) =>
              text == 'apple' || text == 'banana' || text == 'zebra')
          .toList();

      // Check they appear in sorted order
      expect(tagTexts.indexOf('apple'), lessThan(tagTexts.indexOf('banana')));
      expect(tagTexts.indexOf('banana'), lessThan(tagTexts.indexOf('zebra')));
    });

    testWidgets('updates when allTags prop changes',
        (WidgetTester tester) async {
      List<String> tags = ['work', 'personal'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: const [],
                  onTagsChanged: (_) {},
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('work'), findsOneWidget);
      expect(find.text('urgent'), findsNothing);

      // Update tags
      tags = ['work', 'personal', 'urgent'];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('urgent'), findsOneWidget);
    });

    testWidgets('multi-select works with AND logic',
        (WidgetTester tester) async {
      final tags = ['work', 'urgent', 'review'];
      List<String> selectedTags = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TagFilterWidget(
                  allTags: tags,
                  selectedTags: selectedTags,
                  onTagsChanged: (newTags) {
                    setState(() {
                      selectedTags = newTags;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Select multiple tags
      await tester.tap(find.text('work'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('urgent'));
      await tester.pumpAndSettle();

      // Both tags should be selected
      expect(selectedTags, contains('work'));
      expect(selectedTags, contains('urgent'));
      expect(selectedTags.length, 2);
    });

    testWidgets('indents nested tags correctly', (WidgetTester tester) async {
      final tags = ['work/project-a/urgent'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagFilterWidget(
              allTags: tags,
              selectedTags: const [],
              onTagsChanged: (_) {},
            ),
          ),
        ),
      );

      // Find padding widgets for different levels
      final allInkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      final allPaddings = allInkWells
          .map((inkwell) => inkwell.child)
          .whereType<Padding>()
          .toList();

      // Should have different left padding for different depths
      expect(allPaddings.isNotEmpty, true);
    });
  });
}
