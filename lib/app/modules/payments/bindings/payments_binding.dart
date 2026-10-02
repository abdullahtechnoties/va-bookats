import 'package:get/get.dart';
import 'package:va_bookats/app/modules/payments/repositories/payment_repository.dart';

import '../controllers/payments_controller.dart';

class PaymentsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.lazyPut<PaymentRepository>(() => PaymentRepository());
    }
    Get.lazyPut<PaymentsController>(
      () => PaymentsController(repository: Get.find<PaymentRepository>()),
    );
  }
}
