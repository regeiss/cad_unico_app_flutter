// lib/providers/demanda_provider.dart
import 'package:flutter/foundation.dart';

import '../models/demanda_ambiente.model.dart';
import '../models/demanda_educacao_model.dart';
import '../models/demanda_saude_model.dart';
import '../services/api_service.dart';

class DemandaProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<DemandaSaudeModel> _demandasSaude = [];
  List<DemandaEducacaoModel> _demandasEducacao = [];
  List<DemandaAmbienteModel> _demandasAmbiente = [];
  bool _isLoading = false;
  String? _error;

  List<DemandaSaudeModel> get demandasSaude => _demandasSaude;
  List<DemandaEducacaoModel> get demandasEducacao => _demandasEducacao;
  List<DemandaAmbienteModel> get demandasAmbiente => _demandasAmbiente;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar demandas de saúde
  Future<void> loadDemandasSaude() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/cadastro/api/demandas-saude/');
      
      // Verificar se a resposta é uma lista ou um objeto com results
      List<dynamic> dataList;
      if (response is Map<String, dynamic>) {
        // Se for um objeto com paginação
        dataList = response['results'] ?? response['data'] ?? [];
      } else if (response is List) {
        // Se for uma lista direta
        dataList = response;
      } else {
        throw Exception('Formato de resposta inválido');
      }
      
      _demandasSaude = dataList
          .map((json) => DemandaSaudeModel.fromJson(json as Map<String, dynamic>))
          .toList();
          
      debugPrint('Carregadas ${_demandasSaude.length} demandas de saúde');
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar demandas de saúde: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar demandas de educação
  Future<void> loadDemandasEducacao() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/cadastro/api/demandas-educacao/');
      
      List<dynamic> dataList;
      if (response is Map<String, dynamic>) {
        dataList = response['results'] ?? response['data'] ?? [];
      } else if (response is List) {
        dataList = response;
      } else {
        throw Exception('Formato de resposta inválido');
      }
      
      _demandasEducacao = dataList
          .map((json) => DemandaEducacaoModel.fromJson(json as Map<String, dynamic>))
          .toList();
          
      debugPrint('Carregadas ${_demandasEducacao.length} demandas de educação');
      
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar demandas de educação: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar demandas de ambiente
  Future<void> loadDemandasAmbiente() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/cadastro/api/demandas-ambiente/');
      
      List<dynamic> dataList;
      if (response is Map<String, dynamic>) {
        dataList = response['results'] ?? response['data'] ?? [];
      } else if (response is List) {
        dataList = response;
      } else {
        throw Exception('Formato de resposta inválido');
      }
      
      _demandasAmbiente = dataList
          .map((json) => DemandaAmbienteModel.fromJson(json as Map<String, dynamic>))
          .toList();
          
      debugPrint('Carregadas ${_demandasAmbiente.length} demandas de ambiente');
      
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar demandas de ambiente: $e');
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
      loadDemandasAmbiente(),
    ]);
  }

  // Buscar demandas por CPF
  Future<List<DemandaSaudeModel>> getDemandaSaudeByCpf(String cpf) async {
    try {
      final response = await _apiService.get('/cadastro/api/demandas-saude/?cpf=$cpf');
      
      List<dynamic> dataList;
      if (response is Map<String, dynamic>) {
        dataList = response['results'] ?? response['data'] ?? [];
      } else if (response is List) {
        dataList = response;
      } else {
        return [];
      }
      
      return dataList
          .map((json) => DemandaSaudeModel.fromJson(json as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      debugPrint('Erro ao buscar demanda de saúde por CPF: $e');
      return [];
    }
  }

  // Filtrar grupos prioritários
  List<DemandaSaudeModel> get gruposPrioritarios => _demandasSaude.where((demanda) =>
      demanda.gestPuerNutriz == 'S' ||
      demanda.mobReduzida == 'S' ||
      demanda.pcdOuMental == 'S'
    ).toList();

  // Estatísticas
  int get totalDemandasSaude => _demandasSaude.length;
  int get totalDemandasEducacao => _demandasEducacao.length;
  int get totalDemandasAmbiente => _demandasAmbiente.length;
  int get totalGruposPrioritarios => gruposPrioritarios.length;

  // Limpar dados
  void clear() {
    _demandasSaude.clear();
    _demandasEducacao.clear();
    _demandasAmbiente.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}