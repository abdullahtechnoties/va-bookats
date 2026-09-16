// lib/app/modules/createBooking/views/step5.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/models/booking_model.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';
import 'package:va_bookats/widgets/common_dropdown_bottom_sheet_three.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class Step5Payment extends GetView<CreateBookingController> {
  const Step5Payment({super.key});

  void _showThree(
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
      builder: (_) => CommonDropdownBottomSheetThree(
        title: title,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.45,
        dropdownItems: items,
        selectedItem: selectedItem,
        textController: textCtrl,
        currentlySelectedValue: selectedItem.value,
        onValueSelected: (v) {
          if (title.contains('Payment')) {
            controller.onPaymentMethodSelected(v?.toString() ?? '');
          } else {
            controller.onBookingStatusSelected(v?.toString() ?? '');
          }
        },
        showSearch: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Refresh computed totals every time payment step renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.recalcPaymentTotals();
    });
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
        child: Form(
          key: controller.stepKeys[4],
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
              const SizedBox(height: 8),
              Obx(() => Text(
                    'Items total: Rs ${controller.computedGrandTotal.toStringAsFixed(2)} '
                    '(Pkg ${controller.packagesSum.toStringAsFixed(2)} + '
                    'Svc ${controller.servicesSum.toStringAsFixed(2)} + '
                    'Prd ${controller.productsSum.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  )),
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
                onChanged: (_) => controller.recalcPaymentTotals(),
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
                onChanged: (_) => controller.recalcPaymentTotals(),
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
                onChanged: (_) => controller.recalcPaymentTotals(),
              ),
              const SizedBox(height: 16),

              // Balance (auto)
              _FieldLabel('createBooking.step5.balance'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintText: '00',
                controller: controller.balanceCtrl,
                keyboardType: TextInputType.number,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
              ),
              const SizedBox(height: 16),

              // Payment Method (static)
              _FieldLabel('createBooking.step5.paymentMethod'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintText:
                    'createBooking.step5.selectPaymentMethod'.trns(),
                controller: controller.paymentMethodCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                showSuffixIcon: true,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888),
                ),
                onTap: () => _showThree(
                  context,
                  title: 'createBooking.step5.paymentMethod'.trns(),
                  items: CreateBookingController.paymentMethods,
                  selectedItem: controller.selectedPaymentMethod,
                  textCtrl: controller.paymentMethodCtrl,
                ),
              ),
              const SizedBox(height: 16),

              // Booking Status (same values as list tabs)
              _FieldLabel('createBooking.step5.bookingStatus'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintText:
                    'createBooking.step5.selectBookingStatus'.trns(),
                controller: controller.bookingStatusCtrl,
                readOnly: true,
                height: 50,
                hintTextSize: 13,
                showSuffixIcon: true,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF888888),
                ),
                onTap: () => _showThree(
                  context,
                  title: 'createBooking.step5.bookingStatus'.trns(),
                  items: BookingStatus.all,
                  selectedItem: controller.selectedBookingStatus,
                  textCtrl: controller.bookingStatusCtrl,
                ),
              ),
              const SizedBox(height: 16),

              // Payment Slip (media library → media_id)
              _FieldLabel('createBooking.step5.paymentSlip'.trns()),
              const SizedBox(height: 8),
              _PaymentSlipPicker(controller: controller),
              const SizedBox(height: 16),

              // Transaction ID
              _FieldLabel('createBooking.step5.transactionId'.trns()),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintText:
                    'createBooking.step5.transactionPlaceholder'.trns(),
                controller: controller.transactionIdCtrl,
                height: 50,
                hintTextSize: 13,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Obx(() => GestureDetector(
                          onTap: controller.isSaving.value
                              ? null
                              : controller.previousStep,
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
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => MainBtn(
                          text: controller.isEditMode
                              ? 'Update'
                              : 'createBooking.save'.trns(),
                          onPressed: controller.isSaving.value
                              ? null
                              : () => controller.submit(context),
                          isLoading: controller.isSaving.value,
                        )),
                  ),
                ],
              ),
            ],
          ),
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
    return Obx(() {
      final slip = controller.slipMedia.value;
      final url = slip?.thumbnailUrl ??
          slip?.networkUrl ??
          controller.existingSlipUrl;
      final name = slip?.name ?? controller.slipFileName.value;
      return Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E4E4)),
            ),
            clipBehavior: Clip.antiAlias,
            child: url != null
                ? AppCachedImage(imageUrl: url, fit: BoxFit.cover)
                : const Icon(
                    Icons.receipt_outlined,
                    color: Color(0xFFBBBBBB),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => controller.pickSlip(context),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  url == null ? 'Choose File' : 'Change',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
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
