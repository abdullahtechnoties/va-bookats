// lib/app/modules/service_revenue_report/views/service_revenue_report_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_controller.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/views/widgets/service_revenue_filter_sheet.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'widgets/service_revenue_table.dart';

class ServiceRevenueReportView extends GetView<ServiceRevenueReportController> {
  const ServiceRevenueReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final status = controller.reportResponse.value.status;

        if (status == Status.loading) {
          return _buildLoader();
        }

        if (status == Status.error) {
          return _buildError();
        }

        if (controller.monthlyData.isEmpty) {
          return _buildEmptyState();
        }

        return _buildContent();
      }),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────
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
        'reports.serviceRevenue.title'.trns(),
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
            onTap: () => _openFilterSheet(Get.context!),
            child: const Icon(Icons.filter_alt_outlined, color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }

  // ── Content ───────────────────────────────────────────────────────────
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshReport,
      color: AppColors.primary,
      child: Column(
        children: [
          _buildFilterRow(),
          const SizedBox(height: 12),
          _buildColumnSelectorRow(),
          const SizedBox(height: 16),
          Expanded(child: _buildTable()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
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
                    border: Border.all(color: AppColors.black.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF9CA3AF)),
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
            onTap: () => _openFilterSheet(Get.context!),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'reports.filter.title'.trns(),
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

  Widget _buildColumnSelectorRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => GestureDetector(
            onTap: () => _openColumnSelector(Get.context!),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.black.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.view_column_outlined, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'reports.columns.selected'.trns()} (${controller.selectedColumnCount})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildTable() {
    return Obx(() {
      final data = controller.monthlyData;
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ServiceRevenueTable(
              controller: controller,
              data: data,
            ),
          ),
        ),
      );
    });
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
          const SizedBox(height: 8),
          Text(
            controller.reportResponse.value.message ?? 'reports.errors.tryAgain'.trns(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.refreshReport,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            'reports.empty.title'.trns(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'reports.empty.message'.trns(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ── Sheet Openers ─────────────────────────────────────────────────────
  void _openFilterSheet(BuildContext context) {
    ServiceRevenueFilterSheet.show(context, controller);
  }

  void _openColumnSelector(BuildContext context) {
    controller.openColumnSelector(context);
  }
}