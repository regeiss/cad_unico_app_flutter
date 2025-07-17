// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contants/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;
  String? _refreshToken;

  // ==========================================================================
  // INICIALIZAÇÃO
  // ==========================================================================

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(seconds: AppConstants.timeoutDuration),
      receiveTimeout: Duration(seconds: AppConstants.timeoutDuration),
      sendTimeout: Duration(seconds: AppConstants.timeoutDuration),
      headers: AppConstants.defaultHeaders,
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Interceptor para adicionar token automaticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adicionar token se disponível
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          // Log da requisição em modo debug
          if (AppConstants.enableLogRequests && kDebugMode) {
            debugPrint('🚀 REQUEST: ${options.method} ${options.uri}');
            debugPrint('🚀 HEADERS: ${options.headers}');
            if (options.data != null) {
              debugPrint('🚀 DATA: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log da resposta em modo debug
          if (AppConstants.enableLogResponses && kDebugMode) {
            debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            debugPrint('✅ DATA: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('❌ ERROR: ${error.requestOptions.uri}');
          debugPrint('❌ MESSAGE: ${error.message}');
          debugPrint('❌ RESPONSE: ${error.response?.data}');

          // Tentar renovar token se erro 401
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            final success = await _refreshAuthToken();
            if (success) {
              // Repetir a requisição original com novo token
              final originalRequest = error.requestOptions;
              originalRequest.headers['Authorization'] = 'Bearer $_authToken';
              
              try {
                final response = await _dio.request(
                  originalRequest.path,
                  options: Options(
                    method: originalRequest.method,
                    headers: originalRequest.headers,
                  ),
                  data: originalRequest.data,
                  queryParameters: originalRequest.queryParameters,
                );
                handler.resolve(response);
                return;
              } catch (e) {
                // Se falhar novamente, prosseguir com o erro original
              }
            } else {
              // Se não conseguir renovar, limpar tokens e redirecionar para login
              await _clearAuthData();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  // ==========================================================================
  // GESTÃO DE AUTENTICAÇÃO
  // ==========================================================================

  Future<void> setAuthToken(String token, String refreshToken) async {
    _authToken = token;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<void> loadSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.tokenKey);
    _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post(
        AppConstants.authRefresh.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: {'refresh': _refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _authToken = data['access'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, _authToken!);
        
        return true;
      }
    }on Exception catch (e) {
      debugPrint('Erro ao renovar token: $e');
    }
    
    return false;
  }

  Future<void> _clearAuthData() async {
    _authToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  bool get isAuthenticated => _authToken != null;

  // ==========================================================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ==========================================================================

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.authLogin.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Salvar tokens
        await setAuthToken(data['access'], data['refresh']);
        
        // Salvar dados do usuário
        if (data['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.userDataKey, jsonEncode(data['user']));
        }

        return {'success': true, 'data': data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.networkError,
        'error': e.toString(),
      };
    }

    return {'success': false, 'message': AppConstants.loginError};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        AppConstants.authRegister.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: userData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } on Exception catch (e) {
      return {
        'success': false,
        'message': 'Erro ao criar conta',
        'error': e.toString(),
      };
    }

    return {'success': false, 'message': 'Erro ao criar conta'};
  }

  Future<Map<String, dynamic>> verifyToken() async {
    if (_authToken == null) {
      return {'success': false, 'message': 'Token não encontrado'};
    }

    try {
      final response = await _dio.post(
        AppConstants.authVerify.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: {'token': _authToken},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } on Exception catch (e) {
      return {
        'success': false,
        'message': 'Erro ao verificar token',
        'error': e.toString(),
      };
    }

    return {'success': false, 'message': 'Token inválido'};
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        AppConstants.authRefresh.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _authToken = data['access'];
        
        // Atualizar token salvo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, _authToken!);
        
        return {'success': true, 'data': data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } on Exception catch (e) {
      return {
        'success': false,
        'message': 'Erro ao renovar token',
        'error': e.toString(),
      };
    }

    return {'success': false, 'message': 'Não foi possível renovar o token'};
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(
        AppConstants.authProfile.replaceFirst(AppConstants.apiBaseUrl, ''),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar perfil'};
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        AppConstants.authProfile.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: data,
      );

      if (response.statusCode == 200) {
        // Atualizar dados do usuário salvos
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userDataKey, jsonEncode(response.data));
        
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao atualizar perfil'};
  }

  Future<Map<String, dynamic>> changePassword({
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
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao alterar senha'};
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      if (_refreshToken != null) {
        await _dio.post(
          AppConstants.authLogout.replaceFirst(AppConstants.apiBaseUrl, ''),
          data: {'refresh': _refreshToken},
        );
      }
    } on Exception catch (e) {
      debugPrint('Erro no logout: $e');
    } finally {
      await _clearAuthData();
    }

    return {'success': true, 'message': AppConstants.logoutSuccess};
  }

  // ==========================================================================
  // MÉTODOS PARA RESPONSÁVEIS
  // ==========================================================================

  Future<Map<String, dynamic>> getResponsaveis({
    int page = 1,
    String? search,
    String? status,
    String? ordering,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }
      if (ordering != null && ordering.isNotEmpty) {
        queryParameters['ordering'] = ordering;
      }

      final response = await _dio.get(
        AppConstants.responsaveisEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar responsáveis'};
  }

  Future<Map<String, dynamic>> getResponsavelByCpf(String cpf) async {
    try {
      final response = await _dio.get(
        AppConstants.getResponsavelByCpfUrl(cpf).replaceFirst(AppConstants.apiBaseUrl, ''),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Responsável não encontrado'};
  }

  Future<Map<String, dynamic>> getResponsavelComMembros(String cpf) async {
    try {
      final response = await _dio.get(
        AppConstants.getResponsavelComMembrosUrl(cpf).replaceFirst(AppConstants.apiBaseUrl, ''),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar dados do responsável'};
  }

  Future<Map<String, dynamic>> createResponsavel(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.responsaveisEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: data,
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': AppConstants.responsavelCreatedSuccess,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao criar responsável'};
  }

  Future<Map<String, dynamic>> updateResponsavel(String cpf, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        AppConstants.getResponsavelByCpfUrl(cpf).replaceFirst(AppConstants.apiBaseUrl, ''),
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': AppConstants.responsavelUpdatedSuccess,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao atualizar responsável'};
  }

  // ==========================================================================
  // MÉTODOS PARA MEMBROS
  // ==========================================================================

  Future<Map<String, dynamic>> getMembros({
    int page = 1,
    String? search,
    String? status,
    String? cpfResponsavel,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }
      if (cpfResponsavel != null && cpfResponsavel.isNotEmpty) {
        queryParameters['cpf_responsavel'] = cpfResponsavel;
      }

      final response = await _dio.get(
        AppConstants.membrosEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar membros'};
  }

  Future<Map<String, dynamic>> createMembro(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppConstants.membrosEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
        data: data,
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': AppConstants.membroCreatedSuccess,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao criar membro'};
  }

  // ==========================================================================
  // MÉTODOS PARA DEMANDAS DE SAÚDE
  // ==========================================================================

  Future<Map<String, dynamic>> getDemandasSaude({
    int page = 1,
    String? search,
    String? genero,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (genero != null && genero.isNotEmpty) {
        queryParameters['genero'] = genero;
      }

      final response = await _dio.get(
        AppConstants.demandasSaudeEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar demandas de saúde'};
  }

  Future<Map<String, dynamic>> getGruposPrioritarios() async {
    try {
      final response = await _dio.get(
        '${AppConstants.demandasSaudeEndpoint.replaceFirst(AppConstants.apiBaseUrl, '')}grupos_prioritarios/',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar grupos prioritários'};
  }

  // ==========================================================================
  // MÉTODOS PARA DEMANDAS DE EDUCAÇÃO
  // ==========================================================================

  Future<Map<String, dynamic>> getDemandasEducacao({
    int page = 1,
    String? search,
    String? turno,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (turno != null && turno.isNotEmpty) {
        queryParameters['turno'] = turno;
      }

      final response = await _dio.get(
        AppConstants.demandasEducacaoEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }

    return {'success': false, 'message': 'Erro ao carregar demandas de educação'};
  }

  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================

  Future<Map<String, dynamic>> getCepInfo(String cep) async {
    try {
      final cleanCep = cep.replaceAll('-', '').replaceAll('.', '');
      
      final dio = Dio(); // Instância separada para APIs externas
      final response = await dio.get(AppConstants.getViaCepUrl(cleanCep));

      if (response.statusCode == 200 && response.data['erro'] == null) {
        return {'success': true, 'data': response.data};
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
    }

    return {'success': false, 'message': 'CEP não encontrado'};
  }

  Map<String, dynamic> _handleDioError(DioException e) {
    String message = AppConstants.networkError;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.timeoutError;
        break;
      
      case DioExceptionType.badResponse:
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = e.response?.data['message'] ?? 'Requisição inválida';
              break;
            case 401:
              message = AppConstants.accessDeniedError;
              break;
            case 403:
              message = 'Acesso proibido';
              break;
            case 404:
              message = AppConstants.noDataFound;
              break;
            case 422:
              message = e.response?.data['message'] ?? AppConstants.requiredFieldsError;
              break;
            case 500:
              message = AppConstants.serverError;
              break;
            default:
              message = 'Erro HTTP $statusCode';
          }
        }
        break;
      
      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          message = 'Sem conexão com a internet';
        } else {
          message = AppConstants.networkError;
        }
        break;
      
      default:
        message = e.message ?? AppConstants.networkError;
    }

    return {
      'success': false,
      'message': message,
      'statusCode': statusCode,
      'error': e.toString(),
    };
  }

  // ==========================================================================
  // MÉTODOS DE LIMPEZA
  // ==========================================================================

  void dispose() {
    _dio.close();
  }
}