import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/vault.dart';
import '../providers/vault_provider.dart';
import '../services/vault_service.dart';
import '../services/file_storage.dart';
import '../bridge/rust_bridge.dart';
import '../widgets/vault_card.dart';
import '../widgets/vault_creation_dialog.dart';
import '../widgets/vault_unlock_dialog.dart';

/// Enhanced vault management screen
/// 
/// This screen displays all local vaults and provides functionality for:
/// - Creating new vaults
/// - Unlocking/locking vaults
/// - Importing vaults from ZIP files
/// - Exporting vaults to ZIP files
/// - Deleting vaults with confirmation
/// - Renaming vaults
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  VaultService? _vaultService;
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _initError;
  List<Vault> _vaults = [];
  String? _selectedVaultId;

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
      final vaultService = VaultService(bridge: bridge, storage: storage);
      
      // Load vaults
      final vaults = await vaultService.listVaults();
      
      if (mounted) {
        setState(() {
          _vaultService = vaultService;
          _vaults = vaults;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _refreshVaults() async {
    if (_vaultService == null) return;
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final vaults = await _vaultService!.listVaults();
      if (mounted) {
        setState(() {
          _vaults = vaults;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load vaults: ${e.toString()}');
      }
    }
  }

  Future<void> _showCreateVaultDialog() async {
    if (_vaultService == null) {
      _showErrorSnackBar('Vault service not initialized');
      return;
    }

    final result = await showDialog<Vault>(
      context: context,
      builder: (context) => VaultCreationDialog(
        vaultService: _vaultService!,
      ),
    );

    if (result != null && mounted) {
      // Update provider
      final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
      vaultProvider.addVault(result);
      
      // Refresh list
      await _refreshVaults();
      
      _showSuccessSnackBar('Vault "${result.name}" created successfully!');
    }
  }

  Future<void> _handleVaultTap(Vault vault) async {
    if (_vaultService == null) return;

    final isUnlocked = _vaultService!.isVaultUnlocked(vault.id);
    
    if (isUnlocked) {
      // Lock the vault
      _vaultService!.lockVault(vaultId: vault.id);
      
      // Update provider
      final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
      if (vaultProvider.currentVault?.id == vault.id) {
        vaultProvider.setCurrentVault(vault);
      }
      
      setState(() {
        _selectedVaultId = null;
      });
      
      _showSuccessSnackBar('Vault "${vault.name}" locked');
    } else {
      // Show unlock dialog
      final unlocked = await showDialog<bool>(
        context: context,
        builder: (context) => VaultUnlockDialog(
          vault: vault,
          vaultService: _vaultService!,
        ),
      );

      if (unlocked == true && mounted) {
        // Update provider
        final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
        vaultProvider.setCurrentVault(vault);
        
        setState(() {
          _selectedVaultId = vault.id;
        });
        
        _showSuccessSnackBar('Vault "${vault.name}" unlocked');
      }
    }
  }

  Future<void> _handleDeleteVault(Vault vault) async {
    if (_vaultService == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _vaultService!.deleteVault(vaultId: vault.id);
      
      if (mounted) {
        // Update provider
        final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
        vaultProvider.removeVault(vault.id);
        
        // Refresh list
        await _refreshVaults();
        
        _showSuccessSnackBar('Vault "${vault.name}" deleted');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to delete vault: ${e.toString()}');
      }
    }
  }

  Future<void> _handleExportVault(Vault vault) async {
    if (_vaultService == null) return;

    // Check if vault is unlocked
    if (!_vaultService!.isVaultUnlocked(vault.id)) {
      _showErrorSnackBar('Please unlock the vault before exporting');
      return;
    }

    // Get export location
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Vault',
      fileName: '${vault.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (outputPath == null) {
      // User cancelled
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final password = _vaultService!.getVaultPassword(vault.id);
      if (password == null) {
        throw Exception('Vault password not found');
      }

      // TODO: Load notes from vault
      final notes = []; // Placeholder - would need NoteService integration
      
      await _vaultService!.exportVault(
        vault: vault,
        notes: notes,
        outputPath: outputPath,
        password: password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessSnackBar('Vault exported to: $outputPath');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to export vault: ${e.toString()}');
      }
    }
  }

  Future<void> _handleImportVault() async {
    if (_vaultService == null) {
      _showErrorSnackBar('Vault service not initialized');
      return;
    }

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Vault',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      // User cancelled
      return;
    }

    final filePath = result.files.first.path;
    if (filePath == null) {
      _showErrorSnackBar('Invalid file path');
      return;
    }

    // Prompt for password
    final passwordController = TextEditingController();
    
    if (!mounted) return;
    
    final password = await showDialog<String>(
      context: context,
      builder: (context) => _ImportPasswordDialog(
        controller: passwordController,
      ),
    );

    // Dispose controller after dialog closes
    passwordController.dispose();

    if (password == null || password.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final (vault, notes) = await _vaultService!.importVault(
        inputPath: filePath,
        password: password,
      );

      if (mounted) {
        // Update provider
        final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
        vaultProvider.addVault(vault);
        
        // Refresh list
        await _refreshVaults();

        _showSuccessSnackBar(
          'Vault "${vault.name}" imported successfully with ${notes.length} notes!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to import vault: ${e.toString()}');
      }
    }
  }

  Future<void> _handleRenameVault(Vault vault) async {
    final nameController = TextEditingController(text: vault.name);
    final descriptionController = TextEditingController(text: vault.description);

    if (!mounted) return;
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _RenameVaultDialog(
        nameController: nameController,
        descriptionController: descriptionController,
      ),
    );

    // Dispose controllers after dialog closes
    nameController.dispose();
    descriptionController.dispose();

    if (result != null && mounted) {
      // Validate name is not empty
      final newName = result['name']?.trim() ?? '';
      if (newName.isEmpty) {
        _showErrorSnackBar('Vault name cannot be empty');
        return;
      }

      final updatedVault = Vault(
        id: vault.id,
        name: newName,
        description: result['description'] ?? vault.description,
        createdAt: vault.createdAt,
        updatedAt: DateTime.now(),
        salt: vault.salt,
      );

      // Update provider
      final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
      vaultProvider.updateVault(updatedVault);
      
      // Refresh list
      await _refreshVaults();
      
      _showSuccessSnackBar('Vault renamed successfully');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _initializeServices();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showCreateVaultDialog,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createVault),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleImportVault,
                      icon: const Icon(Icons.upload),
                      label: Text(l10n.import),
                    ),
                  ),
                ],
              ),
            ),

            // Vaults list
            Expanded(
              child: _vaults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noVaults,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.createNewVaultPrompt,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshVaults,
                      child: ListView.builder(
                        itemCount: _vaults.length,
                        itemBuilder: (context, index) {
                          final vault = _vaults[index];
                          final isLocked = _vaultService != null &&
                              !_vaultService!.isVaultUnlocked(vault.id);

                          return VaultCard(
                            vault: vault,
                            isLocked: isLocked,
                            onTap: () => _handleVaultTap(vault),
                            onDelete: () => _handleDeleteVault(vault),
                            onExport: () => _handleExportVault(vault),
                            onRename: () => _handleRenameVault(vault),
                            isSelected: vault.id == _selectedVaultId,
                            noteCount: 0, // TODO: Get actual note count
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

/// Dialog for importing a vault with password input
class _ImportPasswordDialog extends StatelessWidget {
  final TextEditingController controller;

  const _ImportPasswordDialog({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.importVault),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: l10n.password,
          hintText: 'Enter the vault password',
          border: const OutlineInputBorder(),
        ),
        obscureText: true,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(l10n.import),
        ),
      ],
    );
  }
}

/// Dialog for renaming a vault
class _RenameVaultDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const _RenameVaultDialog({
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.renameVault),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.vaultName,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop({
              'name': nameController.text,
              'description': descriptionController.text,
            });
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
