import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TurmaFormScreen extends StatefulWidget {
  final dynamic turma;
  final Function(Map<String, dynamic>) onSave;

  const TurmaFormScreen({
    Key? key,
    this.turma,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TurmaFormScreen> createState() => _TurmaFormScreenState();
}

class _TurmaFormScreenState extends State<TurmaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nomeController = TextEditingController();
  final _turnoController = TextEditingController(); // Added for Turno
  final _apiService = ApiService();

  // State variables
  int? _escolaSelecionada;
  int? _professorSelecionado;
  bool _isActive = true;

  List<dynamic> _escolas = [];
  List<dynamic> _professores = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();

    if (widget.turma != null) {
      _nomeController.text = widget.turma['nome']?.toString() ?? '';
      _turnoController.text = widget.turma['turno']?.toString() ?? '';
      _escolaSelecionada = widget.turma['escolaId'];
      _professorSelecionado = widget.turma['professorId'];
      _isActive = widget.turma['isActive'] ?? true;
    }

    _carregarDadosRelacionados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _turnoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosRelacionados() async {
    try {
      final resultados = await Future.wait([
        _apiService.getAllEscolas(),
        _apiService.dio.get('/api/usuarios/role/PROFESSOR'),
      ]);

      setState(() {
        _escolas = resultados[0] as List<dynamic>;
        final responseProfessores = resultados[1] as dynamic;
        _professores = responseProfessores.data as List<dynamic>;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String acao = widget.turma != null ? 'Editar' : 'Nova';

    return Scaffold(
      appBar: AppBar(
        title: Text('$acao Turma'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field: Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Turma',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome da turma';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field: Turno (Now a TextFormField)
                      TextFormField(
                        controller: _turnoController,
                        decoration: const InputDecoration(
                          labelText: 'Turno',
                          hintText: 'Ex: Manhã, Tarde, Noite ou Integral',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o turno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field: Escola
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Escola',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _escolaSelecionada,
                            isExpanded: true,
                            onChanged: (int? newValue) {
                              setState(() {
                                _escolaSelecionada = newValue;
                              });
                            },
                            items: _escolas
                                .map<DropdownMenuItem<int>>((escola) => DropdownMenuItem(
                                      value: escola['id'] as int,
                                      child: Text(escola['nome'] as String),
                                    ))
                                .toList(),
                            hint: const Text('Selecione uma escola'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Field: Professor
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Professor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _professorSelecionado,
                            isExpanded: true,
                            onChanged: (int? newValue) {
                              setState(() {
                                _professorSelecionado = newValue;
                              });
                            },
                            items: _professores
                                .map<DropdownMenuItem<int>>((professor) => DropdownMenuItem(
                                      value: professor['id'] as int,
                                      child: Text(professor['username'] as String),
                                    ))
                                .toList(),
                            hint: const Text('Selecione um professor'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Toggle: Ativo
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

                      // Save Button
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final turmaData = {
                              'nome': _nomeController.text,
                              'turno': _turnoController.text, // Data from Controller
                              'escolaId': _escolaSelecionada,
                              'professorId': _professorSelecionado,
                              'isActive': _isActive,
                            };

                            if (widget.turma != null) {
                              turmaData['id'] = widget.turma['id'];
                            }

                            widget.onSave(turmaData);
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          widget.turma != null ? 'Atualizar' : 'Criar',
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