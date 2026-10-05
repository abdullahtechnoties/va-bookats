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

  String get label => resolveReportColumnLabel(
        'reports.product.columns',
        labelKey,
      );
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
  final RxInt selectedBranchId = 0.obs;
  final RxString selectedProductId = 'all'.obs;

  // Temp filters (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxInt tempBranchId = 0.obs;
  final RxString tempProductId = 'all'.obs;

  String get selectedBranchName {
    if (selectedBranchId.value == 0) {
      return 'reports.product.filter.allBranches'.trns();
    }
    final branch = branches.firstWhereOrNull(
      (b) => b.value == selectedBranchId.value,
    );
    return branch?.label ?? 'reports.product.filter.allBranches'.trns();
  }

  String get selectedProductName {
    if (selectedProductId.value == 'all') {
      return 'reports.product.filter.allProducts'.trns();
    }
    final product = products.firstWhereOrNull(
      (p) => p.value == selectedProductId.value,
    );
    return product?.label ?? 'reports.product.filter.allProducts'.trns();
  }

  // ── Column Selection ───────────────────────────────────────────────────
  // Keys are snake_case to match API `monthlyData` fields, so dynamic
  // discovery never duplicates them.
  final RxList<ProductRevenueColumn> allColumns = <ProductRevenueColumn>[
    ProductRevenueColumn(
      key: 'branch_name',
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
      key: 'total_amount',
      labelKey: 'reports.product.columns.totalAmount',
      width: 140,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'total_discount',
      labelKey: 'reports.product.columns.totalDiscount',
      width: 145,
      isSelected: true,
    ),
    ProductRevenueColumn(
      key: 'net_revenue',
      labelKey: 'reports.product.columns.netRevenue',
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
      selectedBranchId.value = userBranchId;
      tempBranchId.value = userBranchId;
    }
  }

  // ── API Calls ──────────────────────────────────────────────────────────
  Future<void> fetchReport({bool showLoading = true}) async {
    if (showLoading) {
      reportResponse.value = ApiResponse.loading();
    }

    final response = await _repository.getProductRevenue(
      branchId: selectedBranchId.value == 0 ? null : selectedBranchId.value,
      fromDate: _formatDateForApi(fromDate.value),
      toDate: _formatDateForApi(toDate.value),
      productId: selectedProductId.value == 'all'
          ? null
          : selectedProductId.value,
    );

    reportResponse.value = response;

    if (response.isCompleted) syncDynamicColumns();

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
    tempBranchId.value = selectedBranchId.value;
    tempProductId.value = selectedProductId.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedProductId.value = tempProductId.value;
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchId.value = isOwner ? 0 : userBranchId;
    tempProductId.value = 'all';
  }

  // ── Column Selection Actions ───────────────────────────────────────────
  void initTempColumns() {
    initTempMulti(tempColumnKeys, selectedColumnKeys);
  }

  /// Discovers scalar fields present in the API rows and appends them as
  /// opt-in columns. Technical ids never become columns.
  void syncDynamicColumns() {
    final rows = report?.monthlyData ?? [];
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(
      rows.map((r) => r.rawFields),
      known,
    );
    if (fresh.isEmpty) return;
    for (final key in fresh) {
      allColumns.add(
        ProductRevenueColumn(
          key: key,
          labelKey: key,
          width: reportColumnWidth(
            resolveReportColumnLabel('reports.product.columns', key),
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
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDisplayDate(row.from);
      case 'to':
        return _formatDisplayDate(row.to);
      case 'total_amount':
        return '${row.currencySymbol ?? '\$'} ${formatReportCell(key, row.totalAmount)}';
      case 'total_discount':
        return '${row.currencySymbol ?? '\$'} ${formatReportCell(key, row.totalDiscount)}';
      case 'net_revenue':
        return '${row.currencySymbol ?? '\$'} ${formatReportCell(key, row.netRevenue)}';
      default:
        // Dynamically discovered columns read straight from the raw row.
        return formatReportCell(key, row.rawFields[key]);
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
}
