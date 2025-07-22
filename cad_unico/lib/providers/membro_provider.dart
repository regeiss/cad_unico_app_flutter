// lib/providers/demanda_provider.dart

import 'package:flutter/material.dart';

class DemandaSaude {
  final String cpf;
  final String? genero;
  final String? saudeCid;
  final DateTime? dataNasc;
  final String gestPuerNutriz;
  final String mobReduzida;
  final String cuidaOutrem;
  final String pcdOuMental;
  final String? alergiaIntol;
  final String? subsPsicoativas;
  final String? medControlada;
  final String? localRef;
  final String? evolucao;

  DemandaSaude({
    required this.cpf,
    this.genero,
    this.saudeCid,
    this.dataNasc,
    required this.gestPuerNutriz,
    required this.mobReduzida,
    required this.cuidaOutrem,
    required this.pcdOuMental,
    this.alergiaIntol,
    this.subsPsicoativas,
    this.medControlada,
    this.localRef,
    this.evolucao,
  });

  factory DemandaSaude.fromJson(Map<String, dynamic> json) {
    return DemandaSaude(
      cpf: json['cpf'],
      genero: json['genero'],
      saudeCid: json['saude_cid'],
      dataNasc: json['data_nasc'] != null ? DateTime.parse(json['data_nasc']) : null,
      gestPuerNutriz: json['gest_puer_nutriz'],
      mobReduzida: json['mob_reduzida'],
      cuidaOutrem: json['cuida_outrem'],
      pcdOuMental: json['pcd_ou_mental'],
      alergiaIntol: json['alergia_intol'],
      subsPsicoativas: json['subs_psicoativas'],
      medControlada: json['med_controlada'],
      localRef: json['local_ref'],
      evolucao: json['evolucao'],
    );
  }
}

class DemandaEducacao {
  final String cpfResponsavel;
  final String nome;
  final String? genero;
  final int? alojamento;
  final DateTime? dataNasc;
  final int? unidadeEnsino;
  final String? turno;
  final String? demanda;
  final String? evolucao;
  final String cpf;

  DemandaEducacao({
    required this.cpfResponsavel,
    required this.nome,
    this.genero,
    this.alojamento,
    this.dataNasc,
    this.unidadeEnsino,
    this.turno,
    this.demanda,
    this.evolucao,
    required this.cpf,
  });

  factory DemandaEducacao.fromJson(Map<String, dynamic> json) {
    return DemandaEducacao(
      cpfResponsavel: json['cpf_responsavel'],
      nome: json['nome'],
      genero: json['genero'],
      alojamento: json['alojamento'],
      dataNasc: json['data_nasc'] != null ? DateTime.parse(json['data_nasc']) : null,
      unidadeEnsino: json['unidade_ensino'],
      turno: json['turno'],
      demanda: json['demanda'],
      evolucao: json['evolucao'],
      cpf: json['cpf'],
    );
  }
}

class DemandaAmbiente {
  final String cpf;
  final int? quantidade;
  final String? especie;
  final String acompanhaTutor;
  final String? vacinado;
  final String? vacRaiva;
  final String? vacV8v10;
  final String? necRacao;
  final String? castrado;
  final String? porte;
  final String? evolucao;

  DemandaAmbiente({
    required this.cpf,
    this.quantidade,
    this.especie,
    required this.acompanhaTutor,
    this.vacinado,
    this.vacRaiva,
    this.vacV8v10,
    this.necRacao,
    this.castrado,
    this.porte,
    this.evolucao,
  });

  factory DemandaAmbiente.fromJson(Map<String, dynamic> json) {
    return DemandaAmbiente(
      cpf: json['cpf'],
      quantidade: json['quantidade'],
      especie: json['especie'],
      acompanhaTutor: json['acompanha_tutor'],
      vacinado: json['vacinado'],
      vacRaiva: json['vac_raiva'],
      vacV8v10: json['vac_v8v10'],
      necRacao: json['nec_racao'],
      castrado: json['castrado'],
      porte: json['porte'],
      evolucao: json['evolucao'],
    );
  }
}

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
  int get totalGruposPrioritarios {
    return _demandasSaude.where((d) => 
      d.gestPuerNutriz == 'S' || 
      d.mobReduzida == 'S' || 
      d.pcdOuMental == 'S'
    ).length;
  }

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
  List<DemandaSaude> _generateMockSaudeData() {
    return List.generate(25, (index) {
      return DemandaSaude(
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
      );
    });
  }

  // Gerar dados mock para teste - Educação
  List<DemandaEducacao> _generateMockEducacaoData() {
    return List.generate(18, (index) {
      return DemandaEducacao(
        cpf: '22233344455$index',
        cpfResponsavel: '12345678900',
        nome: 'Estudante $index',
        genero: index % 2 == 0 ? 'M' : 'F',
        alojamento: (index % 5) + 1,
        dataNasc: DateTime.now().subtract(Duration(days: (5 + index) * 365)),
        unidadeEnsino: (index % 3) + 1,
        turno: index % 2 == 0 ? 'Manhã' : 'Tarde',
        demanda: 'Necessidade de material escolar',
      );
    });
  }

  // Gerar dados mock para teste - Ambiente
  List<DemandaAmbiente> _generateMockAmbienteData() {
    return List.generate(12, (index) {
      return DemandaAmbiente(
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
      );
    });
  }
}