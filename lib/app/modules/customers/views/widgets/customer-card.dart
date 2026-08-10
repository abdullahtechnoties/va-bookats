// lib/app/widgets/customer_card.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String status;
  final String branch;
  final String shift;
  final String designation;
  final String email;
  final String address;
  final String imageUrl;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.branch,
    required this.shift,
    required this.designation,
    required this.email,
    required this.address,
    required this.imageUrl,
  });
}

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onTap;

  const CustomerCard({super.key, required this.customer, this.onTap});

  Color get _statusBgColor =>
      customer.status.toLowerCase() == 'active'
          ? AppColors.secondary.withValues(alpha: 0.12)
          : Colors.grey.withValues(alpha: 0.15);

  Color get _statusTextColor =>
      customer.status.toLowerCase() == 'active'
          ? AppColors.secondary
          : Colors.grey;

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
                      imageUrl: customer.imageUrl,
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
                          customer.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          customer.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      customer.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusTextColor,
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

              // Details
              _DetailRow(
                label: 'customers.card.branch'.trns(),
                value: customer.branch,
              ),
              _DetailDivider(),
              _DetailRow(
                label: 'customers.card.shift'.trns(),
                value: customer.shift,
              ),
              _DetailDivider(),
              _DetailRow(
                label: 'customers.card.designation'.trns(),
                value: customer.designation,
              ),
              _DetailDivider(),
              _DetailRow(
                label: 'customers.card.email'.trns(),
                value: customer.email,
              ),
              _DetailDivider(),
              _DetailRow(
                label: 'customers.card.address'.trns(),
                value: customer.address,
              ),
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