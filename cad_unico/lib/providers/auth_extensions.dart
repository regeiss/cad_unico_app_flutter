import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

/// Extensions para AuthProvider com funcionalidades adicionais
extension AuthProviderExtensions on AuthProvider {
  /// Verifica se o usuário está logado e tem dados válidos
  bool get hasValidUser =>
      currentUser != null &&
      currentUser!.id != null &&
      currentUser!.username.isNotEmpty;

  /// Verifica se o usuário é administrador
  bool get isAdmin => currentUser != null && currentUser!.isStaff == true;

  /// Obtém o nome de exibição do usuário
  String get displayName {
    if (currentUser == null) return 'Usuário';

    final firstName = currentUser!.firstName;
    final lastName = currentUser!.lastName;

    if (firstName != null && firstName.isNotEmpty) {
      if (lastName != null && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }

    return currentUser!.username;
  }

  /// Obtém as iniciais do usuário para avatar
  String get userInitials {
    if (currentUser == null) return '??';

    final firstName = currentUser!.firstName;
    final lastName = currentUser!.lastName;

    if (firstName != null && firstName.isNotEmpty) {
      String initials = firstName[0].toUpperCase();
      if (lastName != null && lastName.isNotEmpty) {
        initials += lastName[0].toUpperCase();
      }
      return initials;
    }

    return currentUser!.username.isNotEmpty
        ? currentUser!.username[0].toUpperCase()
        : '?';
  }

  /// Verifica se o usuário tem email válido
  bool get hasValidEmail =>
      currentUser != null &&
      currentUser!.email != null &&
      currentUser!.email!.isNotEmpty &&
      currentUser!.email!.contains('@');

  /// Verifica se o perfil do usuário está completo
  bool get isProfileComplete {
    if (currentUser == null) return false;

    return currentUser!.username.isNotEmpty &&
        hasValidEmail &&
        currentUser!.firstName != null &&
        currentUser!.firstName!.isNotEmpty;
  }

  /// Obtém a data de cadastro formatada
  String get formattedJoinDate {
    if (currentUser?.dateJoined == null) return 'Data não disponível';

    final date = currentUser!.dateJoined!;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Verifica se o usuário está ativo
  bool get isUserActive => currentUser?.isActive == true;

  /// Obtém informações resumidas do usuário
  Map<String, dynamic> get userSummary {
    if (currentUser == null) {
      return {
        'isLoggedIn': false,
        'displayName': 'Não logado',
        'initials': '?',
        'isAdmin': false,
        'isActive': false,
      };
    }

    return {
      'isLoggedIn': true,
      'id': currentUser!.id,
      'username': currentUser!.username,
      'displayName': displayName,
      'initials': userInitials,
      'email': currentUser!.email,
      'isAdmin': isAdmin,
      'isActive': isUserActive,
      'isStaff': currentUser!.isStaff,
      'joinDate': formattedJoinDate,
      'profileComplete': isProfileComplete,
    };
  }

  /// Gera cor do avatar baseada no nome do usuário
  Color get avatarColor {
    if (currentUser == null) return Colors.grey;

    final username = currentUser!.username;
    final hash = username.hashCode.abs();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.pink,
      Colors.deepOrange,
    ];

    return colors[hash % colors.length];
  }

  get currentUser => null;

  /// Verifica se pode acessar funcionalidades administrativas
  bool canAccessAdmin() => isAuthenticated && isUserActive && isAdmin;

  /// Verifica se precisa completar o perfil
  bool needsProfileCompletion() => isAuthenticated && !isProfileComplete;

  /// Obtém saudação personalizada baseada no horário
  String getPersonalizedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    final name = currentUser?.firstName ?? currentUser?.username ?? '';
    if (name.isNotEmpty) {
      return '$greeting, $name!';
    }

    return '$greeting!';
  }

  /// Verifica se o usuário tem permissões específicas
  bool hasPermission(String permission) {
    if (!isAuthenticated || currentUser == null) return false;

    // Administradores têm todas as permissões
    if (isAdmin) return true;

    // Aqui você pode implementar lógica específica de permissões
    // baseada no seu sistema de roles/permissions
    return false;
  }
}

/// Extensões para validação de dados do usuário
extension UserValidation on User {
  /// Valida se o email tem formato correto
  bool get isEmailValid {
    if (email.isEmpty) return false;
    return true;
  }

  // Verifica se o usuário tem nome completo
  bool get hasFullName =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty;

  // Verifica se é um usuário recém-criado (menos de 7 dias)
  bool get isNewUser {
    if (dateJoined == null) return false;

    final now = DateTime.now();
    final difference = now.difference(dateJoined!);
    return difference.inDays < 7;
  }

  // Obtém o tempo desde o cadastro
  String get timeSinceJoined {
    if (dateJoined == null) return 'Data desconhecida';

    final now = DateTime.now();
    final difference = now.difference(dateJoined!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else {
      return 'Hoje';
    }
  }
}
