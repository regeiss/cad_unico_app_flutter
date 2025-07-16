import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  final ApiService _apiService = ApiService();

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  AuthProvider() {
    _loadSavedAuth();
  }
  
  // Carrega dados de autenticação salvos
  Future<void> _loadSavedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      
      if (_token != null) {
        // Verifica se o token ainda é válido
        final isValid = await _apiService.validateToken(_token!);
        if (isValid) {
          _isAuthenticated = true;
          await _loadUserProfile();
        } else {
          await _clearAuth();
        }
      }
    } on Exception catch (e) {
      debugPrint('Erro ao carregar autenticação: $e');
    }
    notifyListeners();
  }

  // Faz login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      
      if (response['success'] == true) {
        _token = response['token'];
        _isAuthenticated = true;
        
        // Salva o token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        // Carrega perfil do usuário
        await _loadUserProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on Exception catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro no login: $e');
      return false;
    }
  }

  // Carrega perfil do usuário
  Future<void> _loadUserProfile() async {
    try {
      final userData = await _apiService.getUserProfile();
      _user = UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    }
  }

  // Faz logout
  Future<void> logout() async {
    await _clearAuth();
    notifyListeners();
  }

  // Limpa dados de autenticação
  Future<void> _clearAuth() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Registra novo usuário (se necessário)
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(username, email, password);
      
      if (response['success'] == true) {
        // Após registro, fazer login automaticamente
        final loginSuccess = await login(username, password);
        return loginSuccess;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro no registro: $e');
      return false;
    }
  }

  // Atualiza perfil do usuário
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.updateUserProfile(userData);
      
      if (response['success'] == true) {
        await _loadUserProfile(); // Recarrega o perfil
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  // Troca senha
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.changePassword(currentPassword, newPassword);
      
      _isLoading = false;
      notifyListeners();
      return response['success'] == true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erro ao trocar senha: $e');
      return false;
    }
  }
}