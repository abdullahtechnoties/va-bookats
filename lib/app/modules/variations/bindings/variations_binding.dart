import 'package:get/get.dart';
import 'package:va_bookats/app/modules/variations/controllers/variations_controller.dart';

class VariationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VariationsController>(
      () => VariationsController(),
    );
  }
}
