import 'package:get/get.dart';

import '../controllers/booking_payment_details_controller.dart';

class BookingPaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingPaymentDetailsController>(
      () => BookingPaymentDetailsController(),
    );
  }
}
