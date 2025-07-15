// import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para adicionar token automaticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        debugPrint('🌐 ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ Erro API: ${error.message}');
        handler.next(error);
      },
    ));
  }

  void setToken(String token) {
    _token = token;
  }

  // ===== AUTENTICAÇÃO =====

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        setToken(token);
        return {'success': true, 'token': token};
      }
      return {'success': false, 'message': 'Credenciais inválidas'};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register/', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      
      return {'success': response.statusCode == 201};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      setToken(token);
      final response = await _dio.get('/auth/user/');
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/user/');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao carregar perfil: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.patch('/auth/user/', data: userData);
      return {'success': response.statusCode == 200, 'data': response.data};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.post('/auth/change-password/', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return {'success': response.statusCode == 200};
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ===== RESPONSÁVEIS =====

  Future<List<Map<String, dynamic>>> getResponsaveis({
    Map<String, dynamic>? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        ...?filters,
      };
      
      final response = await _dio.get('/cadastro/api/responsaveis/', 
        queryParameters: queryParams);
      
      return List<Map<String, dynamic>>.from(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao carregar responsáveis: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getResponsavel(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/responsaveis/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao carregar responsável: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> createResponsavel(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/cadastro/api/responsaveis/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao criar responsável: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateResponsavel(String cpf, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/cadastro/api/responsaveis/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao atualizar responsável: ${e.message}');
    }
  }

  Future<void> deleteResponsavel(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/responsaveis/$cpf/');
    } on DioException catch (e) {
      throw Exception('Erro ao excluir responsável: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getResponsavelComMembros(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/responsaveis/$cpf/com_membros/');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao carregar responsável com membros: ${e.message}');
    }
  }

  // ===== MEMBROS =====

  Future<List<Map<String, dynamic>>> getMembros({
    Map<String, dynamic>? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        ...?filters,
      };
      
      final response = await _dio.get('/cadastro/api/membros/', 
        queryParameters: queryParams);
      
      return List<Map<String, dynamic>>.from(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao carregar membros: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> createMembro(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/cadastro/api/membros/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao criar membro: ${e.message}');
    }
  }

  // ===== DEMANDAS =====

  Future<List<Map<String, dynamic>>> getDemandasSaude({
    Map<String, dynamic>? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        ...?filters,
      };
      
      final response = await _dio.get('/cadastro/api/demandas-saude/', 
        queryParameters: queryParams);
      
      return List<Map<String, dynamic>>.from(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao carregar demandas de saúde: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getDemandasEducacao({
    Map<String, dynamic>? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        ...?filters,
      };
      
      final response = await _dio.get('/cadastro/api/demandas-educacao/', 
        queryParameters: queryParams);
      
      return List<Map<String, dynamic>>.from(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao carregar demandas de educação: ${e.message}');
    }
  }

  // ===== UTILITÁRIOS =====

  Future<List<Map<String, dynamic>>> getCepsAtingidos() async {
    try {
      final response = await _dio.get('/cadastro/api/ceps-atingidos/');
      return List<Map<String, dynamic>>.from(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao carregar CEPs: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getAlojamentos() async {
    try {
      final response = await _dio.get('/cadastro/api/alojamentos/');
      return List<Map<String, dynamic>>.from(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao carregar alojamentos: ${e.message}');
    }
  }

  // Tratamento de erros
  Map<String, dynamic> _handleError(DioException e) {
    String message = 'Erro desconhecido';
    
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          message = 'Dados inválidos';
          break;
        case 401:
          message = 'Não autorizado';
          break;
        case 403:
          message = 'Acesso negado';
          break;
        case 404:
          message = 'Não encontrado';
          break;
        case 500:
          message = 'Erro interno do servidor';
          break;
        default:
          message = 'Erro de conexão';
      }
      
      // Se houver detalhes específicos do erro
      if (e.response!.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        if (errorData.containsKey('detail')) {
          message = errorData['detail'];
        } else if (errorData.containsKey('message')) {
          message = errorData['message'];
        }
      }
    } else {
      message = 'Erro de conexão com o servidor';
    }
    
    return {'success': false, 'message': message};
  }
}