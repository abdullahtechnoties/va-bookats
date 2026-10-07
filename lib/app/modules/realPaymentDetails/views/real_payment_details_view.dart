import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/realPaymentDetails/controllers/payment_details_controller.dart';
import 'package:va_bookats/models/payment_model.dart';
import 'package:va_bookats/utilities/booking_form_helpers.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class RealPaymentDetailsView extends GetView<RealPaymentDetailsController> {
  const RealPaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _DetailsHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.payment.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }
              if (controller.loadFailed.value &&
                  controller.payment.value == null) {
                return _ErrorState(onRetry: controller.retry);
              }
              final payment = controller.payment.value;
              if (payment == null) {
                return _ErrorState(onRetry: controller.retry);
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: controller.fetchDetail,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PaymentInfoCard(payment: payment),
                      const SizedBox(height: 14),
                      if (payment.hasSlip) ...[
                        _SlipCard(payment: payment),
                        const SizedBox(height: 14),
                      ],
                      if (payment.branch != null) ...[
                        _BranchCard(branch: payment.branch!),
                        const SizedBox(height: 14),
                      ],
                      if (payment.booking != null)
                        _BookingCard(booking: payment.booking!),
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
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _DetailsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
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
                  'paymentDetails.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Payment Info Card ───────────────────────────────────────────────────────

class _PaymentInfoCard extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentInfoCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'paymentDetails.paymentInfo'.trns(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
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
          _InfoRow(
            currencySymbol: payment.branchh?.currency?.symbol,
            isCurrency: true,
            label: 'paymentDetails.totalAmount'.trns(),
            value: payment.totalAmount ?? '—',
          ),
          _InfoRow(
            currencySymbol: payment.branchh?.currency?.symbol,
            isCurrency: true,
            label: 'paymentDetails.discount'.trns(),
            value: payment.discountAmount ?? '—',
          ),
          // after discount, the paid amount is calculated as totalAmount - discountAmount
          if (payment.discountAmount != null && payment.discountAmount != '0') ...[
            _InfoRow(
              currencySymbol: payment.branchh?.currency?.symbol,
              isCurrency: true,
              label: 'paymentDetails.afterDiscount'.trns(),
              value: (payment.totalAmount != null && payment.discountAmount != null)
                  ? (double.tryParse(payment.totalAmount!)! -
                          double.tryParse(payment.discountAmount!)!)
                      .toStringAsFixed(2)
                  : '—',
            ),
          ],
          _InfoRow(
            currencySymbol: payment.branchh?.currency?.symbol,
            isCurrency: true,
            label: 'paymentDetails.paidAmount'.trns(),
            value: payment.paidAmount ?? '—',
          ),
          _InfoRow(
            currencySymbol: payment.branchh?.currency?.symbol,
            isCurrency: true, 
            label: 'paymentDetails.balance'.trns(),
            value: payment.balance ?? '—',
          ),
          _InfoRow(
            label: 'paymentDetails.paymentMethod'.trns(),
            value: (payment.paymentMethod?.isNotEmpty == true)
                ? payment.paymentMethod!
                : '—',
          ),
          _InfoRow(
            label: 'paymentDetails.transactionId'.trns(),
            value: (payment.transactionId?.isNotEmpty == true)
                ? payment.transactionId!
                : '—',
          ),
          _InfoRow(
            label: 'paymentDetails.date'.trns(),
            value: (payment.date?.isNotEmpty == true)
                ? BookingFormHelpers.formatDateHuman(payment.date!)
                : '—',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─── Slip Card ───────────────────────────────────────────────────────────────

class _SlipCard extends StatelessWidget {
  final PaymentModel payment;

  const _SlipCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'paymentDetails.paymentSlip'.trns(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _previewSlip(context, payment.slipDisplayUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppCachedImage(
                imageUrl: payment.slipDisplayUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previewSlip(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AppCachedImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ─── Branch Card ─────────────────────────────────────────────────────────────

class _BranchCard extends StatelessWidget {
  final PaymentBranch branch;

  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'paymentDetails.branchInfo'.trns(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'paymentDetails.branch'.trns(),
            value: (branch.name?.isNotEmpty == true) ? branch.name! : '—',
          ),
          _InfoRow(
            label: 'paymentDetails.email'.trns(),
            value: (branch.email?.isNotEmpty == true) ? branch.email! : '—',
          ),
          _InfoRow(
            label: 'paymentDetails.phone'.trns(),
            value: (branch.phone?.isNotEmpty == true) ? branch.phone! : '—',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─── Booking / Customer Card ─────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final PaymentBooking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final customer = booking.customer;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'paymentDetails.customerInfo'.trns(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (customer != null) ...[
            Row(
              children: [
                ClipOval(
                  child: AppCachedImage(
                    imageUrl: customer.displayImage,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (customer.name?.isNotEmpty == true)
                            ? customer.name!
                            : '—',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Booking #${booking.id ?? '—'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'paymentDetails.email'.trns(),
              value: (customer.email?.isNotEmpty == true)
                  ? customer.email!
                  : '—',
            ),
            _InfoRow(
              label: 'paymentDetails.phone'.trns(),
              value: (customer.phone?.isNotEmpty == true)
                  ? customer.phone!
                  : '—',
              isLast: true,
            ),
          ] else ...[
            _InfoRow(
              label: 'paymentDetails.guestName'.trns(),
              value: (booking.guestName?.isNotEmpty == true)
                  ? booking.guestName!
                  : '—',
            ),
            _InfoRow(
              label: 'paymentDetails.email'.trns(),
              value: (booking.guestEmail?.isNotEmpty == true)
                  ? booking.guestEmail!
                  : '—',
            ),
            _InfoRow(
              label: 'paymentDetails.phone'.trns(),
              value: (booking.guestPhone?.isNotEmpty == true)
                  ? booking.guestPhone!
                  : '—',
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shared Bits ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final bool isCurrency;
  final String? currencySymbol;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.isCurrency = false,
    this.currencySymbol,
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
                  '${isCurrency ? '$currencySymbol ' : ''}$value',
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

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            Text(
              'paymentDetails.loadError'.trns(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'paymentDetails.retry'.trns(),
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
      ),
    );
  }
}
