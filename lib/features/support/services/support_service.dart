import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sportheroes_mobile/core/constants/api_constants.dart';
import 'package:sportheroes_mobile/core/models/api_result.dart';
import 'package:sportheroes_mobile/core/network/api_helpers.dart';
import 'package:sportheroes_mobile/core/network/dio_client.dart';
import 'package:sportheroes_mobile/features/support/models/support_models.dart';

class SupportService {
  SupportService(this._dioClient);

  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  Future<ApiResult<List<SupportConcern>>> listConcerns({
    bool activeOnly = true,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.supportConcerns,
        queryParameters: {'activeOnly': activeOnly},
      );
      final concerns = ApiHelpers.extractList(response.data, key: 'concerns')
          .map(SupportConcern.fromJson)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return ApiResult(
        data: concerns,
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Concerns fetched',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  /// Uploads a support image; returns public Storage URL.
  Future<String> uploadImage(File file) async {
    try {
      final filename = file.path.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: filename),
      });
      final response = await _dio.post(
        ApiConstants.supportUploadImage,
        data: formData,
      );
      final data = ApiHelpers.extractData(response.data);
      final url = data['url']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('Upload succeeded but no image URL was returned');
      }
      return url;
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<SupportTicket>> createTicket(
    CreateSupportTicketRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.supportTickets,
        data: request.toJson(),
      );
      return ApiResult(
        data: SupportTicket.fromJson(
          ApiHelpers.extractObject(response.data, key: 'ticket'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Support ticket created',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<List<SupportTicket>>> listMyTickets({
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.supportTickets,
        queryParameters: {
          'mineOnly': true,
          'status': ?status,
        },
      );
      final tickets = ApiHelpers.extractList(response.data, key: 'tickets')
          .map(SupportTicket.fromJson)
          .toList();
      return ApiResult(
        data: tickets,
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Tickets fetched',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }

  Future<ApiResult<SupportTicket>> getTicket(String id) async {
    try {
      final response = await _dio.get(ApiConstants.supportTicketById(id));
      return ApiResult(
        data: SupportTicket.fromJson(
          ApiHelpers.extractObject(response.data, key: 'ticket'),
        ),
        message: ApiHelpers.extractMessage(
          response.data,
          fallback: 'Ticket fetched',
        ),
      );
    } on DioException catch (e) {
      throw Exception(ApiHelpers.extractError(e));
    }
  }
}
