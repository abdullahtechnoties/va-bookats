// lib/app/modules/packages/controllers/packages_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/packages/repositories/package_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/package_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class PackagesController extends GetxController {
  PackagesController({required PackageRepository repository})
      : _repository = repository;

  final PackageRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final ScrollController scrollController = ScrollController();

  final RxInt selectedTab = 0.obs;
  final RxList<PackageModel> activePackages = <PackageModel>[].obs;
  final RxList<PackageModel> inactivePackages = <PackageModel>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  /// A single package is being mutated (delete / status change).
  final RxnInt busyPackageId = RxnInt();

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
  final RxString selectedBranchFilter = ''.obs;

  String get allBranchesKey => 'packages.filter.allBranches'.trns();

  /// Branch name in the card and the filter dropdown only for owners.
  bool get showBranch => _authService.isOwner;

  List<PackageModel> get currentPackages =>
      selectedTab.value == 0 ? activePackages : inactivePackages;

  int get activeCount => activePackages.length;
  int get inactiveCount => inactivePackages.length;

  String get _statusKey => selectedTab.value == 0 ? 'active' : 'inactive';

  List<String> get branchFilterOptions =>
      [allBranchesKey, ...branches.map((b) => b.displayLabel)];

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    if (label.isEmpty || label == allBranchesKey) return null;
    for (final b in branches) {
      if (b.displayLabel == label) return b.value;
    }
    return null;
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
    super.onClose();
  }

  void _onScroll() {
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
    final response = await _repository.getPackages(
      page: 1,
      status: key,
      search: searchCtrl.text.trim(),
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      branchId: _filterBranchId,
    );

    // Superseded — a newer request (filter change / tab switch / refresh)
    // owns the screen now; ignore this stale result entirely.
    if (gen != _generation) return;

    isLoading.value = false;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      SnackbarService.showError(
        title: 'packages.errorTitle'.trns(),
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
    final response = await _repository.getPackages(
      page: current + 1,
      status: key,
      search: searchCtrl.text.trim(),
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
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

  void _applyPage(PackagesPage page, {required String key, required bool replace}) {
    final list = key == 'active' ? activePackages : inactivePackages;
    _currentPage[key] = page.meta.currentPage;
    _lastPage[key] = page.meta.lastPage;
    _hasMoreMap[key] = page.meta.hasNextPage;
    // Only touch the visible load-more indicator for the tab on screen.
    if (key == _statusKey) {
      hasMore.value = page.meta.hasNextPage;
    }
    if (replace) {
      list.assignAll(page.packages);
    } else {
      list.addAll(page.packages);
    }
  }

  void retry() {
    fetchFirstPage();
  }

  // ─── Tab switching ───────────────────────────────────────────────────────

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    hasMore.value = _hasMoreMap[_statusKey] ?? false;
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
          label: 'packages.filter.search'.trns(),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: 'packages.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'packages.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        if (showBranch)
          FilterField(
            label: 'packages.filter.branches'.trns(),
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

  void resetFilters() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    selectedBranchFilter.value = '';
    _clearPagination();
    fetchFirstPage();
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  Future<void> deletePackage(PackageModel package) async {
    final id = package.id;
    if (id == null) return;

    final confirmed = await _confirmDelete(package);
    if (confirmed != true) return;

    busyPackageId.value = id;
    final response = await _repository.deletePackage(id);
    busyPackageId.value = null;

    if (response.isCompleted) {
      activePackages.removeWhere((p) => p.id == id);
      inactivePackages.removeWhere((p) => p.id == id);
      SnackbarService.showSuccess(
        title: 'packages.deleteSuccessTitle'.trns(),
        message: response.message ?? 'packages.deleteSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'packages.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> updateStatus(PackageModel package) async {
    final id = package.id;
    if (id == null) return;

    final newStatus = await _pickStatus(package);
    if (newStatus == null || newStatus == package.status) return;

    busyPackageId.value = id;
    final response = await _repository.changePackageStatus(
      id: id,
      status: newStatus,
    );
    busyPackageId.value = null;

    if (response.isCompleted) {
      _updateLocalStatus(package, newStatus);
      SnackbarService.showSuccess(
        title: 'packages.statusSuccessTitle'.trns(),
        message: response.message ?? 'packages.statusSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'packages.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  void _updateLocalStatus(PackageModel package, String newStatus) {
    final updated = package.copyWith(status: newStatus);
    activePackages.removeWhere((p) => p.id == package.id);
    inactivePackages.removeWhere((p) => p.id == package.id);
    final target = newStatus == 'active' ? activePackages : inactivePackages;
    target.insert(0, updated);
  }

  Future<bool?> _confirmDelete(PackageModel package) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text('packages.deleteDialogTitle'.trns()),
        content: Text(
          'packages.deleteDialogMessage'.trnsFormat({
            'name': package.name ?? '',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('packages.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'packages.delete'.trns(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<String?> _pickStatus(PackageModel package) {
    return Get.bottomSheet<String>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'packages.changeStatusTitle'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'packages.card.active'.trns(),
              isSelected: package.isActive,
              onTap: () => Get.back(result: 'active'),
            ),
            _StatusOption(
              label: 'packages.card.inactive'.trns(),
              isSelected: !package.isActive,
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
  /// created / updated packages are reflected immediately.
  Future<void> openAddPage({PackageModel? package}) async {
    await Get.toNamed(Routes.ADD_PACKAGE, arguments: package);
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
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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