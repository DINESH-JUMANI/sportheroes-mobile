import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/matches/models/match_model.dart';

class MatchesListResult {
  const MatchesListResult({required this.matches, required this.meta});

  final List<MatchModel> matches;
  final PaginationMeta meta;
}

class MatchesService {
  MatchesService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResult<MatchModel>> createMatch(CreateMatchRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.matches,
        data: request.toJson(),
      );
      return ApiResult(
        data: MatchModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'match'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Match created',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<MatchesListResult> listMatches({
    int page = 1,
    int limit = 20,
    String? sportId,
    String? sportCode,
    String? tournamentId,
    String? status,
    String? createdBy,
    String? participantPhone,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.matches,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sportId': ?sportId,
          'sportCode': ?sportCode,
          'tournamentId': ?tournamentId,
          'status': ?status,
          'createdBy': ?createdBy,
          'participantPhone': ?participantPhone,
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return MatchesListResult(
        matches: ApiHelpers.extractList(response.data, key: 'matches')
            .map(MatchModel.fromJson)
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

  Future<MatchModel> getMatch(String id) async {
    try {
      final response = await _dio.get(ApiConstants.matchById(id));
      return MatchModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'match'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<MatchTimelinePoint>> getTimeline(String id) async {
    try {
      final response = await _dio.get(ApiConstants.matchTimeline(id));
      return ApiHelpers.extractList(response.data, key: 'timeline')
          .map(MatchTimelinePoint.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<MatchModel>> start(String id) async {
    return _postAction(ApiConstants.matchStart(id), fallback: 'Match started');
  }

  Future<ApiResult<MatchModel>> pause(String id) async {
    return _postAction(ApiConstants.matchPause(id), fallback: 'Match paused');
  }

  Future<ApiResult<MatchModel>> resume(String id) async {
    return _postAction(ApiConstants.matchResume(id), fallback: 'Match resumed');
  }

  Future<ApiResult<MatchModel>> recordPoint(
    String id,
    String scoringSide,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.matchPoint(id),
        data: {'scoringSide': scoringSide},
      );
      return ApiResult(
        data: MatchModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'match'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Point recorded',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<MatchModel>> undoPoint(String id) async {
    return _postAction(
      ApiConstants.matchUndoPoint(id),
      fallback: 'Point undone',
    );
  }

  Future<ApiResult<MatchModel>> finishSet(
    String id, {
    String? winnerSide,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.matchFinishSet(id),
        data: {
          'winnerSide': ?winnerSide,
        },
      );
      return ApiResult(
        data: MatchModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'match'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Set finished',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<MatchModel>> complete(
    String id, {
    String? winnerSide,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.matchComplete(id),
        data: {
          'winnerSide': ?winnerSide,
        },
      );
      return ApiResult(
        data: MatchModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'match'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Match completed',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<MatchModel>> cancel(String id, {String? reason}) async {
    try {
      final response = await _dio.post(
        ApiConstants.matchCancel(id),
        data: {'reason': ?reason},
      );
      return ApiResult(
        data: MatchModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'match'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Match cancelled',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<MatchModel>> _postAction(
    String path, {
    required String fallback,
  }) async {
    try {
      final response = await _dio.post(path);
      return ApiResult(
        data: MatchModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'match'),
        ),
        message: ApiHelpers.extractMessage(response.data, fallback: fallback),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
