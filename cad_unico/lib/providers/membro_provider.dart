// lib/providers/membro_provider.dart
import 'package:flutter/material.dart';
import '../contants/constants.dart';
import '../models/membro_model.dart';
import '../services/api_service.dart';

class MembroProvider with ChangeNotifier {
  List<Membro> _membros = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  List<Membro> get membros => _membros;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadMembros() async {
    try {
      _setLoading(true);
      _setError(null);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _membros = []; // Replace with actual API call
      _setLoading(false);
    } catch (e) {
      _setError(AppConstants.networkErrorMessage);
      _setLoading(false);
    }
  }
}
