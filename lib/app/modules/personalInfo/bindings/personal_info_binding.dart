import 'package:get/get.dart';
import 'package:va_bookats/app/modules/personalInfo/repositories/profile_repository.dart';
import '../controllers/personal_info_controller.dart';

class PersonalInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepository());
    Get.lazyPut<PersonalInfoController>(
      () => PersonalInfoController(repository: Get.find<ProfileRepository>()),
    );
  }
}
