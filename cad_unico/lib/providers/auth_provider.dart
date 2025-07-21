// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String get userInitials => _user?.initials ?? 'U';
  String get userName => _user?.fullName ?? 'Usuário';

  AuthProvider() {
    _initializeAuth();
  }

  // Inicializar autenticação
  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      await _apiService.loadToken();
      if (_apiService.isAuthenticated) {
        await _loadUserProfile();
      }
    } catch (e) {
      debugPrint('Erro ao inicializar auth: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Carregar perfil do usuário
  Future<void> _loadUserProfile() async {
    try {
      final userData = await _apiService.getUserProfile();
      _user = User.fromJson(userData);
      _isAuthenticated = true;
      _clearError();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
      await logout();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Validações básicas
      if (username.trim().isEmpty || password.trim().isEmpty) {
        _setError('Username e senha são obrigatórios');
        return false;
      }

      // Fazer login na API
      final response = await _apiService.login(username.trim(), password);
      
      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;
        
        // Salvar dados localmente
        await _saveUserData();
        
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Erro no login');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Fazer logout na API
      await _apiService.logout();
    } catch (e) {
      debugPrint('Erro ao fazer logout na API: $e');
    }

    // Limpar dados locais
    await _clearUserData();
    
    _user = null;
    _isAuthenticated = false;
    _clearError();
    _setLoading(false);
    
    notifyListeners();
  }

  // Atualizar perfil
  Future<bool> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Preparar dados para atualização
      final updateData = <String, dynamic>{};
      if (email != null && email != _user!.email) {
        updateData['email'] = email;
      }
      if (firstName != null && firstName != _user!.firstName) {
        updateData['first_name'] = firstName;
      }
      if (lastName != null && lastName != _user!.lastName) {
        updateData['last_name'] = lastName;
      }

      if (updateData.isEmpty) {
        _setError('Nenhuma alteração detectada');
        return false;
      }

      // Aqui seria feita a chamada para API de atualização
      // Como não existe endpoint específico, vamos simular
      final updatedUser = User(
        id: _user!.id,
        username: _user!.username,
        email: email ?? _user!.email,
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        isStaff: _user!.isStaff,
        isActive: _user!.isActive,
        dateJoined: _user!.dateJoined,
      );

      _user = updatedUser;
      await _saveUserData();
      
      _clearError();
      notifyListeners();
      return true;

    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verificar se token ainda é válido
  Future<bool> checkAuthStatus() async {
    if (!_apiService.isAuthenticated) {
      await logout();
      return false;
    }

    try {
      await _loadUserProfile();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Salvar dados do usuário localmente
  Future<void> _saveUserData() async {
    if (_user == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.toJson().toString());
      await prefs.setBool('is_authenticated', true);
    } catch (e) {
      debugPrint('Erro ao salvar dados do usuário: $e');
    }
  }

  // Limpar dados do usuário localmente
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.setBool('is_authenticated', false);
    } catch (e) {
      debugPrint('Erro ao limpar dados do usuário: $e');
    }
  }

  // Alterar senha
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validações
      if (currentPassword.isEmpty) {
        _setError('Senha atual é obrigatória');
        return false;
      }

      if (newPassword.length < 6) {
        _setError('Nova senha deve ter pelo menos 6 caracteres');
        return false;
      }

      if (newPassword != confirmPassword) {
        _setError('Nova senha e confirmação não correspondem');
        return false;
      }

      if (currentPassword == newPassword) {
        _setError('A nova senha deve ser diferente da atual');
        return false;
      }

      // Aqui seria feita a chamada para API de alteração de senha
      // Como não existe endpoint específico no backend fornecido,
      // vamos simular o sucesso
      
      _clearError();
      return true;

    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recarregar dados do usuário
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      await _loadUserProfile();
    } catch (e) {
      debugPrint('Erro ao recarregar usuário: $e');
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(String error) {
    if (error.contains('Connection failed')) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (error.contains('timeout')) {
      return 'Tempo limite esgotado. Tente novamente.';
    } else if (error.contains('401')) {
      return 'Credenciais inválidas.';
    } else if (error.contains('403')) {
      return 'Acesso negado.';
    } else if (error.contains('500')) {
      return 'Erro interno do servidor.';
    }
    return error;
  }

  // Limpar erro manualmente
  void clearError() {
    _clearError();
  }

  // Verificar se é primeira vez do usuário
  Future<bool> isFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey('has_logged_in_before');
    } catch (e) {
      return true;
    }
  }

  // Marcar que não é primeira vez
  Future<void> markNotFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_logged_in_before', true);
    } catch (e) {
      debugPrint('Erro ao marcar primeira vez: $e');
    }
  }

  // Obter informações do dispositivo para logs
  Map<String, dynamic> getDeviceInfo() {
    return {
      'user_id': _user?.id,
      'username': _user?.username,
      'is_staff': _user?.isStaff,
      'login_time': DateTime.now().toIso8601String(),
    };
  }
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../contants/constants.dart';
// import '../models/user_model.dart';
// import '../services/api_service.dart';

// class AuthProvider with ChangeNotifier {
//   // Private properties
//   UserModel? _user;
//   String? _token;
//   String? _refreshToken;
//   bool _isLoading = false;
//   String? _error;
//   Timer? _tokenRefreshTimer;
  
//   final ApiService _apiService = ApiService();
  
//   // Getters
//   UserModel? get user => _user;
//   String? get token => _token;
//   String? get refreshToken => _refreshToken;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isAuthenticated => _user != null && _token != null;
  
//   // Constructor
//   AuthProvider() {
//     _loadFromStorage();
//   }
  
//   // Load user data from storage
//   Future<void> _loadFromStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
      
//       // Load token
//       _token = prefs.getString(AppConstants.tokenKey);
//       _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      
//       // Load user data
//       final userData = prefs.getString(AppConstants.userKey);
//       if (userData != null) {
//         final userJson = json.decode(userData);
//         _user = UserModel.fromJson(userJson);
//       }
      
//       // Setup token refresh timer if user is logged in
//       if (_token != null) {
//         _setupTokenRefreshTimer();
//       }
      
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading auth data from storage: $e');
//     }
//   }
  
//   // Save user data to storage
//   Future<void> _saveToStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
      
//       if (_token != null) {
//         await prefs.setString(AppConstants.tokenKey, _token!);
//       } else {
//         await prefs.remove(AppConstants.tokenKey);
//       }
      
//       if (_refreshToken != null) {
//         await prefs.setString(AppConstants.refreshTokenKey, _refreshToken!);
//       } else {
//         await prefs.remove(AppConstants.refreshTokenKey);
//       }
      
//       if (_user != null) {
//         await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
//       } else {
//         await prefs.remove(AppConstants.userKey);
//       }
//     } catch (e) {
//       debugPrint('Error saving auth data to storage: $e');
//     }
//   }
  
//   // Clear storage
//   Future<void> _clearStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(AppConstants.tokenKey);
//       await prefs.remove(AppConstants.refreshTokenKey);
//       await prefs.remove(AppConstants.userKey);
//     } catch (e) {
//       debugPrint('Error clearing auth data from storage: $e');
//     }
//   }
  
//   // Setup token refresh timer
//   void _setupTokenRefreshTimer() {
//     _tokenRefreshTimer?.cancel();
    
//     // Refresh token 5 minutes before expiry (55 minutes from now)
//     const refreshDuration = Duration(minutes: 55);
    
//     _tokenRefreshTimer = Timer(refreshDuration, () {
//       if (isAuthenticated) {
//         refreshTokens();
//       }
//     });
//   }
  
//   // Cancel token refresh timer
//   void _cancelTokenRefreshTimer() {
//     _tokenRefreshTimer?.cancel();
//     _tokenRefreshTimer = null;
//   }
  
//   // Set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
  
//   // Set error state
//   void _setError(String? error) {
//     _error = error;
//     notifyListeners();
//   }
  
//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
  
//   // Login method
//   Future<bool> login(String username, String password) async {
//     try {
//       _setLoading(true);
//       _setError(null);
      
//       final response = await _apiService.login(username, password);
      
//       if (response.success) {
//         _token = response.data['token'];
//         _refreshToken = response.data['refresh'];
//         _user = UserModel.fromJson(response.data['user']);
        
//         await _saveToStorage();
//         _setupTokenRefreshTimer();
        
//         _setLoading(false);
//         return true;
//       } else {
//         _setError(response.message ?? AppConstants.loginErrorMessage);
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError(AppConstants.networkErrorMessage);
//       _setLoading(false);
//       debugPrint('Login error: $e');
//       return false;
//     }
//   }
  
//   // Logout method
//   Future<void> logout() async {
//     try {
//       // Call logout API if token exists
//       if (_token != null) {
//         await _apiService.logout(_refreshToken);
//       }
//     } catch (e) {
//       debugPrint('Logout API error: $e');
//     } finally {
//       // Clear local data regardless of API call result
//       _user = null;
//       _token = null;
//       _refreshToken = null;
//       _cancelTokenRefreshTimer();
//       await _clearStorage();
//       _setError(null);
//       notifyListeners();
//     }
//   }
  
//   // Refresh tokens
//   Future<bool> refreshTokens() async {
//     if (_refreshToken == null) return false;
    
//     try {
//       final response = await _apiService.refreshToken(_refreshToken!);
      
//       if (response.success) {
//         _token = response.data['access'];
//         if (response.data.containsKey('refresh')) {
//           _refreshToken = response.data['refresh'];
//         }
        
//         await _saveToStorage();
//         _setupTokenRefreshTimer();
//         notifyListeners();
//         return true;
//       } else {
//         // If refresh fails, logout user
//         await logout();
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Token refresh error: $e');
//       await logout();
//       return false;
//     }
//   }
  
//   // Get user profile
//   Future<bool> getUserProfile() async {
//     if (_token == null) return false;
    
//     try {
//       final response = await _apiService.getUserProfile(_token!);
      
//       if (response.success) {
//         _user = UserModel.fromJson(response.data);
//         await _saveToStorage();
//         notifyListeners();
//         return true;
//       } else {
//         _setError(response.message);
//         return false;
//       }
//     } catch (e) {
//       _setError(AppConstants.networkErrorMessage);
//       debugPrint('Get profile error: $e');
//       return false;
//     }
//   }
  
//   // Update user profile
//   Future<bool> updateProfile(Map<String, dynamic> userData) async {
//     if (_token == null || _user == null) return false;
    
//     try {
//       _setLoading(true);
//       _setError(null);
      
//       final response = await _apiService.updateProfile(_token!, userData);
      
//       if (response.success) {
//         _user = UserModel.fromJson(response.data);
//         await _saveToStorage();
//         _setLoading(false);
//         notifyListeners();
//         return true;
//       } else {
//         _setError(response.message ?? AppConstants.saveErrorMessage);
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError(AppConstants.networkErrorMessage);
//       _setLoading(false);
//       debugPrint('Update profile error: $e');
//       return false;
//     }
//   }
  
//   // Change password
//   Future<bool> changePassword(String currentPassword, String newPassword) async {
//     if (_token == null) return false;
    
//     try {
//       _setLoading(true);
//       _setError(null);
      
//       final response = await _apiService.changePassword(
//         _token!,
//         currentPassword,
//         newPassword,
//       );
      
//       if (response.success) {
//         _setLoading(false);
//         return true;
//       } else {
//         _setError(response.message ?? 'Erro ao alterar senha');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError(AppConstants.networkErrorMessage);
//       _setLoading(false);
//       debugPrint('Change password error: $e');
//       return false;
//     }
//   }
  
//   // Check if token is valid
//   Future<bool> isTokenValid() async {
//     if (_token == null) return false;
    
//     try {
//       final response = await _apiService.verifyToken(_token!);
//       return response.success;
//     } catch (e) {
//       debugPrint('Token validation error: $e');
//       return false;
//     }
//   }
  
//   // Refresh user data
//   Future<void> refreshUser() async {
//     if (isAuthenticated) {
//       await getUserProfile();
//     }
//   }
  
//   // Save user data (called on app pause)
//   Future<void> saveUserData() async {
//     await _saveToStorage();
//   }
  
//   // Cleanup (called on app termination)
//   void cleanup() {
//     _cancelTokenRefreshTimer();
//   }
  
//   // Get authorization header
//   Map<String, String> getAuthHeaders() {
//     if (_token == null) return {};
//     return {
//       'Authorization': 'Bearer $_token',
//       'Content-Type': 'application/json',
//     };
//   }
  
//   // Check if user has role/permission
//   bool hasRole(String role) {
//     return _user?.hasRole(role) ?? false;
//   }
  
//   bool hasPermission(String permission) {
//     return _user?.hasPermission(permission) ?? false;
//   }
  
//   // Get user display name
//   String get displayName {
//     if (_user == null) return 'Usuário';
    
//     if (_user!.firstName.isNotEmpty) {
//       return _user!.firstName;
//     }
    
//     return _user!.username;
//   }
  
//   // Get user full name
//   String get fullName {
//     if (_user == null) return 'Usuário';
    
//     final firstName = _user!.firstName;
//     final lastName = _user!.lastName;
    
//     if (firstName.isNotEmpty && lastName.isNotEmpty) {
//       return '$firstName $lastName';
//     } else if (firstName.isNotEmpty) {
//       return firstName;
//     } else {
//       return _user!.username;
//     }
//   }
  
//   // Get user initials
//   String get initials {
//     if (_user == null) return 'U';
    
//     final firstName = _user!.firstName;
//     final lastName = _user!.lastName;
    
//     String result = '';
    
//     if (firstName.isNotEmpty) {
//       result += firstName[0].toUpperCase();
//     }
    
//     if (lastName.isNotEmpty) {
//       result += lastName[0].toUpperCase();
//     }
    
//     if (result.isEmpty) {
//       result = _user!.username.isNotEmpty 
//           ? _user!.username[0].toUpperCase() 
//           : 'U';
//     }
    
//     return result;
//   }
  
//   @override
//   void dispose() {
//     _cancelTokenRefreshTimer();
//     super.dispose();
//   }
// }