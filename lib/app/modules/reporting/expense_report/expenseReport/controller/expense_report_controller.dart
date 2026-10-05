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

  String get label =>
      resolveReportColumnLabel('expense.columns', labelKey);
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
  final Rx<BranchModel?> selectedBranch = Rx<BranchModel?>(null);
  final Rx<ExpenseCategoryModel?> selectedExpenseCategory =
      Rx<ExpenseCategoryModel?>(null);

  // Temp filter (for bottom sheet)
  final Rx<DateTime> tempFromDate = DateTime.now().obs;
  final Rx<DateTime> tempToDate = DateTime.now().obs;
  final Rx<BranchModel?> tempSelectedBranch = Rx<BranchModel?>(null);
  final Rx<ExpenseCategoryModel?> tempSelectedExpenseCategory =
      Rx<ExpenseCategoryModel?>(null);

  // ── Column Selector ─────────────────────────────────────────────────────
  // Keys are snake_case to match API `monthlyData` fields, so dynamic
  // discovery never duplicates them. `expense_category_id` is technical
  // and intentionally has no column.
  final RxList<ExpenseColumn> allColumns = <ExpenseColumn>[
    ExpenseColumn(
      key: 'branch_name',
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
      key: 'total_expense',
      labelKey: 'expense.columns.totalExpense',
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
    'total_expense',
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
  String get selectedBranchLabel =>
      selectedBranch.value?.label ?? 'expense.filter.allBranches'.trns();

  String get selectedCategoryLabel =>
      selectedExpenseCategory.value?.label ??
      'expense.filter.allCategories'.trns();

  @override
  void onInit() {
    super.onInit();
    _initializeDefaults();
    fetchExpenseReport();
  }

  void _initializeDefaults() {
    // Set default category to "All"
    selectedExpenseCategory.value = ExpenseCategoryModel(
      label: 'expense.filter.allCategories'.trns(),
      value: 'all',
    );
  }

  // ── API Calls ───────────────────────────────────────────────────────────
  Future<void> fetchExpenseReport() async {
    status.value = Status.loading;

    final branchId = selectedBranch.value?.value ?? _getUserBranchId();
    final categoryId = selectedExpenseCategory.value?.displayValue ?? 'all';

    final response = await _repository.fetchExpenseReport(
      branchId: branchId,
      expenseCategoryId: categoryId,
      fromDate: _apiDateFormat(fromDate.value),
      toDate: _apiDateFormat(toDate.value),
    );

    if (response.isCompleted && response.data != null) {
      final data = response.data!;
      branches.value = data.branches;
      expenseCategories.value = data.expenseCategories;
      monthlyData.value = data.monthlyData;
      syncDynamicColumns();

      // Auto-select first branch if owner and none selected
      if (isOwner && selectedBranch.value == null && branches.isNotEmpty) {
        selectedBranch.value = branches.first;
      }

      status.value = Status.completed;
    } else {
      errorMessage.value = response.message ?? 'errors.fetchFailed'.trns();
      status.value = Status.error;
    }
  }

  Future<void> refreshData() async {
    await fetchExpenseReport();
  }

  int _getUserBranchId() {
    return _auth.currentUser.value?.branchId ?? 1;
  }

  // ── Filter Actions ──────────────────────────────────────────────────────
  void initTempFilter() {
    tempFromDate.value = fromDate.value;
    tempToDate.value = toDate.value;
    tempSelectedBranch.value = selectedBranch.value;
    tempSelectedExpenseCategory.value = selectedExpenseCategory.value;
  }

  void applyFilter() {
    fromDate.value = tempFromDate.value;
    toDate.value = tempToDate.value;
    selectedBranch.value = tempSelectedBranch.value;
    selectedExpenseCategory.value = tempSelectedExpenseCategory.value;
    fetchExpenseReport();
  }

  void resetFilter() {
    tempFromDate.value = DateTime.now().subtract(const Duration(days: 30));
    tempToDate.value = DateTime.now();
    tempSelectedBranch.value = isOwner ? branches.firstOrNull : null;
    tempSelectedExpenseCategory.value = expenseCategories.firstOrNull;
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
      'branch_name',
      'from',
      'to',
      'total_expense',
    ]);
  }

  // ── Dynamic columns ───────────────────────────────────────────────────
  /// Discovers scalar fields present in the API rows and appends them as
  /// opt-in columns. Technical ids (branch_id, expense_category_id, …)
  /// never become columns.
  void syncDynamicColumns() {
    final known = allColumns.map((c) => c.key).toSet();
    final fresh = discoverReportColumns(
      monthlyData.map((r) => r.rawFields),
      known,
    );
    if (fresh.isEmpty) return;
    for (final key in fresh) {
      final label = resolveReportColumnLabel('expense.columns', key);
      allColumns.add(
        ExpenseColumn(
          key: key,
          labelKey: key,
          width: reportColumnWidth(label),
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
        'totalExpense': data.totalExpense,
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  String getCellValue(ExpenseMonthlyDataModel row, String key) {
    switch (key) {
      case 'branch_name':
        return row.branchName;
      case 'from':
        return _formatDate(DateTime.tryParse(row.from) ?? DateTime.now());
      case 'to':
        return _formatDate(DateTime.tryParse(row.to) ?? DateTime.now());
      case 'total_expense':
        return '${row.currencySymbol ?? '\$'} ${row.totalExpense}';
      default:
        // Dynamically discovered columns read straight from the raw row.
        return formatReportCell(key, row.rawFields[key]);
    }
  }

  String _formatDate(DateTime date) => reportHumanDate(date);

  String _apiDateFormat(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
