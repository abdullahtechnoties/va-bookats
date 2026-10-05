import 'package:get/get.dart';

import '../controllers/add_new_payment_controller.dart';

class AddNewPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddNewPaymentController>(
      () => AddNewPaymentController(),
    );
  }
}
