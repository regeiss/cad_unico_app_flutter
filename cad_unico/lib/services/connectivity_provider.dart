import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar conectividade: $e');
      }
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    
    // Considera conectado se não for "none"
    _isConnected = result != ConnectivityResult.none;

    if (!wasConnected && _isConnected) {
      // Voltou online - trigger sincronização
      _onBackOnline();
    } else if (wasConnected && !_isConnected) {
      // Perdeu conexão
      _onOffline();
    }

    notifyListeners();
  }

  void _onBackOnline() {
    // Aqui você pode implementar a lógica de sincronização
    if (kDebugMode) {
      print('📶 Voltou online - iniciando sincronização...');
    }
    
    // Exemplo: notificar outros providers para sincronizar
    // context.read<AuthProvider>().syncWhenOnline();
    // context.read<ResponsavelProvider>().syncPendingChanges();
  }

  void _onOffline() {
    if (kDebugMode) {
      print('📵 Perdeu conexão - modo offline ativado');
    }
  }

  /// Verifica manualmente o status da conectividade
  Future<bool> checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
      return _isConnected;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar conectividade manualmente: $e');
      }
      return false;
    }
  }

  /// Força uma verificação de conectividade
  Future<void> forceCheck() async {
    await checkConnectivity();
  }

  /// Retorna o tipo de conexão atual
  Future<ConnectivityResult> getCurrentConnectivity() async {
    try {
      return await Connectivity().checkConnectivity();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter conectividade atual: $e');
      }
      return ConnectivityResult.none;
    }
  }

  /// Retorna uma string descritiva do status de conectividade
  Future<String> getConnectivityStatus() async {
    try {
      final result = await getCurrentConnectivity();
      
      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Dados Móveis';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.other:
          return 'Outra Conexão';
        case ConnectivityResult.none:
        default:
          return 'Sem Conexão';
      }
    } catch (e) {
      return 'Erro ao verificar';
    }
  }

  /// Verifica se está conectado via WiFi
  Future<bool> isWifiConnected() async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Verifica se está conectado via dados móveis
  Future<bool> isMobileConnected() async {
    final result = await getCurrentConnectivity();
    return result == ConnectivityResult.mobile;
  }

  /// Retorna um ícone baseado no tipo de conexão
  String getConnectionIcon() {
    if (!_isConnected) return '📵';
    return '📶';
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}