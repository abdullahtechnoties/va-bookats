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

  String get label =>
      resolveReportColumnLabel('branchComparison.columns', labelKey);
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
  /// Nullable dates: null = "no date filter" — nothing is sent to the API
  /// until the user picks a date in the filter sheet and taps Apply.
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();

  /// Multi-select branch filter (empty = All branches). Sent indexed as
  /// `branch_ids[0]`, `branch_ids[1]`, … — the only indexed param across
  /// reporting. Ids are strings so int/String API payloads can never
  /// crash the sheet.
  final RxSet<String> selectedBranchIds = <String>{}.obs;

  // Available branches from API
  final RxList<BranchFilterOption> availableBranches =
      <BranchFilterOption>[].obs;

  // Temp filter (used in bottom sheet before applying)
  final Rxn<DateTime> tempFromDate = Rxn<DateTime>();
  final Rxn<DateTime> tempToDate = Rxn<DateTime>();
  final RxSet<String> tempBranchIds = <String>{}.obs;

  List<ReportOption> get branchOptions => availableBranches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchOptions,
    allLabel: 'branchComparison.filter.allBranches'.trns(),
    selectedSuffix: 'branchComparison.filter.branchesSelected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchOptions,
    allLabel: 'branchComparison.filter.allBranches'.trns(),
    selectedSuffix: 'branchComparison.filter.branchesSelected'.trns(),
  );

  /// Selected ids as ints for the indexed API params (null = All).
  List<int>? get filterBranchIds {
    if (selectedBranchIds.isEmpty) return null;
    final ids = selectedBranchIds.map(int.tryParse).whereType<int>().toList();
    return ids.isEmpty ? null : ids;
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
    final from = fromDate.value;
    final to = toDate.value;
    if (from == null && to == null) {
      return 'reports.common.allDates'.trns();
    }
    String fmt(DateTime? d) =>
        d == null ? 'reports.common.selectDate'.trns() : reportHumanDate(d);
    return '${fmt(from)} - ${fmt(to)}';
  }

  String _formatDate(DateTime d) => reportHumanDate(d);

  String? _apiDateFormat(DateTime? d) {
    if (d == null) return null;
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
      branchIds: isOwner ? filterBranchIds : null,
    );

    reportResponse.value = response;

    if (response.isCompleted && response.data != null) {
      // Update available branches
      availableBranches.assignAll(response.data!.branches);
      final responseBranchIds = response.data!.branchIds
          .map((id) => id.toString())
          .toSet();
      selectedBranchIds.assignAll(responseBranchIds);
      tempBranchIds.assignAll(responseBranchIds);
      syncDynamicColumns();
      tempFromDate.value = DateTime.parse(response.data!.fromDate);
      tempToDate.value = DateTime.parse(response.data!.toDate);
      fromDate.value = DateTime.parse(response.data!.fromDate);
      toDate.value = DateTime.parse(response.data!.toDate);
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
    initTempMulti(tempBranchIds, selectedBranchIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = null;
    tempToDate.value = null;
    tempBranchIds.clear();
  }

  void selectAllTempBranches() {
    tempBranchIds.assignAll(availableBranches.map((b) => b.value.toString()));
  }

  void clearTempBranches() {
    tempBranchIds.clear();
  }

  // ── Column Selection Actions ─────────────────────────────────────────────
  void initTempColumns() {
    initTempMulti(tempColumnKeys, selectedColumnKeys);
  }

  /// Discovers scalar fields present in the API rows and appends them as
  /// opt-in columns. Technical ids never become columns.
  void syncDynamicColumns() {
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(items.map((r) => r.rawFields), known);
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
        'fromDate': _apiDateFormat(fromDate.value) ?? item.from,
        'toDate': _apiDateFormat(toDate.value) ?? item.to,
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
      case 'service_discount':
        return '${item.currencySymbol} ${item.serviceDiscount.toString()}';
      case 'product_discount':
        return '${item.currencySymbol} ${item.productDiscount.toString()}';
      case 'package_discount':
        return '${item.currencySymbol} ${item.packageDiscount.toString()}';
      case 'service_amount':
        return '${item.currencySymbol} ${item.serviceAmount.toString()}';
      case 'product_amount':
        return '${item.currencySymbol} ${item.productAmount.toString()}';
      case 'package_amount':
        return '${item.currencySymbol} ${item.packageAmount.toString()}';
      default:
        // Dynamically discovered columns read straight from the raw row.
        return formatReportCell(key, item.rawFields[key]);
    }
  }
}
