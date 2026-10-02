import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/models/branch_comparison_details.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/paymentDetails/controllers/payment_details_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BranchComparisonReportDetailsView
    extends GetView<BranchComparisonReportDetailsController> {
  const BranchComparisonReportDetailsView({super.key});

  // Column definitions: date, creator, approver, status, total amount,
  // total discount, total paid, total balance.
  static const List<_ColDef> _columns = [
    _ColDef(
      key: 'date',
      label: 'branchComparison.details.columns.date',
      width: 120,
    ),
    _ColDef(
      key: 'creator',
      label: 'branchComparison.details.columns.creator',
      width: 140,
    ),
    _ColDef(
      key: 'approver',
      label: 'branchComparison.details.columns.approver',
      width: 140,
    ),
    _ColDef(
      key: 'status',
      label: 'branchComparison.details.columns.status',
      width: 100,
    ),
    _ColDef(
      key: 'total_amount',
      label: 'branchComparison.details.columns.totalAmount',
      width: 130,
    ),
    _ColDef(
      key: 'total_discount',
      label: 'branchComparison.details.columns.totalDiscount',
      width: 130,
    ),
    _ColDef(
      key: 'total_paid',
      label: 'branchComparison.details.columns.totalPaid',
      width: 130,
    ),
    _ColDef(
      key: 'total_balance',
      label: 'branchComparison.details.columns.totalBalance',
      width: 130,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final response = controller.detailsResponse.value;

        if (response.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (response.isError) {
          return _buildErrorState(
            response.message ??
                'branchComparison.errors.fetchDetailsFailed'.trns(),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDetails,
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
                _buildTable(),
                const SizedBox(height: 16),
                _buildPagination(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
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
        'branchComparison.details.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Branch Info Card ─────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    final branch = controller.branch;
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
              _InfoRow(icon: Icons.email_outlined, text: branch.emailPrimary!),
            if (branch.phonePrimary != null)
              _InfoRow(icon: Icons.phone_outlined, text: branch.phonePrimary!),
            if (branch.address != null)
              _InfoRow(icon: Icons.location_on_outlined, text: branch.address!),
            if (controller.dateRangeLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.date_range_outlined,
                text: controller.dateRangeLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Table ────────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Obx(() {
      final rows = controller.dailyClosings;

      if (rows.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text(
              'branchComparison.details.empty'.trns(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(),
                ...rows.asMap().entries.map(
                  (e) => _buildTableRow(e.value, e.key % 2 == 0),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: '#', width: 44, isFirst: true),
          ..._columns.map(
            (c) => _HeaderCell(label: c.label.trns(), width: c.width),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(DailyClosingModel row, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    return Container(
      height: 46,
      color: bg,
      child: Row(
        children: [
          _DataCell(
            width: 44,
            showDivider: true,
            child: Text(
              '${row.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ..._columns.map(
            (c) => _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                controller.getCellValue(row, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pagination ───────────────────────────────────────────────────────────
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

  // ── Error State ──────────────────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'branchComparison.retry'.trns(),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Column definition ─────────────────────────────────────────────────────────
class _ColDef {
  final String key;
  final String label;
  final double width;
  const _ColDef({required this.key, required this.label, required this.width});
}

// ── Table cells ───────────────────────────────────────────────────────────────
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

// ── Pagination Button ─────────────────────────────────────────────────────────
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
