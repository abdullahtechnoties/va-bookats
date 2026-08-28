import 'package:get/get.dart';

import '../controllers/packages_controller.dart';
import '../repositories/package_repository.dart';

class PackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageRepository>(
      () => PackageRepository(),
    );
    Get.lazyPut<PackagesController>(
      () => PackagesController(repository: Get.find<PackageRepository>()),
    );
  }
}