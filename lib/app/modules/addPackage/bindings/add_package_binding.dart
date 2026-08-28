import 'package:get/get.dart';

import 'package:va_bookats/app/modules/packages/repositories/package_repository.dart';
import '../controllers/add_package_controller.dart';

class AddPackageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageRepository>(() => PackageRepository());
    Get.lazyPut<AddPackageController>(
      () => AddPackageController(repository: Get.find<PackageRepository>()),
    );
  }
}