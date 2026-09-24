import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commisionReportDetails/controller/commissions_detail_controller.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/models/commissions_detail_model.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class CommissionsDetailView extends GetView<CommissionsDetailController> {
  const CommissionsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final status = controller.apiResponse.value.status;

        if (status == Status.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (status == Status.error) {
          return _buildError();
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
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

  // ── AppBar ────────────────────────────────────────────────────────────────
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
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
      title: Text(
        'commissions.detail.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Branch Card ───────────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    final branch = controller.branch;
    if (branch == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const AppCachedImage(
                imageUrl: null,
                width: 70,
                height: 70,
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
                  const SizedBox(height: 4),
                  if (branch.emailPrimary != null)
                    Text(
                      branch.emailPrimary!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  if (branch.phonePrimary != null)
                    Text(
                      branch.phonePrimary!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    controller.dateRangeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────
  Widget _buildTable() {
    final summaries = controller.summaries;

    if (summaries.isEmpty) {
      return _buildEmpty();
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
              ...summaries.asMap().entries.map(
                (e) => _buildTableRow(e.value, e.key % 2 == 0),
              ),
            ],
          ),
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
          _HeaderCell(label: '#', width: 44),
          _HeaderCell(
            label: 'commissions.detail.table.staffName'.trns(),
            width: 140,
          ),
          _HeaderCell(
            label: 'commissions.detail.table.totalServices'.trns(),
            width: 130,
          ),
          _HeaderCell(
            label: 'commissions.detail.table.totalPackages'.trns(),
            width: 130,
          ),
          _HeaderCell(
            label: 'commissions.detail.table.serviceCommission'.trns(),
            width: 150,
          ),
          _HeaderCell(
            label: 'commissions.detail.table.packageCommission'.trns(),
            width: 150,
          ),
          _HeaderCell(
            label: 'commissions.detail.table.totalCommission'.trns(),
            width: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(StaffCommissionSummary row, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    return Container(
      height: 46,
      color: bg,
      child: Row(
        children: [
          _DataCell(
            width: 44,
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
          _DataCell(
            width: 140,
            child: Text(
              row.staff?.name ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _DataCell(
            width: 130,
            child: Text(
              row.totalServices.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 130,
            child: Text(
              row.totalPackages.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 150,
            child: Text(
              '\$${row.serviceCommission}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 150,
            child: Text(
              '\$${row.packageCommission}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
            ),
          ),
          _DataCell(
            width: 150,
            child: Text(
              '\$${row.totalCommission}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return Obx(() {
      final meta = controller.paginationMeta;
      if (meta == null || meta.total <= meta.perPage)
        return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'commissions.detail.pagination.info'.trnsFormat({
                'from': meta.currentPage.toString(),
                'to': meta.lastPage.toString(),
                'total': meta.total.toString(),
              }),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            Row(
              children: [
                _PaginationBtn(
                  label: '« ${'commissions.detail.pagination.previous'.trns()}',
                  onTap: controller.currentPage.value > 1
                      ? controller.prevPage
                      : null,
                ),
                const SizedBox(width: 8),
                _PaginationBtn(
                  label: '${'commissions.detail.pagination.next'.trns()} »',
                  isPrimary: true,
                  onTap: controller.hasNextPage ? controller.nextPage : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.black.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'commissions.detail.empty.title'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'commissions.detail.empty.message'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildError() {
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
            controller.apiResponse.value.message ??
                'commissions.errors.fetchFailed'.trns(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.black),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.onRefresh,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              'commissions.retry'.trns(),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Table Cells ───────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;

  const _HeaderCell({required this.label, required this.width});

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

  const _DataCell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 46,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
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
