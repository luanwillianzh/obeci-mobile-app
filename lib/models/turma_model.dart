class Turma {
  final int id;
  final String nome;
  final int escolaId;
  final int professorId;
  final String turno;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Turma({
    required this.id,
    required this.nome,
    required this.escolaId,
    required this.professorId,
    required this.turno,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      escolaId: json['escolaId'] ?? 0,
      professorId: json['professorId'] ?? 0,
      turno: json['turno'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'escolaId': escolaId,
      'professorId': professorId,
      'turno': turno,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}