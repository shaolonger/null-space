import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/widgets/markdown_editor.dart';

void main() {
  group('MarkdownEditor Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createEditor({
      MarkdownViewMode? initialMode,
      bool? showToolbar,
      bool? showModeToggle,
      int? maxLines,
      String? hintText,
      bool? enabled,
      ValueChanged<String>? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MarkdownEditor(
            controller: controller,
            initialMode: initialMode ?? MarkdownViewMode.edit,
            showToolbar: showToolbar ?? true,
            showModeToggle: showModeToggle ?? true,
            maxLines: maxLines,
            hintText: hintText,
            enabled: enabled ?? true,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('displays all view mode toggle buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Split'), findsOneWidget);
    });

    testWidgets('displays toolbar buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Check for formatting buttons
      expect(find.byIcon(Icons.format_bold), findsOneWidget);
      expect(find.byIcon(Icons.format_italic), findsOneWidget);
      expect(find.byIcon(Icons.title), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);
      expect(find.byIcon(Icons.format_list_numbered), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('starts in edit mode by default', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Should show text field in edit mode
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('can start in different view modes', (WidgetTester tester) async {
      // Test preview mode
      await tester.pumpWidget(createEditor(initialMode: MarkdownViewMode.preview));
      expect(find.text('No content to preview'), findsOneWidget);

      // Test split mode
      await tester.pumpWidget(createEditor(initialMode: MarkdownViewMode.split));
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('No content to preview'), findsOneWidget);
    });

    testWidgets('switches between view modes', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());
      controller.text = '# Test';
      await tester.pump();

      // Start in edit mode
      expect(find.byType(TextField), findsOneWidget);

      // Switch to preview mode
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      // Should not show text field, should show markdown preview
      expect(find.byType(TextField), findsNothing);

      // Switch to split mode
      await tester.tap(find.text('Split'));
      await tester.pumpAndSettle();

      // Should show both text field and preview
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('bold button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap bold button
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Should insert bold syntax with placeholder
      expect(controller.text, '**bold text**');
    });

    testWidgets('bold button wraps selected text', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Set text and select part of it
      controller.text = 'Hello World';
      controller.selection = const TextSelection(start: 0, end: 5);
      await tester.pump();

      // Tap bold button
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Should wrap selected text in bold syntax
      expect(controller.text, '**Hello** World');
    });

    testWidgets('italic button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap italic button
      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      // Should insert italic syntax with placeholder
      expect(controller.text, '*italic text*');
    });

    testWidgets('italic button wraps selected text', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Set text and select part of it
      controller.text = 'Hello World';
      controller.selection = const TextSelection(start: 6, end: 11);
      await tester.pump();

      // Tap italic button
      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      // Should wrap selected text in italic syntax
      expect(controller.text, 'Hello *World*');
    });

    testWidgets('header button shows menu with options', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap header button
      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();

      // Should show all header levels
      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
      expect(find.text('Heading 3'), findsOneWidget);
      expect(find.text('Heading 4'), findsOneWidget);
      expect(find.text('Heading 5'), findsOneWidget);
      expect(find.text('Heading 6'), findsOneWidget);
    });

    testWidgets('selecting header inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap header button
      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();

      // Select Heading 2
      await tester.tap(find.text('Heading 2'));
      await tester.pump();

      // Should insert ## with space
      expect(controller.text, '## ');
    });

    testWidgets('bullet list button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap bullet list button
      await tester.tap(find.byIcon(Icons.format_list_bulleted));
      await tester.pump();

      // Should insert bullet list syntax
      expect(controller.text, '- ');
    });

    testWidgets('numbered list button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap numbered list button
      await tester.tap(find.byIcon(Icons.format_list_numbered));
      await tester.pump();

      // Should insert numbered list syntax
      expect(controller.text, '1. ');
    });

    testWidgets('link button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap link button
      await tester.tap(find.byIcon(Icons.link));
      await tester.pump();

      // Should insert link syntax with placeholder
      expect(controller.text, '[link text](url)');
    });

    testWidgets('link button wraps selected text', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Set text and select part of it
      controller.text = 'Click here';
      controller.selection = const TextSelection(start: 0, end: 10);
      await tester.pump();

      // Tap link button
      await tester.tap(find.byIcon(Icons.link));
      await tester.pump();

      // Should wrap selected text in link syntax
      expect(controller.text, '[Click here](url)');
    });

    testWidgets('code block button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap code button
      await tester.tap(find.byIcon(Icons.code));
      await tester.pump();

      // Should insert code block syntax
      expect(controller.text, '```\ncode\n```');
    });

    testWidgets('quote button inserts markdown syntax', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Tap quote button
      await tester.tap(find.byIcon(Icons.format_quote));
      await tester.pump();

      // Should insert quote syntax
      expect(controller.text, '> ');
    });

    testWidgets('can hide toolbar', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(showToolbar: false));

      // Should not show toolbar buttons
      expect(find.byIcon(Icons.format_bold), findsNothing);
      expect(find.byIcon(Icons.format_italic), findsNothing);
    });

    testWidgets('can hide mode toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(showModeToggle: false));

      // Should not show mode toggle buttons
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Preview'), findsNothing);
      expect(find.text('Split'), findsNothing);
    });

    testWidgets('toolbar hidden in preview mode', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(initialMode: MarkdownViewMode.preview));

      // Toolbar should not be visible when in preview-only mode
      // (buttons are present but in the Edit widget which is not shown)
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      // Since we're in preview mode, the toolbar row should still be there
      // but the formatting buttons section should not be shown
      expect(find.byIcon(Icons.format_bold), findsNothing);
    });

    testWidgets('respects enabled property', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(enabled: false));

      // Text field should be disabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);

      // Toolbar buttons should be disabled (tap should not work)
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Text should not change since button is disabled
      expect(controller.text, '');
    });

    testWidgets('displays custom hint text', (WidgetTester tester) async {
      const customHint = 'Custom hint text';
      await tester.pumpWidget(createEditor(hintText: customHint));

      expect(find.text(customHint), findsOneWidget);
    });

    testWidgets('calls onChanged callback', (WidgetTester tester) async {
      String? changedValue;
      await tester.pumpWidget(
        createEditor(
          onChanged: (value) {
            changedValue = value;
          },
        ),
      );

      // Tap bold button
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Callback should be called with new value
      expect(changedValue, '**bold text**');
    });

    testWidgets('preview shows empty state when no content', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(initialMode: MarkdownViewMode.preview));

      expect(find.text('No content to preview'), findsOneWidget);
    });

    testWidgets('preview renders markdown content', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(initialMode: MarkdownViewMode.preview));

      controller.text = '# Hello World\n\nThis is a test.';
      await tester.pump();

      // Switch to preview if not already
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      // Should not show empty state
      expect(find.text('No content to preview'), findsNothing);
    });

    testWidgets('split view shows both editor and preview', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor(initialMode: MarkdownViewMode.split));

      controller.text = '# Test';
      await tester.pump();

      // Should show both text field and preview content
      expect(find.byType(TextField), findsOneWidget);
      // Preview area exists (either with content or empty state)
    });

    testWidgets('handles multiple toolbar actions in sequence', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Insert bullet list
      await tester.tap(find.byIcon(Icons.format_list_bulleted));
      await tester.pump();
      expect(controller.text, '- ');

      // Set cursor at end and insert bold text
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, '- **bold text**');
    });

    testWidgets('maintains cursor position after toolbar action', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Insert bold text
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Cursor should be positioned after "**bold text"
      expect(controller.selection.baseOffset, 11); // After "**bold text"
    });

    testWidgets('toolbar buttons update text when tapped multiple times', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // First bold
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();
      expect(controller.text, '**bold text**');

      // Set cursor at end
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      await tester.pump();

      // Second bold
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();
      expect(controller.text, '**bold text****bold text**');
    });

    testWidgets('heading menu closes after selection', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Open header menu
      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();

      // Select a heading
      await tester.tap(find.text('Heading 1'));
      await tester.pumpAndSettle();

      // Menu should be closed
      expect(find.text('Heading 1'), findsNothing);
    });

    testWidgets('editor accepts text input from user', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Enter text in the editor
      await tester.enterText(find.byType(TextField), 'User typed text');
      await tester.pump();

      expect(controller.text, 'User typed text');
    });

    testWidgets('combines user input with toolbar actions', (WidgetTester tester) async {
      await tester.pumpWidget(createEditor());

      // Type some text
      await tester.enterText(find.byType(TextField), 'Hello ');
      await tester.pump();

      // Set cursor at end
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      await tester.pump();

      // Add bold text
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, 'Hello **bold text**');
    });
  });
}
