// lib/app/modules/products/views/products_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/products/controllers/products_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/product-card.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _ProductsHeader(controller: controller),
          _ProductsTabBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.currentProducts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }
              if (controller.loadFailed.value &&
                  controller.currentProducts.isEmpty) {
                return _ErrorState(onRetry: controller.retry);
              }
              return RefreshIndicator(
                onRefresh: controller.handleRefresh,
                color: AppColors.secondary,
                child: ListView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 14, bottom: 30),
                  children: [
                    // Add New Product button
                    Can(
                      AppPerm.create(AppPerm.products),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                                  'products.addNew'.trns(),
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
                    ),

                    if (controller.currentProducts.isEmpty)
                      _ProductsEmptyState()
                    else
                      ...controller.currentProducts.map(
                        (product) => ProductCard(
                          product: product,
                          isBusy:
                              controller.busyProductId.value == product.id,
                          isDeleting:
                              controller.busyDeleteId.value == product.id,
                          onEdit: () => controller.openEditPage(product),
                          onViewDetails: () =>
                              controller.openDetails(product),
                          onDelete: () => controller.deleteProduct(product),
                          onStatusTap: () =>
                              controller.updateStatus(product),
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

class _ProductsHeader extends StatelessWidget {
  final ProductsController controller;

  const _ProductsHeader({required this.controller});

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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
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
                  'products.title'.trns(),
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
              Can(
                AppPerm.create(AppPerm.products),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _ProductsTabBar extends StatelessWidget {
  final ProductsController controller;

  const _ProductsTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Obx(
        () => Row(
          children: [
            _TabItem(
              label:
                  '${'products.tabs.active'.trns()} (${controller.activeCount})',
              isSelected: controller.selectedTab.value == 0,
              onTap: () => controller.changeTab(0),
            ),
            _TabItem(
              label:
                  '${'products.tabs.inactive'.trns()} (${controller.inactiveCount})',
              isSelected: controller.selectedTab.value == 1,
              onTap: () => controller.changeTab(1),
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
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.black : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _ProductsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 16),
            Text(
              'products.empty'.trns(),
              style: const TextStyle(
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

// ─── Error State ─────────────────────────────────────────────────────────────

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
            const Icon(Icons.error_outline, size: 60, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            Text(
              'products.loadError'.trns(),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                child: Text(
                  'products.retry'.trns(),
                  style: const TextStyle(
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
