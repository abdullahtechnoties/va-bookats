import 'package:get/get.dart';

import '../controllers/add_service_category_controller.dart';

class AddServiceCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddServiceCategoryController>(
      () => AddServiceCategoryController(),
    );
  }
}
