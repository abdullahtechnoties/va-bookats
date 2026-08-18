// lib/app/modules/login/controllers/login_controller.dart

import 'package:va_bookats/app/modules/login/repositories/login_repository.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class LoginController extends GetxController {
  LoginController({required LoginRepository repository})
      : _repository = repository;

  final LoginRepository _repository;
  final AuthService _authService = Get.find<AuthService>();

  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;

  

  @override
  void onInit() {
    super.onInit();
    // Pre-fill a previously saved company id if one exists.
    final savedCompanyId = _authService.companyId.value;
    if (savedCompanyId != null && savedCompanyId.isNotEmpty) {
      companyIdController.text = savedCompanyId;
    }
  }

  @override
  void onClose() {
    loginController.dispose();
    passwordController.dispose();
    companyIdController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await _repository.login(
        login: loginController.text.trim(),
        password: passwordController.text,
        companyId: companyIdController.text.trim(),
      );

      if (!response.isCompleted || response.data == null) {
        SnackbarService.showError(
          title: 'auth.login.errorTitle'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
        return;
      }

      final data = response.data!;

      // Persist credentials reactively.
      final token = data.token;
      if (token != null && token.isNotEmpty) {
        await _authService.setAccessToken(token);
      }
      if (data.user != null) {
        await _authService.setCurrentUser(data.user);
      }
      final companyId = data.companyId ?? companyIdController.text.trim();
      if (companyId.isNotEmpty) {
        await _authService.setCompanyId(companyId);
      }
      await AuthService.setAuthenticated(true);

      SnackbarService.showSuccess(
        title: 'auth.login.successTitle'.trns(),
        message: 'auth.login.successMessage'.trns(),
      );

      Get.offAllNamed(Routes.BOTTOMNAV);
    } catch (_) {
      SnackbarService.showError(
        title: 'auth.login.errorTitle'.trns(),
        message: 'errors.unexpected'.trns(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void continueWithGoogle() {
    SnackbarService.showSuccess(
      title: 'auth.login.googleTitle'.trns(),
      message: 'auth.login.googleMessage'.trns(),
    );
  }

  void goToSignup() {
    Get.toNamed('/signup');
  }

  void goToForgotPassword() {
    // Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  /// Accepts either an email address or a phone number.
  String? validateLogin(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'auth.validation.loginRequired'.trns();
    }
    final isEmail = GetUtils.isEmail(trimmed);
    final isPhone = GetUtils.isPhoneNumber(trimmed);
    if (!isEmail && !isPhone) {
      return 'auth.validation.loginInvalid'.trns();
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.validation.passwordRequired'.trns();
    }
    if (value.length < 6) {
      return 'auth.validation.passwordMinLength'.trns();
    }
    return null;
  }

  String? validateCompanyId(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'auth.validation.companyIdRequired'.trns();
    }
    return null;
  }
}
