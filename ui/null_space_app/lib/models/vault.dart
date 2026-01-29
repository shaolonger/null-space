/// Model for a Vault
class Vault {
  final String id;
  String name;
  String description;
  final DateTime createdAt;
  DateTime updatedAt;
  final String salt;

  Vault({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.salt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'salt': salt,
    };
  }

  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      salt: json['salt'],
    );
  }
}
