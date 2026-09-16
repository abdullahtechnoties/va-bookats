// lib/app/modules/customers/controllers/customers_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/customers/repositories/customer_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/models/customer_model.dart';
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class CustomersController extends GetxController {
  CustomersController({required CustomerRepository repository})
      : _repository = repository;

  final CustomerRepository _repository;
  final ScrollController scrollController = ScrollController();

  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxInt totalCustomers = 0.obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyCustomerId = RxnInt();

  int _currentPage = 1;
  int _lastPage = 1;

  // Date range display
  final RxString displayDateRange = ''.obs;

  // Filter state
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController statusFilterCtrl = TextEditingController();
  final TextEditingController countryFilterCtrl = TextEditingController();

  final RxString selectedStatusFilter = ''.obs;
  final RxString selectedCountryFilter = ''.obs;

  final List<String> statusOptions = ['All', 'Active', 'Inactive'];
  final RxList<String> countryOptions = <String>['All Country'].obs;
  final Map<String, int?> _countryIdByLabel = {'All Country': null};
  final RxBool isLoadingCountries = false.obs;

  String? get _filterStatus {
    final v = selectedStatusFilter.value.trim().toLowerCase();
    if (v.isEmpty || v == 'all') return null;
    return v;
  }

  int? get _filterCountryId {
    final label = selectedCountryFilter.value;
    if (label.isEmpty) return null;
    return _countryIdByLabel[label];
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    displayDateRange.value = _defaultRangeLabel();
    fetchCountries();
    fetchFirstPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchCtrl.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    statusFilterCtrl.dispose();
    countryFilterCtrl.dispose();
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

  String _defaultRangeLabel() =>
      'customers.filter.fromDate'.trns() == 'customers.filter.fromDate'
          ? ''
          : '';

  // ─── Fetching ──────────────────────────────────────────────────────────

  Future<void> fetchCountries() async {
    isLoadingCountries.value = true;
    final response = await _repository.getCountries();
    isLoadingCountries.value = false;
    if (response.isCompleted && response.data != null) {
      final options = response.data!;
      countryOptions.assignAll(['All Country', ...options.map((o) => o.label)]);
      _countryIdByLabel
        ..clear()
        ..['All Country'] = null;
      for (final LookupOption o in options) {
        _countryIdByLabel[o.label] = o.valueAsInt;
      }
    }
  }

  Future<void> fetchFirstPage() async {
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.getCustomers(
      page: 1,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      countryId: _filterCountryId,
    );

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      if (customers.isEmpty) {
        SnackbarService.showError(
          title: 'customers.errorTitle'.trns() == 'customers.errorTitle'
              ? 'Error'
              : 'customers.errorTitle'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
      return;
    }

    final page = response.data!;
    _currentPage = page.meta.currentPage;
    _lastPage = page.meta.lastPage;
    hasMore.value = page.meta.hasNextPage;
    totalCustomers.value = page.meta.total;
    customers.assignAll(page.customers);
    _updateRangeLabel();
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
    isLoadingMore.value = true;
    final response = await _repository.getCustomers(
      page: _currentPage + 1,
      search: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
      status: _filterStatus,
      fromDate: _toApiDate(fromDateCtrl.text),
      toDate: _toApiDate(toDateCtrl.text),
      countryId: _filterCountryId,
    );
    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
      totalCustomers.value = page.meta.total;
      customers.addAll(page.customers);
    }
    isLoadingMore.value = false;
  }

  void retry() => fetchFirstPage();

  void _updateRangeLabel() {
    final from = fromDateCtrl.text.trim();
    final to = toDateCtrl.text.trim();
    if (from.isEmpty && to.isEmpty) {
      displayDateRange.value = searchCtrl.text.trim().isEmpty
          ? ''
          : searchCtrl.text.trim();
    } else if (from.isNotEmpty && to.isNotEmpty) {
      displayDateRange.value = '$from - $to';
    } else {
      displayDateRange.value = from.isNotEmpty ? from : to;
    }
  }

  // ─── Filter ────────────────────────────────────────────────────────────

  void resetFilter() {
    searchCtrl.clear();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    statusFilterCtrl.clear();
    countryFilterCtrl.clear();
    selectedStatusFilter.value = '';
    selectedCountryFilter.value = '';
    displayDateRange.value = '';
    fetchFirstPage();
  }

  void applyFilter() {
    _updateRangeLabel();
    fetchFirstPage();
  }

  void openFilter(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'customers.filter.search'.trns() == 'customers.filter.search'
              ? 'Search'
              : 'customers.filter.search'.trns(),
          type: FilterFieldType.text,
          controller: searchCtrl,
        ),
        FilterField(
          label: 'customers.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'customers.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: 'customers.filter.status'.trns(),
          type: FilterFieldType.dropdown,
          controller: statusFilterCtrl,
          dropdownItems: statusOptions,
          selectedValue: selectedStatusFilter,
        ),
        FilterField(
          label: 'customers.filter.country'.trns(),
          type: FilterFieldType.dropdown,
          controller: countryFilterCtrl,
          dropdownItems: countryOptions,
          selectedValue: selectedCountryFilter,
        ),
      ],
      onReset: resetFilter,
      onApply: applyFilter,
    );
  }

  // ─── Mutations ─────────────────────────────────────────────────────────

  Future<void> deleteCustomer(CustomerModel customer) async {
    final confirmed = await _confirmDelete(customer);
    if (confirmed != true) return;

    busyCustomerId.value = customer.id;
    final response = await _repository.deleteCustomer(customer.id);
    busyCustomerId.value = null;

    if (response.isCompleted) {
      customers.removeWhere((c) => c.id == customer.id);
      totalCustomers.value =
          (totalCustomers.value - 1).clamp(0, 1 << 31);
      SnackbarService.showSuccess(
        title: 'customers.deleteSuccessTitle'.trns() ==
                'customers.deleteSuccessTitle'
            ? 'Deleted'
            : 'customers.deleteSuccessTitle'.trns(),
        message: response.message ??
            ('customers.deleteSuccessMessage'.trns() ==
                    'customers.deleteSuccessMessage'
                ? 'Customer deleted successfully.'
                : 'customers.deleteSuccessMessage'.trns()),
      );
    } else {
      SnackbarService.showError(
        title: 'customers.errorTitle'.trns() == 'customers.errorTitle'
            ? 'Error'
            : 'customers.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<void> toggleStatus(CustomerModel customer) async {
    busyCustomerId.value = customer.id;
    final response = await _repository.changeCustomerStatus(customer.id);
    busyCustomerId.value = null;

    if (response.isCompleted) {
      final newStatus = (response.data ?? '').isNotEmpty
          ? response.data!
          : (customer.isActive ? 'inactive' : 'active');
      final index = customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        customers[index] = customer.copyWith(status: newStatus);
      }
      SnackbarService.showSuccess(
        title: 'customers.statusSuccessTitle'.trns() ==
                'customers.statusSuccessTitle'
            ? 'Updated'
            : 'customers.statusSuccessTitle'.trns(),
        message: response.message ??
            ('customers.statusSuccessMessage'.trns() ==
                    'customers.statusSuccessMessage'
                ? 'Customer status updated successfully.'
                : 'customers.statusSuccessMessage'.trns()),
      );
    } else {
      SnackbarService.showError(
        title: 'customers.errorTitle'.trns() == 'customers.errorTitle'
            ? 'Error'
            : 'customers.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  Future<bool?> _confirmDelete(CustomerModel customer) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'customers.deleteDialogTitle'.trns() ==
                  'customers.deleteDialogTitle'
              ? 'Delete Customer'
              : 'customers.deleteDialogTitle'.trns(),
        ),
        content: Text(
          'customers.deleteDialogMessage'.trnsFormat({'name': customer.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'customers.cancel'.trns() == 'customers.cancel'
                  ? 'Cancel'
                  : 'customers.cancel'.trns(),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'customers.delete'.trns() == 'customers.delete'
                  ? 'Delete'
                  : 'customers.delete'.trns(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Opens add (null) / edit page and refreshes on return.
  Future<void> openAddPage({CustomerModel? customer}) async {
    await Get.toNamed(Routes.ADD_CUSTOMER, arguments: customer);
    handleRefresh();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  String? _toApiDate(String text) {
    if (text.trim().isEmpty) return null;
    final parts = text.trim().split('/');
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
