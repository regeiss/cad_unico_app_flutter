// lib/providers/responsavel_provider.dart
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/responsavel_model.dart';
import '../services/api_service.dart';

class ResponsavelProvider with ChangeNotifier {
  List<ResponsavelModel> _responsaveis = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<ResponsavelModel> get responsaveis => _responsaveis;
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

  Future<void> loadResponsaveis() async {
    try {
      _setLoading(true);
      _setError(null);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _responsaveis = []; // Replace with actual API call
      _setLoading(false);
    } on Exception {
      _setError(AppConstants.networkErrorMessage);
      _setLoading(false);
    }
  }
}

// // ignore_for_file: unused_field

// import 'package:flutter/foundation.dart';

// import '../models/responsavel_model.dart';
// import '../services/api_service.dart';

// class ResponsavelProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
  
//   Map<String, dynamic>? _responsavelAtual;
//   List<ResponsavelModel> _responsaveis = [];
//   ResponsavelModel? _selectedResponsavel;
//   bool _isLoading = false;
//   String? _error;
  
//   // Paginação
//   int _currentPage = 1;
//   bool _hasNextPage = true;
  
//   // Filtros
//   Map<String, dynamic> _filters = {};

//   // Getters
//   List<ResponsavelModel> get responsaveis => _responsaveis;
//   ResponsavelModel? get selectedResponsavel => _selectedResponsavel;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   int get currentPage => _currentPage;
//   bool get hasNextPage => _hasNextPage;
//   Map<String, dynamic> get filters => _filters;

//   // Carregar lista de responsáveis
//   Future<void> loadResponsaveis({bool refresh = false}) async {
//     if (refresh) {
//       _currentPage = 1;
//       _responsaveis.clear();
//       _hasNextPage = true;
//     }

//     if (_isLoading || !_hasNextPage) return;

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await _apiService.getResponsaveis(
//         filters: _filters,
//         page: _currentPage,
//       );

//       final newResponsaveis = await _apiService.getResponsaveis(filters: {});// data.map((json) => ResponsavelModel.fromJson(json as Map<String, dynamic>));
      
//       if (refresh) {
//         _responsaveis = newResponsaveis as List<ResponsavelModel>;
//       } else {
//         _responsaveis.addAll(newResponsaveis as Iterable<ResponsavelModel>);
//       }

//       _currentPage++;
//       _hasNextPage = newResponsaveis.length == 20; // Assuming page size is 20

//     } on Exception   {
//       _error = e.toString();
//       debugPrint('Erro ao carregar responsáveis: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Buscar responsável por CPF
//   Future<ResponsavelModel?> getResponsavel(String cpf) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await _apiService.getResponsavel(cpf);
//       _selectedResponsavel = ResponsavelModel.fromJson(data);
//       return _selectedResponsavel;
//     } on Exception   {
//       _error = e.toString();
//       debugPrint('Erro ao buscar responsável: $e');
//       return null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Criar novo responsável
//   Future<bool> createResponsavel(ResponsavelModel responsavel) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await _apiService.createResponsavel(responsavel.toJson());
//       final newResponsavel = ResponsavelModel.fromJson(data);
//       _responsaveis.insert(0, newResponsavel);
//       return true;
//     } on Exception catch  (e) {
//       _error = e.toString();
//       debugPrint('Erro ao criar responsável: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Atualizar responsável
//   Future<bool> updateResponsavel(ResponsavelModel responsavel) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await _apiService.updateResponsavel(responsavel.cpf, responsavel.toJson());
//       final updatedResponsavel = ResponsavelModel.fromJson(data);
      
//       final index = _responsaveis.indexWhere((r) => r.cpf == responsavel.cpf);
//       if (index != -1) {
//         _responsaveis[index] = updatedResponsavel;
//       }
      
//       if (_selectedResponsavel?.cpf == responsavel.cpf) {
//         _selectedResponsavel = updatedResponsavel;
//       }
      
//       return true;
//     } on Exception catch  (e) {
//       _error = e.toString();
//       debugPrint('Erro ao atualizar responsável: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Aplicar filtros
//   void setFilters(Map<String, dynamic> newFilters) {
//     _filters = newFilters;
//     loadResponsaveis(refresh: true);
//   }

//   // // Limpar filtros
//   void clearFilters() {
//     _filters.clear();
//     loadResponsaveis(refresh: true);
//   }

//   // Buscar responsáveis
//   Future<void> searchResponsaveis(String query) async {
//     if (query.isEmpty) {
//       clearFilters();
//       return;
//     }

//     setFilters({'search': query});
//   }

//   // Limpar erro
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // Selecionar responsável
//   void selectResponsavel(ResponsavelModel? responsavel) {
//     _selectedResponsavel = responsavel;
//     notifyListeners();
//   }

//   /// Busca um responsável com seus membros
//   Future<void> buscarResponsavelComMembros(String cpf) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       _responsavelAtual = await _apiService.getResponsavelComMembros(cpf);
//       _error = null;
//     } on Exception   {
//       _error = e.toString();
//       _responsavelAtual = null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   /// Busca um responsável com todas as demandas
//   Future<void> buscarResponsavelCompleto(String cpf) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
    
//     try {
//       _responsavelAtual = await _apiService.getResponsavelComDemandas(cpf);
//       _error = null;
//     } on Exception   {
//       _error = e.toString();
//       _responsavelAtual = null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }