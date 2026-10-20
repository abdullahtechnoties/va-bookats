// lib/app/modules/payments/controllers/payments_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/payments/repositories/payment_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/payment_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/filter_loader.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class PaymentsController extends GetxController {
  PaymentsController({PaymentRepository? repository})
    : _repository = repository;

  final PaymentRepository? _repository;
  PaymentRepository get _repo {
    final r = _repository;
    if (r != null) return r;
    if (Get.isRegistered<PaymentRepository>()) {
      return Get.find<PaymentRepository>();
    }
    return PaymentRepository();
  }

  final AuthService _auth = Get.find<AuthService>();
  bool get showBranch => _auth.isOwner;

  final ScrollController scrollController = ScrollController();

  // Tabs: Paid | Unpaid | Returned.
  final RxInt selectedTab = 0.obs;

  static const List<String> _tabStatuses = ['Paid', 'Unpaid', 'Return'];
  final List<RxList<PaymentModel>> _paymentsByTab = List.generate(
    3,
    (_) => <PaymentModel>[].obs,
  );
  final List<bool> _tabLoaded = List.filled(3, false);
  final List<int> _currentPageByTab = List.filled(3, 1);
  final List<int> _lastPageByTab = List.filled(3, 1);
  final List<bool> _hasMoreByTab = List.filled(3, false);
  final List<int> _generationByTab = List.filled(3, 0);

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  // ─── Search (inside the filter sheet) ────────────────────────────────────
  final TextEditingController searchCtrl = TextEditingController();

  // ─── Filters ─────────────────────────────────────────────────────────────
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final TextEditingController quickRangeCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;
  final RxString selectedQuickRange = ''.obs;

  final RxList<BranchModel> branches = <BranchModel>[].obs;

  /// Branch lookups are fetched lazily — only when the filter sheet opens
  /// (see [openFilter]), never on controller init.
  final RxBool isFilterLoading = false.obs;
  bool _filterBranchesLoaded = false;

  List<PaymentModel> paymentsForTab(int index) => _paymentsByTab[index];

  List<PaymentModel> get currentPayments => paymentsForTab(selectedTab.value);

  int get paidCount => _paymentsByTab[0].length;
  int get unpaidCount => _paymentsByTab[1].length;
  int get returnedCount => _paymentsByTab[2].length;

  bool get _currentHasMore => _hasMoreByTab[selectedTab.value];

  String get allBranchesKey => 'payments.filter.allBranches'.trns();

  List<String> get branchFilterOptions => [
    allBranchesKey,
    ...branches.map((b) => b.displayLabel),
  ];

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    if (label.isEmpty || label == allBranchesKey) {
      return null;
    }
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
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        hasMore.value &&
        !isLoadingMore.value &&
        !isLoading.value) {
      loadMore();
    }
  }

  // ─── Fetching ────────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    if (_filterBranchesLoaded && branches.isNotEmpty) return;
    final response = await _repo.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
      _filterBranchesLoaded = true;
    }
  }

  /// Ensures filter lookups are ready before the sheet opens, showing a
  /// graceful loader only while the (first) fetch is in flight.
  Future<void> ensureFilterData() async {
    if (_filterBranchesLoaded && branches.isNotEmpty) return;
    if (!showBranch) return;
    isFilterLoading.value = true;
    try {
      await fetchBranches();
    } finally {
      isFilterLoading.value = false;
    }
  }

  Future<void> fetchFirstPage() async {
    await _fetchFirstPageForTab(selectedTab.value);
  }

  Future<void> _fetchFirstPageForTab(int tabIndex, {bool force = false}) async {
    if (_tabLoaded[tabIndex] && !force) return;
    final query = searchCtrl.text.trim();
    final from = _toApiDate(fromDateCtrl.text);
    final to = _toApiDate(toDateCtrl.text);
    final branchId = _filterBranchId;
    final gen = ++_generationByTab[tabIndex];
    if (tabIndex == selectedTab.value) {
      isLoading.value = true;
      loadFailed.value = false;
    }
    final response = await _repo.getPayments(
      page: 1,
      status: _tabStatuses[tabIndex],
      search: query.isEmpty ? null : query,
      branchId: branchId,
      fromDate: from,
      toDate: to,
      quickRange: _filterQuickRange,
    );

    // Superseded by a newer filter/search request — drop it.
    if (gen != _generationByTab[tabIndex]) return;

    if (!response.isCompleted || response.data == null) {
      if (tabIndex == selectedTab.value) {
        loadFailed.value = true;
        isLoading.value = false;
      }
      if (_paymentsByTab[tabIndex].isEmpty && tabIndex == selectedTab.value) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
      return;
    }

    final page = response.data!;
    _currentPageByTab[tabIndex] = page.meta.currentPage;
    _lastPageByTab[tabIndex] = page.meta.lastPage;
    _hasMoreByTab[tabIndex] = page.meta.hasNextPage;
    _paymentsByTab[tabIndex].assignAll(page.payments);
    _tabLoaded[tabIndex] = true;
    if (tabIndex == selectedTab.value) {
      hasMore.value = page.meta.hasNextPage;
      isLoading.value = false;
    }
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    try {
      await _fetchFirstPageForTab(selectedTab.value, force: true);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    final tabIndex = selectedTab.value;
    if (!_currentHasMore || isLoadingMore.value) return;
    final query = searchCtrl.text.trim();
    final from = _toApiDate(fromDateCtrl.text);
    final to = _toApiDate(toDateCtrl.text);
    final branchId = _filterBranchId;
    final gen = _generationByTab[tabIndex];
    isLoadingMore.value = true;
    final response = await _repo.getPayments(
      page: _currentPageByTab[tabIndex] + 1,
      status: _tabStatuses[tabIndex],
      search: query.isEmpty ? null : query,
      branchId: branchId,
      fromDate: from,
      toDate: to,
      quickRange: _filterQuickRange,
    );
    if (gen != _generationByTab[tabIndex]) {
      isLoadingMore.value = false;
      return;
    }
    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      _currentPageByTab[tabIndex] = page.meta.currentPage;
      _lastPageByTab[tabIndex] = page.meta.lastPage;
      _hasMoreByTab[tabIndex] = page.meta.hasNextPage;
      _paymentsByTab[tabIndex].addAll(page.payments);
      hasMore.value = page.meta.hasNextPage;
    }
    isLoadingMore.value = false;
  }

  void retry() => fetchFirstPage();

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    hasMore.value = _hasMoreByTab[index];
    loadFailed.value = false;
    if (!_tabLoaded[index]) {
      fetchFirstPage();
    }
  }

  // ─── Filters ─────────────────────────────────────────────────────────────

  void openFilter(BuildContext context) async {
    final needsFetch =
        showBranch && (!_filterBranchesLoaded || branches.isEmpty);
    await runWithFilterLoader(() => ensureFilterData(), shouldShow: needsFetch);
    if (isClosed) return;
    if (!context.mounted) return;
    _showFilterSheet(context);
  }

  void _showFilterSheet(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'payments.filter.search'.trns(),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: 'payments.filter.quickRange'.trns(),
          type: FilterFieldType.dropdown,
          controller: quickRangeCtrl,
          dropdownItems: quickRangeOptions,
          selectedValue: selectedQuickRange,
        ),
        FilterField(
          label: 'payments.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'payments.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        if (showBranch)
          FilterField(
            label: 'payments.filter.branches'.trns(),
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

  void applyFilters() {
    _invalidateTabCaches();
    fetchFirstPage();
  }

  void resetFilters() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    quickRangeCtrl.clear();
    selectedBranchFilter.value = '';
    selectedQuickRange.value = '';
    _invalidateTabCaches();
    fetchFirstPage();
  }

  void _invalidateTabCaches() {
    for (var i = 0; i < _tabLoaded.length; i++) {
      _tabLoaded[i] = false;
      _paymentsByTab[i].clear();
      _currentPageByTab[i] = 1;
      _lastPageByTab[i] = 1;
      _hasMoreByTab[i] = false;
      _generationByTab[i]++;
    }
    hasMore.value = false;
  }

  // ─── Navigation ──────────────────────────────────────────────────────────

  void openDetails(PaymentModel payment) {
    Get.toNamed(Routes.REAL_PAYMENT_DETAILS, arguments: payment.id);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String? _toApiDate(String text) {
    if (text.trim().isEmpty) return null;
    final parts = text.trim().split('/');
    if (parts.length != 3) {
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text.trim())) {
        return text.trim();
      }
      return null;
    }
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
