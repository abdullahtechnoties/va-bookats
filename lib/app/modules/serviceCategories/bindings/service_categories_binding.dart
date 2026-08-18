import 'package:get/get.dart';

import 'package:va_bookats/app/modules/serviceCategories/controllers/service_categories_controller.dart';
import 'package:va_bookats/app/modules/serviceCategories/repositories/service_category_repository.dart';

class ServiceCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceCategoryRepository>(
      () => ServiceCategoryRepository(),
    );
    Get.lazyPut<ServiceCategoriesController>(
      () => ServiceCategoriesController(repository: Get.find<ServiceCategoryRepository>()),
    );
  }
}
