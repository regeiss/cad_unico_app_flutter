// lib/providers/responsavel_provider.dart

import 'package:flutter/material.dart';

import '../models/responsavel_model.dart';

class ResponsavelProvider extends ChangeNotifier {
  List<Responsavel> _responsaveis = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  // Getters
  List<Responsavel> get responsaveis => _responsaveis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  int get totalResponsaveis => _responsaveis.length;

  // Filtros
  List<Responsavel> get responsaveisAtivos =>
      _responsaveis.where((r) => r.status == 'A').toList();
  
  List<Responsavel> get responsaveisInativos =>
      _responsaveis.where((r) => r.status == 'I').toList();

  // Carregar responsáveis
  Future<void> loadResponsaveis({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _responsaveis.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implementar chamada para API
      // Por enquanto, simulando dados
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = _generateMockData();
      
      if (refresh) {
        _responsaveis = mockData;
      } else {
        _responsaveis.addAll(mockData);
      }
      
      _currentPage++;
      _hasMore = mockData.length >= 20; // Simular fim dos dados
      
    } catch (e) {
      _setError('Erro ao carregar responsáveis: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Buscar responsável por CPF
  Future<Responsavel?> buscarPorCpf(String cpf) async {
    try {
      // TODO: Implementar busca na API
      return _responsaveis.firstWhere(
        (r) => r.cpf == cpf,
        orElse: () => throw Exception('Responsável não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  // Adicionar responsável
  Future<bool> adicionarResponsavel(Responsavel responsavel) async {
    try {
      // TODO: Implementar POST na API
      _responsaveis.add(responsavel);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro ao adicionar responsável: $e');
      return false;
    }
  }

  // Atualizar responsável
  Future<bool> atualizarResponsavel(Responsavel responsavel) async {
    try {
      // TODO: Implementar PUT na API
      final index = _responsaveis.indexWhere((r) => r.cpf == responsavel.cpf);
      if (index != -1) {
        _responsaveis[index] = responsavel;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao atualizar responsável: $e');
      return false;
    }
  }

  // Pesquisar
  void pesquisar(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filtrar responsáveis por pesquisa
  List<Responsavel> get responsaveisFiltrados {
    if (_searchQuery.isEmpty) return _responsaveis;
    
    return _responsaveis.where((responsavel) => responsavel.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             responsavel.cpf.contains(_searchQuery) ||
             (responsavel.nomeMae?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Gerar dados mock para teste
  List<Responsavel> _generateMockData() => List.generate(10, (index) => Responsavel(
        cpf: '123456789${index.toString().padLeft(2, '0')}',
        nome: 'Responsável $index',
        cep: '93000000',
        numero: 100 + index,
        bairro: 'Centro',
        logradouro: 'Rua das Flores',
        status: index % 3 == 0 ? 'I' : 'A',
        timestamp: DateTime.now().subtract(Duration(days: index)),
      ));
}