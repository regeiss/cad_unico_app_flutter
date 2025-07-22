import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final int? statusCode;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success({
    String? message,
    Map<String, dynamic>? data,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    dynamic error,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }
}

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
    _loadTokenFromStorage();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adicionar token de autorização se disponível
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          
          if (kDebugMode) {
            debugPrint('🔗 REQUEST: ${options.method} ${options.path}');
            debugPrint('📝 Headers: ${options.headers}');
            if (options.data != null) {
              debugPrint('📄 Data: ${options.data}');
            }
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
            debugPrint('📄 Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('❌ ERROR: ${error.message}');
            debugPrint('📄 Response: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    } catch (e) {
      debugPrint('Erro ao carregar token: $e');
    }
  }

  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _token = token;
    } catch (e) {
      debugPrint('Erro ao salvar token: $e');
    }
  }

  Future<void> _removeTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _token = null;
    } catch (e) {
      debugPrint('Erro ao remover token: $e');
    }
  }

  // ========== MÉTODOS DE AUTENTICAÇÃO ==========

  /// Realiza login do usuário
  Future<ApiResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Salvar token se presente
        if (data['token'] != null) {
          await _saveTokenToStorage(data['token']);
        }

        return ApiResponse.success(
          message: 'Login realizado com sucesso',
          data: data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Erro no login',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro inesperado: $e',
        error: e,
      );
    }
  }

  /// Realiza logout do usuário
  Future<ApiResponse> logout(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/logout/',
        data: {
          'refresh': refreshToken,
        },
      );

      await _removeTokenFromStorage();

      return ApiResponse.success(
        message: 'Logout realizado com sucesso',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // Mesmo com erro, remover token local
      await _removeTokenFromStorage();
      return _handleDioError(e);
    } catch (e) {
      await _removeTokenFromStorage();
      return ApiResponse.error(
        message: 'Erro no logout: $e',
        error: e,
      );
    }
  }

  /// Valida se o token ainda é válido
  Future<ApiResponse> validateToken(String token) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/verify/',
        data: {
          'token': token,
        },
      );

      return ApiResponse.success(
        message: 'Token válido',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao validar token: $e',
        error: e,
      );
    }
  }

  /// Renova o token de acesso
  Future<ApiResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/refresh/',
        data: {
          'refresh': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Salvar novo token
        if (data['access'] != null) {
          await _saveTokenToStorage(data['access']);
        }

        return ApiResponse.success(
          message: 'Token renovado com sucesso',
          data: data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Erro ao renovar token',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao renovar token: $e',
        error: e,
      );
    }
  }

  /// Registra um novo usuário
  Future<ApiResponse> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Usuário registrado com sucesso',
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Erro no registro',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro no registro: $e',
        error: e,
      );
    }
  }

  /// Obtém o perfil do usuário logado
  Future<ApiResponse> getUserProfile() async {
    try {
      final response = await _dio.get('/api/v1/auth/profile/');

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Perfil carregado com sucesso',
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Erro ao carregar perfil',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao carregar perfil: $e',
        error: e,
      );
    }
  }

  /// Atualiza o perfil do usuário
  Future<ApiResponse> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put(
        '/api/v1/auth/profile/',
        data: userData,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Perfil atualizado com sucesso',
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Erro ao atualizar perfil',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao atualizar perfil: $e',
        error: e,
      );
    }
  }

  /// Altera a senha do usuário
  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/change-password/',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Senha alterada com sucesso',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.data['message'] ?? 'Erro ao alterar senha',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao alterar senha: $e',
        error: e,
      );
    }
  }

  // ========== MÉTODOS DE DADOS ==========

  /// Busca responsáveis
  Future<ApiResponse> getResponsaveis({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/api/v1/cadastro/api/responsaveis/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Erro ao buscar responsáveis',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar responsáveis: $e',
        error: e,
      );
    }
  }

  /// Busca responsável por CPF
  Future<ApiResponse> getResponsavelByCpf(String cpf) async {
    try {
      final response = await _dio.get(
        '/api/v1/cadastro/api/responsaveis/$cpf/',
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Responsável não encontrado',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar responsável: $e',
        error: e,
      );
    }
  }

  /// Busca responsável com membros
  Future<ApiResponse> getResponsavelComMembros(String cpf) async {
    try {
      final response = await _dio.get(
        '/api/v1/cadastro/api/responsaveis/$cpf/com_membros/',
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Responsável não encontrado',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar responsável com membros: $e',
        error: e,
      );
    }
  }

  /// Busca demandas de saúde
  Future<ApiResponse> getDemandasSaude({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/api/v1/cadastro/api/demandas-saude/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Erro ao buscar demandas de saúde',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar demandas de saúde: $e',
        error: e,
      );
    }
  }

  /// Busca demandas de educação
  Future<ApiResponse> getDemandasEducacao({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/api/v1/cadastro/api/demandas-educacao/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.data,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: 'Erro ao buscar demandas de educação',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar demandas de educação: $e',
        error: e,
      );
    }
  }

  // ========== MÉTODOS UTILITÁRIOS ==========

  /// Tratamento de erros do Dio
  ApiResponse _handleDioError(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Timeout na conexão. Verifique sua internet.';
        break;

      case DioExceptionType.badResponse:
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data;
            if (errorData is Map<String, dynamic>) {
              message = errorData['message'] ?? 
                       errorData['error'] ?? 
                       errorData['detail'] ?? 
                       'Erro do servidor';
            } else {
              message = 'Erro do servidor: ${e.response!.statusCode}';
            }
          } catch (_) {
            message = 'Erro do servidor: ${e.response!.statusCode}';
          }
        } else {
          message = 'Erro do servidor: ${e.response!.statusCode}';
        }
        break;

      case DioExceptionType.connectionError:
        message = 'Erro de conexão. Verifique sua internet.';
        break;

      case DioExceptionType.cancel:
        message = 'Requisição cancelada.';
        break;

      default:
        message = 'Erro inesperado: ${e.message}';
        break;
    }

    return ApiResponse.error(
      message: message,
      statusCode: statusCode,
      error: e,
    );
  }

  /// Verifica se está autenticado
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Obtém o token atual
  String? get currentToken => _token;

  /// Define um novo token
  void setToken(String token) {
    _token = token;
    _saveTokenToStorage(token);
  }

  /// Remove o token
  void clearToken() {
    _removeTokenFromStorage();
  }
}