import 'package:get/get.dart';
import 'package:va_bookats/app/modules/units/controllers/units_controller.dart';

class UnitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnitsController>(
      () => UnitsController(),
    );
  }
}
