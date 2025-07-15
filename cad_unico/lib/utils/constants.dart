class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://10.13.65.37:8001/api/';
  static const String apiVersion = 'v1';
  
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

// Helper class for responsive design
// class Responsive {
//   static bool isMobile(double width) => width < AppConstants.mobileBreakpoint;
//   static bool isTablet(double width) => width >= AppConstants.mobileBreakpoint && width < AppConstants.desktopBreakpoint;
//   static bool isDesktop(double width) => width >= AppConstants.desktopBreakpoint;
// }

// // Helper functions
// class AppUtils {
//   static String formatCpf(String cpf) {
//     if (cpf.length != 11) return cpf;
//     return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
//   }
  
//   static String formatTelefone(String telefone) {
//     if (telefone.length == 10) {
//       return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 6)}-${telefone.substring(6)}';
//     } else if (telefone.length == 11) {
//       return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}';
//     }
//     return telefone;
//   }
  
//   static String formatCep(String cep) {
//     if (cep.length != 8) return cep;
//     return '${cep.substring(0, 5)}-${cep.substring(5)}';
//   }
  
//   static String cleanCpf(String cpf) => cpf.replaceAll(RegExp(r'[^\d]'), '');
  
//   static String cleanTelefone(String telefone) => telefone.replaceAll(RegExp(r'[^\d]'), '');
  
//   static String cleanCep(String cep) => cep.replaceAll(RegExp(r'[^\d]'), '');
// }