// lib/app/modules/createBooking/controllers/create_booking_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/modules/customers/repositories/customer_repository.dart';
import 'package:va_bookats/app/modules/mediaLibrary/controllers/media_library_controller.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/models/lookup_option.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/navigation_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/media-selector-sheet.dart';

// ─── Row models ──────────────────────────────────────────────────────────────

class PackageFormItem {
  final TextEditingController packageCtrl = TextEditingController();
  final TextEditingController employeeCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');
  final TextEditingController totalCtrl = TextEditingController();

  final RxString selectedPackageId = ''.obs;
  final RxString selectedEmployeeId = ''.obs;
  final RxList<LookupOption> employeeOptions = <LookupOption>[].obs;
  final RxBool isLoadingStaffs = false.obs;

  void dispose() {
    packageCtrl.dispose();
    employeeCtrl.dispose();
    amountCtrl.dispose();
    discountCtrl.dispose();
    totalCtrl.dispose();
  }

  bool get isEmptyRow =>
      selectedPackageId.value.isEmpty &&
      amountCtrl.text.trim().isEmpty &&
      selectedEmployeeId.value.isEmpty;

  bool get isComplete =>
      selectedPackageId.value.isNotEmpty &&
      amountCtrl.text.trim().isNotEmpty &&
      totalCtrl.text.trim().isNotEmpty;
}

class ServiceFormItem {
  final TextEditingController serviceCtrl = TextEditingController();
  final TextEditingController variationCtrl = TextEditingController();
  final TextEditingController employeeCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');
  final TextEditingController totalCtrl = TextEditingController();

  final RxString selectedServiceId = ''.obs;
  final RxString selectedVariationId = ''.obs;
  final RxString selectedEmployeeId = ''.obs;
  final RxList<ServiceVariationLookup> variationOptions =
      <ServiceVariationLookup>[].obs;
  final RxList<LookupOption> employeeOptions = <LookupOption>[].obs;
  final RxBool isLoadingStaffs = false.obs;
  final RxBool isVariationType = false.obs;

  void dispose() {
    serviceCtrl.dispose();
    variationCtrl.dispose();
    employeeCtrl.dispose();
    amountCtrl.dispose();
    discountCtrl.dispose();
    totalCtrl.dispose();
  }

  bool get isEmptyRow =>
      selectedServiceId.value.isEmpty &&
      amountCtrl.text.trim().isEmpty &&
      selectedEmployeeId.value.isEmpty;

  bool get isComplete {
    if (selectedServiceId.value.isEmpty) return false;
    if (isVariationType.value && selectedVariationId.value.isEmpty) {
      return false;
    }
    return amountCtrl.text.trim().isNotEmpty &&
        totalCtrl.text.trim().isNotEmpty;
  }
}

class ProductFormItem {
  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController variantCtrl = TextEditingController();
  final TextEditingController quantityCtrl =
      TextEditingController(text: '1');
  final TextEditingController unitPriceCtrl = TextEditingController();
  final TextEditingController totalCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');
  final TextEditingController afterDiscountCtrl = TextEditingController();

  final RxString selectedProductId = ''.obs;
  final RxString selectedVariantId = ''.obs;
  final RxList<ProductVariantLookup> variantOptions =
      <ProductVariantLookup>[].obs;
  final RxInt availableStock = 0.obs;

  void dispose() {
    productCtrl.dispose();
    variantCtrl.dispose();
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
    totalCtrl.dispose();
    discountCtrl.dispose();
    afterDiscountCtrl.dispose();
  }

  bool get isEmptyRow =>
      selectedProductId.value.isEmpty &&
      quantityCtrl.text.trim().isEmpty;

  bool get isComplete =>
      selectedProductId.value.isNotEmpty &&
      quantityCtrl.text.trim().isNotEmpty &&
      unitPriceCtrl.text.trim().isNotEmpty &&
      totalCtrl.text.trim().isNotEmpty &&
      afterDiscountCtrl.text.trim().isNotEmpty;
}

// ─── Controller ──────────────────────────────────────────────────────────────

class CreateBookingController extends GetxController {
  CreateBookingController({
    BookingRepository? repository,
    CustomerRepository? customerRepository,
  })  : _repository = repository,
        _customerRepository = customerRepository;

  final BookingRepository? _repository;
  final CustomerRepository? _customerRepository;

  BookingRepository get _repo {
    final r = _repository;
    if (r != null) return r;
    if (Get.isRegistered<BookingRepository>()) {
      return Get.find<BookingRepository>();
    }
    return BookingRepository();
  }

  CustomerRepository get _customerRepo {
    final r = _customerRepository;
    if (r != null) return r;
    if (Get.isRegistered<CustomerRepository>()) {
      return Get.find<CustomerRepository>();
    }
    return CustomerRepository();
  }

  final AuthService _auth = Get.find<AuthService>();
  bool get showBranch => _auth.isOwner;

  // ── Stepper ────────────────────────────────────────────────────────────
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 5;
  final List<GlobalKey<FormState>> stepKeys =
      List.generate(5, (_) => GlobalKey<FormState>());

  // ── Step 1 ─────────────────────────────────────────────────────────────
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController bookingTypeCtrl = TextEditingController();
  final TextEditingController customerCtrl = TextEditingController();
  final TextEditingController guestNameCtrl = TextEditingController();
  final TextEditingController guestEmailCtrl = TextEditingController();
  final TextEditingController guestPhoneCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController startTimeCtrl = TextEditingController();
  final TextEditingController endTimeCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  final RxString selectedBranch = ''.obs;
  final RxnInt selectedBranchId = RxnInt();
  final RxString selectedBranchValue = ''.obs;
  final RxString selectedBookingType = ''.obs;
  final RxString selectedCustomer = ''.obs;
  final RxnInt selectedCustomerId = RxnInt();
  final RxString selectedCustomerValue = ''.obs;

  static const List<String> bookingTypes = ['Guest', 'Customer'];
  bool get isCustomerType =>
      selectedBookingType.value.toLowerCase() == 'customer';
  bool get isGuestType =>
      selectedBookingType.value.toLowerCase() == 'guest';

  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<LookupOption> customerOptions = <LookupOption>[].obs;
  final RxBool isLoadingBranches = false.obs;
  final RxBool isLoadingCustomers = false.obs;

  List<String> get branchLabels => branches.map((b) => b.displayLabel).toList();
  List<String> get branchValues =>
      branches.map((b) => b.value?.toString() ?? '').toList();

  // Quick-add customer dialog
  final TextEditingController addCustomerNameCtrl = TextEditingController();
  final TextEditingController addCustomerPhoneCtrl = TextEditingController();
  final TextEditingController addCustomerEmailCtrl = TextEditingController();
  final RxBool isAddingCustomer = false.obs;

  // ── Steps 2-4 ──────────────────────────────────────────────────────────
  final RxList<PackageFormItem> packageItems = <PackageFormItem>[].obs;
  final RxList<ServiceFormItem> serviceItems = <ServiceFormItem>[].obs;
  final RxList<ProductFormItem> productItems = <ProductFormItem>[].obs;

  final RxList<PackageLookup> packageOptions = <PackageLookup>[].obs;
  final RxList<ServiceLookup> serviceOptions = <ServiceLookup>[].obs;
  final RxList<ProductLookup> productOptions = <ProductLookup>[].obs;
  final RxBool isLoadingPackages = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingProducts = false.obs;

  List<String> get packageLabels =>
      packageOptions.map((p) => p.cleanName).toList();
  List<String> get packageValues =>
      packageOptions.map((p) => p.value.toString()).toList();
  List<String> get serviceLabels =>
      serviceOptions.map((s) => s.label).toList();
  List<String> get serviceValues =>
      serviceOptions.map((s) => s.value.toString()).toList();
  List<String> get productLabels =>
      productOptions.map((p) => p.label).toList();
  List<String> get productValues =>
      productOptions.map((p) => p.value.toString()).toList();

  // ── Step 5 ─────────────────────────────────────────────────────────────
  final TextEditingController totalAmountCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');
  final TextEditingController balanceCtrl = TextEditingController();
  final TextEditingController amountPaidCtrl = TextEditingController(text: '0');
  final TextEditingController paymentMethodCtrl = TextEditingController();
  final TextEditingController bookingStatusCtrl =
      TextEditingController(text: BookingStatus.pending);
  final TextEditingController transactionIdCtrl = TextEditingController();

  final RxString selectedPaymentMethod = ''.obs;
  final RxString selectedBookingStatus = BookingStatus.pending.obs;
  final Rxn<MediaItem> slipMedia = Rxn<MediaItem>();
  final RxString slipFileName = 'No File Chosen'.obs;
  String? existingSlipUrl;

  static const List<String> paymentMethods = ['Cash', 'Card', 'Online'];

  // ── States ─────────────────────────────────────────────────────────────
  final RxBool isSaving = false.obs;
  final RxBool isLoadingDetail = false.obs;

  BookingModel? _editing;
  bool get isEditMode => _editing != null;

  bool get isDirty {
    if (branchCtrl.text.isNotEmpty ||
        bookingTypeCtrl.text.isNotEmpty ||
        customerCtrl.text.isNotEmpty ||
        guestNameCtrl.text.isNotEmpty ||
        dateCtrl.text.isNotEmpty ||
        noteCtrl.text.isNotEmpty ||
        totalAmountCtrl.text.isNotEmpty ||
        transactionIdCtrl.text.isNotEmpty ||
        slipMedia.value != null) {
      return true;
    }
    if (packageItems.any((p) => !p.isEmptyRow)) return true;
    if (serviceItems.any((s) => !s.isEmptyRow)) return true;
    if (productItems.any((p) => !p.isEmptyRow)) return true;
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    selectedBookingStatus.value = BookingStatus.pending;
    bookingStatusCtrl.text = BookingStatus.pending;
    _readArguments();
    fetchBranches();
    fetchCustomers();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is BookingModel) {
      _editing = args;
      _prefillFromBooking(args);
      fetchDetail(args.id);
    } else if (args is int) {
      isLoadingDetail.value = true;
      _repo.getBookingDetail(args).then((res) {
        isLoadingDetail.value = false;
        if (res.isCompleted && res.data != null) {
          _editing = res.data;
          _prefillFromBooking(res.data!);
        }
      });
    }
  }

  // ─── Lookups ───────────────────────────────────────────────────────────

  Future<void> fetchBranches() async {
    if (branches.isNotEmpty) return;
    isLoadingBranches.value = true;
    final res = await _repo.getBranches();
    isLoadingBranches.value = false;
    if (res.isCompleted && res.data != null) {
      branches.assignAll(res.data!);
      if (selectedBranchId.value != null) {
        for (final b in branches) {
          if (b.value == selectedBranchId.value) {
            selectedBranch.value = b.displayLabel;
            branchCtrl.text = b.displayLabel;
            break;
          }
        }
      }
    }
  }

  Future<void> fetchCustomers() async {
    if (customerOptions.isNotEmpty) return;
    isLoadingCustomers.value = true;
    final res = await _repo.getCustomers();
    isLoadingCustomers.value = false;
    if (res.isCompleted && res.data != null) {
      customerOptions.assignAll(res.data!);
      _syncCustomerLabel();
    }
  }

  void _syncCustomerLabel() {
    final id = selectedCustomerId.value;
    if (id == null) return;
    selectedCustomerValue.value = id.toString();
    for (final o in customerOptions) {
      if (o.valueAsInt == id) {
        selectedCustomer.value = o.label;
        customerCtrl.text = o.label;
        break;
      }
    }
  }

  Future<void> fetchBranchCatalogs() async {
    final branchId = selectedBranchId.value;
    if (branchId == null) {
      packageOptions.clear();
      serviceOptions.clear();
      productOptions.clear();
      return;
    }
    await Future.wait([
      fetchPackages(),
      fetchServices(),
      fetchProducts(),
    ]);
  }

  Future<void> fetchPackages() async {
    final branchId = selectedBranchId.value;
    if (branchId == null) return;
    isLoadingPackages.value = true;
    final res = await _repo.getPackages(branchId);
    isLoadingPackages.value = false;
    if (res.isCompleted && res.data != null) {
      packageOptions.assignAll(res.data!);
    }
  }

  Future<void> fetchServices() async {
    final branchId = selectedBranchId.value;
    if (branchId == null) return;
    isLoadingServices.value = true;
    final res = await _repo.getServices(branchId);
    isLoadingServices.value = false;
    if (res.isCompleted && res.data != null) {
      serviceOptions.assignAll(res.data!);
    }
  }

  Future<void> fetchProducts() async {
    final branchId = selectedBranchId.value;
    if (branchId == null) return;
    isLoadingProducts.value = true;
    final res = await _repo.getProducts(branchId);
    isLoadingProducts.value = false;
    if (res.isCompleted && res.data != null) {
      productOptions.assignAll(res.data!);
    }
  }

  // ─── Step 1 handlers ───────────────────────────────────────────────────

  void onBranchSelected(dynamic value) {
    selectedBranchId.value =
        value == null ? null : int.tryParse(value.toString());
    selectedBranchValue.value = value?.toString() ?? '';
    // Branch scopes packages/services/products → reset dependent rows.
    for (final p in packageItems) {
      p.dispose();
    }
    packageItems.clear();
    for (final s in serviceItems) {
      s.dispose();
    }
    serviceItems.clear();
    for (final p in productItems) {
      p.dispose();
    }
    productItems.clear();
    fetchBranchCatalogs();
  }

  void onBookingTypeSelected(String type) {
    selectedBookingType.value = type;
    bookingTypeCtrl.text = type;
    if (!isCustomerType) {
      selectedCustomer.value = '';
      customerCtrl.clear();
      selectedCustomerId.value = null;
    } else {
      guestNameCtrl.clear();
      guestEmailCtrl.clear();
      guestPhoneCtrl.clear();
    }
  }

  void onCustomerSelected(dynamic value) {
    selectedCustomerId.value =
        value == null ? null : int.tryParse(value.toString());
    selectedCustomerValue.value = value?.toString() ?? '';
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = now;
    if (dateCtrl.text.isNotEmpty) {
      try {
        initial = DateTime.parse(dateCtrl.text);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFE7F14),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dateCtrl.text = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> pickTime(
    BuildContext context,
    TextEditingController target,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFE7F14),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      target.text = '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> quickAddCustomer() async {
    final name = addCustomerNameCtrl.text.trim();
    final phone = addCustomerPhoneCtrl.text.trim();
    final email = addCustomerEmailCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please fill all customer fields',
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please enter a valid email address',
      );
      return;
    }
    isAddingCustomer.value = true;
    final res = await _customerRepo.createCustomer(
      name: name,
      email: email,
      phonePrimary: phone,
    );
    isAddingCustomer.value = false;
    if (!res.isCompleted || res.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: res.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }
    final created = res.data!;
    final option = LookupOption(
      label: created.name,
      value: created.id.toString(),
    );
    customerOptions.insert(0, option);
    selectedCustomer.value = option.label;
    customerCtrl.text = option.label;
    selectedCustomerId.value = created.id;
    selectedCustomerValue.value = created.id.toString();
    addCustomerNameCtrl.clear();
    addCustomerPhoneCtrl.clear();
    addCustomerEmailCtrl.clear();
    Get.back();
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: res.message ?? 'Customer added successfully',
    );
  }

  // ─── Packages ──────────────────────────────────────────────────────────

  void addPackage() => packageItems.add(PackageFormItem());

  void removePackage(int index) {
    if (index < 0 || index >= packageItems.length) return;
    packageItems[index].dispose();
    packageItems.removeAt(index);
  }

  void onPackageSelected(PackageFormItem item, dynamic value) {
    item.selectedPackageId.value = value?.toString() ?? '';
    item.selectedEmployeeId.value = '';
    item.employeeCtrl.clear();
    item.employeeOptions.clear();
    PackageLookup? found;
    for (final p in packageOptions) {
      if (p.value.toString() == item.selectedPackageId.value) {
        found = p;
        break;
      }
    }
    if (found != null) {
      if (item.amountCtrl.text.trim().isEmpty) {
        item.amountCtrl.text = found.price;
      }
      _recalcRowTotal(item.amountCtrl, item.discountCtrl, item.totalCtrl);
    }
    _fetchPackageStaffs(item);
  }

  Future<void> _fetchPackageStaffs(PackageFormItem item) async {
    final pkgId = int.tryParse(item.selectedPackageId.value);
    if (pkgId == null) return;
    item.isLoadingStaffs.value = true;
    final res = await _repo.getPackageStaffs(
      packageId: pkgId,
      bookingDate: dateCtrl.text.trim().isEmpty
          ? null
          : dateCtrl.text.trim().replaceAll('-', '/'),
      startTime: startTimeCtrl.text.trim().isEmpty
          ? null
          : startTimeCtrl.text.trim(),
      endTime:
          endTimeCtrl.text.trim().isEmpty ? null : endTimeCtrl.text.trim(),
    );
    item.isLoadingStaffs.value = false;
    if (res.isCompleted && res.data != null) {
      item.employeeOptions.assignAll(res.data!);
    }
  }

  void onPackageEmployeeSelected(PackageFormItem item, dynamic value) {
    item.selectedEmployeeId.value = value?.toString() ?? '';
  }

  // ─── Services ──────────────────────────────────────────────────────────

  void addService() => serviceItems.add(ServiceFormItem());

  void removeService(int index) {
    if (index < 0 || index >= serviceItems.length) return;
    serviceItems[index].dispose();
    serviceItems.removeAt(index);
  }

  void onServiceSelected(ServiceFormItem item, dynamic value) {
    item.selectedServiceId.value = value?.toString() ?? '';
    item.selectedVariationId.value = '';
    item.variationCtrl.clear();
    item.variationOptions.clear();
    item.selectedEmployeeId.value = '';
    item.employeeCtrl.clear();
    item.employeeOptions.clear();
    ServiceLookup? found;
    for (final s in serviceOptions) {
      if (s.value.toString() == item.selectedServiceId.value) {
        found = s;
        break;
      }
    }
    if (found == null) return;
    item.isVariationType.value = found.isVariation;
    item.variationOptions.assignAll(found.variations);
    if (!found.isVariation && found.defaultPrice.isNotEmpty) {
      item.amountCtrl.text = found.defaultPrice;
      _recalcRowTotal(item.amountCtrl, item.discountCtrl, item.totalCtrl);
    } else {
      item.amountCtrl.clear();
      item.totalCtrl.clear();
    }
    _fetchServiceStaffs(item);
  }

  void onVariationSelected(ServiceFormItem item, dynamic value) {
    item.selectedVariationId.value = value?.toString() ?? '';
    for (final v in item.variationOptions) {
      if (v.id.toString() == item.selectedVariationId.value) {
        item.amountCtrl.text = v.price;
        _recalcRowTotal(item.amountCtrl, item.discountCtrl, item.totalCtrl);
        break;
      }
    }
  }

  Future<void> _fetchServiceStaffs(ServiceFormItem item) async {
    final serviceId = int.tryParse(item.selectedServiceId.value);
    if (serviceId == null) return;
    item.isLoadingStaffs.value = true;
    final res = await _repo.getServiceStaffs(serviceId);
    item.isLoadingStaffs.value = false;
    if (res.isCompleted && res.data != null) {
      item.employeeOptions.assignAll(res.data!);
    }
  }

  void onServiceEmployeeSelected(ServiceFormItem item, dynamic value) {
    item.selectedEmployeeId.value = value?.toString() ?? '';
  }

  // ─── Products ──────────────────────────────────────────────────────────

  void addProduct() => productItems.add(ProductFormItem());

  void removeProduct(int index) {
    if (index < 0 || index >= productItems.length) return;
    productItems[index].dispose();
    productItems.removeAt(index);
  }

  void onProductSelected(ProductFormItem item, dynamic value) {
    item.selectedProductId.value = value?.toString() ?? '';
    item.selectedVariantId.value = '';
    item.variantCtrl.clear();
    item.variantOptions.clear();
    ProductLookup? found;
    for (final p in productOptions) {
      if (p.value.toString() == item.selectedProductId.value) {
        found = p;
        break;
      }
    }
    if (found == null) return;
    item.variantOptions.assignAll(found.variants);
    item.availableStock.value = found.stock;
    if (!found.hasVariants && found.price.isNotEmpty) {
      item.unitPriceCtrl.text = found.price;
      _recalcProductTotals(item);
    } else {
      item.unitPriceCtrl.clear();
      item.totalCtrl.clear();
      item.afterDiscountCtrl.clear();
    }
  }

  void onVariantSelected(ProductFormItem item, dynamic value) {
    item.selectedVariantId.value = value?.toString() ?? '';
    for (final v in item.variantOptions) {
      if (v.id.toString() == item.selectedVariantId.value) {
        item.unitPriceCtrl.text = v.price;
        item.availableStock.value = v.stock;
        _recalcProductTotals(item);
        break;
      }
    }
  }

  void _recalcProductTotals(ProductFormItem item) {
    final qty = double.tryParse(item.quantityCtrl.text.trim()) ?? 0;
    final unit = double.tryParse(item.unitPriceCtrl.text.trim()) ?? 0;
    final discount = double.tryParse(item.discountCtrl.text.trim()) ?? 0;
    final total = qty * unit;
    item.totalCtrl.text =
        total == 0 ? '' : total.toStringAsFixed(2);
    final after = (total - discount).clamp(0, double.infinity);
    item.afterDiscountCtrl.text =
        total == 0 ? '' : after.toStringAsFixed(2);
  }

  void onProductQtyChanged(ProductFormItem item, String _) =>
      _recalcProductTotals(item);

  void onProductDiscountChanged(ProductFormItem item, String _) =>
      _recalcProductTotals(item);

  static void _recalcRowTotal(
    TextEditingController amount,
    TextEditingController discount,
    TextEditingController total,
  ) {
    final a = double.tryParse(amount.text.trim()) ?? 0;
    final d = double.tryParse(discount.text.trim()) ?? 0;
    final t = (a - d).clamp(0, double.infinity);
    total.text = a == 0 && d == 0 ? total.text : t.toStringAsFixed(2);
    if (a == 0 && d == 0 && total.text.isEmpty) return;
  }

  void recalcPackageRow(PackageFormItem item) =>
      _recalcRowTotal(item.amountCtrl, item.discountCtrl, item.totalCtrl);

  void recalcServiceRow(ServiceFormItem item) =>
      _recalcRowTotal(item.amountCtrl, item.discountCtrl, item.totalCtrl);

  // ─── Payment ───────────────────────────────────────────────────────────

  double get packagesSum {
    var sum = 0.0;
    for (final p in packageItems) {
      if (p.isEmptyRow) continue;
      sum += double.tryParse(p.totalCtrl.text.trim()) ?? 0;
    }
    return sum;
  }

  double get servicesSum {
    var sum = 0.0;
    for (final s in serviceItems) {
      if (s.isEmptyRow) continue;
      sum += double.tryParse(s.totalCtrl.text.trim()) ?? 0;
    }
    return sum;
  }

  double get productsSum {
    var sum = 0.0;
    for (final p in productItems) {
      if (p.isEmptyRow) continue;
      sum += double.tryParse(p.afterDiscountCtrl.text.trim()) ?? 0;
    }
    return sum;
  }

  double get computedGrandTotal => packagesSum + servicesSum + productsSum;

  void recalcPaymentTotals() {
    if (totalAmountCtrl.text.trim().isEmpty && computedGrandTotal > 0) {
      totalAmountCtrl.text = computedGrandTotal.toStringAsFixed(2);
    }
    final total = double.tryParse(totalAmountCtrl.text.trim()) ?? 0;
    final discount = double.tryParse(discountCtrl.text.trim()) ?? 0;
    final paid = double.tryParse(amountPaidCtrl.text.trim()) ?? 0;
    final remaining = (total - discount - paid).clamp(0, double.infinity);
    balanceCtrl.text = remaining.toStringAsFixed(2);
  }

  void onPaymentMethodSelected(String method) {
    selectedPaymentMethod.value = method;
    paymentMethodCtrl.text = method;
  }

  void onBookingStatusSelected(String status) {
    selectedBookingStatus.value = status;
    bookingStatusCtrl.text = status;
  }

  void pickSlip(BuildContext context) {
    MediaSelectorSheet.show(
      context,
      allowMultiple: false,
      initialSelectedIds:
          slipMedia.value == null ? const [] : [slipMedia.value!.mediaId],
      onConfirmed: (items) {
        if (items.isEmpty) return;
        slipMedia.value = items.first;
        slipFileName.value = items.first.name;
        existingSlipUrl = null;
      },
    );
  }

  // ─── Stepper navigation ────────────────────────────────────────────────

  bool _validateStep(int step) {
    final key = stepKeys[step];
    final form = key.currentState;
    if (form != null && !form.validate()) return false;

    switch (step) {
      case 0:
        return _validateStep1();
      case 1:
        return _validatePackages();
      case 2:
        return _validateServices();
      case 3:
        return _validateProducts();
      case 4:
        return true;
      default:
        return true;
    }
  }

  bool _validateStep1() {
    if (showBranch && selectedBranchId.value == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please select a branch',
      );
      return false;
    }
    if (selectedBookingType.value.isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please select a booking type',
      );
      return false;
    }
    if (isCustomerType && selectedCustomerId.value == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please select a customer',
      );
      return false;
    }
    if (dateCtrl.text.trim().isEmpty ||
        startTimeCtrl.text.trim().isEmpty ||
        endTimeCtrl.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please select date, start and end time',
      );
      return false;
    }
    return true;
  }

  bool _validatePackages() {
    for (final p in packageItems) {
      if (p.isEmptyRow) continue;
      if (!p.isComplete) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'Please complete each package row or remove it',
        );
        return false;
      }
    }
    return true;
  }

  bool _validateServices() {
    for (final s in serviceItems) {
      if (s.isEmptyRow) continue;
      if (!s.isComplete) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message:
              'Please complete each service row (variation required) or remove it',
        );
        return false;
      }
    }
    return true;
  }

  bool _validateProducts() {
    for (final p in productItems) {
      if (p.isEmptyRow) continue;
      if (!p.isComplete) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'Please complete each product row or remove it',
        );
        return false;
      }
      final qty = int.tryParse(p.quantityCtrl.text.trim()) ?? 0;
      if (qty <= 0) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'Quantity must be at least 1',
        );
        return false;
      }
      if (p.availableStock.value > 0 && qty > p.availableStock.value) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message:
              'Quantity exceeds available stock (${p.availableStock.value})',
        );
        return false;
      }
    }
    return true;
  }

  bool get _hasAnyItem =>
      packageItems.any((p) => !p.isEmptyRow) ||
      serviceItems.any((s) => !s.isEmptyRow) ||
      productItems.any((p) => !p.isEmptyRow);

  void nextStep() {
    if (!_validateStep(currentStep.value)) return;
    if (currentStep.value == 0 && selectedBranchId.value != null) {
      // Catalogs must be ready before package/service/product steps.
      fetchBranchCatalogs();
    }
    if (currentStep.value == 3) {
      recalcPaymentTotals();
    }
    if (currentStep.value < totalSteps - 1) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step <= currentStep.value && step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  Future<bool> confirmDiscard(BuildContext context) async {
    if (!isDirty) return true;
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'Going back will discard all the information you have entered. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result == true;
  }

  /// System back / header back handling. Returns true when the route may pop.
  Future<bool> handleBack(BuildContext context) async {
    if (isSaving.value) return false;
    if (currentStep.value > 0) {
      previousStep();
      return false;
    }
    return confirmDiscard(context);
  }

  // ─── Prefill (edit) ────────────────────────────────────────────────────

  void _prefillFromBooking(BookingModel b) {
    selectedBranchId.value = b.branchId;
    selectedBranchValue.value = b.branchId?.toString() ?? '';
    if (b.branchId != null) {
      fetchBranches().then((_) {
        for (final br in branches) {
          if (br.value == b.branchId) {
            selectedBranch.value = br.displayLabel;
            branchCtrl.text = br.displayLabel;
            break;
          }
        }
      });
      fetchBranchCatalogs();
    }
    final type = (b.bookingType ?? '').isEmpty
        ? 'Customer'
        : _capitalize(b.bookingType!);
    selectedBookingType.value = type;
    bookingTypeCtrl.text = type;
    selectedCustomerId.value = b.customerId;
    if (b.customerId != null) {
      fetchCustomers();
    } else {
      selectedCustomer.value = b.customer?.name ?? '';
      customerCtrl.text = b.customer?.name ?? '';
    }
    guestNameCtrl.text = b.guestName ?? '';
    guestEmailCtrl.text = b.guestEmail ?? '';
    guestPhoneCtrl.text = b.guestPhone ?? '';
    dateCtrl.text = b.bookingDate ?? '';
    startTimeCtrl.text = _toHHMM(b.startTime);
    endTimeCtrl.text = _toHHMM(b.endTime);
    noteCtrl.text = b.note ?? '';
    totalAmountCtrl.text = b.totalAmount ?? '';
    amountPaidCtrl.text = b.amountPaid ?? b.payment?.paidAmount ?? '0';
    discountCtrl.text = b.discount ?? b.payment?.discountAmount ?? '0';
    balanceCtrl.text = b.remainingAmount ?? b.payment?.balance ?? '';
    final method = b.paymentMethod ?? b.payment?.paymentMethod ?? '';
    selectedPaymentMethod.value = method;
    paymentMethodCtrl.text = method;
    final status = b.status.isEmpty ? BookingStatus.pending : b.status;
    selectedBookingStatus.value = status;
    bookingStatusCtrl.text = status;
    transactionIdCtrl.text =
        b.transactionId ?? b.payment?.transactionId ?? '';
    existingSlipUrl = b.payment?.slipThumbUrl ?? b.payment?.slipUrl;
    if (existingSlipUrl != null) slipFileName.value = 'Payment slip attached';
  }

  Future<void> fetchDetail(int id) async {
    isLoadingDetail.value = true;
    // Ensure catalogs exist so ids can resolve to labels/options.
    await fetchBranches();
    await fetchCustomers();
    await fetchBranchCatalogs();
    final res = await _repo.getBookingDetail(id);
    isLoadingDetail.value = false;
    if (!res.isCompleted || res.data == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: res.message ?? 'errors.requestFailed'.trns(),
      );
      return;
    }
    final detail = res.data!;
    _editing = detail;
    _prefillFromBooking(detail);
    _rebuildItems(detail);
  }

  void _rebuildItems(BookingModel detail) {
    for (final p in packageItems) {
      p.dispose();
    }
    packageItems.clear();
    for (final line in detail.packages) {
      final row = PackageFormItem();
      if (line.packageId != null) {
        row.selectedPackageId.value = line.packageId.toString();
        for (final p in packageOptions) {
          if (p.value == line.packageId) {
            row.packageCtrl.text = p.cleanName;
            break;
          }
        }
      }
      row.amountCtrl.text = line.amount ?? '';
      row.discountCtrl.text = line.discount ?? '0';
      row.totalCtrl.text = line.totalAmount ?? '';
      packageItems.add(row);
    }

    for (final s in serviceItems) {
      s.dispose();
    }
    serviceItems.clear();
    for (final line in detail.services) {
      final row = ServiceFormItem();
      if (line.serviceId != null) {
        row.selectedServiceId.value = line.serviceId.toString();
        for (final s in serviceOptions) {
          if (s.value == line.serviceId) {
            row.serviceCtrl.text = s.label;
            row.isVariationType.value = s.isVariation;
            row.variationOptions.assignAll(s.variations);
            break;
          }
        }
      }
      if (line.variationId != null) {
        row.selectedVariationId.value = line.variationId.toString();
        for (final v in row.variationOptions) {
          if (v.id == line.variationId) {
            row.variationCtrl.text = v.name;
            break;
          }
        }
      }
      if (line.employeeId != null) {
        row.selectedEmployeeId.value = line.employeeId.toString();
        row.employeeCtrl.text = line.employeeName ?? '';
      }
      row.amountCtrl.text = line.amount ?? '';
      row.discountCtrl.text = line.discount ?? '0';
      row.totalCtrl.text = line.totalAmount ?? '';
      serviceItems.add(row);
    }

    for (final p in productItems) {
      p.dispose();
    }
    productItems.clear();
    for (final line in detail.products) {
      final row = ProductFormItem();
      if (line.productId != null) {
        row.selectedProductId.value = line.productId.toString();
        for (final p in productOptions) {
          if (p.value == line.productId) {
            row.productCtrl.text = p.label;
            row.variantOptions.assignAll(p.variants);
            break;
          }
        }
      }
      if (line.variantId != null) {
        row.selectedVariantId.value = line.variantId.toString();
        for (final v in row.variantOptions) {
          if (v.id == line.variantId) {
            row.variantCtrl.text = v.displayName;
            row.availableStock.value = v.stock;
            break;
          }
        }
      }
      row.quantityCtrl.text = (line.quantity ?? 1).toString();
      row.unitPriceCtrl.text = line.unitPrice ?? '';
      row.totalCtrl.text = line.totalPrice ?? '';
      row.discountCtrl.text = line.discount ?? '0';
      row.afterDiscountCtrl.text = line.afterDiscountPrice ?? '';
      productItems.add(row);
    }
  }

  // ─── Submit ────────────────────────────────────────────────────────────

  List<ServiceDraft> _serviceDrafts() {
    final out = <ServiceDraft>[];
    for (final s in serviceItems) {
      if (s.isEmptyRow) continue;
      final id = int.tryParse(s.selectedServiceId.value);
      if (id == null) continue;
      out.add(ServiceDraft(
        serviceId: id,
        variationId: int.tryParse(s.selectedVariationId.value),
        employeeId: int.tryParse(s.selectedEmployeeId.value),
        amount: s.amountCtrl.text.trim().isEmpty
            ? '0'
            : s.amountCtrl.text.trim(),
        discount: s.discountCtrl.text.trim().isEmpty
            ? '0'
            : s.discountCtrl.text.trim(),
        totalAmount: s.totalCtrl.text.trim().isEmpty
            ? '0'
            : s.totalCtrl.text.trim(),
      ));
    }
    return out;
  }

  List<PackageDraft> _packageDrafts() {
    final out = <PackageDraft>[];
    for (final p in packageItems) {
      if (p.isEmptyRow) continue;
      final id = int.tryParse(p.selectedPackageId.value);
      if (id == null) continue;
      final staffId = int.tryParse(p.selectedEmployeeId.value);
      out.add(PackageDraft(
        packageId: id,
        amount: p.amountCtrl.text.trim().isEmpty
            ? '0'
            : p.amountCtrl.text.trim(),
        discount: p.discountCtrl.text.trim().isEmpty
            ? '0'
            : p.discountCtrl.text.trim(),
        totalAmount: p.totalCtrl.text.trim().isEmpty
            ? '0'
            : p.totalCtrl.text.trim(),
        staffIds: staffId == null ? const [] : [staffId],
      ));
    }
    return out;
  }

  List<ProductDraft> _productDrafts() {
    final out = <ProductDraft>[];
    for (final p in productItems) {
      if (p.isEmptyRow) continue;
      final id = int.tryParse(p.selectedProductId.value);
      if (id == null) continue;
      out.add(ProductDraft(
        productId: id,
        variantId: int.tryParse(p.selectedVariantId.value),
        quantity: p.quantityCtrl.text.trim().isEmpty
            ? '1'
            : p.quantityCtrl.text.trim(),
        unitPrice: p.unitPriceCtrl.text.trim().isEmpty
            ? '0'
            : p.unitPriceCtrl.text.trim(),
        totalPrice: p.totalCtrl.text.trim().isEmpty
            ? '0'
            : p.totalCtrl.text.trim(),
        discount: p.discountCtrl.text.trim().isEmpty
            ? '0'
            : p.discountCtrl.text.trim(),
        afterDiscountPrice: p.afterDiscountCtrl.text.trim().isEmpty
            ? '0'
            : p.afterDiscountCtrl.text.trim(),
      ));
    }
    return out;
  }

  Future<void> submit(BuildContext context) async {
    // Validate every step's form before submitting.
    for (var i = 0; i < totalSteps; i++) {
      if (!_validateStep(i)) {
        currentStep.value = i;
        return;
      }
    }
    if (!_hasAnyItem) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'Please add at least one package, service or product',
      );
      return;
    }

    recalcPaymentTotals();
    isSaving.value = true;
    try {
      final type = selectedBookingType.value.isEmpty
          ? 'Guest'
          : selectedBookingType.value;
      final isCustomer = type.toLowerCase() == 'customer';
      final res = isEditMode
          ? await _repo.updateBooking(
              id: _editing!.id,
              branchId: showBranch ? selectedBranchId.value : null,
              bookingType: type,
              customerId: isCustomer ? selectedCustomerId.value : null,
              guestName:
                  isCustomer ? null : guestNameCtrl.text.trim().isEmpty
                      ? null
                      : guestNameCtrl.text.trim(),
              guestEmail:
                  isCustomer ? null : guestEmailCtrl.text.trim().isEmpty
                      ? null
                      : guestEmailCtrl.text.trim(),
              guestPhone:
                  isCustomer ? null : guestPhoneCtrl.text.trim().isEmpty
                      ? null
                      : guestPhoneCtrl.text.trim(),
              bookingDate: dateCtrl.text.trim(),
              startTime: startTimeCtrl.text.trim(),
              endTime: endTimeCtrl.text.trim(),
              note: noteCtrl.text.trim().isEmpty
                  ? null
                  : noteCtrl.text.trim(),
              totalAmount: totalAmountCtrl.text.trim().isEmpty
                  ? null
                  : totalAmountCtrl.text.trim(),
              amountPaid: amountPaidCtrl.text.trim().isEmpty
                  ? null
                  : amountPaidCtrl.text.trim(),
              discount: discountCtrl.text.trim().isEmpty
                  ? null
                  : discountCtrl.text.trim(),
              remainingAmount: balanceCtrl.text.trim().isEmpty
                  ? null
                  : balanceCtrl.text.trim(),
              paymentMethod: selectedPaymentMethod.value.isEmpty
                  ? null
                  : selectedPaymentMethod.value,
              status: selectedBookingStatus.value.isEmpty
                  ? null
                  : selectedBookingStatus.value,
              transactionId: transactionIdCtrl.text.trim().isEmpty
                  ? null
                  : transactionIdCtrl.text.trim(),
              mediaId: slipMedia.value?.mediaId,
              services: _serviceDrafts(),
              packages: _packageDrafts(),
              products: _productDrafts(),
            )
          : await _repo.createBooking(
              branchId: showBranch ? selectedBranchId.value : null,
              bookingType: type,
              customerId: isCustomer ? selectedCustomerId.value : null,
              guestName:
                  isCustomer ? null : guestNameCtrl.text.trim().isEmpty
                      ? null
                      : guestNameCtrl.text.trim(),
              guestEmail:
                  isCustomer ? null : guestEmailCtrl.text.trim().isEmpty
                      ? null
                      : guestEmailCtrl.text.trim(),
              guestPhone:
                  isCustomer ? null : guestPhoneCtrl.text.trim().isEmpty
                      ? null
                      : guestPhoneCtrl.text.trim(),
              bookingDate: dateCtrl.text.trim(),
              startTime: startTimeCtrl.text.trim(),
              endTime: endTimeCtrl.text.trim(),
              note: noteCtrl.text.trim().isEmpty
                  ? null
                  : noteCtrl.text.trim(),
              totalAmount: totalAmountCtrl.text.trim().isEmpty
                  ? null
                  : totalAmountCtrl.text.trim(),
              amountPaid: amountPaidCtrl.text.trim().isEmpty
                  ? null
                  : amountPaidCtrl.text.trim(),
              discount: discountCtrl.text.trim().isEmpty
                  ? null
                  : discountCtrl.text.trim(),
              remainingAmount: balanceCtrl.text.trim().isEmpty
                  ? null
                  : balanceCtrl.text.trim(),
              paymentMethod: selectedPaymentMethod.value.isEmpty
                  ? null
                  : selectedPaymentMethod.value,
              status: selectedBookingStatus.value.isEmpty
                  ? null
                  : selectedBookingStatus.value,
              transactionId: transactionIdCtrl.text.trim().isEmpty
                  ? null
                  : transactionIdCtrl.text.trim(),
              mediaId: slipMedia.value?.mediaId,
              services: _serviceDrafts(),
              packages: _packageDrafts(),
              products: _productDrafts(),
            );

      if (res.isCompleted && res.data != null) {
        SnackbarService.showSuccess(
          title: 'common.success'.trns(),
          message: res.message ??
              (isEditMode
                  ? 'Booking updated successfully.'
                  : 'Booking created successfully.'),
        );
        if (!context.mounted) return;
        // Pop with the booking so the list can jump to its status tab.
        await NavigationHelper.safePop(context, res.data);
      } else {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: res.message ?? 'errors.requestFailed'.trns(),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static String _toHHMM(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    bookingTypeCtrl.dispose();
    customerCtrl.dispose();
    guestNameCtrl.dispose();
    guestEmailCtrl.dispose();
    guestPhoneCtrl.dispose();
    dateCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();
    noteCtrl.dispose();
    addCustomerNameCtrl.dispose();
    addCustomerPhoneCtrl.dispose();
    addCustomerEmailCtrl.dispose();
    totalAmountCtrl.dispose();
    discountCtrl.dispose();
    balanceCtrl.dispose();
    amountPaidCtrl.dispose();
    paymentMethodCtrl.dispose();
    bookingStatusCtrl.dispose();
    transactionIdCtrl.dispose();
    for (final p in packageItems) {
      p.dispose();
    }
    for (final s in serviceItems) {
      s.dispose();
    }
    for (final p in productItems) {
      p.dispose();
    }
    super.onClose();
  }
}
