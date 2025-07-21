class CepInfo {
  final String cep;
  final String logradouro;
  final String? bairro;
  final String municipio;
  final String uf;
  final int? numInicial;
  final int? numFinal;

  CepInfo({
    required this.cep,
    required this.logradouro,
    this.bairro,
    required this.municipio,
    required this.uf,
    this.numInicial,
    this.numFinal,
  });

  factory CepInfo.fromJson(Map<String, dynamic> json) {
    return CepInfo(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'],
      municipio: json['municipio'] ?? json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      numInicial: json['num_inicial'],
      numFinal: json['num_final'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'municipio': municipio,
      'uf': uf,
      'num_inicial': numInicial,
      'num_final': numFinal,
    };
  }

  String get cepFormatado {
    if (cep.length == 8) {
      return '${cep.substring(0, 5)}-${cep.substring(5)}';
    }
    return cep;
  }

  String get enderecoCompleto {
    final endereco = StringBuffer();
    endereco.write(logradouro);
    if (bairro != null && bairro!.isNotEmpty) {
      endereco.write(', $bairro');
    }
    endereco.write(' - $municipio/$uf');
    endereco.write(' - CEP: $cepFormatado');
    return endereco.toString();
  }
}