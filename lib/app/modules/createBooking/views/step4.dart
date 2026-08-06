// lib/app/modules/create_booking/steps/step4_products.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/app/modules/createBooking/views/widgets/step_form_card.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step4Products extends StatelessWidget {
  const Step4Products({super.key});

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
    final controller = Get.find<CreateBookingController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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

        // Product Items
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.productItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = controller.productItems[index];
              return _ProductCard(
                index: index,
                item: item,
                controller: controller,
                onDropdown: _showDropdown,
                buildContext: context,
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        MainBtn(
          text: 'createBooking.next'.trns(),
          onPressed: controller.nextStep,
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;
  final ProductItem item;
  final CreateBookingController controller;
  final BuildContext buildContext;
  final void Function(
    BuildContext context, {
    required String title,
    required List<String> items,
    required RxString selectedItem,
    required TextEditingController textCtrl,
  }) onDropdown;

  const _ProductCard({
    required this.index,
    required this.item,
    required this.controller,
    required this.onDropdown,
    required this.buildContext,
  });

  @override
  Widget build(BuildContext context) {
    return StepFormCard(
      title: 'createBooking.step4.productInfo'.trns(),
      showDelete: true,
      onDelete: () => controller.removeProduct(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product
          _FieldLabel('createBooking.step4.product'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: 'createBooking.step4.selectProduct'.trns(),
            controller: item.productCtrl,
            readOnly: true,
            height: 50,
            hintTextSize: 13,
            onTap: () => onDropdown(
              buildContext,
              title: 'createBooking.step4.product'.trns(),
              items: controller.productOptions,
              selectedItem: item.selectedProduct,
              textCtrl: item.productCtrl,
            ),
          ),
          const SizedBox(height: 16),

          // Variation
          _FieldLabel('createBooking.step4.variation'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: 'createBooking.step4.selectVariation'.trns(),
            controller: item.variationCtrl,
            readOnly: true,
            height: 50,
            hintTextSize: 13,
            onTap: () => onDropdown(
              buildContext,
              title: 'createBooking.step4.variation'.trns(),
              items: controller.variationOptions,
              selectedItem: item.selectedVariation,
              textCtrl: item.variationCtrl,
            ),
          ),
          const SizedBox(height: 16),

          // Stock
          _FieldLabel('createBooking.step4.stock'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: 'createBooking.step4.selectStock'.trns(),
            controller: item.stockCtrl,
            readOnly: true,
            height: 50,
            hintTextSize: 13,
            onTap: () => onDropdown(
              buildContext,
              title: 'createBooking.step4.stock'.trns(),
              items: controller.stockOptions,
              selectedItem: item.selectedStock,
              textCtrl: item.stockCtrl,
            ),
          ),
          const SizedBox(height: 16),

          // Quantity
          _FieldLabel('createBooking.step4.quantity'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: 'createBooking.step4.quantity'.trns(),
            controller: item.quantityCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
          const SizedBox(height: 16),

          // Unit Price
          _FieldLabel('createBooking.step4.unitPrice'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: 'createBooking.step4.unitPrice'.trns(),
            controller: item.unitPriceCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
          const SizedBox(height: 16),

          // Total
          _FieldLabel('createBooking.step4.total'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: '00',
            controller: item.totalCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
          const SizedBox(height: 16),

          // Discount
          _FieldLabel('createBooking.step4.discount'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: '00',
            controller: item.discountCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
          ),
          const SizedBox(height: 16),

          // Total After Discount
          _FieldLabel('createBooking.step4.totalAfterDiscount'.trns()),
          const SizedBox(height: 8),
          CommonTextInputField(
            hintText: '00',
            controller: item.totalAfterDiscountCtrl,
            keyboardType: TextInputType.number,
            height: 50,
            hintTextSize: 13,
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