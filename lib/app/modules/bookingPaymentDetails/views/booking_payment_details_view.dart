import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/controllers/booking_payment_details_controller.dart';
import 'package:va_bookats/app/modules/bookingPaymentDetails/models/booking_payment_details_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class BookingPaymentDetailsView
    extends GetView<BookingPaymentDetailsController> {
  const BookingPaymentDetailsView({super.key});

  static const List<_ColDef> _columns = [
    _ColDef(key: 'name', label: 'bookingPaymentDetails.table.item', width: 150),
    _ColDef(key: 'staff', label: 'bookingPaymentDetails.table.staff', width: 110),
    _ColDef(
        key: 'category',
        label: 'bookingPaymentDetails.table.category',
        width: 110),
    _ColDef(
        key: 'variation',
        label: 'bookingPaymentDetails.table.variation',
        width: 100),
    _ColDef(key: 'price', label: 'bookingPaymentDetails.table.price', width: 110),
    _ColDef(key: 'qty', label: 'bookingPaymentDetails.table.quantity', width: 70),
    _ColDef(key: 'total', label: 'bookingPaymentDetails.table.total', width: 110),
    _ColDef(
        key: 'discount',
        label: 'bookingPaymentDetails.table.discount',
        width: 100),
    _ColDef(
        key: 'afterDiscount',
        label: 'bookingPaymentDetails.table.afterDiscount',
        width: 120),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.hasError) {
                return _buildErrorState();
              }
              if (!controller.hasData) {
                return _buildEmptyState(
                  'bookingPaymentDetails.empty.title'.trns(),
                  'bookingPaymentDetails.empty.message'.trns(),
                );
              }
              switch (controller.activeTab.value) {
                case PaymentDetailTab.details:
                  return _buildDetailsTab();
                case PaymentDetailTab.payments:
                  return _buildPaymentsTab();
                case PaymentDetailTab.activities:
                  return _buildActivitiesTab(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left,
              color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        'bookingPaymentDetails.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Tabs ─────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Obx(() {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TabItem(
              label: 'bookingPaymentDetails.details'.trns(),
              isActive:
                  controller.activeTab.value == PaymentDetailTab.details,
              onTap: () => controller.setTab(PaymentDetailTab.details),
            ),
            _TabItem(
              label: 'bookingPaymentDetails.payments'.trns(),
              isActive:
                  controller.activeTab.value == PaymentDetailTab.payments,
              onTap: () => controller.setTab(PaymentDetailTab.payments),
            ),
            _TabItem(
              label: 'bookingPaymentDetails.activities'.trns(),
              isActive:
                  controller.activeTab.value == PaymentDetailTab.activities,
              onTap: () => controller.setTab(PaymentDetailTab.activities),
            ),
          ],
        ),
      );
    });
  }

  // ── Details Tab ──────────────────────────────────────────────────────────
  Widget _buildDetailsTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshDetails,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create New Payment button
            GestureDetector(
              onTap: controller.openCreatePayment,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'bookingPaymentDetails.createNewPayment'.trns(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Print button
            // GestureDetector(
            //   onTap: () {},
            //   child: Container(
            //     width: double.infinity,
            //     height: 50,
            //     decoration: BoxDecoration(
            //       color: AppColors.white,
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(color: AppColors.primary, width: 1.3),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         const Icon(Icons.print_outlined,
            //             color: AppColors.primary, size: 18),
            //         const SizedBox(width: 8),
            //         Text(
            //           'bookingPaymentDetails.print'.trns(),
            //           style: const TextStyle(
            //             color: AppColors.primary,
            //             fontSize: 14,
            //             fontWeight: FontWeight.w700,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),

            // Branch card
            _buildBranchCard(),
            const SizedBox(height: 16),

            // Lines table
            _buildTable(),
            const SizedBox(height: 16),

            // Totals card
            _buildTotalsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard() {
    return Obx(() {
      final booking = controller.booking;
      if (booking == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppCachedImage(
                imageUrl: booking.customer?.imageThumbUrl ??
                    booking.customer?.imageUrl,
                width: 72,
                height: 64,
                fit: BoxFit.cover,
                fallbackAsset: 'assets/images/placeholder.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.branchName.isNotEmpty
                        ? controller.branchName
                        : '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${booking.bookingSerial} • ${controller.customerName}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (controller.branchEmail.isNotEmpty)
                  Text(controller.branchEmail,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 3),
                if (controller.branchPhone.isNotEmpty)
                  Text(controller.branchPhone,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 3),
                Text(controller.branchDate,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTable() {
    return Obx(() {
      final items = controller.lineItems;
      if (items.isEmpty) {
        return _buildEmptyState(
          'bookingPaymentDetails.empty.title'.trns(),
          'bookingPaymentDetails.empty.message'.trns(),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeader(),
              ...items.asMap().entries.map(
                    (e) => _buildTableRow(e.value, e.key % 2 == 0),
                  ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: Row(
        children: [
          _HeaderCell(label: '#', width: 36),
          ..._columns.map(
              (c) => _HeaderCell(label: c.label.trns(), width: c.width)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BookingLineItem item, bool isEven) {
    final bg = isEven ? AppColors.white : const Color(0xFFFFF5F2);
    return Container(
      height: 44,
      color: bg,
      child: Row(
        children: [
          _DataCell(
            width: 36,
            showDivider: true,
            child: Text(
              '${item.index}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ..._columns.map(
            (c) => _DataCell(
              width: c.width,
              showDivider: true,
              child: Text(
                _cellValue(item, c.key),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cellValue(BookingLineItem item, String key) {
    switch (key) {
      case 'name':
        return item.name;
      case 'staff':
        return item.staff.isNotEmpty ? item.staff : '-';
      case 'category':
        return item.category;
      case 'variation':
        return item.variation;
      case 'price':
        return item.price;
      case 'qty':
        return item.qty;
      case 'total':
        return item.total;
      case 'discount':
        return item.discount;
      case 'afterDiscount':
        return item.afterDiscount;
      default:
        return '-';
    }
  }

  Widget _buildTotalsCard() {
    return Obx(() {
      final booking = controller.booking;
      if (booking == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'bookingPaymentDetails.summary.title'.trns(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                _StatusPill(
                  label: controller.formatStatus(booking.status),
                  status: booking.status,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'bookingPaymentDetails.summary.totalAmount'.trns(),
              value: controller.money(booking.totalAmount),
            ),
            _SummaryRow(
              label: 'bookingPaymentDetails.summary.discount'.trns(),
              value: controller.money(booking.discount),
            ),
            _SummaryRow(
              label: 'bookingPaymentDetails.summary.paidAmount'.trns(),
              value: controller.money(booking.amountPaid),
            ),
            _SummaryRow(
              label: 'bookingPaymentDetails.summary.remainingAmount'.trns(),
              value: controller.money(booking.remainingAmount),
              isLast: true,
            ),
          ],
        ),
      );
    });
  }

  // ── Payments Tab ─────────────────────────────────────────────────────────
  Widget _buildPaymentsTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshDetails,
      color: AppColors.primary,
      child: Obx(() {
        final records = controller.paymentRecords;
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: records.length +
              (controller.showPaymentsPagination ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            if (i >= records.length) return _buildPaymentsPagination();
            return _PaymentCard(
              payment: records[i],
              controller: controller,
            );
          },
        );
      }),
    );
  }

  Widget _buildPaymentsPagination() {
    return Obx(() {
      if (!controller.showPaymentsPagination) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PaginationBtn(
              label:
                  '« ${'bookingPaymentDetails.pagination.previous'.trns()}',
              onTap: controller.hasPrevPaymentsPage
                  ? controller.prevPaymentsPage
                  : null,
            ),
            const SizedBox(width: 8),
            _PaginationBtn(
              label: '${'bookingPaymentDetails.pagination.next'.trns()} »',
              isPrimary: true,
              onTap: controller.hasNextPaymentsPage
                  ? controller.nextPaymentsPage
                  : null,
            ),
          ],
        ),
      );
    });
  }

  // ── Activities Tab ───────────────────────────────────────────────────────
  Widget _buildActivitiesTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshDetails,
      color: AppColors.primary,
      child: Obx(() {
        final records = controller.activityRecords;
        if (records.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(
                'bookingPaymentDetails.activitiesEmpty.title'.trns(),
                'bookingPaymentDetails.activitiesEmpty.message'.trns(),
              ),
            ),
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: records.length +
              (controller.showActivitiesPagination ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= records.length) {
              return _buildActivitiesPagination();
            }
            final a = records[i];
            final isLast = i == records.length - 1 &&
                !controller.showActivitiesPagination;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      ClipOval(
                        child: AppCachedImage(
                          imageUrl: a.user?.imageThumbUrl ??
                              a.user?.imageUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          fallbackAsset: 'assets/images/placeholder.png',
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.comment,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              )),
                          const SizedBox(height: 2),
                          Text(controller.humanDateTime(a.createdAt),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildActivitiesPagination() {
    return Obx(() {
      if (!controller.showActivitiesPagination) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PaginationBtn(
              label:
                  '« ${'bookingPaymentDetails.pagination.previous'.trns()}',
              onTap: controller.hasPrevActivitiesPage
                  ? controller.prevActivitiesPage
                  : null,
            ),
            const SizedBox(width: 8),
            _PaginationBtn(
              label: '${'bookingPaymentDetails.pagination.next'.trns()} »',
              isPrimary: true,
              onTap: controller.hasNextActivitiesPage
                  ? controller.nextActivitiesPage
                  : null,
            ),
          ],
        ),
      );
    });
  }

  // ── States ───────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              controller.detailsResponse.value.message ??
                  'bookingPaymentDetails.errors.fetchFailed'.trns(),
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: controller.fetchDetails,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 26, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'bookingPaymentDetails.retry'.trns(),
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

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Card ────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final PaymentEntry payment;
  final BookingPaymentDetailsController controller;

  const _PaymentCard({required this.payment, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SlipThumb(payment: payment),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.currencySymbol}${payment.paidAmount}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${payment.paymentMethod ?? '-'} • ${controller.humanDate(payment.date)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${'bookingPaymentDetails.summary.balance'.trns()}: ${controller.currencySymbol}${payment.balance}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: controller.formatStatus(payment.status),
                status: payment.status,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.openEditPayment(payment),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'bookingPaymentDetails.paymentsTab.edit'.trns(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slip Thumbnail ──────────────────────────────────────────────────────────
class _SlipThumb extends StatelessWidget {
  final PaymentEntry payment;

  const _SlipThumb({required this.payment});

  @override
  Widget build(BuildContext context) {
    final thumb = payment.slipThumbUrl ?? payment.slipUrl;
    if (thumb == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.receipt_outlined,
            color: AppColors.primary, size: 22),
      );
    }
    return GestureDetector(
      onTap: () => _showSlipDialog(payment.slipUrl ?? thumb),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AppCachedImage(
          imageUrl: thumb,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

void _showSlipDialog(String imageUrl) {
  Get.dialog(
    Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppCachedImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0x80000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    color: AppColors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Status Pill ─────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String label;
  final String status;

  const _StatusPill({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    late final Color bg;
    late final Color fg;
    switch (s) {
      case 'paid':
      case 'active':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'unpaid':
      case 'pending':
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F00);
        break;
      case 'returned':
      case 'refunded':
      case 'cancelled':
        bg = const Color(0xFFFDECEA);
        fg = const Color(0xFFC62828);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Summary Row ─────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),
      ],
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

// ── Column def ───────────────────────────────────────────────────────────────
class _ColDef {
  final String key;
  final String label;
  final double width;
  const _ColDef({required this.key, required this.label, required this.width});
}

// ── Table Cells ────────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;

  const _HeaderCell({required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.white.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final double width;
  final Widget child;
  final bool showDivider;

  const _DataCell({
    required this.width,
    required this.child,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          right: showDivider
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)
              : BorderSide.none,
          bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: child,
    );
  }
}

// ── Pagination Button ─────────────────────────────────────────────────────────
class _PaginationBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _PaginationBtn({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? (isPrimary ? AppColors.primary : const Color(0xFFD1D5DB))
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: enabled
                ? (isPrimary ? AppColors.primary : const Color(0xFF374151))
                : const Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }
}
