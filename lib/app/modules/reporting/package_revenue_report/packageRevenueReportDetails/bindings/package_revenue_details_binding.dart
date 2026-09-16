import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/package_revenue_report/packageRevenueReportDetails/controller/package_revenue_details_controller.dart';

class PackageRevenueDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageRevenueDetailsController>(
      () => PackageRevenueDetailsController(),
    );
  }
}