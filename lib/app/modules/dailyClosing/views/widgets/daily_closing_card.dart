// lib/app/modules/dailyClosing/views/widgets/daily_closing_card.dart
//
// List card, styled after the customers card: header + status pill, label/value
// detail rows, then a filled primary action plus a square outlined action.

import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/utilities/closing_formatters.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class DailyClosingCard extends StatelessWidget {
  final DailyClosingModel closing;
  final bool isBusy;
  final VoidCallback onViewDetails;
  final VoidCallback onChangeStatus;

  const DailyClosingCard({
    super.key,
    required this.closing,
    required this.onViewDetails,
    required this.onChangeStatus,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = closing.currencySymbol;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_note_outlined,
                    size: 22,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        closingDisplayDate(closing.closingDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        closing.branchName.isEmpty ? '—' : closing.branchName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                ClosingStatusChip(status: closing.status),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFFF0F0F0),
              ),
            ),

            // Details
            // _DetailRow(
            //   label: 'dailyClosing.openingBalance'.trns(),
            //   value: closingMoney(closing.openingBalance, symbol),
            //   valueStyle: const TextStyle(
            //     fontSize: 13,
            //     fontWeight: FontWeight.w700,
            //     color: AppColors.black,
            //   ),
            // ),
            if (closing.creatorName.isNotEmpty) ...[
              // const _DetailDivider(),
              _DetailRow(
                label: 'dailyClosing.createdBy'.trns(),
                value: closing.creatorName,
              ),
            ],

            // Actions — view details / change status
            Can.any(
              [
                AppPerm.show(AppPerm.dailyClosings),
                AppPerm.update(AppPerm.dailyClosings),
              ],
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Can(
                      AppPerm.show(AppPerm.dailyClosings),
                      child: Expanded(
                        child: GestureDetector(
                          onTap: isBusy ? null : onViewDetails,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'dailyClosing.viewDetails'.trns(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (Permissions.can(AppPerm.show(AppPerm.dailyClosings)))
                      const SizedBox(width: 10),
                    Can(
                      AppPerm.update(AppPerm.dailyClosings),
                      child: Tooltip(
                        message: 'dailyClosing.changeStatus'.trns(),
                        child: GestureDetector(
                          onTap: isBusy ? null : onChangeStatus,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: isBusy
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.secondary,
                                    ),
                                  )
                                : const Icon(
                                    Icons.swap_horiz,
                                    color: AppColors.secondary,
                                    size: 19,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle = const TextStyle(
      fontSize: 13,
      color: Color(0xFF888888),
      fontWeight: FontWeight.w400,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label  ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.8, color: Color(0xFFF5F5F5));
  }
}

/// Pending / Approved pill shared by the list and detail screens.
class ClosingStatusChip extends StatelessWidget {
  final String status;

  const ClosingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final approved = status.toLowerCase() == 'approved';
    final color = approved ? const Color(0xFF2E7D32) : const Color(0xFFF59E0B);
    final label = approved
        ? 'dailyClosing.status.approved'.trns()
        : 'dailyClosing.status.pending'.trns();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
