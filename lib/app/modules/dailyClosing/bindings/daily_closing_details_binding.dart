import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/controllers/daily_closing_details_controller.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';

class DailyClosingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyClosingRepository>(() => DailyClosingRepository());
    Get.lazyPut<DailyClosingDetailsController>(
      () => DailyClosingDetailsController(
        repository: Get.find<DailyClosingRepository>(),
      ),
    );
  }
}
