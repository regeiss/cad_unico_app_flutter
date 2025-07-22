// lib/utils/auth_extensions.dart
// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

/// Extensão para facilitar o acesso ao AuthProvider
extension BuildContextAuth on BuildContext {
  /// Obtém o AuthProvider
  AuthProvider get auth => Provider.of<AuthProvider>(this, listen: false);

  /// Obtém o AuthProvider com listen
  AuthProvider get authWatch => Provider.of<AuthProvider>(this, listen: true);

  /// Verifica se está autenticado
  bool get isAuthenticated => auth.isAuthenticated;

  /// Obtém dados do usuário
  UserModel? get user => auth.user;

  /// Obtém token de autorização
  String? get authToken => auth.token;

  /// Faz logout
  Future<void> logout() => auth.logout();
}

/// Mixin para widgets que precisam de autenticação
mixin AuthRequiredMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() {
    final authProvider = context.auth;
    if (!authProvider.isAuthenticated) {
      // Redireciona para login se não estiver autenticado
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

/// Widget que só exibe conteúdo se usuário estiver autenticado
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool showLoading;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
    this.showLoading = true,
  });

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized && showLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (auth.isAuthenticated) {
            return child;
          }

          return fallback ?? const SizedBox.shrink();
        },
      );
}

/// Widget que só exibe conteúdo se usuário for admin
class AdminGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated && auth.isAdmin) {
            return child;
          }

          return fallback ?? const SizedBox.shrink();
        },
      );
}

/// Widget para exibir avatar do usuário
class UserAvatar extends StatelessWidget {
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
        builder: (context, auth, _) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          child: Text(
            auth.userInitials,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.8,
            ),
          ),
        ),
      );
}

/// Widget para exibir nome do usuário
class UserNameDisplay extends StatelessWidget {
  final TextStyle? style;
  final String? fallback;

  const UserNameDisplay({
    super.key,
    this.style,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
        builder: (context, auth, _) => Text(
          auth.fullName.isNotEmpty ? auth.fullName : (fallback ?? 'Usuário'),
          style: style,
        ),
      );
}

/// Interceptor para requisições HTTP com token
class AuthInterceptor {
  final AuthProvider authProvider;

  AuthInterceptor(this.authProvider);

  /// Adiciona headers de autenticação
  Map<String, String> getHeaders([Map<String, String>? additionalHeaders]) {
    final headers = authProvider.getAuthHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  /// Trata resposta de erro 401 (não autorizado)
  Future<bool> handleUnauthorized() async {
    if (authProvider.isAuthenticated) {
      // Tenta renovar token ou faz logout
      await authProvider.logout();
      return true; // Indica que houve logout
    }
    return false;
  }
}

/// Classe para validações de autenticação
class AuthValidator {
  /// Valida formato de email
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  /// Valida força da senha
  /// Pelo menos 8 caracteres, 1 maiúscula, 1 minúscula, 1 número
  static bool isStrongPassword(String password) => password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);

  /// Valida username
  /// // Entre 3 e 20 caracteres, apenas letras, números e underscore
  static bool isValidUsername(String username) => RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);

  /// Obtém mensagem de erro para senha fraca
  static String getPasswordStrengthMessage(String password) {
    if (password.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Senha deve ter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Senha deve ter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Senha deve ter pelo menos um número';
    }
    return '';
  }
}

/// Utilitários para JWT
class JWTUtils {
  /// Decodifica payload do JWT (sem verificação de assinatura)
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];

      // Adiciona padding se necessário
      var paddedPayload = payload;
      while (paddedPayload.length % 4 != 0) {
        paddedPayload += '=';
      }

      final decoded = utf8.decode(base64Url.decode(paddedPayload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } on Exception {
      return null;
    }
  }

  /// Verifica se token está expirado
  static bool isTokenExpired(String token) {
    final payload = decodePayload(token);
    if (payload == null) return true;

    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  /// Obtém tempo restante do token em segundos
  static int? getTokenRemainingTime(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'] as int?;
    if (exp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = exp - now;

    return remaining > 0 ? remaining : 0;
  }
}
