import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_details.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_report_model.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BranchComparisonReportService {
  final NetworkService _network = Get.find<NetworkService>();

  /// Fetch branch comparison report
  /// [fromDate] - format: 2026-08-01
  /// [toDate] - format: 2026-08-31
  /// [branchIds] - indexed branch IDs (branch_ids[0]=1&branch_ids[1]=2)
  Future<ApiResponse<BranchComparisonReportModel>> getBranchComparisonReport({
    required String fromDate,
    required String toDate,
    List<String>? branchIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'from_date': fromDate,
        'to_date': toDate,
      };

      if (branchIds != null) {
        addIndexedParams(queryParams, 'branch_ids', branchIds);
      }

      final response = await _network.get(
        endpoint: ApiPath.branchComparisonReport,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final model = BranchComparisonReportModel.fromJson(response.data!);
        return ApiResponse.completed(model);
      }

      return ApiResponse.error(
        response.message ?? 'branchComparison.errors.fetchFailed'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('branchComparison.errors.unexpected'.trns());
    }
  }

  /// Fetch branch comparison details
  /// [branchId] - single branch ID
  /// [fromDate] - format: 2026-08-01
  /// [toDate] - format: 2026-08-31
  /// [page] - pagination page number
  Future<ApiResponse<BranchComparisonDetailsModel>> getBranchComparisonDetails({
    required int branchId,
    required String fromDate,
    required String toDate,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'branch_id': branchId,
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
      };

      final response = await _network.get(
        endpoint: ApiPath.branchComparisonReportDetails,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final model = BranchComparisonDetailsModel.fromJson(response.data!);
        return ApiResponse.completed(model);
      }

      return ApiResponse.error(
        response.message ?? 'branchComparison.errors.fetchDetailsFailed'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('branchComparison.errors.unexpected'.trns());
    }
  }
}
