class FilterOptions {
  final String? search;
  final String? status;
  final String? bairro;
  final String? genero;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final Map<String, dynamic>? customFilters;

  FilterOptions({
    this.search,
    this.status,
    this.bairro,
    this.genero,
    this.dataInicio,
    this.dataFim,
    this.customFilters,
  });

  FilterOptions copyWith({
    String? search,
    String? status,
    String? bairro,
    String? genero,
    DateTime? dataInicio,
    DateTime? dataFim,
    Map<String, dynamic>? customFilters,
  }) => FilterOptions(
      search: search ?? this.search,
      status: status ?? this.status,
      bairro: bairro ?? this.bairro,
      genero: genero ?? this.genero,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      customFilters: customFilters ?? this.customFilters,
    );

  bool get hasFilters => (search?.isNotEmpty ?? false) ||
           status != null ||
           bairro != null ||
           genero != null ||
           dataInicio != null ||
           dataFim != null ||
           (customFilters?.isNotEmpty ?? false);

  int get activeFiltersCount {
    int count = 0;
    if (search?.isNotEmpty ?? false) count++;
    if (status != null) count++;
    if (bairro != null) count++;
    if (genero != null) count++;
    if (dataInicio != null) count++;
    if (dataFim != null) count++;
    if (customFilters?.isNotEmpty ?? false) count += customFilters!.length;
    return count;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (search?.isNotEmpty ?? false) params['search'] = search;
    if (status != null) params['status'] = status;
    if (bairro != null) params['bairro'] = bairro;
    if (genero != null) params['genero'] = genero;
    if (dataInicio != null) params['data_inicio'] = dataInicio!.toIso8601String().split('T')[0];
    if (dataFim != null) params['data_fim'] = dataFim!.toIso8601String().split('T')[0];
    
    if (customFilters != null) {
      params.addAll(customFilters!);
    }
    
    return params;
  }

  void clear() {
    // Esta função seria chamada através de copyWith
  }
}
