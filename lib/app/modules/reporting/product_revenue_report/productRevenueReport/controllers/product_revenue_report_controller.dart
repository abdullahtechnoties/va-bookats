import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/controllers/product_revenue_repo.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/models/product_revenue_models.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

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
  final Rx<DateTime> fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxInt selectedBranchId = 0.obs;
  final RxString selectedProductId = 'all'.obs;

  // Temp filters (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxInt tempBranchId = 0.obs;
  final RxString tempProductId = 'all'.obs;

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

  late RxList<bool> tempColumnSelected;

  // ── Computed ───────────────────────────────────────────────────────────
  List<ProductRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  String get dateRangeLabel =>
      '${_formatDate(fromDate.value)} - ${_formatDate(toDate.value)}';

  bool get isOwner => _authService.isOwner;

  int get userBranchId => _authService.currentUser.value?.branchId ?? 0;

  List<BranchLookup> get branches => report?.branches ?? [];

  List<ProductLookup> get products => report?.products ?? [];

  String get selectedBranchName {
    if (selectedBranchId.value == 0) {
      return 'reports.product.filter.allBranches'.trns();
    }
    final branch = branches.firstWhereOrNull(
      (b) => b.value == selectedBranchId.value,
    );
    return branch?.label ?? '';
  }

  String get selectedProductName {
    if (selectedProductId.value == 'all') {
      return 'reports.product.filter.allProducts'.trns();
    }
    final product = products.firstWhereOrNull(
      (p) => p.value == selectedProductId.value,
    );
    return product?.label ?? '';
  }

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
      productId: selectedProductId.value == 'all' ? null : selectedProductId.value,
    );

    reportResponse.value = response;

    if (response.isError) {
      SnackbarService.showError(
        title: 'reports.product.errors.title'.trns(),
        message: response.message ?? 'reports.product.errors.fetchFailed'.trns(),
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
      tempColumnSelected[i] = true;
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

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]}/${date.day}/${date.year}';
  }

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