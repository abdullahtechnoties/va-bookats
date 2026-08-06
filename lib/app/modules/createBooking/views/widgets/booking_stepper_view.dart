// lib/app/modules/create_booking/widgets/booking_stepper.dart

import 'package:flutter/material.dart';
import 'package:va_bookats/utilities/colors.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int)? onStepTapped;

  const BookingStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? AppColors.secondary
                    : AppColors.secondary.withValues(alpha: 0.3),
              ),
            );
          } else {
            // Step circle
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isActive = stepIndex == currentStep;

            return GestureDetector(
              onTap: () => onStepTapped?.call(stepIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isActive || isCompleted)
                      ? AppColors.secondary
                      : AppColors.white,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: (isActive || isCompleted)
                          ? AppColors.white
                          : AppColors.secondary,
                    ),
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}