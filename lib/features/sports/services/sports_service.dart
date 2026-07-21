import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_model.dart';
import 'package:sportheroes_mobile/features/sports/models/sport_rules_model.dart';

class SportsListResult {
  const SportsListResult({required this.sports, required this.meta});

  final List<SportModel> sports;
  final PaginationMeta meta;
}

class SportsService {
  SportsService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<SportsListResult> listSports({
    int page = 1,
    int limit = 20,
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.sports,
        queryParameters: {
          'page': page,
          'limit': limit,
          'activeOnly': activeOnly.toString(),
        },
      );
      final data = ApiHelpers.extractData(response.data);
      final sports = ApiHelpers.extractList(response.data, key: 'sports')
          .map(SportModel.fromJson)
          .toList();
      return SportsListResult(
        sports: sports,
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

  Future<SportModel> getSportById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.sportById(id));
      return SportModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'sport'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<SportModel> getSportByCode(String code) async {
    try {
      final response = await _dio.get(ApiConstants.sportByCode(code));
      return SportModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'sport'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<SportRules> getSportRules(String code) async {
    try {
      final response = await _dio.get(ApiConstants.sportRulesByCode(code));
      return SportRules.fromJson(
        ApiHelpers.extractObject(response.data, key: 'rules'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<PlayerSportProfile> createPlayerProfile(
    CreatePlayerProfileRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.playerProfiles,
        data: request.toJson(),
      );
      return PlayerSportProfile.fromJson(
        ApiHelpers.extractObject(response.data, key: 'profile'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<PlayerSportProfile>> getMyProfiles() async {
    try {
      final response = await _dio.get(ApiConstants.playerProfilesMe);
      return ApiHelpers.extractList(response.data, key: 'profiles')
          .map(PlayerSportProfile.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<PlayerSportProfile>> getUserProfiles(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.playerProfilesByUser(userId),
      );
      return ApiHelpers.extractList(response.data, key: 'profiles')
          .map(PlayerSportProfile.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<PlayerSportProfile> updatePlayerProfile(
    String id,
    UpdatePlayerProfileRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        ApiConstants.playerProfileById(id),
        data: request.toJson(),
      );
      return PlayerSportProfile.fromJson(
        ApiHelpers.extractObject(response.data, key: 'profile'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<void> deletePlayerProfile(String id) async {
    try {
      await _dio.delete(ApiConstants.playerProfileById(id));
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
