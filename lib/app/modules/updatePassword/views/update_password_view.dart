import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/updatePassword/controllers/update_password_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class UpdatePasswordView extends GetView<UpdatePasswordController> {
  const UpdatePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Form(
          key: controller.formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Heading ───────────────────────────────────────────────
                Text(
                  'updatePassword.title'.trns(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'updatePassword.subtitle'.trns(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Current Password ──────────────────────────────────────
                _FieldLabel(label: 'updatePassword.currentPassword'.trns()),
                Obx(
                  () => CommonTextInputField(
                    hintTextColor: AppColors.grey,
                    hintText: 'updatePassword.enterCurrentPassword'.trns(),
                    controller: controller.currentPasswordController,
                    obscureText: !controller.showCurrent.value,
                    showSuffixIcon: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showCurrent.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => controller.showCurrent.toggle(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'updatePassword.currentRequired'.trns();
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── New Password ──────────────────────────────────────────
                _FieldLabel(label: 'updatePassword.newPassword'.trns()),
                Obx(
                  () => CommonTextInputField(
                    hintTextColor: AppColors.grey,
                    hintText: 'updatePassword.enterNewPassword'.trns(),
                    controller: controller.newPasswordController,
                    obscureText: !controller.showNew.value,
                    showSuffixIcon: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showNew.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => controller.showNew.toggle(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'updatePassword.newRequired'.trns();
                      }
                      if (v.length < 8) {
                        return 'updatePassword.minLength'.trns();
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ──────────────────────────────────────
                _FieldLabel(label: 'updatePassword.confirmPassword'.trns()),
                Obx(
                  () => CommonTextInputField(
                    hintTextColor: AppColors.grey,
                    hintText: 'updatePassword.confirmPasswordHint'.trns(),
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.showConfirm.value,
                    showSuffixIcon: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showConfirm.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () => controller.showConfirm.toggle(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'updatePassword.confirmRequired'.trns();
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // ── Save Button ───────────────────────────────────────────
                Obx(
                  () => MainBtn(
                    text: 'updatePassword.save'.trns(),
                    isLoading: controller.isLoading.value,
                    onPressed: controller.save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
      title: Text(
        'updatePassword.appBarTitle'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Field Label ────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    );
  }
}
