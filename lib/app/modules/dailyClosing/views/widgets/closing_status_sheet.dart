// lib/app/modules/dailyClosing/views/widgets/closing_status_sheet.dart
//
// Pending ⇄ Approved picker. The backend endpoint toggles status on PUT, so
// this sheet only confirms intent and returns the requested target label.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// Opens the Pending / Approved picker. Uses `Get.bottomSheet` (like the
/// customers status sheet) so controllers never need a BuildContext.
Future<String?> showClosingStatusSheet({required String currentStatus}) {
  final isApproved = currentStatus.toLowerCase() == 'approved';
  return Get.bottomSheet<String>(
    SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'dailyClosing.changeStatus'.trns(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          _StatusOption(
            label: 'dailyClosing.status.pending'.trns(),
            isSelected: !isApproved,
            onTap: () => Get.back(result: 'Pending'),
          ),
          _StatusOption(
            label: 'dailyClosing.status.approved'.trns(),
            isSelected: isApproved,
            onTap: () => Get.back(result: 'Approved'),
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
