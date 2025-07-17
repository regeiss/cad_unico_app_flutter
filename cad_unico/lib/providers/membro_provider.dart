import 'package:flutter/material.dart';

import '../models/membro_model.dart';
import '../services/api_service.dart';

class MembroProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<MembroModel> _membros = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasNextPage = true;
  Map<String, dynamic> _filters = {};

  // Getters
  List<MembroModel> get membros => _membros;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;

  // Carregar membros
  Future<void> loadMembros({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _membros.clear();
      _hasNextPage = true;
    }

    if (_isLoading || !_hasNextPage) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMembros(
        filters: _filters,
        page: _currentPage,
      );

      final newMembros = data.map((json) => MembroModel.fromJson(json)).toList();
      
      if (refresh) {
        _membros = newMembros;
      } else {
        _membros.addAll(newMembros);
      }

      _currentPage++;
      _hasNextPage = newMembros.length == 20;

    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar membros: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar membros por responsável
  Future<void> loadMembrosByResponsavel(String cpfResponsavel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      setFilters({'cpf_responsavel': cpfResponsavel});
      await loadMembros(refresh: true);
    } on Exception catch  (e) {
      _error = e.toString();
      debugPrint('Erro ao carregar membros por responsável: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar membro
  Future<bool> createMembro(MembroModel membro) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.createMembro(membro.toJson());
      final newMembro = MembroModel.fromJson(data);
      _membros.insert(0, newMembro);
      return true;
    }  (e) {
      _error = e.toString();
      debugPrint('Erro ao criar membro: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtros
  void setFilters(Map<String, dynamic> newFilters) {
    _filters = newFilters;
    loadMembros(refresh: true);
  }

  void clearFilters() {
    _filters.clear();
    loadMembros(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}