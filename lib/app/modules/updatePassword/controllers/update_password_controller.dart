// lib/app/modules/updatePassword/controllers/update_password_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/personalInfo/repositories/profile_repository.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class UpdatePasswordController extends GetxController {
  UpdatePasswordController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool currentPasswordVisible = false.obs;
  final RxBool newPasswordVisible = false.obs;
  final RxBool confirmPasswordVisible = false.obs;

  final RxBool isLoading = false.obs;

  // Field-level error messages
  final RxString currentPasswordError = ''.obs;
  final RxString newPasswordError = ''.obs;

  void toggleCurrentPasswordVisibility() {
    currentPasswordVisible.value = !currentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    newPasswordVisible.value = !newPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  void _clearErrors() {
    currentPasswordError.value = '';
    newPasswordError.value = '';
  }

  Future<void> updatePassword() async {
    _clearErrors();

    if (currentPasswordController.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'changePassword.validation.currentRequired'.trns() ==
                'changePassword.validation.currentRequired'
            ? 'Please enter your current password'
            : 'changePassword.validation.currentRequired'.trns(),
      );
      return;
    }
    if (newPasswordController.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'changePassword.validation.newRequired'.trns() ==
                'changePassword.validation.newRequired'
            ? 'Please enter your new password'
            : 'changePassword.validation.newRequired'.trns(),
      );
      return;
    }
    if (confirmPasswordController.text.trim().isEmpty) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'changePassword.validation.confirmRequired'.trns() ==
                'changePassword.validation.confirmRequired'
            ? 'Please confirm your new password'
            : 'changePassword.validation.confirmRequired'.trns(),
      );
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'changePassword.validation.mismatch'.trns() ==
                'changePassword.validation.mismatch'
            ? 'Passwords do not match'
            : 'changePassword.validation.mismatch'.trns(),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _repository.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (response.isCompleted) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        _showSuccessDialog(
          response.message ?? 'Password updated successfully.',
        );
      } else {
        // Handle field-level validation errors from API
        if (response.errors != null && response.errors!.isNotEmpty) {
          final errs = response.errors!;
          if (errs.containsKey('current_password')) {
            currentPasswordError.value =
                (errs['current_password'] as List).first.toString();
          }
          if (errs.containsKey('password')) {
            newPasswordError.value = (errs['password'] as List).first.toString();
          }
        }
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FC642).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF8FC642),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Success',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.back(); // pop screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}