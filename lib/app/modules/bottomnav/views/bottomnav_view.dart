import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/appDrawer/views/app_drawer_view.dart';
import 'package:va_bookats/app/modules/allBooking/views/all_booking_view.dart';
import 'package:va_bookats/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:va_bookats/app/modules/profile/views/profile_view.dart';
import 'package:va_bookats/app/modules/services/views/services_view.dart';
import 'package:va_bookats/app/routes/app_pages.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
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
    label: 'Bookings',
    assetPath: 'assets/images/b2.png',
    activeAssetPath: 'assets/images/b2a.png',
  ),
  _NavItem(
    label: 'Services',
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
  const BottomnavView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevents default pop behavior unless allowed
      onPopInvokedWithResult: (popResult, isFinal) async {
        // Show confirmation dialog manually
        final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Exit'),
            backgroundColor: AppColors.white,
            content: const Text('Are you sure you want to exit?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            actions: [
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.primary,
                    style: BorderStyle.solid,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: AppColors.primary,
                    style: BorderStyle.solid
                    ),

                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  Get.back(result: false);
                },
                child: const Text('No', style: TextStyle(color: AppColors.primary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () async {
                  Get.back(result: true);
                },
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
          // If user confirmed, exit the app
   
    if (shouldExit == true) {
      SystemNavigator.pop(); // or exit(0);
    }
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        drawer: const AppDrawerView(),
        // backgroundColor: AppColors.primary,
        extendBody: true,
        body: Obx(
          () => IndexedStack(
            index: controller.tabIndex.value,
            children: _buildPages(),
          ),
        ),
        // Always visible so the bar keeps its shape; denied taps show a
        // graceful "no access" popup instead of navigating.
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () {
            if (!Permissions.can(AppPerm.create(AppPerm.bookings))) {
              showNoAccessDialog();
              return;
            }
            Get.toNamed(Routes.CREATE_BOOKING);
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
      ),
    );
  }

  /// Builds the tab pages, replacing any tab that has not been opened yet
  /// with an empty placeholder. GetX controllers are created lazily when the
  /// real page is first built (their bindings register them with
  /// `Get.lazyPut`), so API calls only start when the user opens the tab.
  List<Widget> _buildPages() {
    return List<Widget>.generate(BottomnavController.tabCount, (index) {
      if (!controller.isTabInitialized(index)) {
        return const SizedBox.shrink();
      }
      switch (index) {
        case 1:
          return const AllBookingView();
        case 2:
          return const ServicesView();
        case 3:
          return const ProfileView();
        case 0:
        default:
          return const HomeView();
      }
    });
  }

  /// Permission required to open a tab (`null` = always allowed).
  /// Tabs stay visible so the bar keeps its shape; denied taps show a
  /// graceful "no access" popup instead of navigating.
  String? _tabPermission(int index) {
    switch (index) {
      case 1:
        return AppPerm.index(AppPerm.bookings);
      case 2:
        return AppPerm.index(AppPerm.services);
      default:
        return null;
    }
  }

  // ignore: library_private_types_in_public_api
  Widget navItem(_NavItem icon, int index) {
    return Obx(() {
      final isSelected = controller.tabIndex.value == index;
      final _NavItem navItem = _navItems[index];
      return GestureDetector(
        onTap: () {
          final permission = _tabPermission(index);
          if (permission != null && !Permissions.can(permission)) {
            showNoAccessDialog();
            return;
          }
          controller.changeTabIndex(index);
        },
        child: Column(
          children: [
            Image.asset(
              fit: BoxFit.contain,
              height: 22,
              width: 22,
              isSelected ? navItem.activeAssetPath! : navItem.assetPath,
              // color:
              // isSelected ,
              // ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              navItem.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      );
    });
  }
}
