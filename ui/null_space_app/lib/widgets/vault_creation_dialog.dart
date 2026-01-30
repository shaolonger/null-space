import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vault.dart';
import '../services/vault_service.dart';
import '../providers/vault_provider.dart';

/// Dialog for creating a new vault
/// 
/// This dialog collects vault information (name, description, password)
/// and creates a new encrypted vault using VaultService.
class VaultCreationDialog extends StatefulWidget {
  final VaultService vaultService;

  const VaultCreationDialog({
    super.key,
    required this.vaultService,
  });

  @override
  State<VaultCreationDialog> createState() => _VaultCreationDialogState();
}

class _VaultCreationDialogState extends State<VaultCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Calculate password strength (0-3)
  /// 0 = weak, 1 = medium, 2 = strong, 3 = very strong
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Complexity checks
    if (password.contains(RegExp(r'[A-Z]'))) strength++; // Has uppercase
    if (password.contains(RegExp(r'[a-z]'))) strength++; // Has lowercase
    if (password.contains(RegExp(r'[0-9]'))) strength++; // Has digits
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++; // Has special chars

    // Cap at 3 for display purposes (weak, medium, strong)
    return (strength / 2).round().clamp(0, 3);
  }

  /// Get password strength label
  String _getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
        return 'Weak';
      case 1:
        return 'Medium';
      case 2:
        return 'Strong';
      case 3:
        return 'Very Strong';
      default:
        return 'Weak';
    }
  }

  /// Get password strength color
  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  /// Validate vault name
  String? _validateName(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return 'Vault name is required';
    }
    if (trimmedValue.length > 100) {
      return 'Name must be 100 characters or less';
    }
    return null;
  }

  /// Validate password
  /// 
  /// Note: Password is intentionally NOT trimmed to allow users to include
  /// leading or trailing whitespace in their passwords if desired.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Create vault
  Future<void> _createVault() async {
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
      // Create vault using VaultService
      final vault = await widget.vaultService.createVault(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        password: _passwordController.text,
      );

      // Add vault to provider
      if (mounted) {
        final vaultProvider = context.read<VaultProvider>();
        vaultProvider.addVault(vault);

        // Close dialog and return the created vault
        Navigator.of(context).pop(vault);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create vault: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Create New Vault'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vault name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vault Name',
                  hintText: 'Enter vault name',
                  prefixIcon: Icon(Icons.folder),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: _validateName,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter vault description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                maxLines: 2,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password (min 8 characters)',
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
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                enabled: !_isLoading,
                onChanged: (value) {
                  // Update password strength
                  setState(() {
                    _passwordStrength = _calculatePasswordStrength(value);
                  });
                },
              ),
              const SizedBox(height: 8),

              // Password strength indicator
              if (_passwordController.text.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _passwordStrength / 3,
                        backgroundColor: Colors.grey[300],
                        color: _getPasswordStrengthColor(_passwordStrength),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPasswordStrengthLabel(_passwordStrength),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getPasswordStrengthColor(_passwordStrength),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),

              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: _validateConfirmPassword,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _createVault(),
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
            ],
          ),
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        // Create button
        FilledButton(
          onPressed: _isLoading ? null : _createVault,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
