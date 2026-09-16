import 'package:get/get.dart';

import '../controllers/customers_controller.dart';
import '../repositories/customer_repository.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerRepository>(() => CustomerRepository());
    Get.lazyPut<CustomersController>(
      () => CustomersController(repository: Get.find<CustomerRepository>()),
    );
  }
}
