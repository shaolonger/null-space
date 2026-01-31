import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/widgets/markdown_toolbar.dart';

void main() {
  group('MarkdownToolbar', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders all toolbar buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      // Check for all buttons
      expect(find.byIcon(Icons.format_bold), findsOneWidget);
      expect(find.byIcon(Icons.format_italic), findsOneWidget);
      expect(find.byIcon(Icons.title), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);
      expect(find.byIcon(Icons.format_list_numbered), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('bold button wraps selected text', (WidgetTester tester) async {
      controller.text = 'Hello World';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, '**Hello** World');
      expect(controller.selection.baseOffset, 7);
      expect(controller.selection.extentOffset, 7);
    });

    testWidgets('bold button inserts placeholder when no selection', (WidgetTester tester) async {
      controller.text = 'Hello';
      controller.selection = const TextSelection.collapsed(offset: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, 'Hello**bold text**');
      expect(controller.selection.baseOffset, 16);
      expect(controller.selection.extentOffset, 16);
    });

    testWidgets('italic button wraps selected text', (WidgetTester tester) async {
      controller.text = 'Hello World';
      controller.selection = const TextSelection(baseOffset: 6, extentOffset: 11);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      expect(controller.text, 'Hello *World*');
      expect(controller.selection.baseOffset, 12);
      expect(controller.selection.extentOffset, 12);
    });

    testWidgets('italic button inserts placeholder when no selection', (WidgetTester tester) async {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      expect(controller.text, '*italic text*');
      expect(controller.selection.baseOffset, 12);
    });

    testWidgets('heading dropdown shows all heading options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();

      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
      expect(find.text('Heading 3'), findsOneWidget);
      expect(find.text('Heading 4'), findsOneWidget);
      expect(find.text('Heading 5'), findsOneWidget);
      expect(find.text('Heading 6'), findsOneWidget);
    });

    testWidgets('heading 1 inserts # at cursor', (WidgetTester tester) async {
      controller.text = 'Title';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heading 1'));
      await tester.pump();

      expect(controller.text, '# Title');
      expect(controller.selection.baseOffset, 2);
    });

    testWidgets('heading 2 inserts ## at cursor', (WidgetTester tester) async {
      controller.text = 'Subtitle';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heading 2'));
      await tester.pump();

      expect(controller.text, '## Subtitle');
      expect(controller.selection.baseOffset, 3);
    });

    testWidgets('bullet list button inserts - at cursor', (WidgetTester tester) async {
      controller.text = 'Item';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_list_bulleted));
      await tester.pump();

      expect(controller.text, '- Item');
      expect(controller.selection.baseOffset, 2);
    });

    testWidgets('numbered list button inserts 1. at cursor', (WidgetTester tester) async {
      controller.text = 'First';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_list_numbered));
      await tester.pump();

      expect(controller.text, '1. First');
      expect(controller.selection.baseOffset, 3);
    });

    testWidgets('link button wraps selected text', (WidgetTester tester) async {
      controller.text = 'Click here';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.link));
      await tester.pump();

      expect(controller.text, '[Click here](url)');
      expect(controller.selection.baseOffset, 11);
      expect(controller.selection.extentOffset, 11);
    });

    testWidgets('link button inserts placeholder when no selection', (WidgetTester tester) async {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.link));
      await tester.pump();

      expect(controller.text, '[link text](url)');
      expect(controller.selection.baseOffset, 10);
      expect(controller.selection.extentOffset, 10);
    });

    testWidgets('code button wraps selected text', (WidgetTester tester) async {
      controller.text = 'print("Hello")';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 14);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.code));
      await tester.pump();

      expect(controller.text, '```\nprint("Hello")\n```');
    });

    testWidgets('code button inserts placeholder when no selection', (WidgetTester tester) async {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.code));
      await tester.pump();

      expect(controller.text, '```\ncode\n```');
    });

    testWidgets('quote button inserts > at cursor', (WidgetTester tester) async {
      controller.text = 'Quote text';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_quote));
      await tester.pump();

      expect(controller.text, '> Quote text');
      expect(controller.selection.baseOffset, 2);
    });

    testWidgets('multiple actions can be performed in sequence', (WidgetTester tester) async {
      controller.text = 'Text';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      // Add heading
      await tester.tap(find.byIcon(Icons.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heading 1'));
      await tester.pump();

      expect(controller.text, '# Text');

      // Add bullet list at the end
      controller.selection = const TextSelection.collapsed(offset: 6);
      await tester.tap(find.byIcon(Icons.format_list_bulleted));
      await tester.pump();

      expect(controller.text, '# Text- ');
    });

    testWidgets('onChanged callback is called on button press', (WidgetTester tester) async {
      controller.text = 'Test';
      controller.selection = const TextSelection.collapsed(offset: 4);
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
              onChanged: () => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(callCount, 1);
    });

    testWidgets('disabled toolbar does not respond to taps', (WidgetTester tester) async {
      controller.text = 'Test';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      // Text should remain unchanged
      expect(controller.text, 'Test');
    });

    testWidgets('toolbar respects custom icon size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
              iconSize: 24,
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byIcon(Icons.format_bold).first);
      expect(iconButton.iconSize, 24);
    });

    testWidgets('toolbar can hide dividers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
              showDividers: false,
            ),
          ),
        ),
      );

      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('toolbar can show dividers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
              showDividers: true,
            ),
          ),
        ),
      );

      expect(find.byType(VerticalDivider), findsWidgets);
    });

    testWidgets('handles empty text correctly', (WidgetTester tester) async {
      controller.text = '';
      controller.selection = const TextSelection.collapsed(offset: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, '**bold text**');
    });

    testWidgets('handles cursor at text end correctly', (WidgetTester tester) async {
      controller.text = 'Hello';
      controller.selection = const TextSelection.collapsed(offset: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_italic));
      await tester.pump();

      expect(controller.text, 'Hello*italic text*');
      expect(controller.selection.baseOffset, 17);
    });

    testWidgets('wraps text in middle of document', (WidgetTester tester) async {
      controller.text = 'Start Middle End';
      controller.selection = const TextSelection(baseOffset: 6, extentOffset: 12);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, 'Start **Middle** End');
      expect(controller.selection.baseOffset, 14);
      expect(controller.selection.extentOffset, 14);
    });
  });

  group('MarkdownToolbarField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders toolbar and text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownToolbar), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('toolbar buttons work with text field', (WidgetTester tester) async {
      controller.text = 'Test';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(controller.text, '**Test**');
    });

    testWidgets('keyboard shortcut Ctrl+B works', (WidgetTester tester) async {
      controller.text = 'Bold this';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 9);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
            ),
          ),
        ),
      );

      // Focus the text field
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Send Ctrl+B
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(controller.text, '**Bold this**');
    });

    testWidgets('keyboard shortcut Ctrl+I works', (WidgetTester tester) async {
      controller.text = 'Italic this';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 11);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(controller.text, '*Italic this*');
    });

    testWidgets('keyboard shortcut Ctrl+K works', (WidgetTester tester) async {
      controller.text = 'Link text';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 9);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(controller.text, '[Link text](url)');
    });

    testWidgets('keyboard shortcuts do not work when disabled', (WidgetTester tester) async {
      controller.text = 'Test';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      // Text should remain unchanged
      expect(controller.text, 'Test');
    });

    testWidgets('onChanged callback is called', (WidgetTester tester) async {
      int callCount = 0;
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
              onChanged: (value) {
                callCount++;
                lastValue = value;
              },
            ),
          ),
        ),
      );

      controller.text = 'Test';
      controller.selection = const TextSelection.collapsed(offset: 4);
      await tester.tap(find.byIcon(Icons.format_bold));
      await tester.pump();

      expect(callCount, greaterThan(0));
      expect(lastValue, 'Test**bold text**');
    });

    testWidgets('respects hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
              hintText: 'Enter markdown here...',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, 'Enter markdown here...');
    });

    testWidgets('respects maxLines', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
              maxLines: 5,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets('respects enabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('respects custom decoration', (WidgetTester tester) async {
      const decoration = InputDecoration(
        labelText: 'Custom Label',
        border: OutlineInputBorder(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownToolbarField(
              controller: controller,
              decoration: decoration,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.labelText, 'Custom Label');
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
    });
  });
}
