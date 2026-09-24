import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/profile/controllers/profile_controller.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
        child: Column(
          children: [
            _ProfileMenuTile(
              icon: Icons.person_rounded,
              label: 'profile.personalInfo'.trns(),
              onTap: () => Get.toNamed(Routes.PERSONAL_INFO),
            ),
            const SizedBox(height: 14),
            _ProfileMenuTile(
              icon: Icons.lock_rounded,
              label: 'profile.updatePassword'.trns(),
              onTap: () => Get.toNamed('/update-password'),
            ),
            const SizedBox(height: 14),
            _ProfileMenuTile(
              icon: Icons.logout_rounded,
              label: 'profile.logout'.trns(),
              iconColor: AppColors.red,
              labelColor: AppColors.red,
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      AlertDialog(
        title: Text('profile.logoutTitle'.trns()),
        content: Text('profile.logoutMessage'.trns()),
        actions: [
          TextButton(onPressed: Get.back, child: Text('profile.cancel'.trns())),
          Obx(
            () => TextButton(
              onPressed: AuthService.isLogoutInProgress
                  ? null
                  : () async {
                      await AuthService.forceLogout(showLogin: false);
                      if (Get.isDialogOpen == true) Get.back();
                      Get.offAllNamed(Routes.LOGIN);
                    },
              child: AuthService.isLogoutInProgress
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('profile.confirmLogout'.trns()),
            ),
          ),
        ],
      ),
      barrierDismissible: AuthService.isLogoutInProgress ? false : true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 60,
      // leading: Padding(
      //   padding: const EdgeInsets.only(left: 16),
      //   child: GestureDetector(
      //     onTap: () => Get.back(),
      //     child: const Icon(
      //       Icons.chevron_left,
      //       color: AppColors.white,
      //       size: 28,
      //     ),
      //   ),
      // ),
      title: Text(
        'profile.title'.trns(),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Profile menu tile ─────────────────────────────────────────────────────────
class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primary,
    this.labelColor = AppColors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
