// lib/app/modules/customerDetails/views/customer_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/models/customer_report_model.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReportDetails/controller/customer_details_controller.dart';
import 'package:va_bookats/network/response/status.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final status = controller.detailsResponse.value.status;

        if (status == Status.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (status == Status.error) {
          return _buildErrorState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDetails,
          color: AppColors.primary,
          child: Column(
            children: [
              _buildTabs(),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildBranchCard(),
                        const SizedBox(height: 16),
                        _buildBookingsList(),
                        if (controller.isLoadingMore.value) ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels >= metrics.maxScrollExtent - 200) {
        controller.loadNextPage();
      }
    }
    return false;
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
      title: Text(
        'customerDetails.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Obx(
      () => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _TabItem(
                label: 'customerDetails.tabs.all'.trns(),
                isActive: controller.activeTab.value == BookingStatusTab.all,
                onTap: () => controller.setTab(BookingStatusTab.all),
              ),
              _TabItem(
                label: 'customerDetails.tabs.completed'.trns(),
                isActive:
                    controller.activeTab.value == BookingStatusTab.completed,
                onTap: () => controller.setTab(BookingStatusTab.completed),
              ),
              _TabItem(
                label: 'customerDetails.tabs.pending'.trns(),
                isActive:
                    controller.activeTab.value == BookingStatusTab.pending,
                onTap: () => controller.setTab(BookingStatusTab.pending),
              ),
              _TabItem(
                label: 'customerDetails.tabs.cancelled'.trns(),
                isActive:
                    controller.activeTab.value == BookingStatusTab.cancelled,
                onTap: () => controller.setTab(BookingStatusTab.cancelled),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Branch Card ───────────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    final branch = controller.branch;
    if (branch == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppCachedImage(
                    imageUrl: null,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    fallbackAsset: 'assets/images/placeholder.png',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (branch.emailPrimary != null) ...[
                        _InfoRow(
                          icon: Icons.email_outlined,
                          text: branch.emailPrimary!,
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (branch.phonePrimary != null) ...[
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          text: branch.phonePrimary!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.customerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bookings List ─────────────────────────────────────────────────────────
  Widget _buildBookingsList() {
    return Obx(() {
      final bookings = controller.filteredBookings;

      if (bookings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'customerDetails.emptyBookings'.trns(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: bookings.map((booking) {
            return _BookingCard(booking: booking, controller: controller);
          }).toList(),
        ),
      );
    });
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            controller.detailsResponse.value.message ??
                'customerDetails.errors.generic'.trns(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchDetails(),
            icon: const Icon(Icons.refresh),
            label: Text('customerDetails.retry'.trns()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Item ──────────────────────────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : AppColors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.primary : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Booking Card ──────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingData booking;
  final CustomerDetailsController controller;

  const _BookingCard({required this.booking, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Booking Serial + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'customerDetails.bookingSerial'.trns()} #${booking.bookingSerial}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Customer info
          if (booking.customer != null) ...[
            _DetailRow(
              icon: Icons.person_outline,
              label: 'customerDetails.customer'.trns(),
              value: booking.customer!.name,
            ),
            const SizedBox(height: 6),
          ],

          // Date & Time
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'customerDetails.date'.trns(),
            value: controller.formatDate(booking.bookingDate),
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.access_time,
            label: 'customerDetails.time'.trns(),
            value:
                '${controller.formatTime(booking.startTime)} - ${controller.formatTime(booking.endTime)}',
          ),
          const SizedBox(height: 6),

          // Payment
          _DetailRow(
            icon: Icons.payment_outlined,
            label: 'customerDetails.paymentMethod'.trns(),
            value: booking.paymentMethod,
          ),
          const SizedBox(height: 10),

          // Divider
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 10),

          // Amounts
          Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: 'customerDetails.totalAmount'.trns(),
                  value: '\$${booking.totalAmount}',
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'customerDetails.amountPaid'.trns(),
                  value: '\$${booking.amountPaid}',
                  valueColor: Colors.green,
                ),
              ),
              Expanded(
                child: _AmountColumn(
                  label: 'customerDetails.remaining'.trns(),
                  value: '\$${booking.remainingAmount}',
                  valueColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (booking.isCompleted) return Colors.green;
    if (booking.isPending) return Colors.orange;
    if (booking.isCancelled) return Colors.red;
    return Colors.grey;
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _AmountColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
