// lib/providers/demanda_provider.dart
import 'package:flutter/material.dart';
import '../contants/constants.dart';
import '../models/demanda_model.dart';
import '../services/api_service.dart';

class DemandaProvider with ChangeNotifier {
  List<DemandaModel> _demandas = [];
  bool _isLoading = false;
  String? _error;
  
  final ApiService _apiService = ApiService();
  
  List<DemandaModel> get demandas => _demandas;
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
  
  Future<void> loadDemandas() async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _demandas = []; // Replace with actual API call
      _setLoading(false);
    } on Exception   {
      _setError(AppConstants.networkErrorMessage);
      _setLoading(false);
    }
  }
}

