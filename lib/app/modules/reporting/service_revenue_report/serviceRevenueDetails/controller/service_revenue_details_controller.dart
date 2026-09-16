// lib/app/modules/service_revenue_report/controllers/service_revenue_details_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_service.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/models/service_revenue_model_detals.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ServiceRevenueDetailsController extends GetxController {
  final ServiceRevenueService _service = Get.find<ServiceRevenueService>();

  // ── Arguments ─────────────────────────────────────────────────────────
  late final int branchId;
  late final String fromDate;
  late final String toDate;
  late final dynamic serviceId;
  late final String branchName;

  // ── API Response ──────────────────────────────────────────────────────
  final Rx<ApiResponse<ServiceRevenueDetailResponse>> detailResponse =
      ApiResponse<ServiceRevenueDetailResponse>.loading().obs;

  ServiceRevenueDetailResponse? get detailData => detailResponse.value.data;
  BranchDetail? get branch => detailData?.branch;
  List<DailyServiceSummary> get summaries =>
      detailData?.dailyServiceSummaries.items ?? [];
  PaginationMeta? get paginationMeta => detailData?.dailyServiceSummaries.meta;

  // ── Pagination ────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;

  bool get hasNextPage => paginationMeta?.hasNextPage ?? false;
  bool get hasPrevPage => currentPage.value > 1;
  int get totalPages => paginationMeta?.lastPage ?? 1;

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    _fetchDetails();
  }

  @override
  void onReady() {
    super.onReady();
    ever(detailResponse, _handleResponseChange);
  }

  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    branchId = args['branchId'] as int? ?? 0;
    fromDate = args['fromDate'] as String? ?? '';
    toDate = args['toDate'] as String? ?? '';
    serviceId = args['serviceId'] ?? 'all';
    branchName = args['branchName'] as String? ?? '';
  }

  void _handleResponseChange(ApiResponse<ServiceRevenueDetailResponse> response) {
    if (response.isError) {
      SnackbarService.showError(
        title: 'reports.errors.title'.trns(),
        message: response.message ?? 'reports.errors.fetchFailed'.trns(),
      );
    }
  }

  // ── API Calls ─────────────────────────────────────────────────────────
  Future<void> _fetchDetails({int page = 1}) async {
    if (page == 1) {
      detailResponse.value = ApiResponse.loading();
    }

    final response = await _service.getServiceRevenueDetails(
      branchId: branchId,
      fromDate: fromDate,
      toDate: toDate,
      serviceId: serviceId,
      page: page,
    );

    detailResponse.value = response;
    if (response.isCompleted) {
      currentPage.value = page;
    }
  }

  Future<void> refreshDetails() async {
    currentPage.value = 1;
    await _fetchDetails(page: 1);
  }

  // ── Pagination ────────────────────────────────────────────────────────
  void nextPage() {
    if (hasNextPage) {
      _fetchDetails(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (hasPrevPage) {
      _fetchDetails(page: currentPage.value - 1);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String formatCurrency(String amount) {
    try {
      final value = double.tryParse(amount) ?? 0;
      if (value == 0) return '\$0';
      return '\$${value.toStringAsFixed(2)}';
    } catch (e) {
      return amount;
    }
  }

  String formatDate(String apiDate) {
    try {
      final parts = apiDate.split('-');
      if (parts.length != 3) return apiDate;
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = int.tryParse(parts[1]) ?? 1;
      return '${months[month]}/${parts[2]}/${parts[0]}';
    } catch (e) {
      return apiDate;
    }
  }
}