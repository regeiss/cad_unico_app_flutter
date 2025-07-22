import 'package:flutter/material.dart';
import 'auth_provider.dart';

/// Extensões úteis para o AuthProvider
extension AuthProviderExtensions on AuthProvider {
  
  /// Retorna o token de autenticação atual
  String? get authToken {
    return user?.token; // Assumindo que user tem uma propriedade token
  }
  
  /// Verifica se o usuário está autenticado
  bool get isAuthenticated {
    return user != null && authToken != null;
  }
  
  /// Retorna true se o provider foi inicializado
  bool get hasInitialized {
    return !isLoading; // Usando isLoading como indicador inverso de inicialização
  }
  
  /// Verifica se o usuário é administrador
  bool get hasAdminRole {
    return user?.isStaff == true; // Usando isStaff como indicador de admin
  }
  
  /// Retorna o nome completo do usuário
  String get userFullName {
    if (user == null) return '';
    
    final firstName = user!.firstName ?? '';
    final lastName = user!.lastName ?? '';
    
    if (firstName.isEmpty && lastName.isEmpty) {
      return user!.username;
    }
    
    return '$firstName $lastName'.trim();
  }
  
  /// Retorna headers de autenticação para requisições HTTP
  Map<String, String> get authHeaders {
    final token = authToken;
    if (token == null) return {};
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  
  /// Verifica se o token está expirado (implementação básica)
  bool get isTokenExpired {
    // Implementação básica - pode ser melhorada com verificação real do JWT
    return !isAuthenticated;
  }
  
  /// Retorna as iniciais do usuário para avatar
  String get userInitials {
    final fullName = userFullName;
    if (fullName.isEmpty) return '?';
    
    final names = fullName.split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    
    return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'.toUpperCase();
  }
  
  /// Verifica se o usuário tem permissão específica
  bool hasPermission(String permission) {
    // Implementação básica - pode ser expandida conforme necessário
    if (!isAuthenticated) return false;
    if (hasAdminRole) return true;
    
    // Adicionar lógica específica de permissões aqui
    return false;
  }
  
  /// Retorna informações resumidas do usuário
  Map<String, dynamic> get userSummary {
    if (!isAuthenticated) {
      return {
        'authenticated': false,
        'name': 'Usuário não autenticado',
        'role': 'guest',
      };
    }
    
    return {
      'authenticated': true,
      'id': user!.id,
      'username': user!.username,
      'name': userFullName,
      'email': user!.email,
      'role': hasAdminRole ? 'admin' : 'user',
      'isStaff': user!.isStaff,
      'isActive': user!.isActive,
    };
  }
  
  /// Valida se o usuário pode acessar uma determinada rota
  bool canAccessRoute(String routeName) {
    if (!isAuthenticated) {
      // Rotas públicas que não precisam de autenticação
      const publicRoutes = ['/login', '/register', '/forgot-password'];
      return publicRoutes.contains(routeName);
    }
    
    // Se está autenticado, pode acessar rotas protegidas
    return true;
  }
  
  /// Formata o nome do usuário para exibição
  String get displayName {
    if (!isAuthenticated) return 'Visitante';
    
    final fullName = userFullName;
    if (fullName.isNotEmpty && fullName != user!.username) {
      return fullName;
    }
    
    return user!.username;
  }
  
  /// Retorna a cor do avatar baseada no usuário
  Color get avatarColor {
    if (!isAuthenticated) return Colors.grey;
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ];
    
    final hash = user!.username.hashCode;
    return colors[hash.abs() % colors.length];
  }
  
  /// Verifica se é necessário atualizar o token
  bool get needsTokenRefresh {
    // Implementação básica - pode ser melhorada
    return isAuthenticated && isTokenExpired;
  }
  
  /// Retorna o tempo desde o último login (em minutos)
  int get minutesSinceLogin {
    if (user?.dateJoined == null) return 0;
    
    final now = DateTime.now();
    final loginTime = user!.dateJoined!;
    
    return now.difference(loginTime).inMinutes;
  }
  
  /// Verifica se o usuário logou recentemente (últimas 24h)
  bool get isRecentLogin {
    return minutesSinceLogin <= (24 * 60); // 24 horas em minutos
  }
}