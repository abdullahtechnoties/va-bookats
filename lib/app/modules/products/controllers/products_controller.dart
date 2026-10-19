// lib/app/modules/products/controllers/products_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/products/repositories/product_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class ProductsController extends GetxController {
  ProductsController({required ProductRepository repository})
    : _repository = repository;

  final ProductRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final ScrollController scrollController = ScrollController();

  final RxInt selectedTab = 0.obs;
  final RxList<ProductModel> activeProducts = <ProductModel>[].obs;
  final RxList<ProductModel> inactiveProducts = <ProductModel>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  /// A single product is being mutated (delete / status change).
  /// Split so a status change never shows a loader on the delete icon.
  final RxnInt busyProductId = RxnInt();
  final RxnInt busyDeleteId = RxnInt();

  final Map<String, int> _currentPage = {};
  final Map<String, int> _lastPage = {};
  final Map<String, bool> _hasMoreMap = {};
  final Set<String> _loadedForStatus = {};

  /// Bumped on every list request. A response whose captured generation no
  /// longer matches has been superseded (filter applied / tab switched /
  /// refreshed) and must NOT be applied, otherwise stale data overwrites a
  /// newer result or lands in the wrong tab's list.
  int _generation = 0;

  // ─── Filter state ────────────────────────────────────────────────────────

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final TextEditingController quickRangeCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;
  final RxString selectedQuickRange = ''.obs;

  String get allBranchesKey => 'products.filter.allBranches'.trns();

  /// Branch name in the card and the filter dropdown only for owners.
  bool get showBranch => _authService.isOwner;

  List<ProductModel> get currentProducts =>
      selectedTab.value == 0 ? activeProducts : inactiveProducts;

  int get activeCount => activeProducts.length;
  int get inactiveCount => inactiveProducts.length;

  String get _statusKey => selectedTab.value == 0 ? 'active' : 'inactive';

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

  /// Capitalized for display; mapped to API values before hitting the API.
  /// No 'All' entry — an empty selection already means "no quick range".
  static const List<String> quickRangeOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
  ];

  String? get _filterQuickRange {
    final v = selectedQuickRange.value;
    if (v.isEmpty) return null;
    return v.toLowerCase().replaceAll(' ', '_');
  }

  int get appliedFiltersCount {
    var n = 0;
    if (searchCtrl.text.trim().isNotEmpty) n++;
    if (fromDateCtrl.text.trim().isNotEmpty) n++;
    if (toDateCtrl.text.trim().isNotEmpty) n++;
    if (selectedBranchFilter.value.isNotEmpty) n++;
    if (selectedQuickRange.value.isNotEmpty) n++;
    return n;
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
    quickRangeCtrl.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        hasMore.value &&
        !isLoadingMore.value &&
        !isLoading.value) {
      loadMore();
    }
  }

  // ─── Fetching ────────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    final response = await _repository.getBranches();
    if (response.isCompleted &&
        response.data != null &&
        response.data!.isNotEmpty) {
      branches.assignAll(response.data!);
    }
  }

  Future<void> fetchFirstPage() async {
    final key = _statusKey;
    final gen = ++_generation;
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.getProducts(
      page: 1,
      status: key,
      search: searchCtrl.text.trim(),
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      quickRange: _filterQuickRange,
      branchId: _filterBranchId,
    );

    // Superseded — a newer request (filter change / tab switch / refresh)
    // owns the screen now; ignore this stale result entirely.
    if (gen != _generation) return;

    isLoading.value = false;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      SnackbarService.showError(
        title: 'products.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    final page = response.data!;
    _applyPage(page, key: key, replace: true);
    if (page.branches.isNotEmpty) branches.assignAll(page.branches);
    _loadedForStatus.add(key);
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    await fetchFirstPage();
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    final key = _statusKey;
    final current = _currentPage[key] ?? 1;
    final last = _lastPage[key] ?? current;
    if (current >= last || isLoadingMore.value || isLoading.value) return;

    final gen = ++_generation;
    isLoadingMore.value = true;
    final response = await _repository.getProducts(
      page: current + 1,
      status: key,
      search: searchCtrl.text.trim(),
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      quickRange: _filterQuickRange,
      branchId: _filterBranchId,
    );

    // Superseded — drop the stale page so it never appends onto a reloaded
    // or re-filtered list (and never crosses into another tab's list).
    if (gen != _generation) {
      isLoadingMore.value = false;
      return;
    }

    if (response.isCompleted && response.data != null) {
      _applyPage(response.data!, key: key, replace: false);
    }
    isLoadingMore.value = false;
  }

  void _applyPage(
    ProductsPage page, {
    required String key,
    required bool replace,
  }) {
    final list = key == 'active' ? activeProducts : inactiveProducts;
    _currentPage[key] = page.meta.currentPage;
    _lastPage[key] = page.meta.lastPage;
    _hasMoreMap[key] = page.meta.hasNextPage;
    // Only touch the visible load-more indicator for the tab on screen.
    if (key == _statusKey) {
      hasMore.value = page.meta.hasNextPage;
    }
    if (replace) {
      list.assignAll(page.products);
    } else {
      list.addAll(page.products);
    }
  }

  void retry() {
    fetchFirstPage();
  }

  // ─── Tab switching ───────────────────────────────────────────────────────

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    // Reset filters on tab change so the other tab never inherits stale state.
    resetFilters(silent: true);
    selectedTab.value = index;
    hasMore.value = _hasMoreMap[_statusKey] ?? false;
    _generation++;
    final hasLoaded = _loadedForStatus.contains(_statusKey);
    if (!hasLoaded) {
      fetchFirstPage();
    }
  }

  // ─── Filtering ───────────────────────────────────────────────────────────

  void openFilter(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'products.filter.search'.trns(),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: 'products.filter.quickRange'.trns(),
          type: FilterFieldType.dropdown,
          controller: quickRangeCtrl,
          dropdownItems: quickRangeOptions,
          selectedValue: selectedQuickRange,
        ),
        FilterField(
          label: 'products.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'products.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        if (showBranch)
          FilterField(
            label: 'products.filter.branches'.trns(),
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

  void _clearPagination() {
    _loadedForStatus.clear();
    _currentPage.clear();
    _lastPage.clear();
    _hasMoreMap.clear();
  }

  void applyFilters() {
    _clearPagination();
    fetchFirstPage();
  }

  void resetFilters({bool silent = false}) {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    quickRangeCtrl.clear();
    selectedBranchFilter.value = '';
    selectedQuickRange.value = '';
    _clearPagination();
    if (silent) return;
    fetchFirstPage();
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  Future<void> deleteProduct(ProductModel product) async {
    final id = product.id;
    if (id == null) return;

    final confirmed = await _confirmDelete(product);
    if (confirmed != true) return;

    busyDeleteId.value = id;
    final response = await _repository.deleteProduct(id);
    busyDeleteId.value = null;

    if (response.isCompleted) {
      activeProducts.removeWhere((p) => p.id == id);
      inactiveProducts.removeWhere((p) => p.id == id);
      SnackbarService.showSuccess(
        title: 'products.deleteSuccessTitle'.trns(),
        message: response.message ?? 'products.deleteSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'products.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> updateStatus(ProductModel product) async {
    final id = product.id;
    if (id == null) return;

    final newStatus = await _pickStatus(product);
    if (newStatus == null || newStatus == product.status) return;

    busyProductId.value = id;
    final response = await _repository.changeProductStatus(
      id: id,
      status: newStatus,
    );
    busyProductId.value = null;

    if (response.isCompleted) {
      _updateLocalStatus(product, newStatus);
      SnackbarService.showSuccess(
        title: 'products.statusSuccessTitle'.trns(),
        message: response.message ?? 'products.statusSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'products.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  void _updateLocalStatus(ProductModel product, String newStatus) {
    final updated = product.copyWith(status: newStatus);
    activeProducts.removeWhere((p) => p.id == product.id);
    inactiveProducts.removeWhere((p) => p.id == product.id);
    final target = newStatus == 'active' ? activeProducts : inactiveProducts;
    target.insert(0, updated);
  }

  Future<bool?> _confirmDelete(ProductModel product) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text('products.deleteDialogTitle'.trns()),
        content: Text(
          'products.deleteDialogMessage'.trnsFormat({
            'name': product.name ?? '',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('products.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'products.delete'.trns(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<String?> _pickStatus(ProductModel product) {
    return Get.bottomSheet<String>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'products.changeStatusTitle'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'products.card.active'.trns(),
              isSelected: product.isActive,
              onTap: () => Get.back(result: 'active'),
            ),
            _StatusOption(
              label: 'products.card.inactive'.trns(),
              isSelected: !product.isActive,
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

  /// Opens the add/edit page and refreshes the list on return so freshly
  /// created / updated products are reflected immediately.
  Future<void> openAddPage({ProductModel? product}) async {
    await Get.toNamed(Routes.ADD_PRODUCT, arguments: product);
    handleRefresh();
  }

  /// Opens the product details page and refreshes on return so status /
  /// delete changes made there are reflected immediately.
  Future<void> openDetails(ProductModel product) async {
    if (product.id == null) return;
    await Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product.id);
    handleRefresh();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Converts the sheet's display date ("Aug/1/2026") to an API-safe
  /// "YYYY-MM-DD" string, or null when blank / unparseable.
  String? _toApiDate(String text) {
    if (text.isEmpty) return null;
    final parts = text.split('/');
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
