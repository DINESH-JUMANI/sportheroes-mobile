import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/search/models/search_result.dart';

class SearchResultPage {
  const SearchResultPage({
    required this.results,
    required this.meta,
  });

  final List<SearchResult> results;
  final PaginationMeta meta;
}

class SearchService {
  SearchService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<SearchResultPage> search({
    required String query,
    List<String>? types,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.search,
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
          if (types != null && types.isNotEmpty) 'types': types.join(','),
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return SearchResultPage(
        results: ApiHelpers.extractList(response.data, key: 'results')
            .map(SearchResult.fromJson)
            .toList(),
        meta: PaginationMeta.fromJson(
          data['meta'] is Map
              ? Map<String, dynamic>.from(data['meta'] as Map)
              : null,
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
