import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LembreteProvider with ChangeNotifier {
  List<String> _lembretes = [];
  bool _isLoading = false;

  List<String> get lembretes => _lembretes;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchLembretes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.listMyLembretes();
      _lembretes = data;
    } catch (e) {
      print('Error fetching lembretes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLembrete(String text) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.addMyLembrete(text);
      _lembretes = result;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding lembrete: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLembrete(int index, String text) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.updateMyLembrete(index, text);
      _lembretes = result;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating lembrete: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLembrete(int index) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.deleteMyLembrete(index);
      _lembretes = result;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting lembrete: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}