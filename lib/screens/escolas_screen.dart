import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/escola_provider.dart';
import '../models/escola_model.dart';

class EscolasScreen extends StatelessWidget {
  const EscolasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditEscolaDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: Consumer<EscolaProvider>(
        builder: (context, escolaProvider, child) {
          if (escolaProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (escolaProvider.escolas.isEmpty) {
            return const Center(
              child: Text('Nenhuma escola encontrada.'),
            );
          }

          return ListView.builder(
            itemCount: escolaProvider.escolas.length,
            itemBuilder: (context, index) {
              final escola = escolaProvider.escolas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(escola.nome),
                  subtitle: Text(escola.isActive ? 'Ativa' : 'Inativa'),
                  trailing: PopupMenuButton(
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
                        _showAddEditEscolaDialog(context, escola: escola);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, escola);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditEscolaDialog(BuildContext context, {Escola? escola}) {
    final TextEditingController nomeController = TextEditingController(text: escola?.nome);
    final TextEditingController cidadeController = TextEditingController(text: escola?.cidade);
    bool isActive = escola?.isActive ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(escola == null ? 'Adicionar Escola' : 'Editar Escola'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),
              SwitchListTile(
                title: const Text('Ativa'),
                value: isActive,
                onChanged: (bool value) {
                  isActive = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isNotEmpty && cidadeController.text.isNotEmpty) {

                  final escolaProvider = Provider.of<EscolaProvider>(context, listen: false);

                  if (escola == null) {
                    // Add new escola
                    await escolaProvider.createEscola(
                      nomeController.text,
                      cidadeController.text,
                      isActive
                    );
                  } else {
                    // Update existing escola
                    await escolaProvider.updateEscola(
                      escola.id,
                      nomeController.text,
                      cidadeController.text,
                      isActive,
                    );
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(escola == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Escola escola) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir a escola "${escola.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final escolaProvider = Provider.of<EscolaProvider>(context, listen: false);
                await escolaProvider.deleteEscola(escola.id);
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