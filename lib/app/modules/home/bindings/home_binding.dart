import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/opening_balance_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    if (!Get.isRegistered<DailyClosingRepository>()) {
      Get.lazyPut<DailyClosingRepository>(() => DailyClosingRepository());
    }
    Get.lazyPut<OpeningBalanceController>(
      () => OpeningBalanceController(
        repository: Get.find<DailyClosingRepository>(),
      ),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(repository: Get.find<BookingRepository>()),
    );
  }
}
