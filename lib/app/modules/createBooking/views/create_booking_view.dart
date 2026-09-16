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
    return Obx(() => PopScope(
          canPop: !controller.isSaving.value,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final mayPop = await controller.handleBack(context);
            if (mayPop && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Column(
              children: [
                // ── Orange Header ──────────────────────────────────────
                _CreateBookingHeader(controller: controller),

                // ── Stepper + Content ──────────────────────────────────
                Expanded(
                  child: controller.isLoadingDetail.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stepper
                              Obx(
                                () => BookingStepper(
                                  currentStep:
                                      controller.currentStep.value,
                                  totalSteps:
                                      CreateBookingController.totalSteps,
                                  onStepTapped: controller.goToStep,
                                ),
                              ),

                              // Step Content
                              Obx(() => _buildStepContent(
                                  controller.currentStep.value)),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const Step1BookingInfo();
      case 1:
        return const Step2Packages();
      case 2:
        return const Step3Services();
      case 3:
        return const Step4Products();
      case 4:
        return const Step5Payment();
      default:
        return const Step1BookingInfo();
    }
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
              Obx(() => IconButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final mayPop =
                                await controller.handleBack(context);
                            if (mayPop && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.white,
                      size: 20,
                    ),
                  )),
              Expanded(
                child: Obx(() => Text(
                      controller.isEditMode
                          ? 'Edit Booking'
                          : 'createBooking.title'.trns(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
              ),
              Obx(() => controller.isSaving.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const SizedBox(width: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
