// lib/app/widgets/package_card.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class PackageModel {
  final String id;
  final String name;
  final String branch;
  final String status;

  const PackageModel({
    required this.id,
    required this.name,
    required this.branch,
    required this.status,
  });
}

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onViewEdit;
  final VoidCallback? onDelete;

  const PackageCard({
    super.key,
    required this.package,
    this.onViewEdit,
    this.onDelete,
  });

  Color get _statusBgColor =>
      package.status.toLowerCase() == 'active'
          ? AppColors.secondary.withValues(alpha: 0.12)
          : Colors.grey.withValues(alpha: 0.15);

  Color get _statusTextColor =>
      package.status.toLowerCase() == 'active'
          ? AppColors.secondary
          : Colors.grey;

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
          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'packages.card.status'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  package.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name Row with divider
          _InfoRow(
            label: 'packages.card.name'.trns(),
            value: package.name,
          ),
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

          // Branch Row
          _InfoRow(
            label: 'packages.card.branch'.trns(),
            value: package.branch,
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onViewEdit,
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
                        'packages.card.viewOrEdit'.trns(),
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
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label  ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF888888),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}