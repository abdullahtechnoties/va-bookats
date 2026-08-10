import 'package:get/get.dart';

import '../controllers/service_categories_controller.dart';

class ServiceCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceCategoriesController>(
      () => ServiceCategoriesController(),
    );
  }
}
