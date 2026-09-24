import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/controllers/commissions_report_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/report_filter_helpers.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class CommissionsFilterSheet extends StatelessWidget {
  final CommissionsReportController controller;

  const CommissionsFilterSheet({super.key, required this.controller});

  static void show(
    BuildContext context,
    CommissionsReportController controller,
  ) {
    controller.initTempFilter();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => CommissionsFilterSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'commissions.filter.title'.trns(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(
                  Icons.close,
                  color: AppColors.black,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // From Date
          Text(
            'commissions.filter.fromDate'.trns(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => _DateField(
              value: controller.tempFromDate.value,
              onTap: () async {
                final picked = await _pickDate(
                  context,
                  controller.tempFromDate.value,
                );
                if (picked != null) controller.tempFromDate.value = picked;
              },
            ),
          ),

          const SizedBox(height: 16),

          // To Date
          Text(
            'commissions.filter.toDate'.trns(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => _DateField(
              value: controller.tempToDate.value,
              onTap: () async {
                final picked = await _pickDate(
                  context,
                  controller.tempToDate.value,
                );
                if (picked != null) controller.tempToDate.value = picked;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Branch & Staff Row (only if owner)
          if (controller.isOwner) ...[
            Row(
              children: [
                // Branch multi-select Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'commissions.filter.branch'.trns(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => _DropdownField(
                          value: controller.tempBranchFilterDisplay,
                          onTap: () => _showBranchPicker(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Staff multi-select Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'commissions.filter.staff'.trns(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => _DropdownField(
                          value: controller.tempStaffFilterDisplay,
                          onTap: () => _showStaffPicker(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Staff only (if not owner)
          if (!controller.isOwner) ...[
            Text(
              'commissions.filter.staff'.trns(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _DropdownField(
                value: controller.tempStaffFilterDisplay,
                onTap: () => _showStaffPicker(context),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: _OutlineBtn(
                  label: 'commissions.filter.reset'.trns(),
                  onTap: controller.resetFilter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MainBtn(
                  text: 'commissions.filter.apply'.trns(),
                  onPressed: () {
                    controller.applyFilter();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
    final options = controller.branchFilterOptions;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: 'commissions.filter.branch'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.55,
        dropdownItems: options.map((o) => o.label).toList(),
        selectedValue: options.map((o) => o.value).toList(),
        textController: TextEditingController(),
        showSearch: true,
        isMultiSelect: true,
        selectedValues: controller.tempBranchIds,
      ),
    );
  }

  void _showStaffPicker(BuildContext context) {
    final options = controller.staffFilterOptions;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: 'commissions.filter.staff'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.55,
        dropdownItems: options.map((o) => o.label).toList(),
        selectedValue: options.map((o) => o.value).toList(),
        textController: TextEditingController(),
        showSearch: true,
        isMultiSelect: true,
        selectedValues: controller.tempStaffIds,
      ),
    );
  }
}

// ── Date Field ────────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({required this.value, required this.onTap});

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
                reportHumanDate(value),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Color(0xFF9CA3AF),
            ),
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
