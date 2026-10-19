import 'package:get/get.dart';

import '../controllers/add_variations_controller.dart';

class AddVariationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddVariationsController>(
      () => AddVariationsController(),
    );
  }
}
