import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/demanda_ambiente.model.dart';
import '../models/demanda_educacao_model.dart';
import '../models/demanda_saude_model.dart';
import '../services/api_service.dart';

class DemandaAmbienteProvider with ChangeNotifier {
  List<DemandaAmbiente> _demandas = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  // Getters
  List<DemandaAmbiente> get demandas => _demandas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalDemandas => _demandas.length;

  // Getters de estatísticas
  int get totalAnimais =>
      _demandas.fold(0, (sum, d) => sum + (d.quantidade ?? 0));
  int get animaisVacinados => _demandas.where((d) => d.vacinado == 'S').length;
  int get animaisCastrados => _demandas.where((d) => d.castrado == 'S').length;
  Map<String, int> get distribuicaoEspecie {
    final Map<String, int> dist = {};
    for (var demanda in _demandas) {
      final especie = demanda.especie ?? 'Não informado';
      dist[especie] = (dist[especie] ?? 0) + 1;
    }
    return dist;
  }

  /// Buscar todas as demandas de ambiente
  Future<void> fetchDemandas() async {
    await _performRequest(() async {
      final response =
          await _apiService.get('/cadastro/api/demandas-ambiente/');
      final List<dynamic> data = response['results'] ?? response;
      _demandas = data.map((item) => DemandaAmbiente.fromJson(item)).toList();
    });
  }

  /// Buscar demanda por CPF
  Future<DemandaAmbiente?> getDemandaByCpf(String cpf) async {
    try {
      final response =
          await _apiService.get('/cadastro/api/demandas-ambiente/$cpf/');
      return DemandaAmbiente.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao buscar demanda de ambiente: $e');
      return null;
    }
  }

  /// Criar nova demanda de ambiente
  Future<bool> createDemanda(DemandaAmbiente demanda) async =>
      await _performRequest(() async {
        await _apiService.post(
            '/cadastro/api/demandas-ambiente/', demanda.toJson());
        await fetchDemandas(); // Recarregar lista
      });

  /// Atualizar demanda existente
  Future<bool> updateDemanda(String cpf, DemandaAmbiente demanda) async =>
      await _performRequest(() async {
        await _apiService.put('/cadastro/api/demandas-ambiente/$cpf/',
            jsonEncode(demanda.toJson()), {});
        await fetchDemandas(); // Recarregar lista
      });

  /// Deletar demanda
  Future<bool> deleteDemanda(String cpf) async =>
      await _performRequest(() async {
        await _apiService.delete(
            '/cadastro/api/demandas-ambiente/$cpf/', jsonEncode({}));
        _demandas.removeWhere((d) => d.cpf == cpf);
      });

  /// Filtrar demandas por espécie
  List<DemandaAmbiente> filterByEspecie(String especie) =>
      _demandas.where((d) => d.especie == especie).toList();

  /// Filtrar demandas vacinadas
  List<DemandaAmbiente> getVacinados() =>
      _demandas.where((d) => d.vacinado == 'S').toList();

  /// Filtrar demandas não vacinadas
  List<DemandaAmbiente> getNaoVacinados() =>
      _demandas.where((d) => d.vacinado != 'S').toList();

  Future<bool> _performRequest(Future<void> Function() request) async {
    _setLoading(true);
    _clearError();

    try {
      await request();
      return true;
    } catch (e) {
      _setError('Erro na operação: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

class DemandaEducacaoProvider with ChangeNotifier {
  List<DemandaEducacao> _demandas = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  // Getters
  List<DemandaEducacao> get demandas => _demandas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalDemandas => _demandas.length;

  // Getters de estatísticas
  Map<String, int> get distribuicaoGenero {
    final Map<String, int> dist = {};
    for (var demanda in _demandas) {
      final genero = demanda.genero ?? 'Não informado';
      dist[genero] = (dist[genero] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get distribuicaoTurno {
    final Map<String, int> dist = {};
    for (var demanda in _demandas) {
      final turno = demanda.turno ?? 'Não informado';
      dist[turno] = (dist[turno] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get distribuicaoIdade {
    final Map<String, int> dist = {
      'Infantil (0-5)': 0,
      'Fundamental (6-14)': 0,
      'Médio (15-17)': 0,
      'Adulto (18+)': 0,
    };

    for (var demanda in _demandas) {
      final idade = demanda.idade;
      if (idade <= 5) {
        dist['Infantil (0-5)'] = dist['Infantil (0-5)']! + 1;
      } else if (idade <= 14) {
        dist['Fundamental (6-14)'] = dist['Fundamental (6-14)']! + 1;
      } else if (idade <= 17) {
        dist['Médio (15-17)'] = dist['Médio (15-17)']! + 1;
      } else {
        dist['Adulto (18+)'] = dist['Adulto (18+)']! + 1;
      }
    }
    return dist;
  }

  /// Buscar todas as demandas de educação
  Future<void> fetchDemandas() async {
    await _performRequest(() async {
      final response =
          await _apiService.get('/cadastro/api/demandas-educacao/');
      final List<dynamic> data = response['results'] ?? response;
      _demandas = data.map((item) => DemandaEducacao.fromJson(item)).toList();
    });
  }

  /// Buscar demanda por CPF
  Future<DemandaEducacao?> getDemandaByCpf(String cpf) async {
    try {
      final response =
          await _apiService.get('/cadastro/api/demandas-educacao/$cpf/');
      return DemandaEducacao.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao buscar demanda de educação: $e');
      return null;
    }
  }

  /// Buscar demandas por responsável
  Future<List<DemandaEducacao>> getDemandasByResponsavel(
      String cpfResponsavel) async {
    try {
      final response = await _apiService.get(
          '/cadastro/api/demandas-educacao/?cpf_responsavel=$cpfResponsavel');
      final List<dynamic> data = response['results'] ?? response;
      return data.map((item) => DemandaEducacao.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar demandas por responsável: $e');
      return [];
    }
  }

  /// Criar nova demanda de educação
  Future<bool> createDemanda(DemandaEducacao demanda) async =>
      await _performRequest(() async {
        await _apiService.post(
            '/cadastro/api/demandas-educacao/', demanda.toJson());
        await fetchDemandas(); // Recarregar lista
      });

  /// Atualizar demanda existente
  Future<bool> updateDemanda(String cpf, DemandaEducacao demanda) async =>
      await _performRequest(() async {
        await _apiService.put('/cadastro/api/demandas-educacao/$cpf/',
            jsonEncode(demanda.toJson()), {});
        await fetchDemandas(); // Recarregar lista
      });

  /// Deletar demanda
  Future<bool> deleteDemanda(String cpf) async =>
      await _performRequest(() async {
        await _apiService.delete(
            '/cadastro/api/demandas-educacao/$cpf/', jsonEncode({}));

        _demandas.removeWhere((d) => d.cpf == cpf);
      });

  /// Filtrar por turno
  List<DemandaEducacao> filterByTurno(String turno) =>
      _demandas.where((d) => d.turno == turno).toList();

  /// Filtrar por gênero
  List<DemandaEducacao> filterByGenero(String genero) =>
      _demandas.where((d) => d.genero == genero).toList();

  /// Filtrar por faixa etária
  List<DemandaEducacao> filterByIdade(int idadeMin, int idadeMax) =>
      _demandas.where((d) {
        final idade = d.idade;
        return idade >= idadeMin && idade <= idadeMax;
      }).toList();

  /// Buscar demandas por nome
  List<DemandaEducacao> searchByName(String query) => _demandas
      .where((d) => d.nome.toLowerCase().contains(query.toLowerCase()))
      .toList();

  Future<bool> _performRequest(Future<void> Function() request) async {
    _setLoading(true);
    _clearError();

    try {
      await request();
      return true;
    } catch (e) {
      _setError('Erro na operação: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

class DemandaSaudeProvider with ChangeNotifier {
  List<DemandaSaude> _demandas = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  // Getters
  List<DemandaSaude> get demandas => _demandas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalDemandas => _demandas.length;

  // Getters de estatísticas
  int get totalGruposPrioritarios =>
      _demandas.where((d) => _isGrupoPrioritario(d)).length;
  int get gestantesPuerperas =>
      _demandas.where((d) => d.gestPuerNutriz == 'S').length;
  int get mobilidadeReduzida =>
      _demandas.where((d) => d.mobReduzida == 'S').length;
  int get pcdMental => _demandas.where((d) => d.pcdOuMental == 'S').length;
  int get cuidadores => _demandas.where((d) => d.cuidaOutrem == 'S').length;

  // Método auxiliar para verificar se é grupo prioritário
  bool _isGrupoPrioritario(DemandaSaude demanda) {
    return demanda.gestPuerNutriz == 'S' ||
        demanda.mobReduzida == 'S' ||
        demanda.pcdOuMental == 'S' ||
        demanda.cuidaOutrem == 'S';
  }

  Map<String, int> get distribuicaoGenero {
    final Map<String, int> dist = {};
    for (var demanda in _demandas) {
      final genero = demanda.genero ?? 'Não informado';
      dist[genero] = (dist[genero] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, int> get distribuicaoIdade {
    final Map<String, int> dist = {
      'Criança (0-12)': 0,
      'Adolescente (13-17)': 0,
      'Adulto (18-59)': 0,
      'Idoso (60+)': 0,
    };

    for (var demanda in _demandas) {
      final idade = demanda.idade;
      if (idade <= 12) {
        dist['Criança (0-12)'] = dist['Criança (0-12)']! + 1;
      } else if (idade <= 17) {
        dist['Adolescente (13-17)'] = dist['Adolescente (13-17)']! + 1;
      } else if (idade <= 59) {
        dist['Adulto (18-59)'] = dist['Adulto (18-59)']! + 1;
      } else {
        dist['Idoso (60+)'] = dist['Idoso (60+)']! + 1;
      }
    }
    return dist;
  }

  /// Buscar todas as demandas de saúde
  Future<void> fetchDemandas() async {
    await _performRequest(() async {
      final response = await _apiService.get('/cadastro/api/demandas-saude/');
      final List<dynamic> data = response['results'] ?? response;
      _demandas = data.map((item) => DemandaSaude.fromJson(item)).toList();
    });
  }

  /// Buscar grupos prioritários
  Future<void> fetchGruposPrioritarios() async {
    await _performRequest(() async {
      final response = await _apiService
          .get('/cadastro/api/demandas-saude/grupos_prioritarios/');
      final List<dynamic> data = response['results'] ?? response;
      _demandas = data.map((item) => DemandaSaude.fromJson(item)).toList();
    });
  }

  /// Buscar demanda por CPF
  Future<DemandaSaude?> getDemandaByCpf(String cpf) async {
    try {
      final response =
          await _apiService.get('/cadastro/api/demandas-saude/$cpf/');
      return DemandaSaude.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao buscar demanda de saúde: $e');
      return null;
    }
  }

  /// Criar nova demanda de saúde
  Future<bool> createDemanda(DemandaSaude demanda) async =>
      await _performRequest(() async {
        await _apiService.post(
            '/cadastro/api/demandas-saude/', demanda.toJson());
        await fetchDemandas(); // Recarregar lista
      });

  /// Atualizar demanda existente
  Future<bool> updateDemanda(String cpf, DemandaSaude demanda) async =>
      await _performRequest(() async {
        await _apiService.put('/cadastro/api/demandas-saude/$cpf/',
            jsonEncode(demanda.toJson()), {});
        await fetchDemandas(); // Recarregar lista
      });

  /// Deletar demanda
  Future<bool> deleteDemanda(String cpf) async =>
      await _performRequest(() async {
        await _apiService.delete(
            '/cadastro/api/demandas-saude/$cpf/', jsonEncode({}));
        _demandas.removeWhere((d) => d.cpf == cpf);
      });

  /// Filtrar grupos prioritários
  List<DemandaSaude> getGruposPrioritarios() =>
      _demandas.where((d) => _isGrupoPrioritario(d)).toList();

  /// Filtrar por gênero
  List<DemandaSaude> filterByGenero(String genero) =>
      _demandas.where((d) => d.genero == genero).toList();

  /// Filtrar por condição específica
  List<DemandaSaude> filterByCondicao(String condicao) {
    switch (condicao.toLowerCase()) {
      case 'gestante':
        return _demandas.where((d) => d.gestPuerNutriz == 'S').toList();
      case 'mobilidade':
        return _demandas.where((d) => d.mobReduzida == 'S').toList();
      case 'pcd':
        return _demandas.where((d) => d.pcdOuMental == 'S').toList();
      case 'cuidador':
        return _demandas.where((d) => d.cuidaOutrem == 'S').toList();
      default:
        return [];
    }
  }

  /// Filtrar por CID
  List<DemandaSaude> filterByCid(String cid) => _demandas
      .where(
          (d) => d.saudeCid?.toLowerCase().contains(cid.toLowerCase()) ?? false)
      .toList();

  /// Filtrar por faixa etária
  List<DemandaSaude> filterByIdade(int idadeMin, int idadeMax) =>
      _demandas.where((d) {
        final idade = d.idade;
        return idade >= idadeMin && idade <= idadeMax;
      }).toList();

  Future<bool> _performRequest(Future<void> Function() request) async {
    _setLoading(true);
    _clearError();

    try {
      await request();
      return true;
    } catch (e) {
      _setError('Erro na operação: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

class DemandaProvider with ChangeNotifier {
  final DemandaAmbienteProvider _ambienteProvider = DemandaAmbienteProvider();
  final DemandaEducacaoProvider _educacaoProvider = DemandaEducacaoProvider();
  final DemandaSaudeProvider _saudeProvider = DemandaSaudeProvider();

  // Getters para os providers individuais
  DemandaAmbienteProvider get ambiente => _ambienteProvider;
  DemandaEducacaoProvider get educacao => _educacaoProvider;
  DemandaSaudeProvider get saude => _saudeProvider;

  // Estado geral
  bool get isAnyLoading =>
      _ambienteProvider.isLoading ||
      _educacaoProvider.isLoading ||
      _saudeProvider.isLoading;

  List<String> get allErrors => [
        if (_ambienteProvider.error != null) _ambienteProvider.error!,
        if (_educacaoProvider.error != null) _educacaoProvider.error!,
        if (_saudeProvider.error != null) _saudeProvider.error!,
      ];

  // Estatísticas consolidadas
  Map<String, int> get resumoGeral => {
        'Total Ambiente': _ambienteProvider.totalDemandas,
        'Total Educação': _educacaoProvider.totalDemandas,
        'Total Saúde': _saudeProvider.totalDemandas,
        'Grupos Prioritários': _saudeProvider.totalGruposPrioritarios,
      };

  DemandaProvider() {
    // Escutar mudanças nos providers individuais
    _ambienteProvider.addListener(notifyListeners);
    _educacaoProvider.addListener(notifyListeners);
    _saudeProvider.addListener(notifyListeners);
  }

  /// Carregar todas as demandas
  Future<void> loadAllDemandas() async {
    await Future.wait([
      _ambienteProvider.fetchDemandas(),
      _educacaoProvider.fetchDemandas(),
      _saudeProvider.fetchDemandas(),
    ]);
  }

  /// Buscar demandas por CPF em todas as categorias
  Future<Map<String, dynamic>> getDemandas(String cpf) async {
    final results = await Future.wait([
      _ambienteProvider.getDemandaByCpf(cpf),
      _educacaoProvider.getDemandasByResponsavel(cpf),
      _saudeProvider.getDemandaByCpf(cpf),
    ]);

    return {
      'ambiente': results[0],
      'educacao': results[1],
      'saude': results[2],
    };
  }

  @override
  void dispose() {
    _ambienteProvider.dispose();
    _educacaoProvider.dispose();
    _saudeProvider.dispose();
    super.dispose();
  }
}
