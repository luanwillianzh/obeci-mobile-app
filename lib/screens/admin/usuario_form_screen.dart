import 'package:flutter/material.dart';

class UsuarioFormScreen extends StatefulWidget {
  final dynamic usuario;
  final String tipo; // 'PROFESSOR' ou 'ADMIN'
  final Function(Map<String, dynamic>) onSave;

  const UsuarioFormScreen({
    Key? key,
    this.usuario,
    required this.tipo,
    required this.onSave,
  }) : super(key: key);

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _documentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nomeController.text = widget.usuario['username']?.toString() ?? '';
      _emailController.text = widget.usuario['email']?.toString() ?? '';
      // CORREÇÃO: Inicializar o documento (CPF) se ele existir no objeto usuario
      _documentoController.text = widget.usuario['cpf']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    // BOA PRÁTICA: Sempre dar dispose nos controllers
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _documentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titulo = widget.tipo == 'PROFESSOR' ? 'Professor' : 'Administrador';
    String acao = widget.usuario != null ? 'Editar' : 'Novo';

    return Scaffold(
      appBar: AppBar(
        title: Text('$acao $titulo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _documentoController,
                  decoration: InputDecoration(
                    labelText: 'CPF',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CPF';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (widget.usuario == null && (value == null || value.isEmpty)) {
                      return 'Por favor, insira a senha';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final usuarioData = {
                        'username': _nomeController.text,
                        'email': _emailController.text,
                        'cpf': _documentoController.text,
                        'arrayRoles': [widget.tipo], // PROFESSOR ou ADMIN
                      };

                      // Adiciona a senha somente se for fornecida (para novos usuários ou alterações)
                      if (_senhaController.text.isNotEmpty) {
                        usuarioData['password'] = _senhaController.text;
                      }

                      if (widget.usuario != null) {
                        usuarioData['id'] = widget.usuario['id'];
                      }

                      widget.onSave(usuarioData);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.usuario != null ? 'Atualizar' : 'Criar',
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