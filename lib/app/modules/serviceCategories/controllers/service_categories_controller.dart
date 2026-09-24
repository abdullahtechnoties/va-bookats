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
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

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
  final RxnInt busyDeleteId = RxnInt();

  // ─── Filter + search (same CRUD pattern as services/packages) ──────────
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final TextEditingController statusFilterCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;
  final RxString selectedStatusFilter = ''.obs;

  List<String> get statusOptions => [
    'All',
    'serviceCategories.active'.trns(),
    'serviceCategories.inactive'.trns(),
  ];

  String get allBranchesKey => 'serviceCategories.filter.allBranches'.trns();

  List<String> get branchFilterOptions => [
    allBranchesKey,
    ...branches.map((b) => b.displayLabel),
  ];

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    if (label.isEmpty || label == allBranchesKey) return null;
    for (final b in branches) {
      if (b.displayLabel == label) return b.value;
    }
    return null;
  }

  int get appliedFiltersCount {
    var n = 0;
    if (searchCtrl.text.trim().isNotEmpty) n++;
    if (fromDateCtrl.text.trim().isNotEmpty) n++;
    if (toDateCtrl.text.trim().isNotEmpty) n++;
    if (selectedBranchFilter.value.isNotEmpty) n++;
    if (selectedStatusFilter.value.isNotEmpty) n++;
    return n;
  }

  String? get _filterStatus {
    final value = selectedStatusFilter.value.trim();
    if (value.isEmpty || value == statusOptions.first) return null;
    if (value == statusOptions[1]) return 'active';
    if (value == statusOptions[2]) return 'inactive';
    return value.toLowerCase();
  }

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
    searchCtrl.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    branchFilterCtrl.dispose();
    statusFilterCtrl.dispose();
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
    final response = await _repository.getServiceCategories(
      page: 1,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      branchId: _filterBranchId,
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
    );

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
    final response = await _repository.getServiceCategories(
      page: 1,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      branchId: _filterBranchId,
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
    );

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
    final response = await _repository.getServiceCategories(
      page: next,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      branchId: _filterBranchId,
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
    );

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

    busyDeleteId.value = id;
    final response = await _repository.deleteServiceCategory(id);
    busyDeleteId.value = null;

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
        message:
            response.message ?? 'serviceCategories.statusSuccessMessage'.trns(),
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

  void onFilter(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'serviceCategories.filter.search'.trns(),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: 'serviceCategories.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'serviceCategories.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: 'serviceCategories.filter.status'.trns(),
          type: FilterFieldType.dropdown,
          controller: statusFilterCtrl,
          dropdownItems: statusOptions,
          selectedValue: selectedStatusFilter,
        ),
        if (showBranch)
          FilterField(
            label: 'serviceCategories.filter.branches'.trns(),
            type: FilterFieldType.dropdown,
            controller: branchFilterCtrl,
            dropdownItems: branchFilterOptions,
            selectedValue: selectedBranchFilter,
          ),
      ],
      onReset: resetFilters,
      onApply: applyFilters,
    );
  }

  void applyFilters() => fetchFirstPage();

  void resetFilters() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    statusFilterCtrl.clear();
    selectedBranchFilter.value = '';
    selectedStatusFilter.value = '';
    fetchFirstPage();
  }

  String? _toApiDate(String text) {
    if (text.trim().isEmpty) return null;
    final parts = text.trim().split('/');
    if (parts.length != 3) return null;
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months.indexOf(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month < 1 || day == null || year == null) return null;
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Opens the add/edit page and refreshes the list on return so freshly
  /// created / updated categories are reflected immediately.
  Future<void> openAddPage({ServiceCategoryModel? category}) async {
    await Get.toNamed(Routes.ADD_SERVICE_CATEGORY, arguments: category);
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
