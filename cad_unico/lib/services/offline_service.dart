// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  static const String _offlineActionsKey = 'offline_actions';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Estrutura para ações offline
  static Future<void> saveOfflineAction({
    required String action,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final actionsJson = prefs.getString(_offlineActionsKey) ?? '[]';
    final actions = List<Map<String, dynamic>>.from(jsonDecode(actionsJson));

    final offlineAction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action, // 'create', 'update', 'delete'
      'type': type, // 'responsavel', 'membro', etc.
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    actions.add(offlineAction);
    await prefs.setString(_offlineActionsKey, jsonEncode(actions));
  }

  // Sincronizar ações offline quando voltar online
  static Future<List<Map<String, dynamic>>> getOfflineActions() async {
    final prefs = await SharedPreferences.getInstance();
    final actionsJson = prefs.getString(_offlineActionsKey) ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(actionsJson));
  }

  // Limpar ações sincronizadas
  static Future<void> clearOfflineActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineActionsKey);
  }

  // Verificar conectividade
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Salvar timestamp da última sincronização
  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  // Obter timestamp da última sincronização
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
}

// lib/providers/connectivity_provider.dart
