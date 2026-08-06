import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color containerColor;
  final bool showBackBtn;
  final List<Widget>? actions;

  const ScreenAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor = AppColors.white,
    this.iconColor = AppColors.grey,
    this.containerColor = const Color(0xffF1F2F4),
    this.showBackBtn = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leadingWidth: 60,
      leading: showBackBtn
          ? Padding(
              padding: const EdgeInsets.only(left: 18),
              child: GestureDetector(
                onTap: onBackPressed ?? () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: containerColor,
                  ),
                  child: Icon(Icons.arrow_back, size: 17, color: iconColor),
                ),
              ),
            )
          : null,
      title: Text(title, style: AppTypography.mainTitle.copyWith(fontSize: 18)),
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
