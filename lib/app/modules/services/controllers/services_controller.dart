// lib/app/modules/services/controllers/services_controller.dart

import 'package:get/get.dart';

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String branch;
  final String duration;
  final String price;
  final String status;
  final String imageUrl;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.branch,
    required this.duration,
    required this.price,
    required this.status,
    required this.imageUrl,
  });
}

class ServicesController extends GetxController {
  final RxInt selectedTab = 0.obs;

  final RxList<ServiceModel> activeServices = <ServiceModel>[
    const ServiceModel(
      id: '1',
      name: 'Service Name Here',
      category: 'Hair Color',
      branch: 'Branch Name Here',
      duration: '30 Minutes',
      price: '999',
      status: 'Active',
      imageUrl: '',
    ),
    const ServiceModel(
      id: '2',
      name: 'Service Name Here',
      category: 'Hair Color',
      branch: 'Branch Name Here',
      duration: '30 Minutes',
      price: '999',
      status: 'Active',
      imageUrl: '',
    ),
    const ServiceModel(
      id: '3',
      name: 'Service Name Here',
      category: 'Hair Style',
      branch: 'Branch Name Here',
      duration: '45 Minutes',
      price: '1299',
      status: 'Active',
      imageUrl: '',
    ),
  ].obs;

  final RxList<ServiceModel> inactiveServices = <ServiceModel>[
    const ServiceModel(
      id: '4',
      name: 'Inactive Service',
      category: 'Hair Extension',
      branch: 'Branch Name Here',
      duration: '60 Minutes',
      price: '2000',
      status: 'Inactive',
      imageUrl: '',
    ),
  ].obs;

  List<ServiceModel> get currentServices =>
      selectedTab.value == 0 ? activeServices : inactiveServices;

  void deleteService(String id) {
    activeServices.removeWhere((s) => s.id == id);
    inactiveServices.removeWhere((s) => s.id == id);
  }

  void onFilter() {
    // TODO: open filter sheet
  }
}