// lib/app/modules/service_revenue_report/bindings/service_revenue_details_binding.dart

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueDetails/controller/service_revenue_details_controller.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/controller/service_revenue_service.dart';


class ServiceRevenueDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceRevenueService>(() => ServiceRevenueService());
    Get.lazyPut<ServiceRevenueDetailsController>(
      () => ServiceRevenueDetailsController(),
    );
  }
}