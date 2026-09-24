import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/models/commissions_report_model.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/network/response/api_response.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/network/service/network_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

class CommissionsReportController extends GetxController {
  final NetworkService _network = Get.find();
  final AuthService _auth = Get.find();

  // ── API Response ──────────────────────────────────────────────────────────
  final Rx<ApiResponse<CommissionsReportResponse>> apiResponse =
      ApiResponse<CommissionsReportResponse>.loading().obs;

  // ── Filters ───────────────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select filters (stringified ids; empty = All).
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxSet<String> selectedStaffIds = <String>{}.obs;

  // Temp filters (inside bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;
  final RxSet<String> tempStaffIds = <String>{}.obs;

  List<ReportOption> get branchFilterOptions => branches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  List<ReportOption> get staffFilterOptions => staffs
      .map((s) => ReportOption(label: s.label, value: s.value.toString()))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchFilterOptions,
    allLabel: 'commissions.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get staffFilterDisplay => multiSelectDisplay(
    selected: selectedStaffIds,
    options: staffFilterOptions,
    allLabel: 'commissions.filter.allStaff'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'commissions.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempStaffFilterDisplay => multiSelectDisplay(
    selected: tempStaffIds,
    options: staffFilterOptions,
    allLabel: 'commissions.filter.allStaff'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  // ── Columns ───────────────────────────────────────────────────────────────
  final RxList<CommissionsColumn> allColumns = <CommissionsColumn>[
    CommissionsColumn(
      key: 'branchName',
      labelKey: 'commissions.table.branch',
      width: 140,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'from',
      labelKey: 'commissions.table.from',
      width: 110,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'to',
      labelKey: 'commissions.table.to',
      width: 110,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'totalServices',
      labelKey: 'commissions.table.totalServices',
      width: 130,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'totalPackages',
      labelKey: 'commissions.table.totalPackages',
      width: 130,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'serviceCommission',
      labelKey: 'commissions.table.serviceCommission',
      width: 150,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'packageCommission',
      labelKey: 'commissions.table.packageCommission',
      width: 150,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'totalCommission',
      labelKey: 'commissions.table.totalCommission',
      width: 150,
      isSelected: true,
    ),
  ].obs;

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branchName',
    'from',
    'to',
    'totalServices',
    'totalPackages',
    'serviceCommission',
    'packageCommission',
    'totalCommission',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.labelKey.trns()))
      .toList();

  // ── Computed ──────────────────────────────────────────────────────────────
  List<CommissionsColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  bool get isOwner => _auth.isOwner;

  int? get userBranchId => _auth.currentUser.value?.branchId;

  List<DropdownOption> get branches => apiResponse.value.data?.branches ?? [];

  List<DropdownOption> get staffs => apiResponse.value.data?.staffs ?? [];

  List<CommissionMonthlyData> get monthlyData =>
      apiResponse.value.data?.monthlyData ?? [];

  String get dateRangeLabel {
    final fmt = reportHumanDate;
    return '${fmt(fromDate.value)} - ${fmt(toDate.value)}';
  }

  String? get selectedBranchLabel =>
      selectedBranchIds.isEmpty ? null : branchFilterDisplay;

  String? get selectedStaffLabel =>
      selectedStaffIds.isEmpty ? null : staffFilterDisplay;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initFilters();
    fetchReport();
  }

  void _initFilters() {
    if (!isOwner && userBranchId != null) {
      selectedBranchIds.assignAll([userBranchId.toString()]);
      tempBranchIds.assignAll([userBranchId.toString()]);
    }
  }

  // ── API ───────────────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    apiResponse.value = ApiResponse.loading();

    final params = <String, dynamic>{
      'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value),
      'to_date': DateFormat('yyyy-MM-dd').format(toDate.value),
    };

    if (isOwner) {
      if (selectedBranchIds.isNotEmpty) {
        addIndexedParams(params, 'branch_ids', selectedBranchIds);
      }
    } else if (userBranchId != null) {
      addIndexedParams(params, 'branch_ids', [userBranchId.toString()]);
    }

    if (selectedStaffIds.isNotEmpty) {
      addIndexedParams(params, 'staff_ids', selectedStaffIds);
    }

    final response = await _network.get(
      endpoint: ApiPath.commissionsReport,
      queryParams: params,
    );

    if (response.isCompleted && response.data != null) {
      try {
        final data = CommissionsReportResponse.fromJson(response.data!);
        apiResponse.value = ApiResponse.completed(data);
      } catch (e) {
        apiResponse.value = ApiResponse.error(
          'commissions.errors.parseFailed'.trns(),
        );
      }
    } else {
      apiResponse.value = ApiResponse.error(
        response.message ?? 'commissions.errors.fetchFailed'.trns(),
      );
    }
  }

  // ── Filter Actions ────────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    initTempMulti(tempBranchIds, selectedBranchIds);
    initTempMulti(tempStaffIds, selectedStaffIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    selectedStaffIds.assignAll(tempStaffIds);
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchIds.clear();
    if (!isOwner && userBranchId != null) {
      tempBranchIds.assignAll([userBranchId.toString()]);
    }
    tempStaffIds.clear();
  }

  // ── Column Selection ──────────────────────────────────────────────────────
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
      title: 'commissions.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
  }

  // ── Cell Value ────────────────────────────────────────────────────────────
  String getCellValue(CommissionMonthlyData row, String key) {
    switch (key) {
      case 'branchName':
        return row.branchName;
      case 'from':
        return _formatDate(row.from);
      case 'to':
        return _formatDate(row.to);
      case 'totalServices':
        return row.totalServices.toString();
      case 'totalPackages':
        return row.totalPackages.toString();
      case 'serviceCommission':
        return '\$${row.serviceCommission}';
      case 'packageCommission':
        return '\$${row.packageCommission}';
      case 'totalCommission':
        return '\$${row.totalCommission}';
      default:
        return '-';
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('MMM/d/yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void viewDetails(CommissionMonthlyData row) {
    Get.toNamed(
      Routes.COMMISSIONS_DETAIL,
      parameters: {
        'branch_id': row.branchId.toString(),
        'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value),
        'to_date': DateFormat('yyyy-MM-dd').format(toDate.value),
        if (selectedStaffIds.isNotEmpty) 'staff_id': selectedStaffIds.first,
      },
    );
  }
}
