import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    Get.lazyPut<HomeController>(
      () => HomeController(repository: Get.find<BookingRepository>()),
    );
  }
}
