import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/turma_provider.dart';
import '../providers/professor_provider.dart';
import '../models/turma_model.dart';
import '../models/professor_model.dart';

class TurmasScreen extends StatelessWidget {
  const TurmasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turmas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditTurmaDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<TurmaProvider>(
        builder: (context, turmaProvider, child) {
          if (turmaProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (turmaProvider.turmas.isEmpty) {
            return const Center(
              child: Text('Nenhuma turma encontrada.'),
            );
          }

          return ListView.builder(
            itemCount: turmaProvider.turmas.length,
            itemBuilder: (context, index) {
              final turma = turmaProvider.turmas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turma.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Escola ID: ${turma.escolaId}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Turno: ${turma.turno}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                // Mostrar os professores associados à turma
                                if (turma.professorIds.isNotEmpty)
                                  Wrap(
                                    spacing: 4.0,
                                    runSpacing: 2.0,
                                    children: [
                                      const Text('Professores:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ...turma.professorIds.map((id) => Text(' #$id', style: const TextStyle(fontSize: 12))).toList(),
                                    ],
                                  )
                                else
                                  const Text('Nenhum professor associado', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  'Ativa: ${turma.isActive ? 'Sim' : 'Não'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: const [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(Icons.delete, size: 20),
                                    SizedBox(width: 8),
                                    Text('Excluir'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddEditTurmaDialog(context, turma: turma);
                              } else if (value == 'delete') {
                                _showDeleteConfirmationDialog(context, turma);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditTurmaDialog(BuildContext context, {Turma? turma}) {
    final TextEditingController nomeController = TextEditingController(text: turma?.nome);
    final TextEditingController escolaIdController = TextEditingController(text: turma?.escolaId.toString());
    final TextEditingController turnoController = TextEditingController(text: turma?.turno);
    bool isActive = turma?.isActive ?? true;

    // Carregar os IDs dos professores existentes
    List<int> selectedProfessorIds = turma?.professorIds ?? [];

    // Carregar a lista de professores
    final professorProvider = Provider.of<ProfessorProvider>(context, listen: false);
    List<Professor> availableProfessores = professorProvider.professores;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(turma == null ? 'Adicionar Turma' : 'Editar Turma'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: escolaIdController,
                      decoration: const InputDecoration(labelText: 'ID da Escola'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: turnoController,
                      decoration: const InputDecoration(labelText: 'Turno'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Professores associados:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        itemCount: availableProfessores.length,
                        itemBuilder: (context, index) {
                          Professor professor = availableProfessores[index];
                          bool isSelected = selectedProfessorIds.contains(professor.id);

                          return CheckboxListTile(
                            title: Text(professor.username),
                            subtitle: Text(professor.email),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedProfessorIds.add(professor.id);
                                } else {
                                  selectedProfessorIds.remove(professor.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Ativa'),
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isNotEmpty &&
                    escolaIdController.text.isNotEmpty &&
                    turnoController.text.isNotEmpty) {

                  final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);

                  if (turma == null) {
                    // Add new turma with selected professors
                    await turmaProvider.createTurma(
                      nomeController.text,
                      int.parse(escolaIdController.text),
                      selectedProfessorIds,
                      turnoController.text,
                      isActive
                    );
                  } else {
                    // Update existing turma with selected professors
                    await turmaProvider.updateTurma(
                      turma.id,
                      nomeController.text,
                      int.parse(escolaIdController.text),
                      selectedProfessorIds,
                      turnoController.text,
                      isActive
                    );
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(turma == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Turma turma) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir a turma "${turma.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
                await turmaProvider.deleteTurma(turma.id);
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Excluir'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            ),
          ],
        );
      },
    );
  }
}