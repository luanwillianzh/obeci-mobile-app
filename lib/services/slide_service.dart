import '../models/slide_model.dart';
import '../services/api_service.dart';

class SlideService {
  final ApiService _apiService = ApiService();

  Future<Instrumento?> getInstrumentoByTurma(int turmaId) async {
    try {
      final response = await _apiService.dio.get('/api/instrumentos/turma/$turmaId');
      
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is Map<String, dynamic>) {
          // O JSON agora vem como um objeto contendo id, turmaId e slidesJson
          return Instrumento.fromJson(response.data);
        } else {
          print('Formato de resposta inesperado: ${response.data.runtimeType}');
          return null;
        }
      } else {
        print('Erro API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exceção ao buscar instrumento: $e');
      return null;
    }
  }
}