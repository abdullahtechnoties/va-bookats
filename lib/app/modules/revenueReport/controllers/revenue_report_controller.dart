// lib/app/modules/reports/revenue/controllers/revenue_report_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/revenueReport/service/revenue_service.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_option.dart';
import 'package:va_bookats/models/revenue_data_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

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
  final RxInt selectedBranchId = 0.obs; // 0 = All branches
  final RxString selectedBranchLabel = 'All Branches'.obs;

  // Temp filter (inside sheet before apply)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxInt tempBranchId = 0.obs;
  final RxString tempBranchLabel = 'All Branches'.obs;

  // Branch options from API
  final RxList<BranchOption> branchOptions = <BranchOption>[].obs;
  List<String> get branchLabels =>
      branchOptions.map((b) => b.label).toList();

  // ── Column selector ──────────────────────────────────────────────────────
  final RxList<RevenueColumn> allColumns = <RevenueColumn>[
    RevenueColumn(key: 'branch_name', label: 'reports.revenue.columns.branch', width: 140, isSelected: true),
    RevenueColumn(key: 'from', label: 'reports.revenue.columns.from', width: 110, isSelected: true),
    RevenueColumn(key: 'to', label: 'reports.revenue.columns.to', width: 110, isSelected: true),
    RevenueColumn(key: 'total_amount', label: 'reports.revenue.columns.totalAmount', width: 130, isSelected: true),
    RevenueColumn(key: 'total_discount', label: 'reports.revenue.columns.totalDiscount', width: 145, isSelected: true),
    RevenueColumn(key: 'total_revenue', label: 'reports.revenue.columns.totalRevenue', width: 130, isSelected: true),
    RevenueColumn(key: 'total_balance', label: 'reports.revenue.columns.totalBalance', width: 140, isSelected: true),
    RevenueColumn(key: 'cash_payment', label: 'reports.revenue.columns.cashPayment', width: 130, isSelected: false),
    RevenueColumn(key: 'card_payment', label: 'reports.revenue.columns.cardPayment', width: 130, isSelected: false),
    RevenueColumn(key: 'online_payment', label: 'reports.revenue.columns.onlinePayment', width: 145, isSelected: false),
    RevenueColumn(key: 'service_revenue', label: 'reports.revenue.columns.serviceRevenue', width: 145, isSelected: false),
    RevenueColumn(key: 'product_revenue', label: 'reports.revenue.columns.productRevenue', width: 145, isSelected: false),
    RevenueColumn(key: 'package_revenue', label: 'reports.revenue.columns.packageRevenue', width: 145, isSelected: false),
    RevenueColumn(key: 'total_count', label: 'reports.revenue.columns.totalCount', width: 110, isSelected: false),
    RevenueColumn(key: 'paid_count', label: 'reports.revenue.columns.paidCount', width: 110, isSelected: false),
    RevenueColumn(key: 'unpaid_count', label: 'reports.revenue.columns.unpaidCount', width: 120, isSelected: false),
    RevenueColumn(key: 'return_count', label: 'reports.revenue.columns.returnCount', width: 120, isSelected: false),
  ].obs;

  late RxList<bool> tempColumnSelected;

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
    return '${_formatDate(fromDate.value)} - ${_formatDate(toDate.value)}';
  }

  List<RevenueData> get pagedData {
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, revenueDataList.length);
    return revenueDataList.sublist(start, end);
  }

  int get totalPages =>
      revenueDataList.isEmpty ? 1 : (revenueDataList.length / itemsPerPage).ceil();

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
      final int? branchIdParam = isOwner && selectedBranchId.value > 0
          ? selectedBranchId.value
          : (!isOwner
              ? (_authService.currentUser.value?.branchId ?? 0)
              : null);

      final response = await _reportService.getRevenueReport(
        branchId: branchIdParam,
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
      final List<BranchOption> branches = [
        BranchOption(label: 'reports.revenue.filter.allBranches'.trns(), value: 0),
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
    final now = DateTime.now();
    tempFromDate.value = DateTime(now.year, now.month, 1);
    tempToDate.value = DateTime(now.year, now.month + 1, 0);
    tempBranchId.value = 0;
    tempBranchLabel.value = 'reports.revenue.filter.allBranches'.trns();
  }

  void selectBranch(BranchOption option) {
    tempBranchId.value = option.value;
    tempBranchLabel.value = option.label;
  }

  // ── Column Actions ───────────────────────────────────────────────────────
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
      tempColumnSelected[i] = i < 7; // Default first 7
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

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]}/${date.day}/${date.year}';
  }

  String _formatDateApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}