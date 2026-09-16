import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReport/controller/package_revenue_report_controller.dart';

class PackageRevenueReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageRevenueReportController>(
      () => PackageRevenueReportController(),
    );
  }
}