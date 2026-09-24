import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/controllers/product_revenue_repo.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/models/product_revenue_models.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

// ─── Column Model ───────────────────────────────────────────────────────────

class ProductRevenueColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  ProductRevenueColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });

  String get label => labelKey.trns();
}

// ─── Controller ─────────────────────────────────────────────────────────────

class ProductRevenueReportController extends GetxController {
  final ProductRevenueRepository _repository = ProductRevenueRepository();
  final AuthService _authService = Get.find<AuthService>();

  // ── State ──────────────────────────────────────────────────────────────
  final Rx<ApiResponse<ProductRevenueReport>> reportResponse =
      ApiResponse<ProductRevenueReport>.loading().obs;

  ProductRevenueReport? get report => reportResponse.value.data;
  bool get isLoading => reportResponse.value.isLoading;
  bool get hasError => reportResponse.value.isError;
  bool get hasData => report != null && report!.monthlyData.isNotEmpty;

  // ── Filter State ───────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select filters (stringified ids; empty = All).
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxSet<String> selectedProductIds = <String>{}.obs;

  // Temp filters (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;
  final RxSet<String> tempProductIds = <String>{}.obs;

  List<ReportOption> get branchFilterOptions => branches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  List<ReportOption> get productFilterOptions => products
      .map((p) => ReportOption(label: p.label, value: p.value))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchFilterOptions,
    allLabel: 'reports.product.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get productFilterDisplay => multiSelectDisplay(
    selected: selectedProductIds,
    options: productFilterOptions,
    allLabel: 'reports.product.filter.allProducts'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'reports.product.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempProductFilterDisplay => multiSelectDisplay(
    selected: tempProductIds,
    options: productFilterOptions,
    allLabel: 'reports.product.filter.allProducts'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get selectedBranchName => branchFilterDisplay;

  String get selectedProductName => productFilterDisplay;

  // ── Column Selection ───────────────────────────────────────────────────
  final RxList<ProductRevenueColumn> allColumns = <ProductRevenueColumn>[
    ProductRevenueColumn(
      key: 'branch',
      labelKey: 'reports.product.columns.branch',
      width: 140,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'from',
      labelKey: 'reports.product.columns.from',
      width: 120,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'to',
      labelKey: 'reports.product.columns.to',
      width: 120,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'totalAmount',
      labelKey: 'reports.product.columns.totalAmount',
      width: 140,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'totalDiscount',
      labelKey: 'reports.product.columns.totalDiscount',
      width: 145,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'netRevenue',
      labelKey: 'reports.product.columns.netRevenue',
      width: 140,
      isSelected: true,
    ),
  ].obs;

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branch',
    'from',
    'to',
    'totalAmount',
    'totalDiscount',
    'netRevenue',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.label))
      .toList();

  // ── Computed ───────────────────────────────────────────────────────────
  List<ProductRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  String get dateRangeLabel =>
      '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';

  bool get isOwner => _authService.isOwner;

  int get userBranchId => _authService.currentUser.value?.branchId ?? 0;

  List<BranchLookup> get branches => report?.branches ?? [];

  List<ProductLookup> get products => report?.products ?? [];

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
    fetchReport();
  }

  void _initializeFilters() {
    if (!isOwner) {
      selectedBranchIds.assignAll([userBranchId.toString()]);
      tempBranchIds.assignAll([userBranchId.toString()]);
    }
  }

  // ── API Calls ──────────────────────────────────────────────────────────
  Future<void> fetchReport({bool showLoading = true}) async {
    if (showLoading) {
      reportResponse.value = ApiResponse.loading();
    }

    final List<String>? branchIds;
    if (isOwner) {
      branchIds = selectedBranchIds.isEmpty ? null : selectedBranchIds.toList();
    } else {
      branchIds = [userBranchId.toString()];
    }

    final response = await _repository.getProductRevenue(
      branchIds: branchIds,
      fromDate: _formatDateForApi(fromDate.value),
      toDate: _formatDateForApi(toDate.value),
      productIds: selectedProductIds.isEmpty
          ? null
          : selectedProductIds.toList(),
    );

    reportResponse.value = response;

    if (response.isError) {
      SnackbarService.showError(
        title: 'reports.product.errors.title'.trns(),
        message:
            response.message ?? 'reports.product.errors.fetchFailed'.trns(),
      );
    }
  }

  Future<void> refreshReport() async {
    await fetchReport(showLoading: false);
  }

  // ── Filter Actions ─────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    initTempMulti(tempBranchIds, selectedBranchIds);
    initTempMulti(tempProductIds, selectedProductIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    selectedProductIds.assignAll(tempProductIds);
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchIds.clear();
    if (!isOwner) {
      tempBranchIds.assignAll([userBranchId.toString()]);
    }
    tempProductIds.clear();
  }

  // ── Column Selection Actions ───────────────────────────────────────────
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
      title: 'reports.product.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────
  void navigateToDetails(ProductRevenueData data) {
    Get.toNamed(
      Routes.PRODUCT_REVENUE_DETAILS,
      parameters: {
        'branch_id': data.branchId.toString(),
        'from_date': _formatDateForApi(fromDate.value),
        'to_date': _formatDateForApi(toDate.value),
        'product_id': data.productId,
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  String getCellValue(ProductRevenueData row, String key) {
    switch (key) {
      case 'branch':
        return row.branchName;
      case 'from':
        return _formatDisplayDate(row.from);
      case 'to':
        return _formatDisplayDate(row.to);
      case 'totalAmount':
        return _formatCurrency(row.totalAmount);
      case 'totalDiscount':
        return _formatCurrency(row.totalDiscount);
      case 'netRevenue':
        return _formatCurrency(row.netRevenue);
      default:
        return '-';
    }
  }

  String _formatDate(DateTime date) => reportHumanDate(date);

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return _formatDate(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
