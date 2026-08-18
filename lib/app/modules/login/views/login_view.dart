// lib/app/modules/login/views/login_view.dart

import 'package:va_bookats/app/modules/login/controllers/login_controller.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/common_text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/widgets/main_btn.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // ── Orange Header ──────────────────────────────────────────
          _buildHeader(context, isRtl),

          // ── White Card Body ────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'auth.login.title'.trns(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        'auth.login.subtitle'.trns(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email / Phone Field
                      _buildFloatingLabelField(
                        label: 'auth.login.loginLabel'.trns(),
                        child: CommonTextInputField(
                          hintText: 'auth.login.loginHint'.trns(),
                          controller: controller.loginController,
                          keyboardType: TextInputType.emailAddress,
                          height: 56,
                          hintTextSize: 14,
                          validator: controller.validateLogin,
                          autofillHints: const [AutofillHints.email],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Company Id Field
                      _buildFloatingLabelField(
                        label: 'auth.login.companyIdLabel'.trns(),
                        child: CommonTextInputField(
                          hintText: 'auth.login.companyIdHint'.trns(),
                          controller: controller.companyIdController,
                          keyboardType: TextInputType.text,
                          height: 56,
                          hintTextSize: 14,
                          validator: controller.validateCompanyId,
                          autofillHints: const [AutofillHints.organizationName],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildFloatingLabelField(
                        label: 'auth.login.passwordLabel'.trns(),
                        child: Obx(
                          () => CommonTextInputField(
                            hintText: 'auth.login.passwordHint'.trns(),
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            height: 56,
                            hintTextSize: 14,
                            validator: controller.validatePassword,
                            showSuffixIcon: true,
                            suffixIcon: GestureDetector(
                              onTap: controller.togglePasswordVisibility,
                              child: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password Row
                      _buildRememberForgotRow(context, isRtl),
                      const SizedBox(height: 28),

                      // Login Button
                      Obx(
                        () => MainBtn(
                          text: 'auth.login.loginBtn'.trns(),
                          onPressed: controller.login,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // // OR Divider
                      // _buildOrDivider(context),
                      // const SizedBox(height: 20),

                      // // Continue with Google
                      // _buildGoogleButton(context),
                      // const SizedBox(height: 28),

                      // // Sign Up Row
                      // _buildSignUpRow(context),
                      // const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header with back arrow + Bookats logo ──────────────────────────
  Widget _buildHeader(BuildContext context, bool isRtl) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Back button
            Align(
              alignment:
                  isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),

            // Bookats Logo
            _BookatsLogo(),
          ],
        ),
      ),
    );
  }

  // ── Floating label wrapper ─────────────────────────────────────────
  Widget _buildFloatingLabelField({
    required String label,
    required Widget child,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -9,
          left: 14,
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Remember Me & Forgot Password ─────────────────────────────────
  Widget _buildRememberForgotRow(BuildContext context, bool isRtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        Row(
          children: [
            Obx(
              () => GestureDetector(
                onTap: controller.toggleRememberMe,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: controller.rememberMe.value
                        ? AppColors.primary
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: controller.rememberMe.value
                          ? AppColors.primary
                          : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  ),
                  child: controller.rememberMe.value
                      ? const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 14,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'auth.login.rememberMe'.trns(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),

        // Forgot Password
        GestureDetector(
          onTap: controller.goToForgotPassword,
          child: Text(
            'auth.login.forgotPassword'.trns(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── OR Divider ─────────────────────────────────────────────────────
  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'auth.login.or'.trns(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
      ],
    );
  }

  // ── Google Button ──────────────────────────────────────────────────
  Widget _buildGoogleButton(BuildContext context) {
    return GestureDetector(
      onTap: controller.continueWithGoogle,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon
            _GoogleIcon(),
            const SizedBox(width: 12),
            Text(
              'auth.login.continueWithGoogle'.trns(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Don't have account row ─────────────────────────────────────────
  Widget _buildSignUpRow(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'auth.login.noAccount'.trns(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: controller.goToSignup,
                child: Text(
                  ' ${'auth.login.signUp'.trns()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bookats Logo Widget ────────────────────────────────────────────────
class _BookatsLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logow.png',
      width: 120,
      height: 40,
      fit: BoxFit.contain,
    );
  }
}

// ── Google Icon Painter ────────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Blue arc (top-right)
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.butt;

    // Red arc (top-left)
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.butt;

    // Yellow arc (bottom-left)
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.butt;

    // Green arc (bottom-right)
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(
        center: Offset(cx, cy), radius: r - size.width * 0.09);

    canvas.drawArc(rect, -1.1, 2.2, false, paintBlue);
    canvas.drawArc(rect, 1.1, 2.2, false, paintYellow);
    canvas.drawArc(rect, -2.1, 1.0, false, paintRed);
    canvas.drawArc(rect, 3.2, 1.0, false, paintGreen);

    // White horizontal bar (the G crossbar)
    final paintWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.18;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.85, cy),
      paintWhite,
    );

    // Blue horizontal bar
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.85, cy),
      paintBlue..strokeWidth = size.width * 0.17,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}