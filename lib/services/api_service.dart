import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Updated to match the backend configuration
  static const String baseUrl = 'https://obeci.the-fool.site'; // Using 10.0.2.2 to connect to localhost on Android emulator
  late Dio _dio;
  Dio get dio => _dio; // Getter to access the Dio instance
  static const String tokenKey = 'jwt_token';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      // Enable cookie handling for JWT cookie authentication
      validateStatus: (status) => status != null && status < 500, // Accept all status codes below 500
    ));

    // Add interceptors for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // For mobile app, we'll store the JWT token in SharedPreferences
        // and send it as Bearer token since mobile apps can't handle HttpOnly cookies like web apps
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString(tokenKey);

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // Check if the response contains a Set-Cookie header with the JWT token
        if (response.headers.value('set-cookie') != null) {
          String? cookieValue = response.headers.value('set-cookie');

          // Extract the JWT token from the cookie if present
          if (cookieValue != null && cookieValue.contains('token=')) {
            RegExp regExp = RegExp(r'token=([^;]+)');
            Match? match = regExp.firstMatch(cookieValue);

            if (match != null) {
              String token = match.group(1)!;

              // Store the token in SharedPreferences for future requests
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString(tokenKey, token);
            }
          }
        }

        return handler.next(response);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          // Handle unauthorized access - maybe redirect to login
          print('Unauthorized access - token may have expired');

          // Clear stored token
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove(tokenKey);
        }
        return handler.next(err);
      },
    ));
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login',
          data: {'email': email, 'password': password});

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // The token might be returned in the response body or in a cookie
        String? token;

        // Check if token is in response body
        if (response.data != null && response.data['token'] != null) {
          token = response.data['token'];
        }

        // If token is not in response body, try to extract from Set-Cookie header
        if (token == null) {
          String? cookieValue = response.headers.value('set-cookie');
          if (cookieValue != null && cookieValue.contains('token=')) {
            RegExp regExp = RegExp(r'token=([^;]+)');
            Match? match = regExp.firstMatch(cookieValue);
            if (match != null) {
              token = match.group(1)!;
            }
          }
        }

        // Store the token in SharedPreferences
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey, token);
        }

        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'error': 'Login failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register',
          data: {'username': username, 'email': email, 'password': password});

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'error': 'Registration failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Even if the logout request fails, clear the local token
      print('Logout request failed, clearing local token anyway');
    }

    // Clear stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Turmas methods
  Future<List<dynamic>> getAllTurmas() async {
    try {
      final response = await _dio.get('/api/turmas');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting turmas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting turmas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getTurmaById(int id) async {
    try {
      final response = await _dio.get('/api/turmas/$id');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting turma: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error getting turma: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> createTurma(Map<String, dynamic> turmaData) async {
    try {
      final response = await _dio.post('/api/turmas', data: turmaData);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error creating turma: ${response.statusCode}');
        return {'success': false, 'error': 'Create turma failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error creating turma: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateTurma(int id, Map<String, dynamic> turmaData) async {
    try {
      final response = await _dio.put('/api/turmas/$id', data: turmaData);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error updating turma: ${response.statusCode}');
        return {'success': false, 'error': 'Update turma failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error updating turma: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteTurma(int id) async {
    try {
      final response = await _dio.delete('/api/turmas/$id');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return {'success': true, 'data': response.data};
      } else {
        print('Error deleting turma: ${response.statusCode}');
        return {'success': false, 'error': 'Delete turma failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error deleting turma: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<dynamic>> getTurmasByEscola(int escolaId) async {
    try {
      final response = await _dio.get('/api/turmas/escola/$escolaId');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting turmas by escola: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting turmas by escola: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTurmasByProfessor(int professorId) async {
    try {
      final response = await _dio.get('/api/turmas/professor/$professorId');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting turmas by professor: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting turmas by professor: $e');
      return [];
    }
  }

  // Escolas methods
  Future<List<dynamic>> getAllEscolas() async {
    try {
      final response = await _dio.get('/api/escolas');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting escolas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting escolas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getEscolaById(int id) async {
    try {
      final response = await _dio.get('/api/escolas/$id');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting escola: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error getting escola: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> createEscola(Map<String, dynamic> escolaData) async {
    try {
      final response = await _dio.post('/api/escolas', data: escolaData);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error creating escola: ${response.statusCode}');
        return {'success': false, 'error': 'Create escola failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error creating escola: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateEscola(int id, Map<String, dynamic> escolaData) async {
    try {
      final response = await _dio.put('/api/escolas/$id', data: escolaData);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error updating escola: ${response.statusCode}');
        return {'success': false, 'error': 'Update escola failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error updating escola: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteEscola(int id) async {
    try {
      final response = await _dio.delete('/api/escolas/$id');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return {'success': true, 'data': response.data};
      } else {
        print('Error deleting escola: ${response.statusCode}');
        return {'success': false, 'error': 'Delete escola failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error deleting escola: $e');
      return {'success': false, 'error': e.toString()};
    }
  }


  // Get current user details
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        print('Error getting current user: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error getting current user: $e');
      return {};
    }
  }

  // Lembretes methods
  Future<List<String>> listMyLembretes() async {
    try {
      final response = await _dio.get('/auth/me/lembretes');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is List) {
          return List<String>.from(response.data);
        } else {
          print('Unexpected response format for lembretes');
          return [];
        }
      } else {
        print('Error getting lembretes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting lembretes: $e');
      return [];
    }
  }

  Future<List<String>> addMyLembrete(String text) async {
    try {
      final response = await _dio.post('/auth/me/lembretes', data: {'text': text});
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is List) {
          return List<String>.from(response.data);
        } else {
          print('Unexpected response format for adding lembrete');
          return [];
        }
      } else {
        print('Error adding lembrete: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error adding lembrete: $e');
      return [];
    }
  }

  Future<List<String>> updateMyLembrete(int index, String text) async {
    try {
      final response = await _dio.put('/auth/me/lembretes/$index', data: {'text': text});
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is List) {
          return List<String>.from(response.data);
        } else {
          print('Unexpected response format for updating lembrete');
          return [];
        }
      } else {
        print('Error updating lembrete: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error updating lembrete: $e');
      return [];
    }
  }

  Future<List<String>> deleteMyLembrete(int index) async {
    try {
      final response = await _dio.delete('/auth/me/lembretes/$index');
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data is List) {
          return List<String>.from(response.data);
        } else {
          print('Unexpected response format for deleting lembrete');
          return [];
        }
      } else {
        print('Error deleting lembrete: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error deleting lembrete: $e');
      return [];
    }
  }
}