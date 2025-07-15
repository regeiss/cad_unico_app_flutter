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

  factory DemandaAmbienteModel.fromJson(Map<String, dynamic> json) {
    return DemandaAmbienteModel(
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

  Map<String, dynamic> toJson() {
    return {
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
  }
}