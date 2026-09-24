import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/controllers/product_revenue_report_controller.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/views/widgets/product_filter_sheet.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/views/widgets/product_revenue_table.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ProductRevenueReportView extends GetView<ProductRevenueReportController> {
  const ProductRevenueReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
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

        return _buildContent(context);
      }),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────
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
          child: const Icon(Icons.chevron_left, color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        'reports.product.title'.trns(),
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

  // ── Content ────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshReport,
      color: AppColors.primary,
      child: Column(
        children: [
          _buildFilterRow(context),
          const SizedBox(height: 12),
          _buildColumnSelectorRow(context),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final data = controller.report?.monthlyData ?? [];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductRevenueTableWidget(
                      controller: controller,
                      rows: data,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Filter Row ─────────────────────────────────────────────────────────
  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Container(
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
                )),
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
                'reports.product.filter.title'.trns(),
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

  // ── Column Selector Row ────────────────────────────────────────────────
  Widget _buildColumnSelectorRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => GestureDetector(
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
                      '${'reports.product.columns.selected'.trns()} (${controller.selectedColumnCount})',
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
          )),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────
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
            'reports.product.empty.title'.trns(),
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
              'reports.product.empty.message'.trns(),
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
            'reports.product.error.title'.trns(),
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
              controller.reportResponse.value.message ?? 'reports.product.error.message'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.fetchReport,
            icon: const Icon(Icons.refresh, color: AppColors.white),
            label: Text(
              'reports.product.error.retry'.trns(),
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

  // ── Sheet Openers ──────────────────────────────────────────────────────
  void _openFilterSheet(BuildContext context) {
    ProductFilterSheet.show(context, controller);
  }

  void _openColumnSelector(BuildContext context) {
    controller.openColumnSelector(context);
  }
}