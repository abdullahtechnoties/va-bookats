// lib/app/modules/packages/repositories/package_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/data_service_item.dart';
import 'package:va_bookats/models/package_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Result of the paginated packages fetch.
class PackagesPage {
  final List<PackageModel> packages;
  final PaginationMeta meta;
  final List<BranchModel> branches;

  const PackagesPage({
    required this.packages,
    required this.meta,
    required this.branches,
  });
}

/// Repository pattern wrapper around every package API call.
class PackageRepository {
  final NetworkService _network = Get.find<NetworkService>();

  // ─── Branches ──────────────────────────────────────────────────────────

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

  // ─── Services by branch (for add-package form) ─────────────────────────

  /// Fetches services for a specific branch via `GET /data/services?branch_id=N`.
  /// Returns a top-level JSON array of lightweight service items.
  Future<ApiResponse<List<DataServiceItem>>> getDataServices(int branchId) async {
    final response = await _network.getRaw(
      endpoint: ApiPath.dataServices(branchId),
    );

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

    final services = raw
        .whereType<Map>()
        .map((e) => DataServiceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ApiResponse.completed(services);
  }

  // ─── Paginated list ───────────────────────────────────────────────────

  Future<ApiResponse<PackagesPage>> getPackages({
    required int page,
    String? status,
    String? search,
    String? fromDate,
    String? toDate,
    int? branchId,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.packages,
      queryParams: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        'branch_id': ?branchId,
      },
    );

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawList = body['data'];
    final packages = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => PackageModel.fromJson(Map<String, dynamic>.from(e)))
              .where((p) => p.id != null)
              .toList()
        : <PackageModel>[];

    return ApiResponse.completed(
      PackagesPage(
        packages: packages,
        meta: PaginationMeta.fromJson(body),
        branches: _parseBranches(body['branches']),
      ),
    );
  }

  // ─── Single package (for edit) ────────────────────────────────────────

  Future<ApiResponse<PackageModel>> getPackage(int id) async {
    final response = await _network.get(endpoint: ApiPath.package(id));

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    return ApiResponse.completed(
      PackageModel.fromJson(Map<String, dynamic>.from(body)),
    );
  }

  // ─── Create ───────────────────────────────────────────────────────────

  Future<ApiResponse<PackageModel>> createPackage({
    int? branchId,
    required String name,
    required String startingFrom,
    required String endingOn,
    required String status,
    String? description,
    required String packagePrice,
    required List<Map<String, dynamic>> services,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.packages,
      fields: {
        'branch_id': ?branchId,
        'name': name,
        'starting_from': startingFrom,
        'ending_on': endingOn,
        'status': status,
        if (description != null && description.isNotEmpty)
        'description': description,
        'package_price': packagePrice,
        for (var i = 0; i < services.length; i++) ...{
          'services[$i][service_id]': services[i]['service_id'],
          if (services[i]['variation_id'] != null)
            'services[$i][variation_id]': services[i]['variation_id'],
        },
      },
    );
    return _mapSingle(response);
  }

  // ─── Update ───────────────────────────────────────────────────────────

  Future<ApiResponse<PackageModel>> updatePackage({
    required int id,
    int? branchId,
    required String name,
    required String startingFrom,
    required String endingOn,
    required String status,
    String? description,
    required String packagePrice,
    required List<Map<String, dynamic>> services,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.package(id),
      fields: {
        '_method': 'PUT',
        'branch_id': ?branchId,
        'name': name,
        'starting_from': startingFrom,
        'ending_on': endingOn,
        'status': status,
        if (description != null && description.isNotEmpty)
          'description': description,
        'package_price': packagePrice,
        for (var i = 0; i < services.length; i++) ...{
          'services[$i][service_id]': services[i]['service_id'],
          if (services[i]['variation_id'] != null)
            'services[$i][variation_id]': services[i]['variation_id'],
        },
      },
    );
    return _mapSingle(response);
  }

  // ─── Delete / Status ──────────────────────────────────────────────────

  Future<ApiResponse<void>> deletePackage(int id) async {
    final response = await _network.delete(endpoint: ApiPath.package(id));
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  Future<ApiResponse<void>> changePackageStatus({
    required int id,
    required String status,
  }) async {
    final response = await _network.put(
      endpoint: ApiPath.packageStatus(id),
      body: {'status': status},
    );
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────

  ApiResponse<PackageModel> _mapSingle(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawPkg = body['package'] ?? body;
    if (rawPkg is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    return ApiResponse.completed(
      PackageModel.fromJson(Map<String, dynamic>.from(rawPkg)),
      message: response.message,
    );
  }

  List<BranchModel> _parseBranches(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();
  }
}