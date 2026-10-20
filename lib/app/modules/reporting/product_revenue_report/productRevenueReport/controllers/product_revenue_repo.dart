import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/models/product_revenue_models.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ProductRevenueRepository {
  final NetworkService _network = Get.find<NetworkService>();

  Future<ApiResponse<ProductRevenueReport>> getProductRevenue({
    int? branchId,
    String? fromDate,
    String? toDate,
    String? productId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (branchId != null) {
        queryParams['branch_id'] = branchId;
      }
      if (fromDate != null) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null) {
        queryParams['to_date'] = toDate;
      }
      if (productId != null) {
        queryParams['product_id'] = productId;
      }

      final response = await _network.get(
        endpoint: ApiPath.productRevenue,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final report = ProductRevenueReport.fromJson(response.data!);
        return ApiResponse.completed(report);
      }

      return ApiResponse.error(
        response.message ?? 'reports.product.errors.fetchFailed'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('reports.product.errors.unexpected'.trns());
    }
  }

  /// Branch-scoped product lookups for the filter sheet
  /// (`/data/products?branch_id=N`). Returns a top-level JSON array —
  /// never hits the report endpoint.
  Future<ApiResponse<List<ProductLookup>>> getBranchProducts(
    int branchId,
  ) async {
    try {
      final response = await _network.getRaw(
        endpoint: ApiPath.lookupProducts(branchId),
      );
      if (!response.isCompleted || response.data == null) {
        return ApiResponse.error(
          response.message ?? 'reports.product.errors.fetchFailed'.trns(),
        );
      }
      final raw = response.data;
      if (raw is! List) {
        return ApiResponse.error('reports.product.errors.unexpected'.trns());
      }
      final items = raw
          .whereType<Map>()
          .map(
            (e) => ProductLookup.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      return ApiResponse.completed(items);
    } catch (e) {
      return ApiResponse.error('reports.product.errors.unexpected'.trns());
    }
  }

  Future<ApiResponse<ProductRevenueDetails>> getProductRevenueDetails({
    required int branchId,
    required String fromDate,
    required String toDate,
    required String productId,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'branch_id': branchId,
        'from_date': fromDate,
        'to_date': toDate,
        'product_id': productId,
        'page': page,
      };

      final response = await _network.get(
        endpoint: ApiPath.productRevenueDetails,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final details = ProductRevenueDetails.fromJson(response.data!);
        return ApiResponse.completed(details);
      }

      return ApiResponse.error(
        response.message ?? 'reports.product.errors.detailsFetchFailed'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('reports.product.errors.unexpected'.trns());
    }
  }
}
