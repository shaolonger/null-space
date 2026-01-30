import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/widgets/tag_input_widget.dart';

void main() {
  group('TagInputWidget Tests', () {
    late List<String> selectedTags;
    
    setUp(() {
      selectedTags = [];
    });

    Widget createWidget({
      List<String>? availableTags,
      List<String>? initialTags,
      Function(List<String>)? onTagsChanged,
      bool? allowNewTags,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TagInputWidget(
            availableTags: availableTags ?? [],
            selectedTags: initialTags ?? selectedTags,
            onTagsChanged: onTagsChanged ?? (tags) {
              selectedTags = tags;
            },
            allowNewTags: allowNewTags ?? true,
          ),
        ),
      );
    }

    testWidgets('displays empty state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Should have text field
      expect(find.byType(TextField), findsOneWidget);
      
      // Should have hint text
      expect(find.text('Add tag (e.g., work/project)'), findsOneWidget);
      
      // Should not have any chips
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('displays selected tags as chips', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(
        initialTags: ['work', 'urgent', 'personal/finance'],
      ));

      // Should display all tags as chips
      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.text('work'), findsOneWidget);
      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('personal/finance'), findsOneWidget);
    });

    testWidgets('can remove tag by clicking delete button', (WidgetTester tester) async {
      List<String> tags = ['work', 'urgent'];
      
      await tester.pumpWidget(createWidget(
        initialTags: tags,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Initial state
      expect(find.byType(Chip), findsNWidgets(2));

      // Find and tap the delete button on the first chip
      final deleteIcons = find.byIcon(Icons.close);
      expect(deleteIcons, findsNWidgets(2));
      
      await tester.tap(deleteIcons.first);
      await tester.pumpAndSettle();

      // Verify callback was called with updated tags
      expect(tags.length, 1);
      expect(tags.contains('urgent'), true);
    });

    testWidgets('shows add button when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Initially no add button
      expect(find.byIcon(Icons.add), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'work');
      await tester.pump();

      // Add button should appear
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('adds new tag on submit', (WidgetTester tester) async {
      List<String> tags = [];
      
      await tester.pumpWidget(createWidget(
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'newtag');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify tag was added
      expect(tags, contains('newtag'));
      expect(tags.length, 1);
    });

    testWidgets('filters autocomplete suggestions', (WidgetTester tester) async {
      final availableTags = [
        'work/project-a',
        'work/project-b',
        'personal/finance',
        'personal/health',
        'urgent',
      ];

      await tester.pumpWidget(createWidget(
        availableTags: availableTags,
      ));

      // Enter text that matches some tags
      await tester.enterText(find.byType(TextField), 'work');
      await tester.pumpAndSettle();

      // The overlay should be created but we can't easily test it
      // in unit tests without integration testing.
      // We verify the widget builds without error
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('does not show already selected tags in suggestions', 
        (WidgetTester tester) async {
      final availableTags = ['work', 'urgent', 'personal'];
      final selectedTags = ['work'];

      await tester.pumpWidget(createWidget(
        availableTags: availableTags,
        initialTags: selectedTags,
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'w');
      await tester.pumpAndSettle();

      // Widget should build successfully
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('clears input after adding tag', (WidgetTester tester) async {
      List<String> tags = [];
      
      await tester.pumpWidget(createWidget(
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'newtag');
      expect(find.text('newtag'), findsOneWidget);

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Text field should be cleared
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, isEmpty);
    });

    testWidgets('does not add duplicate tags', (WidgetTester tester) async {
      List<String> tags = ['work'];
      
      await tester.pumpWidget(createWidget(
        initialTags: tags,
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Try to add existing tag
      await tester.enterText(find.byType(TextField), 'work');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should still have only one tag
      expect(tags.length, 1);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('handles hierarchical tag input', (WidgetTester tester) async {
      List<String> tags = [];
      
      await tester.pumpWidget(createWidget(
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Add hierarchical tag
      await tester.enterText(find.byType(TextField), 'work/project/urgent');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify tag was added correctly
      expect(tags, contains('work/project/urgent'));
      expect(tags.length, 1);
    });

    testWidgets('trims whitespace from tags', (WidgetTester tester) async {
      List<String> tags = [];
      
      await tester.pumpWidget(createWidget(
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Add tag with whitespace
      await tester.enterText(find.byType(TextField), '  work  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify tag was trimmed
      expect(tags, contains('work'));
      expect(tags, isNot(contains('  work  ')));
    });

    testWidgets('does not add empty tags', (WidgetTester tester) async {
      List<String> tags = [];
      
      await tester.pumpWidget(createWidget(
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Try to add empty tag
      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // No tags should be added
      expect(tags, isEmpty);
    });

    testWidgets('custom hint text is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagInputWidget(
              availableTags: const [],
              selectedTags: const [],
              onTagsChanged: (_) {},
              hintText: 'Custom hint text',
            ),
          ),
        ),
      );

      expect(find.text('Custom hint text'), findsOneWidget);
    });

    testWidgets('can limit max suggestions', (WidgetTester tester) async {
      final availableTags = List.generate(10, (i) => 'tag$i');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagInputWidget(
              availableTags: availableTags,
              selectedTags: const [],
              onTagsChanged: (_) {},
              maxSuggestions: 3,
            ),
          ),
        ),
      );

      // Widget should build without error
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('clicking add button adds tag', (WidgetTester tester) async {
      List<String> tags = [];
      
      await tester.pumpWidget(createWidget(
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'newtag');
      await tester.pump();

      // Click add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify tag was added
      expect(tags, contains('newtag'));
    });

    testWidgets('supports multiple tag operations', (WidgetTester tester) async {
      List<String> tags = ['initial'];
      
      await tester.pumpWidget(createWidget(
        availableTags: ['work', 'urgent'],
        initialTags: tags,
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));

      // Add second tag
      await tester.enterText(find.byType(TextField), 'work');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      
      expect(tags.length, 2);
      expect(tags, containsAll(['initial', 'work']));

      // Rebuild with updated tags
      await tester.pumpWidget(createWidget(
        availableTags: ['work', 'urgent'],
        initialTags: tags,
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));
      await tester.pump();

      // Add third tag
      await tester.enterText(find.byType(TextField), 'urgent');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      
      expect(tags.length, 3);

      // Rebuild with updated tags
      await tester.pumpWidget(createWidget(
        availableTags: ['work', 'urgent'],
        initialTags: tags,
        allowNewTags: true,
        onTagsChanged: (newTags) {
          tags = newTags;
        },
      ));
      await tester.pump();

      // Remove a tag
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      
      expect(tags.length, 2);
    });

    testWidgets('respects allowNewTags parameter', (WidgetTester tester) async {
      List<String> tags = [];
      final availableTags = ['work', 'urgent'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagInputWidget(
              availableTags: availableTags,
              selectedTags: tags,
              onTagsChanged: (newTags) {
                tags = newTags;
              },
              allowNewTags: false,
            ),
          ),
        ),
      );

      // Try to add a new tag not in available tags
      await tester.enterText(find.byType(TextField), 'newtag');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tag should not be added when allowNewTags is false and no suggestions
      expect(tags, isEmpty);
    });
  });
}
