import 'package:get/get.dart';

import '../../services/controllers/services_controller.dart';
import '../../services/repositories/service_repository.dart';
import '../controllers/bottomnav_controller.dart';

class BottomnavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomnavController>(
      () => BottomnavController(),
    );
    Get.lazyPut<ServiceRepository>(() => ServiceRepository());
    Get.lazyPut<ServicesController>(
      () => ServicesController(repository: Get.find<ServiceRepository>()),
    );
  }
}
