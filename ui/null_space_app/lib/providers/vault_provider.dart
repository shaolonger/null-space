import 'package:flutter/foundation.dart';
import '../models/vault.dart';

/// Provider for managing vaults
class VaultProvider extends ChangeNotifier {
  Vault? _currentVault;
  List<Vault> _vaults = [];

  Vault? get currentVault => _currentVault;
  List<Vault> get vaults => _vaults;

  void setCurrentVault(Vault vault) {
    _currentVault = vault;
    notifyListeners();
  }

  void addVault(Vault vault) {
    _vaults.add(vault);
    notifyListeners();
  }

  void removeVault(String vaultId) {
    _vaults.removeWhere((v) => v.id == vaultId);
    if (_currentVault?.id == vaultId) {
      _currentVault = null;
    }
    notifyListeners();
  }

  void updateVault(Vault vault) {
    final index = _vaults.indexWhere((v) => v.id == vault.id);
    if (index != -1) {
      _vaults[index] = vault;
      if (_currentVault?.id == vault.id) {
        _currentVault = vault;
      }
      notifyListeners();
    }
  }
}
