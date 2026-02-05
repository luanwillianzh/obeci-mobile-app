import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAdmin {
    if (_currentUser == null) return false;

    // Tenta buscar em arrayRoles (formato da API)
    final arrayRoles = _currentUser?['arrayRoles'];
    if (arrayRoles is List) {
      return arrayRoles.contains('ADMIN');
    }

    // Fallback para roles (outro formato possível)
    final rolesRaw = _currentUser?['roles'];
    if (rolesRaw is List) {
      return rolesRaw.contains('ADMIN');
    }

    return false;
  }

  final ApiService _apiService = ApiService();

  Future<bool> login(String email, String password) async {
    final result = await _apiService.login(email, password);

    if (result['success']) {
      _isAuthenticated = true;
      _errorMessage = '';
      await loadCurrentUser(); // Carrega os detalhes do usuário após login
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Login failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final userData = await _apiService.getCurrentUser();
      if (userData.isNotEmpty) {
        _currentUser = userData;
        _isAuthenticated = true;
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    final result = await _apiService.register(username, email, password);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Registration failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  bool checkAuthStatus() {
    // This could check if token exists and is valid
    // For now, we'll just return the current status
    return _isAuthenticated;
  }
}