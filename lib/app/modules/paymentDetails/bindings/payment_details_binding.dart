import 'package:get/get.dart';
import 'package:va_bookats/app/modules/revenueReport/service/revenue_service.dart';

import '../controllers/payment_details_controller.dart';

class PaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
        // Register report service if not already registered
    if (!Get.isRegistered<ReportService>()) {
      Get.lazyPut<ReportService>(() => ReportService());
    }
    Get.lazyPut<PaymentDetailsController>(
      () => PaymentDetailsController(),
    );
  }
}
