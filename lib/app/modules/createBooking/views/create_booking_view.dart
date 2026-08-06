// lib/app/modules/create_booking/views/create_booking_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/createBooking/controllers/create_booking_controller.dart';
import 'package:va_bookats/app/modules/createBooking/views/step1.dart';
import 'package:va_bookats/app/modules/createBooking/views/step2.dart';
import 'package:va_bookats/app/modules/createBooking/views/step3.dart';
import 'package:va_bookats/app/modules/createBooking/views/step4.dart';
import 'package:va_bookats/app/modules/createBooking/views/step5.dart';
import 'package:va_bookats/app/modules/createBooking/views/widgets/booking_stepper_view.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class CreateBookingView extends GetView<CreateBookingController> {
  const CreateBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CreateBookingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── Orange Header ──────────────────────────────────────────────
          _CreateBookingHeader(controller: controller),

          // ── Stepper + Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stepper
                  Obx(
                    () => BookingStepper(
                      currentStep: controller.currentStep.value,
                      totalSteps: CreateBookingController.totalSteps,
                      onStepTapped: controller.goToStep,
                    ),
                  ),

                  // Step Content
                  Obx(() => _buildStepContent(controller.currentStep.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    // Determine which step to show based on selected service type
    // Step 0 → Booking Info
    // Step 1 → Packages / Services / Products (based on selection)
    // Step 2,3 → additional steps in flow
    // Step 4 → Payment

    switch (step) {
      case 0:
        return const Step1BookingInfo();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return const Step5Payment();
      default:
        return const Step1BookingInfo();
    }
  }

  Widget _buildStep2() {
    // Step 2 shows Packages by default based on the service type selected
    // But since all 3 (package/service/product) go through steps 2,3,4
    // and payment is always step 5, we show the correct form here
    // For this design all three forms exist as separate steps
    return const Step2Packages();
  }

  Widget _buildStep3() {
    return const Step3Services();
  }

  Widget _buildStep4() {
    return const Step4Products();
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _CreateBookingHeader extends StatelessWidget {
  final CreateBookingController controller;

  const _CreateBookingHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: controller.previousStep,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  'createBooking.title'.trns(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}