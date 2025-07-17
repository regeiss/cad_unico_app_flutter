class ResponsavelModel {
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

  ResponsavelModel({
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

  factory ResponsavelModel.fromJson(Map<String, dynamic> json) => ResponsavelModel(
      cpf: json['cpf'],
      nome: json['nome'],
      cep: json['cep'],
      numero: json['numero'],
      complemento: json['complemento'],
      telefone: json['telefone'],
      bairro: json['bairro'],
      logradouro: json['logradouro'],
      nomeMae: json['nome_mae'],
      dataNasc: json['data_nasc'] != null ? DateTime.parse(json['data_nasc']) : null,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
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
      'data_nasc': dataNasc?.toIso8601String().split('T')[0],
      'timestamp': timestamp?.toIso8601String(),
      'status': status,
      'cod_rge': codRge,
    };

  String get enderecoCompleto {
    final parts = <String>[];
    if (logradouro != null) parts.add(logradouro!);
    parts.add(numero.toString());
    if (complemento != null && complemento!.isNotEmpty) parts.add(complemento!);
    if (bairro != null) parts.add(bairro!);
    return parts.join(', ');
  }

  bool get isAtivo => status == 'A';
}