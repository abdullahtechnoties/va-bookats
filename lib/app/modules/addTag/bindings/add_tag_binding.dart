import 'package:get/get.dart';

import '../controllers/add_tag_controller.dart';

class AddTagBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTagController>(
      () => AddTagController(),
    );
  }
}
