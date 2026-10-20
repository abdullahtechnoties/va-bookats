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
  /// Nullable dates: null = "no date filter" — nothing is sent to the API
  /// until the user picks a date in the filter sheet and taps Apply.
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();
  final RxnString selectedBranchId = RxnString(null);
  final RxnString selectedStaffId = RxnString(null);

  // Temp filters (inside bottom sheet)
  final Rxn<DateTime> tempFromDate = Rxn<DateTime>();
  final Rxn<DateTime> tempToDate = Rxn<DateTime>();
  final RxnString tempBranchId = RxnString(null);
  final RxnString tempStaffId = RxnString(null);

  /// Initial-state snapshot taken from the first report response (the API
  /// echoes the effective filter). The sheet's Reset restores exactly this —
  /// never nulls — then the sheet closes gracefully.
  DateTime? _initialFromDate;
  DateTime? _initialToDate;
  String? _initialBranchId;
  String? _initialStaffId;
  bool get hasInitialState => _initialStaffId != null || _initialBranchId != null || _initialFromDate != null;

  /// While the linked staff list refreshes after a branch change inside
  /// the open filter sheet. The staff dropdown stays visible but
  /// unselectable with a loader during this fetch.
  final RxBool isTempStaffsLoading = false.obs;

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
    final from = fromDate.value;
    final to = toDate.value;
    if (from == null && to == null) {
      return 'reports.common.allDates'.trns();
    }
    String fmt(DateTime? d) =>
        d == null ? 'reports.common.selectDate'.trns() : reportHumanDate(d);
    return '${fmt(from)} - ${fmt(to)}';
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

    // Dates are only sent when the user picked them in the filter sheet.
    // First load sends no from/to params (backend decides the range).
    final params = <String, dynamic>{};
    final from = fromDate.value;
    final to = toDate.value;
    if (from != null) {
      params['from_date'] = DateFormat('yyyy-MM-dd').format(from);
    }
    if (to != null) {
      params['to_date'] = DateFormat('yyyy-MM-dd').format(to);
    }

    if (isOwner && selectedBranchId.value != null) {
      params['branch_id'] = selectedBranchId.value;
    } else if (!isOwner && userBranchId != null) {
      params['branch_id'] = userBranchId;
    }

    // Always send staff_id: 'all' when nothing is selected, else the id.
    params['staff_id'] =
        (selectedStaffId.value == null || selectedStaffId.value!.isEmpty)
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
        _applyResponseSelections(data);
        // syncDynamicColumns();
        // // First branch/staff become the default selection on first load —
        // // refetch once so the data matches the filter state.
        if (_applyDefaultSelections()) {
          // await fetchReport();
        }
        tempFromDate.value = fromDate.value;
        tempToDate.value = toDate.value;
        fromDate.value = DateTime.tryParse(data.fromDate) ?? fromDate.value;
        toDate.value = DateTime.tryParse(data.toDate) ?? toDate.value;
        if (!hasInitialState) {
          _initialFromDate = fromDate.value;
          _initialToDate = toDate.value;
          _initialBranchId = selectedBranchId.value;
          _initialStaffId = selectedStaffId.value;
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
    // Restore the exact initial state from the first report response.
    // Falls back to the applied/default values when the snapshot isn't
    // ready yet.
    tempFromDate.value = _initialFromDate ?? fromDate.value;
    tempToDate.value = _initialToDate ?? toDate.value;
    tempBranchId.value =
        _initialBranchId ??
        (isOwner
            ? _idOf(_firstRealOption(branches))
            : userBranchId?.toString());
    tempStaffId.value =
        _initialStaffId ?? _idOf(_firstRealOption(staffs));
  }

  /// Applies the temp filter, closes the sheet gracefully, then refetches.
  void applyFilterAndClose() {
    applyFilter();
    Get.back();
  }

  /// Resets temp fields to the initial API state, applies them to the
  /// report, closes the sheet gracefully, then refetches.
  void resetFilterAndClose() {
    resetFilter();
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchId.value = tempBranchId.value;
    selectedStaffId.value = tempStaffId.value;
    Get.back();
    fetchReport();
  }

  /// Called when the branch changes inside the open filter sheet: clears
  /// the selected staff, refreshes the staff list via the lookups API
  /// (`/data/staffs?branch_id=N`), and keeps the staff dropdown
  /// unselectable with a loader until the fetch completes. The report API
  /// is never hit here — only Apply refetches the report.
  Future<void> onTempBranchChanged(String? branchId) async {
    tempBranchId.value = branchId;
    tempStaffId.value = null;
    if (isTempStaffsLoading.value) return;
    final branchParam = int.tryParse(
      (isOwner ? branchId : userBranchId?.toString()) ?? '',
    );
    if (branchParam == null) return;
    isTempStaffsLoading.value = true;
    try {
      final response = await _network.getRaw(
        endpoint: ApiPath.lookupStaffs(branchParam),
      );
      if (response.isCompleted && response.data is List) {
        final items = (response.data as List)
            .whereType<Map>()
            .map((e) => DropdownOption.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        // Swap only the staff options for the sheet; the applied report
        // state stays untouched until Apply.
        final data = apiResponse.value.data;
        if (data != null) {
          apiResponse.value = ApiResponse.completed(
            data.copyWithStaffs(items),
          );
        }
      }
    } finally {
      isTempStaffsLoading.value = false;
    }
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

  void _applyResponseSelections(CommissionsReportResponse data) {
    final backendBranchId = data.branchId?.toString();
    final backendBranch = backendBranchId == null
        ? null
        : data.branches.firstWhereOrNull(
            (branch) => branch.value.toString() == backendBranchId,
          );
    if (backendBranch != null) {
      final id = _idOf(backendBranch);
      selectedBranchId.value = id;
      tempBranchId.value = id;
    }

    final backendStaffId = data.staffId?.trim();
    final backendStaff = backendStaffId == null
        ? null
        : data.staffs.firstWhereOrNull(
            (staff) => staff.value.toString() == backendStaffId,
          );
    if (backendStaff != null) {
      final id = _idOf(backendStaff);
      selectedStaffId.value = id;
      tempStaffId.value = id;
    }
  }

  /// Selects the first branch (owner only — non-owner stays scoped to their
  /// own branch) and applies the API's staff selection once the lists arrive.
  /// Falls back to the first real staff when the API does not return one.
  /// Returns true when a selection changed (caller refetches once).
  bool _applyDefaultSelections() {
    var changed = false;
    if ((selectedBranchId.value == null || selectedBranchId.value!.isEmpty) &&
        isOwner) {
      final id = _idOf(_firstRealOption(branches));
      if (id != null) {
        selectedBranchId.value = id;
        tempBranchId.value = id;
        changed = true;
      }
    }
    if (selectedStaffId.value == null || selectedStaffId.value!.isEmpty) {
      final backendStaffId = apiResponse.value.data?.staffId?.trim();
      final backendStaff = backendStaffId == null
          ? null
          : staffs.firstWhereOrNull(
              (staff) => staff.value.toString() == backendStaffId,
            );
      final id = _idOf(backendStaff ?? _firstRealOption(staffs));
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
    String fmt(DateTime? d, String fallback) =>
        d == null ? fallback : DateFormat('yyyy-MM-dd').format(d);
    Get.toNamed(
      Routes.COMMISSIONS_DETAIL,
      parameters: {
        'branch_id': row.branchId.toString(),
        'from_date': fmt(fromDate.value, row.from),
        'to_date': fmt(toDate.value, row.to),
        // Always forward staff_id: 'all' when nothing is selected.
        'staff_id': (staffId == null || staffId.isEmpty) ? 'all' : staffId,
      },
    );
  }
}
