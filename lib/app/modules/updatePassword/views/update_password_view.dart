import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/updatePassword/controllers/update_password_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({super.key});

  String _t(String key, String fallback) {
    final v = key.trns();
    return v == key ? fallback : v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _UpdatePasswordHeader(
            title: _t('changePassword.title', 'Change Password'),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('changePassword.formTitle', 'Update Your Password'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Current Password
                      _FieldLabel(_t('changePassword.currentPassword', 'Current Password')),
                      const SizedBox(height: 8),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTextInputField(
                              hintTextColor: AppColors.grey,
                              hintText: _t('changePassword.enterCurrent', 'Enter current password'),
                              controller: controller.currentPasswordController,
                              height: 52,
                              hintTextSize: 13,
                              obscureText: !controller.currentPasswordVisible.value,
                              showSuffixIcon: true,
                              suffixIcon: GestureDetector(
                                onTap: controller.toggleCurrentPasswordVisibility,
                                child: Icon(
                                  controller.currentPasswordVisible.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (controller.currentPasswordError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  controller.currentPasswordError.value,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // New Password
                      _FieldLabel(_t('changePassword.newPassword', 'New Password')),
                      const SizedBox(height: 8),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTextInputField(
                              hintTextColor: AppColors.grey,
                              hintText: _t('changePassword.enterNew', 'Enter new password'),
                              controller: controller.newPasswordController,
                              height: 52,
                              hintTextSize: 13,
                              obscureText: !controller.newPasswordVisible.value,
                              showSuffixIcon: true,
                              suffixIcon: GestureDetector(
                                onTap: controller.toggleNewPasswordVisibility,
                                child: Icon(
                                  controller.newPasswordVisible.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (controller.newPasswordError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  controller.newPasswordError.value,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Confirm New Password
                      _FieldLabel(_t('changePassword.confirmPassword', 'Confirm Password')),
                      const SizedBox(height: 8),
                      Obx(
                        () => CommonTextInputField(
                          hintTextColor: AppColors.grey,
                          hintText: _t('changePassword.enterConfirm', 'Confirm new password'),
                          controller: controller.confirmPasswordController,
                          height: 52,
                          hintTextSize: 13,
                          obscureText: !controller.confirmPasswordVisible.value,
                          showSuffixIcon: true,
                          suffixIcon: GestureDetector(
                            onTap: controller.toggleConfirmPasswordVisibility,
                            child: Icon(
                              controller.confirmPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      Obx(
                        () => MainBtn(
                          text: _t('changePassword.updateBtn', 'Update Password'),
                          onPressed: controller.isLoading.value ? null : controller.updatePassword,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _UpdatePasswordHeader extends StatelessWidget {
  final String title;

  const _UpdatePasswordHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }
}
