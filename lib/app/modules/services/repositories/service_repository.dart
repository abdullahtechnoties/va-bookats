// lib/app/modules/services/repositories/service_repository.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/models/service_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// A single variation entered in the create/update form.
class VariationDraft {
  final String name;
  final String price;

  const VariationDraft({required this.name, required this.price});
}

/// Result of the paginated services fetch.
class ServicesPage {
  final List<ServiceModel> services;
  final PaginationMeta meta;
  final List<BranchModel> branches;
  final List<ServiceCategoryModel> categories;

  const ServicesPage({
    required this.services,
    required this.meta,
    required this.branches,
    required this.categories,
  });
}

/// Repository pattern wrapper around every service API call.
class ServiceRepository {
  final NetworkService _network = Get.find<NetworkService>();

  /// GET /data/branches — returns a top-level JSON array.
  Future<ApiResponse<List<BranchModel>>> getBranches() async {
    final response = await _network.getRaw(endpoint: ApiPath.branches);

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final raw = response.data;
    if (raw is! List) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    final branches = raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();

    return ApiResponse.completed(branches);
  }

  /// GET /service-categories — fetches every page so all categories are
  /// available for the dropdowns. Duplicate rows (same id across pages or
  /// repeated by the backend) are collapsed to a single entry.
  Future<ApiResponse<List<ServiceCategoryModel>>> getCategories() async {
    final categories = <ServiceCategoryModel>[];
    final seenIds = <int>{};
    int page = 1;

    while (true) {
      final response = await _network.get(
        endpoint: ApiPath.serviceCategories,
        queryParams: {'page': page},
      );

      if (!response.isCompleted || response.data == null) {
        return ApiResponse.error(
          response.message ?? 'errors.requestFailed'.trns(),
          errors: response.errors,
        );
      }

      final body = response.data!;
      final rawPage = body['serviceCategories'];
      if (rawPage is! Map) {
        return ApiResponse.error('errors.unexpectedShort'.trns());
      }

      final pageMap = Map<String, dynamic>.from(rawPage);
      final rawList = pageMap['data'];
      if (rawList is List) {
        for (final entry in rawList.whereType<Map>()) {
          final category = ServiceCategoryModel.fromJson(
            Map<String, dynamic>.from(entry),
          );
          final id = category.id;
          if (id == null || !seenIds.add(id)) continue;
          categories.add(category);
        }
      }

      final meta = PaginationMeta.fromJson(pageMap);
      if (!meta.hasNextPage) break;
      page = meta.currentPage + 1;
    }

    return ApiResponse.completed(categories);
  }

  /// GET /services — paginated list + available branches & categories.
  Future<ApiResponse<ServicesPage>> getServices({
    required int page,
    String? status,
    String? search,
    String? fromDate,
    String? toDate,
    String? quickRange,
    int? branchId,
    String? type,
    int? categoryId,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.services,
      queryParams: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        if (quickRange != null && quickRange.isNotEmpty)
          'quick_range': quickRange,
        if (branchId != null) 'branch_id': branchId,
        if (type != null && type.isNotEmpty) 'type': type,
        if (categoryId != null) 'category_id': categoryId,
      },
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawPage = body['services'];
    if (rawPage is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    final pageMap = Map<String, dynamic>.from(rawPage);
    final rawList = pageMap['data'];
    final services = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
              .where((s) => s.id != null)
              .toList()
        : <ServiceModel>[];

    return ApiResponse.completed(
      ServicesPage(
        services: services,
        meta: PaginationMeta.fromJson(pageMap),
        branches: _parseBranches(body['branches']),
        categories: _parseCategories(body['serviceCategories']),
      ),
    );
  }

  /// POST /services — create a service (owner only, multipart/form-data).
  Future<ApiResponse<ServiceModel>> createService({
    int? branchId,
    required int? categoryId,
    required String name,
    String? serviceDuration,
    String? status,
    required String type,
    String? defaultPrice,
    String? description,
    List<VariationDraft> variations = const [],
    File? imageFile,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.services,
      fields: _buildFields(
        branchId: branchId,
        categoryId: categoryId,
        name: name,
        serviceDuration: serviceDuration,
        status: status,
        type: type,
        defaultPrice: defaultPrice,
        description: description,
        variations: variations,
      ),
      files: imageFile == null ? null : {'image': imageFile},
    );
    return _mapSingleService(response);
  }

  /// POST /services/{id} with a spoofed `_method: PUT` — update a service.
  Future<ApiResponse<ServiceModel>> updateService({
    required int id,
    int? branchId,
    required int? categoryId,
    required String name,
    String? serviceDuration,
    String? status,
    required String type,
    String? defaultPrice,
    String? description,
    List<VariationDraft> variations = const [],
    File? imageFile,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.service(id),
      fields: {
        '_method': 'PUT',
        ..._buildFields(
          branchId: branchId,
          categoryId: categoryId,
          name: name,
          serviceDuration: serviceDuration,
          status: status,
          type: type,
          defaultPrice: defaultPrice,
          description: description,
          variations: variations,
        ),
      },
      files: imageFile == null ? null : {'image': imageFile},
    );
    return _mapSingleService(response);
  }

  /// DELETE /services/{id}
  Future<ApiResponse<void>> deleteService(int id) async {
    final response = await _network.delete(endpoint: ApiPath.service(id));
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  /// PUT /services/{id}/status
  Future<ApiResponse<ServiceModel>> changeServiceStatus({
    required int id,
    required String status,
  }) async {
    final response = await _network.put(
      endpoint: ApiPath.serviceStatus(id),
      body: {'status': status},
    );
    return _mapSingleService(response);
  }

  /// Builds the multipart payload Laravel expects.
  ///
  /// - `default_price` is only ever sent for `normal` services.
  /// - Variations are only sent for `variation` services, using the indexed
  ///   `variations[i][name]` / `variations[i][price]` keys Laravel parses.
  Map<String, dynamic> _buildFields({
    int? branchId,
    required int? categoryId,
    required String name,
    String? serviceDuration,
    String? status,
    required String type,
    String? defaultPrice,
    String? description,
    required List<VariationDraft> variations,
  }) {
    return {
      'branch_id': branchId,
      'category_id': categoryId,
      'name': name,
      if (serviceDuration != null && serviceDuration.isNotEmpty)
        'service_duration': serviceDuration,
      if (status != null && status.isNotEmpty) 'status': status,
      'type': type,
      if (type == 'normal' && defaultPrice != null && defaultPrice.isNotEmpty)
        'default_price': defaultPrice,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (type == 'variation')
        for (var i = 0; i < variations.length; i++) ...{
          'variations[$i][name]': variations[i].name,
          'variations[$i][price]': variations[i].price,
        },
    };
  }

  List<BranchModel> _parseBranches(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();
  }

  List<ServiceCategoryModel> _parseCategories(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ServiceCategoryModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .where((c) => c.id != null)
          .toList();
    }
    if (raw is Map) {
      final inner = raw['data'];
      if (inner is List) {
        return inner
            .whereType<Map>()
            .map(
              (e) =>
                  ServiceCategoryModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .where((c) => c.id != null)
            .toList();
      }
    }
    return const [];
  }

  ApiResponse<ServiceModel> _mapSingleService(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawService = body['service'] ?? body;
    if (rawService is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    return ApiResponse.completed(
      ServiceModel.fromJson(Map<String, dynamic>.from(rawService)),
      message: response.message,
    );
  }
}
