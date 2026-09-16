// lib/app/modules/mediaLibrary/repositories/media_repository.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:va_bookats/models/media_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class MediaPage {
  final List<MediaModel> items;
  final PaginationMeta meta;

  const MediaPage({required this.items, required this.meta});
}

class MediaRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /media — paginated. `search` is forwarded when non-empty.
  Future<ApiResponse<MediaPage>> getMedia({
    required int page,
    String? search,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.media,
      queryParams: {
        'page': page,
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    // Backend returns a Laravel paginator at the top level.
    final rawList = body['data'];
    final items = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => MediaModel.fromJson(Map<String, dynamic>.from(e)))
            .where((m) => m.id != 0)
            .toList()
        : <MediaModel>[];

    return ApiResponse.completed(
      MediaPage(items: items, meta: PaginationMeta.fromJson(body)),
      message: response.message,
    );
  }

  /// POST /media — upload one or many files as `files[0]`, `files[1]` …
  Future<ApiResponse<List<MediaModel>>> uploadMedia(List<File> files) async {
    if (files.isEmpty) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    final fileMap = <String, File>{
      for (var i = 0; i < files.length; i++) 'files[$i]': files[i],
    };
    final response = await _network.postForm(
      endpoint: ApiPath.media,
      files: fileMap,
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final raw = response.data!['media'];
    if (raw is! List) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    final items = raw
        .whereType<Map>()
        .map((e) => MediaModel.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.id != 0)
        .toList();
    return ApiResponse.completed(items, message: response.message);
  }

  /// DELETE /media — body `ids[0]`, `ids[1]` … (multipart).
  Future<ApiResponse<void>> deleteMedia(List<int> ids) async {
    if (ids.isEmpty) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    final fields = <String, dynamic>{
      for (var i = 0; i < ids.length; i++) 'ids[$i]': ids[i].toString(),
    };
    // Try multipart first (matches Postman `ids[0]` form fields).
    var response =
        await _network.deleteForm(endpoint: ApiPath.media, fields: fields);
    if (!response.isCompleted) {
      // Fallback to JSON `{ids: [...]}` for backends that parse JSON deletes.
      response = await _network.delete(
        endpoint: ApiPath.media,
        body: {'ids': ids},
      );
    }
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }
}
