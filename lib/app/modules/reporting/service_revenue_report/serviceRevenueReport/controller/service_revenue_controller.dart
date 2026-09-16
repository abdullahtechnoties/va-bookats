// lib/app/modules/service_revenue_report/controllers/service_revenue_report_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_service.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import '../models/service_revenue_models.dart';

class ServiceRevenueColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  ServiceRevenueColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });

  String get label => labelKey.trns();
}

class ServiceRevenueReportController extends GetxController {
  final ServiceRevenueService _service = Get.find<ServiceRevenueService>();
  final AuthService _auth = Get.find<AuthService>();

  // ── API Response ──────────────────────────────────────────────────────
  final Rx<ApiResponse<ServiceRevenueResponse>> reportResponse =
      ApiResponse<ServiceRevenueResponse>.loading().obs;

  ServiceRevenueResponse? get reportData => reportResponse.value.data;
  List<ServiceRevenueData> get monthlyData => reportData?.monthlyData ?? [];
  List<BranchOption> get branches => reportData?.branches ?? [];
  List<ServiceOption> get services => reportData?.services ?? [];

  // ── Filter State ──────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxnInt selectedBranchId = RxnInt(null);
  final Rx<dynamic> selectedServiceId = 'all'.obs;

  // Temp filters (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxnInt tempBranchId = RxnInt(null);
  final Rx<dynamic> tempServiceId = 'all'.obs;

  // ── Column Selection ──────────────────────────────────────────────────
  final RxList<ServiceRevenueColumn> allColumns = <ServiceRevenueColumn>[
    ServiceRevenueColumn(
      key: 'branchName',
      labelKey: 'reports.serviceRevenue.columns.branch',
      width: 140,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'from',
      labelKey: 'reports.serviceRevenue.columns.from',
      width: 120,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'to',
      labelKey: 'reports.serviceRevenue.columns.to',
      width: 120,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'totalAmount',
      labelKey: 'reports.serviceRevenue.columns.totalAmount',
      width: 140,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'totalDiscount',
      labelKey: 'reports.serviceRevenue.columns.totalDiscount',
      width: 140,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'netRevenue',
      labelKey: 'reports.serviceRevenue.columns.netRevenue',
      width: 140,
      isSelected: true,
    ),
  ].obs;

  late RxList<bool> tempColumnSelected;

  // ── Computed ──────────────────────────────────────────────────────────
  List<ServiceRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

  bool get isOwner => _auth.isOwner;
  bool get showBranchFilter => isOwner && branches.isNotEmpty;

  String get dateRangeLabel =>
      '${_formatDate(fromDate.value)} - ${_formatDate(toDate.value)}';

  String get selectedBranchLabel {
    if (selectedBranchId.value == null) return 'reports.filter.allBranches'.trns();
    final branch = branches.firstWhereOrNull((b) => b.value == selectedBranchId.value);
    return branch?.label ?? 'reports.filter.allBranches'.trns();
  }

  String get selectedServiceLabel {
    if (selectedServiceId.value == 'all') return 'reports.filter.allServices'.trns();
    final service = services.firstWhereOrNull((s) => s.value == selectedServiceId.value);
    return service?.label ?? 'reports.filter.allServices'.trns();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _fetchReport();
  }

  @override
  void onReady() {
    super.onReady();
    ever(reportResponse, _handleResponseChange);
  }

  void _handleResponseChange(ApiResponse<ServiceRevenueResponse> response) {
    if (response.isError) {
      SnackbarService.showError(
        title: 'reports.errors.title'.trns(),
        message: response.message ?? 'reports.errors.fetchFailed'.trns(),
      );
    }
  }

  // ── API Calls ─────────────────────────────────────────────────────────
  Future<void> _fetchReport() async {
    reportResponse.value = ApiResponse.loading();

    final response = await _service.getServiceRevenueReport(
      fromDate: _formatDateForApi(fromDate.value),
      toDate: _formatDateForApi(toDate.value),
      branchId: isOwner ? selectedBranchId.value : _auth.currentUser.value?.branchId,
      serviceId: selectedServiceId.value,
    );

    reportResponse.value = response;
  }

  Future<void> refreshReport() async {
    await _fetchReport();
  }

  // ── Filter Actions ────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempBranchId.value = selectedBranchId.value;
    tempServiceId.value = selectedServiceId.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedServiceId.value = tempServiceId.value;
    _fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchId.value = null;
    tempServiceId.value = 'all';
  }

  // ── Column Selection ──────────────────────────────────────────────────
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

  // ── Navigation ────────────────────────────────────────────────────────
  void navigateToDetails(ServiceRevenueData data) {
    Get.toNamed(
      Routes.SERVICE_REVENUE_DETAILS,
      arguments: {
        'branchId': data.branchId,
        'fromDate': data.from,
        'toDate': data.to,
        'serviceId': data.serviceId,
        'branchName': data.branchName,
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String getCellValue(ServiceRevenueData row, String key) {
    switch (key) {
      case 'branchName':
        return row.branchName;
      case 'from':
        return _formatDateDisplay(row.from);
      case 'to':
        return _formatDateDisplay(row.to);
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
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month]}/${date.day}/${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(String apiDate) {
    try {
      final parts = apiDate.split('-');
      if (parts.length != 3) return apiDate;
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = int.tryParse(parts[1]) ?? 1;
      return '${months[month]}/${parts[2]}/${parts[0]}';
    } catch (e) {
      return apiDate;
    }
  }

  String _formatCurrency(String amount) {
    try {
      final value = double.tryParse(amount) ?? 0;
      if (value == 0) return '\$0';
      return '\$${value.toStringAsFixed(2)}';
    } catch (e) {
      return amount;
    }
  }
}