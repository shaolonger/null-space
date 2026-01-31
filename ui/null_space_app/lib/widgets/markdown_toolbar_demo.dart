import 'package:flutter/material.dart';
import 'package:null_space_app/widgets/markdown_toolbar.dart';

/// Demo application for the MarkdownToolbar widget
/// 
/// Demonstrates:
/// - Basic MarkdownToolbar usage
/// - MarkdownToolbarField usage
/// - Custom configurations
/// - Real-world integration examples
void main() {
  runApp(const MarkdownToolbarDemo());
}

class MarkdownToolbarDemo extends StatelessWidget {
  const MarkdownToolbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Toolbar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BasicToolbarDemo(),
    const ToolbarFieldDemo(),
    const CustomConfigDemo(),
    const RealWorldDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Toolbar Demo'),
        elevation: 2,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.widgets),
            label: 'Basic',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note),
            label: 'Field',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Custom',
          ),
          NavigationDestination(
            icon: Icon(Icons.app_shortcut),
            label: 'Real-World',
          ),
        ],
      ),
    );
  }
}

/// Demo 1: Basic MarkdownToolbar usage
class BasicToolbarDemo extends StatefulWidget {
  const BasicToolbarDemo({super.key});

  @override
  State<BasicToolbarDemo> createState() => _BasicToolbarDemoState();
}

class _BasicToolbarDemoState extends State<BasicToolbarDemo> {
  final _controller = TextEditingController(
    text: 'Select this text and click toolbar buttons to format it.\n\n'
        'Try these:\n'
        '- Select text and click Bold\n'
        '- Place cursor and click any button\n'
        '- Use heading dropdown for H1-H6\n',
  );
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
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Toolbar Demo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Standalone toolbar with separate TextField',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: MarkdownToolbar(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: () {
              setState(() {}); // Rebuild to show character count
            },
          ),
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Start typing...',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Characters: ${_controller.text.length}'),
              Text('Lines: ${_controller.text.split('\n').length}'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Demo 2: MarkdownToolbarField usage
class ToolbarFieldDemo extends StatefulWidget {
  const ToolbarFieldDemo({super.key});

  @override
  State<ToolbarFieldDemo> createState() => _ToolbarFieldDemoState();
}

class _ToolbarFieldDemoState extends State<ToolbarFieldDemo> {
  final _controller = TextEditingController(
    text: '# Welcome\n\n'
        'This is a **MarkdownToolbarField** - an all-in-one widget.\n\n'
        'Try keyboard shortcuts:\n'
        '- Ctrl+B for bold\n'
        '- Ctrl+I for italic\n'
        '- Ctrl+K for link\n',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MarkdownToolbarField Demo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'All-in-one widget with keyboard shortcuts',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: MarkdownToolbarField(
            controller: _controller,
            hintText: 'Write your markdown here...',
            onChanged: (value) {
              // Handle changes
            },
          ),
        ),
      ],
    );
  }
}

/// Demo 3: Custom configuration
class CustomConfigDemo extends StatefulWidget {
  const CustomConfigDemo({super.key});

  @override
  State<CustomConfigDemo> createState() => _CustomConfigDemoState();
}

class _CustomConfigDemoState extends State<CustomConfigDemo> {
  final _controller = TextEditingController(
    text: 'This demo shows custom configurations:\n\n'
        '- Larger icons (24px)\n'
        '- No dividers\n'
        '- Custom decoration\n',
  );
  bool _enabled = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custom Configuration Demo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Toolbar with custom settings',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Enable toolbar:'),
              const SizedBox(width: 8),
              Switch(
                value: _enabled,
                onChanged: (value) {
                  setState(() {
                    _enabled = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: MarkdownToolbarField(
            controller: _controller,
            enabled: _enabled,
            toolbarIconSize: 24,
            showToolbarDividers: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Note Content',
              hintText: 'Enter your note...',
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) {
              // Handle changes
            },
          ),
        ),
      ],
    );
  }
}

/// Demo 4: Real-world integration
class RealWorldDemo extends StatefulWidget {
  const RealWorldDemo({super.key});

  @override
  State<RealWorldDemo> createState() => _RealWorldDemoState();
}

class _RealWorldDemoState extends State<RealWorldDemo> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController(
    text: '# My Note\n\nStart writing your note here...\n',
  );
  bool _hasChanges = false;
  String _savedContent = '';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _savedContent = _contentController.text;
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _contentController.text = _savedContent;
      _hasChanges = false;
    });
  }

  void _clear() {
    setState(() {
      _titleController.clear();
      _contentController.clear();
      _hasChanges = false;
      _savedContent = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Real-World Integration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Note editor with save/reset functionality',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Note Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MarkdownToolbarField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Note Content',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_hasChanges ? 'Unsaved changes' : 'No changes'),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _clear,
                            child: const Text('Clear'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _hasChanges ? _reset : null,
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _hasChanges ? _save : null,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
