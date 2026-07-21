class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0);
    }
    return PaginationMeta(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 20,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 0,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
