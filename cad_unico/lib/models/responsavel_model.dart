class Responsavel {
  final String cpf;
  final String nome;
  final String cep;
  final int numero;
  final String? complemento;
  final int? telefone;
  final String? bairro;
  final String? logradouro;
  final String? nomeMae;
  final DateTime? dataNasc;
  final DateTime? timestamp;
  final String? status;
  final int? codRge;

  Responsavel({
    required this.cpf,
    required this.nome,
    required this.cep,
    required this.numero,
    this.complemento,
    this.telefone,
    this.bairro,
    this.logradouro,
    this.nomeMae,
    this.dataNasc,
    this.timestamp,
    this.status,
    this.codRge,
  });

  factory Responsavel.fromJson(Map<String, dynamic> json) => Responsavel(
        cpf: json['cpf'] ?? '',
        nome: json['nome'] ?? '',
        cep: json['cep'] ?? '',
        numero: json['numero'] ?? 0,
        complemento: json['complemento'],
        telefone: json['telefone'],
        bairro: json['bairro'],
        logradouro: json['logradouro'],
        nomeMae: json['nome_mae'],
        dataNasc: json['data_nasc'] != null
            ? DateTime.tryParse(json['data_nasc'])
            : null,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'])
            : null,
        status: json['status'],
        codRge: json['cod_rge'],
      );

  Map<String, dynamic> toJson() => {
        'cpf': cpf,
        'nome': nome,
        'cep': cep,
        'numero': numero,
        'complemento': complemento,
        'telefone': telefone,
        'bairro': bairro,
        'logradouro': logradouro,
        'nome_mae': nomeMae,
        'data_nasc': dataNasc?.toIso8601String(),
        'timestamp': timestamp?.toIso8601String(),
        'status': status,
        'cod_rge': codRge,
      };
}
