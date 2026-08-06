// lib/app/modules/booking_details/views/booking_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookingDetails/controllers/booking_details_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class BookingDetailsView extends GetView<BookingDetailsController> {
  const BookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _BookingDetailsHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  // Booking Info Card
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID + DateTime
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${'bookingDetails.id'.trns()} ',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '#${controller.bookingId}',
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
                              controller.bookingDateTime,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Branch Image + Name + Location
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AppCachedImage(
                                imageUrl: controller.branchImageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.branchName,
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
                                    Text(
                                      controller.branchLocation,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Detail Rows
                        _DetailLabelRow(
                          label: 'bookingDetails.service'.trns(),
                          value: controller.services.join('  |  '),
                        ),
                        const SizedBox(height: 8),
                        _DetailLabelRow(
                          label: 'bookingDetails.timeDuration'.trns(),
                          value: controller.timeDuration,
                        ),
                        const SizedBox(height: 8),
                        _DetailLabelRow(
                          label: 'bookingDetails.email'.trns(),
                          value: controller.email,
                        ),
                        const SizedBox(height: 8),
                        _DetailLabelRow(
                          label: 'bookingDetails.phoneNumber'.trns(),
                          value: controller.phoneNumber,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Customer Info Card
                  _SectionCard(
                    child: Column(
                      children: [
                        // Header row with toggle
                        GestureDetector(
                          onTap: controller.toggleCustomerInfo,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'bookingDetails.customerInfo'.trns(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              Obx(
                                () => Icon(
                                  controller.isCustomerInfoExpanded.value
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: controller.isCustomerInfoExpanded.value
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      _DetailLabelRow(
                                        label: 'bookingDetails.name'.trns(),
                                        value: controller.customerName,
                                      ),
                                      const SizedBox(height: 8),
                                      _DetailLabelRow(
                                        label: 'bookingDetails.email'.trns(),
                                        value: controller.customerEmail,
                                      ),
                                      const SizedBox(height: 8),
                                      _DetailLabelRow(
                                        label:
                                            'bookingDetails.phoneNumber'.trns(),
                                        value: controller.customerPhone,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price Breakdown Card
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'bookingDetails.totalPrice'.trns(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$ ${controller.totalPrice}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PriceRow(
                          label: 'bookingDetails.services'.trns(),
                          value: controller.servicesDetail,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.staff'.trns(),
                          value: controller.staff,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.categories'.trns(),
                          value: controller.categories,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.variation'.trns(),
                          value: controller.variation,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.price'.trns(),
                          value: controller.price,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.qty'.trns(),
                          value: controller.qty,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.total'.trns(),
                          value: controller.total,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.discount'.trns(),
                          value: controller.discount,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.afterDiscount'.trns(),
                          value: controller.afterDiscount,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Grand Total Card
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grand Total + Paid badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'bookingDetails.grandTotal'.trns(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF888888),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$ ${controller.grandTotal}',
                                  style: const TextStyle(
                                    fontSize: 26,
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
                                color:
                                    AppColors.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.paymentStatus,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _PriceRow(
                          label: 'bookingDetails.customerName'.trns(),
                          value: controller.grandCustomerName,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.customerEmail'.trns(),
                          value: controller.grandCustomerEmail,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.customerPhone'.trns(),
                          value: controller.grandCustomerPhone,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.branch'.trns(),
                          value: controller.branch,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.total'.trns(),
                          value: controller.grandTotalTotal,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.paid'.trns(),
                          value: controller.paid,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.remaining'.trns(),
                          value: controller.remaining,
                        ),
                        _PriceRow(
                          label: 'bookingDetails.grandTotal'.trns(),
                          value: controller.grandTotal,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.secondary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'bookingDetails.viewDetails'.trns(),
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
                          onTap: () {},
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _BookingDetailsHeader extends StatelessWidget {
  const _BookingDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  'bookingDetails.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.filter_alt_outlined,
                color: AppColors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailLabelRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLabelRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
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
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}