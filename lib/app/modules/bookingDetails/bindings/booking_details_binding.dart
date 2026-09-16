import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';

import '../controllers/booking_details_controller.dart';

class BookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    Get.lazyPut<BookingDetailsController>(
      () => BookingDetailsController(
          repository: Get.find<BookingRepository>()),
    );
  }
}
