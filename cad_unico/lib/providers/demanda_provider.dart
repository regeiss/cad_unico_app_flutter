// lib/providers/demanda_provider.dart
import 'package:flutter/material.dart';
import '../contants/constants.dart';
import '../models/demanda_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class DemandaProvider with ChangeNotifier {
  List<DemandaModel> _demandas = [];
  bool _isLoading = false;
  String? _error;
  
  final ApiService _apiService = ApiService();
  
  List<DemandaModel> get demandas => _demandas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<void> loadDemandas() async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _demandas = []; // Replace with actual API call
      _setLoading(false);
    } on Exception   {
      _setError(AppConstants.networkErrorMessage);
      _setLoading(false);
    }
  }
}

/




// // lib/providers/demanda_provider.dart
// import 'package:flutter/foundation.dart';

// import '../models/demanda_ambiente.model.dart';
// import '../models/demanda_educacao_model.dart';
// import '../models/demanda_saude_model.dart';
// import '../services/api_service.dart';

// // class DemandaProvider extends ChangeNotifier 
//   final ApiService _apiService = ApiService();
  
//   List<DemandaSaudeModel> _demandasSaude = [];
//   List<DemandaEducacaoModel> _demandasEducacao = [];
//   List<DemandaAmbienteModel> _demandasAmbiente = [];
//   bool _isLoading = false;
//   String? _error;

//   List<DemandaSaudeModel> get demandasSaude => _demandasSaude;
//   List<DemandaEducacaoModel> get demandasEducacao => _demandasEducacao;
//   List<DemandaAmbienteModel> get demandasAmbiente => _demandasAmbiente;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   // Carregar demandas de saúde
//   Future<void> loadDemandasSaude() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       final response = await _apiService.get(filters: {});
      
//       // Verificar se a resposta é uma lista ou um objeto com results
//       List<dynamic> dataList;
//       // Se for um objeto com paginação
//       dataList = response['results'] ?? response['data'] ?? [];
          
//       _demandasSaude = dataList
//           .map((json) => DemandaSaudeModel.fromJson(json as Map<String, dynamic>))
//           .toList();
          
//       debugPrint('Carregadas ${_demandasSaude.length} demandas de saúde');
      
//     } on Exception   {
//       _error = e.toString();
//       debugPrint('Erro ao carregar demandas de saúde: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Carregar demandas de educação
//   Future<void> loadDemandasEducacao() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       final response = await _apiService.get(filters: {});
      
//       List<dynamic> dataList;
//       dataList = response['results'] ?? response['data'] ?? [];
          
//       _demandasEducacao = dataList
//           .map((json) => DemandaEducacaoModel.fromJson(json as Map<String, dynamic>))
//           .toList();
          
//       debugPrint('Carregadas ${_demandasEducacao.length} demandas de educação');
      
//     } on Exception   {
//       _error = e.toString();
//       debugPrint('Erro ao carregar demandas de educação: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Carregar demandas de ambiente
//   Future<void> loadDemandasAmbiente() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       final response = await _apiService.get(filters: {});
      
//       List<dynamic> dataList;
//       dataList = response['results'] ?? response['data'] ?? [];
          
//       _demandasAmbiente = dataList
//           .map((json) => DemandaAmbienteModel.fromJson(json as Map<String, dynamic>))
//           .toList();
          
//       debugPrint('Carregadas ${_demandasAmbiente.length} demandas de ambiente');
      
//     } on Exception   {
//       _error = e.toString();
//       debugPrint('Erro ao carregar demandas de ambiente: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Carregar todas as demandas
//   Future<void> loadAllDemandas() async {
//     await Future.wait([
//       loadDemandasSaude(),
//       loadDemandasEducacao(),
//       loadDemandasAmbiente(),
//     ]);
//   }

//   // Buscar demandas por CPF
//   Future<List<DemandaSaudeModel>> getDemandaSaudeByCpf(String cpf) async {
//     try {
//       final response = await _apiService.get(filters: {});
//       List<dynamic> dataList;
//       dataList = response['results'] ?? response['data'] ?? [];
          
//       return dataList
//           .map((json) => DemandaSaudeModel.fromJson(json as Map<String, dynamic>))
//           .toList();
          
//     } on Exception   {
//       debugPrint('Erro ao buscar demanda de saúde por CPF: $e');
//       return [];
//     }
//   }

//   // Filtrar grupos prioritários
//   List<DemandaSaudeModel> get gruposPrioritarios => _demandasSaude.where((demanda) =>
//       demanda.gestPuerNutriz == 'S' ||
//       demanda.mobReduzida == 'S' ||
//       demanda.pcdOuMental == 'S'
//     ).toList();

//   // Estatísticas
//   int get totalDemandasSaude => _demandasSaude.length;
//   int get totalDemandasEducacao => _demandasEducacao.length;
//   int get totalDemandasAmbiente => _demandasAmbiente.length;
//   int get totalGruposPrioritarios => gruposPrioritarios.length;

//   // Limpar dados
//   void clear() {
//     _demandasSaude.clear();
//     _demandasEducacao.clear();
//     _demandasAmbiente.clear();
//     _error = null;
//     _isLoading = false;
//     notifyListeners();
//   }
// }