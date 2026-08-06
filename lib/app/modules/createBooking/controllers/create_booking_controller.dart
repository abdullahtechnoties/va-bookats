// lib/app/modules/create_booking/controllers/create_booking_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';

enum ServiceType { packages, services, products }

class PackageItem {
  final TextEditingController packageCtrl = TextEditingController();
  final TextEditingController employeeCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController();
  final TextEditingController totalCtrl = TextEditingController();

  final RxString selectedPackage = ''.obs;
  final RxString selectedEmployee = ''.obs;

  void dispose() {
    packageCtrl.dispose();
    employeeCtrl.dispose();
    amountCtrl.dispose();
    discountCtrl.dispose();
    totalCtrl.dispose();
  }
}

class ServiceItem {
  final TextEditingController serviceCtrl = TextEditingController();
  final TextEditingController variationCtrl = TextEditingController();
  final TextEditingController employeeCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController();
  final TextEditingController totalCtrl = TextEditingController();

  final RxString selectedService = ''.obs;
  final RxString selectedVariation = ''.obs;
  final RxString selectedEmployee = ''.obs;

  void dispose() {
    serviceCtrl.dispose();
    variationCtrl.dispose();
    employeeCtrl.dispose();
    amountCtrl.dispose();
    discountCtrl.dispose();
    totalCtrl.dispose();
  }
}

class ProductItem {
  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController variationCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();
  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController unitPriceCtrl = TextEditingController();
  final TextEditingController totalCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController();
  final TextEditingController totalAfterDiscountCtrl = TextEditingController();

  final RxString selectedProduct = ''.obs;
  final RxString selectedVariation = ''.obs;
  final RxString selectedStock = ''.obs;

  void dispose() {
    productCtrl.dispose();
    variationCtrl.dispose();
    stockCtrl.dispose();
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
    totalCtrl.dispose();
    discountCtrl.dispose();
    totalAfterDiscountCtrl.dispose();
  }
}

class CreateBookingController extends GetxController {
  // ── Stepper ──────────────────────────────────────────────────────────────
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 5;

  // ── Step 1 – Booking Info ────────────────────────────────────────────────
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController bookingTypeCtrl = TextEditingController();
  final TextEditingController customerCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController startTimeCtrl = TextEditingController();
  final TextEditingController endTimeCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  final RxString selectedBranch = ''.obs;
  final RxString selectedBookingType = ''.obs;
  final RxString selectedCustomer = ''.obs;
  final Rx<ServiceType> selectedServiceType = ServiceType.packages.obs;

  // Dropdown options
  final List<String> branches = ['Branch A', 'Branch B', 'Branch C'];
  final List<String> bookingTypes = ['Walk-in', 'Online', 'Phone'];
  final List<String> customers = [
    'Shahid Mirza',
    'Ali Khan',
    'Sara Ahmed',
    'John Doe',
  ];

  // ── Add Customer Dialog ──────────────────────────────────────────────────
  final TextEditingController addCustomerNameCtrl = TextEditingController();
  final TextEditingController addCustomerPhoneCtrl = TextEditingController();
  final TextEditingController addCustomerEmailCtrl = TextEditingController();

  // ── Step 2 – Packages ────────────────────────────────────────────────────
  final RxList<PackageItem> packageItems = <PackageItem>[PackageItem()].obs;
  final List<String> packageOptions = [
    'Bridal Package',
    'Hair Package',
    'Spa Package',
  ];
  final List<String> employeeOptions = [
    'Ahmed Ali',
    'Sara Khan',
    'John Smith',
  ];

  // ── Step 3 – Services ────────────────────────────────────────────────────
  final RxList<ServiceItem> serviceItems = <ServiceItem>[ServiceItem()].obs;
  final List<String> serviceOptions = [
    'Haircut',
    'Facial',
    'Waxing',
    'Massage',
    'Manicure',
  ];
  final List<String> variationOptions = [
    'Standard',
    'Premium',
    'Deluxe',
  ];

  // ── Step 4 – Products ────────────────────────────────────────────────────
  final RxList<ProductItem> productItems = <ProductItem>[ProductItem()].obs;
  final List<String> productOptions = [
    'Shampoo',
    'Conditioner',
    'Hair Oil',
    'Face Wash',
  ];
  final List<String> stockOptions = ['In Stock', 'Low Stock', 'Out of Stock'];

  // ── Step 5 – Payment ─────────────────────────────────────────────────────
  final TextEditingController totalAmountCtrl = TextEditingController(text: '00');
  final TextEditingController discountCtrl = TextEditingController(text: '00');
  final TextEditingController balanceCtrl = TextEditingController(text: '00');
  final TextEditingController amountPaidCtrl = TextEditingController(text: '00');
  final TextEditingController paymentMethodCtrl = TextEditingController();
  final TextEditingController bookingStatusCtrl = TextEditingController();
  final TextEditingController transactionIdCtrl = TextEditingController();

  final RxString selectedPaymentMethod = ''.obs;
  final RxString selectedBookingStatus = ''.obs;
  final RxString paymentSlipFileName = 'No File Chosen'.obs;

  final List<String> paymentMethods = ['Cash', 'Card', 'Online Transfer', 'Cheque'];
  final List<String> bookingStatuses = ['Active', 'Pending', 'Completed', 'Cancelled'];

  // ── Navigation ───────────────────────────────────────────────────────────
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  void goToStep(int step) {
    if (step <= currentStep.value) {
      currentStep.value = step;
    }
  }

  // ── Step 2 Package Actions ───────────────────────────────────────────────
  void addPackage() {
    packageItems.add(PackageItem());
  }

  void removePackage(int index) {
    if (packageItems.length > 1) {
      packageItems[index].dispose();
      packageItems.removeAt(index);
    }
  }

  // ── Step 3 Service Actions ───────────────────────────────────────────────
  void addService() {
    serviceItems.add(ServiceItem());
  }

  void removeService(int index) {
    if (serviceItems.length > 1) {
      serviceItems[index].dispose();
      serviceItems.removeAt(index);
    }
  }

  // ── Step 4 Product Actions ───────────────────────────────────────────────
  void addProduct() {
    productItems.add(ProductItem());
  }

  void removeProduct(int index) {
    if (productItems.length > 1) {
      productItems[index].dispose();
      productItems.removeAt(index);
    }
  }

  // ── Add Customer ─────────────────────────────────────────────────────────
  void addCustomer() {
    final name = addCustomerNameCtrl.text.trim();
    final phone = addCustomerPhoneCtrl.text.trim();
    final email = addCustomerEmailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      SnackbarService.showError(
        title: 'Error',
        message: 'Please fill all customer fields',
      );
      return;
    }

    customers.add(name);
    selectedCustomer.value = name;
    customerCtrl.text = name;

    addCustomerNameCtrl.clear();
    addCustomerPhoneCtrl.clear();
    addCustomerEmailCtrl.clear();

    Get.back();

    SnackbarService.showSuccess(
      title: 'Success',
      message: 'Customer added successfully',
    );
  }

  // ── Payment Slip ─────────────────────────────────────────────────────────
  void pickPaymentSlip() {
    // TODO: integrate file_picker
    paymentSlipFileName.value = 'payment_slip.jpg';
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  void saveBooking() {
    SnackbarService.showSuccess(
      title: 'Success',
      message: 'Booking created successfully!',
    );
    Get.back();
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    bookingTypeCtrl.dispose();
    customerCtrl.dispose();
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
    for (final p in packageItems) p.dispose();
    for (final s in serviceItems) s.dispose();
    for (final pr in productItems) pr.dispose();
    super.onClose();
  }
}