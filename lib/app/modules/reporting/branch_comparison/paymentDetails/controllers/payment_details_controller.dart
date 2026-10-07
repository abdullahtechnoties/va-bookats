import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/controllers/branch_comparison_service.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_details.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BranchComparisonReportDetailsController extends GetxController {
  final BranchComparisonReportService _service =
      BranchComparisonReportService();

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
  List<DailyClosingModel> get dailyClosings =>
      detailsData?.dailyClosings.items ?? [];
  PaginationMeta? get paginationMeta => detailsData?.dailyClosings.meta;

  // ── Pagination ───────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;

  bool get hasNextPage => paginationMeta?.hasNextPage ?? false;
  bool get hasPrevPage => currentPage.value > 1;
  bool get showPagination => hasNextPage || hasPrevPage;

  /// `Sep 2, 2026 - Oct 2, 2026` — human readable range passed from the
  /// previous page, used in the top details card.
  String get dateRangeLabel {
    final from = _humanDate(fromDate);
    final to = _humanDate(toDate);
    if (from.isEmpty && to.isEmpty) return '';
    return '$from - $to';
  }

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
        message:
            response.message ??
            'branchComparison.errors.fetchDetailsFailed'.trns(),
      );
    }
  }

  Future<void> refreshDetails() async {
    await fetchDetails(page: currentPage.value);
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

  // ── Table Helper ─────────────────────────────────────────────────────────
  /// Columns: date, creator, approver, status, total amount, total
  /// discount, total paid (= total revenue), total balance.
  String getCellValue(DailyClosingModel item, String key) {
    switch (key) {
      case 'date':
        return _humanDate(item.closingDate);
      case 'creator':
        return item.creator?.name ?? '-';
      case 'approver':
        return item.approver?.name ?? '-';
      case 'status':
        return item.status;
      case 'total_amount':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.totalAmount)}';
      case 'total_discount':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.totalDiscount)}';
      case 'total_paid':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.totalRevenue)}';
      case 'total_balance':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatReportCell(key, item.totalBalance)}';
      default:
        return '-';
    }
  }

  String _humanDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return reportHumanDate(parsed);
  }
}
