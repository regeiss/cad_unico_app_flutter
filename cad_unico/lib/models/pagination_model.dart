class PaginationResult<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginationResult({
    required this.results,
    required this.count,
    this.next,
    this.previous,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    int currentPage,
    int pageSize,
  ) {
    final results = (json['results'] as List<dynamic>?)
        ?.map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList() ?? <T>[];
    
    final count = json['count'] as int? ?? 0;
    final totalPages = (count / pageSize).ceil();
    
    return PaginationResult<T>(
      results: results,
      count: count,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      currentPage: currentPage,
      totalPages: totalPages,
      hasNext: json['next'] != null,
      hasPrevious: json['previous'] != null,
    );
  }

  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
  int get length => results.length;
}