import 'package:flutter/material.dart';
import '../models/turma_model.dart';
import '../services/api_service.dart';

class TurmaProvider with ChangeNotifier {
  List<Turma> _turmas = [];
  bool _isLoading = false;

  List<Turma> get turmas => _turmas;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchTurmas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.getAllTurmas();
      _turmas = data.map((json) => Turma.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching turmas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTurma(String nome, int escolaId, int professorId, String turno, bool isActive) async {
    _isLoading = true;
    notifyListeners();

    try {
      final turmaData = {
        'nome': nome,
        'escolaId': escolaId,
        'professorId': professorId,
        'turno': turno,
        'isActive': isActive,
      };

      final result = await _apiService.createTurma(turmaData);

      if (result['success']) {
        await fetchTurmas(); // Refresh the list
        return true;
      }
    } catch (e) {
      print('Error creating turma: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> createTurmaWithoutProfessor(String nome, int escolaId, String turno, bool isActive, {int defaultProfessorId = 0}) async {
    return createTurma(nome, escolaId, defaultProfessorId, turno, isActive);
  }

  Future<bool> updateTurma(int id, String nome, int escolaId, int professorId, String turno, bool isActive) async {
    _isLoading = true;
    notifyListeners();

    try {
      final turmaData = {
        'nome': nome,
        'escolaId': escolaId,
        'professorId': professorId,
        'turno': turno,
        'isActive': isActive,
      };

      final result = await _apiService.updateTurma(id, turmaData);

      if (result['success']) {
        await fetchTurmas(); // Refresh the list
        return true;
      }
    } catch (e) {
      print('Error updating turma: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> updateTurmaWithoutProfessor(int id, String nome, int escolaId, String turno, bool isActive) async {
    // Fetch current turma to get the existing professorId
    final currentTurma = _turmas.firstWhere((t) => t.id == id, orElse: () => _turmas[0]);
    return updateTurma(id, nome, escolaId, currentTurma.professorId, turno, isActive);
  }

  Future<bool> deleteTurma(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.deleteTurma(id);

      if (result['success']) {
        _turmas.removeWhere((turma) => turma.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting turma: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }
}