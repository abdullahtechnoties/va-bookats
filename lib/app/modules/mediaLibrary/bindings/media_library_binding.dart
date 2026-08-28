import 'package:get/get.dart';

import '../controllers/media_library_controller.dart';

class MediaLibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaLibraryController>(
      () => MediaLibraryController(),
    );
  }
}
