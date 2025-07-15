class MembroModel {
  final String cpf;
  final String nome;
  final String cpfResponsavel;
  final DateTime? timestamp;
  final String? status;

  MembroModel({
    required this.cpf,
    required this.nome,
    required this.cpfResponsavel,
    this.timestamp,
    this.status,
  });

  factory MembroModel.fromJson(Map<String, dynamic> json) => MembroModel(
      cpf: json['cpf'],
      nome: json['nome'],
      cpfResponsavel: json['cpf_responsavel'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      status: json['status'],
    );

  Map<String, dynamic> toJson() => {
      'cpf': cpf,
      'nome': nome,
      'cpf_responsavel': cpfResponsavel,
      'timestamp': timestamp?.toIso8601String(),
      'status': status,
    };

  bool get isAtivo => status == 'A';
}
