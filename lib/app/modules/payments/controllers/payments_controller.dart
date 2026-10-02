// lib/app/modules/payments/controllers/payments_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/payments/repositories/payment_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/payment_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
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
  //
  // NOTE: the backend does not reliably honor a `status` query param (every
  // tab was returning the full list), so tabs are filtered client-side from
  // one master list. This stays correct whether or not the API filters.
  final RxInt selectedTab = 0.obs;

  final RxList<PaymentModel> allPayments = <PaymentModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;

  int _currentPage = 1;
  int _lastPage = 1;

  /// Bumped on every list request so a stale response can never overwrite a
  /// newer filter/search result.
  int _generation = 0;

  // ─── Search (inside the filter sheet) ────────────────────────────────────
  final TextEditingController searchCtrl = TextEditingController();

  // ─── Filters ─────────────────────────────────────────────────────────────
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;

  final RxList<BranchModel> branches = <BranchModel>[].obs;

  /// Tab index for a payment, derived from its own status string.
  static int tabIndexFor(PaymentModel p) {
    final s = p.status.trim().toLowerCase();
    if (s.startsWith('paid')) return 0;
    if (s.startsWith('return')) return 2;
    return 1;
  }

  List<PaymentModel> paymentsForTab(int index) =>
      allPayments.where((p) => tabIndexFor(p) == index).toList();

  List<PaymentModel> get currentPayments => paymentsForTab(selectedTab.value);

  int get paidCount => paymentsForTab(0).length;
  int get unpaidCount => paymentsForTab(1).length;
  int get returnedCount => paymentsForTab(2).length;

  List<String> get branchFilterOptions => [
    'packages.filter.allBranches'.trns(),
    ...branches.map((b) => b.displayLabel),
  ];

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    if (label.isEmpty || label == 'packages.filter.allBranches'.trns()) {
      return null;
    }
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
    return n;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    if (showBranch) fetchBranches();
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
    final response = await _repo.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
    }
  }

  Future<void> fetchFirstPage() async {
    final query = searchCtrl.text.trim();
    final from = _toApiDate(fromDateCtrl.text);
    final to = _toApiDate(toDateCtrl.text);
    final branchId = _filterBranchId;
    final gen = ++_generation;
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repo.getPayments(
      page: 1,
      search: query.isEmpty ? null : query,
      branchId: branchId,
      fromDate: from,
      toDate: to,
    );

    // Superseded by a newer filter/search request — drop it.
    if (gen != _generation) return;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      if (allPayments.isEmpty) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
      return;
    }

    final page = response.data!;
    _currentPage = page.meta.currentPage;
    _lastPage = page.meta.lastPage;
    hasMore.value = page.meta.hasNextPage;
    allPayments.assignAll(page.payments);
    isLoading.value = false;
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    await fetchFirstPage();
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    if (_currentPage >= _lastPage || isLoadingMore.value) return;
    final query = searchCtrl.text.trim();
    final from = _toApiDate(fromDateCtrl.text);
    final to = _toApiDate(toDateCtrl.text);
    final branchId = _filterBranchId;
    final gen = ++_generation;
    isLoadingMore.value = true;
    final response = await _repo.getPayments(
      page: _currentPage + 1,
      search: query.isEmpty ? null : query,
      branchId: branchId,
      fromDate: from,
      toDate: to,
    );
    if (gen != _generation) {
      isLoadingMore.value = false;
      return;
    }
    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
      allPayments.addAll(page.payments);
    }
    isLoadingMore.value = false;
  }

  void retry() => fetchFirstPage();

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    // Tabs are a client-side slice of the master list, so switching is
    // instant. If nothing is loaded yet (and nothing is loading), fetch.
    if (allPayments.isEmpty && !isLoading.value && !loadFailed.value) {
      fetchFirstPage();
    }
  }

  // ─── Filters ─────────────────────────────────────────────────────────────

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

  void applyFilters() {
    fetchFirstPage();
  }

  void resetFilters() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    selectedBranchFilter.value = '';
    fetchFirstPage();
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
