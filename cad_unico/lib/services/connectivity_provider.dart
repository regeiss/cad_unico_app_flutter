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
    } on Exception {
      debugPrint('Erro ao verificar conectividade: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    if (!wasConnected && _isConnected) {
      // Voltou online - trigger sincronização
      _onBackOnline();
    }

    notifyListeners();
  }

  void _onBackOnline() {
    // Aqui você pode implementar a lógica de sincronização
    debugPrint('Voltou online - iniciando sincronização...');
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
