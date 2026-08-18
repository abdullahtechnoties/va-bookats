import 'package:get/get.dart';

import 'package:va_bookats/app/modules/services/controllers/services_controller.dart';
import 'package:va_bookats/app/modules/services/repositories/service_repository.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceRepository>(
      () => ServiceRepository(),
    );
    Get.lazyPut<ServicesController>(
      () => ServicesController(repository: Get.find<ServiceRepository>()),
    );
  }
}