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
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select filters (stringified ids; empty = All).
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxSet<String> selectedServiceIds = <String>{}.obs;

  // Temp filters (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;
  final RxSet<String> tempServiceIds = <String>{}.obs;

  List<ReportOption> get branchFilterOptions => branches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  List<ReportOption> get serviceFilterOptions => services
      .map((s) => ReportOption(label: s.label, value: s.value.toString()))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchFilterOptions,
    allLabel: 'reports.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get serviceFilterDisplay => multiSelectDisplay(
    selected: selectedServiceIds,
    options: serviceFilterOptions,
    allLabel: 'reports.filter.allServices'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'reports.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempServiceFilterDisplay => multiSelectDisplay(
    selected: tempServiceIds,
    options: serviceFilterOptions,
    allLabel: 'reports.filter.allServices'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

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

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branchName',
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

  // ── Computed ──────────────────────────────────────────────────────────
  List<ServiceRevenueColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => allColumns.where((c) => c.isSelected).length;

  bool get isOwner => _auth.isOwner;
  bool get showBranchFilter => isOwner && branches.isNotEmpty;

  String get dateRangeLabel =>
      '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';

  String get selectedBranchLabel => branchFilterDisplay;

  String get selectedServiceLabel => serviceFilterDisplay;

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

    final List<String>? branchIds;
    if (isOwner) {
      branchIds = selectedBranchIds.isEmpty ? null : selectedBranchIds.toList();
    } else {
      final userBranch = _auth.currentUser.value?.branchId;
      branchIds = userBranch == null ? null : [userBranch.toString()];
    }

    final response = await _service.getServiceRevenueReport(
      fromDate: _formatDateForApi(fromDate.value),
      toDate: _formatDateForApi(toDate.value),
      branchIds: branchIds,
      serviceIds: selectedServiceIds.isEmpty
          ? null
          : selectedServiceIds.toList(),
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
    initTempMulti(tempBranchIds, selectedBranchIds);
    initTempMulti(tempServiceIds, selectedServiceIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    selectedServiceIds.assignAll(tempServiceIds);
    _fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchIds.clear();
    tempServiceIds.clear();
  }

  // ── Column Selection ──────────────────────────────────────────────────
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
