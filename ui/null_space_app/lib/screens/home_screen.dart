import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_editor_screen.dart';
import 'notes_list_screen.dart';
import '../widgets/vault_creation_dialog.dart';
import '../services/vault_service.dart';
import '../services/file_storage.dart';
import '../bridge/rust_bridge.dart';
import '../providers/vault_provider.dart';

/// Home screen with navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NotesListScreen(),
    const SearchScreen(),
    const VaultScreen(),
  ];

  void _navigateToNoteEditor() {
    // TODO: Replace with actual vault credentials from VaultProvider
    // For now, using placeholder values for development
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(
          vaultPath: '/tmp/default-vault',
          vaultPassword: 'development',
          vaultSalt: 'development-salt',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Null Space'),
        elevation: 2,
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToNoteEditor,
              tooltip: 'Create Note',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder),
            label: 'Vault',
          ),
        ],
      ),
    );
  }
}

/// Search screen placeholder
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text('Enter search query to find notes'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vault management screen placeholder
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  VaultService? _vaultService;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final bridge = RustBridge();
      bridge.init();
      final storage = await FileStorage.create();
      setState(() {
        _vaultService = VaultService(bridge: bridge, storage: storage);
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _initError = e.toString();
        _isInitializing = false;
      });
    }
  }

  Future<void> _showCreateVaultDialog() async {
    if (_vaultService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vault service not initialized'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => VaultCreationDialog(
        vaultService: _vaultService!,
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vault "${result.name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to Initialize',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Vault Management',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Create and manage encrypted vaults'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateVaultDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create New Vault'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import vault feature coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.upload),
            label: const Text('Import Vault'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export vault feature coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Vault'),
          ),
        ],
      ),
    );
  }
}
