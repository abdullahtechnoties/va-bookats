import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/models/expense_item_model.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReportDetails/controller/expense_detail_controller.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class ExpenseDetailView extends GetView<ExpenseDetailController> {
  const ExpenseDetailView({super.key});

  // Summary table: branch, from, to, total expense.
  static const List<_ColDef> _summaryColumns = [
    _ColDef(key: 'branch', label: 'expense.detail.summary.branch', width: 150),
    _ColDef(key: 'from', label: 'expense.detail.summary.from', width: 120),
    _ColDef(key: 'to', label: 'expense.detail.summary.to', width: 120),
    _ColDef(
      key: 'total_expense',
      label: 'expense.detail.summary.totalExpense',
      width: 140,
    ),
  ];

  // Items table: bill, name, category, date, status, amount.
  static const List<_ColDef> _columns = [
    _ColDef(key: 'bill', label: 'expense.detail.table.bill', width: 80),
    _ColDef(key: 'name', label: 'expense.detail.table.name', width: 150),
    _ColDef(key: 'category', label: 'expense.detail.table.category', width: 130),
    _ColDef(key: 'date', label: 'expense.detail.table.date', width: 120),
    _ColDef(key: 'status', label: 'expense.detail.table.status', width: 120),
    _ColDef(key: 'amount', label: 'expense.detail.table.amount', width: 130),
  ];

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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildBranchCard(),
            const SizedBox(height: 16),
            _buildSummaryTable(),
            const SizedBox(height: 16),
            _buildExpensesTable(),
            const SizedBox(height: 16),
            _buildPagination(),
            const SizedBox(height: 24),
          ],
        ),
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
          width: double.infinity,
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

  // ── Summary Table (branch / from / to / total expense) ─────────────────
  Widget _buildSummaryTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(_summaryColumns),
                _buildSummaryRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      height: 46,
      color: AppColors.white,
      child: Row(
        children: [
          _DataCell(
            width: 44,
            showDivider: true,
            child: const Text(
              '1',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          _DataCell(
            width: 150,
            showDivider: true,
            child: Text(
              controller.summaryBranch.isNotEmpty
                  ? controller.summaryBranch
                  : '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _DataCell(
            width: 120,
            showDivider: true,
            child: Text(
              controller.formatDate(controller.summaryFrom),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _DataCell(
            width: 120,
            showDivider: true,
            child: Text(
              controller.formatDate(controller.summaryTo),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _DataCell(
            width: 140,
            showDivider: false,
            child: Text(
              controller.formatAmount(controller.summaryTotalExpense),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Expenses Table ──────────────────────────────────────────────────────
  Widget _buildExpensesTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final expenses = controller.expenses;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(_columns),
                ...expenses.asMap().entries.map(
                  (e) => _buildTableRow(e.value, e.key % 2 == 0),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<_ColDef> columns) {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: '#', width: 44, isFirst: true),
          ...columns.map(
            (c) => _HeaderCell(label: c.label.trns(), width: c.width),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ExpenseItemModel expense, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    final index = controller.expenses.indexOf(expense) + 1;

    return Container(
      height: 46,
      color: bg,
      child: Row(
        children: [
          _DataCell(
            width: 44,
            showDivider: true,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ..._columns.map((c) {
            if (c.key == 'bill') {
              final fullUrl = expense.billUrl ?? expense.billThumbUrl;
              return _DataCell(
                width: c.width,
                showDivider: true,
                child: _BillThumb(
                  imageUrl: expense.billThumbUrl ?? expense.billUrl,
                  onTap: fullUrl != null
                      ? () => _showBillDialog(fullUrl)
                      : null,
                ),
              );
            }
            if (c.key == 'status') {
              return _DataCell(
                width: c.width,
                showDivider: true,
                child: _StatusPill(
                  label: controller.formatStatus(expense.status),
                  status: expense.status,
                ),
              );
            }
            return _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                controller.getCellValue(expense, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Pagination ──────────────────────────────────────────────────────────
  // Shown only when there is a previous or next page, centered.
  Widget _buildPagination() {
    return Obx(() {
      if (!controller.showPagination) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PaginationBtn(
              label: '« ${'reports.common.previous'.trns()}',
              onTap: controller.hasPrevPage ? controller.prevPage : null,
            ),
            const SizedBox(width: 8),
            _PaginationBtn(
              label: '${'reports.common.next'.trns()} »',
              isPrimary: true,
              onTap: controller.hasNextPage ? controller.nextPage : null,
            ),
          ],
        ),
      );
    });
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

// ── Column Definition ───────────────────────────────────────────────────────
class _ColDef {
  final String key;
  final String label;
  final double width;

  const _ColDef({required this.key, required this.label, required this.width});
}

// ── Table Cells ─────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final bool isFirst;

  const _HeaderCell({
    required this.label,
    required this.width,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.white.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final double width;
  final Widget child;
  final bool showDivider;

  const _DataCell({
    required this.width,
    required this.child,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 46,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: showDivider
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)
              : BorderSide.none,
          bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: child,
    );
  }
}

// ── Bill Thumbnail Cell ─────────────────────────────────────────────────────
class _BillThumb extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const _BillThumb({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Text(
        '-',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: Color(0xFF374151)),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppCachedImage(
          imageUrl: imageUrl,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ── Status Pill ─────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String label;
  final String status;

  const _StatusPill({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    late final Color bg;
    late final Color fg;
    switch (s) {
      case 'active':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'pending':
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F00);
        break;
      case 'inactive':
      case 'rejected':
        bg = const Color(0xFFFDECEA);
        fg = const Color(0xFFC62828);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Bill Expand Dialog ──────────────────────────────────────────────────────
void _showBillDialog(String imageUrl) {
  Get.dialog(
    Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppCachedImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0x80000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
