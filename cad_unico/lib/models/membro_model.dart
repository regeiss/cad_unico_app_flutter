class Membro {
  final String cpf;
  final String nome;
  final String cpfResponsavel;
  final String? cpfResponsavelNome;
  final DateTime? timestamp;
  final String? status;

  Membro({
    required this.cpf,
    required this.nome,
    required this.cpfResponsavel,
    this.cpfResponsavelNome,
    this.timestamp,
    this.status,
  });

  factory Membro.fromJson(Map<String, dynamic> json) => Membro(
      cpf: json['cpf'] ?? '',
      nome: json['nome'] ?? '',
      cpfResponsavel: json['cpf_responsavel'] ?? '',
      cpfResponsavelNome: json['cpf_responsavel_nome'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      status: json['status'],
    );

  Map<String, dynamic> toJson() => {
      'cpf': cpf,
      'nome': nome,
      'cpf_responsavel': cpfResponsavel,
      'status': status,
    };

  String get statusDescricao {
    switch (status) {
      case 'A': return 'Ativo';
      case 'I': return 'Inativo';
      default: return status ?? 'Desconhecido';
    }
  }

  String get cpfFormatado {
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }
}