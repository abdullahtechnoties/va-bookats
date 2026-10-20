// lib/app/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusTap;
  final VoidCallback? onEdit;
  final bool isBusy;
  final bool isDeleting;

  const ProductCard({
    super.key,
    required this.product,
    this.onViewDetails,
    this.onDelete,
    this.onStatusTap,
    this.onEdit,
    this.isBusy = false,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppCachedImage(
              imageUrl: product.coverUrl,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),

          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'products.card.status'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Can(
                AppPerm.update(AppPerm.products),
                fallback: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.isActive
                        ? 'products.card.active'.trns()
                        : 'products.card.inactive'.trns(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: isBusy ? null : onStatusTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.secondary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.isActive
                                    ? 'products.card.active'.trns()
                                    : 'products.card.inactive'.trns(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name Row
          _InfoRow(
            label: 'products.card.name'.trns(),
            value: product.name ?? '',
          ),

          // Branch Row
          if (product.branchName.isNotEmpty)
            _InfoRow(
              label: 'products.card.branch'.trns(),
              value: product.branchName,
            ),

          // Price Row
          // _InfoRow(
          //   label: 'products.card.price'.trns(),
          //   value: product.price ?? '0',
          // ),

          // Stock Row
          _InfoRow(
            label: 'products.card.stock'.trns(),
            value: '${product.stock ?? 0}',
            isLast: true,
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (Permissions.can(AppPerm.show(AppPerm.products)))
                Expanded(
                  child: GestureDetector(
                    onTap: isBusy || isDeleting ? null : onViewDetails,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'products.card.viewDetails'.trns(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // edit
              if (Permissions.can(AppPerm.update(AppPerm.products)))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: isBusy || isDeleting ? null : onEdit,
                      child: Container(
                        height: 48,
                        width: 48,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (onDelete != null)
                Can(
                  AppPerm.destroy(AppPerm.products),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isBusy || isDeleting ? null : onDelete,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                value.isEmpty ? '—' : value,
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
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: Color(0xFFF0F0F0),
              indent: 0,
              endIndent: 0,
            ),
          ),
      ],
    );
  }
}
