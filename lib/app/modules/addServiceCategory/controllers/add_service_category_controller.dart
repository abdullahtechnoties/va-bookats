// lib/app/modules/add_service_category/controllers/add_service_category_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';

class AddServiceCategoryController extends GetxController {
  final bool isEditMode;

  AddServiceCategoryController({this.isEditMode = false});

  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final RxString selectedBranch = ''.obs;

  final List<String> branches = ['Branch A', 'Branch B', 'Branch C'];

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
        message: 'Please enter category name',
      );
      return;
    }

    SnackbarService.showSuccess(
      title: 'Success',
      message: isEditMode
          ? 'Category updated successfully!'
          : 'Category added successfully!',
    );
    Get.back();
  }

  @override
  void onClose() {
    branchCtrl.dispose();
    nameCtrl.dispose();
    super.onClose();
  }
}