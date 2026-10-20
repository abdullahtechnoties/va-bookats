// lib/app/modules/reports/revenue/controllers/revenue_report_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/revenue_report/revenueReport/service/revenue_service.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_option.dart';
import 'package:va_bookats/models/revenue_data_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

class RevenueColumn {
  final String key;
  final String label;
  final double width;
  bool isSelected;

  RevenueColumn({
    required this.key,
    required this.label,
    this.width = 130,
    this.isSelected = true,
  });
}

class RevenueReportController extends GetxController {
  final ReportService _reportService = Get.find<ReportService>();
  final AuthService _authService = Get.find<AuthService>();

  // ── Screen state ─────────────────────────────────────────────────────────
  final String screenTitle = 'reports.revenue.title';
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // ── Filter state ─────────────────────────────────────────────────────────
  /// Nullable dates: null = "no date filter" — nothing is sent to the API
  /// until the user picks a date in the filter sheet and taps Apply.
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();
  final RxInt selectedBranchId = 0.obs; // 0 = All branches
  final RxString selectedBranchLabel = 'All Branches'.obs;

  // Temp filter (inside sheet before apply)
  final Rxn<DateTime> tempFromDate = Rxn<DateTime>();
  final Rxn<DateTime> tempToDate = Rxn<DateTime>();
  final RxInt tempBranchId = 0.obs;
  final RxString tempBranchLabel = 'All Branches'.obs;

  /// Initial-state snapshot taken from the first report response (the API
  /// echoes the effective filter). The sheet's Reset restores exactly this —
  /// never nulls — then the sheet closes gracefully.
  DateTime? _initialFromDate;
  DateTime? _initialToDate;
  int? _initialBranchId;
  String? _initialBranchLabel;
  bool get hasInitialState => _initialBranchLabel != null;

  // Branch options from API
  final RxList<BranchOption> branchOptions = <BranchOption>[].obs;
  List<String> get branchLabels => branchOptions.map((b) => b.label).toList();

  // ── Column selector ──────────────────────────────────────────────────────
  final RxList<RevenueColumn> allColumns = <RevenueColumn>[
    RevenueColumn(
      key: 'branch_name',
      label: 'reports.revenue.columns.branch',
      width: 140,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'from',
      label: 'reports.revenue.columns.from',
      width: 110,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'to',
      label: 'reports.revenue.columns.to',
      width: 110,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'total_amount',
      label: 'reports.revenue.columns.totalAmount',
      width: 130,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'total_discount',
      label: 'reports.revenue.columns.totalDiscount',
      width: 145,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'total_revenue',
      label: 'reports.revenue.columns.totalRevenue',
      width: 130,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'total_balance',
      label: 'reports.revenue.columns.totalBalance',
      width: 140,
      isSelected: true,
    ),
    RevenueColumn(
      key: 'cash_payment',
      label: 'reports.revenue.columns.cashPayment',
      width: 130,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'card_payment',
      label: 'reports.revenue.columns.cardPayment',
      width: 130,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'online_payment',
      label: 'reports.revenue.columns.onlinePayment',
      width: 145,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'service_revenue',
      label: 'reports.revenue.columns.serviceRevenue',
      width: 145,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'product_revenue',
      label: 'reports.revenue.columns.productRevenue',
      width: 145,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'package_revenue',
      label: 'reports.revenue.columns.packageRevenue',
      width: 145,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'total_count',
      label: 'reports.revenue.columns.totalCount',
      width: 110,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'paid_count',
      label: 'reports.revenue.columns.paidCount',
      width: 110,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'unpaid_count',
      label: 'reports.revenue.columns.unpaidCount',
      width: 120,
      isSelected: false,
    ),
    RevenueColumn(
      key: 'return_count',
      label: 'reports.revenue.columns.returnCount',
      width: 120,
      isSelected: false,
    ),
  ].obs;

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branch_name',
    'from',
    'to',
    'total_amount',
    'total_discount',
    'total_revenue',
    'total_balance',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.label.trns()))
      .toList();

  // ── Data ─────────────────────────────────────────────────────────────────
  final RxList<RevenueData> revenueDataList = <RevenueData>[].obs;

  // ── Pagination ───────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;

  // ── Computed ─────────────────────────────────────────────────────────────
  List<RevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

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

  List<RevenueData> get pagedData {
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, revenueDataList.length);
    return revenueDataList.sublist(start, end);
  }

  int get totalPages => revenueDataList.isEmpty
      ? 1
      : (revenueDataList.length / itemsPerPage).ceil();

  bool get isOwner => _authService.isOwner;

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // No preset dates: the first load sends no from/to params so the
    // backend decides the default range. Dates are only sent after the
    // user picks them in the filter sheet and taps Apply.
    fetchRevenueReport();
  }

  // ── API Calls ────────────────────────────────────────────────────────────
  Future<void> fetchRevenueReport({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final int? branchIdParam = isOwner && selectedBranchId.value > 0
          ? selectedBranchId.value
          : (!isOwner ? (_authService.currentUser.value?.branchId ?? 0) : null);

      final response = await _reportService.getRevenueReport(
        branchId: branchIdParam,
        fromDate: _formatDateApi(fromDate.value),
        toDate: _formatDateApi(toDate.value),
      );

      if (response.isCompleted && response.data != null) {
        _parseRevenueResponse(response.data!);
        syncDynamicColumns();
        // select branch and date range from API response (first row) if available
        if (revenueDataList.isNotEmpty) {
          tempFromDate.value = fromDate.value;
          tempToDate.value = toDate.value;
          fromDate.value =
              DateTime.tryParse(response.data!['from_date']) ?? fromDate.value;
          toDate.value =
              DateTime.tryParse(response.data!['to_date']) ?? toDate.value;
          selectedBranchId.value = int.tryParse(response.data!['branch_id'].toString()) ?? 0;
          selectedBranchLabel.value = branchOptions
              .firstWhere(
                (b) => b.value == selectedBranchId.value,
                // orElse: () => BranchOption(id: 0, label: 'reports.revenue.filter.allBranches'.trns()),
              )
              .label;
          if (!hasInitialState) {
            _initialFromDate = fromDate.value;
            _initialToDate = toDate.value;
            _initialBranchId = selectedBranchId.value;
            _initialBranchLabel = selectedBranchLabel.value;
          }
        } else {
          // No data returned, reset branch and date range
          tempFromDate.value = null;
          tempToDate.value = null;
          fromDate.value = null;
          toDate.value = null;
          selectedBranchId.value = 0;
          selectedBranchLabel.value = 'reports.revenue.filter.allBranches'.trns();
        }
      } else {
        // SnackbarService.showError(
        //   title: 'errors.errorTitle'.trns(),
        //   message: response.message ?? 'errors.unexpected'.trns(),
        // );
      }
    } catch (e) {
      print('Error fetching revenue report: $e');
      // SnackbarService.showError(
      //   title: 'errors.errorTitle'.trns(),
      //   message: 'errors.unexpected'.trns(),
      // );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void _parseRevenueResponse(Map<String, dynamic> data) {
    // Parse branches
    if (data['branches'] != null && data['branches'] is List) {
      final List<BranchOption> branches = [

      ];
      for (var b in data['branches']) {
        branches.add(BranchOption.fromJson(b));
      }
      branchOptions.value = branches;
     
    }

    // Parse monthlyData
    if (data['monthlyData'] != null && data['monthlyData'] is List) {
      revenueDataList.value = (data['monthlyData'] as List)
          .map((e) => RevenueData.fromJson(e))
          .toList();
    } else {
      revenueDataList.clear();
    }

    currentPage.value = 1;
  }

  // ── Filter Actions ───────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempBranchId.value = selectedBranchId.value;
    tempBranchLabel.value = selectedBranchLabel.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedBranchLabel.value = tempBranchLabel.value;

    fetchRevenueReport();
  }

  void resetFilter() {
    // Restore the exact initial state from the first report response.
    // Falls back to the applied values when the snapshot isn't ready yet.
    tempFromDate.value = _initialFromDate ?? fromDate.value;
    tempToDate.value = _initialToDate ?? toDate.value;
    tempBranchId.value = _initialBranchId ?? selectedBranchId.value;
    tempBranchLabel.value = _initialBranchLabel ?? selectedBranchLabel.value;
  }

  /// Applies the temp filter, closes the sheet gracefully, then refetches.
  void applyFilterAndClose() {
    applyFilter();
    Get.back();
  }

  /// Resets temp fields to the initial API state, applies them to the
  /// report, closes the sheet gracefully, then refetches.
  void resetFilterAndClose() {
    resetFilter();
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedBranchLabel.value = tempBranchLabel.value;
    Get.back();
    fetchRevenueReport();
  }

  void selectBranch(int id, String label) {
    tempBranchId.value = id;
    tempBranchLabel.value = label;
  }

  // ── Column Actions ───────────────────────────────────────────────────────
  void initTempColumns() {
    initTempMulti(tempColumnKeys, selectedColumnKeys);
  }

  // ── Dynamic columns ────────────────────────────────────────────────────
  /// Discovers scalar fields present in the API rows (e.g. cash_count,
  /// service_discount, total_services_sold) and appends them as opt-in
  /// columns. Technical ids never become columns.
  void syncDynamicColumns() {
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(
      revenueDataList.map((r) => r.rawFields),
      known,
    );
    if (fresh.isEmpty) return;
    for (final key in fresh) {
      final label = resolveReportColumnLabel(
        'reports.revenue.columns',
        key,
      );
      allColumns.add(
        RevenueColumn(
          key: key,
          label: label,
          width: reportColumnWidth(label),
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
      'total_amount',
      'total_discount',
      'total_revenue',
      'total_balance',
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
      title: 'reports.revenue.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
  }

  // ── Pagination ───────────────────────────────────────────────────────────
  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void navigateToDetails(RevenueData data) {
    Get.toNamed(
      Routes.PAYMENT_DETAILS,
      arguments: {
        'branchId': data.branchId,
        'fromDate': data.from,
        'toDate': data.to,
      },
    );
  }

  // ── Table helpers ────────────────────────────────────────────────────────
  String getCellValue(RevenueData row, String key) {
    switch (key) {
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDate(DateTime.tryParse(row.from) ?? DateTime.now());
      case 'to':
        return _formatDate(DateTime.tryParse(row.to) ?? DateTime.now());
      case 'total_amount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.totalAmount)}';
      case 'total_discount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.totalDiscount)}';
      case 'total_revenue':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.totalRevenue)}';
      case 'total_balance':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.totalBalance)}';
      case 'cash_payment':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.cashPayment)}';
      case 'card_payment':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.cardPayment)}';
      case 'online_payment':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.onlinePayment)}';
      case 'service_revenue':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.serviceRevenue)}';
      case 'product_revenue':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.productRevenue)}';
      case 'package_revenue':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.packageRevenue)}';
      case 'total_count':
        return row.totalCount.toString();
      case 'paid_count':
        return row.paidCount.toString();
      case 'unpaid_count':
        return row.unpaidCount.toString();
      case 'return_count':
        return row.returnCount.toString();
      case 'unpaid_amount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.unpaidAmount)}';
      case 'return_amount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.returnAmount)}';
      case 'service_discount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.serviceDiscount)}';
      case 'product_discount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.productDiscount)}';
      case 'package_discount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.packageDiscount)}';
      case 'service_amount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.serviceAmount)}';
      case 'product_amount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.productAmount)}';
      case 'package_amount':
        return '${row.currencySymbol ?? '\$'} ${_formatCurrency(row.packageAmount)}';
      default:
        // Dynamically discovered columns read straight from the raw row.
        return formatReportCell(key, row.rawFields[key]);
    }
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) => reportHumanDate(date);

  String? _formatDateApi(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
