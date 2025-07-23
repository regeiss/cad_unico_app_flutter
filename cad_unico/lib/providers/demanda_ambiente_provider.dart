import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/demanda_ambiente_model.dart';
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
