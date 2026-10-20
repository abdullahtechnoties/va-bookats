import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_details_model.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_report_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageRevenueReportRepository {
  final NetworkService _network = Get.find<NetworkService>();

  Future<ApiResponse<PackageRevenueReportModel>> getPackageRevenueReport({
    String? fromDate,
    String? toDate,
    int? branchId,
    dynamic packageId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['to_date'] = toDate;
      }

      if (branchId != null && branchId > 0) {
        queryParams['branch_id'] = branchId;
      }

      if (packageId != null) {
        queryParams['package_id'] = packageId;
      }

      final response = await _network.get(
        endpoint: ApiPath.packageRevenueReport,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final model = PackageRevenueReportModel.fromJson(response.data!);
        return ApiResponse.completed(model);
      }

      return ApiResponse.error(
        response.message ?? 'errors.failedToFetch'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }

  /// Branch-scoped package lookups for the filter sheet
  /// (`/data/packages?branch_id=N`). Returns a top-level JSON array —
  /// never hits the report endpoint.
  Future<ApiResponse<List<PackageFilterOption>>> getBranchPackages(
    int branchId,
  ) async {
    try {
      final response = await _network.getRaw(
        endpoint: ApiPath.lookupPackages(branchId),
      );
      if (!response.isCompleted || response.data == null) {
        return ApiResponse.error(
          response.message ?? 'errors.failedToFetch'.trns(),
        );
      }
      final raw = response.data;
      if (raw is! List) {
        return ApiResponse.error('errors.unexpected'.trns());
      }
      final items = raw
          .whereType<Map>()
          .map(
            (e) => PackageFilterOption.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      return ApiResponse.completed(items);
    } catch (e) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }

  Future<ApiResponse<PackageRevenueDetailsModel>> getPackageRevenueDetails({
    required int branchId,
    required String fromDate,
    required String toDate,
    required dynamic packageId,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'branch_id': branchId,
        'from_date': fromDate,
        'to_date': toDate,
        'package_id': packageId,
        'page': page,
      };

      final response = await _network.get(
        endpoint: ApiPath.packageRevenueDetails,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final model = PackageRevenueDetailsModel.fromJson(response.data!);
        return ApiResponse.completed(model);
      }

      return ApiResponse.error(
        response.message ?? 'errors.failedToFetch'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('errors.unexpected'.trns());
    }
  }
}
