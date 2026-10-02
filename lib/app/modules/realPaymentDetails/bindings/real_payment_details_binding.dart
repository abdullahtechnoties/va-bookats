import 'package:get/get.dart';

import '../controllers/payment_details_controller.dart';

class RealPaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RealPaymentDetailsController>(
      () => RealPaymentDetailsController(),
    );
  }
}
