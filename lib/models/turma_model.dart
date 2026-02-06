class Turma {
  final int id;
  final String nome;
  final int escolaId;
  final List<int> professorIds;  // Alterado para suportar múltiplos professores
  final String turno;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Turma({
    required this.id,
    required this.nome,
    required this.escolaId,
    required this.professorIds,
    required this.turno,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    // Suporte para ambos os formatos: professorId (único) e professorIds (múltiplos)
    List<int> professorIds = [];
    if (json['professorIds'] != null && json['professorIds'] is List) {
      professorIds = (json['professorIds'] as List).cast<int>();
    } else if (json['professorId'] != null) {
      // Converter formato antigo para novo
      professorIds = [json['professorId']];
    }

    return Turma(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      escolaId: json['escolaId'] ?? 0,
      professorIds: professorIds,
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
      'professorIds': professorIds,  // Sempre retorna no novo formato
      'turno': turno,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}