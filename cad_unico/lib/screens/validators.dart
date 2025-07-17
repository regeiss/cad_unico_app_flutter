 // Regex patterns
//  class Validators {
//   static const String cpfPattern = r'^\d{3}\.\d{3}\.\d{3}-\d{2};
//   static const String phonePattern = r'^\(\d{2}\) \d{4,5}-\d{4};
//   static const String cepPattern = r'^\d{5}-\d{3};
//   static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,};

//   // Validadores customizados
  
  
//   static String? get requiredField => null;
  
//   static Object get cpfLength => null;static String? validateNome(String? value) {
//     if (value == null || value.isEmpty) {
//       return requiredField;
//     }
//     if (value.length < minNomeLength) {
//       return 'Nome deve ter pelo menos $minNomeLength caracteres';
//     }
//     if (value.length > maxNomeLength) {
//       return 'Nome deve ter no máximo $maxNomeLength caracteres';
//     }
//     return null;
//   }

//   static String? validateCpf(String? value) {
//     if (value == null || value.isEmpty) {
//       return requiredField;
//     }
//     // Remove formatação
//     final cleanCpf = value.replaceAll(RegExp(r'[^\d]'), '');
//     if (cleanCpf.length != cpfLength) {
//       return invalidCpf;
//     }
//     // Validação básica de CPF (pode ser expandida)
//     if (cleanCpf == '00000000000' || 
//         cleanCpf == '11111111111' || 
//         cleanCpf == '22222222222' ||
//         cleanCpf == '33333333333' ||
//         cleanCpf == '44444444444' ||
//         cleanCpf == '55555555555' ||
//         cleanCpf == '66666666666' ||
//         cleanCpf == '77777777777' ||
//         cleanCpf == '88888888888' ||
//         cleanCpf == '99999999999') {
//       return invalidCpf;
//     }
//     return null;
//   }

//   static String? validateTelefone(String? value) {
//     if (value == null || value.isEmpty) {
//       return null; // Telefone é opcional
//     }
//     final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
//     if (cleanPhone.length < 10 || cleanPhone.length > 11) {
//       return invalidPhone;
//     }
//     return null;
//   }

//   static String? validateCep(String? value) {
//     if (value == null || value.isEmpty) {
//       return requiredField;
//     }
//     final cleanCep = value.replaceAll(RegExp(r'[^\d]'), '');
//     if (cleanCep.length != cepLength) {
//       return invalidCep;
//     }
//     return null;
//   }

//   static String? validateNumero(String? value) {
//     if (value == null || value.isEmpty) {
//       return requiredField;
//     }
//     final numero = int.tryParse(value);
//     if (numero == null || numero <= 0) {
//       return invalidNumber;
//     }
//     return null;
//   }

//   // Formatadores
//   static String formatCpf(String cpf) {
//     final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
//     if (cleanCpf.length == 11) {
//       return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
//     }
//     return cpf;
//   }

//   static String formatPhone(String phone) {
//     final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
//     if (cleanPhone.length == 11) {
//       return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
//     } else if (cleanPhone.length == 10) {
//       return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
//     }
//     return phone;
//   }

//   static String formatCep(String cep) {
//     final cleanCep = cep.replaceAll(RegExp(r'[^\d]'), '');
//     if (cleanCep.length == 8) {
//       return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
//     }
//     return cep;
//   }
//  }
// Ícones do sistema
  // static const Map<String, IconData> systemIcons = {
  //   'dashboard': Icons.dashboard,
  //   'people': Icons.people,
  //   'person_add': Icons.person_add,
  //   'search': Icons.search,
  //   'filter': Icons.filter_list,
  //   'export': Icons.file_download,
  //   'settings': Icons.settings,
  //   'help': Icons.help_outline,
  //   'logout': Icons.logout,
  //   'refresh': Icons.refresh,
  //   'save': Icons.save,
  //   'cancel': Icons.cancel,
  //   'edit': Icons.edit,
  //   'delete': Icons.delete,
  //   'add': Icons.add,
  //   'check': Icons.check,
  //   'warning': Icons.warning,
  //   'error': Icons.error,
  //   'info': Icons.info,
  // };

  // // Opções de Status
  // static const Map<String, Map<String, dynamic>> statusOptions = {
  //   // Status gerais para responsáveis e membros
  //   'general': {
  //     'A': {
  //       'label': 'Ativo',
  //       'color': Colors.green,
  //       'icon': Icons.check_circle,
  //       'description': 'Registro ativo no sistema'
  //     },
  //     'I': {
  //       'label': 'Inativo',
  //       'color': Colors.red,
  //       'icon': Icons.cancel,
  //       'description': 'Registro inativo'
  //     },
  //     'P': {
  //       'label': 'Pendente',
  //       'color': Colors.orange,
  //       'icon': Icons.pending,
  //       'description': 'Aguardando verificação'
  //     },
  //     'B': {
  //       'label': 'Bloqueado',
  //       'color': Colors.grey,
  //       'icon': Icons.block,
  //       'description': 'Registro bloqueado'
  //     },
  //   },

  //   // Status de demandas internas
  //   'demandas': {
  //     'ABERTA': {
  //       'label': 'Aberta',
  //       'color': Colors.blue,
  //       'icon': Icons.assignment,
  //       'description': 'Demanda em aberto'
  //     },
  //     'EM_ANDAMENTO': {
  //       'label': 'Em Andamento',
  //       'color': Colors.orange,
  //       'icon': Icons.pending_actions,
  //       'description': 'Demanda sendo processada'
  //     },
  //     'CONCLUIDA': {
  //       'label': 'Concluída',
  //       'color': Colors.green,
  //       'icon': Icons.check_circle,
  //       'description': 'Demanda finalizada'
  //     },
  //     'CANCELADA': {
  //       'label': 'Cancelada',
  //       'color': Colors.red,
  //       'icon': Icons.cancel,
  //       'description': 'Demanda cancelada'
  //     },
  //     'AGUARDANDO_DOCUMENTOS': {
  //       'label': 'Aguardando Documentos',
  //       'color': Colors.amber,
  //       'icon': Icons.description,
  //       'description': 'Aguardando documentação'
  //     },
  //   },

  //   // Status de sim/não
  //   'boolean': {
  //     'S': {
  //       'label': 'Sim',
  //       'color': Colors.green,
  //       'icon': Icons.check,
  //       'description': 'Confirmado'
  //     },
  //     'N': {
  //       'label': 'Não',
  //       'color': Colors.red,
  //       'icon': Icons.close,
  //       'description': 'Negativo'
  //     },
  //   },

  //   // Status de saúde/grupos prioritários
  //   'saude': {
  //     'NORMAL': {
  //       'label': 'Normal',
  //       'color': Colors.green,
  //       'icon': Icons.health_and_safety,
  //       'description': 'Sem condições especiais'
  //     },
  //     'PRIORITARIO': {
  //       'label': 'Prioritário',
  //       'color': Colors.orange,
  //       'icon': Icons.priority_high,
  //       'description': 'Grupo prioritário'
  //     },
  //     'CRITICO': {
  //       'label': 'Crítico',
  //       'color': Colors.red,
  //       'icon': Icons.warning,
  //       'description': 'Situação crítica'
  //     },
  //   },

  //   // Status de vacinação
  //   'vacinacao': {
  //     'COMPLETA': {
  //       'label': 'Completa',
  //       'color': Colors.green,
  //       'icon': Icons.verified,
  //       'description': 'Vacinação em dia'
  //     },
  //     'PARCIAL': {
  //       'label': 'Parcial',
  //       'color': Colors.orange,
  //       'icon': Icons.pending,
  //       'description': 'Vacinação incompleta'
  //     },
  //     'PENDENTE': {
  //       'label': 'Pendente',
  //       'color': Colors.red,
  //       'icon': Icons.schedule,
  //       'description': 'Sem vacinação'
  //     },
  //   },

  //   // Status de turno escolar
  //   'turno': {
  //     'MATUTINO': {
  //       'label': 'Matutino',
  //       'color': Colors.blue,
  //       'icon': Icons.wb_sunny,
  //       'description': 'Período da manhã'
  //     },
  //     'VESPERTINO': {
  //       'label': 'Vespertino',
  //       'color': Colors.orange,
  //       'icon': Icons.wb_sunny_outlined,
  //       'description': 'Período da tarde'
  //     },
  //     'NOTURNO': {
  //       'label': 'Noturno',
  //       'color': Colors.indigo,
  //       'icon': Icons.nightlight_round,
  //       'description': 'Período da noite'
  //     },
  //     'INTEGRAL': {
  //       'label': 'Integral',
  //       'color': Colors.purple,
  //       'icon': Icons.all_inclusive,
  //       'description': 'Período integral'
  //     },
  //   },

  //   // Status de gênero
  //   'genero': {
  //     'MASCULINO': {
  //       'label': 'Masculino',
  //       'color': Colors.blue,
  //       'icon': Icons.male,
  //       'description': 'Gênero masculino'
  //     },
  //     'FEMININO': {
  //       'label': 'Feminino',
  //       'color': Colors.pink,
  //       'icon': Icons.female,
  //       'description': 'Gênero feminino'
  //     },
  //     'OUTROS': {
  //       'label': 'Outros',
  //       'color': Colors.purple,
  //       'icon': Icons.transgender,
  //       'description': 'Outros gêneros'
  //     },
  //     'NAO_INFORMADO': {
  //       'label': 'Não Informado',
  //       'color': Colors.grey,
  //       'icon': Icons.help_outline,
  //       'description': 'Não informado'
  //     },
  //   },
  // };

  // // Métodos auxiliares para trabalhar com status
  // static Map<String, dynamic>? getStatusInfo(String category, String status) {
  //   return statusOptions[category]?[status];
  // }

  // static String getStatusLabel(String category, String status) {
  //   return getStatusInfo(category, status)?['label'] ?? status;
  // }

  // static Color getStatusColor(String category, String status) {
  //   return getStatusInfo(category, status)?['color'] ?? Colors.grey;
  // }

  // static IconData getStatusIcon(String category, String status) {
  //   return getStatusInfo(category, status)?['icon'] ?? Icons.help_outline;
  // }

  // static String getStatusDescription(String category, String status) {
  //   return getStatusInfo(category, status)?['description'] ?? 'Status não encontrado';
  // }

  // // Lista de opções para dropdowns
  // static List<DropdownMenuItem<String>> getStatusDropdownItems(String category) {
  //   final options = statusOptions[category];
  //   if (options == null) return [];

  //   return options.entries.map((entry) {
  //     return DropdownMenuItem<String>(
  //       value: entry.key,
  //       child: Row(
  //         children: [
  //           Icon(
  //             entry.value['icon'] as IconData,
  //             color: entry.value['color'] as Color,
  //             size: 16,
  //           ),
  //           const SizedBox(width: 8),
  //           Text(entry.value['label'] as String),
  //         ],
  //       ),
  //     );
  //   }).toList();
  // }