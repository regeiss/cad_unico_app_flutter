// // lib/utils/constants.dart
// ignore_for_file: avoid_classes_with_only_static_members
import 'package:flutter/material.dart';

class AppConstants {
  // Informações da aplicação
  static const String appName = 'Cadastro Unificado';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Sistema de Gestão de Cadastros e Demandas Sociais';

  // API Configuration
  static const String apiBaseUrl = 'http://10.13.65.37:8001';
  static const int apiTimeout = 30000; // 30 seconds

  // Paginação
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validações
  static const int minPasswordLength = 6;
  static const int maxNameLength = 150;
  static const int maxDescriptionLength = 500;

  // Breakpoints para responsividade
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ===== ROTAS =====
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String responsaveisRoute = '/responsaveis';
  static const String responsavelDetalhesRoute = '/responsaveis/detalhes';
  static const String responsavelFormRoute = '/responsaveis/form';
  static const String membrosRoute = '/membros';
  static const String membroFormRoute = '/membros/form';
  static const String demandasSaudeRoute = '/demandas/saude';
  static const String demandasEducacaoRoute = '/demandas/educacao';
  static const String demandasAmbienteRoute = '/demandas/ambiente';
  static const String demandasHabitacaoRoute = '/demandas/habitacao';
  static const String demandasInternasRoute = '/demandas/internas';
  static const String alojamentosRoute = '/alojamentos';
  static const String desaparecidosRoute = '/desaparecidos';
  static const String perfilRoute = '/perfil';
  static const String configuracoesRoute = '/configuracoes';
  static const String sobreRoute = '/sobre';
  
  // ===== CONFIGURAÇÕES DE DEBUG =====
  static const bool enableDebugMode = false;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  
  // ===== LIMITES =====
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  // Durações de animação
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Raio de bordas
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Espaçamentos
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Altura de componentes
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 80.0;

  // URLs externas
  static const String viaCepBaseUrl = 'https://viacep.com.br/ws';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportUrl = 'https://example.com/support';

  // Mensagens padrão
  static const String defaultErrorMessage =
      'Ocorreu um erro inesperado. Tente novamente.';
  static const String networkErrorMessage =
      'Erro de conexão. Verifique sua internet.';
  static const String timeoutErrorMessage =
      'Tempo limite esgotado. Tente novamente.';
  static const String unauthorizedMessage =
      'Sessão expirada. Faça login novamente.';

  // Labels e placeholders
  static const String loginButtonLabel = 'Entrar';
  static const String logoutButtonLabel = 'Sair';
  static const String registerButtonLabel = 'Registrar';
  static const String cancelButtonLabel = 'Cancelar';
  static const String deleteButtonLabel = 'Excluir';
  static const String editButtonLabel = 'Editar';
  static const String createButtonLabel = 'Criar';
  static const String updateButtonLabel = 'Atualizar';
  static const String searchButtonLabel = 'Buscar';
  static const String clearButtonLabel = 'Limpar';

  static const String saveButtonLabel = 'Salvar';
  static const String usernameLabel = 'Usuário';
  static const String usernamePlaceholder = 'Digite seu usuário';
  static const String passwordLabel = 'Senha';
  static const String passwordPlaceholder = 'Digite sua senha';
  static const String confirmPasswordLabel = 'Confirmar Senha';
  static const String confirmPasswordPlaceholder = 'Confirme sua senha';
  static const String emailLabel = 'Email';
  static const String emailPlaceholder = 'Digite seu email';
  static const String firstNameLabel = 'Nome';
  static const String firstNamePlaceholder = 'Digite seu nome';
  static const String lastNameLabel = 'Sobrenome';
  static const String lastNamePlaceholder = 'Digite seu sobrenome';
  static const int passwordMinLength = 10;
  static const String weakPasswordMessage =
      'Senha fraca. Deve ter pelo menos $passwordMinLength caracteres.';
  static const String phoneLabel = 'Telefone';
  static const String phonePlaceholder = 'Digite seu telefone';
  // Mensagens de sucesso
  static const String loginSuccessMessage = 'Login realizado com sucesso!';
  static const String logoutSuccessMessage = 'Logout realizado com sucesso!';
  static const String saveSuccessMessage = 'Dados salvos com sucesso!';
  static const String updateSuccessMessage = 'Dados atualizados com sucesso!';
  static const String deleteSuccessMessage = 'Dados removidos com sucesso!';
  static const String createSuccessMessage = 'Registro criado com sucesso!';

  // Mensagens de validação
  static const String requiredFieldMessage = 'Este campo é obrigatório';
  static const String invalidEmailMessage = 'Email inválido';
  static const String invalidCpfMessage = 'CPF inválido';
  static const String invalidPhoneMessage = 'Telefone inválido';
  static const String invalidCepMessage = 'CEP inválido';

// Validações de login
  static const String usernameRequiredMessage = 'Username é obrigatório';
  static const String passwordRequiredMessage = 'Senha é obrigatória';
  static const String invalidCredentialsMessage = 'Credenciais inválidas';
  static const String accountDisabledMessage = 'Conta desativada';
  static const String passwordsDontMatchMessage = 'Senhas não conferem';
  static const String passwordTooShortMessage =
      'Senha deve ter pelo menos 6 caracteres';
  // Mensagens de erro
  static const String loginError =
      'Erro ao fazer login. Verifique suas credenciais.';
  static const String networkError = 'Erro de rede. Verifique sua conexão.';
  static const String serverError = 'Erro interno do servidor.';
  static const String timeoutError = 'Timeout na requisição.';
  static const String noDataFound = 'Nenhum dado encontrado.';
  static const String invalidCpfError = 'CPF inválido.';
  static const String cpfAlreadyExistsError = 'CPF já cadastrado.';
  static const String requiredFieldsError =
      'Preencha todos os campos obrigatórios.';
  static const String accessDeniedError = 'Acesso negado.';
  static const String tokenExpiredError =
      'Sessão expirada. Faça login novamente.';
  static const String passwordRequired = 'A senha é obrigatória.';
  static const String usernameRequired = 'O usuário é obrigatório.';
  static const String successUpdate = 'Dados atualizados com sucesso!';
  static const String successDelete = 'Registro excluído com sucesso!';
  static const String errorDelete = 'Erro ao excluir o registro.';
  static const String errorUpdate = 'Erro ao atualizar os dados.';
  static const String successSave = 'Dados atualizados com sucesso!';

  // Status codes
  static const List<String> statusOptions = ['A', 'I', 'P', 'B'];
  static const Map<String, String> statusLabels = {
    'A': 'Ativo',
    'I': 'Inativo',
    'P': 'Pendente',
    'B': 'Bloqueado',
  };

  // Gêneros
  static const List<String> genderOptions = ['M', 'F', 'O'];
  static const Map<String, String> genderLabels = {
    'M': 'Masculino',
    'F': 'Feminino',
    'O': 'Outro',
  };

  // Tipos de demanda
  static const List<String> demandTypes = [
    'saude',
    'educacao',
    'habitacao',
    'ambiente',
    'interna'
  ];

  static const Map<String, String> demandTypeLabels = {
    'saude': 'Saúde',
    'educacao': 'Educação',
    'habitacao': 'Habitação',
    'ambiente': 'Meio Ambiente',
    'interna': 'Demanda Interna',
  };

  // Cores do sistema
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = Color(0xFF2196F3);

  // Cores de status
  static const Map<String, Color> statusColors = {
    'A': Color(0xFF4CAF50), // Verde para ativo
    'I': Color(0xFFB00020), // Vermelho para inativo
    'P': Color(0xFFFF9800), // Laranja para pendente
    'B': Color(0xFF424242), // Cinza para bloqueado
  };

  // Ícones do sistema
  static const Map<String, IconData> demandTypeIcons = {
    'saude': Icons.local_hospital,
    'educacao': Icons.school,
    'habitacao': Icons.home,
    'ambiente': Icons.eco,
    'interna': Icons.assignment,
  };

  static const Map<String, IconData> statusIcons = {
    'A': Icons.check_circle,
    'I': Icons.cancel,
    'P': Icons.schedule,
    'B': Icons.block,
  };

   // ===== ÍCONES =====
  static const IconData dashboardIcon = Icons.dashboard;
  static const IconData responsaveisIcon = Icons.people;
  static const IconData membrosIcon = Icons.family_restroom;
  static const IconData demandasIcon = Icons.assignment;
  static const IconData saudeIcon = Icons.local_hospital;
  static const IconData educacaoIcon = Icons.school;
  static const IconData ambienteIcon = Icons.pets;
  static const IconData habitacaoIcon = Icons.home;
  static const IconData internasIcon = Icons.business;
  static const IconData alojamentosIcon = Icons.hotel;
  static const IconData desaparecidosIcon = Icons.search;
  static const IconData configuracoesIcon = Icons.settings;
  static const IconData perfilIcon = Icons.person;
  static const IconData sairIcon = Icons.exit_to_app;
  static const IconData sobreIcon = Icons.info;
  static const IconData ajudaIcon = Icons.help;
  static const IconData buscarIcon = Icons.search;
  static const IconData filtrarIcon = Icons.filter_list;
  static const IconData adicionarIcon = Icons.add;
  static const IconData editarIcon = Icons.edit;
  static const IconData excluirIcon = Icons.delete;
  static const IconData visualizarIcon = Icons.visibility;
  static const IconData imprimirIcon = Icons.print;
  static const IconData exportarIcon = Icons.file_download;
  static const IconData atualizarIcon = Icons.refresh;
  
  // ===== BREAKPOINTS RESPONSIVOS =====
  // Configurações de cache
  static const Duration cacheExpiration = Duration(minutes: 30);
  static const int maxCacheSize = 100; // MB

  // Configurações de imagem
  static const int maxImageSize = 5; // MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;

  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Formatos de data
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ssZ';

  // Configurações de localização
  static const String defaultLocale = 'pt_BR';
  static const String defaultTimezone = 'America/Sao_Paulo';

  // Limites de busca
  static const int minSearchLength = 2;
  static const int maxSearchLength = 100;
  static const Duration searchDebounceTime = Duration(milliseconds: 500);

  // Configurações de paginação
  static const int defaultPageNumber = 1;
  static const List<int> pageSizeOptions = [10, 20, 50, 100];

  // Estados brasileiros
  static const List<String> brazilianStates = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO'
  ];

  static const Map<String, String> stateNames = {
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  // Padrões de expressão regular
  // static const String cpfPattern = r'^\d{3}\.\d{3}\.\d{3}-\d{2};
  // static const String phonePattern = r'^\(\d{2}\)\s\d{4,5}-\d{4};
  // static const String cepPattern = r'^\d{5}-\d{3};
  // static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,};

  // Animation Durations
  static const Duration mediumAnimation = Duration(milliseconds: 300);

  // Sidebar Dimensions
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 70.0;

  // Icons
  static const IconData logoutIcon = Icons.logout;
  static const IconData settingsIcon = Icons.settings;
  static const IconData helpIcon = Icons.help_outline;
  static const IconData homeIcon = Icons.home;
  static const IconData userIcon = Icons.person;
  static const IconData notificationsIcon = Icons.notifications;
  static const IconData searchIcon = Icons.search;
  static const IconData addIcon = Icons.add;
  static const IconData editIcon = Icons.edit;
  static const IconData deleteIcon = Icons.delete;
  static const IconData refreshIcon = Icons.refresh;
  static const IconData closeIcon = Icons.close;
  static const IconData checkIcon = Icons.check_circle;
  static const IconData errorIcon = Icons.error_outline;
  static const IconData infoIcon = Icons.info_outline;
  static const IconData warningIcon = Icons.warning_amber_outlined;
  static const IconData uploadIcon = Icons.upload_file;
  static const IconData downloadIcon = Icons.download;    
  static const IconData filterIcon = Icons.filter_list;
  static const IconData sortIcon = Icons.sort;
  static const IconData visibilityIcon = Icons.visibility;
  static const IconData visibilityOffIcon = Icons.visibility_off;
  static const IconData calendarIcon = Icons.calendar_today;
  static const IconData locationIcon = Icons.location_on; 
  static const IconData phoneIcon = Icons.phone;
  static const IconData emailIcon = Icons.email;
  static const IconData lockIcon = Icons.lock;
  static const IconData unlockIcon = Icons.lock_open;
  static const IconData uploadFileIcon = Icons.file_upload;
  static const IconData downloadFileIcon = Icons.file_download;
  static const IconData attachmentIcon = Icons.attach_file;
  static const IconData membroIcon = Icons.group;
  static const IconData demandaIcon = Icons.chat_bubble_outline;
  static const IconData responsavelIcon = Icons.feedback; 

  // Display
  static const String displayName = 'Cadastro Unificado';
  // Configurações de tema
  static const double defaultElevation = 2.0;
  static const double cardElevation = 4.0;
  static const double modalElevation = 8.0;

  // Configurações de feedback
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration dialogAutoCloseDuration = Duration(seconds: 5);

  // Configurações de acessibilidade
  static const double minTouchTargetSize = 48.0;
  static const Duration accessibilityTimeout = Duration(seconds: 10);

  // Configurações de fontes
  static const String defaultFontFamily = 'Roboto';
  static const double defaultFontSize = 16.0;
  static const double smallFontSize = 12.0;
  static const double largeFontSize = 20.0;
  static const double titleFontSize = 24.0;
  static const double headlineFontSize = 32.0;

  // Links úteis
  static const Map<String, String> socialLinks = {
    'facebook': 'https://facebook.com',
    'twitter': 'https://twitter.com',
    'instagram': 'https://instagram.com',
    'linkedin': 'https://linkedin.com',
  };

  // Configurações de desenvolvimento
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // Métodos utilitários
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static String getStatusLabel(String status) => statusLabels[status] ?? status;

  static Color getStatusColor(String status) =>
      statusColors[status] ?? Colors.grey;

  static String getGenderLabel(String gender) => genderLabels[gender] ?? gender;

  static String getDemandTypeLabel(String type) =>
      demandTypeLabels[type] ?? type;

  static IconData getDemandTypeIcon(String type) =>
      demandTypeIcons[type] ?? Icons.help_outline;

  static IconData getStatusIcon(String status) =>
      statusIcons[status] ?? Icons.help_outline;

  static String getStateName(String stateCode) =>
      stateNames[stateCode] ?? stateCode;
}
