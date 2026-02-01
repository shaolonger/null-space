import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:null_space_app/l10n/app_localizations.dart';
import '../models/vault.dart';
import '../services/vault_service.dart';
import '../services/auth_service.dart';
import '../providers/settings_provider.dart';

/// Dialog for unlocking a vault
///
/// This dialog prompts the user to enter a password to unlock a vault.
/// It includes password validation, error handling, biometric authentication,
/// and warnings for multiple failed attempts.
class VaultUnlockDialog extends StatefulWidget {
  final Vault vault;
  final VaultService vaultService;
  final AuthService? authService;

  const VaultUnlockDialog({
    super.key,
    required this.vault,
    required this.vaultService,
    this.authService,
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
  bool _biometricsAvailable = false;
  bool _checkedBiometrics = false;

  @override
  void initState() {
    super.initState();
    // Check biometric availability will be done in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only check once
    if (!_checkedBiometrics) {
      _checkedBiometrics = true;
      _checkBiometricAvailability();
    }
  }

  /// Check if biometrics are available and enabled
  Future<void> _checkBiometricAvailability() async {
    if (widget.authService == null) {
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.biometricEnabled) {
      return;
    }

    final available = await widget.authService!.canUseBiometrics();
    if (mounted) {
      setState(() {
        _biometricsAvailable = available;
      });

      // Automatically attempt biometric auth if available
      if (available) {
        _authenticateWithBiometrics();
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate password
  ///
  /// Note: Password is intentionally NOT trimmed to allow users to include
  /// leading or trailing whitespace in their passwords if desired.
  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    return null;
  }

  /// Authenticate with biometrics
  Future<void> _authenticateWithBiometrics() async {
    if (widget.authService == null || !_biometricsAvailable) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Attempt to unlock with biometrics and retrieve stored password
      final password = await widget.authService!.unlockWithBiometrics(
        vaultId: widget.vault.id,
        reason: 'Unlock ${widget.vault.name}',
      );

      if (!mounted) return;

      if (password != null) {
        // Successfully retrieved password, now unlock the vault
        final success = await widget.vaultService.unlockVault(
          vault: widget.vault,
          password: password,
        );

        if (success && mounted) {
          // Vault unlocked successfully
          Navigator.of(context).pop(true);
        } else if (mounted) {
          // Password was wrong or vault unlock failed
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to unlock vault. Please use password.';
          });
        }
      } else {
        // Biometric authentication failed or no password stored
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Biometric authentication failed. Please use password.';
        });
      }
    }
  }

  /// Unlock vault
  Future<void> _unlockVault() async {
    final l10n = AppLocalizations.of(context)!;

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

    // Unlock vault using VaultService
    final success = await widget.vaultService.unlockVault(
      vault: widget.vault,
      password: _passwordController.text,
    );

    if (!success) {
      // Increment failed attempts
      setState(() {
        _failedAttempts++;
        _errorMessage = l10n.incorrectPassword;
        _isLoading = false;
      });
      return;
    }

    // If biometric auth is available and enabled, store password for future biometric unlock
    if (widget.authService != null && _biometricsAvailable) {
      try {
        await widget.authService!.storeVaultPassword(
          vaultId: widget.vault.id,
          password: _passwordController.text,
        );
      } catch (e) {
        // Log but don't fail the unlock if password storage fails
        debugPrint('Failed to store password for biometric unlock: $e');
      }
    }

    // Close dialog and return success
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.unlockVault),
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
                  color: theme.colorScheme.surfaceVariant,
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
                  labelText: l10n.password,
                  hintText: 'Enter vault password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
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
                validator: (value) => _validatePassword(value, l10n),
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _unlockVault(),
                autofocus: !_biometricsAvailable,
              ),

              // Biometric unlock button
              if (_biometricsAvailable) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _authenticateWithBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.unlockWithBiometrics),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],

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
          child: Text(l10n.cancel),
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
              : Text(l10n.unlock),
        ),
      ],
    );
  }
}
