// lib/app/modules/add_package/controllers/add_package_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';

class PackageServiceItem {
  final TextEditingController serviceCtrl = TextEditingController();
  final TextEditingController priceCtrl =
      TextEditingController(text: '999.00');
  final TextEditingController totalPriceCtrl =
      TextEditingController(text: '999.00');
  final TextEditingController packagePriceCtrl =
      TextEditingController(text: '599.00');
  final RxString selectedService = ''.obs;

  void dispose() {
    serviceCtrl.dispose();
    priceCtrl.dispose();
    totalPriceCtrl.dispose();
    packagePriceCtrl.dispose();
  }
}

class AddPackageController extends GetxController {
  final bool isEditMode;

  AddPackageController({this.isEditMode = false});

  // Package Info
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();

  final RxString selectedBranch = ''.obs;
  final RxString selectedStatus = ''.obs;

  // Service Items
  final RxList<PackageServiceItem> serviceItems =
      <PackageServiceItem>[PackageServiceItem()].obs;

  // Dropdown options
  final List<String> branches = ['Branch A', 'Branch B', 'Branch C'];
  final List<String> statusOptions = ['Active', 'Inactive'];
  final List<String> serviceOptions = [
    'Haircut',
    'Facial',
    'Waxing',
    'Massage',
    'Manicure',
    'Pedicure',
  ];

  void addServiceItem() {
    serviceItems.add(PackageServiceItem());
  }

  void removeServiceItem(int index) {
    if (serviceItems.length > 1) {
      serviceItems[index].dispose();
      serviceItems.removeAt(index);
    }
  }

  void save() {
    if (branchCtrl.text.isEmpty) {
      SnackbarService.showError(
        title: 'Validation Error',
        message: 'Please select a branch',
      );
      return;
    }
    if (nameCtrl.text.isEmpty) {
      SnackbarService.showError(
        title: 'Validation Error',
        message: 'Please enter package name',
      );
      return;
    }
    SnackbarService.showSuccess(
      title: 'Success',
      message: isEditMode
          ? 'Package updated successfully!'
          : 'Package added successfully!',
    );
    Get.back();
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    nameCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    statusCtrl.dispose();
    descriptionCtrl.dispose();
    for (final s in serviceItems) s.dispose();
    super.onClose();
  }
}