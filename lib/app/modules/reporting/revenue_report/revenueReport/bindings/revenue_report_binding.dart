import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/revenue_report/revenueReport/service/revenue_service.dart';

import '../controllers/revenue_report_controller.dart';

class RevenueReportBinding extends Bindings {
  @override
  void dependencies() {
        // Register report service if not already registered
    if (!Get.isRegistered<ReportService>()) {
      Get.lazyPut<ReportService>(() => ReportService());
    }
    Get.lazyPut<RevenueReportController>(
      () => RevenueReportController(),
    );
  }
}
