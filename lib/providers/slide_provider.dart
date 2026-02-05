import 'dart:async';
import 'package:flutter/material.dart';
import '../models/slide_model.dart';
import '../services/slide_service.dart';

class SlideProvider with ChangeNotifier {
  final SlideService _service = SlideService();
  Instrumento? _instrumento;
  Timer? _timer;
  bool _isLoading = false;

  Instrumento? get instrumento => _instrumento;
  bool get isLoading => _isLoading;

  void startAutoUpdate(int turmaId) {
    stopAutoUpdate();
    _fetch(turmaId); // Primeira busca
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetch(turmaId, silent: true));
  }

  void stopAutoUpdate() => _timer?.cancel();

  Future<void> _fetch(int turmaId, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final res = await _service.getInstrumentoByTurma(turmaId);
      // Só atualiza se a versão mudou
      if (res != null && res.version != _instrumento?.version) {
        _instrumento = res;
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAutoUpdate();
    super.dispose();
  }
}