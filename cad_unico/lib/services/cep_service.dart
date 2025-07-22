// lib/services/cep_service.dart
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CepModel {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String ibge;
  final String gia;
  final String ddd;
  final String siafi;
  final bool erro;

  CepModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ibge,
    required this.gia,
    required this.ddd,
    required this.siafi,
    this.erro = false,
  });

  factory CepModel.fromJson(Map<String, dynamic> json) => CepModel(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      ibge: json['ibge'] ?? '',
      gia: json['gia'] ?? '',
      ddd: json['ddd'] ?? '',
      siafi: json['siafi'] ?? '',
      erro: json['erro'] == true,
    );

  Map<String, dynamic> toJson() => {
      'cep': cep,
      'logradouro': logradouro,
      'complemento': complemento,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'ibge': ibge,
      'gia': gia,
      'ddd': ddd,
      'siafi': siafi,
      'erro': erro,
    };
}

class CepService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://viacep.com.br/ws/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Busca informações de endereço pelo CEP
  /// [cep] deve conter apenas números (8 dígitos)
  static Future<CepModel?> buscarCep(String cep) async {
    try {
      // Remove formatação do CEP
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Valida se o CEP tem 8 dígitos
      if (cleanCep.length != 8) {
        debugPrint('CEP deve ter 8 dígitos');
        return null;
      }
      
      // Faz a requisição para a API do ViaCEP
      final response = await _dio.get('$cleanCep/json/');
      
      if (response.statusCode == 200) {
        final cepData = CepModel.fromJson(response.data);
        
        // Verifica se houve erro na resposta da API
        if (cepData.erro) {
          debugPrint('CEP não encontrado: $cleanCep');
          return null;
        }
        
        return cepData;
      }
      
      return null;
    } on DioException catch (e) {
      debugPrint('Erro ao buscar CEP: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tempo limite de conexão esgotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tempo limite de resposta esgotado');
      } else {
        throw Exception('Erro de rede ao buscar CEP');
      }
    } catch (e) {
      debugPrint('Erro inesperado ao buscar CEP: $e');
      throw Exception('Erro inesperado ao buscar CEP');
    }
  }

  /// Busca CEPs por endereço (busca reversa)
  /// [uf] deve ter 2 caracteres (ex: SP, RJ)
  /// [cidade] nome da cidade
  /// [logradouro] nome da rua/avenida (mínimo 3 caracteres)
  static Future<List<CepModel>> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) async {
    try {
      // Valida parâmetros
      if (uf.length != 2) {
        throw Exception('UF deve ter 2 caracteres');
      }
      
      if (cidade.length < 2) {
        throw Exception('Nome da cidade deve ter pelo menos 2 caracteres');
      }
      
      if (logradouro.length < 3) {
        throw Exception('Nome do logradouro deve ter pelo menos 3 caracteres');
      }
      
      // Faz a requisição
      final response = await _dio.get('$uf/$cidade/$logradouro/json/');
      
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => CepModel.fromJson(json)).toList();
      }
      
      return [];
    } on DioException catch (e) {
      debugPrint('Erro ao buscar endereços: ${e.message}');
      throw Exception('Erro de rede ao buscar endereços');
    } catch (e) {
      debugPrint('Erro inesperado ao buscar endereços: $e');
      rethrow;
    }
  }

  /// Valida se um CEP tem formato válido
  static bool isValidCepFormat(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCep.length == 8 && int.tryParse(cleanCep) != null;
  }
}