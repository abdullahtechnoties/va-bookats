// lib/app/modules/add_service_category/views/add_service_category_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addServiceCategory/controllers/add_service_category_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddServiceCategoryView extends GetView<AddServiceCategoryController> {
  const AddServiceCategoryView({super.key});

  void _showBranchDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: 'addServiceCategory.branch'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
        dropdownItems: controller.branches,
        selectedItem: controller.selectedBranch,
        textController: controller.branchCtrl,
        currentlySelectedValue: controller.selectedBranch.value,
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
          // ── Header ──────────────────────────────────────────────────────
          _AddServiceCategoryHeader(),

          // ── Form ────────────────────────────────────────────────────────
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
                        'addServiceCategory.formTitle'.trns(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Branch
                      _FieldLabel('addServiceCategory.branch'.trns()),
                      const SizedBox(height: 8),
                      Obx(
                        () => CommonTextInputField(
                          hintText: 'addServiceCategory.selectBranch'.trns(),
                          controller: controller.branchCtrl,
                          readOnly: true,
                          height: 52,
                          hintTextSize: 13,
                          onTap: () => _showBranchDropdown(context),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      _FieldLabel('addServiceCategory.name'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: 'addServiceCategory.enterFullName'.trns(),
                        controller: controller.nameCtrl,
                        height: 52,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 28),

                      // Save Button
                      MainBtn(
                        text: 'addServiceCategory.save'.trns(),
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

class _AddServiceCategoryHeader extends StatelessWidget {
  const _AddServiceCategoryHeader();

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
                  'addServiceCategory.pageTitle'.trns(),
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