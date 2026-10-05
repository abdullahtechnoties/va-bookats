import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/controllers/branch_comparison_service.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_report_model.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

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

  String get label => resolveReportColumnLabel(
        'branchComparison.columns',
        labelKey,
      );
}

class BranchComparisonReportController extends GetxController {
  final BranchComparisonReportService _service =
      BranchComparisonReportService();
  final AuthService _auth = Get.find<AuthService>();

  // ── API Response State ───────────────────────────────────────────────────
  final Rx<ApiResponse<BranchComparisonReportModel>> reportResponse =
      ApiResponse<BranchComparisonReportModel>.loading().obs;

  BranchComparisonReportModel? get reportData => reportResponse.value.data;
  List<BranchComparisonItemModel> get items => reportData?.monthlyData ?? [];

  // ── Filter State ─────────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Single-select branch filter (null = All branches). Sent indexed as
  /// `branch_ids[0]` — the only indexed param across reporting.
  final RxnInt selectedBranchId = RxnInt(null);

  // Available branches from API
  final RxList<BranchFilterOption> availableBranches =
      <BranchFilterOption>[].obs;

  // Temp filter (used in bottom sheet before applying)
  final Rx<DateTime> tempFromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxnInt tempBranchId = RxnInt(null);

  String get branchFilterDisplay {
    final id = selectedBranchId.value;
    if (id == null) {
      return 'branchComparison.filter.allBranches'.trns();
    }
    return availableBranches.firstWhereOrNull((b) => b.value == id)?.label ??
        'branchComparison.filter.allBranches'.trns();
  }

  String get tempBranchFilterDisplay {
    final id = tempBranchId.value;
    if (id == null) {
      return 'branchComparison.filter.allBranches'.trns();
    }
    return availableBranches.firstWhereOrNull((b) => b.value == id)?.label ??
        'branchComparison.filter.allBranches'.trns();
  }

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

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branch_name',
    'from',
    'to',
    'total_revenue',
    'total_amount',
    'total_discount',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.label))
      .toList();

  List<ReportColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

  // ── Computed ─────────────────────────────────────────────────────────────
  bool get isOwner => _auth.isOwner;

  String get dateRangeLabel {
    return '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';
  }

  String _formatDate(DateTime d) => reportHumanDate(d);

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

    final response = await _service.getBranchComparisonReport(
      fromDate: _apiDateFormat(fromDate.value),
      toDate: _apiDateFormat(toDate.value),
      branchId: selectedBranchId.value,
    );

    reportResponse.value = response;

    if (response.isCompleted && response.data != null) {
      // Update available branches
      availableBranches.assignAll(response.data!.branches);
      syncDynamicColumns();
    } else if (response.isError) {
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message:
            response.message ?? 'branchComparison.errors.fetchFailed'.trns(),
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
    tempBranchId.value = selectedBranchId.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchId.value = null;
  }

  void selectTempBranch(int? branchId) {
    tempBranchId.value = branchId;
  }

  // ── Column Selection Actions ─────────────────────────────────────────────
  void initTempColumns() {
    initTempMulti(tempColumnKeys, selectedColumnKeys);
  }

  /// Discovers scalar fields present in the API rows and appends them as
  /// opt-in columns. Technical ids never become columns.
  void syncDynamicColumns() {
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(
      items.map((r) => r.rawFields),
      known,
    );
    if (fresh.isEmpty) return;
    for (final key in fresh) {
      allColumns.add(
        ReportColumn(
          key: key,
          labelKey: key,
          width: reportColumnWidth(
            resolveReportColumnLabel('branchComparison.columns', key),
          ),
          isSelected: false,
        ),
      );
    }
    allColumns.refresh();
  }

  void applyColumnSelection() {
    selectedColumnKeys.assignAll(tempColumnKeys);
    for (final c in allColumns) {
      c.isSelected = selectedColumnKeys.contains(c.key);
    }
    allColumns.refresh();
  }

  void resetColumnSelection() {
    tempColumnKeys.assignAll(const {
      'branch_name',
      'from',
      'to',
      'total_revenue',
      'total_amount',
      'total_discount',
    });
  }

  void selectAllColumns() {
    tempColumnKeys.assignAll(allColumns.map((c) => c.key));
  }

  void toggleTempColumn(int index) {
    if (index < 0 || index >= allColumns.length) return;
    final key = allColumns[index].key;
    if (tempColumnKeys.contains(key)) {
      tempColumnKeys.remove(key);
    } else {
      tempColumnKeys.add(key);
    }
  }

  void openColumnSelector(BuildContext context) {
    initTempColumns();
    ReportColumnSelectorSheet.show(
      context: context,
      title: 'branchComparison.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
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
      case 'branch_name':
        return item.branchName;
      case 'from':
        return _formatDate(DateTime.parse(item.from));
      case 'to':
        return _formatDate(DateTime.parse(item.to));
      case 'total_revenue':
        return '${item.currencySymbol} ${item.totalRevenue}';
      case 'total_amount':
        return '${item.currencySymbol} ${item.totalAmount}';
      case 'total_discount':
        return '${item.currencySymbol} ${item.totalDiscount}';
      case 'total_balance':
        return '${item.currencySymbol} ${item.totalBalance}';
      case 'cash_payment':
        return '${item.currencySymbol} ${item.cashPayment}';
      case 'card_payment':
        return '${item.currencySymbol} ${item.cardPayment}';
      case 'online_payment':
        return '${item.currencySymbol} ${item.onlinePayment}';
      case 'service_revenue':
        return '${item.currencySymbol} ${item.serviceRevenue}';
      case 'product_revenue':
        return '${item.currencySymbol} ${item.productRevenue}';
      case 'package_revenue':
        return '${item.currencySymbol} ${item.packageRevenue}';
      case 'unpaid_amount':
        return '${item.currencySymbol} ${item.unpaidAmount}';
      default:
        // Dynamically discovered columns read straight from the raw row.
        return formatReportCell(key, item.rawFields[key]);
    }
  }
}
