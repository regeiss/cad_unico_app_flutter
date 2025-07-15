class CepAtingidoModel {
  final String cep;
  final String logradouro;
  final int? numInicial;
  final int? numFinal;
  final String municipio;
  final String uf;
  final String? bairro;

  CepAtingidoModel({
    required this.cep,
    required this.logradouro,
    this.numInicial,
    this.numFinal,
    required this.municipio,
    required this.uf,
    this.bairro,
  });

  factory CepAtingidoModel.fromJson(Map<String, dynamic> json) => CepAtingidoModel(
      cep: json['cep'],
      logradouro: json['logradouro'],
      numInicial: json['num_inicial'],
      numFinal: json['num_final'],
      municipio: json['municipio'],
      uf: json['uf'],
      bairro: json['bairro'],
    );

  Map<String, dynamic> toJson() => {
      'cep': cep,
      'logradouro': logradouro,
      'num_inicial': numInicial,
      'num_final': numFinal,
      'municipio': municipio,
      'uf': uf,
      'bairro': bairro,
    };

  String get enderecoCompleto {
    final parts = <String>[logradouro];
    if (bairro != null) parts.add(bairro!);
    parts.add('$municipio/$uf');
    return parts.join(', ');
  }
}