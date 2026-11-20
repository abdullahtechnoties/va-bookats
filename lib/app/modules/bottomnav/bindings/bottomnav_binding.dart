import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/opening_balance_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';

import '../../allBooking/controllers/all_booking_controller.dart';
import '../../bookings/repositories/booking_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../services/controllers/services_controller.dart';
import '../../services/repositories/service_repository.dart';
import '../controllers/bottomnav_controller.dart';

class BottomnavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomnavController>(() => BottomnavController());

    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    if (!Get.isRegistered<ServiceRepository>()) {
      Get.lazyPut<ServiceRepository>(() => ServiceRepository());
    }
    if (!Get.isRegistered<DailyClosingRepository>()) {
      Get.lazyPut<DailyClosingRepository>(() => DailyClosingRepository());
    }
    if (!Get.isRegistered<OpeningBalanceController>()) {
      Get.lazyPut<OpeningBalanceController>(
        () => OpeningBalanceController(
          repository: Get.find<DailyClosingRepository>(),
        ),
      );
    }

    // Every tab controller is registered lazily and only created the first
    // time its tab is opened (see BottomnavController.isTabInitialized).
    // That keeps the startup API calls down to the visible tab only, while
    // the singleton instances stay alive for subsequent tab switches.
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(repository: Get.find<BookingRepository>()),
      );
    }
    if (!Get.isRegistered<AllBookingController>()) {
      Get.lazyPut<AllBookingController>(
        () => AllBookingController(repository: Get.find<BookingRepository>()),
      );
    }
    if (!Get.isRegistered<ServicesController>()) {
      Get.lazyPut<ServicesController>(
        () => ServicesController(repository: Get.find<ServiceRepository>()),
      );
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController());
    }
  }
}
