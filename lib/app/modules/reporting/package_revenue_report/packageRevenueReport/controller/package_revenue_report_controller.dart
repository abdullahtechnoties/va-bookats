import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/models/package_revenue_report_model.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/repo/package_revenue_report_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

class PackageRevenueColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  PackageRevenueColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });
}

class PackageRevenueReportController extends GetxController {
  final PackageRevenueReportRepository _repository =
      PackageRevenueReportRepository();
  final AuthService _authService = Get.find<AuthService>();

  // ── Loading & states ──────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // ── API Response ──────────────────────────────────────────────────────
  final Rx<PackageRevenueReportModel?> reportData =
      Rx<PackageRevenueReportModel?>(null);

  // ── Filter state ──────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select filters (stringified ids; empty = All).
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxSet<String> selectedPackageIds = <String>{}.obs;

  // Temp filters
  final Rx<DateTime> tempFromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;
  final RxSet<String> tempPackageIds = <String>{}.obs;

  // ── Dropdown Options ──────────────────────────────────────────────────
  final RxList<BranchFilterOption> branches = <BranchFilterOption>[].obs;
  final RxList<PackageFilterOption> packages = <PackageFilterOption>[].obs;

  List<ReportOption> get branchFilterOptions => branches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  List<ReportOption> get packageFilterOptions => packages
      .map((p) => ReportOption(label: p.label, value: p.value.toString()))
      .toList();

  String get packageFilterDisplay => multiSelectDisplay(
    selected: selectedPackageIds,
    options: packageFilterOptions,
    allLabel: 'packageRevenue.filter.allPackages'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'packageRevenue.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempPackageFilterDisplay => multiSelectDisplay(
    selected: tempPackageIds,
    options: packageFilterOptions,
    allLabel: 'packageRevenue.filter.allPackages'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  /// Backwards-compatible single-label accessors (main-view dropdown).
  String get selectedPackageLabel => packageFilterDisplay;

  // ── Column selector ───────────────────────────────────────────────────
  final RxList<PackageRevenueColumn> allColumns = <PackageRevenueColumn>[
    PackageRevenueColumn(
      key: 'branch_name',
      labelKey: 'packageRevenue.table.branch',
      width: 130,
      isSelected: true,
    ),
    PackageRevenueColumn(
      key: 'from',
      labelKey: 'packageRevenue.table.from',
      width: 120,
      isSelected: true,
    ),
    PackageRevenueColumn(
      key: 'to',
      labelKey: 'packageRevenue.table.to',
      width: 120,
      isSelected: true,
    ),
    PackageRevenueColumn(
      key: 'total_amount',
      labelKey: 'packageRevenue.table.totalAmount',
      width: 140,
      isSelected: true,
    ),
    PackageRevenueColumn(
      key: 'total_discount',
      labelKey: 'packageRevenue.table.totalDiscount',
      width: 150,
      isSelected: true,
    ),
    PackageRevenueColumn(
      key: 'net_revenue',
      labelKey: 'packageRevenue.table.netRevenue',
      width: 140,
      isSelected: true,
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
    'net_revenue',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.labelKey.trns()))
      .toList();

  // ── Computed ──────────────────────────────────────────────────────────
  List<MonthlyPackageData> get monthlyData =>
      reportData.value?.monthlyData ?? [];

  List<PackageRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  String get dateRangeLabel =>
      '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';

  bool get showBranchFilter => _authService.isOwner;

  bool get isEmpty => !isLoading.value && monthlyData.isEmpty;

  int? get userBranchId => _authService.currentUser.value?.branchId;

  String _formatApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  // ── API Calls ─────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<String>? branchParam;
      if (showBranchFilter) {
        branchParam = selectedBranchIds.isEmpty
            ? null
            : selectedBranchIds.toList();
      } else {
        branchParam = userBranchId == null ? null : [userBranchId.toString()];
      }

      final response = await _repository.getPackageRevenueReport(
        fromDate: _formatApi(fromDate.value),
        toDate: _formatApi(toDate.value),
        branchIds: branchParam,
        packageIds: selectedPackageIds.isEmpty
            ? null
            : selectedPackageIds.toList(),
      );

      if (response.isCompleted && response.data != null) {
        reportData.value = response.data;
        branches.value = response.data!.branches;
        packages.value = response.data!.packages;
      } else {
        errorMessage.value = response.message ?? 'errors.failedToFetch'.trns();
        SnackbarService.showError(
          title: 'errors.errorTitle'.trns(),
          message: errorMessage.value,
        );
      }
    } catch (e) {
      errorMessage.value = 'errors.unexpected'.trns();
      SnackbarService.showError(
        title: 'errors.errorTitle'.trns(),
        message: errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReport() async {
    isRefreshing.value = true;
    await fetchReport();
    isRefreshing.value = false;
  }

  // ── Filter Actions ────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    initTempMulti(tempBranchIds, selectedBranchIds);
    initTempMulti(tempPackageIds, selectedPackageIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    selectedPackageIds.assignAll(tempPackageIds);
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchIds.clear();
    tempPackageIds.clear();
  }

  /// Main-view package multi-picker: replaces the selection and refetches.
  void applyMainPackageSelection(Set<String> ids) {
    selectedPackageIds.assignAll(ids);
    tempPackageIds.assignAll(ids);
    fetchReport();
  }

  // ── Column Actions ────────────────────────────────────────────────────
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
    tempColumnKeys.assignAll(allColumns.map((c) => c.key));
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
      title: 'packageRevenue.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String getCellValue(MonthlyPackageData row, String key) {
    switch (key) {
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDisplayFromString(row.from);
      case 'to':
        return _formatDisplayFromString(row.to);
      case 'total_amount':
        return '\$${row.totalAmount.toStringAsFixed(2)}';
      case 'total_discount':
        return '\$${row.totalDiscount.toStringAsFixed(2)}';
      case 'net_revenue':
        return '\$${row.netRevenue.toStringAsFixed(2)}';
      default:
        return '-';
    }
  }

  String _formatDisplayFromString(String dateStr) {
    try {
      return reportHumanDate(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────
  void navigateToDetails(MonthlyPackageData data) {
    Get.toNamed(
      Routes.PACKAGE_REVENUE_DETAILS,
      arguments: {
        'branch_id': data.branchId,
        'from_date': data.from,
        'to_date': data.to,
        'package_id': data.packageId,
      },
    );
  }
}
