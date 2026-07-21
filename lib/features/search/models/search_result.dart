class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.meta = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      type: json['type']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle'] as String?,
      meta: json['meta'] is Map
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : const {},
    );
  }

  final String type;
  final String id;
  final String title;
  final String? subtitle;
  final Map<String, dynamic> meta;
}

enum SearchResultType { user, team, tournament, match, venue, other }

extension SearchResultX on SearchResult {
  SearchResultType get resultType => switch (type) {
        'user' => SearchResultType.user,
        'team' => SearchResultType.team,
        'tournament' => SearchResultType.tournament,
        'match' => SearchResultType.match,
        'venue' => SearchResultType.venue,
        _ => SearchResultType.other,
      };
}
