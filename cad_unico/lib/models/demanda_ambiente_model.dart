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

  factory DemandaAmbiente.fromJson(Map<String, dynamic> json) => DemandaAmbiente(
      cpf: json['cpf'] ?? '',
      quantidade: json['quantidade'],
      especie: json['especie'],
      acompanhaTutor: json['acompanha_tutor'] ?? 'N',
      vacinado: json['vacinado'],
      vacRaiva: json['vac_raiva'],
      vacV8v10: json['vac_v8v10'],
      necRacao: json['nec_racao'],
      castrado: json['castrado'],
      porte: json['porte'],
      evolucao: json['evolucao'],
    );

  Map<String, dynamic> toJson() => {
      'cpf': cpf,
      'quantidade': quantidade,
      'especie': especie,
      'acompanha_tutor': acompanhaTutor,
      'vacinado': vacinado,
      'vac_raiva': vacRaiva,
      'vac_v8v10': vacV8v10,
      'nec_racao': necRacao,
      'castrado': castrado,
      'porte': porte,
      'evolucao': evolucao,
    };

  // Getters utilitários
  String get especieFormatada {
    switch (especie?.toLowerCase()) {
      case 'cao':
      case 'cão':
        return '🐕 Cão';
      case 'gato':
        return '🐱 Gato';
      case 'ave':
        return '🐦 Ave';
      case 'outro':
        return '🐾 Outro';
      default:
        return especie ?? 'Não informado';
    }
  }

  String get porteFormatado {
    switch (porte?.toLowerCase()) {
      case 'pequeno':
      case 'p':
        return 'Pequeno';
      case 'medio':
      case 'médio':
      case 'm':
        return 'Médio';
      case 'grande':
      case 'g':
        return 'Grande';
      default:
        return porte ?? 'Não informado';
    }
  }

  bool get vacinacoesCompletas => 
      vacRaiva == 'S' && vacV8v10 == 'S';

  String get statusSaude {
    final status = <String>[];
    
    if (vacinado == 'S') {
      status.add('Vacinado');
      if (vacinacoesCompletas) {
        status.add('(Completo)');
      } else {
        status.add('(Incompleto)');
      }
    } else {
      status.add('Não Vacinado');
    }
    
    if (castrado == 'S') {
      status.add('Castrado');
    } else {
      status.add('Não Castrado');
    }
    
    return status.join(' • ');
  }

  String get necessidades {
    final necessidades = <String>[];
    
    if (necRacao == 'S') necessidades.add('Ração');
    if (vacinado != 'S') necessidades.add('Vacinação');
    if (castrado != 'S') necessidades.add('Castração');
    
    return necessidades.isEmpty ? 'Nenhuma' : necessidades.join(', ');
  }
}
