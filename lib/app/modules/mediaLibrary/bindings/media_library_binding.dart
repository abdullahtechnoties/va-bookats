import 'package:get/get.dart';

import '../controllers/media_library_controller.dart';
import '../repositories/media_repository.dart';

class MediaLibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaRepository>(() => MediaRepository());
    Get.lazyPut<MediaLibraryController>(
      () => MediaLibraryController(
        repository: Get.find<MediaRepository>(),
      ),
    );
  }
}
