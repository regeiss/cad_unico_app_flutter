import 'package:flutter/material.dart';
import '../models/demanda_ambiente.model.dart';
import '../models/demanda_educacao_model.dart';
import '../models/demanda_model.dart';
import '../models/demanda_saude_model.dart';
import '../services/api_service.dart';

class DemandaProvider with ChangeNotifier {
  final ApiService _apiService;
  
  // Listas de demandas
  List<DemandaSaude> _demandasSaude = [];
  List<DemandaEducacao> _demandasEducacao = [];
  List<DemandaAmbiente> _demandasAmbiente = [];
  List<DemandaSaude> _gruposPrioritarios = [];
  
  // Estados de carregamento
  bool _isLoading = false;
  bool _isLoadingSaude = false;
  bool _isLoadingEducacao = false;
  bool _isLoadingAmbiente = false;
  String? _error;
  
  DemandaProvider(this._apiService);
  
  // Getters para listas
  List<DemandaSaude> get demandasSaude => _demandasSaude;
  List<DemandaEducacao> get demandasEducacao => _demandasEducacao;
  List<DemandaAmbiente> get demandasAmbiente => _demandasAmbiente;
  List<DemandaSaude> get gruposPrioritarios => _gruposPrioritarios;
  
  // Getters para totais
  int get totalDemandasSaude => _demandasSaude.length;
  int get totalDemandasEducacao => _demandasEducacao.length;
  int get totalDemandasAmbiente => _demandasAmbiente.length;
  int get totalGruposPrioritarios => _gruposPrioritarios.length;
  
  // Getters para estados
  bool get isLoading => _isLoading;
  bool get isLoadingSaude => _isLoadingSaude;
  bool get isLoadingEducacao => _isLoadingEducacao;
  bool get isLoadingAmbiente => _isLoadingAmbiente;
  String? get error => _error;
  
  // Método principal para carregar todas as demandas
  Future<void> loadAllDemandas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.wait([
        loadDemandasSaude(),
        loadDemandasEducacao(),
        loadDemandasAmbiente(),
        loadGruposPrioritarios(),
      ]);
    } catch (e) {
      _error = 'Erro ao carregar demandas: $e';
      debugPrint('Erro em loadAllDemandas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Carrega demandas de saúde
  Future<void> loadDemandasSaude() async {
    _isLoadingSaude = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/cadastro/api/demandas-saude/');
      if (response['success'] == true && response['data'] != null) {
        final results = response['data']['results'] as List? ?? response['data'] as List? ?? [];
        _demandasSaude = results
            .map((json) => DemandaSaude.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao carregar demandas de saúde: $e');
      _error = 'Erro ao carregar demandas de saúde';
    } finally {
      _isLoadingSaude = false;
      notifyListeners();
    }
  }
  
  // Carrega demandas de educação
  Future<void> loadDemandasEducacao() async {
    _isLoadingEducacao = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/cadastro/api/demandas-educacao/');
      if (response['success'] == true && response['data'] != null) {
        final results = response['data']['results'] as List? ?? response['data'] as List? ?? [];
        _demandasEducacao = results
            .map((json) => DemandaEducacao.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao carregar demandas de educação: $e');
      _error = 'Erro ao carregar demandas de educação';
    } finally {
      _isLoadingEducacao = false;
      notifyListeners();
    }
  }
  
  // Carrega demandas de ambiente
  Future<void> loadDemandasAmbiente() async {
    _isLoadingAmbiente = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/cadastro/api/demandas-ambiente/');
      if (response['success'] == true && response['data'] != null) {
        final results = response['data']['results'] as List? ?? response['data'] as List? ?? [];
        _demandasAmbiente = results
            .map((json) => DemandaAmbiente.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao carregar demandas de ambiente: $e');
      _error = 'Erro ao carregar demandas de ambiente';
    } finally {
      _isLoadingAmbiente = false;
      notifyListeners();
    }
  }
  
  // Carrega grupos prioritários
  Future<void> loadGruposPrioritarios() async {
    try {
      final response = await _apiService.get('/cadastro/api/demandas-saude/grupos_prioritarios/');
      if (response['success'] == true && response['data'] != null) {
        final results = response['data'] as List? ?? [];
        _gruposPrioritarios = results
            .map((json) => DemandaSaude.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao carregar grupos prioritários: $e');
      // Fallback: filtrar da lista de saúde já carregada
      _gruposPrioritarios = _demandasSaude.where((demanda) => 
        demanda.gestPuerNutriz == 'S' ||
        demanda.mobReduzida == 'S' ||
        demanda.pcdOuMental == 'S'
      ).toList();
    }
    notifyListeners();
  }
  
  // Filtrar demandas
  List<DemandaSaude> filterDemandasSaude({String? search, String? genero}) {
    var filtered = List<DemandaSaude>.from(_demandasSaude);
    
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((demanda) =>
          demanda.cpf.contains(search) ||
          (demanda.saudeCid?.toLowerCase().contains(search.toLowerCase()) ?? false)
      ).toList();
    }
    
    if (genero != null && genero.isNotEmpty) {
      filtered = filtered.where((demanda) => demanda.genero == genero).toList();
    }
    
    return filtered;
  }
  
  List<DemandaEducacao> filterDemandasEducacao({String? search, String? turno}) {
    var filtered = List<DemandaEducacao>.from(_demandasEducacao);
    
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((demanda) =>
          demanda.cpf.contains(search) ||
          demanda.nome.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    
    if (turno != null && turno.isNotEmpty) {
      filtered = filtered.where((demanda) => demanda.turno == turno).toList();
    }
    
    return filtered;
  }
  
  List<DemandaAmbiente> filterDemandasAmbiente({String? search, String? especie}) {
    var filtered = List<DemandaAmbiente>.from(_demandasAmbiente);
    
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((demanda) =>
          demanda.cpf.contains(search) ||
          (demanda.especie?.toLowerCase().contains(search.toLowerCase()) ?? false)
      ).toList();
    }
    
    if (especie != null && especie.isNotEmpty) {
      filtered = filtered.where((demanda) => demanda.especie == especie).toList();
    }
    
    return filtered;
  }
  
  // Refresh dos dados
  Future<void> refresh() async {
    await loadAllDemandas();
  }
  
  // Limpar dados
  void clearData() {
    _demandasSaude.clear();
    _demandasEducacao.clear();
    _demandasAmbiente.clear();
    _gruposPrioritarios.clear();
    _error = null;
    notifyListeners();
  }
}