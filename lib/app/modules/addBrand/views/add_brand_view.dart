import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addBrand/controllers/add_brand_controller.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/inventory-form-widgets.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddBrandView extends GetView<AddBrandController> {
  const AddBrandView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          InventoryFormHeader(
            title: controller.isEditMode
                ? 'addBrand.editTitle'.trns()
                : 'addBrand.title'.trns(),
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
                          ? 'addBrand.editFormTitle'.trns()
                          : 'addBrand.formTitle'.trns(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    if(controller.auth.isOwner) ...[
                    const SizedBox(height: 22),
                     InventoryFieldLabel('addBrand.branch'.trns()),
                    ],
                    const SizedBox(height: 8),
                    InventoryBranchField(
                      controller: controller,
                      titleKey: 'addBrand.branch',
                      hintKey: 'addBrand.selectBranch',
                    ),
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addBrand.name'.trns()),
                    const SizedBox(height: 8),
                    CommonTextInputField(
                      hintText: 'addBrand.enterName'.trns(),
                      controller: controller.nameCtrl,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addBrand.logo'.trns()),
                    const SizedBox(height: 8),
                    InventoryImageField(
                      controller: controller,
                      chooseKey: 'addBrand.chooseLogo',
                      changeKey: 'addBrand.changeLogo',
                    ),
                    const SizedBox(height: 28),
                    Can(
                      controller.isEditMode ? AppPerm.update(AppPerm.brands) : AppPerm.store(AppPerm.brands),
                      child: Obx(() => MainBtn(
                            text: controller.isEditMode
                                ? 'addBrand.update'.trns()
                                : 'addBrand.save'.trns(),
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
