import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addTag/controllers/add_tag_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/inventory-form-widgets.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddTagView extends GetView<AddTagController> {
  const AddTagView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          InventoryFormHeader(
            title: controller.isEditMode
                ? 'addTag.editTitle'.trns()
                : 'addTag.title'.trns(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: InventoryFormCard(
                formKey: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isEditMode
                          ? 'addTag.editFormTitle'.trns()
                          : 'addTag.formTitle'.trns(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 22),
                    InventoryFieldLabel('addTag.branch'.trns()),
                    const SizedBox(height: 8),
                    InventoryBranchField(
                      controller: controller,
                      titleKey: 'addTag.branch',
                      hintKey: 'addTag.selectBranch',
                    ),
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addTag.name'.trns()),
                    const SizedBox(height: 8),
                    CommonTextInputField(
                      hintText: 'addTag.enterName'.trns(),
                      controller: controller.nameCtrl,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 28),
                    Obx(() => MainBtn(
                          text: controller.isEditMode
                              ? 'addTag.update'.trns()
                              : 'addTag.save'.trns(),
                          isLoading: controller.isSaving.value,
                          onPressed: () => controller.save(context),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
