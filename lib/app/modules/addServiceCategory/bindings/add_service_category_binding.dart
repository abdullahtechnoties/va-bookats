import 'package:get/get.dart';

import 'package:va_bookats/app/modules/addServiceCategory/controllers/add_service_category_controller.dart';
import 'package:va_bookats/app/modules/serviceCategories/repositories/service_category_repository.dart';

class AddServiceCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceCategoryRepository>(
      () => ServiceCategoryRepository(),
    );
    Get.lazyPut<AddServiceCategoryController>(
      () => AddServiceCategoryController(repository: Get.find<ServiceCategoryRepository>()),
    );
  }
}
