import 'package:get/get.dart';

import '../controllers/packages_controller.dart';

class PackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackagesController>(
      () => PackagesController(),
    );
  }
}
