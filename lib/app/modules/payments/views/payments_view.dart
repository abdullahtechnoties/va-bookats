// lib/app/modules/payments/views/payments_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:va_bookats/app/modules/payments/controllers/payments_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/payment_card.dart';

class PaymentsView extends GetView<PaymentsController> {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PaymentsHeader(controller: controller),
          _PaymentsTabBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.currentPayments.isEmpty) {
                return const _ListShimmer();
              }
              if (controller.loadFailed.value &&
                  controller.currentPayments.isEmpty) {
                return _ErrorState(onRetry: controller.retry);
              }
              if (controller.currentPayments.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: controller.handleRefresh,
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount:
                      controller.currentPayments.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.currentPayments.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final payment = controller.currentPayments[index];
                    return PaymentCard(
                      payment: payment.toCardModel(),
                      onViewDetails: () => controller.openDetails(payment),
                      onDelete: null,
                      currencySymbol: payment.branchh?.currency?.symbol ?? '\$',
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _PaymentsHeader extends StatelessWidget {
  final PaymentsController controller;

  const _PaymentsHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  'payments.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.openFilter(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.white,
                      size: 22,
                    ),
                    Obx(() {
                      final n = controller.appliedFiltersCount;
                      if (n == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$n',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _PaymentsTabBar extends StatelessWidget {
  final PaymentsController controller;

  const _PaymentsTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Obx(
        () => Row(
          children: [
            _TabItem(
              label: '${'payments.tabs.paid'.trns()} (${controller.paidCount})',
              isSelected: controller.selectedTab.value == 0,
              onTap: () => controller.changeTab(0),
            ),
            _TabItem(
              label:
                  '${'payments.tabs.unpaid'.trns()} (${controller.unpaidCount})',
              isSelected: controller.selectedTab.value == 1,
              onTap: () => controller.changeTab(1),
            ),
            _TabItem(
              label:
                  '${'payments.tabs.returned'.trns()} (${controller.returnedCount})',
              isSelected: controller.selectedTab.value == 2,
              onTap: () => controller.changeTab(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.secondary : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── States ──────────────────────────────────────────────────────────────────

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: 4,
      shrinkWrap: true,
      itemBuilder: (_, ___) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 12),
            Text(
              'payments.empty'.trns(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
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
              'payments.loadError'.trns(),
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
                  'payments.retry'.trns(),
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
