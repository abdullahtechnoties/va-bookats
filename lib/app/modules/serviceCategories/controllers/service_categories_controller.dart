// lib/app/modules/service_categories/controllers/service_categories_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/serviceCategories/repositories/service_category_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ServiceCategoriesController extends GetxController {
  ServiceCategoriesController({required ServiceCategoryRepository repository})
      : _repository = repository;

  final ServiceCategoryRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final ScrollController scrollController = ScrollController();

  final RxList<ServiceCategoryModel> categories = <ServiceCategoryModel>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  int _currentPage = 1;
  int _lastPage = 1;

  /// Branch selector (and branch label) is only shown to the owner role.
  bool get showBranch => _authService.isOwner;

  /// A single category is being mutated (delete / status change).
  final RxnInt busyCategoryId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchBranches();
    fetchFirstPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        hasMore.value &&
        !isLoadingMore.value) {
      loadMore();
    }
  }

  // ─── Fetching ────────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    final response = await _repository.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
    }
  }

  Future<void> fetchFirstPage() async {
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.getServiceCategories(page: 1);

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      SnackbarService.showError(
        title: 'serviceCategories.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    final page = response.data!;
    categories.assignAll(page.categories);
    branches.assignAll(page.branches);
    _currentPage = page.meta.currentPage;
    _lastPage = page.meta.lastPage;
    hasMore.value = page.meta.hasNextPage;
    isLoading.value = false;
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    final response = await _repository.getServiceCategories(page: 1);

    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      categories.assignAll(page.categories);
      branches.assignAll(page.branches);
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
    }
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    if (_currentPage >= _lastPage) {
      hasMore.value = false;
      return;
    }
    isLoadingMore.value = true;
    final next = _currentPage + 1;
    final response = await _repository.getServiceCategories(page: next);

    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      categories.addAll(page.categories);
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
    }
    isLoadingMore.value = false;
  }

  void retry() {
    fetchFirstPage();
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  Future<void> deleteCategory(ServiceCategoryModel category) async {
    final id = category.id;
    if (id == null) return;

    final confirmed = await _confirmDelete(category);
    if (confirmed != true) return;

    busyCategoryId.value = id;
    final response = await _repository.deleteServiceCategory(id);
    busyCategoryId.value = null;

    if (response.isCompleted) {
      categories.removeWhere((c) => c.id == id);
      SnackbarService.showSuccess(
        title: 'serviceCategories.deleteSuccessTitle'.trns(),
        message: 'serviceCategories.deleteSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'serviceCategories.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> updateStatus(ServiceCategoryModel category) async {
    final id = category.id;
    if (id == null) return;

    final newStatus = await _pickStatus(category);
    if (newStatus == null || newStatus == category.status) return;

    busyCategoryId.value = id;
    final response = await _repository.changeServiceCategoryStatus(
      id: id,
      status: newStatus,
    );
    busyCategoryId.value = null;

    if (response.isCompleted) {
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = categories[index].copyWith(status: newStatus);
      }
      SnackbarService.showSuccess(
        title: 'serviceCategories.statusSuccessTitle'.trns(),
        message: response.message ?? 'serviceCategories.statusSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'serviceCategories.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<bool?> _confirmDelete(ServiceCategoryModel category) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text('serviceCategories.deleteDialogTitle'.trns()),
        content: Text(
          'serviceCategories.deleteDialogMessage'.trnsFormat({
            'name': category.name ?? '',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('serviceCategories.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'serviceCategories.delete'.trns(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<String?> _pickStatus(ServiceCategoryModel category) {
    return Get.bottomSheet<String>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'serviceCategories.changeStatusTitle'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'serviceCategories.active'.trns(),
              isSelected: category.isActive,
              onTap: () => Get.back(result: 'active'),
            ),
            _StatusOption(
              label: 'serviceCategories.inactive'.trns(),
              isSelected: !category.isActive,
              onTap: () => Get.back(result: 'inactive'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void onFilter() {
    // TODO: open filter sheet
    print(_authService.currentUser.value?.roles?.first.name);
    print(_authService.isOwner);
    print("abc + $showBranch");
  }

  /// Opens the add/edit page and refreshes the list on return so freshly
  /// created / updated categories are reflected immediately.
  Future<void> openAddPage({ServiceCategoryModel? category}) async {
    await Get.toNamed(
      Routes.ADD_SERVICE_CATEGORY,
      arguments: category,
    );
    handleRefresh();
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.4)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
