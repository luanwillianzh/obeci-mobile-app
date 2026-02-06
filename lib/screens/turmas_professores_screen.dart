import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/turma_provider.dart';
import '../providers/escola_provider.dart';
import '../providers/professor_provider.dart';
import '../models/turma_model.dart';
import '../models/escola_model.dart';
import '../models/professor_model.dart';

class TurmasProfessoresScreen extends StatefulWidget {
  const TurmasProfessoresScreen({Key? key}) : super(key: key);

  @override
  _TurmasProfessoresScreenState createState() => _TurmasProfessoresScreenState();
}

class _TurmasProfessoresScreenState extends State<TurmasProfessoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    final escolaProvider = Provider.of<EscolaProvider>(context, listen: false);
    final professorProvider = Provider.of<ProfessorProvider>(context, listen: false);

    await Future.wait([
      turmaProvider.fetchTurmas(),
      escolaProvider.fetchEscolas(),
      professorProvider.fetchProfessores(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final escolaProvider = Provider.of<EscolaProvider>(context);
    final professorProvider = Provider.of<ProfessorProvider>(context);

    // Group turmas by escola
    Map<int, List<Turma>> turmasPorEscola = {};
    for (var turma in turmaProvider.turmas) {
      if (!turmasPorEscola.containsKey(turma.escolaId)) {
        turmasPorEscola[turma.escolaId] = [];
      }
      turmasPorEscola[turma.escolaId]!.add(turma);
    }

    // Create a map of escola names by ID for quick lookup
    Map<int, String> escolasPorId = {};
    for (var escola in escolaProvider.escolas) {
      escolasPorId[escola.id] = escola.nome;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turmas e Professores'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (turmaProvider.isLoading || escolaProvider.isLoading || professorProvider.isLoading)
              const LinearProgressIndicator()
            else if (turmaProvider.turmas.isEmpty)
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'Nenhuma turma encontrada.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: turmasPorEscola.entries.map((entry) {
                    final escolaId = entry.key;
                    final turmas = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 16, top: 8),
                          child: Row(
                            children: [
                              Text(
                                escolasPorId[escolaId] ?? 'Escola #$escolaId',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  indent: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: turmas.map((turma) {
                            // Obter os nomes dos professores associados à turma
                            List<Professor> professoresDaTurma = professorProvider.getProfessoresByIds(turma.professorIds);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      turma.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Turno: ${turma.turno}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    // Mostrar os professores associados à turma
                                    if (professoresDaTurma.isNotEmpty)
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: professoresDaTurma.map((professor) {
                                          return Chip(
                                            label: Text(
                                              professor.username,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                          );
                                        }).toList(),
                                      )
                                    else
                                      const Text(
                                        'Nenhum professor associado',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    const SizedBox(height: 8),
                                    Chip(
                                      label: Text(
                                        turma.isActive ? 'Ativa' : 'Inativa',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: turma.isActive
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                          : Theme.of(context).colorScheme.error.withOpacity(0.2),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}