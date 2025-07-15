// ignore_for_file: avoid_catches_without_on_clauses, avoid_classes_with_only_static_members

import 'package:flutter/foundation.dart';

class AnalyticsService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Inicializar Firebase Analytics ou outra solução
      if (kDebugMode) {
        debugPrint('Analytics initialized in debug mode');
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing analytics: $e');
    }
  }

  // User events
  static Future<void> logLogin(String method) async {
    await _logEvent('login', {'method': method});
  }

  static Future<void> logSignUp(String method) async {
    await _logEvent('sign_up', {'method': method});
  }

  // Screen tracking
  static Future<void> logScreenView(String screenName) async {
    await _logEvent('screen_view', {'screen_name': screenName});
  }

  // Business events
  static Future<void> logResponsavelCreated() async {
    await _logEvent('responsavel_created');
  }

  static Future<void> logMembroAdded() async {
    await _logEvent('membro_added');
  }

  static Future<void> logDemandaViewed(String type) async {
    await _logEvent('demanda_viewed', {'type': type});
  }

  // Search and filter events
  static Future<void> logSearch(String query, String section) async {
    await _logEvent('search', {
      'search_term': query,
      'section': section,
    });
  }

  static Future<void> logFilterUsed(String filterType, String value) async {
    await _logEvent('filter_used', {
      'filter_type': filterType,
      'filter_value': value,
    });
  }

  // Error tracking
  static Future<void> logError(String error, Map<String, dynamic>? context) async {
    await _logEvent('error_occurred', {
      'error_message': error,
      ...?context,
    });
  }

  // Performance tracking
  static Future<void> logPerformance(String action, int duration) async {
    await _logEvent('performance', {
      'action': action,
      'duration_ms': duration,
    });
  }

  static Future<void> _logEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    if (!_initialized) await init();
    
    try {
      if (kDebugMode) {
        debugPrint('Analytics Event: $eventName ${parameters ?? ''}');
      }
      // Implementar envio real para o serviço de analytics
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }

  // User properties
  static Future<void> setUserProperty(String name, String value) async {
    if (!_initialized) await init();
    
    try {
      if (kDebugMode) {
        debugPrint('Analytics User Property: $name = $value');
      }
      // Implementar definição de propriedade do usuário
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }
}