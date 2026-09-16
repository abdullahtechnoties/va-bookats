import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/controllers/commissions_report_controller.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/models/commissions_report_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class CommissionsFilterSheet extends StatelessWidget {
  final CommissionsReportController controller;

  const CommissionsFilterSheet({super.key, required this.controller});

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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: AppColors.black, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // From Date
          Text(
            'commissions.filter.fromDate'.trns(),
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

          const SizedBox(height: 16),

          // To Date
          Text(
            'commissions.filter.toDate'.trns(),
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

          const SizedBox(height: 16),

          // Branch & Staff Row (only if owner)
          if (controller.isOwner) ...[
            Row(
              children: [
                // Branch Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'commissions.filter.branch'.trns(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final selectedLabel = controller.branches
                                .firstWhereOrNull((b) => b.value.toString() == controller.tempBranchId.value)
                                ?.label ??
                            'commissions.filter.selectBranch'.trns();
                        return _DropdownField(
                          value: selectedLabel,
                          onTap: () => _showBranchPicker(context),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Staff Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'commissions.filter.staff'.trns(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final selectedLabel = controller.staffs
                                .firstWhereOrNull((s) => s.value.toString() == controller.tempStaffId.value)
                                ?.label ??
                            'commissions.filter.selectStaff'.trns();
                        return _DropdownField(
                          value: selectedLabel,
                          onTap: () => _showStaffPicker(context),
                        );
                      }),
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final selectedLabel = controller.staffs
                      .firstWhereOrNull((s) => s.value.toString() == controller.tempStaffId.value)
                      ?.label ??
                  'commissions.filter.selectStaff'.trns();
              return _DropdownField(
                value: selectedLabel,
                onTap: () => _showStaffPicker(context),
              );
            }),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'commissions.filter.branch'.trns(),
        items: controller.branches,
        selectedValue: controller.tempBranchId,
      ),
    );
  }

  void _showStaffPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'commissions.filter.staff'.trns(),
        items: controller.staffs,
        selectedValue: controller.tempStaffId,
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
                DateFormat('MMM/d/yyyy').format(value),
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
                overflow: TextOverflow.ellipsis,
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.6),
        ),
      ),
    );
  }
}

// ── Picker Sheet ──────────────────────────────────────────────────────────────
class _PickerSheet extends StatelessWidget {
  final String title;
  final List<DropdownOption> items;
  final RxnString selectedValue;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Obx(() {
                  final isSelected = selectedValue.value == item.value.toString();
                  return ListTile(
                    title: Text(
                      item.label,
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
                      selectedValue.value = item.value.toString();
                      Get.back();
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}