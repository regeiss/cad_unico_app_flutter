class DemandaSaude {
  final String cpf;
  final String? genero;
  final String? saudeCid;
  final DateTime? dataNasc;
  final String gestPuerNutriz;
  final String mobReduzida;
  final String cuidaOutrem;
  final String pcdOuMental;
  final String? alergiaIntol;
  final String? subsPsicoativas;
  final String? medControlada;
  final String? localRef;
  final String? evolucao;

  static var totalDemandasSaude;

  DemandaSaude({
    required this.cpf,
    this.genero,
    this.saudeCid,
    this.dataNasc,
    required this.gestPuerNutriz,
    required this.mobReduzida,
    required this.cuidaOutrem,
    required this.pcdOuMental,
    this.alergiaIntol,
    this.subsPsicoativas,
    this.medControlada,
    this.localRef,
    this.evolucao,
  });

  factory DemandaSaude.fromJson(Map<String, dynamic> json) => DemandaSaude(
      cpf: json['cpf'] ?? '',
      genero: json['genero'],
      saudeCid: json['saude_cid'],
      dataNasc: json['data_nasc'] != null
          ? DateTime.tryParse(json['data_nasc'])
          : null,
      gestPuerNutriz: json['gest_puer_nutriz'] ?? 'N',
      mobReduzida: json['mob_reduzida'] ?? 'N',
      cuidaOutrem: json['cuida_outrem'] ?? 'N',
      pcdOuMental: json['pcd_ou_mental'] ?? 'N',
      alergiaIntol: json['alergia_intol'],
      subsPsicoativas: json['subs_psicoativas'],
      medControlada: json['med_controlada'],
      localRef: json['local_ref'],
      evolucao: json['evolucao'],
    );

  Map<String, dynamic> toJson() => {
      'cpf': cpf,
      'genero': genero,
      'saude_cid': saudeCid,
      'data_nasc': dataNasc?.toIso8601String().split('T').first,
      'gest_puer_nutriz': gestPuerNutriz,
      'mob_reduzida': mobReduzida,
      'cuida_outrem': cuidaOutrem,
      'pcd_ou_mental': pcdOuMental,
      'alergia_intol': alergiaIntol,
      'subs_psicoativas': subsPsicoativas,
      'med_controlada': medControlada,
      'local_ref': localRef,
      'evolucao': evolucao,
    };

  // Getters utilitários
  bool get isPrioritario =>
      gestPuerNutriz == 'S' || mobReduzida == 'S' || pcdOuMental == 'S';

  int get idade {
    if (dataNasc == null) return 0;
    final hoje = DateTime.now();
    int idade = hoje.year - dataNasc!.year;
    if (hoje.month < dataNasc!.month ||
        (hoje.month == dataNasc!.month && hoje.day < dataNasc!.day)) {
      idade--;
    }
    return idade;
  }

  String get statusPrioridade {
    final prioridades = <String>[];
    if (gestPuerNutriz == 'S') prioridades.add('Gestante/Puérpera/Nutriz');
    if (mobReduzida == 'S') prioridades.add('Mobilidade Reduzida');
    if (pcdOuMental == 'S') prioridades.add('PCD/Deficiência Mental');
    if (cuidaOutrem == 'S') prioridades.add('Cuida de Terceiros');

    return prioridades.isEmpty ? 'Normal' : prioridades.join(', ');
  }
}
