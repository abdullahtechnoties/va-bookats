import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/controller/package_revenue_report_controller.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/views/widgets/package_column_selector_sheet.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/views/widgets/package_filter_sheet.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/views/widgets/package_revenue_table.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageRevenueReportView extends GetView<PackageRevenueReportController> {
  const PackageRevenueReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
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
          onRefresh: controller.refreshReport,
          color: AppColors.primary,
          child: Column(
            children: [
              _buildFilters(context),
              const SizedBox(height: 12),
              _buildColumnSelector(context),
              const SizedBox(height: 16),
              Expanded(child: _buildTable(context)),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────
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
          child: const Icon(Icons.chevron_left,
              color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        'packageRevenue.title'.trns(),
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
            child: const Icon(Icons.filter_alt_outlined,
                color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }

  // ── Filters Row ───────────────────────────────────────────────────────
  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Date range + Filter button
          Row(
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
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: Color(0xFF9CA3AF)),
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
                    'packageRevenue.filter.filterBtn'.trns(),
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
          const SizedBox(height: 12),
          // Package dropdown (always visible)
          Obx(() => GestureDetector(
                onTap: () => _showPackagePicker(context),
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
                      const Icon(Icons.inventory_2_outlined,
                          size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.selectedPackageLabel.value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ── Column Selector ───────────────────────────────────────────────────
  Widget _buildColumnSelector(BuildContext context) {
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
                  const Icon(Icons.calendar_view_week_outlined,
                      size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'packageRevenue.columns.selected'.trns()} (${controller.selectedColumnCount})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          )),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────
  Widget _buildTable(BuildContext context) {
    return Obx(() {
      final rows = controller.monthlyData;
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PackageRevenueTableWidget(
              controller: controller,
              rows: rows,
            ),
          ),
        ),
      );
    });
  }

  // ── Empty State ───────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: AppColors.black.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'packageRevenue.empty.title'.trns(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'packageRevenue.empty.message'.trns(),
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

  // ── Sheet Openers ─────────────────────────────────────────────────────
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => PackageFilterSheet(controller: controller),
    );
  }

  void _openColumnSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => PackageColumnSelectorSheet(controller: controller),
    );
  }

  void _showPackagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PackagePickerSheet(controller: controller),
    );
  }
}

// ── Package Picker Sheet ──────────────────────────────────────────────────
class _PackagePickerSheet extends StatelessWidget {
  final PackageRevenueReportController controller;
  const _PackagePickerSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'packageRevenue.filter.selectPackage'.trns(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final packages = controller.packages;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final pkg = packages[index];
                final isSelected =
                    controller.selectedPackageId.value == pkg.value;
                return ListTile(
                  title: Text(
                    pkg.label,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isSelected ? AppColors.primary : AppColors.black,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 20)
                      : null,
                  onTap: () {
                    controller.selectedPackageId.value = pkg.value;
                    controller.selectedPackageLabel.value = pkg.label;
                    controller.fetchReport();
                    Get.back();
                  },
                );
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}