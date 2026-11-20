import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/daily_closings_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';

class DailyClosingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyClosingRepository>(() => DailyClosingRepository());
    Get.lazyPut<DailyClosingsController>(
      () => DailyClosingsController(
        repository: Get.find<DailyClosingRepository>(),
      ),
    );
  }
}
