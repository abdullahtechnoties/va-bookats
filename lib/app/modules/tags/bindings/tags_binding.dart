import 'package:get/get.dart';
import 'package:va_bookats/app/modules/tags/controllers/tags_controller.dart';

class TagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagsController>(
      () => TagsController(),
    );
  }
}
