import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/controllers/branch_comparison_controller.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/views/Widgets/bcomp-filter-sheet.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/branchComparison/views/Widgets/bcomp-table.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class BranchComparisonReportView
    extends GetView<BranchComparisonReportController> {
  const BranchComparisonReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: Obx(() {
        final response = controller.reportResponse.value;

        if (response.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (response.isError) {
          return _buildErrorState(
            response.message ?? 'branchComparison.errors.fetchFailed'.trns(),
          );
        }

        if (controller.items.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshReport,
          color: AppColors.primary,
          child: Column(
            children: [
              _buildFilterRow(context),
              const SizedBox(height: 12),
              _buildColumnSelectorRow(context),
              const SizedBox(height: 16),
              Expanded(child: _buildTableSection()),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
        'branchComparison.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _openFilterSheet(context),
            child: const Icon(
              Icons.filter_alt_outlined,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ── Date Range + Filter Button ───────────────────────────────────────────
  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.black.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.dateRangeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _openFilterSheet(context),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'branchComparison.filter.title'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Column Selector Row ──────────────────────────────────────────────────
  Widget _buildColumnSelectorRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => GestureDetector(
          onTap: () => _openColumnSelector(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_view_week_outlined,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${'branchComparison.columns.selected'.trns()} (${controller.selectedColumnCount})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Table Section ────────────────────────────────────────────────────────
  Widget _buildTableSection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(
          () => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BranchComparisonTable(
              controller: controller,
              items: controller.items,
            ),
          ),
        ),
      ),
    );
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
            onPressed: controller.refreshReport,
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

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, color: Color(0xFF9CA3AF), size: 60),
          const SizedBox(height: 16),
          Text(
            'branchComparison.empty'.trns(),
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ── Sheet Openers ────────────────────────────────────────────────────────
  void _openFilterSheet(BuildContext context) {
    BranchComparisonFilterSheet.show(context, controller);
  }

  void _openColumnSelector(BuildContext context) {
    controller.openColumnSelector(context);
  }
}
