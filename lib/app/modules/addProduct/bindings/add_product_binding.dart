import 'package:get/get.dart';
import 'package:va_bookats/app/modules/addProduct/controllers/add_product_controller.dart';
import 'package:va_bookats/app/modules/addProduct/repositories/add_product_repository.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductRepository>(() => AddProductRepository());
    Get.lazyPut<AddProductController>(
      () => AddProductController(
        repository: Get.find<AddProductRepository>(),
      ),
    );
  }
}
