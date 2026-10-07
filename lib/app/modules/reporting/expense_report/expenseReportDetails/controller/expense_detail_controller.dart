import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_detail_response_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_item_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/repo/expense_report_repository.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ExpenseDetailController extends GetxController {
  final ExpenseReportRepository _repository = ExpenseReportRepository();

  // ── Arguments ───────────────────────────────────────────────────────────
  late final int branchId;
  late final String expenseCategoryId;
  late final String fromDate;
  late final String toDate;
  late final String branchName;

  /// Exact period total passed from the monthly row (previous page).
  /// Falls back to the sum of loaded items when absent.
  double? totalExpenseArg;

  // ── State ───────────────────────────────────────────────────────────────
  final Rx<Status> status = Status.loading.obs;
  final RxString errorMessage = ''.obs;

  // ── Data ────────────────────────────────────────────────────────────────
  final Rx<BranchDetailModel?> branch = Rx<BranchDetailModel?>(null);
  final RxList<ExpenseItemModel> expenses = <ExpenseItemModel>[].obs;
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);
  final RxString responseFromDate = ''.obs;
  final RxString responseToDate = ''.obs;

  String get summaryFrom =>
      responseFromDate.value.isNotEmpty ? responseFromDate.value : fromDate;
  String get summaryTo =>
      responseToDate.value.isNotEmpty ? responseToDate.value : toDate;

  // ── Pagination ──────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;

  bool get hasNextPage => paginationMeta.value?.hasNextPage ?? false;
  bool get hasPrevPage => currentPage.value > 1;
  int get totalPages => paginationMeta.value?.lastPage ?? 1;
  bool get showPagination => hasNextPage || hasPrevPage;

  /// Branch / from / to shown in the summary table. The details response
  /// carries the authoritative range; navigation arguments are fallback.
  String get summaryBranch {
    final name = branch.value?.name ?? '';
    return name.isNotEmpty ? name : branchName;
  }

  /// Period total for the summary table: exact value from the previous
  /// page when available, otherwise the sum of loaded items.
  double get summaryTotalExpense {
    if (totalExpenseArg != null) return totalExpenseArg!;
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchExpenseDetails();
  }

  void _extractArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    branchId = int.tryParse(args['branchId']?.toString() ?? '0') ?? 0;
    expenseCategoryId = args['expenseCategoryId']?.toString() ?? 'all';
    fromDate = args['fromDate']?.toString() ?? '';
    toDate = args['toDate']?.toString() ?? '';
    branchName = args['branchName']?.toString() ?? '';
    totalExpenseArg = double.tryParse(args['totalExpense']?.toString() ?? '');
  }

  // ── API Calls ───────────────────────────────────────────────────────────
  Future<void> fetchExpenseDetails({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      status.value = Status.loading;
    }

    final response = await _repository.fetchExpenseDetails(
      branchId: branchId,
      expenseCategoryId: expenseCategoryId,
      fromDate: fromDate,
      toDate: toDate,
      page: currentPage.value,
    );

    if (response.isCompleted && response.data != null) {
      final data = response.data!;
      branch.value = data.branch;
      responseFromDate.value = data.fromDate;
      responseToDate.value = data.toDate;

      if (isLoadMore) {
        expenses.addAll(data.expenses);
      } else {
        expenses.value = data.expenses;
      }

      paginationMeta.value = data.paginationMeta;
      status.value = Status.completed;
    } else {
      errorMessage.value = response.message ?? 'errors.fetchFailed'.trns();
      status.value = Status.error;
    }
  }

  Future<void> refreshData() async {
    currentPage.value = 1;
    await fetchExpenseDetails();
  }

  // ── Pagination Actions ──────────────────────────────────────────────────
  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      fetchExpenseDetails(isLoadMore: false);
    }
  }

  void prevPage() {
    if (hasPrevPage) {
      currentPage.value--;
      fetchExpenseDetails(isLoadMore: false);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  String formatDate(String date) {
    if (date.isEmpty) return '';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return reportHumanDate(parsed);
  }

  String formatAmount(double amount) {
    return formatReportCell('total_expense', amount);
  }

  /// Capitalizes the status for display (`active` → `Active`).
  String formatStatus(String status) {
    final s = status.trim();
    if (s.isEmpty) return '-';
    if (s.length == 1) return s.toUpperCase();
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String getCellValue(ExpenseItemModel item, String key) {
    switch (key) {
      case 'name':
        return item.name.isNotEmpty ? item.name : '-';
      case 'category':
        return item.category?.name ?? '-';
      case 'date':
        return formatDate(item.date);
      case 'status':
        return item.status.isNotEmpty ? item.status : '-';
      case 'amount':
        return '${item.branch?.currency?.symbol ?? '\$'} ${formatAmount(item.amount)}';
      default:
        return '-';
    }
  }
}
