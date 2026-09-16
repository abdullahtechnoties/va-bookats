import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/app/modules/customers/repositories/customer_repository.dart';

import '../controllers/create_booking_controller.dart';

class CreateBookingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(() => CustomerRepository());
    }
    Get.lazyPut<CreateBookingController>(
      () => CreateBookingController(
        repository: Get.find<BookingRepository>(),
        customerRepository: Get.find<CustomerRepository>(),
      ),
    );
  }
}
