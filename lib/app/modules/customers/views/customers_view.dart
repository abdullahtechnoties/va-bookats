// lib/app/modules/customers/views/customers_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/customers/controllers/customers_controller.dart';
import 'package:va_bookats/app/modules/customers/views/widgets/customer-card.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _CustomersHeader(controller: controller),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.customers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }
              if (controller.loadFailed.value && controller.customers.isEmpty) {
                return _CustomersErrorState(onRetry: controller.retry);
              }
              return RefreshIndicator(
                color: AppColors.secondary,
                onRefresh: controller.handleRefresh,
                child: ListView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 14, bottom: 30),
                  children: [
                    // Date Filter Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _DateFilterBar(controller: controller),
                    ),

                    // Add New Customer button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: GestureDetector(
                        onTap: () => controller.openAddPage(),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'customers.addNewCustomer'.trns(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Total Customer count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'customers.totalCustomer'.trns(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.totalCustomers.value}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Customer Cards
                    if (controller.customers.isEmpty)
                      const _CustomersEmptyState()
                    else
                      ...controller.customers.map(
                        (customer) => CustomerCard(
                          customer: customer,
                          isBusy:
                              controller.busyCustomerId.value == customer.id,
                          isDeleting:
                              controller.busyDeleteId.value == customer.id,
                          onTap: () =>
                              controller.openAddPage(customer: customer),
                          onEdit: () =>
                              controller.openAddPage(customer: customer),
                          onDelete: () => controller.deleteCustomer(customer),
                          onStatusTap: () => controller.toggleStatus(customer),
                        ),
                      ),

                    if (controller.isLoadingMore.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  ],
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

class _CustomersHeader extends StatelessWidget {
  final CustomersController controller;

  const _CustomersHeader({required this.controller});

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
                  'customers.title'.trns(),
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
                      final n = controller.appliedFiltersCount.value;
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
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.openAddPage(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date Filter Bar ──────────────────────────────────────────────────────────

class _DateFilterBar extends StatelessWidget {
  final CustomersController controller;

  const _DateFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final range = controller.displayDateRange.value;
                    final search = controller.searchCtrl.text.trim();
                    final label = range.isNotEmpty
                        ? range
                        : (search.isNotEmpty ? search : 'Filter');
                    return Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => controller.openFilter(context),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _CustomersEmptyState extends StatelessWidget {
  const _CustomersEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 60, color: Color(0xFFCCCCCC)),
            SizedBox(height: 16),
            Text(
              'No customers found',
              style: TextStyle(
                fontSize: 16,
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

class _CustomersErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _CustomersErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            const Text(
              'Failed to load customers.\nPull to refresh or try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14,
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
