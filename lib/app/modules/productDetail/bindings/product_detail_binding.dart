import 'package:get/get.dart';
import 'package:va_bookats/app/modules/productDetail/controllers/product_detail_controller.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailController>(
      () => ProductDetailController(),
    );
  }
}
