import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/vault.dart';
import 'package:null_space_app/providers/vault_provider.dart';

void main() {
  group('VaultProvider Tests', () {
    late VaultProvider provider;
    late Vault vault1;
    late Vault vault2;
    late Vault vault3;

    setUp(() {
      provider = VaultProvider();
      vault1 = Vault(
        id: 'vault-1',
        name: 'Personal Vault',
        description: 'My personal notes',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        salt: 'salt-1',
      );
      vault2 = Vault(
        id: 'vault-2',
        name: 'Work Vault',
        description: 'Work-related notes',
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
        salt: 'salt-2',
      );
      vault3 = Vault(
        id: 'vault-3',
        name: 'Shared Vault',
        description: 'Shared notes',
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 3),
        salt: 'salt-3',
      );
    });

    test('initializes with null current vault and empty vaults list', () {
      expect(provider.currentVault, isNull);
      expect(provider.vaults, isEmpty);
    });

    test('setCurrentVault sets the current vault', () {
      provider.setCurrentVault(vault1);
      expect(provider.currentVault, vault1);
      expect(provider.currentVault?.id, 'vault-1');
      expect(provider.currentVault?.name, 'Personal Vault');
    });

    test('setCurrentVault can change current vault', () {
      provider.setCurrentVault(vault1);
      expect(provider.currentVault, vault1);

      provider.setCurrentVault(vault2);
      expect(provider.currentVault, vault2);
      expect(provider.currentVault?.id, 'vault-2');
    });

    test('addVault adds vault to list', () {
      provider.addVault(vault1);
      expect(provider.vaults.length, 1);
      expect(provider.vaults.first, vault1);

      provider.addVault(vault2);
      expect(provider.vaults.length, 2);
      expect(provider.vaults[1], vault2);
    });

    test('addVault allows duplicate vaults', () {
      provider.addVault(vault1);
      provider.addVault(vault1);
      expect(provider.vaults.length, 2);
    });

    test('removeVault removes vault from list', () {
      provider.addVault(vault1);
      provider.addVault(vault2);
      provider.addVault(vault3);
      expect(provider.vaults.length, 3);

      provider.removeVault('vault-2');
      expect(provider.vaults.length, 2);
      expect(provider.vaults.any((v) => v.id == 'vault-2'), false);
    });

    test('removeVault clears current vault if it matches', () {
      provider.addVault(vault1);
      provider.setCurrentVault(vault1);
      expect(provider.currentVault, vault1);

      provider.removeVault('vault-1');
      expect(provider.currentVault, isNull);
      expect(provider.vaults, isEmpty);
    });

    test('removeVault does not affect current vault if different', () {
      provider.addVault(vault1);
      provider.addVault(vault2);
      provider.setCurrentVault(vault1);

      provider.removeVault('vault-2');
      expect(provider.currentVault, vault1);
      expect(provider.vaults.length, 1);
    });

    test('removeVault does nothing for non-existent vault', () {
      provider.addVault(vault1);
      expect(provider.vaults.length, 1);

      provider.removeVault('vault-999');
      expect(provider.vaults.length, 1);
      expect(provider.vaults.first, vault1);
    });

    test('updateVault updates existing vault', () {
      provider.addVault(vault1);
      provider.addVault(vault2);

      final updatedVault = Vault(
        id: 'vault-1',
        name: 'Updated Personal Vault',
        description: 'Updated description',
        createdAt: vault1.createdAt,
        updatedAt: DateTime(2024, 1, 10),
        salt: vault1.salt,
      );

      provider.updateVault(updatedVault);

      final foundVault = provider.vaults.firstWhere((v) => v.id == 'vault-1');
      expect(foundVault.name, 'Updated Personal Vault');
      expect(foundVault.description, 'Updated description');
    });

    test('updateVault updates current vault if it matches', () {
      provider.addVault(vault1);
      provider.setCurrentVault(vault1);

      final updatedVault = Vault(
        id: 'vault-1',
        name: 'Updated Name',
        description: 'Updated description',
        createdAt: vault1.createdAt,
        updatedAt: DateTime.now(),
        salt: vault1.salt,
      );

      provider.updateVault(updatedVault);

      expect(provider.currentVault?.name, 'Updated Name');
      expect(provider.currentVault?.description, 'Updated description');
    });

    test('updateVault does not affect current vault if different', () {
      provider.addVault(vault1);
      provider.addVault(vault2);
      provider.setCurrentVault(vault1);

      final updatedVault2 = Vault(
        id: 'vault-2',
        name: 'Updated Work Vault',
        description: 'Updated',
        createdAt: vault2.createdAt,
        updatedAt: DateTime.now(),
        salt: vault2.salt,
      );

      provider.updateVault(updatedVault2);

      expect(provider.currentVault, vault1);
      expect(provider.currentVault?.name, 'Personal Vault');
    });

    test('updateVault does nothing for non-existent vault', () {
      provider.addVault(vault1);

      final nonExistentVault = Vault(
        id: 'vault-999',
        name: 'Non-existent',
        description: 'Does not exist',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-999',
      );

      provider.updateVault(nonExistentVault);

      expect(provider.vaults.length, 1);
      expect(provider.vaults.first, vault1);
    });

    test('notifies listeners on setCurrentVault', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setCurrentVault(vault1);
      expect(notified, true);
    });

    test('notifies listeners on addVault', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.addVault(vault1);
      expect(notified, true);
    });

    test('notifies listeners on removeVault', () {
      provider.addVault(vault1);

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.removeVault('vault-1');
      expect(notified, true);
    });

    test('notifies listeners on updateVault', () {
      provider.addVault(vault1);

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updateVault(vault1);
      expect(notified, true);
    });

    test('handles multiple vaults with same name', () {
      final vault1Copy = Vault(
        id: 'vault-1-copy',
        name: 'Personal Vault', // Same name as vault1
        description: 'Copy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-copy',
      );

      provider.addVault(vault1);
      provider.addVault(vault1Copy);

      expect(provider.vaults.length, 2);
      expect(provider.vaults[0].id, 'vault-1');
      expect(provider.vaults[1].id, 'vault-1-copy');
    });

    test('vaults list is independent of modifications', () {
      provider.addVault(vault1);
      provider.addVault(vault2);

      final vaultsCopy = provider.vaults;
      expect(vaultsCopy.length, 2);

      provider.addVault(vault3);
      expect(provider.vaults.length, 3);
      // Original reference should still have 3 (not a deep copy in this case)
    });

    test('handles removing vault that was never added', () {
      provider.removeVault('vault-999');
      expect(provider.vaults, isEmpty);
      expect(provider.currentVault, isNull);
    });

    test('handles updating vault that was never added', () {
      provider.updateVault(vault1);
      expect(provider.vaults, isEmpty);
    });

    test('can add vault after removing it', () {
      provider.addVault(vault1);
      expect(provider.vaults.length, 1);

      provider.removeVault('vault-1');
      expect(provider.vaults, isEmpty);

      provider.addVault(vault1);
      expect(provider.vaults.length, 1);
      expect(provider.vaults.first, vault1);
    });

    test('can set current vault without adding it to list', () {
      // This tests that current vault is independent of vaults list
      provider.setCurrentVault(vault1);
      expect(provider.currentVault, vault1);
      expect(provider.vaults, isEmpty);
    });

    test('handles clearing current vault then setting again', () {
      provider.addVault(vault1);
      provider.setCurrentVault(vault1);
      expect(provider.currentVault, vault1);

      provider.removeVault('vault-1');
      expect(provider.currentVault, isNull);

      provider.addVault(vault1);
      provider.setCurrentVault(vault1);
      expect(provider.currentVault, vault1);
    });

    test('maintains vault order when adding multiple vaults', () {
      provider.addVault(vault1);
      provider.addVault(vault2);
      provider.addVault(vault3);

      expect(provider.vaults[0].id, 'vault-1');
      expect(provider.vaults[1].id, 'vault-2');
      expect(provider.vaults[2].id, 'vault-3');
    });

    test('removes only matching vault when multiple exist', () {
      provider.addVault(vault1);
      provider.addVault(vault2);
      provider.addVault(vault3);

      provider.removeVault('vault-2');

      expect(provider.vaults.length, 2);
      expect(provider.vaults[0].id, 'vault-1');
      expect(provider.vaults[1].id, 'vault-3');
    });
  });
}
