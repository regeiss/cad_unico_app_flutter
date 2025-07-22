import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isLoggingOut = false;
  bool _isAuthenticated = false;
  UserModel? _currentUser;
  String? _token;
  String? _refreshToken;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get errorMessage => _errorMessage;

  // Construtor
  AuthProvider() {
    _checkAuthStatus();
  }
  String get userInitials {
    if (_currentUser == null) return '??';
    
    final firstName = _currentUser!.firstName;
    final lastName = _currentUser!.lastName;
    
    if (firstName != null && firstName.isNotEmpty) {
      String initials = firstName[0].toUpperCase();
      if (lastName != null && lastName.isNotEmpty) {
        initials += lastName[0].toUpperCase();
      }
      return initials;
    }
    
    return _currentUser!.username.isNotEmpty 
        ? _currentUser!.username[0].toUpperCase() 
        : '?';
  }
  String get displayName {
    if (_currentUser == null) return 'Usuário';
    
    final firstName = _currentUser!.firstName;
    final lastName = _currentUser!.lastName;
    
    if (firstName != null && firstName.isNotEmpty) {
      if (lastName != null && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName;
    }
    
    return _currentUser!.username;
  }
  String? get userEmail => _currentUser?.email ?? "";
  String? get userName => _currentUser?.username ?? "";
  bool get isAdmin => _currentUser?.isStaff ?? false;
  bool get isProfileComplete {
    if (_currentUser == null) return false;
    
    return _currentUser!.username.isNotEmpty &&
           _currentUser!.email != null && 
           _currentUser!.email!.isNotEmpty &&
           _currentUser!.email!.contains('@') &&
           _currentUser!.firstName != null &&
           _currentUser!.firstName!.isNotEmpty;
  }
  bool get hasValidEmail {
    return _currentUser != null && 
           _currentUser!.email != null && 
           _currentUser!.email.isNotEmpty &&
           _currentUser!.email.contains('@');
  }
  bool get isNewUser {
    if (_currentUser == null || _currentUser!.dateJoined == null) return false;
    
    final difference = DateTime.now().difference(_currentUser!.dateJoined!);
    return difference.inDays < 7;
  }
  String get timeSinceJoined {
    if (_currentUser == null || _currentUser!.dateJoined == null) return 'Data desconhecida';
    
    final difference = DateTime.now().difference(_currentUser!.dateJoined!);
    if (difference.inDays > 0) {
      return '${difference.inDays} dia(s) atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora(s) atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto(s) atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  /// Verifica o status de autenticação ao inicializar
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _refreshToken = prefs.getString('refresh_token');
      
      if (_token != null && _token!.isNotEmpty) {
        // Verificar se o token ainda é válido
        final isValid = await _validateToken();
        if (isValid) {
          _isAuthenticated = true;
          await _loadUserProfile();
        } else {
          await _clearAuthData();
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar status de autenticação: $e');
      await _clearAuthData();
    }
    notifyListeners();
  }

  /// Carrega o perfil do usuário
  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.success && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    }
  }

  /// Valida se o token ainda é válido
  Future<bool> _validateToken() async {
    try {
      if (_token == null) return false;
      
      final response = await _apiService.validateToken(_token!);
      return response.success;
    } catch (e) {
      debugPrint('Erro ao validar token: $e');
      return false;
    }
  }

  /// Realiza o login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(username, password);
      
      if (response.success && response.data != null) {
        _token = response.data!['token'] as String?;
        _refreshToken = response.data!['refresh'] as String?;
        
        if (response.data!['user'] != null) {
          _currentUser = UserModel.fromJson(response.data!['user'] as Map<String, dynamic>);
        }

        if (_token != null) {
          await _saveAuthData();
          _isAuthenticated = true;
          _setLoading(false);
          return true;
        }
      }
      
      _errorMessage = response.message ?? AppConstants.loginError;
      _setLoading(false);
      return false;
      
    } catch (e) {
      _errorMessage = 'Erro ao fazer login: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Realiza o logout
  Future<void> logout() async {
    _setLoggingOut(true);
    
    try {
      // Tentar fazer logout no servidor
      if (_refreshToken != null) {
        await _apiService.logout(_refreshToken!);
      }
    } catch (e) {
      debugPrint('Erro ao fazer logout no servidor: $e');
    } finally {
      await _clearAuthData();
      _setLoggingOut(false);
    }
  }

  /// Salva os dados de autenticação
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_token != null) {
        await prefs.setString('token', _token!);
      }
      
      if (_refreshToken != null) {
        await prefs.setString('refresh_token', _refreshToken!);
      }
      
      if (_currentUser != null) {
        await prefs.setString('user_data', _currentUser!.toJson().toString());
      }
    } catch (e) {
      debugPrint('Erro ao salvar dados de autenticação: $e');
    }
  }

  /// Limpa todos os dados de autenticação
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      
      _token = null;
      _refreshToken = null;
      _currentUser = null;
      _isAuthenticated = false;
      _isLoggingOut = false;
      _errorMessage = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao limpar dados de autenticação: $e');
    }
  }

  /// Verifica se o usuário está autenticado
  Future<bool> checkAuthStatus() async {
    if (_token == null) return false;
    
    try {
      final isValid = await _validateToken();
      if (!isValid) {
        await _clearAuthData();
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Erro ao verificar status de autenticação: $e');
      return false;
    }
  }

  /// Atualiza o token usando o refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _apiService.refreshToken(_refreshToken!);
      
      if (response.success && response.data != null) {
        _token = response.data!['access'] as String?;
        
        if (response.data!['refresh'] != null) {
          _refreshToken = response.data!['refresh'] as String?;
        }
        
        if (_token != null) {
          await _saveAuthData();
          return true;
        }
      }
      
      // Se não conseguiu renovar, fazer logout
      await _clearAuthData();
      return false;
      
    } catch (e) {
      debugPrint('Erro ao renovar token: $e');
      await _clearAuthData();
      return false;
    }
  }

  /// Registra um novo usuário
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.success) {
        _setLoading(false);
        return true;
      }
      
      _errorMessage = response.message ?? 'Erro ao registrar usuário';
      _setLoading(false);
      return false;
      
    } catch (e) {
      _errorMessage = 'Erro ao registrar: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Atualiza o perfil do usuário
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.updateProfile(userData);
      
      if (response.success && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);
        await _saveAuthData();
        _setLoading(false);
        return true;
      }
      
      _errorMessage = response.message ?? 'Erro ao atualizar perfil';
      _setLoading(false);
      return false;
      
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Altera a senha do usuário
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        _setLoading(false);
        return true;
      }
      
      _errorMessage = response.message ?? 'Erro ao alterar senha';
      _setLoading(false);
      return false;
      
    } catch (e) {
      _errorMessage = 'Erro ao alterar senha: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Define o estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define o estado de logging out
  void _setLoggingOut(bool loggingOut) {
    _isLoggingOut = loggingOut;
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa a mensagem de erro manualmente
  void clearError() {
    _clearError();
  }
}