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
  final RxnString selectedBranchId = RxnString(null);
  final RxnString selectedStaffId = RxnString(null);

  // Temp filters (inside bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxnString tempBranchId = RxnString(null);
  final RxnString tempStaffId = RxnString(null);

  // ── Columns ───────────────────────────────────────────────────────────────
  // Keys are snake_case to match API `monthlyData` fields, so dynamic
  // discovery never duplicates them. Labels resolve via en.json first,
  // Title-Case fallback otherwise.
  final RxList<CommissionsColumn> allColumns = <CommissionsColumn>[
    CommissionsColumn(
      key: 'branch_name',
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
      key: 'total_services',
      labelKey: 'commissions.table.totalServices',
      width: 130,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'total_packages',
      labelKey: 'commissions.table.totalPackages',
      width: 130,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'service_commission',
      labelKey: 'commissions.table.serviceCommission',
      width: 150,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'package_commission',
      labelKey: 'commissions.table.packageCommission',
      width: 150,
      isSelected: true,
    ),
    CommissionsColumn(
      key: 'total_commission',
      labelKey: 'commissions.table.totalCommission',
      width: 150,
      isSelected: true,
    ),
  ].obs;

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branch_name',
    'from',
    'to',
    'total_services',
    'total_packages',
    'service_commission',
    'package_commission',
    'total_commission',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map(
        (c) => ReportColumnOption(
          key: c.key,
          label: resolveReportColumnLabel('commissions.table', c.labelKey),
        ),
      )
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

  String? get selectedBranchLabel {
    if (selectedBranchId.value == null) return null;
    return branches
        .firstWhereOrNull((b) => b.value.toString() == selectedBranchId.value)
        ?.label;
  }

  String? get selectedStaffLabel {
    if (selectedStaffId.value == null) return null;
    return staffs
        .firstWhereOrNull((s) => s.value.toString() == selectedStaffId.value)
        ?.label;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initFilters();
    fetchReport();
  }

  void _initFilters() {
    if (!isOwner && userBranchId != null) {
      selectedBranchId.value = userBranchId.toString();
      tempBranchId.value = userBranchId.toString();
    }
  }

  // ── API ───────────────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    apiResponse.value = ApiResponse.loading();

    final params = <String, dynamic>{
      'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value),
      'to_date': DateFormat('yyyy-MM-dd').format(toDate.value),
    };

    if (isOwner && selectedBranchId.value != null) {
      params['branch_id'] = selectedBranchId.value;
    } else if (!isOwner && userBranchId != null) {
      params['branch_id'] = userBranchId;
    }

    // Always send staff_id: 'all' when nothing is selected, else the id.
    params['staff_id'] = (selectedStaffId.value == null ||
            selectedStaffId.value!.isEmpty)
        ? 'all'
        : selectedStaffId.value;

    final response = await _network.get(
      endpoint: ApiPath.commissionsReport,
      queryParams: params,
    );

    if (response.isCompleted && response.data != null) {
      try {
        final data = CommissionsReportResponse.fromJson(response.data!);
        apiResponse.value = ApiResponse.completed(data);
        syncDynamicColumns();
        // First branch/staff become the default selection on first load —
        // refetch once so the data matches the filter state.
        if (_applyDefaultSelections()) {
          await fetchReport();
        }
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
    tempBranchId.value = selectedBranchId.value;
    tempStaffId.value = selectedStaffId.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedStaffId.value = tempStaffId.value;
    fetchReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    // Reset restores the defaults: first branch (owner) / own branch
    // (non-owner) and first staff.
    tempBranchId.value =
        isOwner ? _idOf(_firstRealOption(branches)) : userBranchId?.toString();
    tempStaffId.value = _idOf(_firstRealOption(staffs));
  }

  /// First selectable API option, skipping any "All" entry so the default
  /// is always a real branch/staff. Falls back to the raw first entry.
  DropdownOption? _firstRealOption(List<DropdownOption> options) {
    if (options.isEmpty) return null;
    for (final o in options) {
      final v = o.value?.toString().trim().toLowerCase() ?? '';
      if (v.isNotEmpty && v != 'all') return o;
    }
    return options.first;
  }

  String? _idOf(DropdownOption? option) => option?.value?.toString();

  /// Selects the first branch (owner only — non-owner stays scoped to their
  /// own branch) and the first staff by default once the API lists arrive.
  /// Returns true when a selection changed (caller refetches once).
  bool _applyDefaultSelections() {
    var changed = false;
    if ((selectedBranchId.value == null ||
            selectedBranchId.value!.isEmpty) &&
        isOwner) {
      final id = _idOf(_firstRealOption(branches));
      if (id != null) {
        selectedBranchId.value = id;
        tempBranchId.value = id;
        changed = true;
      }
    }
    if (selectedStaffId.value == null || selectedStaffId.value!.isEmpty) {
      final id = _idOf(_firstRealOption(staffs));
      if (id != null) {
        selectedStaffId.value = id;
        tempStaffId.value = id;
        changed = true;
      }
    }
    return changed;
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

  // ── Dynamic columns ─────────────────────────────────────────────────────
  /// Discovers scalar fields present in the API rows (e.g. future keys the
  /// backend adds tomorrow) and appends them as opt-in columns.
  /// Technical ids (branch_id, staff_id, …) never become columns.
  void syncDynamicColumns() {
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(
      monthlyData.map((r) => r.rawFields),
      known,
    );
    if (fresh.isEmpty) return;
    for (final key in fresh) {
      allColumns.add(
        CommissionsColumn(
          key: key,
          labelKey: key,
          width: reportColumnWidth(
            resolveReportColumnLabel('commissions.table', key),
          ),
          isSelected: false,
        ),
      );
    }
    allColumns.refresh();
  }

  // ── Cell Value ────────────────────────────────────────────────────────────
  String getCellValue(CommissionMonthlyData row, String key) {
    switch (key) {
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDate(row.from);
      case 'to':
        return _formatDate(row.to);
      case 'total_services':
        return row.totalServices.toString();
      case 'total_packages':
        return row.totalPackages.toString();
      case 'service_commission':
        return '${row.currencySymbol ?? '\$'} ${formatReportCell(key, row.serviceCommission)}';
      case 'package_commission':
        return '${row.currencySymbol ?? '\$'} ${formatReportCell(key, row.packageCommission)}';
      case 'total_commission':
        return '${row.currencySymbol ?? '\$'} ${formatReportCell(key, row.totalCommission)}';
      default:
        // Dynamically discovered columns read straight from the raw row.
        return formatReportCell(key, row.rawFields[key]);
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
    final staffId = selectedStaffId.value;
    Get.toNamed(
      Routes.COMMISSIONS_DETAIL,
      parameters: {
        'branch_id': row.branchId.toString(),
        'from_date': DateFormat('yyyy-MM-dd').format(fromDate.value),
        'to_date': DateFormat('yyyy-MM-dd').format(toDate.value),
        // Always forward staff_id: 'all' when nothing is selected.
        'staff_id': (staffId == null || staffId.isEmpty) ? 'all' : staffId,
      },
    );
  }
}
