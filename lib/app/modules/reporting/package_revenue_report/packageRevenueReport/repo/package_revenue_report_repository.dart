import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_details_model.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_report_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageRevenueReportRepository {
  final NetworkService _network = Get.find<NetworkService>();

  Future<ApiResponse<PackageRevenueReportModel>> getPackageRevenueReport({
    required String fromDate,
    required String toDate,
    List<String>? branchIds,
    List<String>? packageIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
      };

      if (branchIds != null) {
        addIndexedParams(queryParams, 'branch_ids', branchIds);
      }

      if (packageIds != null) {
        addIndexedParams(queryParams, 'package_ids', packageIds);
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
