class AlojamentoModel {
  final int id;
  final String? nome;

  AlojamentoModel({
    required this.id,
    this.nome,
  });

  factory AlojamentoModel.fromJson(Map<String, dynamic> json) => AlojamentoModel(
      id: json['id'],
      nome: json['nome'],
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'nome': nome,
    };
}