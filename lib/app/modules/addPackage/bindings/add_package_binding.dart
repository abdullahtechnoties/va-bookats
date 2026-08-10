import 'package:get/get.dart';

import '../controllers/add_package_controller.dart';

class AddPackageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPackageController>(
      () => AddPackageController(),
    );
  }
}
