// lib/app/modules/services/controllers/services_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/services/repositories/service_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/models/service_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class ServicesController extends GetxController {
  ServicesController({required ServiceRepository repository})
      : _repository = repository;

  final ServiceRepository _repository;
  final AuthService _authService = Get.find<AuthService>();
  final ScrollController scrollController = ScrollController();

  final RxInt selectedTab = 0.obs;
  final RxList<ServiceModel> activeServices = <ServiceModel>[].obs;
  final RxList<ServiceModel> inactiveServices = <ServiceModel>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<ServiceCategoryModel> categories = <ServiceCategoryModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  /// A single service is being mutated (delete / status change).
  final RxnInt busyServiceId = RxnInt();

  final Map<String, int> _currentPage = {};
  final Map<String, int> _lastPage = {};
  final Map<String, bool> _hasMoreMap = {};
  final Set<String> _loadedForStatus = {};

  // ─── Filter state ────────────────────────────────────────────────────────

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final TextEditingController typeFilterCtrl = TextEditingController();
  final TextEditingController categoryFilterCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;
  final RxString selectedTypeFilter = ''.obs;
  final RxString selectedCategoryFilter = ''.obs;

  String get allBranchesKey => 'services.filter.allBranches'.trns();
  String get allTypesKey => 'services.filter.allTypes'.trns();
  String get allCategoriesKey => 'services.filter.allCategories'.trns();

  bool get showBranch => _authService.isOwner;

  List<ServiceModel> get currentServices =>
      selectedTab.value == 0 ? activeServices : inactiveServices;

  int get activeCount => activeServices.length;
  int get inactiveCount => inactiveServices.length;

  String get _statusKey => selectedTab.value == 0 ? 'active' : 'inactive';

  RxList<ServiceModel> get _listForStatus {
    return selectedTab.value == 0 ? activeServices : inactiveServices;
  }

  List<String> get branchFilterOptions =>
      [allBranchesKey, ...branches.map((b) => b.displayLabel)];

  List<String> get typeFilterOptions => [allTypesKey, 'normal', 'variation'];

  List<String> get categoryFilterOptions =>
      [allCategoriesKey, ...categories.map((c) => c.name ?? '')];

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    if (label.isEmpty || label == allBranchesKey) return null;
    for (final b in branches) {
      if (b.displayLabel == label) return b.value;
    }
    return null;
  }

  int? get _filterCategoryId {
    final label = selectedCategoryFilter.value;
    if (label.isEmpty || label == allCategoriesKey) return null;
    for (final c in categories) {
      if (c.name == label) return c.id;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchBranches();
    fetchCategories();
    fetchFirstPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchCtrl.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    branchFilterCtrl.dispose();
    typeFilterCtrl.dispose();
    categoryFilterCtrl.dispose();
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

  Future<void> fetchCategories() async {
    final response = await _repository.getCategories();
    if (response.isCompleted &&
        response.data != null &&
        response.data!.isNotEmpty) {
      categories.assignAll(response.data!);
    }
  }

  Future<void> fetchFirstPage() async {
    final key = _statusKey;
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.getServices(
      page: 1,
      status: key,
      search: searchCtrl.text.trim(),
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      branchId: _filterBranchId,
      type: selectedTypeFilter.value.isEmpty ||
              selectedTypeFilter.value == allTypesKey
          ? null
          : selectedTypeFilter.value,
      categoryId: _filterCategoryId,
    );

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      SnackbarService.showError(
        title: 'services.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    final page = response.data!;
    _applyPage(page, replace: true);
    if (page.branches.isNotEmpty) branches.assignAll(page.branches);
    if (page.categories.isNotEmpty) categories.assignAll(page.categories);
    _loadedForStatus.add(key);
    isLoading.value = false;
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
    if (current >= last || isLoadingMore.value) return;

    isLoadingMore.value = true;
    final response = await _repository.getServices(
      page: current + 1,
      status: key,
      search: searchCtrl.text.trim(),
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      branchId: _filterBranchId,
      type: selectedTypeFilter.value.isEmpty ||
              selectedTypeFilter.value == allTypesKey
          ? null
          : selectedTypeFilter.value,
      categoryId: _filterCategoryId,
    );

    if (response.isCompleted && response.data != null) {
      _applyPage(response.data!, replace: false);
    }
    isLoadingMore.value = false;
  }

  void _applyPage(ServicesPage page, {required bool replace}) {
    final key = _statusKey;
    final list = _listForStatus;
    _currentPage[key] = page.meta.currentPage;
    _lastPage[key] = page.meta.lastPage;
    _hasMoreMap[key] = page.meta.hasNextPage;
    hasMore.value = page.meta.hasNextPage;
    if (replace) {
      list.assignAll(page.services);
    } else {
      list.addAll(page.services);
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

  void onFilter() {
    FilterBottomSheet.show(
      Get.context!,
      fields: [
        FilterField(
          label: 'services.filter.search'.trns(),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: 'services.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'services.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: 'services.filter.branches'.trns(),
          type: FilterFieldType.dropdown,
          controller: branchFilterCtrl,
          dropdownItems: branchFilterOptions,
          selectedValue: selectedBranchFilter,
        ),
        FilterField(
          label: 'services.filter.type'.trns(),
          type: FilterFieldType.dropdown,
          controller: typeFilterCtrl,
          dropdownItems: typeFilterOptions,
          selectedValue: selectedTypeFilter,
        ),
        FilterField(
          label: 'services.filter.category'.trns(),
          type: FilterFieldType.dropdown,
          controller: categoryFilterCtrl,
          dropdownItems: categoryFilterOptions,
          selectedValue: selectedCategoryFilter,
        ),
      ],
      onReset: resetFilters,
      onApply: applyFilters,
    );
  }

  void applyFilters() {
    _loadedForStatus.clear();
    fetchFirstPage();
  }

  void resetFilters() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    typeFilterCtrl.clear();
    categoryFilterCtrl.clear();
    selectedBranchFilter.value = '';
    selectedTypeFilter.value = '';
    selectedCategoryFilter.value = '';
    _loadedForStatus.clear();
    fetchFirstPage();
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  Future<void> deleteService(ServiceModel service) async {
    final id = service.id;
    if (id == null) return;

    final confirmed = await _confirmDelete(service);
    if (confirmed != true) return;

    busyServiceId.value = id;
    final response = await _repository.deleteService(id);
    busyServiceId.value = null;

    if (response.isCompleted) {
      activeServices.removeWhere((s) => s.id == id);
      inactiveServices.removeWhere((s) => s.id == id);
      SnackbarService.showSuccess(
        title: 'services.deleteSuccessTitle'.trns(),
        message: response.message ?? 'services.deleteSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'services.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> updateStatus(ServiceModel service) async {
    final id = service.id;
    if (id == null) return;

    final newStatus = await _pickStatus(service);
    if (newStatus == null || newStatus == service.status) return;

    busyServiceId.value = id;
    final response = await _repository.changeServiceStatus(
      id: id,
      status: newStatus,
    );
    busyServiceId.value = null;

    if (response.isCompleted) {
      _updateLocalStatus(service, newStatus);
      SnackbarService.showSuccess(
        title: 'services.statusSuccessTitle'.trns(),
        message: response.message ?? 'services.statusSuccessMessage'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'services.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  void _updateLocalStatus(ServiceModel service, String newStatus) {
    final updated = service.copyWith(status: newStatus);
    activeServices.removeWhere((s) => s.id == service.id);
    inactiveServices.removeWhere((s) => s.id == service.id);
    final target = newStatus == 'active' ? activeServices : inactiveServices;
    target.insert(0, updated);
  }

  Future<bool?> _confirmDelete(ServiceModel service) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text('services.deleteDialogTitle'.trns()),
        content: Text(
          'services.deleteDialogMessage'.trnsFormat({
            'name': service.name ?? '',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('services.cancel'.trns()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'services.delete'.trns(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<String?> _pickStatus(ServiceModel service) {
    return Get.bottomSheet<String>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'services.changeStatusTitle'.trns(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'services.card.active'.trns(),
              isSelected: service.isActive,
              onTap: () => Get.back(result: 'active'),
            ),
            _StatusOption(
              label: 'services.card.inactive'.trns(),
              isSelected: !service.isActive,
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
  /// created / updated services are reflected immediately.
  Future<void> openAddPage({ServiceModel? service}) async {
    await Get.toNamed(Routes.ADD_SERVICE, arguments: service);
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