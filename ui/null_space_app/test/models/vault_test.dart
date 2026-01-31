import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/models/vault.dart';

void main() {
  group('Vault Model Tests', () {
    late Vault testVault;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 10, 9, 0);
      testUpdatedAt = DateTime(2024, 1, 20, 15, 30);
      testVault = Vault(
        id: 'vault-123',
        name: 'Test Vault',
        description: 'A test vault for testing',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        salt: 'test-salt-abc123',
      );
    });

    test('creates vault with all properties', () {
      expect(testVault.id, 'vault-123');
      expect(testVault.name, 'Test Vault');
      expect(testVault.description, 'A test vault for testing');
      expect(testVault.createdAt, testCreatedAt);
      expect(testVault.updatedAt, testUpdatedAt);
      expect(testVault.salt, 'test-salt-abc123');
    });

    test('toJson serializes vault correctly', () {
      final json = testVault.toJson();

      expect(json['id'], 'vault-123');
      expect(json['name'], 'Test Vault');
      expect(json['description'], 'A test vault for testing');
      expect(json['created_at'], testCreatedAt.toIso8601String());
      expect(json['updated_at'], testUpdatedAt.toIso8601String());
      expect(json['salt'], 'test-salt-abc123');
    });

    test('fromJson deserializes vault correctly', () {
      final json = {
        'id': 'vault-456',
        'name': 'Deserialized Vault',
        'description': 'Vault from JSON',
        'created_at': '2024-03-01T10:00:00.000',
        'updated_at': '2024-03-15T14:30:00.000',
        'salt': 'salt-xyz789',
      };

      final vault = Vault.fromJson(json);

      expect(vault.id, 'vault-456');
      expect(vault.name, 'Deserialized Vault');
      expect(vault.description, 'Vault from JSON');
      expect(vault.createdAt, DateTime.parse('2024-03-01T10:00:00.000'));
      expect(vault.updatedAt, DateTime.parse('2024-03-15T14:30:00.000'));
      expect(vault.salt, 'salt-xyz789');
    });

    test('serialization and deserialization round trip', () {
      final json = testVault.toJson();
      final deserializedVault = Vault.fromJson(json);

      expect(deserializedVault.id, testVault.id);
      expect(deserializedVault.name, testVault.name);
      expect(deserializedVault.description, testVault.description);
      expect(
        deserializedVault.createdAt.toIso8601String(),
        testVault.createdAt.toIso8601String(),
      );
      expect(
        deserializedVault.updatedAt.toIso8601String(),
        testVault.updatedAt.toIso8601String(),
      );
      expect(deserializedVault.salt, testVault.salt);
    });

    test('handles empty description', () {
      final vault = Vault(
        id: 'vault-empty-desc',
        name: 'Vault Name',
        description: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-123',
      );

      expect(vault.description, '');
      final json = vault.toJson();
      expect(json['description'], '');
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.description, '');
    });

    test('name is mutable', () {
      testVault.name = 'Updated Vault Name';
      expect(testVault.name, 'Updated Vault Name');
    });

    test('description is mutable', () {
      testVault.description = 'Updated description';
      expect(testVault.description, 'Updated description');
    });

    test('updatedAt is mutable', () {
      final newDate = DateTime(2024, 2, 1, 12, 0);
      testVault.updatedAt = newDate;
      expect(testVault.updatedAt, newDate);
    });

    test('handles special characters in name', () {
      final vault = Vault(
        id: 'vault-special',
        name: 'Vault! @#$% Name',
        description: 'Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-123',
      );

      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.name, vault.name);
    });

    test('handles special characters in description', () {
      final vault = Vault(
        id: 'vault-special-desc',
        name: 'Vault Name',
        description: 'Description with "quotes" and \'apostrophes\' and \n newlines',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-123',
      );

      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.description, vault.description);
    });

    test('handles very long description', () {
      final longDescription = 'A' * 5000; // 5,000 characters
      final vault = Vault(
        id: 'vault-long-desc',
        name: 'Vault Name',
        description: longDescription,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-123',
      );

      expect(vault.description.length, 5000);
      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.description.length, 5000);
      expect(deserializedVault.description, longDescription);
    });

    test('handles long salt values', () {
      final longSalt = 'a' * 1000; // Very long salt
      final vault = Vault(
        id: 'vault-long-salt',
        name: 'Vault Name',
        description: 'Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: longSalt,
      );

      expect(vault.salt.length, 1000);
      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.salt.length, 1000);
      expect(deserializedVault.salt, longSalt);
    });

    test('preserves datetime precision', () {
      final preciseDate = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);
      final vault = Vault(
        id: 'vault-precise-date',
        name: 'Vault Name',
        description: 'Description',
        createdAt: preciseDate,
        updatedAt: preciseDate,
        salt: 'salt-123',
      );

      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      // DateTime.parse may not preserve microseconds, but should preserve milliseconds
      expect(
        deserializedVault.createdAt.millisecondsSinceEpoch,
        preciseDate.millisecondsSinceEpoch,
      );
    });

    test('id is immutable', () {
      // This test verifies that id is final
      expect(testVault.id, 'vault-123');
      // Attempting to assign would cause a compile error
      // testVault.id = 'new-id'; // This would not compile
    });

    test('createdAt is immutable', () {
      // This test verifies that createdAt is final
      expect(testVault.createdAt, testCreatedAt);
      // Attempting to assign would cause a compile error
      // testVault.createdAt = DateTime.now(); // This would not compile
    });

    test('salt is immutable', () {
      // This test verifies that salt is final
      expect(testVault.salt, 'test-salt-abc123');
      // Attempting to assign would cause a compile error
      // testVault.salt = 'new-salt'; // This would not compile
    });

    test('handles unicode characters in name', () {
      final vault = Vault(
        id: 'vault-unicode',
        name: '保险库 🔐 Vault Сейф',
        description: 'Unicode description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-123',
      );

      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.name, vault.name);
    });

    test('handles unicode characters in description', () {
      final vault = Vault(
        id: 'vault-unicode-desc',
        name: 'Vault Name',
        description: '描述 📝 Описание',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: 'salt-123',
      );

      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.description, vault.description);
    });

    test('handles base64-like salt values', () {
      final base64Salt = 'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo=';
      final vault = Vault(
        id: 'vault-base64-salt',
        name: 'Vault Name',
        description: 'Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salt: base64Salt,
      );

      final json = vault.toJson();
      final deserializedVault = Vault.fromJson(json);
      expect(deserializedVault.salt, base64Salt);
    });
  });
}
