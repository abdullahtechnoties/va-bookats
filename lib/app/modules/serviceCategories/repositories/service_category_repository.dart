// lib/app/modules/serviceCategories/repositories/service_category_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Result of the paginated service-categories fetch.
class ServiceCategoriesPage {
  final List<ServiceCategoryModel> categories;
  final PaginationMeta meta;
  final List<BranchModel> branches;

  const ServiceCategoriesPage({
    required this.categories,
    required this.meta,
    required this.branches,
  });
}

/// Repository pattern wrapper around every service-category API call.
class ServiceCategoryRepository {
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

  /// GET /service-categories?page=N — paginated list + available branches.
  Future<ApiResponse<ServiceCategoriesPage>> getServiceCategories({
    required int page,
  }) async {
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
    final categories = rawList is List
        ? rawList
              .whereType<Map>()
              .map(
                (e) => ServiceCategoryModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : <ServiceCategoryModel>[];

    final branches = (body['branches'] is List)
        ? (body['branches'] as List)
            .whereType<Map>()
            .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
            .where((b) => b.isValid)
            .toList()
        : <BranchModel>[];

    return ApiResponse.completed(
      ServiceCategoriesPage(
        categories: categories,
        meta: PaginationMeta.fromJson(pageMap),
        branches: branches,
      ),
    );
  }

  /// POST /service-categories
  Future<ApiResponse<ServiceCategoryModel>> createServiceCategory({
    required String name,
    int? branchId,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.serviceCategories,
      body: {'name': name, 'branch_id': branchId},
    );
    return _mapSingleCategory(response);
  }

  /// PATCH /service-categories/{id}
  Future<ApiResponse<ServiceCategoryModel>> updateServiceCategory({
    required int id,
    required String name,
    int? branchId,
  }) async {
    final response = await _network.patch(
      endpoint: ApiPath.serviceCategory(id),
      body: {'name': name, 'branch_id': branchId},
    );
    return _mapSingleCategory(response);
  }

  /// DELETE /service-categories/{id}
  Future<ApiResponse<void>> deleteServiceCategory(int id) async {
    final response = await _network.delete(endpoint: ApiPath.serviceCategory(id));
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  /// PUT /service-categories/{id}/status
  Future<ApiResponse<ServiceCategoryModel>> changeServiceCategoryStatus({
    required int id,
    required String status,
  }) async {
    final response = await _network.put(
      endpoint: ApiPath.serviceCategoryStatus(id),
      body: {'status': status},
    );
    return _mapSingleCategory(response);
  }

  ApiResponse<ServiceCategoryModel> _mapSingleCategory(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawCategory = body['serviceCategory'] ?? body;
    if (rawCategory is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    return ApiResponse.completed(
      ServiceCategoryModel.fromJson(Map<String, dynamic>.from(rawCategory)),
      message: response.message,
    );
  }
}