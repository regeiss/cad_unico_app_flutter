import 'package:cadastro_app/models/demanda_ambiente.model.dart';
import 'package:cadastro_app/models/demanda_educacao_model.dart';
import 'package:cadastro_app/models/demanda_saude_model.dart';
import 'package:cadastro_app/services/api_service.dart';
import 'package:flutter/material.dart';

class DemandaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<DemandaSaudeModel> _demandasSaude = [];
  List<DemandaEducacaoModel> _demandasEducacao = [];
  List<DemandaAmbienteModel> _demandasAmbiente = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DemandaSaudeModel> get demandasSaude => _demandasSaude;
  List<DemandaEducacaoModel> get demandasEducacao => _demandasEducacao;
  List<DemandaAmbienteModel> get demandasAmbiente => _demandasAmbiente;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar demandas de saúde
  Future<void> loadDemandasSaude({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getDemandasSaude(filters: filters);
      _demandasSaude = data.map((json) => DemandaSaudeModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar demandas de saúde: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar demandas de educação
  Future<void> loadDemandasEducacao({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getDemandasEducacao(filters: filters);
      _demandasEducacao = data.map((json) => DemandaEducacaoModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar demandas de educação: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar todas as demandas
  Future<void> loadAllDemandas() async {
    await Future.wait([
      loadDemandasSaude(),
      loadDemandasEducacao(),
    ]);
  }

  // Filtros por grupos prioritários
  Future<void> loadGruposPrioritarios() async {
    await loadDemandasSaude(filters: {'grupo_prioritario': true});
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}