// ===== RESPONSAVEL PROVIDER =====
// lib/providers/responsavel_provider.dart

import 'package:cadastro_app/models/responsavel_model.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ResponsavelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ResponsavelModel> _responsaveis = [];
  ResponsavelModel? _selectedResponsavel;
  bool _isLoading = false;
  String? _error;
  
  // Paginação
  int _currentPage = 1;
  bool _hasNextPage = true;
  
  // Filtros
  Map<String, dynamic> _filters = {};

  // Getters
  List<ResponsavelModel> get responsaveis => _responsaveis;
  ResponsavelModel? get selectedResponsavel => _selectedResponsavel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  Map<String, dynamic> get filters => _filters;

  // Carregar lista de responsáveis
  Future<void> loadResponsaveis({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _responsaveis.clear();
      _hasNextPage = true;
    }

    if (_isLoading || !_hasNextPage) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getResponsaveis(
        filters: _filters,
        page: _currentPage,
      );

      final newResponsaveis = data.map((json) => ResponsavelModel.fromJson(json)).toList();
      
      if (refresh) {
        _responsaveis = newResponsaveis;
      } else {
        _responsaveis.addAll(newResponsaveis);
      }

      _currentPage++;
      _hasNextPage = newResponsaveis.length == 20; // Assuming page size is 20

    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar responsáveis: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar responsável por CPF
  Future<ResponsavelModel?> getResponsavel(String cpf) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getResponsavel(cpf);
      _selectedResponsavel = ResponsavelModel.fromJson(data);
      return _selectedResponsavel;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao buscar responsável: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar novo responsável
  Future<bool> createResponsavel(ResponsavelModel responsavel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.createResponsavel(responsavel.toJson());
      final newResponsavel = ResponsavelModel.fromJson(data);
      _responsaveis.insert(0, newResponsavel);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao criar responsável: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar responsável
  Future<bool> updateResponsavel(ResponsavelModel responsavel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.updateResponsavel(responsavel.cpf, responsavel.toJson());
      final updatedResponsavel = ResponsavelModel.fromJson(data);
      
      final index = _responsaveis.indexWhere((r) => r.cpf == responsavel.cpf);
      if (index != -1) {
        _responsaveis[index] = updatedResponsavel;
      }
      
      if (_selectedResponsavel?.cpf == responsavel.cpf) {
        _selectedResponsavel = updatedResponsavel;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao atualizar responsável: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aplicar filtros
  void setFilters(Map<String, dynamic> newFilters) {
    _filters = newFilters;
    loadResponsaveis(refresh: true);
  }

  // Limpar filtros
  void clearFilters() {
    _filters.clear();
    loadResponsaveis(refresh: true);
  }

  // Buscar responsáveis
  Future<void> searchResponsaveis(String query) async {
    if (query.isEmpty) {
      clearFilters();
      return;
    }

    setFilters({'search': query});
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Selecionar responsável
  void selectResponsavel(ResponsavelModel? responsavel) {
    _selectedResponsavel = responsavel;
    notifyListeners();
  }
}