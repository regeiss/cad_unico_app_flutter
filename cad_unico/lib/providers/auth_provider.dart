// lib/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contants/constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';


enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  // Estado do usuário
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  bool _isLoggingIn = false;
  bool _isLoggingOut = false;
  bool _isRegistering = false;
  String? _errorMessage;
  String? _token;
  String? _refreshToken;

  // Construtor
  AuthProvider(this._apiService) {
    _initializeAuth();
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isLoggingIn => _isLoggingIn;
  bool get isLoggingOut => _isLoggingOut;
  bool get isRegistering => _isRegistering;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get hasError => _status == AuthStatus.error && _errorMessage != null;

  String get userDisplayName {
    if (_user == null) return 'Usuário';
    return _user!.fullName.isNotEmpty ? _user!.fullName : _user!.username;
  }

  String get userInitials => _user?.initials ?? 'U';

  // ==========================================================================
  // INICIALIZAÇÃO
  // ==========================================================================

  Future<void> _initializeAuth() async {
    _setStatus(AuthStatus.loading);
    
    try {
      // Carregar tokens salvos
      await _loadSavedTokens();
      
      // Se tiver token, tentar carregar perfil do usuário
      if (_apiService.isAuthenticated) {
        await _loadUserProfile();
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } on Exception catch (e) {
      debugPrint('Erro na inicialização da autenticação: $e');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> _loadSavedTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.tokenKey);
      _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      
      // Carregar dados do usuário salvos
      final userDataString = prefs.getString(AppConstants.userDataKey);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        _user = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Erro ao carregar tokens salvos: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await _apiService.getUserProfile();
      
      if (result['success']) {
        _user = User.fromJson(result['data']);
        await _saveUserData();
        _setStatus(AuthStatus.authenticated);
      } else {
        // Se falhar ao carregar perfil, limpar dados
        await _clearAuthData();
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil do usuário: $e');
      await _clearAuthData();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // ==========================================================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ==========================================================================

  Future<bool> login(String username, String password) async {
    if (_isLoggingIn) return false;

    _setLoggingIn(true);
    _clearError();

    try {
      final result = await _apiService.login(username, password);
      
      if (result['success']) {
        // Extrair dados do resultado
        final data = result['data'];
        _token = data['token'] ?? data['access'];
        _refreshToken = data['refresh'];
        
        // Criar usuário a partir dos dados
        if (data['user'] != null) {
          _user = User.fromJson(data['user']);
        } else {
          // Se não tiver dados do usuário na resposta, carregar do perfil
          await _loadUserProfile();
        }

        await _saveUserData();
        await _saveLastLogin();
        _setStatus(AuthStatus.authenticated);
        
        return true;
      } else {
        _setError(result['message'] ?? AppConstants.loginError);
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      debugPrint('Erro no login: $e');
      _setError('Erro inesperado durante o login');
      _setStatus(AuthStatus.error);
      return false;
    } finally {
      _setLoggingIn(false);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
  }) async {
    if (_isRegistering) return false;

    _setRegistering(true);
    _clearError();

    try {
      final result = await _apiService.register({
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
      });
      
      if (result['success']) {
        // Após registro bem-sucedido, fazer login automático
        final loginSuccess = await login(username, password);
        return loginSuccess;
      } else {
        _setError(result['message'] ?? 'Erro ao criar conta');
        _setStatus(AuthStatus.error);
        return false;
      }
    } catch (e) {
      debugPrint('Erro no registro: $e');
      _setError('Erro inesperado durante o registro');
      _setStatus(AuthStatus.error);
      return false;
    } finally {
      _setRegistering(false);
    }
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;

    _setLoggingOut(true);

    try {
      // Chamar logout na API
      await _apiService.logout();
    } catch (e) {
      debugPrint('Erro no logout da API: $e');
    } finally {
      // Limpar dados locais independente do resultado da API
      await _clearAuthData();
      _setStatus(AuthStatus.unauthenticated);
      _setLoggingOut(false);
    }
  }

  Future<void> forceLogout() async {
    await _clearAuthData();
    _setStatus(AuthStatus.unauthenticated);
  }

  // ==========================================================================
  // MÉTODOS DE VALIDAÇÃO DE TOKEN
  // ==========================================================================

  Future<bool> validateToken() async {
    if (!_apiService.isAuthenticated) return false;

    try {
      final result = await _apiService.verifyToken();
      
      if (result['success']) {
        return true;
      } else {
        // Token inválido, tentar renovar
        return await _refreshAuthToken();
      }
    } catch (e) {
      debugPrint('Erro ao validar token: $e');
      return false;
    }
  }

  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final result = await _apiService.refreshToken(_refreshToken!);
      
      if (result['success']) {
        _token = result['data']['access'];
        await _saveTokens();
        return true;
      } else {
        // Não conseguiu renovar, fazer logout
        await forceLogout();
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao renovar token: $e');
      await forceLogout();
      return false;
    }
  }

  // ==========================================================================
  // MÉTODOS DE PERFIL
  // ==========================================================================

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (email != null) data['email'] = email;

      final result = await _apiService.updateUserProfile(data);
      
      if (result['success']) {
        _user = User.fromJson(result['data']);
        await _saveUserData();
        return true;
      } else {
        _setError(result['message'] ?? 'Erro ao atualizar perfil');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      _setError('Erro inesperado ao atualizar perfil');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result['success']) {
        return true;
      } else {
        _setError(result['message'] ?? 'Erro ao alterar senha');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao alterar senha: $e');
      _setError('Erro inesperado ao alterar senha');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // MÉTODOS DE PERSISTÊNCIA
  // ==========================================================================

  Future<void> _saveUserData() async {
    if (_user == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, jsonEncode(_user!.toJson()));
    } catch (e) {
      debugPrint('Erro ao salvar dados do usuário: $e');
    }
  }

  Future<void> _saveTokens() async {
    if (_token == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _token!);
      
      if (_refreshToken != null) {
        await prefs.setString(AppConstants.refreshTokenKey, _refreshToken!);
      }
    } catch (e) {
      debugPrint('Erro ao salvar tokens: $e');
    }
  }

  Future<void> _saveLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Erro ao salvar último login: $e');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      _user = null;
      _token = null;
      _refreshToken = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      await prefs.remove(AppConstants.userDataKey);
      await prefs.remove(AppConstants.lastLoginKey);
    } catch (e) {
      debugPrint('Erro ao limpar dados de autenticação: $e');
    }
  }

  // ==========================================================================
  // MÉTODOS DE ESTADO
  // ==========================================================================

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoggingIn(bool loggingIn) {
    _isLoggingIn = loggingIn;
    notifyListeners();
  }

  void _setLoggingOut(bool loggingOut) {
    _isLoggingOut = loggingOut;
    notifyListeners();
  }

  void _setRegistering(bool registering) {
    _isRegistering = registering;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // ==========================================================================
  // MÉTODOS DE UTILIDADE
  // ==========================================================================

  bool get canRefreshToken => _refreshToken != null;

  Future<DateTime?> getLastLoginDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginString = prefs.getString(AppConstants.lastLoginKey);
      return lastLoginString != null ? DateTime.tryParse(lastLoginString) : null;
    } catch (e) {
      debugPrint('Erro ao obter data do último login: $e');
      return null;
    }
  }

  bool get hasValidSession {
    return isAuthenticated && _token != null;
  }

  // ==========================================================================
  // MÉTODOS DE DEBUG
  // ==========================================================================

  void debugPrintUserInfo() {
    if (AppConstants.enableDebugMode) {
      debugPrint('=== AUTH PROVIDER DEBUG ===');
      debugPrint('Status: $_status');
      debugPrint('User: $_user');
      debugPrint('Has Token: ${_token != null}');
      debugPrint('Has Refresh Token: ${_refreshToken != null}');
      debugPrint('Is Authenticated: $isAuthenticated');
      debugPrint('========================');
    }
  }

  @override
  void dispose() {
    // Limpar recursos se necessário
    super.dispose();
  }
}