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
  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select branch filter (stringified ids; empty = All branches).
  final RxSet<String> selectedBranchIds = <String>{}.obs;

  // Temp filter (inside sheet before apply)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;

  // Branch options from API
  final RxList<BranchOption> branchOptions = <BranchOption>[].obs;
  List<ReportOption> get branchFilterOptions => branchOptions
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchFilterOptions,
    allLabel: 'reports.revenue.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'reports.revenue.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

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
    return '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';
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
    _initializeDates();
    fetchRevenueReport();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    fromDate.value = firstDay;
    toDate.value = lastDay;
    tempFromDate.value = firstDay;
    tempToDate.value = lastDay;
  }

  // ── API Calls ────────────────────────────────────────────────────────────
  Future<void> fetchRevenueReport({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final List<String>? branchIdsParam;
      if (isOwner) {
        branchIdsParam = selectedBranchIds.isEmpty
            ? null
            : selectedBranchIds.toList();
      } else {
        final userBranch = _authService.currentUser.value?.branchId;
        branchIdsParam = userBranch == null ? null : [userBranch.toString()];
      }

      final response = await _reportService.getRevenueReport(
        branchIds: branchIdsParam,
        fromDate: _formatDateApi(fromDate.value),
        toDate: _formatDateApi(toDate.value),
      );

      if (response.isCompleted && response.data != null) {
        _parseRevenueResponse(response.data!);
      } else {
        SnackbarService.showError(
          title: 'errors.errorTitle'.trns(),
          message: response.message ?? 'errors.unexpected'.trns(),
        );
      }
    } catch (e) {
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: 'errors.unexpected'.trns(),
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void _parseRevenueResponse(Map<String, dynamic> data) {
    // Parse branches
    if (data['branches'] != null && data['branches'] is List) {
      final List<BranchOption> branches = [];
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
    initTempMulti(tempBranchIds, selectedBranchIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);

    fetchRevenueReport();
  }

  void resetFilter() {
    final now = DateTime.now();
    tempFromDate.value = DateTime(now.year, now.month, 1);
    tempToDate.value = DateTime(now.year, now.month + 1, 0);
    tempBranchIds.clear();
  }

  // ── Column Actions ───────────────────────────────────────────────────────
  void initTempColumns() {
    initTempMulti(tempColumnKeys, selectedColumnKeys);
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
        return _formatCurrency(row.totalAmount);
      case 'total_discount':
        return _formatCurrency(row.totalDiscount);
      case 'total_revenue':
        return _formatCurrency(row.totalRevenue);
      case 'total_balance':
        return _formatCurrency(row.totalBalance);
      case 'cash_payment':
        return _formatCurrency(row.cashPayment);
      case 'card_payment':
        return _formatCurrency(row.cardPayment);
      case 'online_payment':
        return _formatCurrency(row.onlinePayment);
      case 'service_revenue':
        return _formatCurrency(row.serviceRevenue);
      case 'product_revenue':
        return _formatCurrency(row.productRevenue);
      case 'package_revenue':
        return _formatCurrency(row.packageRevenue);
      case 'total_count':
        return row.totalCount.toString();
      case 'paid_count':
        return row.paidCount.toString();
      case 'unpaid_count':
        return row.unpaidCount.toString();
      case 'return_count':
        return row.returnCount.toString();
      default:
        return '-';
    }
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) => reportHumanDate(date);

  String _formatDateApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
