// lib/app/modules/service_categories/controllers/service_categories_controller.dart

import 'package:get/get.dart';

class ServiceCategoryModel {
  final String id;
  final String name;
  final String branch;
  final String status;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.branch,
    required this.status,
  });
}

class ServiceCategoriesController extends GetxController {
  final RxList<ServiceCategoryModel> categories = <ServiceCategoryModel>[
    const ServiceCategoryModel(
      id: '1',
      name: 'Hair Color',
      branch: 'Branch Name',
      status: 'Active',
    ),
    const ServiceCategoryModel(
      id: '2',
      name: 'Hair Style',
      branch: 'Branch Name',
      status: 'Active',
    ),
    const ServiceCategoryModel(
      id: '3',
      name: 'Hair Extension',
      branch: 'Branch Name',
      status: 'Active',
    ),
  ].obs;

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
  }

  void onFilter() {
    // TODO: open filter sheet
  }
}