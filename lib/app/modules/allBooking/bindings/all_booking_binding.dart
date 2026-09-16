import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';

import '../controllers/all_booking_controller.dart';

class AllBookingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    Get.lazyPut<AllBookingController>(
      () => AllBookingController(
          repository: Get.find<BookingRepository>()),
    );
  }
}
