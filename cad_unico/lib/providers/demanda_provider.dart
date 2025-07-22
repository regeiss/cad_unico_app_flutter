// lib/providers/demanda_provider.dart

import 'package:flutter/material.dart';

import '../models/demanda_ambiente.model.dart';
import '../models/demanda_educacao_model.dart';
import '../models/demanda_saude_model.dart';

class DemandaProvider extends ChangeNotifier {
  List<DemandaSaude> _demandasSaude = [];
  List<DemandaEducacao> _demandasEducacao = [];
  List<DemandaAmbiente> _demandasAmbiente = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DemandaSaude> get demandasSaude => _demandasSaude;
  List<DemandaEducacao> get demandasEducacao => _demandasEducacao;
  List<DemandaAmbiente> get demandasAmbiente => _demandasAmbiente;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters para totais
  int get totalDemandasSaude => _demandasSaude.length;
  int get totalDemandasEducacao => _demandasEducacao.length;
  int get totalDemandasAmbiente => _demandasAmbiente.length;
  
  // Grupos prioritários (pessoas com necessidades especiais)
  int get totalGruposPrioritarios => _demandasSaude.where((d) => 
      d.gestPuerNutriz == 'S' || 
      d.mobReduzida == 'S' || 
      d.pcdOuMental == 'S'
    ).length;

  // Total geral de demandas
  int get totalDemandas => totalDemandasSaude + totalDemandasEducacao + totalDemandasAmbiente;

  // Carregar todas as demandas
  Future<void> loadAllDemandas({bool refresh = false}) async {
    await Future.wait([
      loadDemandasSaude(refresh: refresh),
      loadDemandasEducacao(refresh: refresh),
      loadDemandasAmbiente(refresh: refresh),
    ]);
  }

  // Carregar demandas de saúde
  Future<void> loadDemandasSaude({bool refresh = false}) async {
    if (!refresh && _demandasSaude.isNotEmpty) return;

    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implementar chamada para API
      await Future.delayed(const Duration(milliseconds: 500));
      
      _demandasSaude = _generateMockSaudeData();
      
    } catch (e) {
      _setError('Erro ao carregar demandas de saúde: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Carregar demandas de educação
  Future<void> loadDemandasEducacao({bool refresh = false}) async {
    if (!refresh && _demandasEducacao.isNotEmpty) return;

    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implementar chamada para API
      await Future.delayed(const Duration(milliseconds: 500));
      
      _demandasEducacao = _generateMockEducacaoData();
      
    } catch (e) {
      _setError('Erro ao carregar demandas de educação: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Carregar demandas de ambiente
  Future<void> loadDemandasAmbiente({bool refresh = false}) async {
    if (!refresh && _demandasAmbiente.isNotEmpty) return;

    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implementar chamada para API
      await Future.delayed(const Duration(milliseconds: 500));
      
      _demandasAmbiente = _generateMockAmbienteData();
      
    } catch (e) {
      _setError('Erro ao carregar demandas de ambiente: $e');
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

  // Gerar dados mock para teste - Saúde
  List<DemandaSaude> _generateMockSaudeData() => List.generate(25, (index) => DemandaSaude(
        cpf: '11122233344$index',
        genero: index % 2 == 0 ? 'M' : 'F',
        saudeCid: 'CID${index + 10}',
        dataNasc: DateTime.now().subtract(Duration(days: (20 + index) * 365)),
        gestPuerNutriz: index % 10 == 0 ? 'S' : 'N',
        mobReduzida: index % 8 == 0 ? 'S' : 'N',
        cuidaOutrem: index % 6 == 0 ? 'S' : 'N',
        pcdOuMental: index % 12 == 0 ? 'S' : 'N',
        alergiaIntol: index % 5 == 0 ? 'Alergia a medicamentos' : null,
        evolucao: 'Acompanhamento regular',
      ));

  // Gerar dados mock para teste - Educação
  List<DemandaEducacao> _generateMockEducacaoData() => List.generate(18, (index) => DemandaEducacao(
        cpf: '22233344455$index',
        cpfResponsavel: '12345678900',
        nome: 'Estudante $index',
        genero: index % 2 == 0 ? 'M' : 'F',
        alojamento: (index % 5) + 1,
        dataNasc: DateTime.now().subtract(Duration(days: (5 + index) * 365)),
        unidadeEnsino: (index % 3) + 1,
        turno: index % 2 == 0 ? 'Manhã' : 'Tarde',
        demanda: 'Necessidade de material escolar',
      ));

  // Gerar dados mock para teste - Ambiente
  List<DemandaAmbiente> _generateMockAmbienteData() => List.generate(12, (index) => DemandaAmbiente(
        cpf: '33344455566$index',
        quantidade: (index % 3) + 1,
        especie: index % 2 == 0 ? 'Cão' : 'Gato',
        acompanhaTutor: 'S',
        vacinado: index % 3 == 0 ? 'N' : 'S',
        vacRaiva: index % 3 == 0 ? 'N' : 'S',
        vacV8v10: index % 4 == 0 ? 'N' : 'S',
        necRacao: index % 2 == 0 ? 'S' : 'N',
        castrado: index % 5 == 0 ? 'N' : 'S',
        porte: index % 3 == 0 ? 'Pequeno' : (index % 3 == 1 ? 'Médio' : 'Grande'),
      ));
}