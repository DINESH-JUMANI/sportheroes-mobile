import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/statistics/models/statistics_model.dart';

class LeaderboardResult<T> {
  const LeaderboardResult({required this.items, required this.meta});

  final List<T> items;
  final PaginationMeta meta;
}

class StatisticsService {
  StatisticsService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<LeaderboardResult<PlayerStatistics>> playerLeaderboard({
    required String sportId,
    int page = 1,
    int limit = 20,
    String sortBy = 'ranking_points',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.playerLeaderboard,
        queryParameters: {
          'sportId': sportId,
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return LeaderboardResult(
        items: ApiHelpers.extractList(response.data, key: 'leaderboard')
            .map(PlayerStatistics.fromJson)
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

  Future<List<PlayerStatistics>> playerStats(
    String userId, {
    String? sportId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.playerStats(userId),
        queryParameters: {'sportId': ?sportId},
      );
      return ApiHelpers.extractList(response.data, key: 'stats')
          .map(PlayerStatistics.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<LeaderboardResult<TeamStatistics>> teamLeaderboard({
    String? sportId,
    int page = 1,
    int limit = 20,
    String sortBy = 'win_percentage',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.teamLeaderboard,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'sportId': ?sportId,
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return LeaderboardResult(
        items: ApiHelpers.extractList(response.data, key: 'leaderboard')
            .map(TeamStatistics.fromJson)
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

  Future<TeamStatistics> teamStats(String teamId) async {
    try {
      final response = await _dio.get(ApiConstants.teamStats(teamId));
      return TeamStatistics.fromJson(
        ApiHelpers.extractObject(response.data, key: 'stats'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
