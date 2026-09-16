// lib/app/modules/customers/views/widgets/customer-card.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/models/customer_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

export 'package:va_bookats/models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusTap;
  final bool isBusy;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusTap,
    this.isBusy = false,
  });

  Color get _statusBgColor => customer.isActive
      ? AppColors.secondary.withValues(alpha: 0.12)
      : Colors.grey.withValues(alpha: 0.15);

  Color get _statusTextColor =>
      customer.isActive ? AppColors.secondary : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              // Avatar + Name + Phone + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: AppCachedImage(
                      imageUrl: customer.displayImage,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name.isEmpty ? '—' : customer.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          customer.phonePrimary.isEmpty
                              ? '—'
                              : customer.phonePrimary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (customer.customerSerial != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '#${customer.customerSerial}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAAAAAA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: isBusy ? null : onStatusTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondary,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  customer.isActive
                                      ? 'customers.card.active'.trns()
                                      : 'customers.card.inactive'.trns(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _statusTextColor,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: _statusTextColor,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFF0F0F0)),
              ),

              // Details (only fields the API actually returns)
              _DetailRow(
                label: 'customers.card.email'.trns(),
                value: customer.email.isEmpty ? '—' : customer.email,
              ),
              _DetailDivider(),
              _DetailRow(
                label: 'customers.card.address'.trns(),
                value: customer.addressLabel,
              ),
              if ((customer.country?.name ?? '').isNotEmpty) ...[
                _DetailDivider(),
                _DetailRow(
                  label: 'customers.filter.country'.trns(),
                  value: customer.country!.name!,
                ),
              ],

              // Actions — edit / delete (status toggles via the pill above)
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    if (onDelete != null)
                      GestureDetector(
                        onTap: isBusy ? null : onDelete,
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
                          child: Icon(
                            isBusy
                                ? Icons.hourglass_empty
                                : Icons.delete_outline,
                            color: AppColors.secondary,
                            size: 19,
                          ),
                        ),
                      ),
                    if (onDelete != null && onEdit != null)
                      const SizedBox(width: 10),
                    if (onEdit != null)
                      GestureDetector(
                        onTap: isBusy ? null : onEdit,
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
                            'customers.card.edit'.trns() ==
                                    'customers.card.edit'
                                ? 'Edit'
                                : 'customers.card.edit'.trns(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.8,
      color: Color(0xFFF5F5F5),
    );
  }
}
