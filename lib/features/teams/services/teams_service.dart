import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/teams/models/team_model.dart';

class TeamsListResult {
  const TeamsListResult({required this.teams, required this.meta});

  final List<TeamModel> teams;
  final PaginationMeta meta;
}

class TeamsService {
  TeamsService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResult<TeamModel>> createTeam(CreateTeamRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.teams,
        data: request.toJson(),
      );
      return ApiResult(
        data: TeamModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'team'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Team created',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TeamsListResult> listTeams({
    int page = 1,
    int limit = 20,
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.teams,
        queryParameters: {
          'page': page,
          'limit': limit,
          'activeOnly': activeOnly.toString(),
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return TeamsListResult(
        teams: ApiHelpers.extractList(response.data, key: 'teams')
            .map(TeamModel.fromJson)
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

  Future<TeamModel> getTeam(String id) async {
    try {
      final response = await _dio.get(ApiConstants.teamById(id));
      return TeamModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'team'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TeamModel> updateTeam(String id, UpdateTeamRequest request) async {
    try {
      final response = await _dio.patch(
        ApiConstants.teamById(id),
        data: request.toJson(),
      );
      return TeamModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'team'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<void> deleteTeam(String id) async {
    try {
      await _dio.delete(ApiConstants.teamById(id));
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<List<TeamMember>> listMembers(String teamId) async {
    try {
      final response = await _dio.get(ApiConstants.teamMembers(teamId));
      return ApiHelpers.extractList(response.data, key: 'members')
          .map(TeamMember.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<LookupUserResult> lookupUserByPhone(String phoneNumber) async {
    try {
      final response = await _dio.get(
        ApiConstants.teamLookupUser,
        queryParameters: {'phoneNumber': phoneNumber},
      );
      return LookupUserResult.fromJson(ApiHelpers.extractData(response.data));
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TeamMember> addMember(
    String teamId,
    AddTeamMemberRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.teamMembers(teamId),
        data: request.toJson(),
      );
      return TeamMember.fromJson(
        ApiHelpers.extractObject(response.data, key: 'member'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TeamMember> updateMember(
    String teamId,
    String memberId,
    UpdateTeamMemberRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        ApiConstants.teamMemberById(teamId, memberId),
        data: request.toJson(),
      );
      return TeamMember.fromJson(
        ApiHelpers.extractObject(response.data, key: 'member'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<void> removeMember(String teamId, String memberId) async {
    try {
      await _dio.delete(ApiConstants.teamMemberById(teamId, memberId));
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<TeamModel> uploadLogo(
    String teamId,
    UploadTeamLogoRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.teamLogo(teamId),
        data: request.toJson(),
      );
      return TeamModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'team'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<Uint8List?> fetchLogoBytes(String teamId) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConstants.teamLogo(teamId),
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return Uint8List.fromList(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
