import 'package:flutter/material.dart';
import '../models/professor_model.dart';
import '../services/api_service.dart';

class ProfessorProvider with ChangeNotifier {
  List<Professor> _professores = [];
  bool _isLoading = false;

  List<Professor> get professores => _professores;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchProfessores() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/api/usuarios/role/PROFESSOR');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        _professores = (response.data as List)
            .map((json) => Professor.fromJson(json))
            .toList();
      } else {
        print('Error getting professores: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting professores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Professor? getProfessorById(int id) {
    try {
      return _professores.firstWhere((professor) => professor.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Professor> getProfessoresByIds(List<int> ids) {
    return _professores
        .where((professor) => ids.contains(professor.id))
        .toList();
  }
}