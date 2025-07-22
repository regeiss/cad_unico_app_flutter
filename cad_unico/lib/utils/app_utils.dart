// ignore_for_file: avoid_classes_with_only_static_members

class AppUtils {
  // Formatação de CPF
  static String formatCpf(String cpf) {
    final cleanedCpf = cleanCpf(cpf);
    if (cleanedCpf.length != 11) return cpf;
    
    return '${cleanedCpf.substring(0, 3)}.${cleanedCpf.substring(3, 6)}.${cleanedCpf.substring(6, 9)}-${cleanedCpf.substring(9)}';
  }

  static String cleanCpf(String cpf) => cpf.replaceAll(RegExp(r'[^0-9]'), '');

  // Formatação de Telefone
  static String formatTelefone(String telefone) {
    final cleanedTelefone = cleanTelefone(telefone);
    
    if (cleanedTelefone.length == 10) {
      return '(${cleanedTelefone.substring(0, 2)}) ${cleanedTelefone.substring(2, 6)}-${cleanedTelefone.substring(6)}';
    } else if (cleanedTelefone.length == 11) {
      return '(${cleanedTelefone.substring(0, 2)}) ${cleanedTelefone.substring(2, 7)}-${cleanedTelefone.substring(7)}';
    }
    
    return telefone;
  }

  static String cleanTelefone(String telefone) => telefone.replaceAll(RegExp(r'[^0-9]'), '');

  // Formatação de CEP
  static String formatCep(String cep) {
    final cleanedCep = cleanCep(cep);
    if (cleanedCep.length != 8) return cep;
    
    return '${cleanedCep.substring(0, 5)}-${cleanedCep.substring(5)}';
  }

  static String cleanCep(String cep) => cep.replaceAll(RegExp(r'[^0-9]'), '');

  // Validação de CPF
  static bool isValidCpf(String cpf) {
    final onlyDigitsCpf = cleanCpf(cpf);
    
    if (onlyDigitsCpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(onlyDigitsCpf)) return false;
    
    // Validação dos dígitos verificadores
    int sum = 0;
    
    // Primeiro dígito verificador
    for (int i = 0; i < 9; i++) {
      sum += int.parse(onlyDigitsCpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;
    
    if (int.parse(onlyDigitsCpf[9]) != firstDigit) return false;
    
    // Segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(onlyDigitsCpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;
    
    return int.parse(onlyDigitsCpf[10]) == secondDigit;
  }

  // Formatação de data
  static String formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  // Formatação de data e hora
  static String formatDateTime(DateTime dateTime) => '${formatDate(dateTime)} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  // Capitalizar primeira letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalizar cada palavra
  static String capitalizeWords(String text) => text.split(' ').map(capitalize).join(' ');
}