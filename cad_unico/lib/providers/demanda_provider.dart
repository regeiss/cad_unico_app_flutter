import 'package:flutter/material.dart';

import 'demanda_ambiente_provider.dart';
import 'demanda_educacao_provider.dart';
import 'demanda_saude_provider.dart';

class DemandaProvider with ChangeNotifier {
  final DemandaAmbienteProvider _ambienteProvider = DemandaAmbienteProvider();
  final DemandaEducacaoProvider _educacaoProvider = DemandaEducacaoProvider();
  final DemandaSaudeProvider _saudeProvider = DemandaSaudeProvider();

  // Getters para os providers individuais
  DemandaAmbienteProvider get ambiente => _ambienteProvider;
  DemandaEducacaoProvider get educacao => _educacaoProvider;
  DemandaSaudeProvider get saude => _saudeProvider;

  // Estado geral
  bool get isAnyLoading =>
      _ambienteProvider.isLoading ||
      _educacaoProvider.isLoading ||
      _saudeProvider.isLoading;

  List<String> get allErrors => [
        if (_ambienteProvider.error != null) _ambienteProvider.error!,
        if (_educacaoProvider.error != null) _educacaoProvider.error!,
        if (_saudeProvider.error != null) _saudeProvider.error!,
      ];

  // Estatísticas consolidadas
  Map<String, int> get resumoGeral => {
        'Total Ambiente': _ambienteProvider.totalDemandas,
        'Total Educação': _educacaoProvider.totalDemandas,
        'Total Saúde': _saudeProvider.totalDemandas,
        'Grupos Prioritários': _saudeProvider.totalGruposPrioritarios,
      };

  DemandaProvider() {
    // Escutar mudanças nos providers individuais
    _ambienteProvider.addListener(notifyListeners);
    _educacaoProvider.addListener(notifyListeners);
    _saudeProvider.addListener(notifyListeners);
  }

  get totalDemandasSaude => null;

  get totalDemandasEducacao => null;

  get totalDemandasAmbiente => null;

  int get totalGruposPrioritarios => 0;

  /// Carregar todas as demandas
  Future<void> loadAllDemandas() async {
    await Future.wait([
      _ambienteProvider.fetchDemandas(),
      _educacaoProvider.fetchDemandas(),
      _saudeProvider.fetchDemandas(),
    ]);
  }

  /// Buscar demandas por CPF em todas as categorias
  Future<Map<String, dynamic>> getDemandas(String cpf) async {
    final results = await Future.wait([
      _ambienteProvider.getDemandaByCpf(cpf),
      _educacaoProvider.getDemandasByResponsavel(cpf),
      _saudeProvider.getDemandaByCpf(cpf),
    ]);

    return {
      'ambiente': results[0],
      'educacao': results[1],
      'saude': results[2],
    };
  }

  @override
  void dispose() {
    _ambienteProvider.dispose();
    _educacaoProvider.dispose();
    _saudeProvider.dispose();
    super.dispose();
  }

  void loadDemandasSaude() {}
  // TODO Implementar a função
  void loadDemandasEducacao() {}
  // TODO Implementar a função
  void loadDemandasAmbiente() {}
  // TODO Implementar a função
}
