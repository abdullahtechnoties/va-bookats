import 'package:get/get.dart';

import '../controllers/revenue_report_controller.dart';

class RevenueReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RevenueReportController>(
      () => RevenueReportController(),
    );
  }
}
