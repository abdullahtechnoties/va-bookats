// lib/app/modules/addProduct/repositories/add_product_repository.dart

import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Repository for the add/edit product form: branch-scoped lookups,
/// runtime creation of dropdown items, variation values probe and
/// product create/update with indexed params.
class AddProductRepository {
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

  // ─── Generic `{label, value}` lookups ──────────────────────────────────

  Future<ApiResponse<List<ProductLookup>>> _getLookups(String endpoint) async {
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

  Future<ApiResponse<List<ProductLookup>>> getBrands(int branchId) =>
      _getLookups(ApiPath.dataBrands(branchId));

  Future<ApiResponse<List<ProductLookup>>> getCategories(int branchId) =>
      _getLookups(ApiPath.dataProductCategories(branchId));

  Future<ApiResponse<List<ProductLookup>>> getTags(int branchId) =>
      _getLookups(ApiPath.dataTags(branchId));

  Future<ApiResponse<List<ProductLookup>>> getUnits(int branchId) =>
      _getLookups(ApiPath.dataUnits(branchId));

  Future<ApiResponse<List<ProductLookup>>> getVariationTypes(int branchId) =>
      _getLookups(ApiPath.dataProductVariations(branchId));

  /// Values for one variation type from the data lookup endpoint.
  Future<List<VariationValue>> getVariationValues(int typeId) async {
    final response = await _network.getRaw(
      endpoint: ApiPath.dataProductVariationValues(typeId),
    );
    if (!response.isCompleted || response.data is! List) {
      return const [];
    }
    return (response.data as List)
        .whereType<Map>()
        .map(
          (entry) => VariationValue.fromJson(Map<String, dynamic>.from(entry)),
        )
        .where((value) => value.id != null && value.name?.isNotEmpty == true)
        .toList();
  }

  // ─── Runtime creation ──────────────────────────────────────────────────

  Future<ApiResponse<ProductLookup>> createBrand({
    required int branchId,
    required String name,
    int? mediaId,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.brands,
      body: {'branch_id': branchId, 'name': name, 'media_id': ?mediaId},
    );
    return _mapLookup(response, 'brand');
  }

  Future<ApiResponse<ProductLookup>> createCategory({
    required int branchId,
    required String name,
    int? parentId,
    int? mediaId,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.productCategories,
      body: {
        'branch_id': branchId,
        'name': name,
        'parent_id': ?parentId,
        'media_id': ?mediaId,
      },
    );
    return _mapLookup(response, 'productCategory');
  }

  Future<ApiResponse<ProductLookup>> createTag({
    required int branchId,
    required String name,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.tags,
      body: {'branch_id': branchId, 'name': name},
    );
    return _mapLookup(response, 'tag');
  }

  Future<ApiResponse<ProductLookup>> createUnit({
    required int branchId,
    required String name,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.units,
      body: {'branch_id': branchId, 'name': name},
    );
    return _mapLookup(response, 'unit');
  }

  Future<ApiResponse<VariationTypeWithValues>> createVariationType({
    required int branchId,
    required String name,
    required List<String> valueNames,
  }) async {
    final response = await _network.post(
      endpoint: ApiPath.productVariations,
      body: {
        'branch_id': branchId,
        'name': name,
        for (var i = 0; i < valueNames.length; i++)
          'value_list[$i]': valueNames[i],
      },
    );
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['productVariation'] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    return ApiResponse.completed(
      VariationTypeWithValues.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }

  ApiResponse<ProductLookup> _mapLookup(
    ApiResponse<Map<String, dynamic>> response,
    String key,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body[key] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    final map = Map<String, dynamic>.from(raw);
    return ApiResponse.completed(
      ProductLookup(
        label: map['name']?.toString() ?? '',
        value: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      ),
      message: response.message,
    );
  }

  // ─── Product create / update (indexed params via multipart fields) ────

  Future<ApiResponse<ProductModel>> createProduct(
    Map<String, dynamic> fields,
  ) async {
    final response = await _network.postForm(
      endpoint: ApiPath.products,
      fields: fields,
    );
    return _mapProduct(response);
  }

  Future<ApiResponse<ProductModel>> updateProduct({
    required int id,
    required Map<String, dynamic> fields,
  }) async {
    final response = await _network.postForm(
      endpoint: ApiPath.product(id),
      fields: {'_method': 'PUT', ...fields},
    );
    return _mapProduct(response);
  }

  ApiResponse<ProductModel> _mapProduct(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    if (!response.isCompleted || response.data == null) {
      return ApiResponse.error(
        response.message ?? 'errors.requestFailed'.trns(),
        errors: response.errors,
      );
    }
    final body = response.data!;
    final raw = body['product'] ?? body;
    if (raw is! Map) {
      return ApiResponse.error('errors.unexpectedShort'.trns());
    }
    return ApiResponse.completed(
      ProductModel.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message,
    );
  }
}
