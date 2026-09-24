// lib/widgets/Global-Widgets/add-service-category.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addServiceCategory/controllers/add_service_category_controller.dart';
import 'package:va_bookats/app/modules/serviceCategories/repositories/service_category_repository.dart';
import 'package:va_bookats/models/service_category_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddServiceCategoryDialog extends StatefulWidget {
  final int? branchId;

  /// Invoked with the category created through the API, so the caller can
  /// refresh its dropdown and select the new entry.
  final ValueChanged<ServiceCategoryModel>? onCategoryCreated;

  const AddServiceCategoryDialog({
    super.key,
    this.branchId,
    this.onCategoryCreated,
  });

  @override
  State<AddServiceCategoryDialog> createState() =>
      _AddServiceCategoryDialogState();
}

class _AddServiceCategoryDialogState extends State<AddServiceCategoryDialog> {
  static const _controllerTag = 'addServiceCategoryDialog';

  late final AddServiceCategoryController _controller;

  @override
  void initState() {
    super.initState();
    final repository = Get.isRegistered<ServiceCategoryRepository>()
        ? Get.find<ServiceCategoryRepository>()
        : Get.put(ServiceCategoryRepository());
    _controller = Get.put(
      AddServiceCategoryController(
        repository: repository,
        initialBranchId: widget.branchId,
      ),
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
