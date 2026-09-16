// lib/app/modules/service_revenue_report/views/service_revenue_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueDetails/controller/service_revenue_details_controller.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/models/service_revenue_model_detals.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class ServiceRevenueDetailsView extends GetView<ServiceRevenueDetailsController> {
  const ServiceRevenueDetailsView({super.key});

  static const List<_ColDef> _columns = [
    _ColDef(key: 'serviceName', labelKey: 'reports.serviceRevenue.details.serviceName', width: 150),
    _ColDef(key: 'totalCustomers', labelKey: 'reports.serviceRevenue.details.totalCustomers', width: 130),
    _ColDef(key: 'serviceAmount', labelKey: 'reports.serviceRevenue.details.serviceAmount', width: 140),
    _ColDef(key: 'totalAmount', labelKey: 'reports.serviceRevenue.details.totalAmount', width: 130),
    _ColDef(key: 'totalDiscount', labelKey: 'reports.serviceRevenue.details.totalDiscount', width: 140),
    _ColDef(key: 'netRevenue', labelKey: 'reports.serviceRevenue.details.netRevenue', width: 130),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final status = controller.detailResponse.value.status;

        if (status == Status.loading) {
          return _buildLoader();
        }

        if (status == Status.error) {
          return _buildError();
        }

        return _buildContent();
      }),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
        'reports.serviceRevenue.details.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Content ───────────────────────────────────────────────────────────
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshDetails,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildBranchCard(),
            const SizedBox(height: 16),
            if (controller.summaries.isNotEmpty) ...[
              _buildTable(),
              const SizedBox(height: 16),
              _buildPagination(),
            ] else
              _buildEmptyState(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard() {
    return Obx(() {
      final branch = controller.branch;
      if (branch == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppCachedImage(
                  imageUrl: null,
                  width: 90,
                  height: 80,
                  fit: BoxFit.cover,
                  fallbackAsset: 'assets/images/placeholder.png',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    if (controller.detailData?.serviceName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        controller.detailData!.serviceName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (branch.emailPrimary != null)
                    Text(
                      branch.emailPrimary!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  const SizedBox(height: 4),
                  if (branch.phonePrimary != null)
                    Text(
                      branch.phonePrimary!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.formatDate(controller.fromDate)} - ${controller.formatDate(controller.toDate)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTable() {
    return Obx(() {
      final summaries = controller.summaries;
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
                ...summaries.asMap().entries.map(
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
          _HeaderCell(labelKey: 'reports.common.index', width: 44, isFirst: true),
          ..._columns.map((c) => _HeaderCell(labelKey: c.labelKey, width: c.width)),
        ],
      ),
    );
  }

  Widget _buildTableRow(DailyServiceSummary summary, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    final index = controller.summaries.indexOf(summary) + 1;

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
                _cellValue(summary, c.key),
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

  String _cellValue(DailyServiceSummary summary, String key) {
    switch (key) {
      case 'serviceName':
        return summary.service?.name ?? '-';
      case 'totalCustomers':
        return summary.totalCustomers.toString();
      case 'serviceAmount':
        return controller.formatCurrency(summary.serviceAmount);
      case 'totalAmount':
        return controller.formatCurrency(summary.totalAmount);
      case 'totalDiscount':
        return controller.formatCurrency(summary.totalDiscount);
      case 'netRevenue':
        return controller.formatCurrency(summary.netRevenue);
      default:
        return '-';
    }
  }

  Widget _buildPagination() {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'reports.common.page'.trns()} ${controller.currentPage.value} / ${controller.totalPages}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              Row(
                children: [
                  _PaginationBtn(
                    label: '« ${'reports.common.previous'.trns()}',
                    onTap: controller.hasPrevPage ? controller.prevPage : null,
                  ),
                  const SizedBox(width: 8),
                  _PaginationBtn(
                    label: '${'reports.common.next'.trns()} »',
                    onTap: controller.hasNextPage ? controller.nextPage : null,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  // ── States ────────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            'reports.errors.loadFailed'.trns(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshDetails,
            icon: const Icon(Icons.refresh),
            label: Text('reports.actions.retry'.trns()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              'reports.empty.details'.trns(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table Components ──────────────────────────────────────────────────────────
class _ColDef {
  final String key;
  final String labelKey;
  final double width;
  const _ColDef({required this.key, required this.labelKey, required this.width});
}

class _HeaderCell extends StatelessWidget {
  final String labelKey;
  final double width;
  final bool isFirst;

  const _HeaderCell({required this.labelKey, required this.width, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.white.withValues(alpha: 0.25), width: 0.5),
        ),
      ),
      child: Text(
        labelKey.trns(),
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

  const _DataCell({required this.width, required this.child, required this.showDivider});

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

class _PaginationBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _PaginationBtn({required this.label, required this.onTap, this.isPrimary = false});

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