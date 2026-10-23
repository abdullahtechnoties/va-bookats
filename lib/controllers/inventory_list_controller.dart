// lib/controllers/inventory_list_controller.dart
//
// Shared list logic for the inventory lookup modules (brands, product
// categories, tags, units, product variations). Each module extends this
// with its own resource base, permission noun, translation prefix and
// add-form route — the fetching / filtering / pagination / mutation
// behavior stays identical, mirroring serviceCategories.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/inventory_item.dart';
import 'package:va_bookats/models/product_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/network/api/api_path.dart';
import 'package:va_bookats/repositories/inventory_repository.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/filter_loader.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';
import 'package:va_bookats/widgets/status_picker_sheet.dart';

abstract class InventoryListController extends GetxController {
  final InventoryRepository _repository = InventoryRepository();
  final AuthService _authService = Get.find<AuthService>();
  final ScrollController scrollController = ScrollController();

  // ─── Module config ───────────────────────────────────────────────────────
  String get resourceBase;
  String get permResource;
  String get trPrefix;
  String get addRoute;

  String tr(String key) => '$trPrefix.$key'.trns();

  // ─── State ───────────────────────────────────────────────────────────────
  final RxList<InventoryItem> items = <InventoryItem>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<ProductLookup> parentCategories = <ProductLookup>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  /// Split busy ids so a status change never spins the delete icon.
  final RxnInt busyItemId = RxnInt();
  final RxnInt busyDeleteId = RxnInt();

  int _currentPage = 1;
  int _lastPage = 1;

  /// Bumped on every list request; stale responses never overwrite newer
  /// filter results or land in the wrong list.
  int _generation = 0;

  /// Branch selector (and branch label) is only shown to the owner role.
  bool get showBranch => _authService.isOwner;

  // ─── Filter state ────────────────────────────────────────────────────────
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final TextEditingController statusFilterCtrl = TextEditingController();
  final TextEditingController quickRangeCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;
  final RxString selectedStatusFilter = ''.obs;
  final RxString selectedQuickRange = ''.obs;
  final TextEditingController parentCategoryFilterCtrl =
      TextEditingController();
  final RxString selectedParentCategoryFilter = ''.obs;

  List<String> get parentCategoryFilterOptions => [
    ...parentCategories.map((category) => category.label),
  ];

  List<String> get branchFilterOptions => [
    // allBranchesKey,
    ...branches.map((b) => b.displayLabel),
  ];

  List<String> get statusFilterOptions => [tr('active'), tr('inactive')];

  String statusLabel(InventoryItem item) =>
      item.isActive ? tr('active') : tr('inactive');

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    for (final b in branches) {
      if (b.displayLabel == label) return b.value;
    }
    return null;
  }

  String? get _filterStatus {
    final v = selectedStatusFilter.value.trim();
    if (v.isEmpty) return null;
    if (v == tr('active')) return 'active';
    if (v == tr('inactive')) return 'inactive';
    return v.toLowerCase();
  }

  int? get _filterParentCategoryId {
    final label = selectedParentCategoryFilter.value;
    return parentCategories
        .firstWhereOrNull((category) => category.label == label)
        ?.value;
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
    if (selectedStatusFilter.value.isNotEmpty) n++;
    if (selectedQuickRange.value.isNotEmpty) n++;
    return n;
  }

  /// Branch lookups are fetched lazily — only when the filter sheet opens
  /// (see [openFilter]), never on controller init. The list response seeds
  /// [branches], so a separate call is rarely needed.
  final RxBool isFilterLoading = false.obs;
  bool _filterBranchesLoaded = false;
  bool _filterSheetOpen = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
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
    quickRangeCtrl.dispose();
    parentCategoryFilterCtrl.dispose();
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
    if (_filterBranchesLoaded && branches.isNotEmpty) return;
    final response = await _repository.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
      _filterBranchesLoaded = true;
    }
  }

  Future<void> fetchParentCategories() async {
    if (permResource != 'product-categories') return;
    final branchId = showBranch
        ? _filterBranchId
        : _authService.currentUser.value?.branchId;
    if (branchId == null) {
      parentCategories.clear();
      return;
    }

    final response = await _repository.fetchLookupOptions(
      ApiPath.dataProductCategories(branchId),
    );
    if (response.isCompleted && response.data != null) {
      parentCategories.assignAll(
        response.data!.where((category) => category.children.isNotEmpty),
      );
    } else {
      SnackbarService.showError(
        title: tr('errorTitle'),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  /// Ensures filter lookups are ready before the sheet opens, showing a
  /// graceful loader only while the (first) fetch is in flight.
  Future<void> ensureFilterData() async {
    final needsBranches =
        showBranch && (!_filterBranchesLoaded || branches.isEmpty);
    final needsParents =
        permResource == 'product-categories' && parentCategories.isEmpty;
    if (!needsBranches && !needsParents) return;
    isFilterLoading.value = true;
    try {
      if (needsBranches) await fetchBranches();
      if (needsParents) await fetchParentCategories();
    } finally {
      isFilterLoading.value = false;
    }
  }

  Future<void> fetchFirstPage() async {
    final gen = ++_generation;
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.fetchPage(
      base: resourceBase,
      page: 1,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      quickRange: _filterQuickRange,
      branchId: _filterBranchId,
      parentCategoryId: _filterParentCategoryId,
    );

    if (gen != _generation) return;
    isLoading.value = false;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      SnackbarService.showError(
        title: tr('errorTitle'),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    final page = response.data!;
    items.assignAll(page.items);
    // The list response seeds branches; only take them when the lazy
    // filter fetch hasn't populated anything yet.
    if (page.branches.isNotEmpty && branches.isEmpty) {
      branches.assignAll(page.branches);
      _filterBranchesLoaded = true;
    }
    _currentPage = page.meta.currentPage;
    _lastPage = page.meta.lastPage;
    hasMore.value = page.meta.hasNextPage;
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    await fetchFirstPage();
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    if (_currentPage >= _lastPage || isLoadingMore.value || isLoading.value) {
      return;
    }
    final gen = ++_generation;
    isLoadingMore.value = true;
    final response = await _repository.fetchPage(
      base: resourceBase,
      page: _currentPage + 1,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      quickRange: _filterQuickRange,
      branchId: _filterBranchId,
      parentCategoryId: _filterParentCategoryId,
    );

    if (gen != _generation) {
      isLoadingMore.value = false;
      return;
    }

    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      items.addAll(page.items);
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
    }
    isLoadingMore.value = false;
  }

  void retry() => fetchFirstPage();

  // ─── Filtering ───────────────────────────────────────────────────────────

  void openFilter(BuildContext context) async {
    if (_filterSheetOpen || isFilterLoading.value) return;

    final needsBranches =
        showBranch && (!_filterBranchesLoaded || branches.isEmpty);
    final needsParents =
        permResource == 'product-categories' && parentCategories.isEmpty;
    _filterSheetOpen = true;
    try {
      await runWithFilterLoader(
        () => ensureFilterData(),
        shouldShow: needsBranches || needsParents,
      );
      if (isClosed || !context.mounted) return;
      await _showFilterSheet(context);
    } finally {
      _filterSheetOpen = false;
    }
  }

  Future<void> _showFilterSheet(BuildContext context) {
    return FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: tr('filter.search'),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: tr('filter.quickRange'),
          type: FilterFieldType.dropdown,
          controller: quickRangeCtrl,
          dropdownItems: quickRangeOptions,
          selectedValue: selectedQuickRange,
        ),
        FilterField(
          label: tr('filter.fromDate'),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: tr('filter.toDate'),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: tr('filter.status'),
          type: FilterFieldType.dropdown,
          controller: statusFilterCtrl,
          dropdownItems: statusFilterOptions,
          selectedValue: selectedStatusFilter,
        ),
        if (showBranch)
          FilterField(
            label: tr('filter.branches'),
            type: FilterFieldType.dropdown,
            showSearch: true,
            controller: branchFilterCtrl,
            dropdownItems: branchFilterOptions,
            selectedValue: selectedBranchFilter,
          ),
        if (permResource == 'product-categories')
          FilterField(
            label: 'addProductCategory.parent'.trns(),
            type: FilterFieldType.dropdown,
            showSearch: true,
            controller: parentCategoryFilterCtrl,
            dropdownItems: parentCategoryFilterOptions,
            selectedValue: selectedParentCategoryFilter,
          ),
      ],
      onReset: resetFilters,
      onApply: applyFilters,
    );
  }

  Future<void> applyFilters() async {
    if (permResource == 'product-categories') {
      await fetchParentCategories();
    }
    fetchFirstPage();
  }

  void resetFilters() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    statusFilterCtrl.clear();
    quickRangeCtrl.clear();
    selectedBranchFilter.value = '';
    selectedStatusFilter.value = '';
    selectedQuickRange.value = '';
    parentCategoryFilterCtrl.clear();
    selectedParentCategoryFilter.value = '';
    fetchFirstPage();
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  Future<void> deleteItem(InventoryItem item) async {
    final id = item.id;
    if (id == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.white,
        title: Text(tr('deleteDialogTitle')),
        content: Text(
          '$trPrefix.deleteDialogMessage'.trnsFormat({'name': item.name ?? ''}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (confirmed != true) return;

    busyDeleteId.value = id;
    final response = await _repository.delete(base: resourceBase, id: id);
    busyDeleteId.value = null;

    if (response.isCompleted) {
      items.removeWhere((e) => e.id == id);
      SnackbarService.showSuccess(
        title: tr('deleteSuccessTitle'),
        message: response.message ?? tr('deleteSuccessMessage'),
      );
    } else {
      SnackbarService.showError(
        title: tr('errorTitle'),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> updateStatus(InventoryItem item) async {
    final id = item.id;
    if (id == null || busyItemId.value != null) return;

    final next = item.isActive ? 'inactive' : 'active';
    final picked = await showStatusPickerSheet(
      title: tr('changeStatusTitle'),
      activeLabel: tr('active'),
      inactiveLabel: tr('inactive'),
      isActive: item.isActive,
    );
    if (picked == null || picked == item.status) return;

    busyItemId.value = id;
    final response = await _repository.changeStatus(
      base: resourceBase,
      id: id,
      status: picked,
    );
    busyItemId.value = null;

    if (response.isCompleted) {
      final index = items.indexWhere((e) => e.id == id);
      if (index != -1) {
        items[index] = items[index].copyWith(status: response.data ?? next);
      }
      SnackbarService.showSuccess(
        title: tr('statusSuccessTitle'),
        message: response.message ?? tr('statusSuccessMessage'),
      );
    } else {
      SnackbarService.showError(
        title: tr('errorTitle'),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  /// Opens the add/edit form with the item as arguments (edit when
  /// non-null) and refreshes the list on return.
  Future<void> openAddPage({InventoryItem? item}) async {
    await Get.toNamed(addRoute, arguments: item);
    handleRefresh();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

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
}
