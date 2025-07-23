// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/responsavel_model.dart';

class CacheService {
  static const String _responsaveisKey = 'responsaveis_cache';
  // ignore: unused_field
  static const String _membrosKey = 'membros_cache';

  static Future<void> cacheResponsaveis(List<Responsavel> responsaveis) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = responsaveis.map((r) => r.toJson()).toList();
    await prefs.setString(_responsaveisKey, jsonEncode(jsonList));
  }

  static Future<List<Responsavel>?> getCachedResponsaveis() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_responsaveisKey);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Responsavel.fromJson(json)).toList();
    }
    return null;
  }
}
