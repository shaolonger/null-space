import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_editor_screen.dart';
import 'notes_list_screen.dart';
import 'vault_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
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
    const SettingsScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
