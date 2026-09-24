// lib/app/modules/customerReport/controllers/customer_report_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/models/customer_report_model.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

class CustomerReportColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  CustomerReportColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });

  String get label => labelKey.trns();
}

class CustomerReportController extends GetxController {
  final NetworkService _network = Get.find<NetworkService>();
  final AuthService _auth = Get.find<AuthService>();

  // ── API response state ────────────────────────────────────────────────────
  final Rx<ApiResponse<CustomerReportResponse>> reportResponse =
      ApiResponse<CustomerReportResponse>.loading().obs;

  // ── Filter state ──────────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select filters (stringified ids; empty = All).
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxSet<String> selectedCustomerIds = <String>{}.obs;

  // Temp filters (inside sheet before apply)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;
  final RxSet<String> tempCustomerIds = <String>{}.obs;

  List<ReportOption> get branchFilterOptions => branches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  List<ReportOption> get customerFilterOptions => customers
      .map((c) => ReportOption(label: c.label, value: c.value.toString()))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchFilterOptions,
    allLabel: 'customerReport.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get customerFilterDisplay => multiSelectDisplay(
    selected: selectedCustomerIds,
    options: customerFilterOptions,
    allLabel: 'customerReport.filter.allCustomers'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'customerReport.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempCustomerFilterDisplay => multiSelectDisplay(
    selected: tempCustomerIds,
    options: customerFilterOptions,
    allLabel: 'customerReport.filter.allCustomers'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  // ── Column selector ───────────────────────────────────────────────────────
  final RxList<CustomerReportColumn> allColumns = <CustomerReportColumn>[
    CustomerReportColumn(
      key: 'branch_name',
      labelKey: 'customerReport.columns.branch',
      width: 140,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'from',
      labelKey: 'customerReport.columns.from',
      width: 110,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'to',
      labelKey: 'customerReport.columns.to',
      width: 110,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'total_amount',
      labelKey: 'customerReport.columns.totalAmount',
      width: 130,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'total_discount',
      labelKey: 'customerReport.columns.totalDiscount',
      width: 130,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'net_revenue',
      labelKey: 'customerReport.columns.netRevenue',
      width: 130,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'remaining_amount',
      labelKey: 'customerReport.columns.remainingAmount',
      width: 150,
      isSelected: true,
    ),
    CustomerReportColumn(
      key: 'total_bookings',
      labelKey: 'customerReport.columns.totalBookings',
      width: 120,
      isSelected: false,
    ),
    CustomerReportColumn(
      key: 'completed_bookings',
      labelKey: 'customerReport.columns.completedBookings',
      width: 140,
      isSelected: false,
    ),
    CustomerReportColumn(
      key: 'pending_bookings',
      labelKey: 'customerReport.columns.pendingBookings',
      width: 140,
      isSelected: false,
    ),
    CustomerReportColumn(
      key: 'cancelled_bookings',
      labelKey: 'customerReport.columns.cancelledBookings',
      width: 140,
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
    'net_revenue',
    'remaining_amount',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.label))
      .toList();

  // ── Pagination ────────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;

  // ── Computed ──────────────────────────────────────────────────────────────
  List<CustomerReportColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  bool get isOwner => _auth.isOwner;

  List<BranchOption> get branches => reportResponse.value.data?.branches ?? [];

  List<CustomerOption> get customers =>
      reportResponse.value.data?.customers ?? [];

  List<CustomerReportData> get reportData =>
      reportResponse.value.data?.monthlyData ?? [];

  List<CustomerReportData> get pagedData {
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, reportData.length);
    return reportData.sublist(start, end);
  }

  int get totalPages =>
      reportData.isEmpty ? 1 : (reportData.length / itemsPerPage).ceil();

  String get dateRangeLabel {
    return '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';
  }

  String _fmt(DateTime d) => reportHumanDate(d);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initializeDates();
    fetchReport();
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

  // ── API Calls ─────────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    try {
      reportResponse.value = ApiResponse.loading();

      final params = <String, dynamic>{
        'from_date': _apiDateFormat(fromDate.value),
        'to_date': _apiDateFormat(toDate.value),
      };

      // If not owner, send branch_ids from user model
      if (!isOwner && _auth.currentUser.value?.branchId != null) {
        addIndexedParams(params, 'branch_ids', [
          _auth.currentUser.value!.branchId.toString(),
        ]);
      } else if (selectedBranchIds.isNotEmpty) {
        addIndexedParams(params, 'branch_ids', selectedBranchIds);
      }

      // Add customer_ids if selected
      if (selectedCustomerIds.isNotEmpty) {
        addIndexedParams(params, 'customer_ids', selectedCustomerIds);
      }

      final response = await _network.get(
        endpoint: ApiPath.customersReport,
        queryParams: params,
      );

      if (response.isCompleted && response.data != null) {
        final parsed = CustomerReportResponse.fromJson(response.data!);
        reportResponse.value = ApiResponse.completed(parsed);
      } else {
        reportResponse.value = ApiResponse.error(
          response.message ?? 'customerReport.errors.fetchFailed'.trns(),
        );
      }
    } catch (e) {
      reportResponse.value = ApiResponse.error(e.toString());
    }
  }

  String _apiDateFormat(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> refreshReport() async {
    currentPage.value = 1;
    await fetchReport();
  }

  // ── Filter Actions ────────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    initTempMulti(tempBranchIds, selectedBranchIds);
    initTempMulti(tempCustomerIds, selectedCustomerIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    selectedCustomerIds.assignAll(tempCustomerIds);
    currentPage.value = 1;
    fetchReport();
  }

  void resetFilter() {
    _initializeDates();
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempBranchIds.clear();
    tempCustomerIds.clear();
  }

  // ── Column Actions ────────────────────────────────────────────────────────
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
      title: 'customerReport.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void viewDetails(CustomerReportData data) {
    final params = <String, String>{
      'branch_id': data.branchId.toString(),
      'customer_id': data.customerId.toString(),
      'from_date': data.from,
      'to_date': data.to,
      'branch_name': data.branchName,
    };

    Get.toNamed(Routes.CUSTOMER_DETAILS, parameters: params);
  }

  // ── Cell Value Getter ─────────────────────────────────────────────────────
  String getCellValue(CustomerReportData row, String key) {
    switch (key) {
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDisplayDate(row.from);
      case 'to':
        return _formatDisplayDate(row.to);
      case 'total_amount':
        return '\$${row.totalAmount}';
      case 'total_discount':
        return '\$${row.totalDiscount}';
      case 'net_revenue':
        return '\$${row.netRevenue}';
      case 'remaining_amount':
        return '\$${row.remainingAmount}';
      case 'total_bookings':
        return row.totalBookings.toString();
      case 'completed_bookings':
        return row.completedBookings.toString();
      case 'pending_bookings':
        return row.pendingBookings.toString();
      case 'cancelled_bookings':
        return row.cancelledBookings.toString();
      default:
        return '-';
    }
  }

  String _formatDisplayDate(String apiDate) {
    try {
      final parsed = DateTime.parse(apiDate);
      return _fmt(parsed);
    } catch (_) {
      return apiDate;
    }
  }
}
