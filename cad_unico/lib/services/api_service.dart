import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://10.13.65.37:8001/api/v1';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  late final Dio _dio;
  String? _authToken;
  String? _refreshToken;
  
  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
    _loadTokens();
  }
  
  void _setupInterceptors() {
    // Request Interceptor - Adiciona token automaticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        if (kDebugMode) {
          print('🔄 ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📤 Request Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ ${response.statusCode} ${response.requestOptions.uri}');
          print('📥 Response: ${response.data}');
        }
        handler.next(response);
      },
      
      onError: (error, handler) async {
        if (kDebugMode) {
          print('❌ Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('❌ Error Data: ${error.response?.data}');
        }
        
        // Auto-renovação de token
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            await refreshToken();
            // Repetir requisição original
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            if (kDebugMode) print('❌ Falha ao renovar token: $e');
            await logout();
          }
        }
        
        handler.next(error);
      },
    ));
  }
  
  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }
  
  Future<void> _saveTokens(String? token, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = token;
    _refreshToken = refreshToken;
    
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
    
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      await prefs.remove(_refreshTokenKey);
    }
  }
  
  // ========== AUTENTICAÇÃO ==========
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['token'], data['refresh']);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      }
      
      return {
        'success': false,
        'message': 'Erro inesperado no login',
      };
    } on DioException catch (e) {
      return _handleError(e, 'Erro no login');
    }
  }
  
  Future<void> logout() async {
    try {
      if (_refreshToken != null) {
        await _dio.post('/auth/logout/', data: {
          'refresh': _refreshToken,
        });
      }
    } catch (e) {
      if (kDebugMode) print('Erro no logout: $e');
    } finally {
      await _saveTokens(null, null);
    }
  }
  
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await _dio.post('/auth/refresh/', data: {
        'refresh': _refreshToken,
      });
      
      if (response.statusCode == 200) {
        final newToken = response.data['access'];
        await _saveTokens(newToken, _refreshToken);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao renovar token: $e');
    }
    
    return false;
  }
  
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/user/');
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar perfil: $e');
      return null;
    }
  }
  
  bool get isAuthenticated => _authToken != null;
  
  // ========== HEALTH CHECK ==========
  
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health/');
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'API indisponível'};
    }
  }
  
  // ========== RESPONSÁVEIS ==========
  
  Future<Map<String, dynamic>> getResponsaveis({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? bairro,
    String? cep,
    String? ordering,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (bairro != null && bairro.isNotEmpty) queryParams['bairro'] = bairro;
      if (cep != null && cep.isNotEmpty) queryParams['cep'] = cep;
      if (ordering != null && ordering.isNotEmpty) queryParams['ordering'] = ordering;
      
      final response = await _dio.get('/cadastro/api/responsaveis/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar responsáveis');
    }
  }
  
  Future<Map<String, dynamic>> getResponsavelByCpf(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/responsaveis/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar responsável');
    }
  }
  
  Future<Map<String, dynamic>> getResponsavelComMembros(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/responsaveis/$cpf/com_membros/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar responsável com membros');
    }
  }
  
  Future<Map<String, dynamic>> getResponsavelComDemandas(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/responsaveis/$cpf/com_demandas/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar responsável com demandas');
    }
  }
  
  Future<Map<String, dynamic>> createResponsavel(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/cadastro/api/responsaveis/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar responsável');
    }
  }
  
  Future<Map<String, dynamic>> updateResponsavel(String cpf, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/cadastro/api/responsaveis/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar responsável');
    }
  }
  
  Future<void> deleteResponsavel(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/responsaveis/$cpf/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar responsável');
    }
  }
  
  // ========== MEMBROS ==========
  
  Future<Map<String, dynamic>> getMembros({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? cpfResponsavel,
    String? ordering,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (cpfResponsavel != null && cpfResponsavel.isNotEmpty) {
        queryParams['cpf_responsavel'] = cpfResponsavel;
      }
      if (ordering != null && ordering.isNotEmpty) queryParams['ordering'] = ordering;
      
      final response = await _dio.get('/cadastro/api/membros/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar membros');
    }
  }
  
  Future<List<dynamic>> getMembrosPorResponsavel(String cpfResponsavel) async {
    try {
      final response = await _dio.get('/cadastro/api/membros/por_responsavel/', 
        queryParameters: {'cpf_responsavel': cpfResponsavel});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar membros do responsável');
    }
  }
  
  Future<Map<String, dynamic>> createMembro(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/cadastro/api/membros/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar membro');
    }
  }
  
  Future<Map<String, dynamic>> updateMembro(String cpf, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/cadastro/api/membros/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar membro');
    }
  }
  
  // ========== DEMANDAS SAÚDE ==========
  
  Future<Map<String, dynamic>> getDemandasSaude({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? genero,
    String? gestPuerNutriz,
    String? mobReduzida,
    String? cuidaOutrem,
    String? pcdOuMental,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (genero != null && genero.isNotEmpty) queryParams['genero'] = genero;
      if (gestPuerNutriz != null && gestPuerNutriz.isNotEmpty) {
        queryParams['gest_puer_nutriz'] = gestPuerNutriz;
      }
      if (mobReduzida != null && mobReduzida.isNotEmpty) {
        queryParams['mob_reduzida'] = mobReduzida;
      }
      if (cuidaOutrem != null && cuidaOutrem.isNotEmpty) {
        queryParams['cuida_outrem'] = cuidaOutrem;
      }
      if (pcdOuMental != null && pcdOuMental.isNotEmpty) {
        queryParams['pcd_ou_mental'] = pcdOuMental;
      }
      
      final response = await _dio.get('/cadastro/api/demandas-saude/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas de saúde');
    }
  }
  
  Future<List<dynamic>> getGruposPrioritarios() async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-saude/grupos_prioritarios/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar grupos prioritários');
    }
  }
  
  // ========== DEMANDAS EDUCAÇÃO ==========
  
  Future<Map<String, dynamic>> getDemandasEducacao({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? genero,
    String? turno,
    int? alojamento,
    int? unidadeEnsino,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (genero != null && genero.isNotEmpty) queryParams['genero'] = genero;
      if (turno != null && turno.isNotEmpty) queryParams['turno'] = turno;
      if (alojamento != null) queryParams['alojamento'] = alojamento;
      if (unidadeEnsino != null) queryParams['unidade_ensino'] = unidadeEnsino;
      
      final response = await _dio.get('/cadastro/api/demandas-educacao/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas de educação');
    }
  }
  
  // ========== DEMANDAS AMBIENTE ==========
  
  Future<Map<String, dynamic>> getDemandasAmbiente({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? especie,
    String? vacinado,
    String? castrado,
    String? porte,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (especie != null && especie.isNotEmpty) queryParams['especie'] = especie;
      if (vacinado != null && vacinado.isNotEmpty) queryParams['vacinado'] = vacinado;
      if (castrado != null && castrado.isNotEmpty) queryParams['castrado'] = castrado;
      if (porte != null && porte.isNotEmpty) queryParams['porte'] = porte;
      
      final response = await _dio.get('/cadastro/api/demandas-ambiente/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas de ambiente');
    }
  }
  
  // ========== DEMANDAS INTERNAS ==========
  
  Future<Map<String, dynamic>> getDemandasInternas({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? ordering = '-data',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'ordering': ordering,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      
      final response = await _dio.get('/cadastro/api/demandas-internas/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas internas');
    }
  }
  
  Future<List<dynamic>> getDemandasPorStatus(String status) async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-internas/por_status/', 
        queryParameters: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas por status');
    }
  }
  
  // ========== DESAPARECIDOS ==========
  
  Future<Map<String, dynamic>> getDesaparecidos({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? vinculo,
    String? ordering = '-data_desaparecimento',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'ordering': ordering,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (vinculo != null && vinculo.isNotEmpty) queryParams['vinculo'] = vinculo;
      
      final response = await _dio.get('/cadastro/api/desaparecidos/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar desaparecidos');
    }
  }
  
  Future<List<dynamic>> getDesaparecidosRecentes() async {
    try {
      final response = await _dio.get('/cadastro/api/desaparecidos/recentes/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar desaparecidos recentes');
    }
  }
  
  // ========== CEP ATINGIDO ==========
  
  Future<Map<String, dynamic>> getCepsAtingidos({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? uf,
    String? municipio,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (uf != null && uf.isNotEmpty) queryParams['uf'] = uf;
      if (municipio != null && municipio.isNotEmpty) queryParams['municipio'] = municipio;
      
      final response = await _dio.get('/cadastro/api/ceps-atingidos/', 
        queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar CEPs atingidos');
    }
  }
  
  // ========== ALOJAMENTOS ==========
  
  Future<List<dynamic>> getAlojamentos() async {
    try {
      final response = await _dio.get('/cadastro/api/alojamentos/');
      return response.data['results'] ?? response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar alojamentos');
    }
  }
  
  // ========== BUSCA DE CEP ==========
  
  Future<Map<String, dynamic>?> buscarCep(String cep) async {
    try {
      // Remove formatação do CEP
      final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cepLimpo.length != 8) {
        throw Exception('CEP deve ter 8 dígitos');
      }
      
      // Busca via ViaCEP
      final dio = Dio();
      final response = await dio.get('https://viacep.com.br/ws/$cepLimpo/json/');
      
      if (response.data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }
      
      return {
        'cep': response.data['cep'],
        'logradouro': response.data['logradouro'],
        'complemento': response.data['complemento'],
        'bairro': response.data['bairro'],
        'localidade': response.data['localidade'],
        'uf': response.data['uf'],
        'ibge': response.data['ibge'],
        'gia': response.data['gia'],
        'ddd': response.data['ddd'],
        'siafi': response.data['siafi'],
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar CEP: $e');
      return null;
    }
  }
  
  // ========== DASHBOARD / ESTATÍSTICAS ==========
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Como não há endpoint específico para stats, vamos buscar dados básicos
      final futures = await Future.wait([
        getResponsaveis(pageSize: 1),
        getMembros(pageSize: 1),
        getDemandasSaude(pageSize: 1),
        getDemandasEducacao(pageSize: 1),
        getDemandasAmbiente(pageSize: 1),
        getDemandasInternas(pageSize: 1),
      ]);
      
      return {
        'total_responsaveis': futures[0]['count'] ?? 0,
        'total_membros': futures[1]['count'] ?? 0,
        'total_demandas_saude': futures[2]['count'] ?? 0,
        'total_demandas_educacao': futures[3]['count'] ?? 0,
        'total_demandas_ambiente': futures[4]['count'] ?? 0,
        'total_demandas_internas': futures[5]['count'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar estatísticas: $e');
      return {};
    }
  }
  
  // ========== UTILS ==========
  
  Map<String, dynamic> _handleError(DioException error, String defaultMessage) {
    if (kDebugMode) {
      print('❌ API Error: ${error.response?.statusCode}');
      print('❌ Error Data: ${error.response?.data}');
    }
    
    String message = defaultMessage;
    
    if (error.response?.data is Map) {
      final errorData = error.response!.data as Map<String, dynamic>;
      
      // Extrai mensagem de erro da resposta
      if (errorData.containsKey('message')) {
        message = errorData['message'];
      } else if (errorData.containsKey('detail')) {
        message = errorData['detail'];
      } else if (errorData.containsKey('non_field_errors')) {
        final errors = errorData['non_field_errors'] as List;
        if (errors.isNotEmpty) {
          message = errors.first.toString();
        }
      } else {
        // Busca primeiro erro em qualquer campo
        for (final value in errorData.values) {
          if (value is List && value.isNotEmpty) {
            message = value.first.toString();
            break;
          } else if (value is String) {
            message = value;
            break;
          }
        }
      }
    }
    
    // Mensagens específicas por status code
    switch (error.response?.statusCode) {
      case 400:
        message = message.isEmpty ? 'Dados inválidos' : message;
        break;
      case 401:
        message = 'Não autorizado. Faça login novamente.';
        break;
      case 403:
        message = 'Acesso negado';
        break;
      case 404:
        message = 'Recurso não encontrado';
        break;
      case 500:
        message = 'Erro interno do servidor';
        break;
      case null:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          message = 'Timeout na conexão';
        } else if (error.type == DioExceptionType.connectionError) {
          message = 'Erro de conexão. Verifique sua internet.';
        }
        break;
    }
    
    return {
      'success': false,
      'message': message,
      'statusCode': error.response?.statusCode,
      'error': error.response?.data,
    };
  }
  
  // Validação de CPF
  static bool isValidCPF(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanCpf.length != 11) return false;
    if (cleanCpf.split('').toSet().length == 1) return false;
    
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;
    
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    
    int digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;
    
    return int.parse(cleanCpf[9]) == digit1 && int.parse(cleanCpf[10]) == digit2;
  }
  
  // Formatação de CPF
  static String formatCPF(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCpf.length != 11) return cpf;
    
    return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
  }
  
  // Formatação de telefone
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    }
    
    return phone;
  }
  
  // Formatação de CEP
  static String formatCEP(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) return cep;
    
    return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
  }
}


// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../constants/constants.dart';

// class ApiResponse {
//   final bool success;
//   final String? message;
//   final Map<String, dynamic>? data;
//   final int? statusCode;
//   final dynamic error;

//   ApiResponse({
//     required this.success,
//     this.message,
//     this.data,
//     this.statusCode,
//     this.error,
//   });

//   factory ApiResponse.success({
//     String? message,
//     Map<String, dynamic>? data,
//     int? statusCode,
//   }) => ApiResponse(
//       success: true,
//       message: message,
//       data: data,
//       statusCode: statusCode,
//     );

//   factory ApiResponse.error({
//     required String message,
//     int? statusCode,
//     dynamic error,
//   }) => ApiResponse(
//       success: false,
//       message: message,
//       statusCode: statusCode,
//       error: error,
//     );
// }

// class ApiService {
//   late Dio _dio;
//   String? _token;

//   ApiService() {
//     _dio = Dio(BaseOptions(
//       baseUrl: AppConstants.apiBaseUrl,
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       sendTimeout: const Duration(seconds: 30),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ));

//     _setupInterceptors();
//     _loadTokenFromStorage();
//   }

//   void _setupInterceptors() {
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Adicionar token de autorização se disponível
//           if (_token != null && _token!.isNotEmpty) {
//             options.headers['Authorization'] = 'Bearer $_token';
//           }
          
//           if (kDebugMode) {
//             debugPrint('🔗 REQUEST: ${options.method} ${options.path}');
//             debugPrint('📝 Headers: ${options.headers}');
//             if (options.data != null) {
//               debugPrint('📄 Data: ${options.data}');
//             }
//           }
          
//           handler.next(options);
//         },
//         onResponse: (response, handler) {
//           if (kDebugMode) {
//             debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
//             debugPrint('📄 Data: ${response.data}');
//           }
//           handler.next(response);
//         },
//         onError: (error, handler) {
//           if (kDebugMode) {
//             debugPrint('❌ ERROR: ${error.message}');
//             debugPrint('📄 Response: ${error.response?.data}');
//           }
//           handler.next(error);
//         },
//       ),
//     );
//   }

//   Future<void> _loadTokenFromStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _token = prefs.getString('token');
//     } catch (e) {
//       debugPrint('Erro ao carregar token: $e');
//     }
//   }

//   Future<void> _saveTokenToStorage(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', token);
//       _token = token;
//     } catch (e) {
//       debugPrint('Erro ao salvar token: $e');
//     }
//   }

//   Future<void> _removeTokenFromStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('token');
//       _token = null;
//     } catch (e) {
//       debugPrint('Erro ao remover token: $e');
//     }
//   }

//   // ========== MÉTODOS DE AUTENTICAÇÃO ==========

//   /// Realiza login do usuário
//   Future<ApiResponse> login(String username, String password) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/login/',
//         data: {
//           'username': username,
//           'password': password,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = response.data as Map<String, dynamic>;
        
//         // Salvar token se presente
//         if (data['token'] != null) {
//           await _saveTokenToStorage(data['token']);
//         }

//         return ApiResponse.success(
//           message: 'Login realizado com sucesso',
//           data: data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: response.data['message'] ?? 'Erro no login',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro inesperado: $e',
//         error: e,
//       );
//     }
//   }

//   /// Realiza logout do usuário
//   Future<ApiResponse> logout(String refreshToken) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/logout/',
//         data: {
//           'refresh': refreshToken,
//         },
//       );

//       await _removeTokenFromStorage();

//       return ApiResponse.success(
//         message: 'Logout realizado com sucesso',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       // Mesmo com erro, remover token local
//       await _removeTokenFromStorage();
//       return _handleDioError(e);
//     } catch (e) {
//       await _removeTokenFromStorage();
//       return ApiResponse.error(
//         message: 'Erro no logout: $e',
//         error: e,
//       );
//     }
//   }

//   /// Valida se o token ainda é válido
//   Future<ApiResponse> validateToken(String token) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/verify/',
//         data: {
//           'token': token,
//         },
//       );

//       return ApiResponse.success(
//         message: 'Token válido',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao validar token: $e',
//         error: e,
//       );
//     }
//   }

//   /// Renova o token de acesso
//   Future<ApiResponse> refreshToken(String refreshToken) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/refresh/',
//         data: {
//           'refresh': refreshToken,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = response.data as Map<String, dynamic>;
        
//         // Salvar novo token
//         if (data['access'] != null) {
//           await _saveTokenToStorage(data['access']);
//         }

//         return ApiResponse.success(
//           message: 'Token renovado com sucesso',
//           data: data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Erro ao renovar token',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao renovar token: $e',
//         error: e,
//       );
//     }
//   }

//   /// Registra um novo usuário
//   Future<ApiResponse> register({
//     required String username,
//     required String email,
//     required String password,
//     required String passwordConfirm,
//     String? firstName,
//     String? lastName,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/register/',
//         data: {
//           'username': username,
//           'email': email,
//           'password': password,
//           'password_confirm': passwordConfirm,
//           if (firstName != null) 'first_name': firstName,
//           if (lastName != null) 'last_name': lastName,
//         },
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         return ApiResponse.success(
//           message: 'Usuário registrado com sucesso',
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: response.data['message'] ?? 'Erro no registro',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro no registro: $e',
//         error: e,
//       );
//     }
//   }

//   /// Obtém o perfil do usuário logado
//   Future<ApiResponse> getUserProfile() async {
//     try {
//       final response = await _dio.get('/api/v1/auth/profile/');

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           message: 'Perfil carregado com sucesso',
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Erro ao carregar perfil',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao carregar perfil: $e',
//         error: e,
//       );
//     }
//   }

//   /// Atualiza o perfil do usuário
//   Future<ApiResponse> updateProfile(Map<String, dynamic> userData) async {
//     try {
//       final response = await _dio.put(
//         '/api/v1/auth/profile/',
//         data: userData,
//       );

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           message: 'Perfil atualizado com sucesso',
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Erro ao atualizar perfil',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao atualizar perfil: $e',
//         error: e,
//       );
//     }
//   }

//   /// Altera a senha do usuário
//   Future<ApiResponse> changePassword({
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
//         return ApiResponse.success(
//           message: 'Senha alterada com sucesso',
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: response.data['message'] ?? 'Erro ao alterar senha',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao alterar senha: $e',
//         error: e,
//       );
//     }
//   }

//   // ========== MÉTODOS DE DADOS ==========

//   /// Busca responsáveis
//   Future<ApiResponse> getResponsaveis({
//     int page = 1,
//     int pageSize = 20,
//     String? search,
//     String? status,
//   }) async {
//     try {
//       final queryParams = <String, dynamic>{
//         'page': page,
//         'page_size': pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParams['search'] = search;
//       }

//       if (status != null && status.isNotEmpty) {
//         queryParams['status'] = status;
//       }

//       final response = await _dio.get(
//         '/api/v1/cadastro/api/responsaveis/',
//         queryParameters: queryParams,
//       );

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Erro ao buscar responsáveis',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao buscar responsáveis: $e',
//         error: e,
//       );
//     }
//   }

//   /// Busca responsável por CPF
//   Future<ApiResponse> getResponsavelByCpf(String cpf) async {
//     try {
//       final response = await _dio.get(
//         '/api/v1/cadastro/api/responsaveis/$cpf/',
//       );

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Responsável não encontrado',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao buscar responsável: $e',
//         error: e,
//       );
//     }
//   }

//   /// Busca responsável com membros
//   Future<ApiResponse> getResponsavelComMembros(String cpf) async {
//     try {
//       final response = await _dio.get(
//         '/api/v1/cadastro/api/responsaveis/$cpf/com_membros/',
//       );

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Responsável não encontrado',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao buscar responsável com membros: $e',
//         error: e,
//       );
//     }
//   }

//   /// Busca demandas de saúde
//   Future<ApiResponse> getDemandasSaude({
//     int page = 1,
//     int pageSize = 20,
//     String? search,
//   }) async {
//     try {
//       final queryParams = <String, dynamic>{
//         'page': page,
//         'page_size': pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParams['search'] = search;
//       }

//       final response = await _dio.get(
//         '/api/v1/cadastro/api/demandas-saude/',
//         queryParameters: queryParams,
//       );

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Erro ao buscar demandas de saúde',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao buscar demandas de saúde: $e',
//         error: e,
//       );
//     }
//   }

//   /// Busca demandas de educação
//   Future<ApiResponse> getDemandasEducacao({
//     int page = 1,
//     int pageSize = 20,
//     String? search,
//   }) async {
//     try {
//       final queryParams = <String, dynamic>{
//         'page': page,
//         'page_size': pageSize,
//       };

//       if (search != null && search.isNotEmpty) {
//         queryParams['search'] = search;
//       }

//       final response = await _dio.get(
//         '/api/v1/cadastro/api/demandas-educacao/',
//         queryParameters: queryParams,
//       );

//       if (response.statusCode == 200) {
//         return ApiResponse.success(
//           data: response.data,
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse.error(
//         message: 'Erro ao buscar demandas de educação',
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (e) {
//       return _handleDioError(e);
//     } catch (e) {
//       return ApiResponse.error(
//         message: 'Erro ao buscar demandas de educação: $e',
//         error: e,
//       );
//     }
//   }

//   // ========== MÉTODOS UTILITÁRIOS ==========

//   /// Tratamento de erros do Dio
//   ApiResponse _handleDioError(DioException e) {
//     String message;
//     int? statusCode = e.response?.statusCode;

//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         message = 'Timeout na conexão. Verifique sua internet.';
//         break;

//       case DioExceptionType.badResponse:
//         if (e.response?.data != null) {
//           try {
//             final errorData = e.response!.data;
//             if (errorData is Map<String, dynamic>) {
//               message = errorData['message'] ?? 
//                        errorData['error'] ?? 
//                        errorData['detail'] ?? 
//                        'Erro do servidor';
//             } else {
//               message = 'Erro do servidor: ${e.response!.statusCode}';
//             }
//           } catch (_) {
//             message = 'Erro do servidor: ${e.response!.statusCode}';
//           }
//         } else {
//           message = 'Erro do servidor: ${e.response!.statusCode}';
//         }
//         break;

//       case DioExceptionType.connectionError:
//         message = 'Erro de conexão. Verifique sua internet.';
//         break;

//       case DioExceptionType.cancel:
//         message = 'Requisição cancelada.';
//         break;

//       default:
//         message = 'Erro inesperado: ${e.message}';
//         break;
//     }

//     return ApiResponse.error(
//       message: message,
//       statusCode: statusCode,
//       error: e,
//     );
//   }

//   /// Verifica se está autenticado
//   bool get isAuthenticated => _token != null && _token!.isNotEmpty;

//   /// Obtém o token atual
//   String? get currentToken => _token;

//   /// Define um novo token
//   void setToken(String token) {
//     _token = token;
//     _saveTokenToStorage(token);
//   }

//   /// Remove o token
//   void clearToken() {
//     _removeTokenFromStorage();
//   }
// }