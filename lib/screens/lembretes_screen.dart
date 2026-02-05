import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lembrete_provider.dart';

class LembretesScreen extends StatefulWidget {
  const LembretesScreen({Key? key}) : super(key: key);

  @override
  _LembretesScreenState createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {
  final TextEditingController _lembreteController = TextEditingController();
  int? _editandoIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);
    await lembreteProvider.fetchLembretes();
  }

  Future<void> _adicionarOuEditarLembrete() async {
    final texto = _lembreteController.text.trim();
    if (texto.isEmpty) return;

    final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);

    if (_editandoIndex == null) {
      // Add new lembrete
      await lembreteProvider.addLembrete(texto);
    } else {
      // Update existing lembrete
      await lembreteProvider.updateLembrete(_editandoIndex!, texto);
    }

    // Reset form
    _lembreteController.clear();
    setState(() {
      _editandoIndex = null;
    });
  }

  void _iniciarEdicao(int index) {
    final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);
    setState(() {
      _editandoIndex = index;
      _lembreteController.text = lembreteProvider.lembretes[index];
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editandoIndex = null;
      _lembreteController.clear();
    });
  }

  Future<void> _removerLembrete(int index) async {
    final lembreteProvider = Provider.of<LembreteProvider>(context, listen: false);
    await lembreteProvider.deleteLembrete(index);
    
    // If we were editing the item that was deleted, cancel editing
    if (_editandoIndex == index) {
      _cancelarEdicao();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lembreteProvider = Provider.of<LembreteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembretes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add/edit reminder form
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _lembreteController,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Novo lembrete',
                        hintText: 'Digite seu lembrete...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_editandoIndex != null)
                            TextButton(
                              onPressed: lembreteProvider.isLoading ? null : _cancelarEdicao,
                              child: const Text('Cancelar'),
                            ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: lembreteProvider.isLoading
                                ? null
                                : _adicionarOuEditarLembrete,
                            child: Text(_editandoIndex == null ? 'Adicionar' : 'Atualizar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // List of reminders
            Expanded(
              child: lembreteProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : lembreteProvider.lembretes.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum lembrete',
                            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: lembreteProvider.lembretes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lembreteProvider.lembretes[index],
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Criado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          onPressed: () => _iniciarEdicao(index),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                          onPressed: () => _removerLembrete(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lembreteController.dispose();
    super.dispose();
  }
}