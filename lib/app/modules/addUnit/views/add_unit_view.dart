import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addUnit/controllers/add_unit_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/inventory-form-widgets.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddUnitView extends GetView<AddUnitController> {
  const AddUnitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          InventoryFormHeader(
            title: controller.isEditMode
                ? 'addUnit.editTitle'.trns()
                : 'addUnit.title'.trns(),
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
                          ? 'addUnit.editFormTitle'.trns()
                          : 'addUnit.formTitle'.trns(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (controller.showBranch) ...[
                    InventoryFieldLabel('addUnit.branch'.trns()),
                    const SizedBox(height: 8),
                    InventoryBranchField(
                      controller: controller,
                      titleKey: 'addUnit.branch',
                      hintKey: 'addUnit.selectBranch',
                    ),
                    ],
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addUnit.name'.trns()),
                    const SizedBox(height: 8),
                    CommonTextInputField(
                      hintText: 'addUnit.enterName'.trns(),
                      controller: controller.nameCtrl,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 28),
                    Can(
                      controller.isEditMode
                          ? AppPerm.update(AppPerm.units)
                          : AppPerm.store(AppPerm.units),
                      child: Obx(() => MainBtn(
                            text: controller.isEditMode
                                ? 'addUnit.update'.trns()
                                : 'addUnit.save'.trns(),
                            isLoading: controller.isSaving.value,
                            onPressed: () => controller.save(context),
                          )),
                    ),
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
