// lib/app/modules/service_revenue_report/controllers/service_revenue_report_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_service.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';
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

  String get label =>
      resolveReportColumnLabel('reports.serviceRevenue.columns', labelKey);
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
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxnInt selectedBranchId = RxnInt(null);

  /// `Rx<dynamic>` (never `'all'.obs`) so int service ids can never crash
  /// the setter with `type 'int' is not a subtype of type 'String'`.
  final Rx<dynamic> selectedServiceId = Rx<dynamic>('all');

  // Temp filters (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxnInt tempBranchId = RxnInt(null);
  final Rx<dynamic> tempServiceId = Rx<dynamic>('all');

  // ── Column Selection ──────────────────────────────────────────────────
  // Keys are snake_case to match API `monthlyData` fields, so dynamic
  // discovery never duplicates them.
  final RxList<ServiceRevenueColumn> allColumns = <ServiceRevenueColumn>[
    ServiceRevenueColumn(
      key: 'branch_name',
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
      key: 'total_amount',
      labelKey: 'reports.serviceRevenue.columns.totalAmount',
      width: 140,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'total_discount',
      labelKey: 'reports.serviceRevenue.columns.totalDiscount',
      width: 140,
      isSelected: true,
    ),
    ServiceRevenueColumn(
      key: 'net_revenue',
      labelKey: 'reports.serviceRevenue.columns.netRevenue',
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

  // ── Computed ──────────────────────────────────────────────────────────
  List<ServiceRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

  bool get isOwner => _auth.isOwner;
  bool get showBranchFilter => isOwner && branches.isNotEmpty;

  String get dateRangeLabel =>
      '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';

  String get selectedBranchLabel {
    if (selectedBranchId.value == null) {
      return 'reports.filter.allBranches'.trns();
    }
    final branch = branches.firstWhereOrNull(
      (b) => b.value == selectedBranchId.value,
    );
    return branch?.label ?? 'reports.filter.allBranches'.trns();
  }

  String get selectedServiceLabel {
    if (selectedServiceId.value == 'all') {
      return 'reports.filter.allServices'.trns();
    }
    final service = services.firstWhereOrNull(
      (s) => s.value == selectedServiceId.value,
    );
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
      branchId: isOwner
          ? selectedBranchId.value
          : _auth.currentUser.value?.branchId,
      serviceId: selectedServiceId.value,
    );

    reportResponse.value = response;
    if (response.isCompleted) syncDynamicColumns();
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
    initTempMulti(tempColumnKeys, selectedColumnKeys);
  }

  /// Discovers scalar fields present in the API rows and appends them as
  /// opt-in columns. Technical ids never become columns.
  void syncDynamicColumns() {
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(
      monthlyData.map((r) => r.rawFields),
      known,
    );
    if (fresh.isEmpty) return;
    for (final key in fresh) {
      allColumns.add(
        ServiceRevenueColumn(
          key: key,
          labelKey: key,
          width: reportColumnWidth(
            resolveReportColumnLabel('reports.serviceRevenue.columns', key),
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
      title: 'reports.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
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
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDateDisplay(row.from);
      case 'to':
        return _formatDateDisplay(row.to);
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

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(String apiDate) {
    try {
      return reportHumanDate(DateTime.parse(apiDate));
    } catch (e) {
      return apiDate;
    }
  }
}
