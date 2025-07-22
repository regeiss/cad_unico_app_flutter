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
      cpfResponsavel: json['cpf_responsavel'] ?? '',
      nome: json['nome'] ?? '',
      genero: json['genero'],
      alojamento: json['alojamento'],
      dataNasc: json['data_nasc'] != null
          ? DateTime.tryParse(json['data_nasc'])
          : null,
      unidadeEnsino: json['unidade_ensino'],
      turno: json['turno'],
      demanda: json['demanda'],
      evolucao: json['evolucao'],
      cpf: json['cpf'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf_responsavel': cpfResponsavel,
      'nome': nome,
      'genero': genero,
      'alojamento': alojamento,
      'data_nasc': dataNasc?.toIso8601String().split('T').first,
      'unidade_ensino': unidadeEnsino,
      'turno': turno,
      'demanda': demanda,
      'evolucao': evolucao,
      'cpf': cpf,
    };
  }

  // Getters utilitários
  int get idade {
    if (dataNasc == null) return 0;
    final hoje = DateTime.now();
    int idade = hoje.year - dataNasc!.year;
    if (hoje.month < dataNasc!.month ||
        (hoje.month == dataNasc!.month && hoje.day < dataNasc!.day)) {
      idade--;
    }
    return idade;
  }

  String get faixaEtaria {
    final idadeAtual = idade;
    if (idadeAtual <= 5) return 'Educação Infantil';
    if (idadeAtual <= 10) return 'Ensino Fundamental I';
    if (idadeAtual <= 14) return 'Ensino Fundamental II';
    if (idadeAtual <= 17) return 'Ensino Médio';
    return 'EJA';
  }

  String get turnoFormatado {
    switch (turno?.toLowerCase()) {
      case 'matutino':
      case 'm':
        return 'Matutino';
      case 'vespertino':
      case 'v':
        return 'Vespertino';
      case 'noturno':
      case 'n':
        return 'Noturno';
      case 'integral':
      case 'i':
        return 'Integral';
      default:
        return turno ?? 'Não informado';
    }
  }
}
