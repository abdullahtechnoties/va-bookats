import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/controllers/branch_comparison_service.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_details.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

enum ClosingTab { approved, pending, rejected }

class BranchComparisonReportDetailsController extends GetxController {
  final BranchComparisonReportService _service = BranchComparisonReportService();

  // ── Arguments from caller ────────────────────────────────────────────────
  late final int branchId;
  late final String branchName;
  late final String fromDate;
  late final String toDate;

  // ── API Response State ───────────────────────────────────────────────────
  final Rx<ApiResponse<BranchComparisonDetailsModel>> detailsResponse =
      ApiResponse<BranchComparisonDetailsModel>.loading().obs;

  BranchComparisonDetailsModel? get detailsData => detailsResponse.value.data;
  BranchInfoModel? get branch => detailsData?.branch;
  List<DailyClosingModel> get dailyClosings => detailsData?.dailyClosings.items ?? [];
  PaginationMeta? get paginationMeta => detailsData?.dailyClosings.meta;

  // ── Tab State ────────────────────────────────────────────────────────────
  final Rx<ClosingTab> activeTab = ClosingTab.approved.obs;

  // ── Pagination ───────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;

  bool get hasNextPage => paginationMeta?.hasNextPage ?? false;
  bool get hasPrevPage => currentPage.value > 1;

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchDetails();
  }

  void _extractArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    branchId = args['branchId'] as int? ?? 0;
    branchName = args['branchName'] as String? ?? '';
    fromDate = args['fromDate'] as String? ?? '';
    toDate = args['toDate'] as String? ?? '';
  }

  // ── API Calls ────────────────────────────────────────────────────────────
  Future<void> fetchDetails({int page = 1}) async {
    detailsResponse.value = ApiResponse.loading();

    final response = await _service.getBranchComparisonDetails(
      branchId: branchId,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
    );

    detailsResponse.value = response;

    if (response.isCompleted) {
      currentPage.value = page;
    } else if (response.isError) {
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: response.message ?? 'branchComparison.errors.fetchDetailsFailed'.trns(),
      );
    }
  }

  Future<void> refreshDetails() async {
    await fetchDetails(page: currentPage.value);
  }

  // ── Tab Actions ──────────────────────────────────────────────────────────
  void setTab(ClosingTab tab) {
    activeTab.value = tab;
    currentPage.value = 1;
    fetchDetails(page: 1);
  }

  // ── Pagination Actions ───────────────────────────────────────────────────
  void nextPage() {
    if (hasNextPage) {
      fetchDetails(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (hasPrevPage) {
      fetchDetails(page: currentPage.value - 1);
    }
  }

  // ── Filtered Items by Tab ────────────────────────────────────────────────
  List<DailyClosingModel> get filteredClosings {
    switch (activeTab.value) {
      case ClosingTab.approved:
        return dailyClosings.where((c) => c.status.toLowerCase() == 'approved').toList();
      case ClosingTab.pending:
        return dailyClosings.where((c) => c.status.toLowerCase() == 'pending').toList();
      case ClosingTab.rejected:
        return dailyClosings.where((c) => c.status.toLowerCase() == 'rejected').toList();
    }
  }

  // ── Table Helper ─────────────────────────────────────────────────────────
  String getCellValue(DailyClosingModel item, String key) {
    switch (key) {
      case 'closing_date': return item.closingDate;
      case 'total_revenue': return '\$${item.totalRevenue}';
      case 'total_amount': return '\$${item.totalAmount}';
      case 'total_discount': return '\$${item.totalDiscount}';
      case 'total_balance': return '\$${item.totalBalance}';
      case 'service_revenue': return '\$${item.serviceRevenue}';
      case 'product_revenue': return '\$${item.productRevenue}';
      case 'package_revenue': return '\$${item.packageRevenue}';
      case 'status': return item.status;
      default: return '-';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month]}/${date.day}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}