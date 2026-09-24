import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/branch_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_category_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_monthly_data_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/repo/expense_report_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/report_column_selector_sheet.dart';

class ExpenseColumn {
  final String key;
  final String labelKey;
  final double width;
  bool isSelected;

  ExpenseColumn({
    required this.key,
    required this.labelKey,
    this.width = 130,
    this.isSelected = true,
  });

  String get label => labelKey.trns();
}

class ExpenseReportController extends GetxController {
  final ExpenseReportRepository _repository = ExpenseReportRepository();
  final AuthService _auth = Get.find<AuthService>();

  // ── State ───────────────────────────────────────────────────────────────
  final Rx<Status> status = Status.loading.obs;
  final RxString errorMessage = ''.obs;

  // ── Data ────────────────────────────────────────────────────────────────
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<ExpenseCategoryModel> expenseCategories =
      <ExpenseCategoryModel>[].obs;
  final RxList<ExpenseMonthlyDataModel> monthlyData =
      <ExpenseMonthlyDataModel>[].obs;

  // ── Filter State ────────────────────────────────────────────────────────
  final Rx<DateTime> fromDate = DateTime.now()
      .subtract(const Duration(days: 30))
      .obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  /// Multi-select filters (stringified ids; empty = All).
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxSet<String> selectedCategoryIds = <String>{}.obs;

  // Temp filter (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final RxSet<String> tempBranchIds = <String>{}.obs;
  final RxSet<String> tempCategoryIds = <String>{}.obs;

  List<ReportOption> get branchFilterOptions => branches
      .map((b) => ReportOption(label: b.label, value: b.value.toString()))
      .toList();

  List<ReportOption> get categoryFilterOptions => expenseCategories
      .map((c) => ReportOption(label: c.label, value: c.value.toString()))
      .toList();

  String get branchFilterDisplay => multiSelectDisplay(
    selected: selectedBranchIds,
    options: branchFilterOptions,
    allLabel: 'expense.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get categoryFilterDisplay => multiSelectDisplay(
    selected: selectedCategoryIds,
    options: categoryFilterOptions,
    allLabel: 'expense.filter.allCategories'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempBranchFilterDisplay => multiSelectDisplay(
    selected: tempBranchIds,
    options: branchFilterOptions,
    allLabel: 'expense.filter.allBranches'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  String get tempCategoryFilterDisplay => multiSelectDisplay(
    selected: tempCategoryIds,
    options: categoryFilterOptions,
    allLabel: 'expense.filter.allCategories'.trns(),
    selectedSuffix: 'reports.common.selected'.trns(),
  );

  // ── Column Selector ─────────────────────────────────────────────────────
  final RxList<ExpenseColumn> allColumns = <ExpenseColumn>[
    ExpenseColumn(
      key: 'branchName',
      labelKey: 'expense.columns.branch',
      width: 180,
      isSelected: true,
    ),
    ExpenseColumn(
      key: 'from',
      labelKey: 'expense.columns.from',
      width: 130,
      isSelected: true,
    ),
    ExpenseColumn(
      key: 'to',
      labelKey: 'expense.columns.to',
      width: 130,
      isSelected: true,
    ),
    ExpenseColumn(
      key: 'totalExpense',
      labelKey: 'expense.columns.totalExpense',
      width: 140,
      isSelected: true,
    ),
    ExpenseColumn(
      key: 'expenseCategoryId',
      labelKey: 'expense.columns.category',
      width: 160,
      isSelected: false,
    ),
  ].obs;

  /// Set-based column selection backing the shared selector sheet.
  /// Initialized once per sheet open (never inside build).
  final RxSet<String> selectedColumnKeys = <String>{
    'branchName',
    'from',
    'to',
    'totalExpense',
  }.obs;
  final RxSet<String> tempColumnKeys = <String>{}.obs;

  List<ReportColumnOption> get columnOptions => allColumns
      .map((c) => ReportColumnOption(key: c.key, label: c.label))
      .toList();

  // ── Computed ────────────────────────────────────────────────────────────
  List<ExpenseColumn> get selectedColumns =>
      allColumns.where((c) => c.isSelected).toList();

  int get selectedColumnCount => selectedColumns.length;

  String get dateRangeLabel =>
      '${reportHumanDate(fromDate.value)} - ${reportHumanDate(toDate.value)}';

  bool get isOwner => _auth.isOwner;

  // For display
  String get selectedBranchLabel => branchFilterDisplay;

  String get selectedCategoryLabel => categoryFilterDisplay;

  @override
  void onInit() {
    super.onInit();
    fetchExpenseReport();
  }

  // ── API Calls ───────────────────────────────────────────────────────────
  Future<void> fetchExpenseReport() async {
    status.value = Status.loading;

    final List<String>? branchIds;
    if (isOwner) {
      branchIds = selectedBranchIds.isEmpty ? null : selectedBranchIds.toList();
    } else {
      final userBranch = _auth.currentUser.value?.branchId;
      branchIds = userBranch == null ? null : [userBranch.toString()];
    }

    final response = await _repository.fetchExpenseReport(
      branchIds: branchIds,
      expenseCategoryIds: selectedCategoryIds.isEmpty
          ? null
          : selectedCategoryIds.toList(),
      fromDate: _apiDateFormat(fromDate.value),
      toDate: _apiDateFormat(toDate.value),
    );

    if (response.isCompleted && response.data != null) {
      final data = response.data!;
      branches.value = data.branches;
      expenseCategories.value = data.expenseCategories;
      monthlyData.value = data.monthlyData;

      status.value = Status.completed;
    } else {
      errorMessage.value = response.message ?? 'errors.fetchFailed'.trns();
      status.value = Status.error;
    }
  }

  Future<void> refreshData() async {
    await fetchExpenseReport();
  }

  // ── Filter Actions ──────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    initTempMulti(tempBranchIds, selectedBranchIds);
    initTempMulti(tempCategoryIds, selectedCategoryIds);
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranchIds.assignAll(tempBranchIds);
    selectedCategoryIds.assignAll(tempCategoryIds);
    fetchExpenseReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempBranchIds.clear();
    tempCategoryIds.clear();
  }

  // ── Column Selector Actions ─────────────────────────────────────────────
  void initTempColumns() {
    initTempMulti(tempColumnKeys, selectedColumnKeys);
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

  void selectAllColumns() {
    tempColumnKeys.assignAll(allColumns.map((c) => c.key));
  }

  void resetColumnSelection() {
    tempColumnKeys.assignAll(const [
      'branchName',
      'from',
      'to',
      'totalExpense',
    ]);
  }

  void applyColumnSelection() {
    selectedColumnKeys.assignAll(tempColumnKeys);
    for (final c in allColumns) {
      c.isSelected = selectedColumnKeys.contains(c.key);
    }
    allColumns.refresh();
  }

  void openColumnSelector(BuildContext context) {
    initTempColumns();
    ReportColumnSelectorSheet.show(
      context: context,
      title: 'expense.columns.title'.trns(),
      columns: columnOptions,
      tempSelected: tempColumnKeys,
      onApply: applyColumnSelection,
      onReset: resetColumnSelection,
      onSelectAll: selectAllColumns,
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────
  void navigateToDetails(ExpenseMonthlyDataModel data) {
    Get.toNamed(
      Routes.EXPENSE_DETAIL,
      arguments: {
        'branchId': data.branchId,
        'expenseCategoryId': data.expenseCategoryId,
        'fromDate': data.from,
        'toDate': data.to,
        'branchName': data.branchName,
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  String getCellValue(ExpenseMonthlyDataModel row, String key) {
    switch (key) {
      case 'branchName':
        return row.branchName;
      case 'from':
        return _formatDate(DateTime.tryParse(row.from) ?? DateTime.now());
      case 'to':
        return _formatDate(DateTime.tryParse(row.to) ?? DateTime.now());
      case 'totalExpense':
        return '\$${row.totalExpense.toStringAsFixed(2)}';
      case 'expenseCategoryId':
        return row.expenseCategoryId == 'all'
            ? 'All Categories'
            : row.expenseCategoryId;
      default:
        return '-';
    }
  }

  String _formatDate(DateTime date) => reportHumanDate(date);

  String _apiDateFormat(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
