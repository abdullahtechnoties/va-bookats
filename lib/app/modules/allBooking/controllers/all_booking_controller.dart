// lib/app/modules/allBooking/controllers/all_booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class AllBookingController extends GetxController {
  AllBookingController({BookingRepository? repository})
    : _repository = repository;

  final BookingRepository? _repository;
  BookingRepository get _repo {
    final r = _repository;
    if (r != null) return r;
    if (Get.isRegistered<BookingRepository>()) {
      return Get.find<BookingRepository>();
    }
    return BookingRepository();
  }

  final AuthService _auth = Get.find<AuthService>();
  bool get showBranch => _auth.isOwner;

  final ScrollController scrollController = ScrollController();

  // Tabs: Pending | Completed | Cancelled
  final RxInt selectedTab = 0.obs;
  static const List<String> tabStatuses = [
    BookingStatus.pending,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  final RxList<BookingModel> pendingBookings = <BookingModel>[].obs;
  final RxList<BookingModel> completedBookings = <BookingModel>[].obs;
  final RxList<BookingModel> cancelledBookings = <BookingModel>[].obs;
  final RxList<BookingModel> searchResults = <BookingModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyBookingId = RxnInt();

  final Map<String, int> _page = {};
  final Map<String, int> _lastPage = {};
  final Map<String, bool> _hasMore = {};
  final Set<String> _loaded = {};

  /// Bumped on every list request so a slow/stale response can never
  /// overwrite a newer tab/filter/search result (the tab-duplication glitch).
  int _generation = 0;

  // ─── Search (hidden by default; opened from home or search icon) ─────────
  final RxBool isSearchOpen = false.obs;
  final TextEditingController searchCtrl = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  final RxString searchQuery = ''.obs;
  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  // ─── Filters ─────────────────────────────────────────────────────────────
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController branchFilterCtrl = TextEditingController();
  final TextEditingController typeFilterCtrl = TextEditingController();
  final RxString selectedBranchFilter = ''.obs;
  final RxString selectedTypeFilter = ''.obs;

  final RxList<BranchModel> branches = <BranchModel>[].obs;
  static const List<String> typeOptions = ['All', 'Guest', 'Customer'];

  String get _statusKey => isSearching ? 'all' : tabStatuses[selectedTab.value];

  RxList<BookingModel> get _listForKey {
    switch (_statusKey) {
      case BookingStatus.pending:
        return pendingBookings;
      case BookingStatus.completed:
        return completedBookings;
      case BookingStatus.cancelled:
        return cancelledBookings;
      default:
        return searchResults;
    }
  }

  List<BookingModel> get currentBookings => _listForKey;

  int get pendingCount => pendingBookings.length;
  int get completedCount => completedBookings.length;
  int get cancelledCount => cancelledBookings.length;

  /// Number of active (non-empty) filters — shown as a badge on the icon.
  int get appliedFiltersCount {
    var n = 0;
    if (fromDateCtrl.text.trim().isNotEmpty) n++;
    if (toDateCtrl.text.trim().isNotEmpty) n++;
    if (selectedBranchFilter.value.isNotEmpty) n++;
    if (selectedTypeFilter.value.isNotEmpty) n++;
    return n;
  }

  List<String> get branchFilterOptions => [
    'All Branches',
    ...branches.map((b) => b.displayLabel),
  ];

  int? get _filterBranchId {
    final label = selectedBranchFilter.value;
    if (label.isEmpty || label == 'All Branches') return null;
    for (final b in branches) {
      if (b.displayLabel == label) return b.value;
    }
    return null;
  }

  String? get _filterBookingType {
    final v = selectedTypeFilter.value;
    if (v.isEmpty || v == 'All') return null;
    return v;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    // Graceful debounce — every keystroke doesn't hit the API.
    debounce<String>(
      searchQuery,
      (_) => fetchFirstPage(),
      time: const Duration(milliseconds: 500),
    );
    if (showBranch) fetchBranches();
    _readArguments();
    fetchFirstPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchCtrl.dispose();
    searchFocus.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    branchFilterCtrl.dispose();
    typeFilterCtrl.dispose();
    super.onClose();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is Map && args['autoFocusSearch'] == true) {
      openSearchMode();
    } else if (args is Map && args['autoFocusSearch'] == false) {
      closeSearchMode(silent: true);
    }
  }

  /// Safe entry-point for the view (post-frame) and for HomeController when
  /// the controller already lives inside the bottom-nav IndexedStack.
  void handleIncomingArgs() => _readArguments();

  void openSearchMode() {
    isSearchOpen.value = true;
    requestSearchFocus();
  }

  void closeSearchMode({bool silent = false}) {
    isSearchOpen.value = false;
    if (!silent) {
      searchCtrl.clear();
      searchQuery.value = '';
      searchFocus.unfocus();
      fetchFirstPage();
    }
  }

  void requestSearchFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && isSearchOpen.value && searchFocus.canRequestFocus) {
        searchFocus.requestFocus();
      }
    });
  }

  void toggleSearch([bool? open]) {
    final next = open ?? !isSearchOpen.value;
    if (!next) {
      closeSearchMode();
    } else {
      openSearchMode();
    }
  }

  void onSearchChanged(String v) => searchQuery.value = v;

  void _onScroll() {
    if (scrollController.positions.length != 1) return;
    final position = scrollController.positions.single;
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
    final key = _statusKey;
    final searching = isSearching;
    final query = searchQuery.value.trim();
    final from = _toApiDate(fromDateCtrl.text);
    final to = _toApiDate(toDateCtrl.text);
    final branchId = _filterBranchId;
    final bookingType = _filterBookingType;
    final gen = ++_generation;
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repo.getBookings(
      page: 1,
      status: searching ? null : key,
      search: query.isEmpty ? null : query,
      fromDate: from,
      toDate: to,
      branchId: branchId,
      bookingType: bookingType,
    );

    // Superseded by a newer tab/filter/search request — drop it so data can
    // never leak into the wrong tab or wipe a newer result.
    if (gen != _generation) return;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      if (_listForKeyAt(key, searching).isEmpty) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
      return;
    }

    final page = response.data!;
    _page[key] = page.meta.currentPage;
    _lastPage[key] = page.meta.lastPage;
    _hasMore[key] = page.meta.hasNextPage;
    hasMore.value = page.meta.hasNextPage;
    _listForKeyAt(key, searching).assignAll(page.bookings);
    _loaded.add(_loadedKey(key, searching));
    isLoading.value = false;
  }

  /// List lookup pinned to the request's key (not the live tab), so a late
  /// response can never write into whatever tab is on screen now.
  RxList<BookingModel> _listForKeyAt(String key, bool searching) {
    if (searching || key == 'all') return searchResults;
    switch (key) {
      case BookingStatus.pending:
        return pendingBookings;
      case BookingStatus.completed:
        return completedBookings;
      case BookingStatus.cancelled:
        return cancelledBookings;
      default:
        return searchResults;
    }
  }

  String _loadedKey(String key, bool searching) => searching ? 'all|$key' : key;

  Future<void> handleRefresh() async {
    isRefreshing.value = true;
    loadFailed.value = false;
    await fetchFirstPage();
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    final key = _statusKey;
    final searching = isSearching;
    final query = searchQuery.value.trim();
    final from = _toApiDate(fromDateCtrl.text);
    final to = _toApiDate(toDateCtrl.text);
    final branchId = _filterBranchId;
    final bookingType = _filterBookingType;
    final current = _page[key] ?? 1;
    final last = _lastPage[key] ?? current;
    if (current >= last || isLoadingMore.value) return;
    final gen = ++_generation;
    isLoadingMore.value = true;
    final response = await _repo.getBookings(
      page: current + 1,
      status: searching ? null : key,
      search: query.isEmpty ? null : query,
      fromDate: from,
      toDate: to,
      branchId: branchId,
      bookingType: bookingType,
    );
    if (gen != _generation) {
      isLoadingMore.value = false;
      return;
    }
    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      _page[key] = page.meta.currentPage;
      _lastPage[key] = page.meta.lastPage;
      _hasMore[key] = page.meta.hasNextPage;
      hasMore.value = page.meta.hasNextPage;
      _listForKeyAt(key, searching).addAll(page.bookings);
    }
    isLoadingMore.value = false;
  }

  void retry() => fetchFirstPage();

  void changeTab(int index) {
    if (isSearching) {
      // During search there is a single combined list — tabs are hidden.
      return;
    }
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    hasMore.value = _hasMore[_statusKey] ?? false;
    // Invalidate any in-flight request for the previous tab.
    _generation++;
    if (!_loaded.contains(_statusKey)) {
      fetchFirstPage();
    }
  }

  // ─── Filters ─────────────────────────────────────────────────────────────

  void openFilter(BuildContext context) {
    final fields = <FilterField>[
      FilterField(
        label: 'From Date',
        type: FilterFieldType.date,
        controller: fromDateCtrl,
      ),
      FilterField(
        label: 'To Date',
        type: FilterFieldType.date,
        controller: toDateCtrl,
      ),
      if (showBranch)
        FilterField(
          label: 'Branches',
          type: FilterFieldType.dropdown,
          controller: branchFilterCtrl,
          dropdownItems: branchFilterOptions,
          selectedValue: selectedBranchFilter,
        ),
      FilterField(
        label: 'Booking Type',
        type: FilterFieldType.dropdown,
        controller: typeFilterCtrl,
        dropdownItems: typeOptions,
        selectedValue: selectedTypeFilter,
      ),
    ];
    FilterBottomSheet.show(
      context,
      fields: fields,
      onReset: resetFilters,
      onApply: applyFilters,
    );
  }

  void applyFilters() {
    _loaded.clear();
    fetchFirstPage();
  }

  void resetFilters() {
    fromDateCtrl.clear();
    toDateCtrl.clear();
    branchFilterCtrl.clear();
    typeFilterCtrl.clear();
    selectedBranchFilter.value = '';
    selectedTypeFilter.value = '';
    _loaded.clear();
    fetchFirstPage();
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  Future<void> changeStatus(
    BookingModel booking,
    String newStatus, {
    String? returnAmount,
    String? paymentMethod,
    String? transactionId,
    int? mediaId,
  }) async {
    if (newStatus == booking.status) return;
    busyBookingId.value = booking.id;
    final response = await _repo.changeBookingStatus(
      id: booking.id,
      status: newStatus,
      returnAmount: returnAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      mediaId: mediaId,
    );
    busyBookingId.value = null;
    if (response.isCompleted && response.data != null) {
      _moveBooking(booking, response.data!);
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: response.message ?? 'Status updated successfully!',
      );
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  void _moveBooking(BookingModel old, BookingModel updated) {
    pendingBookings.removeWhere((b) => b.id == old.id);
    completedBookings.removeWhere((b) => b.id == old.id);
    cancelledBookings.removeWhere((b) => b.id == old.id);
    searchResults.removeWhere((b) => b.id == old.id);
    final target = switch (updated.status.toLowerCase()) {
      'completed' => completedBookings,
      'cancelled' => cancelledBookings,
      _ => pendingBookings,
    };
    target.insert(0, updated);
    if (isSearching) searchResults.insert(0, updated);
  }

  void openDetails(BookingModel booking) {
    Get.toNamed(
      Routes.BOOKING_DETAILS,
      arguments: booking.id,
    )?.then((_) => handleRefresh());
  }

  Future<void> openCreate({BookingModel? booking}) async {
    final result = await Get.toNamed(Routes.CREATE_BOOKING, arguments: booking);
    // After submission the form pops with the created/updated booking so the
    // list can jump to its status tab and reflect it immediately.
    if (result is BookingModel) {
      final idx = tabStatuses.indexWhere(
        (s) => s.toLowerCase() == result.status.toLowerCase(),
      );
      if (idx != -1) selectedTab.value = idx;
      _loaded.clear();
    }
    handleRefresh();
  }

  String? _toApiDate(String text) {
    if (text.trim().isEmpty) return null;
    final parts = text.trim().split('/');
    if (parts.length != 3) {
      // Already API format?
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
