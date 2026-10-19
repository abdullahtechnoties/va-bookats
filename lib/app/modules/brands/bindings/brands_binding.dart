import 'package:get/get.dart';
import 'package:va_bookats/app/modules/brands/controllers/brands_controller.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BrandsController>(
      () => BrandsController(),
    );
  }
}
