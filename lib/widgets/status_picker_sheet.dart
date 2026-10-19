// lib/widgets/status_picker_sheet.dart
//
// Shared Active/Inactive picker used by every inventory lookup module
// (brands, product categories, tags, units, product variations).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';

/// Returns the picked status (`active`/`inactive`) or null on dismiss.
Future<String?> showStatusPickerSheet({
  required String title,
  required String activeLabel,
  required String inactiveLabel,
  required bool isActive,
}) {
  return Get.bottomSheet<String>(
    SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          _StatusOption(
            label: activeLabel,
            isSelected: isActive,
            onTap: () => Get.back(result: 'active'),
          ),
          _StatusOption(
            label: inactiveLabel,
            isSelected: !isActive,
            onTap: () => Get.back(result: 'inactive'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _StatusOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.4)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
