// lib/app/modules/add_service/controllers/add_service_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';

class AddServiceController extends GetxController {
  final bool isEditMode;

  AddServiceController({this.isEditMode = false});

  // Form Controllers
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController durationCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();

  // Observable selections
  final RxString selectedBranch = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString imageFileName = 'No File Chosen'.obs;

  // Dropdown Options
  final List<String> branches = ['Branch A', 'Branch B', 'Branch C'];
  final List<String> categories = [
    'Hair Color',
    'Hair Style',
    'Hair Extension',
    'Facial',
    'Waxing',
  ];
  final List<String> statusOptions = ['Active', 'Inactive'];
  final List<String> typeOptions = ['Standard', 'Premium', 'VIP'];

  void pickImage() {
    // TODO: integrate image_picker
    imageFileName.value = 'service_image.jpg';
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
        message: 'Please enter service name',
      );
      return;
    }

    SnackbarService.showSuccess(
      title: 'Success',
      message: isEditMode
          ? 'Service updated successfully!'
          : 'Service added successfully!',
    );
    Get.back();
  }

  void showAddCategoryDialog() {
    Get.dialog(const _AddServiceCategoryInlineDialog());
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    categoryCtrl.dispose();
    nameCtrl.dispose();
    durationCtrl.dispose();
    statusCtrl.dispose();
    typeCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}

// Inline dialog placeholder widget reference
class _AddServiceCategoryInlineDialog extends StatelessWidget {
  const _AddServiceCategoryInlineDialog();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}