import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueDetails/controllers/product_revenue_details_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ProductRevenueDetailsView extends GetView<ProductRevenueDetailsController> {
  const ProductRevenueDetailsView({super.key});

  // Column definitions
  static const List<_ColDef> _columns = [
    _ColDef(key: 'product', label: 'reports.product.details.product', width: 150),
    _ColDef(key: 'quantity', label: 'reports.product.details.quantity', width: 100),
    _ColDef(key: 'unitPrice', label: 'reports.product.details.unitPrice', width: 120),
    _ColDef(key: 'totalAmount', label: 'reports.product.details.totalAmount', width: 130),
    _ColDef(key: 'discount', label: 'reports.product.details.discount', width: 120),
    _ColDef(key: 'netRevenue', label: 'reports.product.details.netRevenue', width: 130),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.hasError) {
          return _buildErrorState();
        }

        if (!controller.hasData) {
          return _buildEmptyState();
        }

        return _buildContent();
      }),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────
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
          child: const Icon(Icons.chevron_left, color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        'reports.product.details.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Content ────────────────────────────────────────────────────────────
  Widget _buildContent() {
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
            _buildProductInfo(),
            const SizedBox(height: 16),
            _buildTable(),
            const SizedBox(height: 16),
            _buildPagination(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Branch Card ────────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    final branch = controller.details!.branch;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.store_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'reports.product.details.branchInfo'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'reports.product.details.branchName'.trns(),
              value: branch.name,
            ),
            if (branch.emailPrimary != null && branch.emailPrimary!.isNotEmpty)
              _InfoRow(
                label: 'reports.product.details.email'.trns(),
                value: branch.emailPrimary!,
              ),
            if (branch.phonePrimary != null && branch.phonePrimary!.isNotEmpty)
              _InfoRow(
                label: 'reports.product.details.phone'.trns(),
                value: branch.phonePrimary!,
              ),
            if (branch.address != null && branch.address!.isNotEmpty)
              _InfoRow(
                label: 'reports.product.details.address'.trns(),
                value: branch.address!,
              ),
          ],
        ),
      ),
    );
  }

  // ── Product Info ───────────────────────────────────────────────────────
  Widget _buildProductInfo() {
    final details = controller.details!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'reports.product.details.productInfo'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'reports.product.details.productName'.trns(),
              value: details.productName,
              valueColor: AppColors.primary,
            ),
            _InfoRow(
              label: 'reports.product.details.dateRange'.trns(),
              value: '${controller.formatDate(details.fromDate)} - ${controller.formatDate(details.toDate)}',
            ),
          ],
        ),
      ),
    );
  }

  // ── Table ──────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final items = controller.items;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(),
                ...items.asMap().entries.map(
                      (e) => _buildTableRow(e.value, e.key % 2 == 0),
                    ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: '#', width: 44, isFirst: true),
          ..._columns.map((c) => _HeaderCell(label: c.label.trns(), width: c.width)),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic item, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    final index = controller.items.indexOf(item) + 1 + ((controller.currentPage.value - 1) * 15);

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
          ..._columns.map(
            (c) => _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                _cellValue(item, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cellValue(dynamic item, String key) {
    switch (key) {
      case 'product':
        return item.product?.name ?? '-';
      case 'quantity':
        return item.quantitySold.toString();
      case 'unitPrice':
        return controller.formatCurrency(item.unitPrice);
      case 'totalAmount':
        return controller.formatCurrency(item.totalAmount);
      case 'discount':
        return controller.formatCurrency(item.totalDiscount);
      case 'netRevenue':
        return controller.formatCurrency(item.netRevenue);
      default:
        return '-';
    }
  }

  // ── Pagination ─────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'reports.product.details.page'.trnsFormat({
                  'current': controller.currentPage.value.toString(),
                  'total': controller.totalPages.toString(),
                }),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  _PaginationBtn(
                    label: '« ${'reports.product.details.previous'.trns()}',
                    onTap: controller.hasPrevPage ? controller.prevPage : null,
                  ),
                  const SizedBox(width: 8),
                  _PaginationBtn(
                    label: '${'reports.product.details.next'.trns()} »',
                    isPrimary: true,
                    onTap: controller.hasNextPage ? controller.nextPage : null,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  // ── Empty State ────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'reports.product.details.empty.title'.trns(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'reports.product.details.empty.message'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'reports.product.details.error.title'.trns(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              controller.detailsResponse.value.message ??
                  'reports.product.details.error.message'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.fetchDetails,
            icon: const Icon(Icons.refresh, color: AppColors.white),
            label: Text(
              'reports.product.details.error.retry'.trns(),
              style: const TextStyle(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor ?? AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
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

  const _ColDef({
    required this.key,
    required this.label,
    required this.width,
  });
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