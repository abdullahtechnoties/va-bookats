import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/personalInfo/controllers/personal_info_controller.dart';

import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class PersonalInfoView extends GetView<PersonalInfoController> {
  const PersonalInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
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
              // ── Section heading ─────────────────────────────────────────
              Text(
                'personalInfo.profileInformation'.trns(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'personalInfo.profileSubtitle'.trns(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              // ── Name ────────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.name'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'personalInfo.enterName'.trns(),
                controller: controller.nameController,
              ),
              const SizedBox(height: 14),

              // ── Email Primary ───────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.emailPrimary'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'demo@demo.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // ── Customer ────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.customer'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'demo@demo.com',
                controller: controller.customerController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // ── Phone Primary ───────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.phonePrimary'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: '1234567890',
                controller: controller.phonePrimaryController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // ── Phone Secondary ─────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.phoneSecondary'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: '1234567890',
                controller: controller.phoneSecondaryController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // ── Image / File Picker ─────────────────────────────────────
              _FieldLabel(label: 'personalInfo.image'.trns()),
              _ImagePickerField(controller: controller),
              const SizedBox(height: 14),

              // ── Date of Birth ───────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.dateOfBirth'.trns()),
              GestureDetector(
                onTap: () => controller.pickDate(context),
                child: 
                // Obx(() => 
                AbsorbPointer(
                      child: CommonTextInputField(
                hintTextColor: AppColors.grey,
                        hintText: 'mm/dd/yyyy',
                        controller: controller.dobController,
                        readOnly: true,
                      ),
                    )
                    // ),
              ),
              const SizedBox(height: 14),

              // ── Qualification ───────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.qualification'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'personalInfo.qualificationHint'.trns(),
                controller: controller.qualificationController,
              ),
              const SizedBox(height: 14),

              // ── Country ─────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.country'.trns()),
              Obx(() => _DropdownField(
                    value: controller.selectedCountry.value,
                    onTap: () => _showPicker(
                      context,
                      title: 'personalInfo.country'.trns(),
                      items: controller.countries,
                      selected: controller.selectedCountry,
                    ),
                  )),
              const SizedBox(height: 14),

              // ── City ────────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.city'.trns()),
              Obx(() => _DropdownField(
                    value: controller.selectedCity.value,
                    onTap: () => _showPicker(
                      context,
                      title: 'personalInfo.city'.trns(),
                      items: controller.cities,
                      selected: controller.selectedCity,
                    ),
                  )),
              const SizedBox(height: 14),

              // ── State ───────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.state'.trns()),
              Obx(() => _DropdownField(
                    value: controller.selectedState.value,
                    onTap: () => _showPicker(
                      context,
                      title: 'personalInfo.state'.trns(),
                      items: controller.states,
                      selected: controller.selectedState,
                    ),
                  )),
              const SizedBox(height: 14),

              // ── Zip Code ────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.zipCode'.trns()),
              CommonTextInputField(
                hintText: '127865',
                hintTextColor: AppColors.grey,
                controller: controller.zipController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              // ── Address ─────────────────────────────────────────────────
              _FieldLabel(label: 'personalInfo.address'.trns()),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'personalInfo.addressHint'.trns(),
                controller: controller.addressController,
                maxLines: 4,
                height: 100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              const SizedBox(height: 24),

              // ── Save Button ─────────────────────────────────────────────
              Obx(() => MainBtn(
                    text: 'personalInfo.save'.trns(),
                    isLoading: controller.isLoading.value,
                    onPressed: controller.save,
                  )),
            ],
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
        'personalInfo.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SimplePickerSheet(
        title: title,
        items: items,
        selected: selected,
      ),
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
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }
}

// ── Dropdown display field ────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DropdownField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.black.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Image Picker Field ────────────────────────────────────────────────────────
class _ImagePickerField extends StatelessWidget {
  final PersonalInfoController controller;

  const _ImagePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          // Choose File button
          GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'personalInfo.chooseFile'.trns(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // File name
          Expanded(
            child: Obx(() => Text(
                  controller.pickedFileName.value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Simple Picker Bottom Sheet ────────────────────────────────────────────────
class _SimplePickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final RxString selected;

  const _SimplePickerSheet({
    required this.title,
    required this.items,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Obx(() => ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected.value == item
                        ? AppColors.primary
                        : AppColors.black,
                    fontWeight: selected.value == item
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: selected.value == item
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  selected.value = item;
                  Get.back();
                },
              ))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}