class DemandaStats {
  final int totalSaude;
  final int totalEducacao;
  final int totalAmbiente;
  final int totalPrioritarios;
  final Map<String, int> saudePorGenero;
  final Map<String, int> educacaoPorTurno;
  final Map<String, int> ambientePorEspecie;

  DemandaStats({
    required this.totalSaude,
    required this.totalEducacao,
    required this.totalAmbiente,
    required this.totalPrioritarios,
    required this.saudePorGenero,
    required this.educacaoPorTurno,
    required this.ambientePorEspecie,
  });

  int get totalGeral => totalSaude + totalEducacao + totalAmbiente;

  double get percentualPrioritarios {
    if (totalSaude == 0) return 0.0;
    return (totalPrioritarios / totalSaude) * 100;
  }
}
