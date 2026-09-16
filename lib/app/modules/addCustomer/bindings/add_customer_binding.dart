import 'package:get/get.dart';
import 'package:va_bookats/app/modules/customers/repositories/customer_repository.dart';

import '../controllers/add_customer_controller.dart';

class AddCustomerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomerRepository>()) {
      Get.lazyPut<CustomerRepository>(() => CustomerRepository());
    }
    Get.lazyPut<AddCustomerController>(
      () => AddCustomerController(repository: Get.find<CustomerRepository>()),
    );
  }
}
