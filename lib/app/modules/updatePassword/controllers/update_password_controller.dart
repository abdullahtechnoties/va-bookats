import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class UpdatePasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool showCurrent = false.obs;
  final RxBool showNew = false.obs;
  final RxBool showConfirm = false.obs;
  final RxBool isLoading = false.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'updatePassword.mismatch'.trns(),
      );
      return;
    }

    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'updatePassword.savedSuccess'.trns(),
      );
    });
  }
}