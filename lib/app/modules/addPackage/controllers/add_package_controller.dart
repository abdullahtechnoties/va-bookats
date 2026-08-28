// lib/app/modules/addPackage/controllers/add_package_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/packages/repositories/package_repository.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/data_service_item.dart';
import 'package:va_bookats/models/package_model.dart';
import 'package:va_bookats/models/service_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// One selectable service row inside the package form.
class PackageServiceItem {
  final TextEditingController serviceCtrl = TextEditingController();
  final TextEditingController variationCtrl = TextEditingController();
  final RxnInt selectedServiceId = RxnInt();
  final RxString selectedServiceIdStr = ''.obs;
  final RxString selectedServiceLabel = ''.obs;
  final RxString serviceType = ''.obs;
  final RxList<ServiceVariation> variations = <ServiceVariation>[].obs;
  final RxnInt selectedVariationId = RxnInt();
  final RxString selectedVariationIdStr = ''.obs;
  final RxString selectedVariationLabel = ''.obs;

  bool get isVariationType => serviceType.value == 'variation';

  void resetService() {
    selectedServiceId.value = null;
    selectedServiceIdStr.value = '';
    selectedServiceLabel.value = '';
    serviceCtrl.clear();
    resetVariation();
  }

  void resetVariation() {
    selectedVariationId.value = null;
    selectedVariationIdStr.value = '';
    selectedVariationLabel.value = '';
    variationCtrl.clear();
  }

  void dispose() {
    serviceCtrl.dispose();
    variationCtrl.dispose();
  }
}

class AddPackageController extends GetxController {
  AddPackageController({required PackageRepository repository})
      : _repository = repository;

  final PackageRepository _repository;
  final AuthService _authService = Get.find<AuthService>();

  // ─── Form controllers ────────────────────────────────────────────────

  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController packagePriceCtrl = TextEditingController();

  final RxString selectedBranch = ''.obs;
  final RxnInt selectedBranchId = RxnInt();
  final RxString selectedStatus = ''.obs;

  // ─── Data ────────────────────────────────────────────────────────────

  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<DataServiceItem> allServices = <DataServiceItem>[].obs;
  final RxList<PackageServiceItem> serviceItems =
      <PackageServiceItem>[PackageServiceItem()].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isLoadingServices = false.obs;

  // ─── Edit mode ───────────────────────────────────────────────────────

  PackageModel? _editingPackage;

  bool get isEditMode => _editingPackage != null;
  bool get showBranch => _authService.isOwner;

  String get formTitle =>
      isEditMode ? 'addPackage.editTitle'.trns() : 'addPackage.title'.trns();

  String get saveButtonText =>
      isEditMode ? 'addPackage.update'.trns() : 'addPackage.save'.trns();

  List<String> get branchLabels =>
      branches.map((b) => b.displayLabel).toList();

  List<String> get branchIds =>
      branches.map((b) => b.value?.toString() ?? '').toList();

  List<String> get serviceLabels =>
      allServices.map((s) => s.label ?? '').toList();

  List<String> get serviceIds =>
      allServices.map((s) => s.value?.toString() ?? '').toList();

  /// Returns labels for services not yet selected in other rows.
  List<String> availableServiceLabels(int excludeIndex) {
    final selectedIds = <int>{};
    for (var i = 0; i < serviceItems.length; i++) {
      if (i == excludeIndex) continue;
      final id = serviceItems[i].selectedServiceId.value;
      if (id != null) selectedIds.add(id);
    }
    return allServices
        .where((s) => !selectedIds.contains(s.value))
        .map((s) => s.label ?? '')
        .toList();
  }

  /// Returns IDs for services not yet selected in other rows.
  List<String> availableServiceIds(int excludeIndex) {
    final selectedIds = <int>{};
    for (var i = 0; i < serviceItems.length; i++) {
      if (i == excludeIndex) continue;
      final id = serviceItems[i].selectedServiceId.value;
      if (id != null) selectedIds.add(id);
    }
    return allServices
        .where((s) => !selectedIds.contains(s.value))
        .map((s) => s.value?.toString() ?? '')
        .toList();
  }

  List<String> get statusOptions => ['active', 'inactive'];

  /// Computed total of all selected service/variation prices.
  double get computedTotal {
    double total = 0;
    for (final item in serviceItems) {
      final serviceId = item.selectedServiceId.value;
      if (serviceId == null) continue;

      if (item.isVariationType) {
        final variation = item.variations.firstWhereOrNull(
          (v) => v.id == item.selectedVariationId.value,
        );
        total += double.tryParse(variation?.price ?? '') ?? 0;
      } else {
        final service = allServices.firstWhereOrNull(
          (s) => s.value == serviceId,
        );
        total += double.tryParse(service?.defaultPrice ?? '') ?? 0;
      }
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    _loadData();
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    nameCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    statusCtrl.dispose();
    descriptionCtrl.dispose();
    packagePriceCtrl.dispose();
    for (final item in serviceItems) {
      item.dispose();
    }
    super.onClose();
  }

  // ─── Arguments ─────────────────────────────────────────────────────

  void _readArguments() {
    final args = Get.arguments;
    if (args is PackageModel) {
      _editingPackage = args;
    }
  }

  // ─── Data loading ─────────────────────────────────────────────────

  Future<void> _loadData() async {
    isLoading.value = true;

    if (showBranch) {
      // Owner: load branches first, then fetch services with user's branchId
      await _fetchBranches();
      final userBranchId = _authService.currentUser.value?.branchId;
      if (userBranchId != null) {
        await _fetchServicesForBranch(userBranchId);
      }
    } else {
      // Non-owner: services will be fetched when branch is selected
      // (or in edit mode after branch is prefilled)
    }

    if (isEditMode) await _prefillFromPackage();
    isLoading.value = false;
  }

  Future<void> _fetchBranches() async {
    final response = await _repository.getBranches();
    if (response.isCompleted && response.data != null) {
      branches.assignAll(response.data!);
    }
  }

  /// Fetches services for a specific branch via the new `/data/services` API.
  Future<void> _fetchServicesForBranch(int branchId) async {
    isLoadingServices.value = true;
    allServices.clear();
    // Clear existing service selections
    for (final item in serviceItems) {
      item.resetVariation();
      item.selectedServiceId.value = null;
      item.selectedServiceIdStr.value = '';
      item.serviceCtrl.clear();
    }

    final response = await _repository.getDataServices(branchId);
    if (response.isCompleted && response.data != null) {
      allServices.assignAll(response.data!);
    }
    isLoadingServices.value = false;
  }

  Future<void> _prefillFromPackage() async {
    final pkg = _editingPackage!;
    // Fetch full package data (includes package_services)
    final response = await _repository.getPackage(pkg.id!);
    if (!response.isCompleted || response.data == null) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }

    final full = response.data!;
    nameCtrl.text = full.name ?? '';
    descriptionCtrl.text = full.description ?? '';
    packagePriceCtrl.text = full.price ?? '';

    // Dates: API returns YYYY-MM-DD, display as MM/DD/YYYY
    startDateCtrl.text = _toDisplayDate(full.startingFrom ?? '');
    endDateCtrl.text = _toDisplayDate(full.endingOn ?? '');

    // Status
    selectedStatus.value = full.status ?? 'active';
    statusCtrl.text = selectedStatus.value;

    // Branch (owner only)
    if (showBranch && full.branchId != null) {
      _prefillBranch(full.branchId!);
      // Fetch services for this branch if not already loaded
      if (allServices.isEmpty) {
        await _fetchServicesForBranch(full.branchId!);
      }
    } else if (!showBranch && full.branchId != null) {
      // Non-owner in edit mode: fetch services for the package's branch
      await _fetchServicesForBranch(full.branchId!);
    }

    // Services
    for (final item in serviceItems) {
      item.dispose();
    }
    serviceItems.clear();

    for (final ps in full.packageServices) {
      final item = PackageServiceItem();
      final serviceId = ps.serviceId;
      if (serviceId == null) continue;

      // Find the DataServiceItem for type + variations info
      final service = allServices.firstWhereOrNull((s) => s.value == serviceId);
      item.selectedServiceId.value = serviceId;
      item.selectedServiceIdStr.value = serviceId.toString();
      item.selectedServiceLabel.value = ps.serviceName ?? service?.label ?? '';
      item.serviceCtrl.text = ps.serviceName ?? service?.label ?? '';

      if (service != null) {
        item.serviceType.value = service.type ?? '';
        item.variations.assignAll(service.variations);
      }

      // Variation
      if (ps.variationId != null) {
        item.selectedVariationId.value = ps.variationId;
        item.selectedVariationIdStr.value = ps.variationId.toString();
        item.selectedVariationLabel.value = ps.variationName ?? '';
        item.variationCtrl.text = ps.variationName ?? '';
      }

      serviceItems.add(item);
    }

    if (serviceItems.isEmpty) {
      serviceItems.add(PackageServiceItem());
    }
  }

  void _prefillBranch(int branchId) {
    for (final b in branches) {
      if (b.value == branchId) {
        selectedBranch.value = b.displayLabel;
        branchCtrl.text = b.displayLabel;
        selectedBranchId.value = branchId;
        break;
      }
    }
  }

  // ─── Service items ────────────────────────────────────────────────

  void addServiceItem() {
    serviceItems.add(PackageServiceItem());
  }

  void removeServiceItem(int index) {
    if (serviceItems.length > 1) {
      serviceItems[index].dispose();
      serviceItems.removeAt(index);
    }
  }

  void onServiceSelected(int index, dynamic value) {
    final id = int.tryParse(value.toString());
    if (id == null) return;

    final item = serviceItems[index];
    final service = allServices.firstWhereOrNull((s) => s.value == id);
    if (service == null) return;

    item.selectedServiceId.value = id;
    item.selectedServiceIdStr.value = id.toString();
    item.selectedServiceLabel.value = service.label ?? '';
    item.serviceCtrl.text = service.label ?? '';
    item.serviceType.value = service.type ?? '';
    item.variations.assignAll(service.variations);
    item.resetVariation();
  }

  void onVariationSelected(int index, dynamic value) {
    final id = int.tryParse(value.toString());
    if (id == null) return;

    final item = serviceItems[index];
    final variation = item.variations.firstWhereOrNull((v) => v.id == id);
    if (variation == null) return;

    item.selectedVariationId.value = id;
    item.selectedVariationIdStr.value = id.toString();
    item.selectedVariationLabel.value = variation.name ?? '';
    item.variationCtrl.text = variation.name ?? '';
  }

  // ─── Dropdown callbacks ────────────────────────────────────────────

  void onBranchSelected(dynamic value) {
    final id = int.tryParse(value.toString());
    if (id == null || id == selectedBranchId.value) return;
    selectedBranchId.value = id;
    // Re-fetch services for the newly selected branch
    _fetchServicesForBranch(id);
  }

  // ─── Validation ───────────────────────────────────────────────────

  bool _validate() {
    if (showBranch && selectedBranchId.value == null) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.branchRequired'.trns(),
      );
      return false;
    }
    if (nameCtrl.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.nameRequired'.trns(),
      );
      return false;
    }
    if (startDateCtrl.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.startingFromRequired'.trns(),
      );
      return false;
    }
    if (endDateCtrl.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.endingOnRequired'.trns(),
      );
      return false;
    }
    if (selectedStatus.value.isEmpty) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.statusRequired'.trns(),
      );
      return false;
    }
    if (packagePriceCtrl.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.priceRequired'.trns(),
      );
      return false;
    }
    // Validate at least one service with a valid selection
    bool hasValidService = false;
    for (final item in serviceItems) {
      if (item.selectedServiceId.value == null) continue;
      if (item.isVariationType && item.selectedVariationId.value == null) {
        SnackbarService.showError(
          title: 'addPackage.errorTitle'.trns(),
          message: 'addPackage.validation.variationRequired'.trns(),
        );
        return false;
      }
      hasValidService = true;
    }
    if (!hasValidService) {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: 'addPackage.validation.atLeastOneService'.trns(),
      );
      return false;
    }
    return true;
  }

  // ─── Save ─────────────────────────────────────────────────────────

  void save() {
    if (!_validate()) return;

    isSaving.value = true;
    _performSave().then((_) {
      isSaving.value = false;
    });
  }

  Future<void> _performSave() async {
    final servicesPayload = <Map<String, dynamic>>[];
    for (final item in serviceItems) {
      if (item.selectedServiceId.value == null) continue;
      final entry = <String, dynamic>{
        'service_id': item.selectedServiceId.value,
      };
      if (item.isVariationType && item.selectedVariationId.value != null) {
        entry['variation_id'] = item.selectedVariationId.value;
      }
      servicesPayload.add(entry);
    }

    final id = _editingPackage?.id;
    final response = id == null
        ? await _repository.createPackage(
            branchId: showBranch ? selectedBranchId.value : null,
            name: nameCtrl.text.trim(),
            startingFrom: _toApiDate(startDateCtrl.text),
            endingOn: _toApiDate(endDateCtrl.text),
            status: selectedStatus.value,
            description: descriptionCtrl.text.trim(),
            packagePrice: packagePriceCtrl.text.trim(),
            services: servicesPayload,
          )
        : await _repository.updatePackage(
            id: id,
            branchId: showBranch ? selectedBranchId.value : null,
            name: nameCtrl.text.trim(),
            startingFrom: _toApiDate(startDateCtrl.text),
            endingOn: _toApiDate(endDateCtrl.text),
            status: selectedStatus.value,
            description: descriptionCtrl.text.trim(),
            packagePrice: packagePriceCtrl.text.trim(),
            services: servicesPayload,
          );

    if (response.isCompleted) {
      SnackbarService.showSuccess(
        title: id == null
            ? 'addPackage.createSuccessTitle'.trns()
            : 'addPackage.updateSuccessTitle'.trns(),
        message: response.message ??
            (id == null
                ? 'addPackage.createSuccessMessage'.trns()
                : 'addPackage.updateSuccessMessage'.trns()),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
      });
      Navigator.of(Get.context!).pop(true); 
    } else {
      SnackbarService.showError(
        title: 'addPackage.errorTitle'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  // ─── Date helpers ─────────────────────────────────────────────────

  /// Display (MM/DD/YYYY) → API (YYYY/MM/DD)
  String _toApiDate(String displayDate) {
    if (displayDate.isEmpty) return '';
    final parts = displayDate.split('/');
    if (parts.length != 3) return displayDate;
    return '${parts[2]}/${parts[0]}/${parts[1]}';
  }

  /// API (YYYY-MM-DD) → Display (MM/DD/YYYY)
  String _toDisplayDate(String apiDate) {
    if (apiDate.isEmpty) return '';
    final parts = apiDate.split('-');
    if (parts.length != 3) return apiDate;
    return '${parts[1]}/${parts[2]}/${parts[0]}';
  }
}