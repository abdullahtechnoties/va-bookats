// lib/app/modules/reports/payment_details/views/payment_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/paymentDetails/controllers/payment_details_controller.dart';
import 'package:va_bookats/app/modules/paymentDetails/views/widgets/payment_tablet.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class PaymentDetailsView extends GetView<PaymentDetailsController> {
  const PaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchDetails(isRefresh: true),
        color: AppColors.primary,
        child: Column(
          children: [
            _buildTabs(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoader();
                }

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildBranchCard(),
                      const SizedBox(height: 16),
                      if (controller.currentList.isEmpty)
                        _buildEmptyState()
                      else
                        PaymentTableWidget(controller: controller),
                      const SizedBox(height: 16),
                      if (controller.currentList.isNotEmpty) _buildPagination(),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
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
          child: const Icon(Icons.chevron_left, color: AppColors.white, size: 28),
        ),
      ),
      title: Text(
        'reports.paymentDetails.title'.trns(),
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
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'reports.paymentDetails.tabs.paid'.trns(),
              isActive: controller.activeTab.value == PaymentTab.paid,
              onTap: () => controller.setTab(PaymentTab.paid),
            ),
            _TabItem(
              label: 'reports.paymentDetails.tabs.unpaid'.trns(),
              isActive: controller.activeTab.value == PaymentTab.unpaid,
              onTap: () => controller.setTab(PaymentTab.unpaid),
            ),
            _TabItem(
              label: 'reports.paymentDetails.tabs.returned'.trns(),
              isActive: controller.activeTab.value == PaymentTab.returned,
              onTap: () => controller.setTab(PaymentTab.returned),
            ),
          ],
        ),
      );
    });
  }

  // ── Branch Info Card ─────────────────────────────────────────────────────
  Widget _buildBranchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final branch = controller.branchInfo.value;
        if (branch == null) return const SizedBox.shrink();

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
                  imageUrl: null,
                  width: 90,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (branch.address != null && branch.address!.isNotEmpty)
                      Text(
                        branch.address!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (branch.emailPrimary != null)
                    Text(
                      branch.emailPrimary!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  const SizedBox(height: 4),
                  if (branch.phonePrimary != null)
                    Text(
                      branch.phonePrimary!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.fromDate} - ${controller.toDate}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Loader ───────────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'reports.paymentDetails.noPayments'.trns(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'reports.paymentDetails.noPaymentsDesc'.trns(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pagination ───────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _PaginationBtn(
                label: '« ${'reports.paymentDetails.pagination.previous'.trns()}',
                onTap: controller.hasPrevPage ? controller.prevPage : null,
              ),
              const SizedBox(width: 8),
              _PaginationBtn(
                label: '${'reports.paymentDetails.pagination.next'.trns()} »',
                isPrimary: true,
                onTap: controller.hasNextPage ? controller.nextPage : null,
              ),
            ],
          ),
        ));
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