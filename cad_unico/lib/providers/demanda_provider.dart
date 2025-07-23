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
        }));
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
        if (vinculo != null && vinculo.isNotEmpty) {
          queryParams['vinculo'] = vinculo;
        }

        final response = await _dio.get('/cadastro/api/desaparecidos/',
            queryParameters: queryParams);
        return response.data;
      } on DioException catch (e) {
        throw _handleError(e, 'Erro ao buscar desaparecidos');
      }
    }

    Future<Map<String, dynamic>> getDesaparecidoById(int id) async {
      try {
        final response = await _dio.get('/cadastro/api/desaparecidos/$id/');
        return response.data;
      } on DioException catch (e) {
        throw _handleError(e, 'Erro ao buscar desaparecido');
      }
    }

    Future<Map<String, dynamic>> createDesaparecido(
        Map<String, dynamic> data) async {
      try {
        final response =
            await _dio.post('/cadastro/api/desaparecidos/', data: data);
        return response.data;
      } on DioException catch (e) {
        throw _handleError(e, 'Erro ao registrar desaparecido');
      }
    }

    Future<Map<String, dynamic>> updateDesaparecido(
        int id, Map<String, dynamic> data) async {
      try {
        final response =
            await _dio.put('/cadastro/api/desaparecidos/$id/', data: data);
        return response.data;
      } on DioException catch (e) {
        throw _handleError(e, 'Erro ao atualizar registro de desaparecido');
      }
    }

    Future<void> deleteDesaparecido(int id) async {
      try {
        await _dio.delete('/cadastro/api/desaparecidos/$id/');
      } on DioException catch (e) {
        throw _handleError(e, 'Erro ao deletar registro de desaparecido');
      }
    }

    Future<List<dynamic>> getDesaparecidosRecentes() async {
      try {
        final response =
            await _dio.get('/cadastro/api/desaparecidos/recentes/');
        return response.data;
      } on DioException catch (e) {
        throw _handleError(e, 'Erro ao buscar desaparecidos recentes');
      }
    }

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
          print(
              '❌ Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
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
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }

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
      final response =
          await _dio.get('/cadastro/api/responsaveis/$cpf/com_membros/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar responsável com membros');
    }
  }

  Future<Map<String, dynamic>> getResponsavelComDemandas(String cpf) async {
    try {
      final response =
          await _dio.get('/cadastro/api/responsaveis/$cpf/com_demandas/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar responsável com demandas');
    }
  }

  Future<Map<String, dynamic>> createResponsavel(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/cadastro/api/responsaveis/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar responsável');
    }
  }

  Future<Map<String, dynamic>> updateResponsavel(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/responsaveis/$cpf/', data: data);
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
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }

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

  Future<Map<String, dynamic>> updateMembro(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/membros/$cpf/', data: data);
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

  Future<Map<String, dynamic>> getDemandaSaudeByCpf(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-saude/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demanda de saúde');
    }
  }

  Future<Map<String, dynamic>> createDemandaSaude(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/cadastro/api/demandas-saude/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar demanda de saúde');
    }
  }

  Future<Map<String, dynamic>> updateDemandaSaude(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/demandas-saude/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar demanda de saúde');
    }
  }

  Future<void> deleteDemandaSaude(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/demandas-saude/$cpf/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar demanda de saúde');
    }
  }

  Future<List<dynamic>> getGruposPrioritarios() async {
    try {
      final response =
          await _dio.get('/cadastro/api/demandas-saude/grupos_prioritarios/');
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

  Future<Map<String, dynamic>> getDemandaEducacaoByCpf(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-educacao/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demanda de educação');
    }
  }

  Future<Map<String, dynamic>> createDemandaEducacao(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/cadastro/api/demandas-educacao/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar demanda de educação');
    }
  }

  Future<Map<String, dynamic>> updateDemandaEducacao(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/demandas-educacao/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar demanda de educação');
    }
  }

  Future<void> deleteDemandaEducacao(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/demandas-educacao/$cpf/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar demanda de educação');
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
      if (especie != null && especie.isNotEmpty) {
        queryParams['especie'] = especie;
      }
      if (vacinado != null && vacinado.isNotEmpty) {
        queryParams['vacinado'] = vacinado;
      }
      if (castrado != null && castrado.isNotEmpty) {
        queryParams['castrado'] = castrado;
      }
      if (porte != null && porte.isNotEmpty) queryParams['porte'] = porte;

      final response = await _dio.get('/cadastro/api/demandas-ambiente/',
          queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas de ambiente');
    }
  }

  Future<Map<String, dynamic>> getDemandaAmbienteByCpf(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-ambiente/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demanda de ambiente');
    }
  }

  Future<Map<String, dynamic>> createDemandaAmbiente(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/cadastro/api/demandas-ambiente/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar demanda de ambiente');
    }
  }

  Future<Map<String, dynamic>> updateDemandaAmbiente(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/demandas-ambiente/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar demanda de ambiente');
    }
  }

  Future<void> deleteDemandaAmbiente(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/demandas-ambiente/$cpf/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar demanda de ambiente');
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

  Future<Map<String, dynamic>> getDemandaInternaByCpf(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-internas/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demanda interna');
    }
  }

  Future<Map<String, dynamic>> createDemandaInterna(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/cadastro/api/demandas-internas/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar demanda interna');
    }
  }

  Future<Map<String, dynamic>> updateDemandaInterna(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/demandas-internas/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar demanda interna');
    }
  }

  Future<void> deleteDemandaInterna(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/demandas-internas/$cpf/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar demanda interna');
    }
  }

  Future<List<dynamic>> getDemandasPorStatus(String status) async {
    try {
      final response = await _dio.get(
          '/cadastro/api/demandas-internas/por_status/',
          queryParameters: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas por status');
    }
  }

  // ========== DEMANDAS HABITAÇÃO ==========

  Future<Map<String, dynamic>> getDemandasHabitacao({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? material,
    String? relacaoImovel,
    String? usoImovel,
    String? areaVerde,
    String? ocupacao,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (material != null && material.isNotEmpty) {
        queryParams['material'] = material;
      }
      if (relacaoImovel != null && relacaoImovel.isNotEmpty) {
        queryParams['relacao_imovel'] = relacaoImovel;
      }
      if (usoImovel != null && usoImovel.isNotEmpty) {
        queryParams['uso_imovel'] = usoImovel;
      }
      if (areaVerde != null && areaVerde.isNotEmpty) {
        queryParams['area_verde'] = areaVerde;
      }
      if (ocupacao != null && ocupacao.isNotEmpty) {
        queryParams['ocupacao'] = ocupacao;
      }

      final response = await _dio.get('/cadastro/api/demandas-habitacao/',
          queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demandas de habitação');
    }
  }

  Future<Map<String, dynamic>> getDemandaHabitacaoByCpf(String cpf) async {
    try {
      final response = await _dio.get('/cadastro/api/demandas-habitacao/$cpf/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar demanda de habitação');
    }
  }

  Future<Map<String, dynamic>> createDemandaHabitacao(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/cadastro/api/demandas-habitacao/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar demanda de habitação');
    }
  }

  Future<Map<String, dynamic>> updateDemandaHabitacao(
      String cpf, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('/cadastro/api/demandas-habitacao/$cpf/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar demanda de habitação');
    }
  }

  Future<void> deleteDemandaHabitacao(String cpf) async {
    try {
      await _dio.delete('/cadastro/api/demandas-habitacao/$cpf/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar demanda de habitação');
    }
  }

  // ========== MÉTODOS GENÉRICOS PARA DEMANDAS ==========

  /// Busca todas as demandas de um responsável por CPF
  Future<Map<String, dynamic>> getAllDemandasByCpf(String cpf) async {
    try {
      final futures = await Future.wait([
        getDemandaSaudeByCpf(cpf).catchError((e) => null),
        getDemandaEducacaoByCpf(cpf).catchError((e) => null),
        getDemandaAmbienteByCpf(cpf).catchError((e) => null),
        getDemandaHabitacaoByCpf(cpf).catchError((e) => null),
        getDemandaInternaByCpf(cpf).catchError((e) => null),
      ]);

      return {
        'cpf': cpf,
        'demanda_saude': futures[0],
        'demanda_educacao': futures[1],
        'demanda_ambiente': futures[2],
        'demanda_habitacao': futures[3],
        'demanda_interna': futures[4],
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar todas as demandas: $e');
      return {'cpf': cpf, 'error': e.toString()};
    }
  }

  /// Busca demandas por tipo
  Future<Map<String, dynamic>> getDemandas({
    required String
        tipo, // 'saude', 'educacao', 'ambiente', 'habitacao', 'interna'
    int page = 1,
    int pageSize = 20,
    String? search,
    Map<String, dynamic>? filtros,
  }) async {
    switch (tipo.toLowerCase()) {
      case 'saude':
        return getDemandasSaude(
          page: page,
          pageSize: pageSize,
          search: search,
          genero: filtros?['genero'],
          gestPuerNutriz: filtros?['gest_puer_nutriz'],
          mobReduzida: filtros?['mob_reduzida'],
          cuidaOutrem: filtros?['cuida_outrem'],
          pcdOuMental: filtros?['pcd_ou_mental'],
        );
      case 'educacao':
        return getDemandasEducacao(
          page: page,
          pageSize: pageSize,
          search: search,
          genero: filtros?['genero'],
          turno: filtros?['turno'],
          alojamento: filtros?['alojamento'],
          unidadeEnsino: filtros?['unidade_ensino'],
        );
      case 'ambiente':
        return getDemandasAmbiente(
          page: page,
          pageSize: pageSize,
          search: search,
          especie: filtros?['especie'],
          vacinado: filtros?['vacinado'],
          castrado: filtros?['castrado'],
          porte: filtros?['porte'],
        );
      case 'habitacao':
        return getDemandasHabitacao(
          page: page,
          pageSize: pageSize,
          search: search,
          material: filtros?['material'],
          relacaoImovel: filtros?['relacao_imovel'],
          usoImovel: filtros?['uso_imovel'],
          areaVerde: filtros?['area_verde'],
          ocupacao: filtros?['ocupacao'],
        );
      case 'interna':
        return getDemandasInternas(
          page: page,
          pageSize: pageSize,
          search: search,
          status: filtros?['status'],
          ordering: filtros?['ordering'],
        );
      default:
        throw Exception('Tipo de demanda inválido: $tipo');
    }
  }

  /// Busca demanda específica por tipo e CPF
  Future<Map<String, dynamic>?> getDemandaByCpf({
    required String tipo,
    required String cpf,
  }) async {
    try {
      switch (tipo.toLowerCase()) {
        case 'saude':
          return await getDemandaSaudeByCpf(cpf);
        case 'educacao':
          return await getDemandaEducacaoByCpf(cpf);
        case 'ambiente':
          return await getDemandaAmbienteByCpf(cpf);
        case 'habitacao':
          return await getDemandaHabitacaoByCpf(cpf);
        case 'interna':
          return await getDemandaInternaByCpf(cpf);
        default:
          throw Exception('Tipo de demanda inválido: $tipo');
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar demanda $tipo para CPF $cpf: $e');
      return null;
    }
  }

  /// Cria demanda por tipo
  Future<Map<String, dynamic>> createDemanda({
    required String tipo,
    required Map<String, dynamic> data,
  }) async {
    switch (tipo.toLowerCase()) {
      case 'saude':
        return createDemandaSaude(data);
      case 'educacao':
        return createDemandaEducacao(data);
      case 'ambiente':
        return createDemandaAmbiente(data);
      case 'habitacao':
        return createDemandaHabitacao(data);
      case 'interna':
        return createDemandaInterna(data);
      default:
        throw Exception('Tipo de demanda inválido: $tipo');
    }
  }

  /// Atualiza demanda por tipo
  Future<Map<String, dynamic>> updateDemanda({
    required String tipo,
    required String cpf,
    required Map<String, dynamic> data,
  }) async {
    switch (tipo.toLowerCase()) {
      case 'saude':
        return updateDemandaSaude(cpf, data);
      case 'educacao':
        return updateDemandaEducacao(cpf, data);
      case 'ambiente':
        return updateDemandaAmbiente(cpf, data);
      case 'habitacao':
        return updateDemandaHabitacao(cpf, data);
      case 'interna':
        return updateDemandaInterna(cpf, data);
      default:
        throw Exception('Tipo de demanda inválido: $tipo');
    }
  }

  /// Deleta demanda por tipo
  Future<void> deleteDemanda({
    required String tipo,
    required String cpf,
  }) async {
    switch (tipo.toLowerCase()) {
      case 'saude':
        return deleteDemandaSaude(cpf);
      case 'educacao':
        return deleteDemandaEducacao(cpf);
      case 'ambiente':
        return deleteDemandaAmbiente(cpf);
      case 'habitacao':
        return deleteDemandaHabitacao(cpf);
      case 'interna':
        return deleteDemandaInterna(cpf);
      default:
        throw Exception('Tipo de demanda inválido: $tipo');
    }
  }

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
      if (vinculo != null && vinculo.isNotEmpty) {
        queryParams['vinculo'] = vinculo;
      }

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
      if (municipio != null && municipio.isNotEmpty) {
        queryParams['municipio'] = municipio;
      }

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
      final response =
          await dio.get('https://viacep.com.br/ws/$cepLimpo/json/');

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
        getDemandasHabitacao(pageSize: 1),
        getDesaparecidos(pageSize: 1),
      ]);

      return {
        'total_responsaveis': futures[0]['count'] ?? 0,
        'total_membros': futures[1]['count'] ?? 0,
        'total_demandas_saude': futures[2]['count'] ?? 0,
        'total_demandas_educacao': futures[3]['count'] ?? 0,
        'total_demandas_ambiente': futures[4]['count'] ?? 0,
        'total_demandas_internas': futures[5]['count'] ?? 0,
        'total_demandas_habitacao': futures[6]['count'] ?? 0,
        'total_desaparecidos': futures[7]['count'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  /// Estatísticas específicas por tipo de demanda
  Future<Map<String, dynamic>> getDemandaStats(String tipo) async {
    try {
      final data = await getDemandas(tipo: tipo, pageSize: 1);
      return {
        'tipo': tipo,
        'total': data['count'] ?? 0,
        'has_next': data['next'] != null,
        'has_previous': data['previous'] != null,
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar estatísticas de $tipo: $e');
      return {'tipo': tipo, 'total': 0, 'error': e.toString()};
    }
  }

  /// Contagem de demandas por responsável
  Future<Map<String, dynamic>> getDemandasCountByCpf(String cpf) async {
    try {
      final futures = await Future.wait([
        getDemandaSaudeByCpf(cpf).then((_) => 1).catchError((_) => 0),
        getDemandaEducacaoByCpf(cpf).then((_) => 1).catchError((_) => 0),
        getDemandaAmbienteByCpf(cpf).then((_) => 1).catchError((_) => 0),
        getDemandaHabitacaoByCpf(cpf).then((_) => 1).catchError((_) => 0),
        getDemandaInternaByCpf(cpf).then((_) => 1).catchError((_) => 0),
      ]);

      return {
        'cpf': cpf,
        'saude': futures[0],
        'educacao': futures[1],
        'ambiente': futures[2],
        'habitacao': futures[3],
        'interna': futures[4],
        'total': futures.reduce((a, b) => a + b),
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao contar demandas para CPF $cpf: $e');
      return {'cpf': cpf, 'total': 0, 'error': e.toString()};
    }
  }

  /// Busca simples para o provider - compatibilidade
  Future<List<Map<String, dynamic>>> getItems({
    required String endpoint,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);

      // Se a resposta é paginada
      if (response.data is Map && response.data.containsKey('results')) {
        return List<Map<String, dynamic>>.from(response.data['results']);
      }

      // Se a resposta é uma lista direta
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      // Se é um objeto único
      if (response.data is Map) {
        return [Map<String, dynamic>.from(response.data)];
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao buscar itens');
    }
  }

  /// Get por ID genérico - compatibilidade com providers antigos
  Future<Map<String, dynamic>?> getById({
    required String endpoint,
    required String id,
  }) async {
    try {
      final response = await _dio.get('$endpoint/$id/');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e, 'Erro ao buscar item');
    }
  }

  /// Post genérico - compatibilidade
  Future<Map<String, dynamic>> postItem({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao criar item');
    }
  }

  /// Put genérico - compatibilidade
  Future<Map<String, dynamic>> putItem({
    required String endpoint,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put('$endpoint/$id/', data: data);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao atualizar item');
    }
  }

  /// Delete genérico - compatibilidade
  Future<void> deleteItem({
    required String endpoint,
    required String id,
  }) async {
    try {
      await _dio.delete('$endpoint/$id/');
    } on DioException catch (e) {
      throw _handleError(e, 'Erro ao deletar item');
    }
  }
  // ========== MÉTODOS ALTERNATIVOS PARA COMPATIBILIDADE ==========

  /// Aliases para compatibilidade com providers existentes
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? params}) async => getItems(endpoint: endpoint, queryParams: params).then((list) => {
          'results': list,
          'count': list.length,
        });

  Future<Map<String, dynamic>?> getItem(String endpoint, String id) async => getById(endpoint: endpoint, id: id);

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async => postItem(endpoint: endpoint, data: data);

  Future<Map<String, dynamic>> put(
      String endpoint, String id, Map<String, dynamic> data) async => putItem(endpoint: endpoint, id: id, data: data);

  Future<void> delete(String endpoint, String id) async => deleteItem(endpoint: endpoint, id: id);

  /// Métodos específicos que podem estar sendo usados pelo DemandaProvider
  Future<List<Map<String, dynamic>>> getAllDemandas() async {
    try {
      final futures = await Future.wait([
        getDemandasSaude(pageSize: 100),
        getDemandasEducacao(pageSize: 100),
        getDemandasAmbiente(pageSize: 100),
        getDemandasHabitacao(pageSize: 100),
        getDemandasInternas(pageSize: 100),
      ]);

      List<Map<String, dynamic>> allDemandas = [];

      for (int i = 0; i < futures.length; i++) {
        final result = futures[i];
        if (result['results'] != null) {
          final items = List<Map<String, dynamic>>.from(result['results']);
          // Adiciona tipo da demanda
          final tipo =
              ['saude', 'educacao', 'ambiente', 'habitacao', 'interna'][i];
          for (var item in items) {
            item['tipo_demanda'] = tipo;
            allDemandas.add(item);
          }
        }
      }

      return allDemandas;
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar todas as demandas: $e');
      return [];
    }
  }

  /// Busca demandas com filtros específicos
  Future<List<Map<String, dynamic>>> searchDemandas({
    String? query,
    String? tipo,
    String? status,
    String? prioridade,
  }) async {
    try {
      List<Map<String, dynamic>> results = [];

      if (tipo == null || tipo.isEmpty) {
        // Busca em todos os tipos
        results = await getAllDemandas();
      } else {
        // Busca em tipo específico
        final response = await getDemandas(
          tipo: tipo,
          search: query,
          filtros: status != null ? {'status': status} : null,
        );
        results = List<Map<String, dynamic>>.from(response['results'] ?? []);
      }

      // Filtros adicionais
      if (query != null && query.isNotEmpty) {
        results = results.where((item) {
          final searchIn = [
            item['cpf']?.toString() ?? '',
            item['nome']?.toString() ?? '',
            item['demanda']?.toString() ?? '',
            item['evolucao']?.toString() ?? '',
          ].join(' ').toLowerCase();
          return searchIn.contains(query.toLowerCase());
        }).toList();
      }

      if (prioridade != null && prioridade.isNotEmpty) {
        // Filtro de prioridade baseado em campos específicos
        results = results.where((item) {
          if (prioridade == 'alta') {
            return item['gest_puer_nutriz'] == 'S' ||
                item['mob_reduzida'] == 'S' ||
                item['pcd_ou_mental'] == 'S';
          }
          return true;
        }).toList();
      }

      return results;
    } catch (e) {
      if (kDebugMode) print('Erro na busca de demandas: $e');
      return [];
    }
  }

  /// Método para buscar demandas por responsável
  Future<List<Map<String, dynamic>>> getDemandasByResponsavel(
      String cpfResponsavel) async {
    try {
      final responsavel = await getResponsavelComDemandas(cpfResponsavel);
      List<Map<String, dynamic>> demandas = [];

      // Extrai todas as demandas do responsável
      if (responsavel['demanda_ambiente'] != null) {
        final demanda =
            Map<String, dynamic>.from(responsavel['demanda_ambiente']);
        demanda['tipo_demanda'] = 'ambiente';
        demandas.add(demanda);
      }

      if (responsavel['demandas_educacao'] != null) {
        final list =
            List<Map<String, dynamic>>.from(responsavel['demandas_educacao']);
        for (var demanda in list) {
          demanda['tipo_demanda'] = 'educacao';
          demandas.add(demanda);
        }
      }

      if (responsavel['demanda_habitacao'] != null) {
        final demanda =
            Map<String, dynamic>.from(responsavel['demanda_habitacao']);
        demanda['tipo_demanda'] = 'habitacao';
        demandas.add(demanda);
      }

      if (responsavel['demandas_internas'] != null) {
        final list =
            List<Map<String, dynamic>>.from(responsavel['demandas_internas']);
        for (var demanda in list) {
          demanda['tipo_demanda'] = 'interna';
          demandas.add(demanda);
        }
      }

      if (responsavel['demanda_saude'] != null) {
        final demanda = Map<String, dynamic>.from(responsavel['demanda_saude']);
        demanda['tipo_demanda'] = 'saude';
        demandas.add(demanda);
      }

      return demandas;
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar demandas do responsável: $e');
      return [];
    }
  }

  /// Contadores para dashboard
  Future<Map<String, int>> getDemandasCount() async {
    try {
      final stats = await getDashboardStats();
      return {
        'saude': stats['total_demandas_saude'] ?? 0,
        'educacao': stats['total_demandas_educacao'] ?? 0,
        'ambiente': stats['total_demandas_ambiente'] ?? 0,
        'habitacao': stats['total_demandas_habitacao'] ?? 0,
        'interna': stats['total_demandas_internas'] ?? 0,
        'total': (stats['total_demandas_saude'] ?? 0) +
            (stats['total_demandas_educacao'] ?? 0) +
            (stats['total_demandas_ambiente'] ?? 0) +
            (stats['total_demandas_habitacao'] ?? 0) +
            (stats['total_demandas_internas'] ?? 0),
      };
    } catch (e) {
      if (kDebugMode) print('Erro ao contar demandas: $e');
      return {
        'saude': 0,
        'educacao': 0,
        'ambiente': 0,
        'habitacao': 0,
        'interna': 0,
        'total': 0,
      };
    }
  }

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

    return int.parse(cleanCpf[9]) == digit1 &&
        int.parse(cleanCpf[10]) == digit2;
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
