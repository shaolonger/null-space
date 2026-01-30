import 'package:flutter/material.dart';
import '../models/vault.dart';
import '../services/vault_service.dart';

/// Dialog for unlocking a vault
/// 
/// This dialog prompts the user to enter a password to unlock a vault.
/// It includes password validation, error handling, and warnings for
/// multiple failed attempts.
class VaultUnlockDialog extends StatefulWidget {
  final Vault vault;
  final VaultService vaultService;

  const VaultUnlockDialog({
    super.key,
    required this.vault,
    required this.vaultService,
  });

  @override
  State<VaultUnlockDialog> createState() => _VaultUnlockDialogState();
}

class _VaultUnlockDialogState extends State<VaultUnlockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _failedAttempts = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate password
  /// 
  /// Note: Password is intentionally NOT trimmed to allow users to include
  /// leading or trailing whitespace in their passwords if desired.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  /// Unlock vault
  Future<void> _unlockVault() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Unlock vault using VaultService
      final success = await widget.vaultService.unlockVault(
        vault: widget.vault,
        password: _passwordController.text,
      );

      if (!success) {
        // Increment failed attempts
        setState(() {
          _failedAttempts++;
          _errorMessage = 'Incorrect password. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Close dialog and return success
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to unlock vault: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Unlock Vault'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vault name display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.vault.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.vault.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.vault.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter vault password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: _validatePassword,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _unlockVault(),
                autofocus: true,
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Warning for multiple failed attempts
              if (_failedAttempts >= 3) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Multiple failed attempts detected. If you forgot your password, '
                          'there is no way to recover it. You may need to delete this vault '
                          'and create a new one.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),

        // Unlock button
        FilledButton(
          onPressed: _isLoading ? null : _unlockVault,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Unlock'),
        ),
      ],
    );
  }
}
