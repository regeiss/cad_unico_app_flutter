import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/demanda_educacao_model.dart';
import '../services/api_service.dart';

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
