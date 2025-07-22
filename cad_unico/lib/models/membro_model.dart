class Membro {
  final String cpf;
  final String nome;
  final String cpfResponsavel;
  final DateTime? timestamp;
  final String? status;
  final String? cpfResponsavelNome; // Campo adicional do serializer

  const Membro({
    required this.cpf,
    required this.nome,
    required this.cpfResponsavel,
    this.timestamp,
    this.status,
    this.cpfResponsavelNome,
  });

  // Factory constructor para criar instância a partir de JSON
  factory Membro.fromJson(Map<String, dynamic> json) => Membro(
      cpf: json['cpf'] ?? '',
      nome: json['nome'] ?? '',
      cpfResponsavel: json['cpf_responsavel'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'])
          : null,
      status: json['status'],
      cpfResponsavelNome: json['cpf_responsavel_nome'],
    );

  // Método para converter instância para JSON
  Map<String, dynamic> toJson() => {
      'cpf': cpf,
      'nome': nome,
      'cpf_responsavel': cpfResponsavel,
      'timestamp': timestamp?.toIso8601String(),
      'status': status,
      // Não incluir cpf_responsavel_nome no toJson pois é read_only
    };

  // Método copyWith para criar nova instância com campos modificados
  Membro copyWith({
    String? cpf,
    String? nome,
    String? cpfResponsavel,
    DateTime? timestamp,
    String? status,
    String? cpfResponsavelNome,
  }) => Membro(
      cpf: cpf ?? this.cpf,
      nome: nome ?? this.nome,
      cpfResponsavel: cpfResponsavel ?? this.cpfResponsavel,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      cpfResponsavelNome: cpfResponsavelNome ?? this.cpfResponsavelNome,
    );

  // Getters para propriedades calculadas
  bool get isAtivo => status == 'A';
  bool get isInativo => status == 'I';
  
  String get statusDescricao {
    switch (status) {
      case 'A':
        return 'Ativo';
      case 'I':
        return 'Inativo';
      case 'P':
        return 'Pendente';
      case 'B':
        return 'Bloqueado';
      default:
        return status ?? 'Não definido';
    }
  }

  String get nomeResponsavel => cpfResponsavelNome ?? 'Nome não informado';

  // Método para validar CPF básico (apenas formato)
  bool get cpfValido => cpf.isNotEmpty && 
           cpf.length == 11 && 
           RegExp(r'^\d{11}$').hasMatch(cpf);

  // Método para validar CPF do responsável
  bool get cpfResponsavelValido => cpfResponsavel.isNotEmpty && 
           cpfResponsavel.length == 11 && 
           RegExp(r'^\d{11}$').hasMatch(cpfResponsavel);

  // Método para formatar CPF para exibição
  String get cpfFormatado {
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }

  // Método para formatar CPF do responsável
  String get cpfResponsavelFormatado {
    if (cpfResponsavel.length == 11) {
      return '${cpfResponsavel.substring(0, 3)}.${cpfResponsavel.substring(3, 6)}.${cpfResponsavel.substring(6, 9)}-${cpfResponsavel.substring(9)}';
    }
    return cpfResponsavel;
  }

  // Método para formatar data
  String get timestampFormatado {
    if (timestamp == null) return 'Data não informada';
    
    return '${timestamp!.day.toString().padLeft(2, '0')}/'
           '${timestamp!.month.toString().padLeft(2, '0')}/'
           '${timestamp!.year} '
           '${timestamp!.hour.toString().padLeft(2, '0')}:'
           '${timestamp!.minute.toString().padLeft(2, '0')}';
  }

  // Método toString para debug
  @override
  String toString() => 'Membro{cpf: $cpf, nome: $nome, cpfResponsavel: $cpfResponsavel, status: $status}';

  // Operadores de igualdade
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Membro && other.cpf == cpf;
  }

  @override
  int get hashCode => cpf.hashCode;

  // Método para verificar se os dados são válidos
  bool get isValid => cpfValido && 
           nome.isNotEmpty && 
           nome.length >= 2 && 
           nome.length <= 150 &&
           cpfResponsavelValido;

  // Lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (!cpfValido) {
      errors.add('CPF inválido');
    }
    
    if (nome.isEmpty) {
      errors.add('Nome é obrigatório');
    } else if (nome.length < 2) {
      errors.add('Nome deve ter pelo menos 2 caracteres');
    } else if (nome.length > 150) {
      errors.add('Nome deve ter no máximo 150 caracteres');
    }
    
    if (!cpfResponsavelValido) {
      errors.add('CPF do responsável inválido');
    }
    
    return errors;
  }

  // Método estático para criar instância vazia/padrão
  static Membro empty() => const Membro(
      cpf: '',
      nome: '',
      cpfResponsavel: '',
      status: 'A',
    );

  // Método estático para criar instância com dados mínimos
  static Membro create({
    required String cpf,
    required String nome,
    required String cpfResponsavel,
    String status = 'A',
  }) => Membro(
      cpf: cpf,
      nome: nome,
      cpfResponsavel: cpfResponsavel,
      status: status,
      timestamp: DateTime.now(),
    );

  // Método para converter para mapa simples (para debug/log)
  Map<String, dynamic> toMap() => {
      'cpf': cpf,
      'nome': nome,
      'cpfResponsavel': cpfResponsavel,
      'timestamp': timestamp?.toIso8601String(),
      'status': status,
      'cpfResponsavelNome': cpfResponsavelNome,
      'isValid': isValid,
      'statusDescricao': statusDescricao,
    };
}