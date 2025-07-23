// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _refreshToken;

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  // Getters
  String? get token => _token;
  String? get refreshToken => _refreshToken;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadTokenFromStorage();
  }

  // TODO Implementar
  get errorMessage => null;
  get clearError => null;

  // Carregar token do storage
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');

      if (_token != null) {
        _isAuthenticated = true;
        // TODO: Buscar dados do usuário da API
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar token: $e');
    }
  }

  // Salvar token no storage
  Future<void> _saveTokenToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('access_token', _token!);
      }
      if (_refreshToken != null) {
        await prefs.setString('refresh_token', _refreshToken!);
      }
    } catch (e) {
      debugPrint('Erro ao salvar token: $e');
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);

    try {
      // TODO: Implementar chamada para API
      // Por enquanto, simulando login
      await Future.delayed(const Duration(seconds: 1));

      _token = 'fake_token_123';
      _refreshToken = 'fake_refresh_token_123';
      _user = User(
        id: 1,
        username: username,
        email: '$username@example.com',
        firstName: 'Usuário',
        lastName: 'Teste',
        isStaff: false,
        isActive: true,
        dateJoined: DateTime.now(),
      );
      _isAuthenticated = true;

      await _saveTokenToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      _token = null;
      _refreshToken = null;
      _user = null;
      _isAuthenticated = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Erro no logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Verificar se o token é válido
  Future<bool> isTokenValid() async {
    if (_token == null) return false;

    try {
      // TODO: Implementar verificação de token na API
      return true;
    } catch (e) {
      debugPrint('Erro ao verificar token: $e');
      return false;
    }
  }

  // Refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      // TODO: Implementar refresh token na API
      return true;
    } catch (e) {
      debugPrint('Erro ao fazer refresh do token: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void refreshUser() {}

  void saveUserData() {}

  void cleanup() {}
}
