// lib/app/modules/dailyClosing/views/widgets/opening_balance_card.dart
//
// Floating card shown at the top of the home view. Owners get a mini branch
// selector (their branch list); every other role silently uses the branch on
// their user model. Shows today's opening balance + status when it exists,
// and a gated create shortcut when it does not.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/opening_balance_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/utilities/closing_formatters.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/closing_branch_picker.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/daily_closing_card.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class OpeningBalanceCard extends StatelessWidget {
  final OpeningBalanceController controller;

  const OpeningBalanceCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = controller.today.value;
      final hasOpening = today?.exists == true;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.wallet_outlined,
                    size: 17,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dailyClosing.todayOpening'.trns(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'dailyClosing.todayOpeningHint'.trns(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.isOwner) _BranchChip(controller: controller),
              ],
            ),
            const SizedBox(height: 10),
            if (controller.isLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
              )
            else if (controller.loadFailed.value)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'dailyClosing.loadFailedShort'.trns(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.fetchToday,
                    child: Text(
                      'common.retry'.trns(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              )
            else if (hasOpening)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          closingAmount(today!.openingBalance),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClosingStatusChip(status: today.status),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.DAILY_CLOSINGS),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text(
                            'dailyClosing.viewAll'.trns(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'dailyClosing.notCreated'.trns(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Can(
                    AppPerm.create(AppPerm.dailyClosings),
                    child: GestureDetector(
                      onTap: () => controller.openCreateSheet(context),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'dailyClosing.addOpening'.trns(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}

/// Mini owner branch selector on the card header.
class _BranchChip extends StatelessWidget {
  final OpeningBalanceController controller;

  const _BranchChip({required this.controller});

  @override
  Widget build(BuildContext context) {
    final branch = controller.selectedBranch.value;
    final label = controller.isBranchesLoading.value
        ? 'common.loading'.trns()
        : (branch?.displayLabel ?? 'dailyClosing.selectBranch'.trns());
    return GestureDetector(
      onTap: () async {
        if (controller.isBranchesLoading.value) return;
        if (controller.branches.isEmpty) await controller.loadBranches();
        if (!context.mounted) return;
        final picked = await showClosingBranchPicker(
          context,
          branches: controller.branches,
          selected: controller.selectedBranch.value,
        );
        if (picked == null) return;
        await controller.selectBranch(picked);
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 12,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}
