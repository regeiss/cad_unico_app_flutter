// lib/models/demanda_saude_model.dart
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

  factory DemandaSaudeModel.fromJson(Map<String, dynamic> json) {
    return DemandaSaudeModel(
      cpf: json['cpf']?.toString() ?? '',
      genero: json['genero']?.toString(),
      saudeCid: json['saude_cid']?.toString(),
      dataNasc: json['data_nasc'] != null 
          ? DateTime.tryParse(json['data_nasc'].toString())
          : null,
      gestPuerNutriz: json['gest_puer_nutriz']?.toString() ?? 'N',
      mobReduzida: json['mob_reduzida']?.toString() ?? 'N',
      cuidaOutrem: json['cuida_outrem']?.toString() ?? 'N',
      pcdOuMental: json['pcd_ou_mental']?.toString() ?? 'N',
      alergiaIntol: json['alergia_intol']?.toString(),
      subsPsicoativas: json['subs_psicoativas']?.toString(),
      medControlada: json['med_controlada']?.toString(),
      localRef: json['local_ref']?.toString(),
      evolucao: json['evolucao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'genero': genero,
      'saude_cid': saudeCid,
      'data_nasc': dataNasc?.toIso8601String()?.split('T')[0],
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
  }

  @override
  String toString() {
    return 'DemandaSaudeModel(cpf: $cpf, genero: $genero, saudeCid: $saudeCid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DemandaSaudeModel && other.cpf == cpf;
  }

  @override
  int get hashCode => cpf.hashCode;

  // Getters úteis
  bool get isGrupoPrioritario => 
      gestPuerNutriz == 'S' || 
      mobReduzida == 'S' || 
      pcdOuMental == 'S';

  String get statusSaude {
    if (isGrupoPrioritario) return 'Prioritário';
    if (saudeCid != null && saudeCid!.isNotEmpty) return 'Com CID';
    return 'Normal';
  }

  int? get idade {
    if (dataNasc == null) return null;
    final now = DateTime.now();
    int age = now.year - dataNasc!.year;
    if (now.month < dataNasc!.month || 
        (now.month == dataNasc!.month && now.day < dataNasc!.day)) {
      age--;
    }
    return age;
  }
}