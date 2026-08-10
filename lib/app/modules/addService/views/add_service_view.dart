// lib/app/modules/add_service/views/add_service_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addService/controllers/add_service_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/add-service-category.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddServiceView extends GetView<AddServiceController> {
  const AddServiceView({super.key});

  void _showDropdown(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownItems: items,
        selectedItem: selectedItem,
        textController: textCtrl,
        currentlySelectedValue: selectedItem.value,
        showSearch: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _AddServiceHeader(),

          // ── Form ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 1,
                  ),
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
                      // Form Title
                      Text(
                        'addService.formTitle'.trns(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Branch
                      _FieldLabel('addService.branch'.trns()),
                      const SizedBox(height: 8),
                      Obx(
                        () => CommonTextInputField(
                          hintText: 'addService.selectBranch'.trns(),
                          controller: controller.branchCtrl,
                          readOnly: true,
                          height: 50,
                          hintTextSize: 13,
                          onTap: () => _showDropdown(
                            context,
                            title: 'addService.branch'.trns(),
                            items: controller.branches,
                            selectedItem: controller.selectedBranch,
                            textCtrl: controller.branchCtrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Categories + Add Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FieldLabel('addService.categories'.trns()),
                          GestureDetector(
                            onTap: () => Get.dialog(
                              const AddServiceCategoryDialog(),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.white,
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'addService.addCategory'.trns(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => CommonTextInputField(
                          hintText: 'addService.selectCategories'.trns(),
                          controller: controller.categoryCtrl,
                          readOnly: true,
                          height: 50,
                          hintTextSize: 13,
                          onTap: () => _showDropdown(
                            context,
                            title: 'addService.categories'.trns(),
                            items: controller.categories,
                            selectedItem: controller.selectedCategory,
                            textCtrl: controller.categoryCtrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Name
                      _FieldLabel('addService.name'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: 'addService.enterFullName'.trns(),
                        controller: controller.nameCtrl,
                        height: 50,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Add An Image
                      _FieldLabel('addService.addAnImage'.trns()),
                      const SizedBox(height: 8),
                      _ImagePickerField(controller: controller),
                      const SizedBox(height: 18),

                      // Service Duration
                      _FieldLabel('addService.serviceDuration'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: 'addService.durationPlaceholder'.trns(),
                        controller: controller.durationCtrl,
                        keyboardType: TextInputType.number,
                        height: 50,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 18),

                      // Status
                      _FieldLabel('addService.status'.trns()),
                      const SizedBox(height: 8),
                      Obx(
                        () => CommonTextInputField(
                          hintText: 'addService.selectStatus'.trns(),
                          controller: controller.statusCtrl,
                          readOnly: true,
                          height: 50,
                          hintTextSize: 13,
                          onTap: () => _showDropdown(
                            context,
                            title: 'addService.status'.trns(),
                            items: controller.statusOptions,
                            selectedItem: controller.selectedStatus,
                            textCtrl: controller.statusCtrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Type
                      _FieldLabel('addService.type'.trns()),
                      const SizedBox(height: 8),
                      Obx(
                        () => CommonTextInputField(
                          hintText: 'addService.selectType'.trns(),
                          controller: controller.typeCtrl,
                          readOnly: true,
                          height: 50,
                          hintTextSize: 13,
                          onTap: () => _showDropdown(
                            context,
                            title: 'addService.type'.trns(),
                            items: controller.typeOptions,
                            selectedItem: controller.selectedType,
                            textCtrl: controller.typeCtrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description
                      _FieldLabel('addService.description'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: 'addService.writeSomething'.trns(),
                        controller: controller.descriptionCtrl,
                        maxLines: 4,
                        height: 110,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 26),

                      // Save Button
                      MainBtn(
                        text: 'addService.save'.trns(),
                        onPressed: controller.save,
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

class _AddServiceHeader extends StatelessWidget {
  const _AddServiceHeader();

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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
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
                  'addService.title'.trns(),
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

// ─── Image Picker Field ───────────────────────────────────────────────────────

class _ImagePickerField extends StatelessWidget {
  final AddServiceController controller;

  const _ImagePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Obx(
                () => Text(
                  controller.imageFileName.value,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.imageFileName.value == 'No File Chosen'
                        ? const Color(0xFFAAAAAA)
                        : AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'addService.chooseFile'.trns(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
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