import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../contants/constants.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success({String? message, dynamic data, int? statusCode}) {
    return ApiResponse(
      success: true,
      message: message ?? 'Operação realizada com sucesso',
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({String? message, int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message ?? 'Erro na operação',
      statusCode: statusCode,
    );
  }
}

class ApiService {
  static const String _baseUrl = AppConstants.apiBaseUrl;
  static const int _timeoutDuration = 30;
  
  // Headers padrão
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers com autenticação
  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Salvar token de autenticação
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Obter token de autenticação
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Remover token de autenticação
  static Future<void> removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Verificar se está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Método auxiliar para fazer requisições HTTP
  static Future<ApiResponse> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final headers = requireAuth 
          ? await _getAuthHeaders()
          : _defaultHeaders;

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers)
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: _timeoutDuration));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers)
              .timeout(const Duration(seconds: _timeoutDuration));
          break;
        default:
          return ApiResponse.error(message: 'Método HTTP não suportado: $method');
      }

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error(
        message: 'Tempo limite excedido. Verifique sua conexão.',
        statusCode: 408,
      );
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro inesperado: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Tratar resposta HTTP
  static ApiResponse _handleResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          message: responseData['message'] ?? 'Sucesso',
          data: responseData,
          statusCode: response.statusCode,
        );
      } else {
        String errorMessage = 'Erro na requisição';
        
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 
                        responseData['error'] ?? 
                        responseData['detail'] ?? 
                        'Erro na requisição';
        }
        
        return ApiResponse.error(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao processar resposta: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // ============ AUTENTICAÇÃO ============

  /// Login do usuário
  static Future<ApiResponse> login(String username, String password) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/auth/login/',
        body: {
          'username': username,
          'password': password,
        },
        requireAuth: false,
      );

      if (response.success && response.data != null) {
        final token = response.data['token'] ?? response.data['access'];
        if (token != null) {
          await saveAuthToken(token);
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro no login: ${e.toString()}',
      );
    }
  }

  /// Logout do usuário
  static Future<ApiResponse> logout() async {
    try {
      final response = await _makeRequest('POST', '/auth/logout/');
      await removeAuthToken();
      return response;
    } catch (e) {
      // Mesmo com erro, remove o token local
      await removeAuthToken();
      return ApiResponse.error(
        message: 'Erro no logout: ${e.toString()}',
      );
    }
  }

  /// Obter perfil do usuário
  static Future<ApiResponse> getUserProfile() async {
    try {
      return await _makeRequest('GET', '/auth/user/');
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao obter perfil: ${e.toString()}',
      );
    }
  }

  /// Verificar token
  static Future<ApiResponse> verifyToken() async {
    try {
      return await _makeRequest('POST', '/auth/verify/');
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao verificar token: ${e.toString()}',
      );
    }
  }

  // ============ RESPONSÁVEIS ============

  /// Listar responsáveis
  static Future<ApiResponse> getResponsaveis({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      return await _makeRequest(
        'GET',
        '/cadastro/api/responsaveis/',
        queryParams: queryParams,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao listar responsáveis: ${e.toString()}',
      );
    }
  }

  /// Buscar responsável por CPF
  static Future<ApiResponse> getResponsavelByCpf(String cpf) async {
    try {
      return await _makeRequest(
        'GET',
        '/cadastro/api/responsaveis/$cpf/',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar responsável: ${e.toString()}',
      );
    }
  }

  /// Criar responsável
  static Future<ApiResponse> createResponsavel(Map<String, dynamic> data) async {
    try {
      return await _makeRequest(
        'POST',
        '/cadastro/api/responsaveis/',
        body: data,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao criar responsável: ${e.toString()}',
      );
    }
  }

  /// Atualizar responsável
  static Future<ApiResponse> updateResponsavel(String cpf, Map<String, dynamic> data) async {
    try {
      return await _makeRequest(
        'PUT',
        '/cadastro/api/responsaveis/$cpf/',
        body: data,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao atualizar responsável: ${e.toString()}',
      );
    }
  }

  /// Buscar responsável com membros
  static Future<ApiResponse> getResponsavelComMembros(String cpf) async {
    try {
      return await _makeRequest(
        'GET',
        '/cadastro/api/responsaveis/$cpf/com_membros/',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar responsável com membros: ${e.toString()}',
      );
    }
  }

  // ============ MEMBROS ============

  /// Listar membros
  static Future<ApiResponse> getMembros({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? cpfResponsavel,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (cpfResponsavel != null && cpfResponsavel.isNotEmpty) {
        queryParams['cpf_responsavel'] = cpfResponsavel;
      }

      return await _makeRequest(
        'GET',
        '/cadastro/api/membros/',
        queryParams: queryParams,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao listar membros: ${e.toString()}',
      );
    }
  }

  /// Criar membro
  static Future<ApiResponse> createMembro(Map<String, dynamic> data) async {
    try {
      return await _makeRequest(
        'POST',
        '/cadastro/api/membros/',
        body: data,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao criar membro: ${e.toString()}',
      );
    }
  }

  // ============ DEMANDAS ============

  /// Listar demandas de saúde
  static Future<ApiResponse> getDemandasSaude({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      return await _makeRequest(
        'GET',
        '/cadastro/api/demandas-saude/',
        queryParams: queryParams,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao listar demandas de saúde: ${e.toString()}',
      );
    }
  }

  /// Listar demandas de educação
  static Future<ApiResponse> getDemandasEducacao({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      return await _makeRequest(
        'GET',
        '/cadastro/api/demandas-educacao/',
        queryParams: queryParams,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao listar demandas de educação: ${e.toString()}',
      );
    }
  }

  /// Listar grupos prioritários
  static Future<ApiResponse> getGruposPrioritarios() async {
    try {
      return await _makeRequest(
        'GET',
        '/cadastro/api/demandas-saude/grupos_prioritarios/',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao listar grupos prioritários: ${e.toString()}',
      );
    }
  }

  // ============ UTILIDADES ============

  /// Buscar CEP
  static Future<ApiResponse> buscarCep(String cep) async {
    try {
      // Remove formatação do CEP
      final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cepLimpo.length != 8) {
        return ApiResponse.error(
          message: 'CEP deve ter 8 dígitos',
        );
      }

      // Usar API ViaCEP
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['erro'] == true) {
          return ApiResponse.error(
            message: 'CEP não encontrado',
            statusCode: 404,
          );
        }
        
        return ApiResponse.success(
          message: 'CEP encontrado',
          data: data,
        );
      } else {
        return ApiResponse.error(
          message: 'Erro ao buscar CEP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao buscar CEP: ${e.toString()}',
      );
    }
  }

  /// Verificar conectividade
  static Future<ApiResponse> checkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health/'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Conectado',
          data: {'connected': true},
        );
      } else {
        return ApiResponse.error(
          message: 'Servidor indisponível',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Sem conexão com o servidor',
        statusCode: 0,
      );
    }
  }

  // ============ ESTATÍSTICAS ============

  /// Obter estatísticas do dashboard
  static Future<ApiResponse> getDashboardStats() async {
    try {
      return await _makeRequest('GET', '/api/v1/dashboard/stats/');
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro ao obter estatísticas: ${e.toString()}',
      );
    }
  }
}