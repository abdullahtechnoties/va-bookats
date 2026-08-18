import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Image.asset("assets/images/splash_background.png", fit: BoxFit.fill,
          height: double.infinity, width: double.infinity
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.logoOpacity.value,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeIn,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.8,
                        end: controller.logoOpacity.value == 1.0 ? 1.0 : 0.8,
                      ),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        width: 240,
                        height: 240,
                        // decoration: BoxDecoration(
                        //   color: AppColors.white,
                        //   borderRadius: BorderRadius.circular(28),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: AppColors.primary.withValues(alpha: 0.2),
                        //       blurRadius: 30,
                        //       offset: const Offset(0, 10),
                        //     ),
                        //   ],
                        // ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Animated Tagline
                // Obx(
                //   () => AnimatedOpacity(
                //     opacity: controller.taglineOpacity.value,
                //     duration: const Duration(milliseconds: 600),
                //     curve: Curves.easeIn,
                //     child: Column(
                //       children: [
                //         Text(
                //           'Aroosi',
                //           style: TextStyle(
                //             fontSize: 32,
                //             fontWeight: FontWeight.bold,
                //             color: AppColors.primary,
                //             letterSpacing: 1.2,
                //           ),
                //         ),
                //         const SizedBox(height: 8),
                //         Text(
                //           'Your Wedding, Your Way',
                //           style: TextStyle(
                //             fontSize: 14,
                //             color: AppColors.onboardingMuted,
                //             letterSpacing: 0.5,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
