// lib/app/modules/service_categories/views/service_categories_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/serviceCategories/controllers/service_categories_controller.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ServiceCategoriesView extends GetView<ServiceCategoriesController> {
  const ServiceCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _ServiceCategoriesHeader(controller: controller),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.loadFailed.value &&
                    controller.categories.isEmpty) {
                  return _ErrorState(onRetry: controller.retry);
                }
return RefreshIndicator(
                      color: AppColors.secondary,
                      onRefresh: controller.handleRefresh,
                  child: ListView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                    children: [
                      // Add New Category Button
                      GestureDetector(
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
                                'serviceCategories.addNewCategory'.trns(),
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
                      const SizedBox(height: 16),

                      // Category Cards
                      if (controller.categories.isEmpty)
                        const _EmptyCategoryState()
                      else
                        ...controller.categories.map(
                          (cat) => _CategoryCard(
                            category: cat,
                            showBranch: controller.showBranch,
                            isBusy:
                                controller.busyCategoryId.value == cat.id,
                            onDelete: () =>
                                controller.deleteCategory(cat),
                            onEdit: () =>
                                controller.openAddPage(category: cat),
                            onStatusTap: () =>
                                controller.updateStatus(cat),
                          ),
                        ),
                      if (controller.isLoadingMore.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ServiceCategoriesHeader extends StatelessWidget {
  final ServiceCategoriesController controller;

  const _ServiceCategoriesHeader({required this.controller});

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
                  'serviceCategories.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: controller.onFilter,
              //   child: const Icon(
              //     Icons.filter_alt_outlined,
              //     color: AppColors.white,
              //     size: 22,
              //   ),
              // ),
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

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final ServiceCategoryModel category;
  final bool showBranch;
  final bool isBusy;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onStatusTap;

  const _CategoryCard({
    required this.category,
    required this.showBranch,
    required this.isBusy,
    this.onDelete,
    this.onEdit,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Branch
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                if (showBranch && category.branchName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    category.branchName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right: Status + Icons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Status badge (tappable → change status)
              GestureDetector(
                onTap: isBusy ? null : onStatusTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.statusDisplay,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Delete + Edit Icons
              Row(
                children: [
                  GestureDetector(
                    onTap: isBusy ? null : onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 22,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: isBusy ? null : onEdit,
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 22,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.category_outlined, size: 60, color: Color(0xFFCCCCCC)),
            SizedBox(height: 16),
            Text(
              'No categories found',
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

// ─── Error State ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            'serviceCategories.loadError'.trns(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('serviceCategories.retry'.trns()),
          ),
        ],
      ),
    );
  }
}
