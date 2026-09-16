// lib/app/widgets/booking_card.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

export 'package:va_bookats/models/booking_model.dart';

/// Legacy stub kept so old static call sites still compile until migrated.
/// New code should build cards directly from [BookingModel].
class BookingCardModel {
  final String id;
  final String dateTime;
  final String imageUrl;
  final String name;
  final String location;
  final String date;
  final String totalAmount;
  final List<String> services;
  final String status;

  const BookingCardModel({
    required this.id,
    required this.dateTime,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.date,
    required this.totalAmount,
    required this.services,
    required this.status,
  });
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onViewDetails;
  final VoidCallback? onStatusTap;
  final VoidCallback? onEdit;
  final bool isBusy;
  final bool showShadow;

  const BookingCard({
    super.key,
    required this.booking,
    this.onViewDetails,
    this.onStatusTap,
    this.onEdit,
    this.isBusy = false,
    this.showShadow = true,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.withValues(alpha: 0.15);
      case 'cancelled':
        return AppColors.error.withValues(alpha: 0.15);
      case 'pending':
      default:
        return AppColors.secondary.withValues(alpha: 0.15);
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = booking.serviceNames;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID & DateTime Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${'home.booking.card.id'.trns()} ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      TextSpan(
                        text: '#${booking.serial ?? booking.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  booking.dateTimeLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image + Name + Location
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppCachedImage(
                    imageUrl: booking.displayImage,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Color(0xFF888888),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              booking.displayLocation.isEmpty
                                  ? '—'
                                  : booking.displayLocation,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & Amount Row
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'home.booking.card.date'.trns(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Color(0xFF888888),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.dateLabel.isEmpty
                                  ? '—'
                                  : booking.dateLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      color: const Color(0xFFDDDDDD),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rs: ${booking.totalAmount ?? '0'}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'home.booking.card.totalAmount'.trns(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Services
            if (services.isNotEmpty)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'home.booking.card.service'.trns()} ',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    ...services.asMap().entries.map((entry) {
                      final isLast = entry.key == services.length - 1;
                      return TextSpan(
                        text: isLast ? entry.value : '${entry.value}  |  ',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF888888),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Status + View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.booking.card.bookingStatus'.trns(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: isBusy ? null : onStatusTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(booking.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    booking.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _statusTextColor(booking.status),
                                    ),
                                  ),
                                  if (onStatusTap != null) ...[
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 16,
                                      color:
                                          _statusTextColor(booking.status),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (onEdit != null && booking.isEditable)
                      GestureDetector(
                        onTap: isBusy ? null : onEdit,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: onViewDetails,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'home.booking.card.viewDetails'.trns(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
