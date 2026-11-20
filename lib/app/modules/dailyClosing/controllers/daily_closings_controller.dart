// lib/app/modules/dailyClosing/controllers/daily_closings_controller.dart
//
// List screen for daily closings: paginated fetch, inline search, filters
// (branch for owners only, status, from/to date, quick range), create sheet
// and status toggling. Every mutation is permission-gated here as well as in
// the view, so a hidden button can never be triggered programmatically.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/opening_balance_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';
import 'package:va_bookats/app/modules/dailyClosing/utilities/closing_formatters.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/closing_status_sheet.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/daily_closing_form_sheet.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/filter_loader.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class DailyClosingsController extends GetxController {
  DailyClosingsController({DailyClosingRepository? repository})
    : _repository = repository ?? DailyClosingRepository();

  final DailyClosingRepository _repository;
  final AuthService auth = Get.find<AuthService>();

  // ─── List state ────────────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();
  final RxList<DailyClosingModel> items = <DailyClosingModel>[].obs;
  final RxInt totalItems = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyStatusId = RxnInt();
  final Rxn<TodayClosing> today = Rxn<TodayClosing>();

  int _currentPage = 1;
  int _lastPage = 1;

  // ─── Search ────────────────────────────────────────────────────────────
  final TextEditingController searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  // ─── Filters ───────────────────────────────────────────────────────────
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController statusFilterCtrl = TextEditingController();
  final TextEditingController quickRangeCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();

  final RxString selectedStatusFilter = ''.obs;
  final RxString selectedQuickRange = ''.obs;
  final RxString selectedBranchFilter = ''.obs;
  final RxInt appliedFiltersCount = 0.obs;
  final RxString displayDateRange = ''.obs;

  static const List<String> statusOptions = ['All', 'Pending', 'Approved'];
  static const List<String> quickRangeOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
  ];

  /// Owner-only branch filter sources.
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<String> branchOptions = <String>['All Branches'].obs;
  final Map<String, int?> _branchIdByLabel = {'All Branches': null};
  final RxBool isFilterLoading = false.obs;
  bool _branchesLoaded = false;

  bool get isOwner => auth.isOwner;

  /// Owner → picked filter branch (null = all). Other roles → own branch.
  int? get _queryBranchId {
    if (!isOwner) return auth.currentUser.value?.branchId;
    return _branchIdByLabel[selectedBranchFilter.value];
  }

  int? get effectiveBranchId =>
      _queryBranchId ?? (isOwner ? null : auth.currentUser.value?.branchId);

  String? get _filterStatus {
    final v = selectedStatusFilter.value.trim();
    if (v.isEmpty || v.toLowerCase() == 'all') return null;
    return v;
  }

  String? get _filterFromDate => closingFilterDateToApi(fromDateCtrl.text);
  String? get _filterToDate => closingFilterDateToApi(toDateCtrl.text);
  String? get _filterQuickRange =>
      closingQuickRangeValue(selectedQuickRange.value);

  String get searchLabel => searchCtrl.text.trim();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchCtrl.addListener(_onSearchChanged);
    fetchFirstPage();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchCtrl.removeListener(_onSearchChanged);
    scrollController.dispose();
    searchCtrl.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    statusFilterCtrl.dispose();
    quickRangeCtrl.dispose();
    branchFilterCtrl.dispose();
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

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (isClosed) return;
      _updateAppliedCount();
      fetchFirstPage();
    });
  }

  // ─── Fetching ──────────────────────────────────────────────────────────

  Future<void> fetchFirstPage() async {
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.getDailyClosings(
      page: 1,
      branchId: _queryBranchId,
      search: searchCtrl.text.trim(),
      status: _filterStatus,
      fromDate: _filterFromDate,
      toDate: _filterToDate,
      quickRange: _filterQuickRange,
    );
    if (isClosed) return;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    final page = response.data!;
    _currentPage = page.meta.currentPage;
    _lastPage = page.meta.lastPage;
    hasMore.value = page.meta.hasNextPage;
    totalItems.value = page.meta.total;
    items.assignAll(page.items);
    today.value = page.today;
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (_currentPage >= _lastPage || isLoadingMore.value) return;
    isLoadingMore.value = true;
    final response = await _repository.getDailyClosings(
      page: _currentPage + 1,
      branchId: _queryBranchId,
      search: searchCtrl.text.trim(),
      status: _filterStatus,
      fromDate: _filterFromDate,
      toDate: _filterToDate,
      quickRange: _filterQuickRange,
    );
    if (isClosed) return;
    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
      totalItems.value = page.meta.total;
      items.addAll(page.items);
    }
    isLoadingMore.value = false;
  }

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    await fetchFirstPage();
    isRefreshing.value = false;
  }

  void retry() => fetchFirstPage();

  // ─── Branches / filter sheet ───────────────────────────────────────────

  Future<void> fetchBranches() async {
    if (_branchesLoaded && branches.isNotEmpty) return;
    isFilterLoading.value = true;
    final response = await _repository.getBranches();
    isFilterLoading.value = false;
    if (!response.isCompleted || response.data == null) return;
    branches.assignAll(response.data!);
    branchOptions.assignAll([
      'All Branches',
      ...response.data!.map((b) => b.displayLabel),
    ]);
    _branchIdByLabel
      ..clear()
      ..['All Branches'] = null;
    for (final b in response.data!) {
      _branchIdByLabel[b.displayLabel] = b.value;
    }
    _branchesLoaded = true;
  }

  bool get needsBranchFetch => isOwner && !_branchesLoaded;

  Future<void> openFilter(BuildContext context) async {
    if (isOwner) {
      await runWithFilterLoader(fetchBranches, shouldShow: needsBranchFetch);
      if (isClosed || !context.mounted) return;
    }
    if (!context.mounted) return;
    _showFilterSheet(context);
  }

  void _showFilterSheet(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'dailyClosing.filter.quickRange'.trns(),
          type: FilterFieldType.dropdown,
          controller: quickRangeCtrl,
          dropdownItems: quickRangeOptions,
          selectedValue: selectedQuickRange,
        ),
        FilterField(
          label: 'dailyClosing.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'dailyClosing.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: 'dailyClosing.filter.status'.trns(),
          type: FilterFieldType.dropdown,
          controller: statusFilterCtrl,
          dropdownItems: statusOptions,
          selectedValue: selectedStatusFilter,
        ),
        if (isOwner)
          FilterField(
            label: 'dailyClosing.filter.branch'.trns(),
            type: FilterFieldType.dropdown,
            controller: branchFilterCtrl,
            dropdownItems: branchOptions,
            selectedValue: selectedBranchFilter,
            showSearch: true,
          ),
      ],
      onReset: resetFilter,
      onApply: applyFilter,
    );
  }

  void resetFilter() {
    fromDateCtrl.clear();
    toDateCtrl.clear();
    statusFilterCtrl.clear();
    quickRangeCtrl.clear();
    branchFilterCtrl.clear();
    selectedStatusFilter.value = '';
    selectedQuickRange.value = '';
    selectedBranchFilter.value = '';
    displayDateRange.value = '';
    _updateAppliedCount();
    fetchFirstPage();
  }

  void applyFilter() {
    _updateRangeLabel();
    _updateAppliedCount();
    fetchFirstPage();
  }

  void _updateRangeLabel() {
    final from = fromDateCtrl.text.trim();
    final to = toDateCtrl.text.trim();
    if (from.isNotEmpty && to.isNotEmpty) {
      displayDateRange.value = '$from - $to';
    } else if (from.isNotEmpty || to.isNotEmpty) {
      displayDateRange.value = from.isNotEmpty ? from : to;
    } else {
      displayDateRange.value = '';
    }
  }

  void _updateAppliedCount() {
    var n = 0;
    if (searchCtrl.text.trim().isNotEmpty) n++;
    if (_filterFromDate != null && _filterToDate != null) n++;
    if (_filterStatus != null) n++;
    if (_filterQuickRange != null) n++;
    if (isOwner &&
        selectedBranchFilter.value.isNotEmpty &&
        _branchIdByLabel[selectedBranchFilter.value] != null) {
      n++;
    }
    appliedFiltersCount.value = n;
  }

  // ─── Mutations ─────────────────────────────────────────────────────────

  bool get canCreate => Permissions.can(AppPerm.create(AppPerm.dailyClosings));
  bool get canUpdate => Permissions.can(AppPerm.update(AppPerm.dailyClosings));
  bool get canView =>
      Permissions.can(AppPerm.show(AppPerm.dailyClosings)) ||
      Permissions.can(AppPerm.index(AppPerm.dailyClosings));

  Future<void> openCreateSheet(BuildContext context) async {
    if (!canCreate) {
      showNoAccessDialog();
      return;
    }
    if (isOwner && !_branchesLoaded) await fetchBranches();
    if (isClosed || !context.mounted) return;

    final initialBranchId = _queryBranchId ?? auth.currentUser.value?.branchId;
    final created = await DailyClosingFormSheet.show(
      context,
      branches: isOwner ? branches : const [],
      initialBranchId: initialBranchId,
      allowBranchSelection: isOwner,
    );
    if (created == null) return;
    await fetchFirstPage();
    await refreshOpeningBalanceIfMounted();
  }

  Future<void> changeStatus(DailyClosingModel item) async {
    if (!canUpdate) {
      showNoAccessDialog();
      return;
    }
    if (busyStatusId.value != null) return;

    final target = await showClosingStatusSheet(currentStatus: item.status);
    if (target == null) return;
    if (target.toLowerCase() == item.status.toLowerCase()) return;

    busyStatusId.value = item.id;
    final response = await _repository.changeStatus(item.id);
    busyStatusId.value = null;
    if (isClosed) return;

    if (response.isCompleted) {
      final status = (response.data ?? '').isNotEmpty ? response.data! : target;
      final index = items.indexWhere((c) => c.id == item.id);
      if (index != -1) {
        items[index] = items[index].copyWith(status: status);
      }
      final todayValue = today.value;
      if (todayValue?.id == item.id) {
        today.value = TodayClosing(
          exists: todayValue!.exists,
          id: todayValue.id,
          status: status,
          openingBalance: todayValue.openingBalance,
        );
      }
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: response.message ?? 'dailyClosing.statusUpdated'.trns(),
      );
      await refreshOpeningBalanceIfMounted();
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> openDetails(DailyClosingModel item) async {
    if (!canView) {
      showNoAccessDialog();
      return;
    }
    await Get.toNamed(Routes.DAILY_CLOSING_DETAILS, arguments: item.id);
    await fetchFirstPage();
  }
}
