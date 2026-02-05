class Escola {
  final int id;
  final String nome;
  final String cidade;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Escola({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Escola.fromJson(Map<String, dynamic> json) {
    return Escola(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      cidade: json['cidade'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cidade': cidade,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}