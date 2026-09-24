// lib/app/modules/customerDetails/bindings/customer_details_binding.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReportDetails/controller/customer_details_controller.dart';

class CustomerDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerDetailsController>(() => CustomerDetailsController());
  }
}
