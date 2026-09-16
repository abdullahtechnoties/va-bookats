// lib/app/modules/createBooking/views/step4.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/app/modules/createBooking/views/widgets/step_form_card.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step4Products extends GetView<CreateBookingController> {
  const Step4Products({super.key});

  void _showThree(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
    List<String>? values,
    Function(dynamic)? onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommonDropdownBottomSheetThree(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.55,
        dropdownItems: items,
        selectedItem: selectedItem,
        textController: textCtrl,
        selectedValue: values,
        currentlySelectedValue: selectedItem.value,
        onValueSelected: onSelected,
        showSearch: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.stepKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'createBooking.step4.addProducts'.trns(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: controller.addProduct,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.isLoadingProducts.value &&
                controller.productOptions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                ),
              );
            }
            if (controller.productItems.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: const Text(
                  'No products added (optional).\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.productItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = controller.productItems[index];
                final variantLabels = item.variantOptions
                    .map((v) =>
                        '${v.displayName} — Rs ${v.price} (Stock: ${v.stock})')
                    .toList();
                final variantValues = item.variantOptions
                    .map((v) => v.id.toString())
                    .toList();
                return StepFormCard(
                  title: 'createBooking.step4.productInfo'.trns(),
                  showDelete: true,
                  onDelete: () => controller.removeProduct(index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                          'createBooking.step4.product'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText:
                            'createBooking.step4.selectProduct'.trns(),
                        controller: item.productCtrl,
                        readOnly: true,
                        height: 50,
                        hintTextSize: 13,
                        onTap: () => _showThree(
                          context,
                          title: 'createBooking.step4.product'
                              .trns(),
                          items: controller.productLabels,
                          selectedItem: item.selectedProductId,
                          textCtrl: item.productCtrl,
                          values: controller.productValues,
                          onSelected: (v) =>
                              controller.onProductSelected(item, v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (item.variantOptions.isNotEmpty) ...[
                        _FieldLabel('createBooking.step4.variation'
                            .trns()),
                        const SizedBox(height: 8),
                        CommonTextInputField(
                          hintText:
                              'createBooking.step4.selectVariation'
                                  .trns(),
                          controller: item.variantCtrl,
                          readOnly: true,
                          height: 50,
                          hintTextSize: 13,
                          onTap: () => _showThree(
                            context,
                            title: 'createBooking.step4.variation'
                                .trns(),
                            items: variantLabels,
                            selectedItem: item.selectedVariantId,
                            textCtrl: item.variantCtrl,
                            values: variantValues,
                            onSelected: (v) => controller
                                .onVariantSelected(item, v),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available stock: ${item.availableStock.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _FieldLabel(
                          'createBooking.step4.quantity'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: '1',
                        controller: item.quantityCtrl,
                        keyboardType: TextInputType.number,
                        height: 50,
                        hintTextSize: 13,
                        onChanged: (_) => controller.onProductQtyChanged(
                            item, ''),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step4.unitPrice'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: '00',
                        controller: item.unitPriceCtrl,
                        keyboardType: TextInputType.number,
                        height: 50,
                        hintTextSize: 13,
                        onChanged: (_) => controller.onProductQtyChanged(
                            item, ''),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step4.total'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: '00',
                        controller: item.totalCtrl,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        height: 50,
                        hintTextSize: 13,
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                          'createBooking.step4.discount'.trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: '00',
                        controller: item.discountCtrl,
                        keyboardType: TextInputType.number,
                        height: 50,
                        hintTextSize: 13,
                        onChanged: (_) => controller
                            .onProductDiscountChanged(item, ''),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('createBooking.step4.totalAfterDiscount'
                          .trns()),
                      const SizedBox(height: 8),
                      CommonTextInputField(
                        hintText: '00',
                        controller: item.afterDiscountCtrl,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        height: 50,
                        hintTextSize: 13,
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.previousStep,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: MainBtn(
                  text: 'createBooking.next'.trns(),
                  onPressed: controller.nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
