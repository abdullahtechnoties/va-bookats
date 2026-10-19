import 'package:get/get.dart';

import '../controllers/add_brand_controller.dart';

class AddBrandBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddBrandController>(
      () => AddBrandController(),
    );
  }
}
