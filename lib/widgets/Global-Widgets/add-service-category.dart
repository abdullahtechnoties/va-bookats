// lib/widgets/Global-Widgets/add-service-category.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addServiceCategory/controllers/add_service_category_controller.dart';
import 'package:va_bookats/app/modules/serviceCategories/repositories/service_category_repository.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddServiceCategoryDialog extends StatefulWidget {
  /// Invoked with the category created through the API, so the caller can
  /// refresh its dropdown and select the new entry.
  final ValueChanged<ServiceCategoryModel>? onCategoryCreated;

  const AddServiceCategoryDialog({super.key, this.onCategoryCreated});

  @override
  State<AddServiceCategoryDialog> createState() =>
      _AddServiceCategoryDialogState();
}

class _AddServiceCategoryDialogState extends State<AddServiceCategoryDialog> {
  static const _controllerTag = 'addServiceCategoryDialog';

  late final AddServiceCategoryController _controller;

  void _showBranchDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheet(
        title: 'addServiceCategory.branch'.trns(),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
        dropdownItems: _controller.branchLabels,
        selectedValue: _controller.branchValues,
        selectedItem: _controller.selectedBranch,
        textController: _controller.branchCtrl,
        currentlySelectedValue: _controller.selectedBranch.value,
        onValueSelected: _controller.onBranchSelected,
        showSearch: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final repository = Get.isRegistered<ServiceCategoryRepository>()
        ? Get.find<ServiceCategoryRepository>()
        : Get.put(ServiceCategoryRepository());
    _controller = Get.put(
      AddServiceCategoryController(repository: repository),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<AddServiceCategoryController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'addServiceCategory.dialogTitle'.trns(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 22),

              // Branch — only for owner role
              Obx(
                () => _controller.showBranch
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'addServiceCategory.branch'.trns(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => CommonTextInputField(
                              hintText: 'addServiceCategory.selectBranch'
                                  .trns(),
                              controller: _controller.branchCtrl,
                              readOnly: true,
                              height: 52,
                              hintTextSize: 13,
                              showSuffixIcon: true,
                              suffixIcon: _controller.isLoadingBranches.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              validator: _controller.validateBranch,
                              onTap: _controller.isLoadingBranches.value
                                  ? null
                                  : () => _showBranchDropdown(context),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              // Name
              Text(
                'addServiceCategory.name'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'addServiceCategory.enterFullName'.trns(),
                controller: _controller.nameCtrl,
                height: 52,
                hintTextSize: 13,
                validator: _controller.validateName,
              ),
              const SizedBox(height: 24),

              Obx(
                () => MainBtn(
                  text: 'addServiceCategory.save'.trns(),
                  onPressed: _controller.isSaving.value
                      ? null
                      : () => _controller.save(
                          context,
                          onSuccess: widget.onCategoryCreated,
                        ),
                  isLoading: _controller.isSaving.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
