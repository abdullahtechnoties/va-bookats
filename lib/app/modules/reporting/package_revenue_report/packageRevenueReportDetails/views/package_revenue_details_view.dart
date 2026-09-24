import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReportDetails/controller/package_revenue_details_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageRevenueDetailsView
    extends GetView<PackageRevenueDetailsController> {
  const PackageRevenueDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDetails,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

  // ── AppBar ────────────────────────────────────────────────────────────
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
        'packageRevenueDetails.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Branch Card ───────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final branch = controller.branch;
        if (branch == null) return const SizedBox.shrink();

        return Container(
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
              const SizedBox(height: 12),
              if (branch.emailPrimary != null) ...[
                _InfoRow(
                  icon: Icons.email_outlined,
                  text: branch.emailPrimary!,
                ),
                const SizedBox(height: 8),
              ],
              if (branch.phonePrimary != null) ...[
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: branch.phonePrimary!,
                ),
                const SizedBox(height: 8),
              ],
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text:
                    '${controller.formatDate(controller.fromDate)} - ${controller.formatDate(controller.toDate)}',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.inventory_2_outlined,
                text: controller.packageName,
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final rows = controller.dailySummaries;
        return ClipRRect(
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
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: '#', width: 44, isFirst: true),
          _HeaderCell(
            label: 'packageRevenueDetails.table.package'.trns(),
            width: 150,
          ),
          _HeaderCell(
            label: 'packageRevenueDetails.table.customers'.trns(),
            width: 100,
          ),
          _HeaderCell(
            label: 'packageRevenueDetails.table.quantity'.trns(),
            width: 90,
          ),
          _HeaderCell(
            label: 'packageRevenueDetails.table.packageAmount'.trns(),
            width: 140,
          ),
          _HeaderCell(
            label: 'packageRevenueDetails.table.totalAmount'.trns(),
            width: 130,
          ),
          _HeaderCell(
            label: 'packageRevenueDetails.table.discount'.trns(),
            width: 120,
          ),
          _HeaderCell(
            label: 'packageRevenueDetails.table.netRevenue'.trns(),
            width: 130,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(summary, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    final index = controller.dailySummaries.indexOf(summary) + 1;

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
          _DataCell(
            width: 150,
            showDivider: true,
            child: Text(
              summary.package?.name ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _DataCell(
            width: 100,
            showDivider: true,
            child: Text(
              '${summary.totalCustomers}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 90,
            showDivider: true,
            child: Text(
              '${summary.totalQty}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 140,
            showDivider: true,
            child: Text(
              controller.formatCurrency(summary.packageAmount),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 130,
            showDivider: true,
            child: Text(
              controller.formatCurrency(summary.totalAmount),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 120,
            showDivider: true,
            child: Text(
              controller.formatCurrency(summary.totalDiscount),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 130,
            showDivider: false,
            child: Text(
              controller.formatCurrency(summary.netRevenue),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _PaginationBtn(
              label: '« ${'packageRevenueDetails.pagination.previous'.trns()}',
              onTap: controller.currentPage.value > 1
                  ? controller.prevPage
                  : null,
            ),
            const SizedBox(width: 8),
            _PaginationBtn(
              label: '${'packageRevenueDetails.pagination.next'.trns()} »',
              isPrimary: true,
              onTap: controller.hasNextPage ? controller.nextPage : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'packageRevenueDetails.empty.title'.trns(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'packageRevenueDetails.empty.message'.trns(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}

// ── Table Cells ───────────────────────────────────────────────────────────
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

// ── Pagination Button ─────────────────────────────────────────────────────
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
