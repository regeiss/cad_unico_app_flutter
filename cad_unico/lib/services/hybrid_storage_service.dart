// lib/services/hybrid_storage_service.dart
import 'dart:convert';
// Imports condicionais para web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HybridStorageService {
  static HybridStorageService? _instance;
  static SharedPreferences? _prefs;

  HybridStorageService._();

  static Future<HybridStorageService> getInstance() async {
    _instance ??= HybridStorageService._();

    // Para mobile, usa SharedPreferences
    if (!kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
    }

    return _instance!;
  }

  // Chaves para storage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // ============ MÉTODOS UNIVERSAIS ============

  /// Salva token (funciona em web e mobile)
  Future<bool> saveToken(String token) async {
    try {
      if (kIsWeb) {
        return await _saveToWeb(_tokenKey, token);
      } else {
        return await _saveToMobile(_tokenKey, token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar token: $e');
      }
      return false;
    }
  }

  /// Recupera token
  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        return _getFromWeb(_tokenKey);
      } else {
        return _getFromMobile(_tokenKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recuperar token: $e');
      }
      return null;
    }
  }

  /// Salva refresh token
  Future<bool> saveRefreshToken(String refreshToken) async {
    try {
      if (kIsWeb) {
        return await _saveToWeb(_refreshTokenKey, refreshToken);
      } else {
        return await _saveToMobile(_refreshTokenKey, refreshToken);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar refresh token: $e');
      }
      return false;
    }
  }

  /// Recupera refresh token
  Future<String?> getRefreshToken() async {
    try {
      if (kIsWeb) {
        return _getFromWeb(_refreshTokenKey);
      } else {
        return _getFromMobile(_refreshTokenKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recuperar refresh token: $e');
      }
      return null;
    }
  }

  /// Salva dados do usuário
  Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);

      if (kIsWeb) {
        return await _saveToWeb(_userKey, userJson);
      } else {
        return await _saveToMobile(_userKey, userJson);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar usuário: $e');
      }
      return false;
    }
  }

  /// Recupera dados do usuário
  Future<Map<String, dynamic>?> getUser() async {
    try {
      String? userJson;

      if (kIsWeb) {
        userJson = _getFromWeb(_userKey);
      } else {
        userJson = _getFromMobile(_userKey);
      }

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

  /// Define status de login
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    try {
      final value = isLoggedIn.toString();

      if (kIsWeb) {
        return await _saveToWeb(_isLoggedInKey, value);
      } else {
        return await _prefs!.setBool(_isLoggedInKey, isLoggedIn);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao definir status de login: $e');
      }
      return false;
    }
  }

  /// Verifica se está logado
  Future<bool> isLoggedIn() async {
    try {
      if (kIsWeb) {
        final value = _getFromWeb(_isLoggedInKey);
        return value == 'true';
      } else {
        return _prefs!.getBool(_isLoggedInKey) ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar status de login: $e');
      }
      return false;
    }
  }

  /// Salva sessão completa
  Future<bool> saveSession({
    required String token,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 Salvando sessão completa (${kIsWeb ? "Web" : "Mobile"})...');
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
            ? '✅ Sessão salva com sucesso'
            : '❌ Erro ao salvar sessão');
        await debugListAll();
      }

      return allSuccess;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar sessão: $e');
      }
      return false;
    }
  }

  /// Limpa dados de autenticação
  Future<bool> clearAuth() async {
    try {
      if (kDebugMode) {
        print('🧹 Limpando dados de autenticação...');
      }

      if (kIsWeb) {
        html.window.localStorage.remove(_tokenKey);
        html.window.localStorage.remove(_refreshTokenKey);
        html.window.localStorage.remove(_userKey);
        html.window.localStorage.remove(_isLoggedInKey);
      } else {
        await Future.wait([
          _prefs!.remove(_tokenKey),
          _prefs!.remove(_refreshTokenKey),
          _prefs!.remove(_userKey),
          _prefs!.remove(_isLoggedInKey),
        ]);
      }

      if (kDebugMode) {
        print('✅ Dados de autenticação limpos');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao limpar dados: $e');
      }
      return false;
    }
  }

  /// Força reload (útil para mobile)
  Future<void> reload() async {
    if (!kIsWeb && _prefs != null) {
      try {
        await _prefs!.reload();
        if (kDebugMode) {
          print('🔄 SharedPreferences recarregado');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Erro ao recarregar: $e');
        }
      }
    }
  }

  // ============ MÉTODOS PRIVADOS WEB ============

  Future<bool> _saveToWeb(String key, String value) async {
    try {
      html.window.localStorage[key] = value;

      // Verificação com retry
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (html.window.localStorage[key] == value) {
          return true;
        }
        if (i < 2) {
          html.window.localStorage[key] = value; // Retry
        }
      }

      if (kDebugMode) {
        print('⚠️ Falha na verificação web storage para $key após retries');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar no localStorage: $e');
      }
      return false;
    }
  }

  String? _getFromWeb(String key) {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao ler do localStorage: $e');
      }
      return null;
    }
  }

  // ============ MÉTODOS PRIVADOS MOBILE ============

  Future<bool> _saveToMobile(String key, String value) async {
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar no SharedPreferences: $e');
      }
      return false;
    }
  }

  String? _getFromMobile(String key) {
    try {
      return _prefs!.getString(key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao ler do SharedPreferences: $e');
      }
      return null;
    }
  }

  // ============ MÉTODOS DE DEBUG ============

  Future<void> debugListAll() async {
    if (!kDebugMode) return;

    try {
      print('🔍 === STORAGE DEBUG (${kIsWeb ? "Web" : "Mobile"}) ===');

      final token = await getToken();
      final refreshToken = await getRefreshToken();
      final user = await getUser();
      final loggedIn = await isLoggedIn();

      print('  Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
      print('  RefreshToken: ${refreshToken != null ? "${refreshToken.substring(0, 20)}..." : "null"}');
      print('  User: ${user?['username'] ?? "null"}');
      print('  IsLoggedIn: $loggedIn');

      if (kIsWeb) {
        final keys = html.window.localStorage.keys.toList();
        print('  Todas as chaves localStorage: $keys');
      } else {
        final keys = _prefs!.getKeys();
        print('  Todas as chaves SharedPreferences: $keys');
      }

      print('==========================================');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no debug: $e');
      }
    }
  }

  /// Testa se o storage está funcionando
  Future<bool> testStorage() async {
    try {
      const testKey = 'storage_test';
      const testValue = 'test_value_123';

      if (kIsWeb) {
        await _saveToWeb(testKey, testValue);
        final retrieved = _getFromWeb(testKey);
        html.window.localStorage.remove(testKey);
        return retrieved == testValue;
      } else {
        await _prefs!.setString(testKey, testValue);
        final retrieved = _prefs!.getString(testKey);
        await _prefs!.remove(testKey);
        return retrieved == testValue;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no teste de storage: $e');
      }
      return false;
    }
  }

  /// Informações sobre o storage atual
  Map<String, dynamic> getStorageInfo() => {
        'platform': kIsWeb ? 'web' : 'mobile',
        'storage_type': kIsWeb ? 'localStorage' : 'SharedPreferences',
        'is_available':
            kIsWeb ? html.window.localStorage != null : _prefs != null,
      };
}