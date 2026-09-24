// lib/app/modules/customerReport/bindings/customer_report_binding.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/controller/customer_report_controller.dart';

class CustomerReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerReportController>(() => CustomerReportController());
  }
}
