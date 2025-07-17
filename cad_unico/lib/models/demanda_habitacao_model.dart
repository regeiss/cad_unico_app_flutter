class DemandaHabitacaoModel {
  final String cpf;
  final double? latitude;
  final double? longitude;
  final String? areaVerde;
  final String? ocupacao;
  final String? material;
  final String? relacaoImovel;
  final String? usoImovel;
  final int? codRge;
  final String? evolucao;

  DemandaHabitacaoModel({
    required this.cpf,
    this.latitude,
    this.longitude,
    this.areaVerde,
    this.ocupacao,
    this.material,
    this.relacaoImovel,
    this.usoImovel,
    this.codRge,
    this.evolucao,
  });

  factory DemandaHabitacaoModel.fromJson(Map<String, dynamic> json) => DemandaHabitacaoModel(
      cpf: json['cpf'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      areaVerde: json['area_verde'],
      ocupacao: json['ocupacao'],
      material: json['material'],
      relacaoImovel: json['relacao_imovel'],
      usoImovel: json['uso_imovel'],
      codRge: json['cod_rge'],
      evolucao: json['evolucao'],
    );

  Map<String, dynamic> toJson() => {
      'cpf': cpf,
      'latitude': latitude,
      'longitude': longitude,
      'area_verde': areaVerde,
      'ocupacao': ocupacao,
      'material': material,
      'relacao_imovel': relacaoImovel,
      'uso_imovel': usoImovel,
      'cod_rge': codRge,
      'evolucao': evolucao,
    };

  bool get temLocalizacao => latitude != null && longitude != null;

  String get relacaoImovelTexto {
    switch (relacaoImovel?.toLowerCase()) {
      case 'proprio': return 'Próprio';
      case 'alugado': return 'Alugado';
      case 'cedido': return 'Cedido';
      case 'ocupacao': return 'Ocupação';
      default: return relacaoImovel ?? 'Não informado';
    }
  }

  String get materialTexto {
    switch (material?.toLowerCase()) {
      case 'alvenaria': return 'Alvenaria';
      case 'madeira': return 'Madeira';
      case 'misto': return 'Misto';
      case 'lona': return 'Lona';
      case 'outros': return 'Outros';
      default: return material ?? 'Não informado';
    }
  }

  DemandaHabitacaoModel copyWith({
    String? cpf,
    double? latitude,
    double? longitude,
    String? areaVerde,
    String? ocupacao,
    String? material,
    String? relacaoImovel,
    String? usoImovel,
    int? codRge,
    String? evolucao,
  }) => DemandaHabitacaoModel(
      cpf: cpf ?? this.cpf,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaVerde: areaVerde ?? this.areaVerde,
      ocupacao: ocupacao ?? this.ocupacao,
      material: material ?? this.material,
      relacaoImovel: relacaoImovel ?? this.relacaoImovel,
      usoImovel: usoImovel ?? this.usoImovel,
      codRge: codRge ?? this.codRge,
      evolucao: evolucao ?? this.evolucao,
    );

  @override
  String toString() => 'DemandaHabitacao(cpf: $cpf, material: $material, relacao: $relacaoImovel)';
}
