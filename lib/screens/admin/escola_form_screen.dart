import 'package:flutter/material.dart';

class EscolaFormScreen extends StatefulWidget {
  final dynamic escola;
  final Function(Map<String, dynamic>) onSave;

  const EscolaFormScreen({
    Key? key,
    this.escola,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EscolaFormScreen> createState() => _EscolaFormScreenState();
}

class _EscolaFormScreenState extends State<EscolaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cidadeController = TextEditingController();

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.escola != null) {
      _nomeController.text = widget.escola['nome'] ?? '';
      _cidadeController.text = widget.escola['cidade'] ?? '';
      _isActive = widget.escola['isActive'] ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    String acao = widget.escola != null ? 'Editar' : 'Nova';

    return Scaffold(
      appBar: AppBar(
        title: Text('$acao Escola'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome da Escola',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.school_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome da escola';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cidadeController,
                  decoration: InputDecoration(
                    labelText: 'Cidade',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a cidade';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Ativo'),
                  value: _isActive,
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final escolaData = {
                        'nome': _nomeController.text,
                        'cidade': _cidadeController.text,
                        'isActive': _isActive,
                      };

                      if (widget.escola != null) {
                        escolaData['id'] = widget.escola['id'] as int;
                      }

                      widget.onSave(escolaData);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.escola != null ? 'Atualizar' : 'Criar',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}