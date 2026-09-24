// lib/app/modules/service_revenue_report/services/service_revenue_service.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/models/service_revenue_model_detals.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import '../models/service_revenue_models.dart';

class ServiceRevenueService extends GetxService {
  final NetworkService _network = Get.find<NetworkService>();

  Future<ApiResponse<ServiceRevenueResponse>> getServiceRevenueReport({
    String? fromDate,
    String? toDate,
    List<String>? branchIds,
    List<String>? serviceIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null) {
        queryParams['to_date'] = toDate;
      }
      if (branchIds != null) {
        addIndexedParams(queryParams, 'branch_ids', branchIds);
      }
      if (serviceIds != null) {
        addIndexedParams(queryParams, 'service_ids', serviceIds);
      }

      final response = await _network.get(
        endpoint: ApiPath.serviceRevenueReport,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final reportData = ServiceRevenueResponse.fromJson(response.data!);
        return ApiResponse.completed(reportData);
      }

      return ApiResponse.error(
        response.message ?? 'reports.errors.fetchFailed'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('reports.errors.unexpected'.trns());
    }
  }

  Future<ApiResponse<ServiceRevenueDetailResponse>> getServiceRevenueDetails({
    required int branchId,
    required String fromDate,
    required String toDate,
    dynamic serviceId,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'branch_id': branchId,
        'from_date': fromDate,
        'to_date': toDate,
        'page': page,
      };
      if (serviceId != null) queryParams['service_id'] = serviceId;

      final response = await _network.get(
        endpoint: ApiPath.serviceRevenueReportDetails,
        queryParams: queryParams,
      );

      if (response.isCompleted && response.data != null) {
        final detailData = ServiceRevenueDetailResponse.fromJson(
          response.data!,
        );
        return ApiResponse.completed(detailData);
      }

      return ApiResponse.error(
        response.message ?? 'reports.errors.fetchFailed'.trns(),
      );
    } catch (e) {
      return ApiResponse.error('reports.errors.unexpected'.trns());
    }
  }
}
