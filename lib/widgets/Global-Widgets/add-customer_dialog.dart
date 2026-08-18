// lib/app/modules/create_booking/widgets/add_customer_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class AddCustomerDialog extends StatelessWidget {
  const AddCustomerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateBookingController>();

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'createBooking.addCustomer.title'.trns(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 22),

              // Full Name
              Text(
                'createBooking.addCustomer.fullName'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'createBooking.addCustomer.enterFullName'.trns(),
                controller: controller.addCustomerNameCtrl,
                height: 52,
                hintTextSize: 13,
              ),
              const SizedBox(height: 16),

              // Phone Number
              Text(
                'createBooking.addCustomer.phoneNumber'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'createBooking.addCustomer.enterPhone'.trns(),
                controller: controller.addCustomerPhoneCtrl,
                keyboardType: TextInputType.phone,
                height: 52,
                hintTextSize: 13,
              ),
              const SizedBox(height: 16),

              // Email Address
              Text(
                'createBooking.addCustomer.emailAddress'.trns(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextInputField(
                hintTextColor: AppColors.grey,
                hintText: 'createBooking.addCustomer.enterEmail'.trns(),
                controller: controller.addCustomerEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                height: 52,
                hintTextSize: 13,
              ),
              const SizedBox(height: 24),

              MainBtn(
                text: 'createBooking.addCustomer.addNow'.trns(),
                onPressed: controller.addCustomer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}