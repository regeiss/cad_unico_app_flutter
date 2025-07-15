class DemandaSaudeModel {
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

  DemandaSaudeModel({
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

  factory DemandaSaudeModel.fromJson(Map<String, dynamic> json) => DemandaSaudeModel(
      cpf: json['cpf'],
      genero: json['genero'],
      saudeCid: json['saude_cid'],
      dataNasc: json['data_nasc'] != null ? DateTime.parse(json['data_nasc']) : null,
      gestPuerNutriz: json['gest_puer_nutriz'],
      mobReduzida: json['mob_reduzida'],
      cuidaOutrem: json['cuida_outrem'],
      pcdOuMental: json['pcd_ou_mental'],
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
      'data_nasc': dataNasc?.toIso8601String().split('T')[0],
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

  bool get isGrupoPrioritario => 
      gestPuerNutriz == 'S' || mobReduzida == 'S' || pcdOuMental == 'S';

  int? get idade {
    if (dataNasc == null) return null;
    final agora = DateTime.now();
    int idade = agora.year - dataNasc!.year;
    if (agora.month < dataNasc!.month || 
        (agora.month == dataNasc!.month && agora.day < dataNasc!.day)) {
      idade--;
    }
    return idade;
  }
}
