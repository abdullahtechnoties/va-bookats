// lib/app/widgets/payment_card.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PaymentCardModel {
  final String grandTotal;
  final String status;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String branch;
  final String total;
  final String paid;
  final String remaining;

  const PaymentCardModel({
    required this.grandTotal,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.branch,
    required this.total,
    required this.paid,
    required this.remaining,
  });
}

class PaymentCard extends StatelessWidget {
  final PaymentCardModel payment;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onViewDetails,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grand Total + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'payments.grandTotal'.trns(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$ ${payment.grandTotal}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payment.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details rows
            _PaymentDetailRow(
              label: 'payments.customerName'.trns(),
              value: payment.customerName,
            ),
            _PaymentDetailRow(
              label: 'payments.customerEmail'.trns(),
              value: payment.customerEmail,
            ),
            _PaymentDetailRow(
              label: 'payments.customerPhone'.trns(),
              value: payment.customerPhone,
            ),
            _PaymentDetailRow(
              label: 'payments.branch'.trns(),
              value: payment.branch,
            ),
            _PaymentDetailRow(
              label: 'payments.total'.trns(),
              value: payment.total,
            ),
            _PaymentDetailRow(
              label: 'payments.paid'.trns(),
              value: payment.paid,
            ),
            _PaymentDetailRow(
              label: 'payments.remaining'.trns(),
              value: payment.remaining,
            ),
            _PaymentDetailRow(
              label: 'payments.grandTotal'.trns(),
              value: payment.grandTotal,
              isLast: true,
            ),
            const SizedBox(height: 14),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onViewDetails,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'payments.viewDetails'.trns(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _PaymentDetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFEEEEEE),
          ),
      ],
    );
  }
}