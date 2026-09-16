// lib/app/modules/service_revenue_report/views/widgets/service_revenue_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class ServiceRevenueFilterSheet extends StatelessWidget {
  final ServiceRevenueReportController controller;

  const ServiceRevenueFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.initTempFilter();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFromDate(context),
          const SizedBox(height: 16),
          _buildToDate(context),
          if (controller.showBranchFilter) ...[
            const SizedBox(height: 16),
            _buildBranches(context),
          ],
          const SizedBox(height: 16),
          _buildServices(context),
          const SizedBox(height: 32),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'reports.filter.title'.trns(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.close, color: AppColors.black, size: 22),
        ),
      ],
    );
  }

  Widget _buildFromDate(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'reports.filter.fromDate'.trns(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Obx(() => _DateField(
              value: controller.tempFromDate.value,
              onTap: () async {
                final picked = await _pickDate(context, controller.tempFromDate.value);
                if (picked != null) controller.tempFromDate.value = picked;
              },
            )),
      ],
    );
  }

  Widget _buildToDate(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'reports.filter.toDate'.trns(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Obx(() => _DateField(
              value: controller.tempToDate.value,
              onTap: () async {
                final picked = await _pickDate(context, controller.tempToDate.value);
                if (picked != null) controller.tempToDate.value = picked;
              },
            )),
      ],
    );
  }

  Widget _buildBranches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'reports.filter.branch'.trns(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedLabel = controller.tempBranchId.value == null
              ? 'reports.filter.allBranches'.trns()
              : controller.branches
                      .firstWhereOrNull((b) => b.value == controller.tempBranchId.value)
                      ?.label ??
                  'reports.filter.allBranches'.trns();

          return _DropdownField(
            value: selectedLabel,
            onTap: () => _showBranchPicker(context),
          );
        }),
      ],
    );
  }

  Widget _buildServices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'reports.filter.service'.trns(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedLabel = controller.tempServiceId.value == 'all'
              ? 'reports.filter.allServices'.trns()
              : controller.services
                      .firstWhereOrNull((s) => s.value == controller.tempServiceId.value)
                      ?.label ??
                  'reports.filter.allServices'.trns();

          return _DropdownField(
            value: selectedLabel,
            onTap: () => _showServicePicker(context),
          );
        }),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _OutlineBtn(
            label: 'reports.filter.reset'.trns(),
            onTap: controller.resetFilter,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MainBtn(
            text: 'reports.filter.apply'.trns(),
            onPressed: () {
              controller.applyFilter();
              Get.back();
            },
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
  }

  void _showBranchPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BranchPickerSheet(controller: controller),
    );
  }

  void _showServicePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ServicePickerSheet(controller: controller),
    );
  }
}

// ── Date Field ────────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({required this.value, required this.onTap});

  String _fmt(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month]}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _fmt(value),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.black),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ── Dropdown Field ────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DropdownField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.black),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ── Outline Button ────────────────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

// ── Branch Picker Sheet ───────────────────────────────────────────────────────
class _BranchPickerSheet extends StatelessWidget {
  final ServiceRevenueReportController controller;
  const _BranchPickerSheet({required this.controller});

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
                  'reports.filter.branch'.trns(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => ListTile(
                title: Text(
                  'reports.filter.allBranches'.trns(),
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.tempBranchId.value == null
                        ? AppColors.primary
                        : AppColors.black,
                    fontWeight: controller.tempBranchId.value == null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: controller.tempBranchId.value == null
                    ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  controller.tempBranchId.value = null;
                  Get.back();
                },
              )),
          ...controller.branches.map(
            (b) => Obx(() => ListTile(
                  title: Text(
                    b.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.tempBranchId.value == b.value
                          ? AppColors.primary
                          : AppColors.black,
                      fontWeight: controller.tempBranchId.value == b.value
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: controller.tempBranchId.value == b.value
                      ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
                      : null,
                  onTap: () {
                    controller.tempBranchId.value = b.value;
                    Get.back();
                  },
                )),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Service Picker Sheet ──────────────────────────────────────────────────────
class _ServicePickerSheet extends StatelessWidget {
  final ServiceRevenueReportController controller;
  const _ServicePickerSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
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
                  'reports.filter.service'.trns(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: controller.services.map((s) {
                return Obx(() {
                  final isSelected = controller.tempServiceId.value == s.value;
                  return ListTile(
                    title: Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? AppColors.primary : AppColors.black,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
                        : null,
                    onTap: () {
                      controller.tempServiceId.value = s.value;
                      Get.back();
                    },
                  );
                });
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}