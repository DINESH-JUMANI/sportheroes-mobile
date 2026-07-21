import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/tournaments/models/tournament_model.dart';

class TournamentsListResult {
  const TournamentsListResult({
    required this.tournaments,
    required this.meta,
  });

  final List<TournamentModel> tournaments;
  final PaginationMeta meta;
}

class TournamentsService {
  TournamentsService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResult<TournamentModel>> create(
    CreateTournamentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.tournaments,
        data: request.toJson(),
      );
      return ApiResult(
        data: TournamentModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'tournament'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Tournament created',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TournamentsListResult> list({
    int page = 1,
    int limit = 20,
    String? sportId,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.tournaments,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sportId': ?sportId,
          'status': ?status,
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return TournamentsListResult(
        tournaments: ApiHelpers.extractList(response.data, key: 'tournaments')
            .map(TournamentModel.fromJson)
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

  Future<TournamentModel> getById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.tournamentById(id));
      return TournamentModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'tournament'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TournamentModel> updateStatus(String id, String status) async {
    try {
      final response = await _dio.patch(
        ApiConstants.tournamentStatus(id),
        data: {'status': status},
      );
      return TournamentModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'tournament'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TournamentParticipant> register({
    required String tournamentId,
    String? phoneNumber,
    String? fullName,
    String? teamId,
    int? seedNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.tournamentParticipants(tournamentId),
        data: {
          'phoneNumber': ?phoneNumber,
          'fullName': ?fullName,
          'teamId': ?teamId,
          'seedNumber': ?seedNumber,
        },
      );
      return TournamentParticipant.fromJson(
        ApiHelpers.extractObject(response.data, key: 'participant'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<TournamentParticipant>> listParticipants(String id) async {
    try {
      final response = await _dio.get(ApiConstants.tournamentParticipants(id));
      return ApiHelpers.extractList(response.data, key: 'participants')
          .map(TournamentParticipant.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<TournamentRound>> listRounds(String id) async {
    try {
      final response = await _dio.get(ApiConstants.tournamentRounds(id));
      return ApiHelpers.extractList(response.data, key: 'rounds')
          .map(TournamentRound.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<TournamentStanding>> getStandings(String id) async {
    try {
      final response = await _dio.get(ApiConstants.tournamentStandings(id));
      return ApiHelpers.extractList(response.data, key: 'standings')
          .map(TournamentStanding.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
