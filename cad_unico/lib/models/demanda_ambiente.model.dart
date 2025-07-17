class DemandaAmbienteModel {
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

  DemandaAmbienteModel({
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

  factory DemandaAmbienteModel.fromJson(Map<String, dynamic> json) => DemandaAmbienteModel(
      cpf: json['cpf']?.toString() ?? '',
      quantidade: json['quantidade'] != null 
          ? int.tryParse(json['quantidade'].toString())
          : null,
      especie: json['especie']?.toString(),
      acompanhaTutor: json['acompanha_tutor']?.toString() ?? 'N',
      vacinado: json['vacinado']?.toString(),
      vacRaiva: json['vac_raiva']?.toString(),
      vacV8v10: json['vac_v8v10']?.toString(),
      necRacao: json['nec_racao']?.toString(),
      castrado: json['castrado']?.toString(),
      porte: json['porte']?.toString(),
      evolucao: json['evolucao']?.toString(),
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

  @override
  String toString() => 'DemandaAmbienteModel(cpf: $cpf, especie: $especie, quantidade: $quantidade)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DemandaAmbienteModel && other.cpf == cpf;
  }

  @override
  int get hashCode => cpf.hashCode;

  // Getters úteis
  bool get precisaVacinacao => vacinado != 'S';
  bool get precisaCastracao => castrado != 'S';
  bool get precisaRacao => necRacao == 'S';

  String get statusVacinacao {
    if (vacinado == 'S' && vacRaiva == 'S' && vacV8v10 == 'S') {
      return 'Completa';
    } else if (vacinado == 'S') {
      return 'Parcial';
    }
    return 'Pendente';
  }

  String get situacaoAnimal {
    List<String> pendencias = [];
    if (precisaVacinacao) pendencias.add('Vacinação');
    if (precisaCastracao) pendencias.add('Castração');
    if (precisaRacao) pendencias.add('Ração');
    
    if (pendencias.isEmpty) return 'Regular';
    return 'Pendente: ${pendencias.join(', ')}';
  }
}