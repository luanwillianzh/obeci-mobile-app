import 'package:flutter/material.dart';
import '../models/escola_model.dart';
import '../services/api_service.dart';

class EscolaProvider with ChangeNotifier {
  List<Escola> _escolas = [];
  bool _isLoading = false;

  List<Escola> get escolas => _escolas;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchEscolas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.getAllEscolas();
      _escolas = data.map((json) => Escola.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching escolas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEscola(String nome, String cidade, bool isActive) async {
    _isLoading = true;
    notifyListeners();

    try {
      final escolaData = {
        'nome': nome,
        'cidade': cidade,
        'isActive': isActive,
      };

      final result = await _apiService.createEscola(escolaData);

      if (result['success']) {
        await fetchEscolas(); // Refresh the list
        return true;
      }
    } catch (e) {
      print('Error creating escola: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> updateEscola(int id, String nome, String cidade, bool isActive) async {
    _isLoading = true;
    notifyListeners();

    try {
      final escolaData = {
        'nome': nome,
        'cidade': cidade,
        'isActive': isActive,
      };

      final result = await _apiService.updateEscola(id, escolaData);

      if (result['success']) {
        await fetchEscolas(); // Refresh the list
        return true;
      }
    } catch (e) {
      print('Error updating escola: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> deleteEscola(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.deleteEscola(id);

      if (result['success']) {
        _escolas.removeWhere((escola) => escola.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting escola: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }
}