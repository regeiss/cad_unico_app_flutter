// ignore_for_file: avoid_classes_with_only_static_members

class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://10.13.65.37:8001/api';
  static const String apiVersion = 'v1';
  // Endpoints da API
  static const String loginEndpoint = '/auth/login/';
  static const String userEndpoint = '/auth/user/';
  static const String logoutEndpoint = '/auth/logout/';
  
  // Timeouts
  static const int apiTimeout = 30000; // 30 segundos
  static const int connectTimeout = 10000; // 10 segundos
  // CHAVES DE ARMAZENAMENTO
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
   static const bool isDevelopment = true;
  static const bool enableDebugLogs = true;
  
  // URLs de teste
  static const String testApiUrl = 'http://localhost:8001';
  static const String prodApiUrl = 'https://api.cadastrounificado.com';
  
  // Obter URL da API baseada no ambiente
  static String get currentApiUrl => isDevelopment ? testApiUrl : prodApiUrl;
  // App Info
  static const String appName = 'Cadastro Unificado';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Status Options
  static const Map<String, String> statusOptions = {
    'A': 'Ativo',
    'I': 'Inativo',
  };
  
  // Gênero Options
  static const Map<String, String> generoOptions = {
    'M': 'Masculino',
    'F': 'Feminino',
    'O': 'Outro',
  };
  
  // Turno Options
  static const Map<String, String> turnoOptions = {
    'M': 'Manhã',
    'T': 'Tarde',
    'N': 'Noite',
  };
  
  // Vínculo Options (para desaparecidos)
  static const Map<String, String> vinculoOptions = {
    'Pai': 'Pai',
    'Mãe': 'Mãe',
    'Filho': 'Filho(a)',
    'Irmão': 'Irmão(ã)',
    'Cônjuge': 'Cônjuge',
    'Outro': 'Outro',
  };
  
  // Espécie Options (para animais)
  static const Map<String, String> especieOptions = {
    'Cão': 'Cão',
    'Gato': 'Gato',
    'Pássaro': 'Pássaro',
    'Outro': 'Outro',
  };
  
  // Porte Options (para animais)
  static const Map<String, String> porteOptions = {
    'P': 'Pequeno',
    'M': 'Médio',
    'G': 'Grande',
  };
  
  // Material Options (habitação)
  static const Map<String, String> materialOptions = {
    'Alvenaria': 'Alvenaria',
    'Madeira': 'Madeira',
    'Misto': 'Misto',
    'Outro': 'Outro',
  };
  
  // Relação Imóvel Options
  static const Map<String, String> relacaoImovelOptions = {
    'Próprio': 'Próprio',
    'Alugado': 'Alugado',
    'Cedido': 'Cedido',
    'Ocupação': 'Ocupação',
  };
  
  // Uso Imóvel Options
  static const Map<String, String> usoImovelOptions = {
    'Residencial': 'Residencial',
    'Comercial': 'Comercial',
    'Misto': 'Misto',
  };
  
  // Regex Patterns
  static const String cpfPattern = r'^\d{11}$';
  static const String telefonePattern = r'^\d{10,11}$';
  static const String cepPattern = r'^\d{8}$';
  static const String emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
  
  // Validation Messages
  static const String invalidCpfMessage = 'CPF inválido';
  static const String invalidTelefoneMessage = 'Telefone inválido';
  static const String invalidCepMessage = 'CEP inválido';
  static const String invalidEmailMessage = 'E-mail inválido';
  static const String passwordTooShortMessage = 'A senha deve ter pelo menos $minPasswordLength caracteres';
  static const String passwordTooLongMessage = 'A senha deve ter no máximo $maxPasswordLength caracteres';
  static const String requiredFieldMessage = 'Este campo é obrigatório';
  static const String invalidFieldMessage = 'Campo inválido';
  static const String invalidDateMessage = 'Data inválida';
  static const String invalidTimeMessage = 'Hora inválida';
  static const String invalidDateTimeMessage = 'Data e hora inválidas';
  static const String invalidNumberMessage = 'Número inválido';
  static const String invalidUrlMessage = 'URL inválida';
  static const String usernameRequired =  'Nome de usuário é obrigatório';
  static const String passwordRequired = 'Senha é obrigatória';
  static const String confirmPasswordRequired = 'Confirmação de senha é obrigatória';
  // Confirmation Messages
  static const String confirmDelete = 'Você tem certeza que deseja excluir este item?';
  static const String confirmLogout = 'Você tem certeza que deseja sair?';
  static const String confirmDiscardChanges = 'Você tem certeza que deseja descartar as alterações?';
  static const String confirmExit = 'Você tem certeza que deseja sair do aplicativo?';
  // Info Messages
   
  // Error Messages
  static const String errorGeneral = 'Ocorreu um erro inesperado';
  static const String errorNetwork = 'Erro de conexão com o servidor';
  static const String errorAuth = 'Erro de autenticação';
  static const String errorNotFound = 'Dados não encontrados';
  static const String errorValidation = 'Dados inválidos';
  
  // Success Messages
  static const String successSave = 'Dados salvos com sucesso';
  static const String successUpdate = 'Dados atualizados com sucesso';
  static const String successDelete = 'Dados excluídos com sucesso';
  static const String successLogin = 'Login realizado com sucesso';
  
  // UI Constants
  static const double borderRadius = 8.0;
  static const double elevation = 2.0;
  static const double padding = 16.0;
  static const double margin = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}
