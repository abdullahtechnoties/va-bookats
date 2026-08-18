import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../repositories/login_repository.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginRepository>(() => LoginRepository());
    Get.lazyPut<LoginController>(
      () => LoginController(repository: Get.find<LoginRepository>()),
    );
  }
}
