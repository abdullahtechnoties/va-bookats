import 'package:get/get.dart';
import 'package:va_bookats/app/modules/personalInfo/repositories/profile_repository.dart';
import '../controllers/update_password_controller.dart';

class UpdatePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepository());
    Get.lazyPut<UpdatePasswordController>(
      () => UpdatePasswordController(repository: Get.find<ProfileRepository>()),
    );
  }
}
