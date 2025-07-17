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
      cpfResponsavel: json['cpf_responsavel']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      genero: json['genero']?.toString(),
      alojamento: json['alojamento'] != null 
          ? int.tryParse(json['alojamento'].toString())
          : null,
      dataNasc: json['data_nasc'] != null 
          ? DateTime.tryParse(json['data_nasc'].toString())
          : null,
      unidadeEnsino: json['unidade_ensino'] != null 
          ? int.tryParse(json['unidade_ensino'].toString())
          : null,
      turno: json['turno']?.toString(),
      demanda: json['demanda']?.toString(),
      evolucao: json['evolucao']?.toString(),
      cpf: json['cpf']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf_responsavel': cpfResponsavel,
      'nome': nome,
      'genero': genero,
      'alojamento': alojamento,
      'data_nasc': dataNasc?.toIso8601String()?.split('T')[0],
      'unidade_ensino': unidadeEnsino,
      'turno': turno,
      'demanda': demanda,
      'evolucao': evolucao,
      'cpf': cpf,
    };
  }

  @override
  String toString() {
    return 'DemandaEducacaoModel(cpf: $cpf, nome: $nome, turno: $turno)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DemandaEducacaoModel && other.cpf == cpf;
  }

  @override
  int get hashCode => cpf.hashCode;

  // Getters úteis
  int? get idade {
    if (dataNasc == null) return null;
    final now = DateTime.now();
    int age = now.year - dataNasc!.year;
    if (now.month < dataNasc!.month || 
        (now.month == dataNasc!.month && now.day < dataNasc!.day)) {
      age--;
    }
    return age;
  }

  String get faixaEtaria {
    final age = idade;
    if (age == null) return 'Não informado';
    if (age <= 5) return 'Educação Infantil';
    if (age <= 10) return 'Ensino Fundamental I';
    if (age <= 14) return 'Ensino Fundamental II';
    if (age <= 17) return 'Ensino Médio';
    return 'Educação de Jovens e Adultos';
  }
}
