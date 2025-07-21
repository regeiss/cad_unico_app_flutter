import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../contants/constants.dart';
import '../models/user_model.dart';
import '../services/hybrid_storage_service.dart';
import 'auth_extensions.dart' show StringExtensions, MapExtensions;

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  // Estados principais
  bool _isAuthenticated = false;
  final bool _isLoading = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _user;
  String? _token;
  String? _refreshToken;
  String? _errorMessage;

  // Storage
  late HybridStorageService _storage;

  // Timer para auto-refresh do token
  Timer? _tokenRefreshTimer;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get errorMessage => _errorMessage;
  String? get userName => _user?['username'];
  String? get userEmail => _user?['email'];
  String? get userFirstName => _user?['first_name'];
  String? get userLastName => _user?['last_name'];
  int? get userId => _user?['id'];
  bool get isStaff => _user?['is_staff'] ?? false;
  bool get isActive => _user?['is_active'] ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  String get userDisplayName {
    if (_user == null) return 'Usuário';
    return _user!.fullName.isNotEmpty ? _user!.fullName : _user!.username;
  }

  String get userInitials => _user?.initials ?? 'U';

  // ============ INICIALIZAÇÃO ============

  Future<void> _initializeAuth() async {
    if (kDebugMode) {
      print('🔄 Inicializando AuthProvider...');
    }

    try {
      _storage = await HybridStorageService.getInstance();
      await _loadStoredAuth();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro na inicialização do AuthProvider: $e');
      }
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Carrega dados de autenticação salvos
  Future<void> _loadStoredAuth() async {
    try {
      if (kDebugMode) {
        print('📥 Carregando dados de autenticação salvos...');
      }

      // Força reload para web
      if (kIsWeb) {
        await _storage.reload();
      }

      final isLoggedIn = await _storage.isLoggedIn();

      if (isLoggedIn) {
        _token = await _storage.getToken();
        _refreshToken = await _storage.getRefreshToken();
        _user = await _storage.getUser();

        if (_token != null && _user != null) {
          // Verifica se o token ainda é válido
          if (await _validateToken()) {
            _isAuthenticated = true;
            _startTokenRefreshTimer();
            if (kDebugMode) {
              print('✅ Sessão restaurada com sucesso');
            }
          } else {
            if (kDebugMode) {
              print('⚠️ Token inválido, tentando renovar...');
            }
            if (await _tryRefreshToken()) {
              _isAuthenticated = true;
              _startTokenRefreshTimer();
            } else {
              await logout();
            }
          }
        } else {
          if (kDebugMode) {
            print('❌ Dados incompletos no storage');
          }
          await logout();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao carregar dados salvos: $e');
      }
      await logout();
    }
  }

  // ============ AUTENTICAÇÃO ============

  /// Login do usuário
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (kDebugMode) {
        print('🔐 Tentando fazer login para: $username');
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/auth/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('📡 Status da resposta: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _token = data['token'];
          _refreshToken = data['refresh'];
          _user = data['user'];

          // Salva no storage com verificações robustas
          final saveSuccess = await _storage.saveSession(
            token: _token!,
            refreshToken: _refreshToken!,
            userData: _user!,
          );

          if (saveSuccess) {
            _isAuthenticated = true;
            _startTokenRefreshTimer();
            _setLoading(false);

            _showSuccessMessage('Login realizado com sucesso!');

            if (kDebugMode) {
              print('✅ Login realizado com sucesso');
              await _storage.debugListAll();
            }

            return true;
          } else {
            _setError('Erro ao salvar dados da sessão');
            if (kDebugMode) {
              print('❌ Falha ao salvar sessão');
            }
          }
        } else {
          _setError(data['message'] ?? 'Credenciais inválidas');
        }
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Erro de comunicação com servidor');
      }
    } catch (e) {
      _setError('Erro de conexão. Verifique sua internet.');
      if (kDebugMode) {
        print('❌ Erro no login: $e');
      }
    }

    _setLoading(false);
    return false;
  }

  /// Logout do usuário
  Future<void> logout() async {
    if (kDebugMode) {
      print('🚪 Fazendo logout...');
    }

    _setLoading(true);

    try {
      // Para timer de refresh
      _tokenRefreshTimer?.cancel();

      // Tenta invalidar o token no servidor
      if (_refreshToken != null) {
        await _invalidateTokenOnServer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao invalidar token no servidor: $e');
      }
    }

    // Limpa dados locais
    await _storage.clearAuth();

    _isAuthenticated = false;
    _token = null;
    _refreshToken = null;
    _user = null;
    _clearError();

    _setLoading(false);

    _showSuccessMessage('Logout realizado com sucesso!');

    if (kDebugMode) {
      print('✅ Logout realizado com sucesso');
    }
  }

  /// Registra novo usuário
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
      if (password != passwordConfirm) {
        _setError('As senhas não coincidem');
        _setLoading(false);
        return false;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/auth/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessMessage('Usuário criado com sucesso! Faça login.');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Erro ao criar usuário');
      }
    } catch (e) {
      _setError('Erro de conexão. Verifique sua internet.');
      if (kDebugMode) {
        print('❌ Erro no registro: $e');
      }
    }

    _setLoading(false);
    return false;
  }

  /// Altera senha do usuário
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    if (!_isAuthenticated) {
      _setError('Usuário não autenticado');
      return false;
    }

    if (newPassword != newPasswordConfirm) {
      _setError('As novas senhas não coincidem');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await authenticatedRequest(
        'POST',
        '/api/v1/auth/change-password/',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Senha alterada com sucesso!');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Erro ao alterar senha');
      }
    } catch (e) {
      _setError('Erro de conexão');
      if (kDebugMode) {
        print('❌ Erro ao alterar senha: $e');
      }
    }

    _setLoading(false);
    return false;
  }

  /// Atualiza perfil do usuário
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (!_isAuthenticated) {
      _setError('Usuário não autenticado');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (email != null) body['email'] = email;

      final response = await authenticatedRequest(
        'PUT',
        '/api/v1/auth/profile/',
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = data;
        await _storage.saveUser(_user!);

        _showSuccessMessage('Perfil atualizado com sucesso!');
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Erro ao atualizar perfil');
      }
    } catch (e) {
      _setError('Erro de conexão');
      if (kDebugMode) {
        print('❌ Erro ao atualizar perfil: $e');
      }
    }

    _setLoading(false);
    return false;
  }

  // ============ VALIDAÇÃO E RENOVAÇÃO DE TOKEN ============

  /// Valida se o token atual ainda é válido
  Future<bool> _validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/auth/verify/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': _token}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro na validação do token: $e');
      }
      return false;
    }
  }

  /// Tenta renovar o token usando refresh token
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;

    try {
      if (kDebugMode) {
        print('🔄 Tentando renovar token...');
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/auth/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access'];

        // Salva o novo token
        await _storage.saveToken(_token!);

        if (kDebugMode) {
          print('✅ Token renovado com sucesso');
        }

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao renovar token: $e');
      }
    }

    return false;
  }

  /// Inicia timer para auto-refresh do token
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    // Renova o token a cada 55 minutos (token expira em 1 hora)
    _tokenRefreshTimer =
        Timer.periodic(const Duration(minutes: 55), (timer) async {
      if (_isAuthenticated && _refreshToken != null) {
        final refreshed = await _tryRefreshToken();
        if (!refreshed) {
          // Se não conseguiu renovar, faz logout
          await logout();
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Invalida token no servidor
  Future<void> _invalidateTokenOnServer() async {
    try {
      await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/auth/logout/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao invalidar token no servidor: $e');
      }
    }
  }

  // ============ MÉTODOS DE APOIO ============

  // void _setStatus(AuthStatus status) {
  //   _status = status;
  //   notifyListeners();
  // }

  // void _setLoggingIn(bool loggingIn) {
  //   _isLoggingIn = loggingIn;
  //   notifyListeners();
  // }

  // void _setLoggingOut(bool loggingOut) {
  //   _isLoggingOut = loggingOut;
  //   notifyListeners();
  // }

  // void _setRegistering(bool registering) {
  //   _isRegistering = registering;
  //   notifyListeners();
  // }

  // void _setError(String error) {
  //   _errorMessage = error;
  //   _status = AuthStatus.error;
  //   notifyListeners();
  // }

  // void _clearError() {
  //   _errorMessage = null;
  //   if (_status == AuthStatus.error) {
  //     _status =
  //         _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  //   }
  //   notifyListeners();
  // }

  // void clearError() {
  //   _clearError();
  // }

  void _showSuccessMessage(String message) {
    if (kIsWeb) {
      // Para web, você pode implementar um snackbar customizado
      if (kDebugMode) print('✅ $message');
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  void _showErrorMessage(String message) {
    if (kIsWeb) {
      // Para web, você pode implementar um snackbar customizado
      if (kDebugMode) print('❌ $message');
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// Força verificação de autenticação
  Future<void> checkAuth() async {
    await _loadStoredAuth();
  }

  /// Recarrega dados do usuário do servidor
  Future<void> refreshUserData() async {
    if (!_isAuthenticated) return;

    try {
      final response =
          await authenticatedRequest('GET', '/api/v1/auth/profile/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = data;
        await _storage.saveUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recarregar dados do usuário: $e');
      }
    }
  }

  // ============ MÉTODOS PARA REQUISIÇÕES ============

  /// Obtém headers com token para requisições autenticadas
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  /// Faz requisição autenticada com renovação automática de token
  Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    var headers = getAuthHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    http.Response response;
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError('Método HTTP não suportado: $method');
    }

    // Se token expirou, tenta renovar e refaz a requisição
    if (response.statusCode == 401) {
      if (await _tryRefreshToken()) {
        // Atualiza headers com novo token
        headers = getAuthHeaders();
        if (additionalHeaders != null) {
          headers.addAll(additionalHeaders);
        }

        // Refaz a requisição
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'POST':
            response = await http.post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
        }
      } else {
        // Se não conseguiu renovar, faz logout
        await logout();
        throw Exception('Sessão expirada. Faça login novamente.');
      }
    }

    return response;
  }

  /// Faz requisição GET autenticada
  Future<http.Response> get(String endpoint,
      {Map<String, String>? additionalHeaders}) {
    return authenticatedRequest('GET', endpoint,
        additionalHeaders: additionalHeaders);
  }

  /// Faz requisição POST autenticada
  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? additionalHeaders}) {
    return authenticatedRequest('POST', endpoint,
        body: body, additionalHeaders: additionalHeaders);
  }

  /// Faz requisição PUT autenticada
  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? additionalHeaders}) {
    return authenticatedRequest('PUT', endpoint,
        body: body, additionalHeaders: additionalHeaders);
  }

  /// Faz requisição DELETE autenticada
  Future<http.Response> delete(String endpoint,
      {Map<String, String>? additionalHeaders}) {
    return authenticatedRequest('DELETE', endpoint,
        additionalHeaders: additionalHeaders);
  }

  // ============ MÉTODOS DE DEBUG ============

  /// Método para debug - força limpeza total
  Future<void> debugClearAll() async {
    if (kDebugMode) {
      print('🧹 DEBUG: Limpando todos os dados...');
      await _storage.clearAuth();
      await logout();
      print('✅ DEBUG: Todos os dados limpos');
    }
  }

  /// Método para debug - mostra status atual
  void debugStatus() {
    if (kDebugMode) {
      print('=== STATUS AUTH PROVIDER ===');
      print('Inicializado: $_isInitialized');
      print('Autenticado: $_isAuthenticated');
      print('Loading: $_isLoading');
      print('Token: ${_token?.substring(0, 20)}...');
      print('RefreshToken: ${_refreshToken?.substring(0, 20)}...');
      print('User: ${_user?['username']}');
      print('Erro: $_errorMessage');
      print('==============================');
    }
  }

  // ============ MÉTODOS PARA COMPATIBILIDADE ============

  /// Verifica se usuário é admin/staff
  bool get isAdmin => _user?['is_staff'] == true;

  /// Verifica se usuário está ativo
  bool get isUserActive => _user?['is_active'] == true;

  /// Obtém nome completo do usuário
  String get fullName {
    final firstName = _user?['first_name'] ?? '';
    final lastName = _user?['last_name'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      return _user?['username'] ?? 'Usuário';
    }

    return '$firstName $lastName'.trim();
  }

  /// Obtém iniciais do usuário
  // String get userInitials {
  //   final firstName = _user?['first_name'] ?? '';
  //   final lastName = _user?['last_name'] ?? '';
  //   final username = _user?['username'] ?? '';

  //   if (firstName.isNotEmpty && lastName.isNotEmpty) {
  //     return '${firstName[0]}${lastName[0]}'.toUpperCase();
  //   } else if (username.isNotEmpty) {
  //     return username.length >= 2
  //         ? username.substring(0, 2).toUpperCase()
  //         : username.toUpperCase();
  //   }

  //   return 'U';
  // }

  /// Verifica se pode acessar área administrativa
  bool canAccessAdmin() {
    return _isAuthenticated && isAdmin && isUserActive;
  }

  /// Verifica se pode editar dados
  bool canEdit() {
    return _isAuthenticated && isUserActive;
  }

  /// Verifica se pode visualizar dados sensíveis
  bool canViewSensitiveData() {
    return _isAuthenticated && isUserActive;
  }
  
  void _setLoading(bool bool) {}
}

// // lib/providers/auth_provider.dart
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../contants/constants.dart';
// import '../models/user_model.dart';
// import '../services/api_service.dart';

// enum AuthStatus {
//   initial,
//   loading,
//   authenticated,
//   unauthenticated,
//   error,
// }

// class AuthProvider extends ChangeNotifier {
//   final ApiService _apiService;

//   // Estado do usuário
//   UserModel? _user;
//   AuthStatus _status = AuthStatus.initial;
//   bool _isLoading = false;
//   bool _isLoggingIn = false;
//   bool _isLoggingOut = false;
//   bool _isRegistering = false;
//   String? _errorMessage;
//   String? _token;
//   String? _refreshToken;

//   // Construtor
//   AuthProvider(this._apiService) {
//     _initializeAuth();
//   }

//   // ==========================================================================
//   // GETTERS
//   // ==========================================================================

//   UserModel? get user => _user;
//   AuthStatus get status => _status;
//   bool get isLoading => _isLoading;
//   bool get isLoggingIn => _isLoggingIn;
//   bool get isLoggingOut => _isLoggingOut;
//   bool get isRegistering => _isRegistering;
//   String? get errorMessage => _errorMessage;
//   String? get token => _token;
//   bool get isAuthenticated =>
//       _status == AuthStatus.authenticated && _user != null;
//   bool get hasError => _status == AuthStatus.error && _errorMessage != null;

//   String get userDisplayName {
//     if (_user == null) return 'Usuário';
//     return _user!.fullName.isNotEmpty ? _user!.fullName : _user!.username;
//   }

//   String get userInitials => _user?.initials ?? 'U';

//   // ==========================================================================
//   // INICIALIZAÇÃO
//   // ==========================================================================

//   Future<void> _initializeAuth() async {
//     _setStatus(AuthStatus.loading);

//     try {
//       // Carregar tokens salvos
//       await _loadSavedTokens();

//       // Se tiver token, tentar carregar perfil do usuário
//       if (_apiService.isAuthenticated) {
//         await _loadUserProfile();
//       } else {
//         _setStatus(AuthStatus.unauthenticated);
//       }
//     } on Exception catch (e) {
//       debugPrint('Erro na inicialização da autenticação: $e');
//       _setStatus(AuthStatus.unauthenticated);
//     }
//   }

//   Future<void> _loadSavedTokens() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _token = prefs.getString(AppConstants.tokenKey);
//       _refreshToken = prefs.getString(AppConstants.refreshTokenKey);

//       // Carregar dados do usuário salvos
//       final userDataString = prefs.getString(AppConstants.userDataKey);
//       debugPrint(
//           'Loaded userDataString from SharedPreferences: $userDataString');
//       if (userDataString != null) {
//         final userData = jsonDecode(userDataString);
//         debugPrint('Decoded userData from SharedPreferences: $userData');
//         _user = UserModel.fromJson(userData);
//       }
//     } catch (e) {
//       debugPrint('Erro ao carregar tokens salvos: $e');
//     }
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final result = await _apiService.getUserProfile();

//       if (result['success']) {
//         _user = UserModel.fromJson(result['data']);
//         await _saveUserData();
//         _setStatus(AuthStatus.authenticated);
//       } else {
//         // Se falhar ao carregar perfil, limpar dados
//         await _clearAuthData();
//         _setStatus(AuthStatus.unauthenticated);
//       }
//     } catch (e) {
//       debugPrint('Erro ao carregar perfil do usuário: $e');
//       await _clearAuthData();
//       _setStatus(AuthStatus.unauthenticated);
//     }
//   }

//   // ==========================================================================
//   // MÉTODOS DE AUTENTICAÇÃO
//   // ==========================================================================

//   Future<bool> login(String username, String password) async {
//     if (_isLoggingIn) return false;

//     _setLoggingIn(true);
//     _clearError();

//     try {
//       final result = await _apiService.login(username, password);

//       if (result['success']) {
//         // Extrair dados do resultado
//         final data = result['data'];
//         _token = data['token'] ?? data['access'];
//         _refreshToken = data['refresh'];

//         // Criar usuário a partir dos dados
//         if (data['user'] != null) {
//           debugPrint('Attempting to parse user data: ${data['user']}');
//           _user = UserModel.fromJson(data['user']);
//         } else {
//           // Se não tiver dados do usuário na resposta, carregar do perfil
//           await _loadUserProfile();
//         }

//         await _saveUserData();
//         await _saveLastLogin();
//         _setStatus(AuthStatus.authenticated);

//         return true;
//       } else {
//         _setError(result['message'] ?? AppConstants.loginError);
//         _setStatus(AuthStatus.error);
//         return false;
//       }
//     } on Exception catch (e) {
//       debugPrint('Erro no login: $e');
//       _setError('Erro inesperado durante o login');
//       _setStatus(AuthStatus.error);
//       return false;
//     } finally {
//       _setLoggingIn(false);
//     }
//   }

//   Future<bool> register({
//     required String username,
//     required String email,
//     required String password,
//     required String passwordConfirm,
//     String? firstName,
//     String? lastName,
//   }) async {
//     if (_isRegistering) return false;

//     _setRegistering(true);
//     _clearError();

//     try {
//       final result = await _apiService.register({
//         'username': username,
//         'email': email,
//         'password': password,
//         'password_confirm': passwordConfirm,
//         'first_name': firstName ?? '',
//         'last_name': lastName ?? '',
//       });

//       if (result['success']) {
//         // Após registro bem-sucedido, fazer login automático
//         final loginSuccess = await login(username, password);
//         return loginSuccess;
//       } else {
//         _setError(result['message'] ?? 'Erro ao criar conta');
//         _setStatus(AuthStatus.error);
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Erro no registro: $e');
//       _setError('Erro inesperado durante o registro');
//       _setStatus(AuthStatus.error);
//       return false;
//     } finally {
//       _setRegistering(false);
//     }
//   }

//   Future<void> logout() async {
//     if (_isLoggingOut) return;

//     _setLoggingOut(true);

//     try {
//       // Chamar logout na API
//       await _apiService.logout();
//     } catch (e) {
//       debugPrint('Erro no logout da API: $e');
//     } finally {
//       // Limpar dados locais independente do resultado da API
//       await _clearAuthData();
//       _setStatus(AuthStatus.unauthenticated);
//       _setLoggingOut(false);
//     }
//   }

//   Future<void> forceLogout() async {
//     await _clearAuthData();
//     _setStatus(AuthStatus.unauthenticated);
//   }

//   // ==========================================================================
//   // MÉTODOS DE VALIDAÇÃO DE TOKEN
//   // ==========================================================================

//   Future<bool> validateToken() async {
//     if (!_apiService.isAuthenticated) return false;

//     try {
//       final result = await _apiService.verifyToken();

//       if (result['success']) {
//         return true;
//       } else {
//         // Token inválido, tentar renovar
//         return await _refreshAuthToken();
//       }
//     } catch (e) {
//       debugPrint('Erro ao validar token: $e');
//       return false;
//     }
//   }

//   Future<bool> _refreshAuthToken() async {
//     if (_refreshToken == null) return false;

//     try {
//       final result = await _apiService.refreshToken(_refreshToken!);

//       if (result['success']) {
//         _token = result['data']['access'];
//         await _saveTokens();
//         return true;
//       } else {
//         // Não conseguiu renovar, fazer logout
//         await forceLogout();
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Erro ao renovar token: $e');
//       await forceLogout();
//       return false;
//     }
//   }

//   // ==========================================================================
//   // MÉTODOS DE PERFIL
//   // ==========================================================================

//   Future<bool> updateProfile({
//     String? firstName,
//     String? lastName,
//     String? email,
//   }) async {
//     if (_user == null) return false;

//     _setLoading(true);
//     _clearError();

//     try {
//       final data = <String, dynamic>{};
//       if (firstName != null) data['first_name'] = firstName;
//       if (lastName != null) data['last_name'] = lastName;
//       if (email != null) data['email'] = email;

//       final result = await _apiService.updateUserProfile(data);

//       if (result['success']) {
//         _user = UserModel.fromJson(result['data']);
//         await _saveUserData();
//         return true;
//       } else {
//         _setError(result['message'] ?? 'Erro ao atualizar perfil');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Erro ao atualizar perfil: $e');
//       _setError('Erro inesperado ao atualizar perfil');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<bool> changePassword({
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     _setLoading(true);
//     _clearError();

//     try {
//       final result = await _apiService.changePassword(
//         currentPassword: currentPassword,
//         newPassword: newPassword,
//       );

//       if (result['success']) {
//         return true;
//       } else {
//         _setError(result['message'] ?? 'Erro ao alterar senha');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Erro ao alterar senha: $e');
//       _setError('Erro inesperado ao alterar senha');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // ==========================================================================
//   // MÉTODOS DE PERSISTÊNCIA
//   // ==========================================================================

//   Future<void> _saveUserData() async {
//     if (_user == null) return;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(
//           AppConstants.userDataKey, jsonEncode(_user!.toJson()));
//     } catch (e) {
//       debugPrint('Erro ao salvar dados do usuário: $e');
//     }
//   }

//   Future<void> _saveTokens() async {
//     if (_token == null) return;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(AppConstants.tokenKey, _token!);

//       if (_refreshToken != null) {
//         await prefs.setString(AppConstants.refreshTokenKey, _refreshToken!);
//       }
//     } catch (e) {
//       debugPrint('Erro ao salvar tokens: $e');
//     }
//   }

//   Future<void> _saveLastLogin() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(
//           AppConstants.lastLoginKey, DateTime.now().toIso8601String());
//     } catch (e) {
//       debugPrint('Erro ao salvar último login: $e');
//     }
//   }

//   Future<void> _clearAuthData() async {
//     try {
//       _user = null;
//       _token = null;
//       _refreshToken = null;

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(AppConstants.tokenKey);
//       await prefs.remove(AppConstants.refreshTokenKey);
//       await prefs.remove(AppConstants.userDataKey);
//       await prefs.remove(AppConstants.lastLoginKey);
//     } catch (e) {
//       debugPrint('Erro ao limpar dados de autenticação: $e');
//     }
//   }

//   // ==========================================================================
//   // MÉTODOS DE ESTADO
//   // ==========================================================================

//   void _setStatus(AuthStatus status) {
//     _status = status;
//     notifyListeners();
//   }

//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setLoggingIn(bool loggingIn) {
//     _isLoggingIn = loggingIn;
//     notifyListeners();
//   }

//   void _setLoggingOut(bool loggingOut) {
//     _isLoggingOut = loggingOut;
//     notifyListeners();
//   }

//   void _setRegistering(bool registering) {
//     _isRegistering = registering;
//     notifyListeners();
//   }

//   void _setError(String error) {
//     _errorMessage = error;
//     _status = AuthStatus.error;
//     notifyListeners();
//   }

//   void _clearError() {
//     _errorMessage = null;
//     if (_status == AuthStatus.error) {
//       _status =
//           _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
//     }
//     notifyListeners();
//   }

//   void clearError() {
//     _clearError();
//   }

//   // ==========================================================================
//   // MÉTODOS DE UTILIDADE
//   // ==========================================================================

//   bool get canRefreshToken => _refreshToken != null;

//   Future<DateTime?> getLastLoginDate() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final lastLoginString = prefs.getString(AppConstants.lastLoginKey);
//       return lastLoginString != null
//           ? DateTime.tryParse(lastLoginString)
//           : null;
//     } catch (e) {
//       debugPrint('Erro ao obter data do último login: $e');
//       return null;
//     }
//   }

//   bool get hasValidSession => isAuthenticated && _token != null;

//   // ==========================================================================
//   // MÉTODOS DE DEBUG
//   // ==========================================================================

//   void debugPrintUserInfo() {
//     if (AppConstants.enableDebugMode) {
//       debugPrint('=== AUTH PROVIDER DEBUG ===');
//       debugPrint('Status: $_status');
//       debugPrint('User: $_user');
//       debugPrint('Has Token: ${_token != null}');
//       debugPrint('Has Refresh Token: ${_refreshToken != null}');
//       debugPrint('Is Authenticated: $isAuthenticated');
//       debugPrint('========================');
//     }
//   }

//   @override
//   void dispose() {
//     // Limpar recursos se necessário
//     super.dispose();
//   }
// }
// lib/providers/auth_provider.dart
