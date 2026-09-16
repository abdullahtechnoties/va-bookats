import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/controllers/branch_comparison_service.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_report_model.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ReportColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  ReportColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });

  String get label => labelKey.trns();
}

class BranchComparisonReportController extends GetxController {
  final BranchComparisonReportService _service = BranchComparisonReportService();
  final AuthService _auth = Get.find<AuthService>();

  // ── API Response State ───────────────────────────────────────────────────
  final Rx<ApiResponse<BranchComparisonReportModel>> reportResponse =
      ApiResponse<BranchComparisonReportModel>.loading().obs;

  BranchComparisonReportModel? get reportData => reportResponse.value.data;
  List<BranchComparisonItemModel> get items => reportData?.monthlyData ?? [];

  // ── Filter State ─────────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxList<int> selectedBranchIds = <int>[].obs;

  // Available branches from API
  final RxList<BranchFilterOption> availableBranches = <BranchFilterOption>[].obs;

  // Temp filter (used in bottom sheet before applying)
  final Rx<DateTime> tempFromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxList<int> tempSelectedBranchIds = <int>[].obs;

  // ── Column Selection State ───────────────────────────────────────────────
  final RxList<ReportColumn> allColumns = <ReportColumn>[
    ReportColumn(
      key: 'branch_name',
      labelKey: 'branchComparison.columns.branchName',
      width: 140,
      isSelected: true,
    ),
    ReportColumn(
      key: 'from',
      labelKey: 'branchComparison.columns.from',
      width: 110,
      isSelected: true,
    ),
    ReportColumn(
      key: 'to',
      labelKey: 'branchComparison.columns.to',
      width: 110,
      isSelected: true,
    ),
    ReportColumn(
      key: 'total_revenue',
      labelKey: 'branchComparison.columns.totalRevenue',
      width: 130,
      isSelected: true,
    ),
    ReportColumn(
      key: 'total_amount',
      labelKey: 'branchComparison.columns.totalAmount',
      width: 130,
      isSelected: true,
    ),
    ReportColumn(
      key: 'total_discount',
      labelKey: 'branchComparison.columns.totalDiscount',
      width: 130,
      isSelected: true,
    ),
    ReportColumn(
      key: 'total_balance',
      labelKey: 'branchComparison.columns.totalBalance',
      width: 140,
      isSelected: false,
    ),
    ReportColumn(
      key: 'cash_payment',
      labelKey: 'branchComparison.columns.cashPayment',
      width: 130,
      isSelected: false,
    ),
    ReportColumn(
      key: 'card_payment',
      labelKey: 'branchComparison.columns.cardPayment',
      width: 130,
      isSelected: false,
    ),
    ReportColumn(
      key: 'online_payment',
      labelKey: 'branchComparison.columns.onlinePayment',
      width: 140,
      isSelected: false,
    ),
    ReportColumn(
      key: 'service_revenue',
      labelKey: 'branchComparison.columns.serviceRevenue',
      width: 140,
      isSelected: false,
    ),
    ReportColumn(
      key: 'product_revenue',
      labelKey: 'branchComparison.columns.productRevenue',
      width: 140,
      isSelected: false,
    ),
    ReportColumn(
      key: 'package_revenue',
      labelKey: 'branchComparison.columns.packageRevenue',
      width: 140,
      isSelected: false,
    ),
    ReportColumn(
      key: 'unpaid_amount',
      labelKey: 'branchComparison.columns.unpaidAmount',
      width: 130,
      isSelected: false,
    ),
  ].obs;

  late RxList<bool> tempColumnSelected;

  List<ReportColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

  // ── Computed ─────────────────────────────────────────────────────────────
  bool get isOwner => _auth.isOwner;

  String get dateRangeLabel {
    return '${_formatDate(fromDate.value)} - ${_formatDate(toDate.value)}';
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]}/${d.day}/${d.year}';
  }

  String _apiDateFormat(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  // ── API Calls ────────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    reportResponse.value = ApiResponse.loading();

    final branchIdsParam = selectedBranchIds.isEmpty
        ? null
        : selectedBranchIds.join(',');

    final response = await _service.getBranchComparisonReport(
      fromDate: _apiDateFormat(fromDate.value),
      toDate: _apiDateFormat(toDate.value),
      branchIds: branchIdsParam,
    );

    reportResponse.value = response;

    if (response.isCompleted && response.data != null) {
      // Update available branches
      availableBranches.assignAll(response.data!.branches);
    } else if (response.isError) {
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: response.message ?? 'branchComparison.errors.fetchFailed'.trns(),
      );
    }
  }

  Future<void> refreshReport() async {
    await fetchReport();
  }

  // ── Filter Actions ───────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempSelectedBranchIds.assignAll(selectedBranchIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempSelectedBranchIds);
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempSelectedBranchIds.clear();
  }

  void toggleTempBranch(int branchId) {
    if (tempSelectedBranchIds.contains(branchId)) {
      tempSelectedBranchIds.remove(branchId);
    } else {
      tempSelectedBranchIds.add(branchId);
    }
  }

  // ── Column Selection Actions ─────────────────────────────────────────────
  void initTempColumns() {
    tempColumnSelected = allColumns.map((c) => c.isSelected).toList().obs;
  }

  void applyColumnSelection() {
    for (int i = 0; i < allColumns.length; i++) {
      allColumns[i].isSelected = tempColumnSelected[i];
    }
    allColumns.refresh();
  }

  void resetColumnSelection() {
    for (int i = 0; i < tempColumnSelected.length; i++) {
      tempColumnSelected[i] = i < 6; // First 6 columns selected by default
    }
    tempColumnSelected.refresh();
  }

  void selectAllColumns() {
    for (int i = 0; i < tempColumnSelected.length; i++) {
      tempColumnSelected[i] = true;
    }
    tempColumnSelected.refresh();
  }

  void toggleTempColumn(int index) {
    tempColumnSelected[index] = !tempColumnSelected[index];
    tempColumnSelected.refresh();
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void navigateToDetails(BranchComparisonItemModel item) {
    Get.toNamed(
      Routes.BRANCH_COMPARISON_REPORT_DETAILS,
      arguments: {
        'branchId': item.branchId,
        'branchName': item.branchName,
        'fromDate': _apiDateFormat(fromDate.value),
        'toDate': _apiDateFormat(toDate.value),
      },
    );
  }

  // ── Table Helper ─────────────────────────────────────────────────────────
  String getCellValue(BranchComparisonItemModel item, String key) {
    switch (key) {
      case 'branch_name': return item.branchName;
      case 'from': return _formatDate(DateTime.parse(item.from));
      case 'to': return _formatDate(DateTime.parse(item.to));
      case 'total_revenue': return '\$${item.totalRevenue}';
      case 'total_amount': return '\$${item.totalAmount}';
      case 'total_discount': return '\$${item.totalDiscount}';
      case 'total_balance': return '\$${item.totalBalance}';
      case 'cash_payment': return '\$${item.cashPayment}';
      case 'card_payment': return '\$${item.cardPayment}';
      case 'online_payment': return '\$${item.onlinePayment}';
      case 'service_revenue': return '\$${item.serviceRevenue}';
      case 'product_revenue': return '\$${item.productRevenue}';
      case 'package_revenue': return '\$${item.packageRevenue}';
      case 'unpaid_amount': return '\$${item.unpaidAmount}';
      default: return '-';
    }
  }
}