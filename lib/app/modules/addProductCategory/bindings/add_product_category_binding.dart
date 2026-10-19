import 'package:get/get.dart';

import '../controllers/add_product_category_controller.dart';

class AddProductCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductCategoryController>(
      () => AddProductCategoryController(),
    );
  }
}
