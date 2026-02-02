import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'note_editor_screen.dart';
import 'notes_list_screen.dart';
import 'vault_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../providers/vault_provider.dart';
import '../services/vault_service.dart';

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

  void _navigateToNoteEditor() async {
    final vaultProvider = context.read<VaultProvider>();
    final currentVault = vaultProvider.currentVault;

    if (currentVault == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please unlock a vault first')),
      );
      return;
    }

    final vaultService = context.read<VaultService>();

    final vaultPassword = vaultService.getVaultPassword(currentVault.id);
    if (vaultPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vault is locked. Please unlock it first')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          vaultPath: 'vaults/${currentVault.id}',
          vaultPassword: vaultPassword,
          vaultSalt: currentVault.salt,
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
