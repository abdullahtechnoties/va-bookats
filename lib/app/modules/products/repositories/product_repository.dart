// lib/app/modules/products/repositories/product_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Repository pattern wrapper around every product API call.
class ProductRepository {
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

  // ─── Paginated list ───────────────────────────────────────────────────

  Future<ApiResponse<ProductsPage>> getProducts({
    required int page,
    String? status,
    String? search,
    String? fromDate,
    String? toDate,
    String? quickRange,
    int? branchId,
  }) async {
    final response = await _network.get(
      endpoint: ApiPath.products,
      queryParams: {
        'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        if (quickRange != null && quickRange.isNotEmpty)
          'quick_range': quickRange,
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
    final products = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
              .where((p) => p.id != null)
              .toList()
        : <ProductModel>[];

    return ApiResponse.completed(
      ProductsPage(
        products: products,
        meta: PaginationMeta.fromJson(body),
        branches: _parseBranches(body['branches']),
      ),
    );
  }

  // ─── Single product (details page) ────────────────────────────────────

  Future<ApiResponse<ProductModel>> getProduct(int id) async {
    final response = await _network.get(endpoint: ApiPath.product(id));

    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }

    final body = response.data!;
    final rawProduct = body['product'] ?? body;
    if (rawProduct is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }

    return ApiResponse.completed(
      ProductModel.fromJson(Map<String, dynamic>.from(rawProduct)),
      message: response.message,
    );
  }

  // ─── Delete / Status ──────────────────────────────────────────────────

  Future<ApiResponse<void>> deleteProduct(int id) async {
    final response = await _network.delete(endpoint: ApiPath.product(id));
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  Future<ApiResponse<void>> changeProductStatus({
    required int id,
    required String status,
  }) async {
    final response = await _network.put(
      endpoint: ApiPath.productStatus(id),
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

  List<BranchModel> _parseBranches(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();
  }
}
