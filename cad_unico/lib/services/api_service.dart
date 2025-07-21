import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../contants/constants.dart';

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  // Initialize Dio
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }

    // Add error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Get Dio instance (initialize if not done)
  Dio get dio {
    try {
      // Test if _dio is initialized
      _dio.options;
      return _dio;
    } catch (e) {
      init();
      return _dio;
    }
  }

  // Handle API response
  ApiResponse _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return ApiResponse(
        success: true,
        data: response.data,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: response.data?['message'] ?? 'Erro na requisição',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle API error
  ApiResponse _handleError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Tempo limite excedido. Tente novamente.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          message = 'Acesso negado. Faça login novamente.';
        } else if (statusCode == 403) {
          message = 'Você não tem permissão para esta ação.';
        } else if (statusCode == 404) {
          message = 'Recurso não encontrado.';
        } else if (statusCode == 500) {
          message = 'Erro interno do servidor.';
        } else {
          message = error.response?.data?['message'] ??
              'Erro na requisição (${statusCode})';
        }
        break;
      case DioExceptionType.connectionError:
        message = 'Erro de conexão. Verifique sua internet.';
        break;
      case DioExceptionType.cancel:
        message = 'Requisição cancelada.';
        break;
      default:
        message = 'Erro inesperado. Tente novamente.';
    }

    return ApiResponse(
      success: false,
      message: message,
      statusCode: error.response?.statusCode,
    );
  }

  // Login
  Future<ApiResponse> login(String username, String password) async {
    try {
      final response = await dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro inesperado: $e',
      );
    }
  }

  // Logout
  Future<ApiResponse> logout(String? refreshToken) async {
    try {
      final data = refreshToken != null ? {'refresh': refreshToken} : null;
      final response = await dio.post('/auth/logout/', data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao fazer logout: $e',
      );
    }
  }

  // Refresh token
  Future<ApiResponse> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post('/auth/refresh/', data: {
        'refresh': refreshToken,
      });

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao renovar token: $e',
      );
    }
  }

  // Verify token
  Future<ApiResponse> verifyToken(String token) async {
    try {
      final response = await dio.post('/auth/verify/', data: {
        'token': token,
      });

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao verificar token: $e',
      );
    }
  }

  // Get user profile
  Future<ApiResponse> getUserProfile(String token) async {
    try {
      final response = await dio.get(
        '/auth/profile/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao obter perfil: $e',
      );
    }
  }

  // Update profile
  Future<ApiResponse> updateProfile(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '/auth/profile/',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao atualizar perfil: $e',
      );
    }
  }

  // Change password
  Future<ApiResponse> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await dio.post(
        '/auth/change-password/',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao alterar senha: $e',
      );
    }
  }

  // Get responsaveis
  Future<ApiResponse> getResponsaveis({
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.get(
        '/cadastro/api/responsaveis/',
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao obter responsáveis: $e',
      );
    }
  }

  // Get responsavel by CPF
  Future<ApiResponse> getResponsavelByCpf(String cpf, {String? token}) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.get(
        '/cadastro/api/responsaveis/$cpf/',
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao obter responsável: $e',
      );
    }
  }

  // Create responsavel
  Future<ApiResponse> createResponsavel(
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.post(
        '/cadastro/api/responsaveis/',
        data: data,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao criar responsável: $e',
      );
    }
  }

  // Update responsavel
  Future<ApiResponse> updateResponsavel(
    String cpf,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.put(
        '/cadastro/api/responsaveis/$cpf/',
        data: data,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao atualizar responsável: $e',
      );
    }
  }

  // Get membros
  Future<ApiResponse> getMembros({
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.get(
        '/cadastro/api/membros/',
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao obter membros: $e',
      );
    }
  }

  // Get demandas
  Future<ApiResponse> getDemandas(
    String type, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.get(
        '/cadastro/api/demandas-$type/',
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro ao obter demandas: $e',
      );
    }
  }

  // Generic GET request
  Future<ApiResponse> get(
    String endpoint, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro na requisição: $e',
      );
    }
  }

  // Generic POST request
  Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.post(
        endpoint,
        data: data,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro na requisição: $e',
      );
    }
  }

  // Generic PUT request
  Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.put(
        endpoint,
        data: data,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro na requisição: $e',
      );
    }
  }

  // Generic DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await dio.delete(
        endpoint,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro na requisição: $e',
      );
    }
  }
}

// // lib/services/api_service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../contants/constants.dart';

// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();

//   late Dio _dio;
//   String? _authToken;
//   String? _refreshToken;

//   // ==========================================================================
//   // INICIALIZAÇÃO
//   // ==========================================================================

//   void init() {
//     _dio = Dio(BaseOptions(
//       baseUrl: AppConstants.apiBaseUrl,
//       connectTimeout: Duration(seconds: AppConstants.timeoutDuration),
//       receiveTimeout: Duration(seconds: AppConstants.timeoutDuration),
//       sendTimeout: Duration(seconds: AppConstants.timeoutDuration),
//       headers: AppConstants.defaultHeaders,
//     ));

//     _setupInterceptors();
//   }

//   void _setupInterceptors() {
//     // Interceptor para adicionar token automaticamente
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Adicionar token se disponível
//           if (_authToken != null) {
//             options.headers['Authorization'] = 'Bearer $_authToken';
//           }

//           // Log da requisição em modo debug
//           if (AppConstants.enableLogRequests && kDebugMode) {
//             debugPrint('🚀 REQUEST: ${options.method} ${options.uri}');
//             debugPrint('🚀 HEADERS: ${options.headers}');
//             if (options.data != null) {
//               debugPrint('🚀 DATA: ${options.data}');
//             }
//           }

//           handler.next(options);
//         },
//         onResponse: (response, handler) {
//           // Log da resposta em modo debug
//           if (AppConstants.enableLogResponses && kDebugMode) {
//             debugPrint(
//                 '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
//             debugPrint('✅ DATA: ${response.data}');
//           }
//           handler.next(response);
//         },
//         onError: (error, handler) async {
//           debugPrint('❌ ERROR: ${error.requestOptions.uri}');
//           debugPrint('❌ MESSAGE: ${error.message}');
//           debugPrint('❌ RESPONSE: ${error.response?.data}');

//           // Tentar renovar token se erro 401
//           if (error.response?.statusCode == 401 && _refreshToken != null) {
//             final success = await _refreshAuthToken();
//             if (success) {
//               // Repetir a requisição original com novo token
//               final originalRequest = error.requestOptions;
//               originalRequest.headers['Authorization'] = 'Bearer $_authToken';

//               try {
//                 final response = await _dio.request(
//                   originalRequest.path,
//                   options: Options(
//                     method: originalRequest.method,
//                     headers: originalRequest.headers,
//                   ),
//                   data: originalRequest.data,
//                   queryParameters: originalRequest.queryParameters,
//                 );
//                 handler.resolve(response);
//                 return;
//               } on Exception {
//                 // Se falhar novamente, prosseguir com o erro original
//               }
//             } else {
//               // Se não conseguir renovar, limpar tokens e redirecionar para login
//               await _clearAuthData();
//             }
//           }

//           handler.next(error);
//         },
//       ),
//     );
//   }

//   // ==========================================================================
//   // GESTÃO DE AUTENTICAÇÃO
//   // ==========================================================================

//   Future<void> setAuthToken(String token, String refreshToken) async {
//     _authToken = token;
//     _refreshToken = refreshToken;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(AppConstants.tokenKey, token);
//     await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
//   }

//   Future<void> loadSavedTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     _authToken = prefs.getString(AppConstants.tokenKey);
//     _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
//   }

//   Future<bool> _refreshAuthToken() async {
//     if (_refreshToken == null) return false;

//     try {
//       final response = await _dio.post(
//         AppConstants.authRefresh.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: {'refresh': _refreshToken},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         _authToken = data['access'];

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(AppConstants.tokenKey, _authToken!);

//         return true;
//       }
//     } on Exception catch (e) {
//       debugPrint('Erro ao renovar token: $e');
//     }

//     return false;
//   }

//   Future<void> _clearAuthData() async {
//     _authToken = null;
//     _refreshToken = null;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(AppConstants.tokenKey);
//     await prefs.remove(AppConstants.refreshTokenKey);
//     await prefs.remove(AppConstants.userDataKey);
//   }

//   bool get isAuthenticated => _authToken != null;

//   // ==========================================================================
//   // MÉTODOS DE AUTENTICAÇÃO
//   // ==========================================================================

//   Future<Map<String, dynamic>> login(String username, String password) async {
//     try {
//       final response = await _dio.post(
//         AppConstants.authLogin.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: {
//           'username': username,
//           'password': password,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;

//         // Salvar tokens
//         await setAuthToken(data['access'], data['refresh']);

//         // Salvar dados do usuário
//         if (data['user'] != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(
//               AppConstants.userDataKey, jsonEncode(data['user']));
//         }

//         return {'success': true, 'data': data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } on Exception catch (e) {
//       return {
//         'success': false,
//         'message': AppConstants.networkError,
//         'error': e.toString(),
//       };
//     }
//     return {'success': false, 'message': AppConstants.loginError};
//   }

//   Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
//     try {
//       final response = await _dio.post(
//         AppConstants.authRegister.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: userData,
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } on Exception catch (e) {
//       return {
//         'success': false,
//         'message': 'Erro ao criar conta',
//         'error': e.toString(),
//       };
//     }

//     return {'success': false, 'message': 'Erro ao criar conta'};
//   }

//   Future<Map<String, dynamic>> verifyToken() async {
//     if (_authToken == null) {
//       return {'success': false, 'message': 'Token não encontrado'};
//     }

//     try {
//       final response = await _dio.post(
//         AppConstants.authVerify.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: {'token': _authToken},
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } on Exception catch (e) {
//       return {
//         'success': false,
//         'message': 'Erro ao verificar token',
//         'error': e.toString(),
//       };
//     }

//     return {'success': false, 'message': 'Token inválido'};
//   }

//   Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
//     try {
//       final response = await _dio.post(
//         AppConstants.authRefresh.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: {'refresh': refreshToken},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         _authToken = data['access'];

//         // Atualizar token salvo
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(AppConstants.tokenKey, _authToken!);

//         return {'success': true, 'data': data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } on Exception catch (e) {
//       return {
//         'success': false,
//         'message': 'Erro ao renovar token',
//         'error': e.toString(),
//       };
//     }

//     return {'success': false, 'message': 'Não foi possível renovar o token'};
//   }

//   Future<Map<String, dynamic>> getUserProfile() async {
//     try {
//       final response = await _dio.get(
//         AppConstants.authProfile.replaceFirst(AppConstants.apiBaseUrl, ''),
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao carregar perfil'};
//   }

//   Future<Map<String, dynamic>> updateUserProfile(
//       Map<String, dynamic> data) async {
//     try {
//       final response = await _dio.put(
//         AppConstants.authProfile.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: data,
//       );

//       if (response.statusCode == 200) {
//         // Atualizar dados do usuário salvos
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(
//             AppConstants.userDataKey, jsonEncode(response.data));

//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao atualizar perfil'};
//   }

//   Future<Map<String, dynamic>> changePassword({
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/change-password/',
//         data: {
//           'current_password': currentPassword,
//           'new_password': newPassword,
//         },
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao alterar senha'};
//   }

//   Future<Map<String, dynamic>> logout() async {
//     try {
//       if (_refreshToken != null) {
//         await _dio.post(
//           AppConstants.authLogout.replaceFirst(AppConstants.apiBaseUrl, ''),
//           data: {'refresh': _refreshToken},
//         );
//       }
//     } on Exception catch (e) {
//       debugPrint('Erro no logout: $e');
//     } finally {
//       await _clearAuthData();
//     }

//     return {'success': true, 'message': AppConstants.logoutSuccess};
//   }

//   // ==========================================================================
//   // MÉTODOS PARA RESPONSÁVEIS
//   // ==========================================================================

//   // Metodo tampao para eviter erros - deve ser removido quando a API estiver pronta
//   Future<Map<String, dynamic>> get({
//     int page = 1,
//     String? search,
//     String? status,
//     String? ordering,
//     required Map<String, dynamic> filters,
//   }) async {
//     try {
//       final queryParameters = <String, dynamic>{
//         'page': page,
//         'page_size': AppConstants.pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParameters['search'] = search;
//       }
//       if (status != null && status.isNotEmpty) {
//         queryParameters['status'] = status;
//       }
//       if (ordering != null && ordering.isNotEmpty) {
//         queryParameters['ordering'] = ordering;
//       }

//       final response = await _dio.get(
//         AppConstants.responsaveisEndpoint
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//         queryParameters: queryParameters,
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao carregar responsáveis'};
//   }

//   Future<Map<String, dynamic>> getResponsavel(String cpf) async {
//     try {
//       if (_authToken == null) {
//         await loadSavedTokens();
//         if (_authToken == null) {
//           throw ApiException(
//               'Token de autenticação não encontrado. Faça login novamente.',
//               statusCode: 401);
//         }
//       }

//       final response = await _dio.get(
//         '/cadastro/api/responsaveis/$cpf/',
//         options: Options(
//           headers: _getAuthHeaders(
//               _authToken!), // Now _authToken is guaranteed non-null
//         ),
//       );

//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw ApiException(
//           'Erro ao buscar responsável',
//           statusCode: response.statusCode,
//         );
//       }
//     } on DioException catch (e) {
//       // ... your existing DioError handling
//       if (e.response?.statusCode == 404) {
//         throw ApiException(
//           'Responsável não encontrado',
//           statusCode: 404,
//         );
//       } else if (e.response?.statusCode == 401) {
//         throw ApiException(
//           'Não autorizado. Faça login novamente.',
//           statusCode: 401,
//         );
//       } else {
//         throw ApiException(
//           e.response?.data['message'] ?? 'Erro ao buscar responsável',
//           statusCode: e.response?.statusCode,
//         );
//       }
//     } catch (e) {
//       if (e is ApiException) {
//         rethrow;
//       }
//       throw ApiException('Erro de conexão: ${e.toString()}');
//     }
//   }

//   /// Busca um responsável com seus membros
//   Future<Map<String, dynamic>> getResponsavelComMembros(String cpf) async {
//     try {
//       // Rely on the *current instance's* _authToken.
//       // Ensure `loadSavedTokens()` is called once at app startup
//       // or immediately after `setAuthToken` is called after login/refresh.
//       if (_authToken == null) {
//         // It's possible the _authToken isn't loaded yet on first run.
//         // Let's try loading it from preferences if it's null.
//         await loadSavedTokens();
//         if (_authToken == null) {
//           throw ApiException(
//               'Token de autenticação não encontrado. Faça login novamente.',
//               statusCode: 401);
//         }
//       }

//       final response = await _dio.get(
//         '/cadastro/api/responsaveis/$cpf/',
//         options: Options(
//           headers: _getAuthHeaders(
//               _authToken!), // Now _authToken is guaranteed non-null
//         ),
//       );

//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw ApiException(
//           'Erro ao buscar responsável com membros',
//           statusCode: response.statusCode,
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 404) {
//         throw ApiException(
//           'Responsável não encontrado',
//           statusCode: 404,
//         );
//       } else if (e.response?.statusCode == 401) {
//         throw ApiException(
//           'Não autorizado. Faça login novamente.',
//           statusCode: 401,
//         );
//       } else {
//         throw ApiException(
//           e.response?.data['message'] ??
//               'Erro ao buscar responsável com membros',
//           statusCode: e.response?.statusCode,
//         );
//       }
//     } catch (e) {
//       throw ApiException('Erro de conexão: ${e.toString()}');
//     }
//   }

//   /// Busca um responsável com todas as demandas associadas
//   Future<Map<String, dynamic>> getResponsavelComDemandas(String cpf) async {
//     try {
//       // Rely on the *current instance's* _authToken.
//       // Ensure `loadSavedTokens()` is called once at app startup
//       // or immediately after `setAuthToken` is called after login/refresh.
//       if (_authToken == null) {
//         // It's possible the _authToken isn't loaded yet on first run.
//         // Let's try loading it from preferences if it's null.
//         await loadSavedTokens();
//         if (_authToken == null) {
//           throw ApiException(
//               'Token de autenticação não encontrado. Faça login novamente.',
//               statusCode: 401);
//         }
//       }

//       final response = await _dio.get(
//         '/cadastro/api/responsaveis/$cpf/',
//         options: Options(
//           headers: _getAuthHeaders(
//               _authToken!), // Now _authToken is guaranteed non-null
//         ),
//       );

//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw ApiException(
//           'Erro ao buscar responsável com demandas',
//           statusCode: response.statusCode,
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 404) {
//         throw ApiException(
//           'Responsável não encontrado',
//           statusCode: 404,
//         );
//       } else if (e.response?.statusCode == 401) {
//         throw ApiException(
//           'Não autorizado. Faça login novamente.',
//           statusCode: 401,
//         );
//       } else {
//         throw ApiException(
//           e.response?.data['message'] ??
//               'Erro ao buscar responsável com demandas',
//           statusCode: e.response?.statusCode,
//         );
//       }
//     } catch (e) {
//       throw ApiException('Erro de conexão: ${e.toString()}');
//     }
//   }

//   /// Busca responsável por CPF usando query parameter
//   Future<Map<String, dynamic>> buscarResponsavelPorCpf(String cpf) async {
//     try {
//       // Rely on the *current instance's* _authToken.
//       // Ensure `loadSavedTokens()` is called once at app startup
//       // or immediately after `setAuthToken` is called after login/refresh.
//       if (_authToken == null) {
//         // It's possible the _authToken isn't loaded yet on first run.
//         // Let's try loading it from preferences if it's null.
//         await loadSavedTokens();
//         if (_authToken == null) {
//           throw ApiException(
//               'Token de autenticação não encontrado. Faça login novamente.',
//               statusCode: 401);
//         }
//       }

//       final response = await _dio.get(
//         '/cadastro/api/responsaveis/$cpf/',
//         options: Options(
//           headers: _getAuthHeaders(
//               _authToken!), // Now _authToken is guaranteed non-null
//         ),
//       );

//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw ApiException(
//           'Erro ao buscar responsável por CPF',
//           statusCode: response.statusCode,
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 404) {
//         throw ApiException(
//           'Responsável não encontrado',
//           statusCode: 404,
//         );
//       } else if (e.response?.statusCode == 400) {
//         throw ApiException(
//           e.response?.data['detail'] ?? 'CPF inválido',
//           statusCode: 400,
//         );
//       } else if (e.response?.statusCode == 401) {
//         throw ApiException(
//           'Não autorizado. Faça login novamente.',
//           statusCode: 401,
//         );
//       } else {
//         throw ApiException(
//           e.response?.data['detail'] ?? 'Erro ao buscar responsável',
//           statusCode: e.response?.statusCode,
//         );
//       }
//     } catch (e) {
//       throw ApiException('Erro de conexão: ${e.toString()}');
//     }
//   }

//   Future<Map<String, dynamic>> getResponsaveis({
//     int page = 1,
//     String? search,
//     String? status,
//     String? ordering,
//     required Map<String, dynamic> filters,
//   }) async {
//     try {
//       final queryParameters = <String, dynamic>{
//         'page': page,
//         'page_size': AppConstants.pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParameters['search'] = search;
//       }
//       if (status != null && status.isNotEmpty) {
//         queryParameters['status'] = status;
//       }
//       if (ordering != null && ordering.isNotEmpty) {
//         queryParameters['ordering'] = ordering;
//       }

//       final response = await _dio.get(
//         AppConstants.responsaveisEndpoint
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//         queryParameters: queryParameters,
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao carregar responsáveis'};
//   }

//   Future<Map<String, dynamic>> getResponsavelByCpf(String cpf) async {
//     try {
//       final response = await _dio.get(
//         AppConstants.getResponsavelByCpfUrl(cpf)
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Responsável não encontrado'};
//   }

//   // Future<Map<String, dynamic>> getResponsavelComMembros(String cpf) async {
//   //   try {
//   //     final response = await _dio.get(
//   //       AppConstants.getResponsavelComMembrosUrl(cpf).replaceFirst(AppConstants.apiBaseUrl, ''),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       return {'success': true, 'data': response.data};
//   //     }
//   //   } on DioException catch (e) {
//   //     return _handleDioError(e);
//   //   }

//   //   return {'success': false, 'message': 'Erro ao carregar dados do responsável'};
//   // }

//   Future<Map<String, dynamic>> createResponsavel(
//       Map<String, dynamic> data) async {
//     try {
//       final response = await _dio.post(
//         AppConstants.responsaveisEndpoint
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: data,
//       );

//       if (response.statusCode == 201) {
//         return {
//           'success': true,
//           'data': response.data,
//           'message': AppConstants.responsavelCreatedSuccess,
//         };
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao criar responsável'};
//   }

//   Future<Map<String, dynamic>> updateResponsavel(
//       String cpf, Map<String, dynamic> data) async {
//     try {
//       final response = await _dio.put(
//         AppConstants.getResponsavelByCpfUrl(cpf)
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: data,
//       );

//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'data': response.data,
//           'message': AppConstants.responsavelUpdatedSuccess,
//         };
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao atualizar responsável'};
//   }

//   // ==========================================================================
//   // MÉTODOS PARA MEMBROS
//   // ==========================================================================

//   Future<Map<String, dynamic>> getMembros({
//     int page = 1,
//     String? search,
//     String? status,
//     String? cpfResponsavel,
//     required Map<String, dynamic> filters,
//   }) async {
//     try {
//       final queryParameters = <String, dynamic>{
//         'page': page,
//         'page_size': AppConstants.pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParameters['search'] = search;
//       }
//       if (status != null && status.isNotEmpty) {
//         queryParameters['status'] = status;
//       }
//       if (cpfResponsavel != null && cpfResponsavel.isNotEmpty) {
//         queryParameters['cpf_responsavel'] = cpfResponsavel;
//       }

//       final response = await _dio.get(
//         AppConstants.membrosEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
//         queryParameters: queryParameters,
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao carregar membros'};
//   }

//   Future<Map<String, dynamic>> createMembro(Map<String, dynamic> data) async {
//     try {
//       final response = await _dio.post(
//         AppConstants.membrosEndpoint.replaceFirst(AppConstants.apiBaseUrl, ''),
//         data: data,
//       );

//       if (response.statusCode == 201) {
//         return {
//           'success': true,
//           'data': response.data,
//           'message': AppConstants.membroCreatedSuccess,
//         };
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao criar membro'};
//   }

//   // ==========================================================================
//   // MÉTODOS PARA DEMANDAS DE SAÚDE
//   // ==========================================================================

//   Future<Map<String, dynamic>> getDemandasSaude({
//     int page = 1,
//     String? search,
//     String? genero,
//   }) async {
//     try {
//       final queryParameters = <String, dynamic>{
//         'page': page,
//         'page_size': AppConstants.pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParameters['search'] = search;
//       }
//       if (genero != null && genero.isNotEmpty) {
//         queryParameters['genero'] = genero;
//       }

//       final response = await _dio.get(
//         AppConstants.demandasSaudeEndpoint
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//         queryParameters: queryParameters,
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {'success': false, 'message': 'Erro ao carregar demandas de saúde'};
//   }

//   Future<Map<String, dynamic>> getGruposPrioritarios() async {
//     try {
//       final response = await _dio.get(
//         '${AppConstants.demandasSaudeEndpoint.replaceFirst(AppConstants.apiBaseUrl, '')}grupos_prioritarios/',
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {
//       'success': false,
//       'message': 'Erro ao carregar grupos prioritários'
//     };
//   }

//   // ==========================================================================
//   // MÉTODOS PARA DEMANDAS DE EDUCAÇÃO
//   // ==========================================================================

//   Future<Map<String, dynamic>> getDemandasEducacao({
//     int page = 1,
//     String? search,
//     String? turno,
//   }) async {
//     try {
//       final queryParameters = <String, dynamic>{
//         'page': page,
//         'page_size': AppConstants.pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParameters['search'] = search;
//       }
//       if (turno != null && turno.isNotEmpty) {
//         queryParameters['turno'] = turno;
//       }

//       final response = await _dio.get(
//         AppConstants.demandasEducacaoEndpoint
//             .replaceFirst(AppConstants.apiBaseUrl, ''),
//         queryParameters: queryParameters,
//       );

//       if (response.statusCode == 200) {
//         return {'success': true, 'data': response.data};
//       }
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     }

//     return {
//       'success': false,
//       'message': 'Erro ao carregar demandas de educação'
//     };
//   }

//   // ==========================================================================
//   // MÉTODOS AUXILIARES
//   // ==========================================================================

//   Future<Map<String, dynamic>> getCepInfo(String cep) async {
//     try {
//       final cleanCep = cep.replaceAll('-', '').replaceAll('.', '');

//       final dio = Dio(); // Instância separada para APIs externas
//       final response = await dio.get(AppConstants.getViaCepUrl(cleanCep));

//       if (response.statusCode == 200 && response.data['erro'] == null) {
//         return {'success': true, 'data': response.data};
//       }
//     } catch (e) {
//       debugPrint('Erro ao buscar CEP: $e');
//     }

//     return {'success': false, 'message': 'CEP não encontrado'};
//   }

//   Map<String, dynamic> _handleDioError(DioException e) {
//     String message = AppConstants.networkError;
//     int? statusCode = e.response?.statusCode;

//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         message = AppConstants.timeoutError;
//         break;

//       case DioExceptionType.badResponse:
//         if (statusCode != null) {
//           switch (statusCode) {
//             case 400:
//               message = e.response?.data['message'] ?? 'Requisição inválida';
//               break;
//             case 401:
//               message = AppConstants.accessDeniedError;
//               break;
//             case 403:
//               message = 'Acesso proibido';
//               break;
//             case 404:
//               message = AppConstants.noDataFound;
//               break;
//             case 422:
//               message = e.response?.data['message'] ??
//                   AppConstants.requiredFieldsError;
//               break;
//             case 500:
//               message = AppConstants.serverError;
//               break;
//             default:
//               message = 'Erro HTTP $statusCode';
//           }
//         }
//         break;

//       case DioExceptionType.connectionError:
//         if (e.error is SocketException) {
//           message = 'Sem conexão com a internet';
//         } else {
//           message = AppConstants.networkError;
//         }
//         break;

//       default:
//         message = e.message ?? AppConstants.networkError;
//     }

//     return {
//       'success': false,
//       'message': message,
//       'statusCode': statusCode,
//       'error': e.toString(),
//     };
//   }

//   Map<String, String> _getAuthHeaders(String token) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json', // Keep this if it's a default header as per AppConstants
//     'Authorization': 'Bearer $token',
//   };

//   // ==========================================================================
//   // MÉTODOS DE LIMPEZA
//   // ==========================================================================

//   void dispose() {
//     _dio.close();
//   }
// }

// // Classe de exceção customizada:
// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;

//   ApiException(this.message, {this.statusCode});

//   @override
//   String toString() => message;
// }
