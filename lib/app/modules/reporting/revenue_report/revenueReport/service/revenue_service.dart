import 'package:get/get.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';

class ReportService extends GetxService {
  final NetworkService _network = Get.find<NetworkService>();

  /// Fetch revenue report
  Future<ApiResponse<Map<String, dynamic>>> getRevenueReport({
    int? branchId,
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (branchId != null) params['branch_id'] = branchId;
    if (fromDate != null && fromDate.isNotEmpty) params['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) params['to_date'] = toDate;

    return await _network.get(
      endpoint: ApiPath.revenueReport,
      queryParams: params,
    );
  }

  /// Fetch revenue details with multi-pagination
  Future<ApiResponse<Map<String, dynamic>>> getRevenueDetails({
    required int branchId,
    required String fromDate,
    required String toDate,
    int paymentsPage = 1,
    int unpaidPage = 1,
    int returnPage = 1,
  }) async {
    final params = {
      'branch_id': branchId,
      'from_date': fromDate,
      'to_date': toDate,
      'payments_page': paymentsPage,
      'unpaid_page': unpaidPage,
      'return_page': returnPage,
    };

    return await _network.get(
      endpoint: ApiPath.revenueDetails,
      queryParams: params,
    );
  }
}