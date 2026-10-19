// lib/repositories/inventory_repository.dart
//
// One CRUD repository for all inventory lookup resources (brands,
// product categories, tags, units, product variations). Every resource
// shares the same Laravel shapes:
//   GET  {base}?page&status&search&from_date&to_date&quick_range&branch_id
//     → `{current_page, data: [...], last_page, …}`
//   POST {base}            (multipart fields; images travel as media_id)
//   POST {base}/{id} + `_method: PUT`
//   DELETE {base}/{id}
//   PUT  {base}/{id}/status `{status}` → `{message, status}`

import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/inventory_item.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class InventoryPage {
  final List<InventoryItem> items;
  final PaginationMeta meta;
  final List<BranchModel> branches;

  const InventoryPage({
    required this.items,
    required this.meta,
    this.branches = const [],
  });
}

class InventoryRepository {
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
    return ApiResponse.completed(
      raw
          .whereType<Map>()
          .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
          .where((b) => b.isValid)
          .toList(),
    );
  }

  // ─── Paginated list ──────────────────────────────────────────────────

  Future<ApiResponse<InventoryPage>> fetchPage({
    required String base,
    required int page,
    String? status,
    String? search,
    String? fromDate,
    String? toDate,
    String? quickRange,
    int? branchId,
  }) async {
    final response = await _network.get(
      endpoint: base,
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
    return ApiResponse.completed(
      InventoryPage(
        items: rawList is List
            ? rawList
                  .whereType<Map>()
                  .map(
                    (e) => InventoryItem.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .where((item) => item.id != null)
                  .toList()
            : const [],
        meta: PaginationMeta.fromJson(body),
        branches: _parseBranches(body['branches']),
      ),
      message: response.message,
    );
  }

  // ─── Full `{label, value}` lookup options (un-paginated `/data/*`) ─────

  Future<ApiResponse<List<ProductLookup>>> fetchLookupOptions(
    String endpoint,
  ) async {
    final response = await _network.getRaw(endpoint: endpoint);
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
    return ApiResponse.completed(
      raw
          .whereType<Map>()
          .map((e) => ProductLookup.fromJson(Map<String, dynamic>.from(e)))
          .where((o) => o.label.isNotEmpty && o.value != 0)
          .toList(),
    );
  }

  // ─── Create / Update (indexed multipart fields) ───────────────────────

  Future<ApiResponse<InventoryItem?>> create({
    required String base,
    required Map<String, dynamic> fields,
    String? resultKey,
  }) async {
    final response = await _network.postForm(
      endpoint: base,
      fields: fields,
    );
    return _mapItem(response, resultKey);
  }

  Future<ApiResponse<InventoryItem?>> update({
    required String base,
    required int id,
    required Map<String, dynamic> fields,
  }) async {
    final response = await _network.postForm(
      endpoint: '$base/$id',
      fields: {'_method': 'PUT', ...fields},
    );
    return _mapItem(response, null);
  }

  ApiResponse<InventoryItem?> _mapItem(
    ApiResponse<Map<String, dynamic>> response,
    String? resultKey,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    dynamic raw;
    if (resultKey != null && body[resultKey] is Map) {
      raw = body[resultKey];
    } else {
      raw = body;
    }
    if (raw is! Map) {
      return ApiResponse.completed(null, message: response.message);
    }
    return ApiResponse.completed(
      InventoryItem.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }

  // ─── Delete / Status ─────────────────────────────────────────────────

  Future<ApiResponse<void>> delete({
    required String base,
    required int id,
  }) async {
    final response = await _network.delete(endpoint: '$base/$id');
    if (!response.isCompleted) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    return ApiResponse.completed(null, message: response.message);
  }

  /// Returns the new status string (`{message, status}`).
  Future<ApiResponse<String>> changeStatus({
    required String base,
    required int id,
    required String status,
  }) async {
    final response = await _network.put(
      endpoint: '$base/$id/status',
      body: {'status': status},
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final next = body['status']?.toString() ?? status;
    return ApiResponse.completed(next, message: response.message);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  List<BranchModel> _parseBranches(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.isValid)
        .toList();
  }
}
