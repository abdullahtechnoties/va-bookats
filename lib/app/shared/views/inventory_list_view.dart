// lib/app/shared/views/inventory_list_view.dart
//
// One list screen for all inventory lookup modules (brands, product
// categories, tags, units, product variations). Behavior mirrors
// serviceCategories: header with filter badge + add, add button, cards,
// loader / empty / error / load-more states — all permission-gated.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/controllers/inventory_list_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/orange-header.dart';

class InventoryListView<C extends InventoryListController>
    extends GetView<C> {
  final String titleKey;
  final String addLabelKey;
  final String emptyKey;
  final IconData emptyIcon;
  final bool showImage;

  const InventoryListView({
    super.key,
    required this.titleKey,
    required this.addLabelKey,
    required this.emptyKey,
    required this.emptyIcon,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final createPerm = AppPerm.create(controller.permResource);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Obx(
            () => OrangeHeader(
              title: titleKey.trns(),
              onFilter: () => controller.openFilter(context),
              onAdd: Permissions.can(createPerm)
                  ? () => controller.openAddPage()
                  : null,
              filterCount: controller.appliedFiltersCount,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.items.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator());
              }
              if (controller.loadFailed.value &&
                  controller.items.isEmpty) {
                return _ErrorState(
                  onRetry: controller.retry,
                  loadError: controller.tr('loadError'),
                  retryLabel: controller.tr('retry'),
                );
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
                    Can(
                      createPerm,
                      child: Column(
                        children: [
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
                                          alpha: 0.25),
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
                                    addLabelKey.trns(),
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
                        ],
                      ),
                    ),
                    if (controller.items.isEmpty)
                      _EmptyState(
                        icon: emptyIcon,
                        message: emptyKey.trns(),
                      )
                    else
                      ...controller.items.map(
                        (item) => InventoryItemCard(
                          imageUrl: showImage
                              ? (item.displayUrl ?? '')
                              : '',
                          showImage: showImage,
                          status: controller.statusLabel(item),
                          name: item.name ?? '',
                          branch: item.branchName,
                          showBranch: controller.showBranch,
                          onDetails: () =>
                              controller.openAddPage(item: item),
                          onEdit: () =>
                              controller.openAddPage(item: item),
                          onDelete: () => controller.deleteItem(item),
                          onStatusTap: () =>
                              controller.updateStatus(item),
                          isBusy:
                              controller.busyItemId.value == item.id,
                          isDeleting:
                              controller.busyDeleteId.value == item.id,
                          detailsPermission:
                              AppPerm.show(controller.permResource),
                          editPermission:
                              AppPerm.edit(controller.permResource),
                          deletePermission:
                              AppPerm.destroy(controller.permResource),
                          statusPermission:
                              AppPerm.update(controller.permResource),
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
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 60, color: const Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            Text(
              message,
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
  final String loadError;
  final String retryLabel;

  const _ErrorState({
    required this.onRetry,
    required this.loadError,
    required this.retryLabel,
  });

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
            loadError,
            textAlign: TextAlign.center,
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
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
