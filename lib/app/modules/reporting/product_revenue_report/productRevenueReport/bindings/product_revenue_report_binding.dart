import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/controllers/product_revenue_report_controller.dart';

class ProductRevenueReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRevenueReportController>(
      () => ProductRevenueReportController(),
    );
  }
}