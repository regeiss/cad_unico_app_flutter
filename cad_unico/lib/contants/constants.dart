// lib/utils/constants.dart
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

class AppConstants {
  // ==========================================================================
  // CONFIGURAÇÕES DE API
  // ==========================================================================
  
  // URL base da API Django
  static const String apiBaseUrl = 'http://10.13.65.37:8001';
  
  // Endpoints da API
  static const String apiVersion = '/api/v1';
  static const String fullApiUrl = '$apiBaseUrl$apiVersion';
  
  // ==========================================================================
  // ENDPOINTS DE AUTENTICAÇÃO
  // ==========================================================================
  static const String authLogin = '$fullApiUrl/auth/login/';
  static const String authRefresh = '$fullApiUrl/auth/refresh/';
  static const String authVerify = '$fullApiUrl/auth/verify/';
  static const String authRegister = '$fullApiUrl/auth/register/';
  static const String authProfile = '$fullApiUrl/auth/profile/';
  static const String authLogout = '$fullApiUrl/auth/logout/';
  static const String authUser = '$fullApiUrl/auth/user/';
  
  // ==========================================================================
  // ENDPOINTS DE CADASTRO
  // ==========================================================================
  static const String cadastroBase = '$fullApiUrl/cadastro';
  static const String responsaveisEndpoint = '$cadastroBase/api/responsaveis/';
  static const String membrosEndpoint = '$cadastroBase/api/membros/';
  static const String demandasSaudeEndpoint = '$cadastroBase/api/demandas-saude/';
  static const String demandasEducacaoEndpoint = '$cadastroBase/api/demandas-educacao/';
  static const String demandasAmbienteEndpoint = '$cadastroBase/api/demandas-ambiente/';
  static const String demandasHabitacaoEndpoint = '$cadastroBase/api/demandas-habitacao/';
  static const String demandasInternasEndpoint = '$cadastroBase/api/demandas-internas/';
  static const String alojamentosEndpoint = '$cadastroBase/api/alojamentos/';
  static const String cepsAtingidosEndpoint = '$cadastroBase/api/ceps-atingidos/';
  static const String desaparecidosEndpoint = '$cadastroBase/api/desaparecidos/';
  
  // ==========================================================================
  // ENDPOINTS ESPECÍFICOS
  // ==========================================================================
  static const String responsavelComMembros = '/com_membros/';
  static const String responsavelComDemandas = '/com_demandas/';
  static const String buscarPorCpf = '/buscar_por_cpf/';
  static const String gruposPrioritarios = '/grupos_prioritarios/';
  
  // ==========================================================================
  // CONFIGURAÇÕES DE REQUISIÇÃO
  // ==========================================================================
  static const int timeoutDuration = 30; // segundos
  static const int maxRetryAttempts = 3;
  static const int pageSize = 20;
  
  // ==========================================================================
  // HEADERS HTTP
  // ==========================================================================
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // ==========================================================================
  // CHAVES DE STORAGE
  // ==========================================================================
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String lastLoginKey = 'last_login';
  
  // ==========================================================================
  // CONFIGURAÇÕES DO APP
  // ==========================================================================
  
  static const String appName = 'Cadastro Unificado';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema de Gestão de Cadastros e Demandas Sociais';
  
  // ==========================================================================
  // CONFIGURAÇÕES DE TAMANHO
  // ==========================================================================
  static const double tabletBreakpoint = 960;
  // ==========================================================================
  // MENSAGENS DE SUCESSO
  // ==========================================================================
  static const String loginSucess = 'Login realizado com sucesso!';
  static const String logoutSuccess = 'Logout realizado com sucesso!';
  static const String dataLoadedSuccess = 'Dados carregados com sucesso!';
  static const String responsavelCreatedSuccess = 'Responsável cadastrado com sucesso!';
  static const String responsavelUpdatedSuccess = 'Responsável atualizado com sucesso!';
  static const String membroCreatedSuccess = 'Membro cadastrado com sucesso!';
  static const String membroUpdatedSuccess = 'Membro atualizado com sucesso!';
  
  // ==========================================================================
  // MENSAGENS DE ERRO
  // ==========================================================================
  static const String loginError = 'Erro ao fazer login. Verifique suas credenciais.';
  static const String networkError = 'Erro de rede. Verifique sua conexão.';
  static const String serverError = 'Erro interno do servidor.';
  static const String timeoutError = 'Timeout na requisição.';
  static const String noDataFound = 'Nenhum dado encontrado.';
  static const String invalidCpfError = 'CPF inválido.';
  static const String cpfAlreadyExistsError = 'CPF já cadastrado.';
  static const String requiredFieldsError = 'Preencha todos os campos obrigatórios.';
  static const String accessDeniedError = 'Acesso negado.';
  static const String tokenExpiredError = 'Sessão expirada. Faça login novamente.';
  static const String passwordRequired = 'A senha é obrigatória.';
  static const String usernameRequired = 'O usuário é obrigatório.';
  static const String successUpdate = 'Dados atualizados com sucesso!';
  static const String successDelete = 'Registro excluído com sucesso!';
  static const String errorDelete = 'Erro ao excluir o registro.';
  static const String errorUpdate = 'Erro ao atualizar os dados.';
  static const String successSave = 'Dados atualizados com sucesso!';
  // ==========================================================================
  // VALIDAÇÕES
  // ==========================================================================
  static const int cpfLength = 11;
  static const int telefoneMinLength = 10;
  static const int cepLength = 8;
  static const int nomeMinLength = 2;
  static const int nomeMaxLength = 150;
  
  // ==========================================================================
  // CORES DO SISTEMA (para uso em componentes específicos)
  // ==========================================================================
  static const String primaryColorHex = '#1976D2';
  static const String secondaryColorHex = '#42A5F5';
  static const String successColorHex = '#4CAF50';
  static const String warningColorHex = '#FF9800';
  static const String errorColorHex = '#F44336';
  
  // ==========================================================================
  // CONFIGURAÇÕES DE DEBUG
  // ==========================================================================
  static const bool enableDebugMode = true; // Alterar para false em produção
  static const bool enableLogRequests = true;
  static const bool enableLogResponses = true;
  
  // ==========================================================================
  // URLs EXTERNAS
  // ==========================================================================
  static const String viaCepUrl = 'https://viacep.com.br/ws/';
  static const String documentationUrl = '$apiBaseUrl/api/docs/';
  static const String supportEmail = 'suporte@cadastrounificado.com';
  
  // ==========================================================================
  // Uso em widgets e componentes
  // ==========================================================================
  static const double borderRadius = 12.0;
  static const double margin = 8.0;
  static const double elevation = 4.0;
  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================
  
  /// Retorna a URL completa para buscar responsável por CPF
  static String getResponsavelByCpfUrl(String cpf) => '$responsaveisEndpoint$cpf/';
  
  /// Retorna a URL para responsável com membros
  static String getResponsavelComMembrosUrl(String cpf) => '$responsaveisEndpoint$cpf$responsavelComMembros';
  
  /// Retorna a URL para responsável com demandas
  static String getResponsavelComDemandasUrl(String cpf) => '$responsaveisEndpoint$cpf$responsavelComDemandas';
  
  /// Retorna a URL para buscar CEP no ViaCEP
  static String getViaCepUrl(String cep) => '$viaCepUrl$cep/json/';
  
  /// Retorna headers com token de autenticação
  static Map<String, String> getAuthHeaders(String token) => {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };

static const Map<String, IconData> systemIcons = {
    'dashboard': Icons.dashboard,
    'people': Icons.people,
    'person_add': Icons.person_add,
    'search': Icons.search,
    'filter': Icons.filter_list,
    'export': Icons.file_download,
    'settings': Icons.settings,
    'help': Icons.help_outline,
    'logout': Icons.logout,
    'refresh': Icons.refresh,
    'save': Icons.save,
    'cancel': Icons.cancel,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'add': Icons.add,
    'check': Icons.check,
    'warning': Icons.warning,
    'error': Icons.error,
    'info': Icons.info,
  };

  // Opções de Status
  static const Map<String, Map<String, dynamic>> statusOptions = {
    // Status gerais para responsáveis e membros
    'general': {
      'A': {
        'label': 'Ativo',
        'color': Colors.green,
        'icon': Icons.check_circle,
        'description': 'Registro ativo no sistema'
      },
      'I': {
        'label': 'Inativo',
        'color': Colors.red,
        'icon': Icons.cancel,
        'description': 'Registro inativo'
      },
      'P': {
        'label': 'Pendente',
        'color': Colors.orange,
        'icon': Icons.pending,
        'description': 'Aguardando verificação'
      },
      'B': {
        'label': 'Bloqueado',
        'color': Colors.grey,
        'icon': Icons.block,
        'description': 'Registro bloqueado'
      },
    },

    // Status de demandas internas
    'demandas': {
      'ABERTA': {
        'label': 'Aberta',
        'color': Colors.blue,
        'icon': Icons.assignment,
        'description': 'Demanda em aberto'
      },
      'EM_ANDAMENTO': {
        'label': 'Em Andamento',
        'color': Colors.orange,
        'icon': Icons.pending_actions,
        'description': 'Demanda sendo processada'
      },
      'CONCLUIDA': {
        'label': 'Concluída',
        'color': Colors.green,
        'icon': Icons.check_circle,
        'description': 'Demanda finalizada'
      },
      'CANCELADA': {
        'label': 'Cancelada',
        'color': Colors.red,
        'icon': Icons.cancel,
        'description': 'Demanda cancelada'
      },
      'AGUARDANDO_DOCUMENTOS': {
        'label': 'Aguardando Documentos',
        'color': Colors.amber,
        'icon': Icons.description,
        'description': 'Aguardando documentação'
      },
    },

    // Status de sim/não
    'boolean': {
      'S': {
        'label': 'Sim',
        'color': Colors.green,
        'icon': Icons.check,
        'description': 'Confirmado'
      },
      'N': {
        'label': 'Não',
        'color': Colors.red,
        'icon': Icons.close,
        'description': 'Negativo'
      },
    },

    // Status de saúde/grupos prioritários
    'saude': {
      'NORMAL': {
        'label': 'Normal',
        'color': Colors.green,
        'icon': Icons.health_and_safety,
        'description': 'Sem condições especiais'
      },
      'PRIORITARIO': {
        'label': 'Prioritário',
        'color': Colors.orange,
        'icon': Icons.priority_high,
        'description': 'Grupo prioritário'
      },
      'CRITICO': {
        'label': 'Crítico',
        'color': Colors.red,
        'icon': Icons.warning,
        'description': 'Situação crítica'
      },
    },

    // Status de vacinação
    'vacinacao': {
      'COMPLETA': {
        'label': 'Completa',
        'color': Colors.green,
        'icon': Icons.verified,
        'description': 'Vacinação em dia'
      },
      'PARCIAL': {
        'label': 'Parcial',
        'color': Colors.orange,
        'icon': Icons.pending,
        'description': 'Vacinação incompleta'
      },
      'PENDENTE': {
        'label': 'Pendente',
        'color': Colors.red,
        'icon': Icons.schedule,
        'description': 'Sem vacinação'
      },
    },

    // Status de turno escolar
    'turno': {
      'MATUTINO': {
        'label': 'Matutino',
        'color': Colors.blue,
        'icon': Icons.wb_sunny,
        'description': 'Período da manhã'
      },
      'VESPERTINO': {
        'label': 'Vespertino',
        'color': Colors.orange,
        'icon': Icons.wb_sunny_outlined,
        'description': 'Período da tarde'
      },
      'NOTURNO': {
        'label': 'Noturno',
        'color': Colors.indigo,
        'icon': Icons.nightlight_round,
        'description': 'Período da noite'
      },
      'INTEGRAL': {
        'label': 'Integral',
        'color': Colors.purple,
        'icon': Icons.all_inclusive,
        'description': 'Período integral'
      },
    },

    // Status de gênero
    'genero': {
      'MASCULINO': {
        'label': 'Masculino',
        'color': Colors.blue,
        'icon': Icons.male,
        'description': 'Gênero masculino'
      },
      'FEMININO': {
        'label': 'Feminino',
        'color': Colors.pink,
        'icon': Icons.female,
        'description': 'Gênero feminino'
      },
      'OUTROS': {
        'label': 'Outros',
        'color': Colors.purple,
        'icon': Icons.transgender,
        'description': 'Outros gêneros'
      },
      'NAO_INFORMADO': {
        'label': 'Não Informado',
        'color': Colors.grey,
        'icon': Icons.help_outline,
        'description': 'Não informado'
      },
    },
  };

  // Métodos auxiliares para trabalhar com status
  static Map<String, dynamic>? getStatusInfo(String category, String status) => statusOptions[category]?[status];

  static String getStatusLabel(String category, String status) => getStatusInfo(category, status)?['label'] ?? status;

  static Color getStatusColor(String category, String status) => getStatusInfo(category, status)?['color'] ?? Colors.grey;

  static IconData getStatusIcon(String category, String status) => getStatusInfo(category, status)?['icon'] ?? Icons.help_outline;

  static String getStatusDescription(String category, String status) => getStatusInfo(category, status)?['description'] ?? 'Status não encontrado';

  // Lista de opções para dropdowns
  static List<DropdownMenuItem<String>> getStatusDropdownItems(String category) {
    final options = statusOptions[category];
    if (options == null) return [];

    return options.entries.map((entry) => DropdownMenuItem<String>(
        value: entry.key,
        child: Row(
          children: [
            Icon(
              entry.value['icon'] as IconData,
              color: entry.value['color'] as Color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(entry.value['label'] as String),
          ],
        ),
      )).toList();
  }

  // Configurações de formulário
  static const int maxNomeLength = 150;
  static const int maxComplementoLength = 300;
  static const int maxObservacoesLength = 500;
  static const int minNomeLength = 2;
  // static const int cpfLength = 11;
  static const int phoneLength = 11;

  // Padrões de formatação
  static const String cpfMask = '000.000.000-00';
  static const String phoneMask = '(00) 00000-0000';
  static const String cepMask = '00000-000';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timestampFormat = 'dd/MM/yyyy HH:mm';

  // URLs e endpoints específicos
  static const String cepApiUrl = 'https://viacep.com.br/ws/';

  static const String demandasEndpoint = '/cadastro/api/demandas/';
  static const String buscarCepEndpoint = '/buscar-cep/';

  // Configurações de paginação
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 10;

  // Timeouts
  static const int defaultTimeout = 30; // segundos
  static const int uploadTimeout = 60; // segundos
  static const int searchTimeout = 10; // segundos

  // Debounce para pesquisa
  static const int searchDebounceMs = 500;

  // Configurações de cache
  static const int cacheExpirationMinutes = 30;
  static const String cacheKeyResponsaveis = 'responsaveis_cache';
  static const String cacheKeyMembros = 'membros_cache';

  // Chaves de armazenamento local
  static const String storageKeyUser = 'user_data';
  static const String storageKeyToken = 'auth_token';
  static const String storageKeySettings = 'app_settings';
  static const String storageKeyFilters = 'search_filters';

  // Configurações de imagem
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Estados dos UFs brasileiros
  static const List<String> estadosBrasil = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  // Regex patterns
 
  // Formatadores
  static String formatCpf(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCpf.length == 11) {
      return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
    }
    return cpf;
  }

  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    } else if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    }
    return phone;
  }

  static String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }

  // Cores do tema
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryDarkColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = Color(0xFF2196F3);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDarkColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}