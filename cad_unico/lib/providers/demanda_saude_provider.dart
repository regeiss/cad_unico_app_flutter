import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/demanda_saude_model.dart';
import '../services/api_service.dart';

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
      _demandas.where(_isGrupoPrioritario).length;
  int get gestantesPuerperas =>
      _demandas.where((d) => d.gestPuerNutriz == 'S').length;
  int get mobilidadeReduzida =>
      _demandas.where((d) => d.mobReduzida == 'S').length;
  int get pcdMental => _demandas.where((d) => d.pcdOuMental == 'S').length;
  int get cuidadores => _demandas.where((d) => d.cuidaOutrem == 'S').length;

  // Método auxiliar para verificar se é grupo prioritário
  bool _isGrupoPrioritario(DemandaSaude demanda) => demanda.gestPuerNutriz == 'S' ||
        demanda.mobReduzida == 'S' ||
        demanda.pcdOuMental == 'S' ||
        demanda.cuidaOutrem == 'S';

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
      _demandas.where(_isGrupoPrioritario).toList();

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