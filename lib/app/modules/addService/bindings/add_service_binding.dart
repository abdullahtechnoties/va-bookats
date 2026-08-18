import 'package:get/get.dart';

import 'package:va_bookats/app/modules/addService/controllers/add_service_controller.dart';
import 'package:va_bookats/app/modules/services/repositories/service_repository.dart';

class AddServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceRepository>(
      () => ServiceRepository(),
    );
    Get.lazyPut<AddServiceController>(
      () => AddServiceController(repository: Get.find<ServiceRepository>()),
    );
  }
}