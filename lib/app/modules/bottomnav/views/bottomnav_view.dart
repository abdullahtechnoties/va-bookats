import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/allBooking/controllers/all_booking_controller.dart';
import 'package:va_bookats/app/modules/appDrawer/views/app_drawer_view.dart';
import 'package:va_bookats/app/modules/allBooking/views/all_booking_view.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/modules/home/controllers/home_controller.dart';
import 'package:va_bookats/app/modules/payments/views/payments_view.dart';
import 'package:va_bookats/app/modules/profile/controllers/profile_controller.dart';
import 'package:va_bookats/app/modules/profile/views/profile_view.dart';
import 'package:va_bookats/app/modules/services/controllers/services_controller.dart';
import 'package:va_bookats/app/modules/services/repositories/service_repository.dart';
import 'package:va_bookats/app/modules/services/views/services_view.dart';
import 'package:va_bookats/utilities/colors.dart';
import '../../home/views/home_view.dart';



// ─────────────────────────────────────────────
//  Nav item model
// ─────────────────────────────────────────────
class _NavItem {
  final String label;
  final String assetPath; // e.g. 'assets/icons/home.png'
  final String?
  activeAssetPath; // optional, e.g. 'assets/icons/home_active.png'
  const _NavItem({
    required this.label,
    required this.assetPath,
    this.activeAssetPath,
  });
}

// ─────────────────────────────────────────────
//  Nav items  –  swap assetPath values as needed
// ─────────────────────────────────────────────
const List<_NavItem> _navItems = [
  _NavItem(
    label: 'Home',
    assetPath: 'assets/images/b1.png',
    activeAssetPath: 'assets/images/b1a.png',
  ),
  _NavItem(
    label: 'My Bookings',
    assetPath: 'assets/images/b2.png',
    activeAssetPath: 'assets/images/b2a.png',
  ),
  _NavItem(
    label: 'Search',
    assetPath: 'assets/images/b3.png',
    activeAssetPath: 'assets/images/b3a.png',
  ),
  _NavItem(
    label: 'Profile',
    assetPath: 'assets/images/b4.png',
    activeAssetPath: 'assets/images/b4a.png',
  ),
];


class BottomnavView extends GetView<BottomnavController> {
  BottomnavView({super.key});

  final List<Widget> pages = [
    HomeView(),
    AllBookingView(),
    ServicesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final hcontroller = Get.put(HomeController());
    final lcontroller = Get.put(AllBookingController());
    final a = Get.put(ServicesController(repository:  Get.put(ServiceRepository())));
    final p = Get.put(ProfileController());
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const AppDrawerView(),
      backgroundColor: AppColors.primary,
      extendBody: true,
      body: Obx(
        () => IndexedStack(index: controller.tabIndex.value, children: pages),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Get.toNamed(Routes.HOME);
          // AuthServices.logout();
          // Get.offAllNamed(Routes.SPLASH);
        },
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: AppColors.white, size: 48),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0, -2), // Shadow position
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          elevation: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(_navItems[0], 0),
                navItem(_navItems[1], 1),
                const SizedBox(width: 40),
                navItem(_navItems[2], 2),
                navItem(_navItems[3], 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget navItem(_NavItem icon, int index) {
    return Obx(() {
      final isSelected = controller.tabIndex.value == index;
      final _NavItem navItem = _navItems[index];
      return GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        child: Image.asset(
          fit: BoxFit.contain,
          height: 22,
          width: 22,
          isSelected ? navItem.activeAssetPath! : navItem.assetPath,
          // color: 
          // isSelected ,
          // ? AppColors.primary : Colors.grey,
        ),
      );
    });
  }
}