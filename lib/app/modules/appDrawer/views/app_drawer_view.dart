import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/appDrawer/controllers/app_drawer_controller.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/app_cached_image.dart';

class AppDrawerView extends StatelessWidget {
  const AppDrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppDrawerController());

    return Drawer(
      backgroundColor: AppColors.white,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _DrawerExpandable(
                    icon: Icons.calendar_today_outlined,
                    label: 'drawer.booking'.trns(),
                    isExpanded: controller.isBookingExpanded,
                    onTap: controller.toggleBooking,
                    subItems: controller.bookingSubItems,
                    onSubItemTap: (item) {
                      Get.find<BottomnavController>().closeDrawer();
                      // Navigate accordingly
                    },
                  ),
                  _DrawerExpandable(
                    icon: Icons.credit_card_outlined,
                    label: 'drawer.inventory'.trns(),
                    isExpanded: controller.isInventoryExpanded,
                    onTap: controller.toggleInventory,
                    subItems: controller.inventorySubItems,
                    onSubItemTap: (item) {
                      Get.find<BottomnavController>().closeDrawer();
                      if(item == "Services") {
                        // controller.inventorySubItems[0] == null;
                        // Get.toNamed(Routes.SERVICES);
                        _openTab(2);
                        return;
                      } else if (item == "Service Categories"){
                        // controller
                        Get.toNamed(Routes.SERVICE_CATEGORIES);
                        return;
                      } else {
                        Get.toNamed(Routes.PACKAGES);
                      }
                    },
                  ),
                  _DrawerSimpleItem(
                    icon: Icons.groups_outlined,
                    label: 'drawer.customers'.trns(),
                    onTap: () {
                      Get.find<BottomnavController>().closeDrawer();
                    },
                  ),
                  _DrawerExpandable(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'drawer.reporting'.trns(),
                    isExpanded: controller.isReportingExpanded,
                    onTap: controller.toggleReporting,
                    subItems: controller.reportingSubItems,
                    onSubItemTap: (item) {
                      Get.find<BottomnavController>().closeDrawer();
                      _handleReportNavigation(item);
                    },
                  ),
                  _DrawerSimpleItem(
                    icon: Icons.person_outline_rounded,
                    label: 'drawer.profile'.trns(),
                    onTap: () {
                      _openTab(3);
                    },
                  ),
                  const SizedBox(height: 8),
                  // const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                  // const SizedBox(height: 8),
                  // _DrawerSimpleItem(
                  //   icon: Icons.home_outlined,
                  //   label: 'Home',
                  //   onTap: () => _openTab(0),
                  // ),
                  // _DrawerSimpleItem(
                  //   icon: Icons.calendar_month_outlined,
                  //   label: 'My Bookings',
                  //   onTap: () => _openTab(1),
                  // ),
                  // _DrawerSimpleItem(
                  //   icon: Icons.search_outlined,
                  //   label: 'Search',
                  //   onTap: () => _openTab(2),
                  // ),
                  // _DrawerSimpleItem(
                  //   icon: Icons.person_outline_rounded,
                  //   label: 'Profile',
                  //   onTap: () => _openTab(3),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTab(int index) {
    Get.find<BottomnavController>().changeTabIndex(index);
    Get.find<BottomnavController>().closeDrawer();
  }

  void _handleReportNavigation(String item) {
    switch (item) {
      case 'Branch Comparison':
        Get.toNamed('/revenue-report',
            arguments: {'title': 'revenue.branchComparison'});
        break;
      case 'Revenue Report':
        Get.toNamed('/revenue-report',
            arguments: {'title': 'revenue.title'});
        break;
      default:
        Get.toNamed('/revenue-report',
            arguments: {'title': item});
    }
  }

  Widget _buildHeader(BuildContext context, AppDrawerController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipOval(
            child: AppCachedImage(
              imageUrl: controller.userAvatar,
              width: 64,
              height: 64,
              fallbackAsset: 'assets/images/placeholder.png',
            ),
          ),
          const SizedBox(width: 12),
          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  controller.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.userRole,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () => Get.back(),
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.close, color: AppColors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expandable Drawer Item ───────────────────────────────────────────────────
class _DrawerExpandable extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxBool isExpanded;
  final VoidCallback onTap;
  final List<String> subItems;
  final void Function(String) onSubItemTap;

  const _DrawerExpandable({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
    required this.subItems,
    required this.onSubItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = isExpanded.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DrawerItemTile(
            icon: icon,
            label: label,
            trailing: Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: AppColors.black,
            ),
            isExpanded: expanded,
            onTap: onTap,
          ),
          if (expanded)
            Container(
              // color: const Color(0xFFF3F4F6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subItems
                    .map(
                      (sub) => InkWell(
                        onTap: () => onSubItemTap(sub),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          child: Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      );
    });
  }
}

// ── Simple (non-expandable) Item ─────────────────────────────────────────────
class _DrawerSimpleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerSimpleItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _DrawerItemTile(
      icon: icon,
      label: label,
      onTap: onTap,
    );
  }
}

// ── Shared Tile ───────────────────────────────────────────────────────────────
class _DrawerItemTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isExpanded;
  final VoidCallback onTap;

  const _DrawerItemTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isExpanded ? const Color(0xFFF3F4F6) : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}