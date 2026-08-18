// lib/app/modules/onboard/views/onboard_view.dart

import 'package:va_bookats/app/modules/onboard/controllers/onboard_controller.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/main_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardView extends GetView<OnboardController> {
  const OnboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Top orange section takes ~52% of screen height
    final topHeight = size.height * 0.52;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Full screen PageView ───────────────────────────────────
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.slides.length,
            itemBuilder: (context, index) {
              return _OnboardPage(
                slide: controller.slides[index],
                topHeight: topHeight,
              );
            },
          ),

          // ── Fixed bottom section ───────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSection(context, size),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, Size size) {
    return Obx(() {
      final slide = controller.slides[controller.currentPage.value];
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          bottom: MediaQuery.paddingOf(context).bottom + 20,
          top: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              slide['titleKey']!.trns(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Description
            Text(
              slide['descKey']!.trns(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Dot indicators
            _buildDotIndicators(),
            const SizedBox(height: 28),

            // Continue Button
            MainBtn(
              text: 'onboard.continue'.trns(),
              onPressed: controller.onContinue,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDotIndicators() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.slides.length,
          (index) {
            final isActive = controller.currentPage.value == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Single Onboard Page ─────────────────────────────────────────────────────
class _OnboardPage extends StatelessWidget {
  final Map<String, String> slide;
  final double topHeight;

  const _OnboardPage({
    required this.slide,
    required this.topHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Orange top with illustration placeholder ──────────────
        _buildOrangeTop(context),
        // White bottom (content rendered by parent fixed section)
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildOrangeTop(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      height: topHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Illustration placeholder ────────────────────────
            Center(
              child: _IllustrationPlaceholder(
                imagePath: slide['image']!,
                size: size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Illustration Placeholder ────────────────────────────────────────────────
class _IllustrationPlaceholder extends StatelessWidget {
  final String imagePath;
  final Size size;

  const _IllustrationPlaceholder({
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Try to load the asset; if it doesn't exist yet, show a styled placeholder
    return Container(
      width: size.width * 0.78,
      height: size.width * 0.78,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: size.width * 0.70,
          height: size.width * 0.70,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallback(size),
        ),
      ),
    );
  }

  Widget _buildFallback(Size size) {
    return Container(
      width: size.width * 0.55,
      height: size.width * 0.55,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.white,
        size: 60,
      ),
    );
  }
}