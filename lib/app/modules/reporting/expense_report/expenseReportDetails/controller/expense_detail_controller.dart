import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_detail_response_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_item_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/repo/expense_report_repository.dart';
import 'package:va_bookats/network/response/pagination_helper.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ExpenseDetailController extends GetxController {
  final ExpenseReportRepository _repository = ExpenseReportRepository();

  // ── Arguments ───────────────────────────────────────────────────────────
  late final int branchId;
  late final String expenseCategoryId;
  late final String fromDate;
  late final String toDate;
  late final String branchName;

  // ── State ───────────────────────────────────────────────────────────────
  final Rx<Status> status = Status.loading.obs;
  final RxString errorMessage = ''.obs;

  // ── Data ────────────────────────────────────────────────────────────────
  final Rx<BranchDetailModel?> branch = Rx<BranchDetailModel?>(null);
  final RxList<ExpenseItemModel> expenses = <ExpenseItemModel>[].obs;
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);

  // ── Pagination ──────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;

  bool get hasNextPage => paginationMeta.value?.hasNextPage ?? false;
  bool get hasPrevPage => currentPage.value > 1;
  int get totalPages => paginationMeta.value?.lastPage ?? 1;

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchExpenseDetails();
  }

  void _extractArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    branchId = args['branchId'] as int? ?? 0;
    expenseCategoryId = args['expenseCategoryId'] as String? ?? 'all';
    fromDate = args['fromDate'] as String? ?? '';
    toDate = args['toDate'] as String? ?? '';
    branchName = args['branchName'] as String? ?? '';
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
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month]}/${parsed.day}/${parsed.year}';
  }
}
