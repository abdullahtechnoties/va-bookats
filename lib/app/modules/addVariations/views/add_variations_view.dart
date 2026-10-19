import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addVariations/controllers/add_variations_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/inventory-form-widgets.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddVariationsView extends GetView<AddVariationsController> {
  const AddVariationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          InventoryFormHeader(
            title: controller.isEditMode
                ? 'addVariations.editTitle'.trns()
                : 'addVariations.title'.trns(),
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
                          ? 'addVariations.editFormTitle'.trns()
                          : 'addVariations.formTitle'.trns(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 22),
                    InventoryFieldLabel('addVariations.branch'.trns()),
                    const SizedBox(height: 8),
                    InventoryBranchField(
                      controller: controller,
                      titleKey: 'addVariations.branch',
                      hintKey: 'addVariations.selectBranch',
                    ),
                    const SizedBox(height: 20),
                    InventoryFieldLabel('addVariations.name'.trns()),
                    const SizedBox(height: 8),
                    CommonTextInputField(
                      hintText: 'addVariations.enterName'.trns(),
                      controller: controller.nameCtrl,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'addVariations.values'.trns(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.addValueRow,
                          child: Text(
                            'addVariations.addValue'.trns(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        children: controller.valueCtrls
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final ctrl = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CommonTextInputField(
                                    hintText:
                                        '${'addVariations.enterValue'.trns()} ${i + 1}',
                                    controller: ctrl,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      controller.removeValueRow(i),
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xFFC62828),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Obx(() => MainBtn(
                          text: controller.isEditMode
                              ? 'addVariations.update'.trns()
                              : 'addVariations.save'.trns(),
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
