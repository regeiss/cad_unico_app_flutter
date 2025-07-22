class StatisticsData {
  final int totalResponsaveis;
  final int totalMembros;
  final int totalDemandas;
  final Map<String, int> demandasPorTipo;
  final Map<String, int> responsaveisPorStatus;
  final Map<String, int> responsaveisPorBairro;
  final int gruposPrioritarios;
  final DateTime lastUpdate;

  StatisticsData({
    required this.totalResponsaveis,
    required this.totalMembros,
    required this.totalDemandas,
    required this.demandasPorTipo,
    required this.responsaveisPorStatus,
    required this.responsaveisPorBairro,
    required this.gruposPrioritarios,
    required this.lastUpdate,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) => StatisticsData(
      totalResponsaveis: json['total_responsaveis'] ?? 0,
      totalMembros: json['total_membros'] ?? 0,
      totalDemandas: json['total_demandas'] ?? 0,
      demandasPorTipo: Map<String, int>.from(json['demandas_por_tipo'] ?? {}),
      responsaveisPorStatus: Map<String, int>.from(json['responsaveis_por_status'] ?? {}),
      responsaveisPorBairro: Map<String, int>.from(json['responsaveis_por_bairro'] ?? {}),
      gruposPrioritarios: json['grupos_prioritarios'] ?? 0,
      lastUpdate: json['last_update'] != null 
        ? DateTime.parse(json['last_update'])
        : DateTime.now(),
    );

  Map<String, dynamic> toJson() => {
      'total_responsaveis': totalResponsaveis,
      'total_membros': totalMembros,
      'total_demandas': totalDemandas,
      'demandas_por_tipo': demandasPorTipo,
      'responsaveis_por_status': responsaveisPorStatus,
      'responsaveis_por_bairro': responsaveisPorBairro,
      'grupos_prioritarios': gruposPrioritarios,
      'last_update': lastUpdate.toIso8601String(),
    };

  bool get isEmpty => totalResponsaveis == 0 && 
           totalMembros == 0 && 
           totalDemandas == 0;

  String get lastUpdateFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays} dias atrás';
    }
  }
}