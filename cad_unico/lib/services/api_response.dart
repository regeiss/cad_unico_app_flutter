/// Modelo genérico para respostas paginadas da API Django Rest Framework
class ApiResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final T results;

  const ApiResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  /// Factory constructor para criar instância a partir de JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) => ApiResponse<T>(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: fromJsonT(json['results']),
    );

  /// Método para converter instância para JSON
  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) => {
      'count': count,
      'next': next,
      'previous': previous,
      'results': toJsonT(results),
    };

  /// Verifica se há próxima página
  bool get hasNext => next != null && next!.isNotEmpty;

  /// Verifica se há página anterior
  bool get hasPrevious => previous != null && previous!.isNotEmpty;

  /// Retorna true se esta é a primeira página
  bool get isFirstPage => !hasPrevious;

  /// Retorna true se esta é a última página
  bool get isLastPage => !hasNext;

  /// Método copyWith para criar nova instância com campos modificados
  ApiResponse<T> copyWith({
    int? count,
    String? next,
    String? previous,
    T? results,
  }) => ApiResponse<T>(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );

  /// Método toString para debug
  @override
  String toString() => 'ApiResponse{count: $count, hasNext: $hasNext, hasPrevious: $hasPrevious}';

  /// Operadores de igualdade
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiResponse<T> &&
        other.count == count &&
        other.next == next &&
        other.previous == previous &&
        other.results == results;
  }

  @override
  int get hashCode => count.hashCode ^
        next.hashCode ^
        previous.hashCode ^
        results.hashCode;
}

/// Modelo para respostas simples da API (sem paginação)
class SimpleApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final List<String>? errors;

  const SimpleApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  /// Factory constructor para criar instância a partir de JSON
  factory SimpleApiResponse.fromJson(Map<String, dynamic> json) => SimpleApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      errors: json['errors'] != null 
          ? List<String>.from(json['errors'])
          : null,
    );

  /// Método para converter instância para JSON
  Map<String, dynamic> toJson() => {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };

  /// Factory constructor para sucesso
  factory SimpleApiResponse.success({
    String? message,
    dynamic data,
  }) => SimpleApiResponse(
      success: true,
      message: message,
      data: data,
    );

  /// Factory constructor para erro
  factory SimpleApiResponse.error({
    String? message,
    List<String>? errors,
    dynamic data,
  }) => SimpleApiResponse(
      success: false,
      message: message,
      errors: errors,
      data: data,
    );

  /// Retorna a primeira mensagem de erro, se houver
  String? get firstError {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.first;
    }
    return message;
  }

  /// Retorna todas as mensagens de erro como uma string
  String get allErrors {
    final errorMessages = <String>[];
    
    if (message != null && message!.isNotEmpty) {
      errorMessages.add(message!);
    }
    
    if (errors != null && errors!.isNotEmpty) {
      errorMessages.addAll(errors!);
    }
    
    return errorMessages.join(', ');
  }

  /// Método toString para debug
  @override
  String toString() => 'SimpleApiResponse{success: $success, message: $message, errors: $errors}';

  /// Operadores de igualdade
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SimpleApiResponse &&
        other.success == success &&
        other.message == message &&
        other.data == data &&
        other.errors == errors;
  }

  @override
  int get hashCode => success.hashCode ^
        message.hashCode ^
        data.hashCode ^
        errors.hashCode;
}

/// Modelo para erros de validação do Django Rest Framework
class ValidationError {
  final Map<String, List<String>> fieldErrors;
  final List<String>? nonFieldErrors;

  const ValidationError({
    required this.fieldErrors,
    this.nonFieldErrors,
  });

  /// Factory constructor para criar instância a partir de JSON
  factory ValidationError.fromJson(Map<String, dynamic> json) {
    final fieldErrors = <String, List<String>>{};
    
    json.forEach((key, value) {
      if (key != 'non_field_errors') {
        if (value is List) {
          fieldErrors[key] = value.cast<String>();
        } else if (value is String) {
          fieldErrors[key] = [value];
        }
      }
    });

    return ValidationError(
      fieldErrors: fieldErrors,
      nonFieldErrors: json['non_field_errors']?.cast<String>(),
    );
  }

  /// Método para converter instância para JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    fieldErrors.forEach((key, value) {
      json[key] = value;
    });
    
    if (nonFieldErrors != null) {
      json['non_field_errors'] = nonFieldErrors;
    }
    
    return json;
  }

  /// Retorna todos os erros como uma lista de strings
  List<String> get allErrors {
    final errors = <String>[];
    
    if (nonFieldErrors != null) {
      errors.addAll(nonFieldErrors!);
    }
    
    fieldErrors.forEach((field, fieldErrorList) {
      for (final error in fieldErrorList) {
        errors.add('$field: $error');
      }
    });
    
    return errors;
  }

  /// Retorna todos os erros como uma string
  String get allErrorsAsString => allErrors.join(', ');

  /// Retorna os erros de um campo específico
  List<String> getFieldErrors(String field) => fieldErrors[field] ?? [];

  /// Verifica se há erros para um campo específico
  bool hasFieldErrors(String field) => fieldErrors.containsKey(field) && fieldErrors[field]!.isNotEmpty;

  /// Verifica se há erros não relacionados a campos
  bool get hasNonFieldErrors => nonFieldErrors != null && nonFieldErrors!.isNotEmpty;

  /// Verifica se há algum erro
  bool get hasErrors => fieldErrors.isNotEmpty || hasNonFieldErrors;

  /// Método toString para debug
  @override
  String toString() => 'ValidationError{fieldErrors: $fieldErrors, nonFieldErrors: $nonFieldErrors}';
}

/// Modelo para respostas de paginação personalizada
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  /// Factory constructor para criar a partir de ApiResponse
  factory PaginationInfo.fromApiResponse(
    ApiResponse response,
    int itemsPerPage,
  ) {
    final totalPages = (response.count / itemsPerPage).ceil();
    
    // Tentar extrair página atual da URL next/previous
    int currentPage = 1;
    if (response.previous != null) {
      final previousMatch = RegExp(r'page=(\d+)').firstMatch(response.previous!);
      if (previousMatch != null) {
        currentPage = int.parse(previousMatch.group(1)!) + 1;
      }
    } else if (response.next != null) {
      final nextMatch = RegExp(r'page=(\d+)').firstMatch(response.next!);
      if (nextMatch != null) {
        currentPage = int.parse(nextMatch.group(1)!) - 1;
      }
    }

    return PaginationInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: response.count,
      itemsPerPage: itemsPerPage,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  /// Retorna true se esta é a primeira página
  bool get isFirstPage => currentPage == 1;

  /// Retorna true se esta é a última página
  bool get isLastPage => currentPage == totalPages;

  /// Retorna o número do primeiro item da página atual
  int get firstItemNumber => (currentPage - 1) * itemsPerPage + 1;

  /// Retorna o número do último item da página atual
  int get lastItemNumber {
    final lastItem = currentPage * itemsPerPage;
    return lastItem > totalItems ? totalItems : lastItem;
  }

  /// Método toString para debug
  @override
  String toString() => 'PaginationInfo{currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems}';
}