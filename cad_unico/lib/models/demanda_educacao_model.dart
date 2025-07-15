class DemandaEducacaoModel {
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

  DemandaEducacaoModel({
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

  factory DemandaEducacaoModel.fromJson(Map<String, dynamic> json) {
    return DemandaEducacaoModel(
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

  Map<String, dynamic> toJson() {
    return {
      'cpf_responsavel': cpfResponsavel,
      'nome': nome,
      'genero': genero,
      'alojamento': alojamento,
      'data_nasc': dataNasc?.toIso8601String().split('T')[0],
      'unidade_ensino': unidadeEnsino,
      'turno': turno,
      'demanda': demanda,
      'evolucao': evolucao,
      'cpf': cpf,
    };
  }

  int? get idade {
    if (dataNasc == null) return null;
    final agora = DateTime.now();
    int idade = agora.year - dataNasc!.year;
    if (agora.month < dataNasc!.month || 
        (agora.month == dataNasc!.month && agora.day < dataNasc!.day)) {
      idade--;
    }
    return idade;
  }
}