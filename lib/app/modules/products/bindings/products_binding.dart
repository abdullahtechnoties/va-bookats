import 'package:get/get.dart';
import 'package:va_bookats/app/modules/products/controllers/products_controller.dart';
import 'package:va_bookats/app/modules/products/repositories/product_repository.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<ProductsController>(
      () => ProductsController(repository: Get.find<ProductRepository>()),
    );
  }
}
