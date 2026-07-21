import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/models/pagination_meta.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/venues/models/venue_model.dart';

class VenuesListResult {
  const VenuesListResult({required this.venues, required this.meta});

  final List<VenueModel> venues;
  final PaginationMeta meta;
}

class VenuesService {
  VenuesService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResult<VenueModel>> create(CreateVenueRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.venues,
        data: request.toJson(),
      );
      return ApiResult(
        data: VenueModel.fromJson(
          ApiHelpers.extractObject(response.data, key: 'venue'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Venue created',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<VenuesListResult> list({
    int page = 1,
    int limit = 20,
    String? q,
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.venues,
        queryParameters: {
          'page': page,
          'limit': limit,
          'activeOnly': activeOnly.toString(),
          'q': ?q,
        },
      );
      final data = ApiHelpers.extractData(response.data);
      return VenuesListResult(
        venues: ApiHelpers.extractList(response.data, key: 'venues')
            .map(VenueModel.fromJson)
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

  Future<VenueModel> getById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.venueById(id));
      return VenueModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'venue'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<VenueModel> update(String id, UpdateVenueRequest request) async {
    try {
      final response = await _dio.patch(
        ApiConstants.venueById(id),
        data: request.toJson(),
      );
      return VenueModel.fromJson(
        ApiHelpers.extractObject(response.data, key: 'venue'),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete(ApiConstants.venueById(id));
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
