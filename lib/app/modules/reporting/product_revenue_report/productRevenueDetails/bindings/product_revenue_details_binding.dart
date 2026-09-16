import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueDetails/controllers/product_revenue_details_controller.dart';

class ProductRevenueDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRevenueDetailsController>(
      () => ProductRevenueDetailsController(),
    );
  }
}