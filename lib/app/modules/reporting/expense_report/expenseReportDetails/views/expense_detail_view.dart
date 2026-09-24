import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReportDetails/controller/expense_detail_controller.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class ExpenseDetailView extends GetView<ExpenseDetailController> {
  const ExpenseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.status.value == Status.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.status.value == Status.error) {
          return _buildErrorState();
        }

        if (controller.expenses.isEmpty) {
          return _buildEmptyState();
        }

        return _buildContent(context);
      }),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
      title: Text(
        'expense.detail.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Content ─────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppColors.primary,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildBranchCard(),
                  const SizedBox(height: 16),
                  _buildExpensesList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildPagination(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Branch Card ─────────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    return Obx(() {
      final branch = controller.branch.value;
      if (branch == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branch.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              if (branch.emailPrimary != null)
                Text(
                  branch.emailPrimary!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              if (branch.phonePrimary != null)
                Text(
                  branch.phonePrimary!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${controller.formatDate(controller.fromDate)} - ${controller.formatDate(controller.toDate)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Expenses List ───────────────────────────────────────────────────────
  Widget _buildExpensesList() {
    return Obx(() {
      final expenses = controller.expenses;
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: expenses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return _ExpenseCard(expense: expense, controller: controller);
        },
      );
    });
  }

  // ── Pagination ──────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _PaginationBtn(
              label: '« Previous',
              onTap: controller.hasPrevPage ? controller.prevPage : null,
            ),
            const Spacer(),
            Text(
              '${controller.currentPage.value} / ${controller.totalPages}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            _PaginationBtn(
              label: 'Next »',
              isPrimary: true,
              onTap: controller.hasNextPage ? controller.nextPage : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.fetchExpenseDetails,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('expense.retry'.trns()),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'expense.detail.empty'.trns(),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// ── Expense Card ────────────────────────────────────────────────────────────
class _ExpenseCard extends StatelessWidget {
  final expense;
  final ExpenseDetailController controller;

  const _ExpenseCard({required this.expense, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Bill Image
          if (expense.billThumbUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppCachedImage(
                imageUrl: expense.billThumbUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 12),
          // Expense Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.category?.name ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatDate(expense.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pagination Button ───────────────────────────────────────────────────────
class _PaginationBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _PaginationBtn({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? (isPrimary ? AppColors.primary : const Color(0xFFD1D5DB))
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: enabled
                ? (isPrimary ? AppColors.primary : const Color(0xFF374151))
                : const Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }
}
