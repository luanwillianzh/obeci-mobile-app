import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'usuario_form_screen.dart';
import 'turma_form_screen.dart';
import 'escola_form_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();

  // Dados para cada aba
  List<dynamic> _escolas = [];
  List<dynamic> _professores = [];
  List<dynamic> _administradores = [];
  List<dynamic> _turmas = [];

  bool _isLoading = false;

  // Controladores para os campos de pesquisa
  late TextEditingController _escolaSearchController;
  late TextEditingController _professorSearchController;
  late TextEditingController _adminSearchController;
  late TextEditingController _turmaSearchController;

  @override
  void initState() {
    super.initState();
    _escolaSearchController = TextEditingController();
    _professorSearchController = TextEditingController();
    _adminSearchController = TextEditingController();
    _turmaSearchController = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _escolaSearchController.dispose();
    _professorSearchController.dispose();
    _adminSearchController.dispose();
    _turmaSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadEscolas();
    await _loadProfessores();
    await _loadAdministradores();
    await _loadTurmas();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadEscolas() async {
    try {
      final data = await _apiService.getAllEscolas();
      setState(() {
        _escolas = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar escolas: $e')),
      );
    }
  }

  Future<void> _loadProfessores() async {
    try {
      final response = await _apiService.dio.get('/api/usuarios/role/PROFESSOR');
      if (response.statusCode == 200) {
        setState(() {
          // CORREÇÃO: Garantir que estamos pegando a lista de dados
          _professores = response.data as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar professores: $e');
    }
  }

  Future<void> _loadAdministradores() async {
    try {
      // Endpoint para listar usuários com papel ADMIN
      final response = await _apiService.dio.get('/api/usuarios/role/ADMIN');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        setState(() {
          _administradores = response.data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar administradores: $e')),
      );
    }
  }

  Future<void> _loadTurmas() async {
    try {
      final data = await _apiService.getAllTurmas();
      setState(() {
        _turmas = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar turmas: $e')),
      );
    }
  }

  Future<void> _deleteEscola(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir esta escola?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo
                try {
                  await _apiService.deleteEscola(id);
                  await _loadEscolas(); // Recarrega a lista
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Escola excluída com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir escola: $e')),
                  );
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfessor(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir este professor?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo
                try {
                  final response = await _apiService.dio.delete('/api/usuarios/$id');
                  if (response.statusCode! >= 200 && response.statusCode! < 300) {
                    await _loadProfessores(); // Recarrega a lista
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Professor excluído com sucesso!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir professor: $e')),
                  );
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAdministrador(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir este administrador?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo
                try {
                  final response = await _apiService.dio.delete('/api/usuarios/$id');
                  if (response.statusCode! >= 200 && response.statusCode! < 300) {
                    await _loadAdministradores(); // Recarrega a lista
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Administrador excluído com sucesso!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir administrador: $e')),
                  );
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTurma(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir esta turma?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo
                try {
                  await _apiService.deleteTurma(id);
                  await _loadTurmas(); // Recarrega a lista
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Turma excluída com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir turma: $e')),
                  );
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _createOrEditEscola([dynamic escola]) {
    print('Chamando _createOrEditEscola com escola: ${escola != null ? escola['nome'] : 'nova'}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscolaFormScreen(
          escola: escola,
          onSave: (escolaData) async {
            try {
              if (escola != null) {
                print('Atualizando escola com ID: ${escola['id']}');
                await _apiService.updateEscola(escola['id'] as int, escolaData);
              } else {
                print('Criando nova escola');
                await _apiService.createEscola(escolaData);
              }
              await _loadEscolas();
              Navigator.pop(context);
            } catch (e) {
              print('Erro ao salvar escola: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar escola: $e')),
              );
            }
          },
        ),
      ),
    ).then((_) {
      print('Formulário de escola fechado');
    });
  }

  void _createOrEditProfessor([dynamic professor]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuarioFormScreen(
          usuario: professor,
          tipo: 'PROFESSOR',
          onSave: (usuarioData) async {
            try {
              if (professor != null) {
                // Atualizar professor existente
                final response = await _apiService.dio.put('/api/usuarios/${professor['id'] as int}', data: usuarioData);
                if (response.statusCode! < 200 || response.statusCode! >= 300) {
                  throw Exception('Erro ao atualizar professor: ${response.statusMessage}');
                }
              } else {
                // Criar novo professor
                final response = await _apiService.dio.post('/api/usuarios', data: usuarioData);
                if (response.statusCode! < 200 || response.statusCode! >= 300) {
                  throw Exception('Erro ao criar professor: ${response.statusMessage}');
                }
              }
              await _loadProfessores();
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar professor: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  void _createOrEditAdministrador([dynamic administrador]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuarioFormScreen(
          usuario: administrador,
          tipo: 'ADMIN',
          onSave: (usuarioData) async {
            try {
              if (administrador != null) {
                // Atualizar administrador existente
                final response = await _apiService.dio.put('/api/usuarios/${administrador['id'] as int}', data: usuarioData);
                if (response.statusCode! < 200 || response.statusCode! >= 300) {
                  throw Exception('Erro ao atualizar administrador: ${response.statusMessage}');
                }
              } else {
                // Criar novo administrador
                final response = await _apiService.dio.post('/api/usuarios', data: usuarioData);
                if (response.statusCode! < 200 || response.statusCode! >= 300) {
                  throw Exception('Erro ao criar administrador: ${response.statusMessage}');
                }
              }
              await _loadAdministradores();
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar administrador: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  void _createOrEditTurma([dynamic turma]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurmaFormScreen(
          turma: turma,
          onSave: (turmaData) async {
            try {
              if (turma != null) {
                // Atualizar turma existente
                await _apiService.updateTurma(turma['id'] as int, turmaData);
              } else {
                // Criar nova turma
                await _apiService.createTurma(turmaData);
              }
              await _loadTurmas();
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar turma: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'Escolas',
      'Professores',
      'Administradores',
      'Turmas'
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel Administrativo'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildEscolasTab(),
                  _buildProfessoresTab(),
                  _buildAdministradoresTab(),
                  _buildTurmasTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildEscolasTab() {
    // Filtrar escolas com base na pesquisa
    List<dynamic> filteredEscolas = _escolas;
    if (_escolaSearchController.text.isNotEmpty) {
      filteredEscolas = _escolas.where((escola) =>
        (escola['nome']?.toString() ?? '').toLowerCase().contains(_escolaSearchController.text.toLowerCase()) ||
        (escola['cidade']?.toString() ?? '').toLowerCase().contains(_escolaSearchController.text.toLowerCase())
      ).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchBar(
            controller: _escolaSearchController,
            hintText: 'Pesquisar escola...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {}); // Atualiza a lista filtrada quando o texto muda
            },
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => _createOrEditEscola(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredEscolas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma escola encontrada',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione uma nova escola usando o botão acima',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEscolas.length,
                    itemBuilder: (context, index) {
                      final escola = filteredEscolas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.school,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            escola['nome']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(escola['cidade']?.toString() ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _createOrEditEscola(escola),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: () => _deleteEscola(escola['id'] as int),
                                icon: const Icon(Icons.delete),
                                label: const Text('Excluir'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
    );
  }

  Widget _buildProfessoresTab() {
    // Filtrar professores com base na pesquisa
    List<dynamic> filteredProfessores = _professores;
    if (_professorSearchController.text.isNotEmpty) {
      filteredProfessores = _professores.where((professor) =>
        (professor['username']?.toString() ?? '').toLowerCase().contains(_professorSearchController.text.toLowerCase()) ||
        (professor['email']?.toString() ?? '').toLowerCase().contains(_professorSearchController.text.toLowerCase())
      ).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchBar(
            controller: _professorSearchController,
            hintText: 'Pesquisar professor...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {}); // Atualiza a lista filtrada quando o texto muda
            },
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => _createOrEditProfessor(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredProfessores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum professor encontrado',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione um novo professor usando o botão acima',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProfessores.length,
                    itemBuilder: (context, index) {
                      final professor = filteredProfessores[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          title: Text(
                            professor['username']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(professor['email']?.toString() ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _createOrEditProfessor(professor),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: () => _deleteProfessor(professor['id'] as int),
                                icon: const Icon(Icons.delete),
                                label: const Text('Excluir'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
    );
  }

  Widget _buildAdministradoresTab() {
    // Filtrar administradores com base na pesquisa
    List<dynamic> filteredAdministradores = _administradores;
    if (_adminSearchController.text.isNotEmpty) {
      filteredAdministradores = _administradores.where((administrador) =>
        (administrador['username']?.toString() ?? '').toLowerCase().contains(_adminSearchController.text.toLowerCase()) ||
        (administrador['email']?.toString() ?? '').toLowerCase().contains(_adminSearchController.text.toLowerCase())
      ).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchBar(
            controller: _adminSearchController,
            hintText: 'Pesquisar administrador...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {}); // Atualiza a lista filtrada quando o texto muda
            },
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => _createOrEditAdministrador(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredAdministradores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum administrador encontrado',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione um novo administrador usando o botão acima',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredAdministradores.length,
                    itemBuilder: (context, index) {
                      final administrador = filteredAdministradores[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          title: Text(
                            administrador['username']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(administrador['email']?.toString() ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _createOrEditAdministrador(administrador),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: () => _deleteAdministrador(administrador['id'] as int),
                                icon: const Icon(Icons.delete),
                                label: const Text('Excluir'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
    );
  }

  Widget _buildTurmasTab() {
    // Filtrar turmas com base na pesquisa
    List<dynamic> filteredTurmas = _turmas;
    if (_turmaSearchController.text.isNotEmpty) {
      filteredTurmas = _turmas.where((turma) =>
        (turma['nome']?.toString() ?? '').toLowerCase().contains(_turmaSearchController.text.toLowerCase()) ||
        (turma['turno']?.toString() ?? '').toLowerCase().contains(_turmaSearchController.text.toLowerCase())
      ).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SearchBar(
            controller: _turmaSearchController,
            hintText: 'Pesquisar turma...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {}); // Atualiza a lista filtrada quando o texto muda
            },
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceVariant),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => _createOrEditTurma(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredTurmas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma turma encontrada',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione uma nova turma usando o botão acima',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTurmas.length,
                    itemBuilder: (context, index) {
                      final turma = filteredTurmas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.class_,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            turma['nome']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text('Turno: ${turma['turno']?.toString() ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _createOrEditTurma(turma),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: () => _deleteTurma(turma['id'] as int),
                                icon: const Icon(Icons.delete),
                                label: const Text('Excluir'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
    );
  }
}

