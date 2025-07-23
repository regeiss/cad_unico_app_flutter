import 'package:flutter/material.dart';
import '../models/membro_model.dart';

class MembroProvider extends ChangeNotifier {
  List<Membro> _membros = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  // Getters
  List<Membro> get membros => _membros;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  int get totalMembros => _membros.length;

  // Filtros
  List<Membro> get membrosAtivos =>
      _membros.where((r) => r.status == 'A').toList();

  List<Membro> get membrosInativos =>
      _membros.where((r) => r.status == 'I').toList();

  // Carregar responsáveis
  Future<void> loadMembros({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _membros.clear();
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
        _membros = mockData;
      } else {
        _membros.addAll(mockData);
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
  Future<Membro?> buscarPorCpf(String cpf) async {
    try {
      // TODO: Implementar busca na API
      return _membros.firstWhere(
        (r) => r.cpf == cpf,
        orElse: () => throw Exception('Responsável não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  // Adicionar responsável
  Future<bool> adicionarMembro(Membro Membro) async {
    try {
      // TODO: Implementar POST na API
      _membros.add(Membro);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro ao adicionar responsável: $e');
      return false;
    }
  }

  // Atualizar responsável
  Future<bool> atualizarMembro(Membro Membro) async {
    try {
      // TODO: Implementar PUT na API
      final index = _membros.indexWhere((r) => r.cpf == Membro.cpf);
      if (index != -1) {
        _membros[index] = Membro;
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
  List<Membro> get MembrosFiltrados {
    if (_searchQuery.isEmpty) return _membros;

    return _membros
        .where((Membro) =>
            Membro.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            Membro.cpf.contains(_searchQuery) ||
            (Membro.nome?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();
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
  List<Membro> _generateMockData() => List.generate(
      10,
      (index) => Membro(
            cpf: '123456789${index.toString().padLeft(2, '0')}',
            nome: 'Responsável $index',
            cpfResponsavel: '93000000',
            status: index % 3 == 0 ? 'I' : 'A',
            timestamp: DateTime.now().subtract(Duration(days: index)),
          ));
}
