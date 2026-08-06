// lib/app/modules/create_booking/steps/step5_payment.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step5Payment extends StatelessWidget {
  const Step5Payment({super.key});

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
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'createBooking.step5.paymentInfo'.trns(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Total Amount
            _FieldLabel('createBooking.step5.totalAmount'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: '00',
              controller: controller.totalAmountCtrl,
              keyboardType: TextInputType.number,
              height: 50,
              hintTextSize: 13,
            ),
            const SizedBox(height: 16),

            // Discount
            _FieldLabel('createBooking.step5.discount'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: '00',
              controller: controller.discountCtrl,
              keyboardType: TextInputType.number,
              height: 50,
              hintTextSize: 13,
            ),
            const SizedBox(height: 16),

            // Balance
            _FieldLabel('createBooking.step5.balance'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: '00',
              controller: controller.balanceCtrl,
              keyboardType: TextInputType.number,
              height: 50,
              hintTextSize: 13,
            ),
            const SizedBox(height: 16),

            // Amount Paid
            _FieldLabel('createBooking.step5.amountPaid'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: '00',
              controller: controller.amountPaidCtrl,
              keyboardType: TextInputType.number,
              height: 50,
              hintTextSize: 13,
            ),
            const SizedBox(height: 16),

            // Payment Method
            _FieldLabel('createBooking.step5.paymentMethod'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'createBooking.step5.selectPaymentMethod'.trns(),
              controller: controller.paymentMethodCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () => _showDropdown(
                context,
                title: 'createBooking.step5.paymentMethod'.trns(),
                items: controller.paymentMethods,
                selectedItem: controller.selectedPaymentMethod,
                textCtrl: controller.paymentMethodCtrl,
              ),
            ),
            const SizedBox(height: 16),

            // Booking Status
            _FieldLabel('createBooking.step5.bookingStatus'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'createBooking.step5.selectBookingStatus'.trns(),
              controller: controller.bookingStatusCtrl,
              readOnly: true,
              height: 50,
              hintTextSize: 13,
              onTap: () => _showDropdown(
                context,
                title: 'createBooking.step5.bookingStatus'.trns(),
                items: controller.bookingStatuses,
                selectedItem: controller.selectedBookingStatus,
                textCtrl: controller.bookingStatusCtrl,
              ),
            ),
            const SizedBox(height: 16),

            // Payment Slip
            _FieldLabel('createBooking.step5.paymentSlip'.trns()),
            const SizedBox(height: 8),
            _PaymentSlipPicker(controller: controller),
            const SizedBox(height: 16),

            // Transaction ID
            _FieldLabel('createBooking.step5.transactionId'.trns()),
            const SizedBox(height: 8),
            CommonTextInputField(
              hintText: 'createBooking.step5.transactionPlaceholder'.trns(),
              controller: controller.transactionIdCtrl,
              height: 50,
              hintTextSize: 13,
            ),
            const SizedBox(height: 24),

            MainBtn(
              text: 'createBooking.save'.trns(),
              onPressed: controller.saveBooking,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSlipPicker extends StatelessWidget {
  final CreateBookingController controller;

  const _PaymentSlipPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: controller.pickPaymentSlip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'createBooking.step5.chooseFile'.trns(),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
                  controller.paymentSlipFileName.value,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.paymentSlipFileName.value ==
                            'No File Chosen'
                        ? const Color(0xFFAAAAAA)
                        : AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
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