// lib/services/web_storage_service.dart
// ignore_for_file: avoid_classes_with_only_static_members, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // ============ MÉTODOS DE TOKEN ============

  /// Salva token usando localStorage nativo
  static Future<bool> saveToken(String token) async {
    if (!kIsWeb) return false;

    try {
      html.window.localStorage[_tokenKey] = token;

      // Verificação
      final saved = html.window.localStorage[_tokenKey];
      final success = saved == token;

      if (kDebugMode) {
        print('💾 Token salvo no localStorage: $success');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar token no localStorage: $e');
      }
      return false;
    }
  }

  /// Recupera token do localStorage
  static String? getToken() {
    if (!kIsWeb) return null;

    try {
      final token = html.window.localStorage[_tokenKey];

      if (kDebugMode) {
        print(
            '🔍 Token do localStorage: ${token != null ? "encontrado" : "não encontrado"}');
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recuperar token do localStorage: $e');
      }
      return null;
    }
  }

  /// Salva refresh token
  static Future<bool> saveRefreshToken(String refreshToken) async {
    if (!kIsWeb) return false;

    try {
      html.window.localStorage[_refreshTokenKey] = refreshToken;
      return html.window.localStorage[_refreshTokenKey] == refreshToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar refresh token: $e');
      }
      return false;
    }
  }

  /// Recupera refresh token
  static String? getRefreshToken() {
    if (!kIsWeb) return null;

    try {
      return html.window.localStorage[_refreshTokenKey];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recuperar refresh token: $e');
      }
      return null;
    }
  }

  // ============ MÉTODOS DE USUÁRIO ============

  /// Salva dados do usuário
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    if (!kIsWeb) return false;

    try {
      final userJson = jsonEncode(userData);
      html.window.localStorage[_userKey] = userJson;

      return html.window.localStorage[_userKey] == userJson;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar usuário: $e');
      }
      return false;
    }
  }

  /// Recupera dados do usuário
  static Map<String, dynamic>? getUser() {
    if (!kIsWeb) return null;

    try {
      final userJson = html.window.localStorage[_userKey];
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recuperar usuário: $e');
      }
      return null;
    }
  }

  // ============ MÉTODOS DE SESSÃO ============

  /// Define status de login
  static Future<bool> setLoggedIn(bool isLoggedIn) async {
    if (!kIsWeb) return false;

    try {
      html.window.localStorage[_isLoggedInKey] = isLoggedIn.toString();
      return html.window.localStorage[_isLoggedInKey] == isLoggedIn.toString();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao definir status de login: $e');
      }
      return false;
    }
  }

  /// Verifica se está logado
  static bool isLoggedIn() {
    if (!kIsWeb) return false;

    try {
      final value = html.window.localStorage[_isLoggedInKey];
      return value == 'true';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar status de login: $e');
      }
      return false;
    }
  }

  /// Salva sessão completa
  static Future<bool> saveSession({
    required String token,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    if (!kIsWeb) return false;

    try {
      if (kDebugMode) {
        print('💾 Salvando sessão no localStorage...');
      }

      final results = await Future.wait([
        saveToken(token),
        saveRefreshToken(refreshToken),
        saveUser(userData),
        setLoggedIn(true),
      ]);

      final allSuccess = results.every((result) => result);

      if (kDebugMode) {
        print(allSuccess
            ? '✅ Sessão salva no localStorage'
            : '❌ Erro ao salvar sessão');
        debugListAll();
      }

      return allSuccess;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar sessão: $e');
      }
      return false;
    }
  }

  // ============ MÉTODOS DE LIMPEZA ============

  /// Limpa dados de autenticação
  static Future<bool> clearAuth() async {
    if (!kIsWeb) return false;

    try {
      html.window.localStorage.remove(_tokenKey);
      html.window.localStorage.remove(_refreshTokenKey);
      html.window.localStorage.remove(_userKey);
      html.window.localStorage.remove(_isLoggedInKey);

      if (kDebugMode) {
        print('🧹 Dados de auth limpos do localStorage');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao limpar auth: $e');
      }
      return false;
    }
  }

  /// Limpa tudo
  static Future<bool> clearAll() async {
    if (!kIsWeb) return false;

    try {
      html.window.localStorage.clear();

      if (kDebugMode) {
        print('🧹 localStorage completamente limpo');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao limpar tudo: $e');
      }
      return false;
    }
  }

  // ============ MÉTODOS DE DEBUG ============

  /// Lista todos os dados salvos
  static void debugListAll() {
    if (!kDebugMode || !kIsWeb) return;

    try {
      if (kDebugMode) {
        print('🔍 localStorage contents:');

        final token = getToken();
        final refreshToken = getRefreshToken();
        final user = getUser();
        
        print('  Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
        print('  RefreshToken: ${refreshToken != null ? "${refreshToken.substring(0, 20)}..." : "null"}');
        print('  User: ${user?['username'] ?? "null"}');
        print('  IsLoggedIn: ${isLoggedIn()}');
      }
      // Lista todas as chaves
      final keys = html.window.localStorage.keys.toList();
      if (kDebugMode) {
        print('  Todas as chaves: $keys');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao listar localStorage: $e');
      }
    }
  }

  /// Verifica se localStorage está disponível
  static bool isLocalStorageAvailable() {
    if (!kIsWeb) return false;

    try {
      const testKey = 'test_storage';
      html.window.localStorage[testKey] = 'test';
      final result = html.window.localStorage[testKey] == 'test';
      html.window.localStorage.remove(testKey);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ localStorage não disponível: $e');
      }
      return false;
    }
  }
}