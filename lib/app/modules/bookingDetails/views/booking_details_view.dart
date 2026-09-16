// lib/app/modules/bookingDetails/views/booking_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookingDetails/controllers/booking_details_controller.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_status_sheet.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class BookingDetailsView extends GetView<BookingDetailsController> {
  const BookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _BookingDetailsHeader(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.booking.value == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                );
              }
              final booking = controller.booking.value;
              if (booking == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Color(0xFFCCCCCC)),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load booking details.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: controller.retry,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 11),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: controller.fetchDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      _BookingInfoCard(
                        booking: booking,
                        controller: controller,
                      ),
                      const SizedBox(height: 10),
                      _CustomerInfoCard(
                        booking: booking,
                        controller: controller,
                      ),
                      const SizedBox(height: 10),
                      _LinesCard(booking: booking),
                      const SizedBox(height: 10),
                      _GrandTotalCard(booking: booking),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            if (booking.isEditable)
                              Expanded(
                                child: GestureDetector(
                                  onTap: controller.openEdit,
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Edit Booking',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (booking.isEditable)
                              const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _showStatusSheet(context, booking),
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
                                    child: Obx(() => controller
                                                .busyStatus.value ==
                                            booking.id
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.secondary,
                                            ),
                                          )
                                        : Text(
                                            'Status: ${booking.status}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.secondary,
                                            ),
                                          )),
                                  ),
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
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context, BookingModel booking) {
    BookingStatusSheet.show(
      context,
      currentStatus: booking.status,
      onConfirmed: ({
        required String status,
        String? returnAmount,
        String? paymentMethod,
        String? transactionId,
        int? mediaId,
      }) {
        controller.changeStatus(
          status,
          returnAmount: returnAmount,
          paymentMethod: paymentMethod,
          transactionId: transactionId,
          mediaId: mediaId,
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _BookingDetailsHeader extends StatelessWidget {
  final BookingDetailsController controller;

  const _BookingDetailsHeader({required this.controller});

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
                  'home.bookingDetails.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Obx(() {
                final booking = controller.booking.value;
                if (booking == null || !booking.isEditable) {
                  return const SizedBox(width: 30);
                }
                return GestureDetector(
                  onTap: controller.openEdit,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.edit,
                        color: AppColors.white, size: 17),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cards ───────────────────────────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  final BookingModel booking;
  final BookingDetailsController controller;

  const _BookingInfoCard({
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final contactEmail = booking.isGuest
        ? (booking.guestEmail ?? '—')
        : (booking.customer?.email ?? '—');
    final contactPhone = booking.isGuest
        ? (booking.guestPhone ?? '—')
        : (booking.customer?.phone ?? '—');
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'home.bookingDetails.id'.trns()} ',
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppCachedImage(
                  imageUrl: booking.displayImage,
                  width: 70,
                  height: 70,
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
                                ? (booking.branch?.address ?? '—')
                                : booking.displayLocation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
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
          const SizedBox(height: 14),
          if (booking.serviceNames.isNotEmpty)
            _DetailLabelRow(
              label: 'home.bookingDetails.service'.trns(),
              value: booking.serviceNames.join('  |  '),
            ),
          const SizedBox(height: 8),
          _DetailLabelRow(
            label: 'home.bookingDetails.timeDuration'.trns(),
            value:
                '${booking.startTime ?? '—'} - ${booking.endTime ?? '—'}',
          ),
          const SizedBox(height: 8),
          _DetailLabelRow(
            label: 'home.bookingDetails.email'.trns(),
            value: contactEmail,
          ),
          const SizedBox(height: 8),
          _DetailLabelRow(
            label: 'home.bookingDetails.phoneNumber'.trns(),
            value: contactPhone,
          ),
          if ((booking.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailLabelRow(label: 'Note', value: booking.note!),
          ],
        ],
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final BookingModel booking;
  final BookingDetailsController controller;

  const _CustomerInfoCard({
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final name = booking.displayName;
    final email = booking.isGuest
        ? (booking.guestEmail ?? '—')
        : (booking.customer?.email ?? '—');
    final phone = booking.isGuest
        ? (booking.guestPhone ?? '—')
        : (booking.customer?.phone ?? '—');
    return _SectionCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: controller.toggleCustomerInfo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home.bookingDetails.customerInfo'.trns(),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _DetailLabelRow(
                          label: 'home.bookingDetails.name'.trns(),
                          value: name,
                        ),
                        const SizedBox(height: 8),
                        _DetailLabelRow(
                          label: 'home.bookingDetails.email'.trns(),
                          value: email,
                        ),
                        const SizedBox(height: 8),
                        _DetailLabelRow(
                          label: 'home.bookingDetails.phoneNumber'
                              .trns(),
                          value: phone,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinesCard extends StatelessWidget {
  final BookingModel booking;

  const _LinesCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.services.isEmpty &&
        booking.packages.isEmpty &&
        booking.products.isEmpty) {
      return const SizedBox.shrink();
    }
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.bookingDetails.totalPrice'.trns(),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rs ${booking.totalAmount ?? '0'}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          for (final s in booking.services)
            _PriceRow(
              label:
                  '${s.serviceName ?? 'Service'}${s.variationName != null ? ' (${s.variationName})' : ''}',
              value: 'Rs ${s.totalAmount ?? s.amount ?? '0'}',
            ),
          for (final p in booking.packages)
            _PriceRow(
              label: p.packageName ?? 'Package',
              value: 'Rs ${p.totalAmount ?? p.amount ?? '0'}',
            ),
          for (final p in booking.products)
            _PriceRow(
              label:
                  '${p.productName ?? 'Product'}${p.variantName != null ? ' (${p.variantName})' : ''} x${p.quantity ?? 1}',
              value: 'Rs ${p.afterDiscountPrice ?? p.totalPrice ?? '0'}',
              isLast: p == booking.products.last &&
                  booking.services.isEmpty &&
                  booking.packages.isEmpty,
            ),
        ],
      ),
    );
  }
}

class _GrandTotalCard extends StatelessWidget {
  final BookingModel booking;

  const _GrandTotalCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final payment = booking.payment;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home.bookingDetails.grandTotal'.trns(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs ${booking.totalAmount ?? '0'}',
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
                  payment?.status ?? booking.status,
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
            label: 'home.bookingDetails.customerName'.trns(),
            value: booking.displayName,
          ),
          _PriceRow(
            label: 'home.bookingDetails.branch'.trns(),
            value: booking.displayLocation.isEmpty
                ? '—'
                : booking.displayLocation,
          ),
          _PriceRow(
            label: 'home.bookingDetails.total'.trns(),
            value: 'Rs ${booking.totalAmount ?? '0'}',
          ),
          _PriceRow(
            label: 'home.bookingDetails.paid'.trns(),
            value:
                'Rs ${booking.amountPaid ?? payment?.paidAmount ?? '0'}',
          ),
          _PriceRow(
            label: 'home.bookingDetails.remaining'.trns(),
            value:
                'Rs ${booking.remainingAmount ?? payment?.balance ?? '0'}',
          ),
          _PriceRow(
            label: 'Payment Method',
            value: booking.paymentMethod ??
                payment?.paymentMethod ??
                '—',
          ),
          if ((payment?.transactionId ?? booking.transactionId) != null)
            _PriceRow(
              label: 'Transaction ID',
              value: payment?.transactionId ??
                  booking.transactionId ??
                  '—',
            ),
          if ((payment?.slipUrl ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppCachedImage(
                  imageUrl: payment!.slipThumbUrl ?? payment.slipUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          _PriceRow(
            label: 'home.bookingDetails.grandTotal'.trns(),
            value: 'Rs ${booking.totalAmount ?? '0'}',
            isLast: true,
          ),
        ],
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
