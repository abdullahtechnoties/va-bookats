// lib/app/modules/packages/controllers/packages_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';
import 'package:va_bookats/widgets/package-card.dart';

class PackagesController extends GetxController {
  final RxInt selectedTab = 0.obs;

  final RxList<PackageModel> activePackages = <PackageModel>[
    const PackageModel(
      id: '1',
      name: 'Package Name Here',
      branch: 'Branch Name Here',
      status: 'Active',
    ),
    const PackageModel(
      id: '2',
      name: 'Package Name Here',
      branch: 'Branch Name Here',
      status: 'Active',
    ),
    const PackageModel(
      id: '3',
      name: 'Package Name Here',
      branch: 'Branch Name Here',
      status: 'Active',
    ),
    const PackageModel(
      id: '4',
      name: 'Bridal Package',
      branch: 'Main Branch',
      status: 'Active',
    ),
  ].obs;

  final RxList<PackageModel> inactivePackages = <PackageModel>[
    const PackageModel(
      id: '5',
      name: 'Old Package A',
      branch: 'Branch B',
      status: 'Inactive',
    ),
    const PackageModel(
      id: '6',
      name: 'Old Package B',
      branch: 'Branch C',
      status: 'Inactive',
    ),
  ].obs;

  // Filter state
  final TextEditingController fromDateCtrl = TextEditingController(text: 'Aug/1/2026');
  final TextEditingController toDateCtrl = TextEditingController(text: 'Aug/1/2026');
  final TextEditingController branchFilterCtrl = TextEditingController(text: 'All Branches');
  final RxString selectedBranchFilter = 'All Branches'.obs;

  final List<String> branchFilterOptions = [
    'All Branches',
    'Branch A',
    'Branch B',
    'Branch C',
  ];

  List<PackageModel> get currentPackages =>
      selectedTab.value == 0 ? activePackages : inactivePackages;

  int get activeCount => activePackages.length;
  int get inactiveCount => inactivePackages.length;

  void deletePackage(String id) {
    activePackages.removeWhere((p) => p.id == id);
    inactivePackages.removeWhere((p) => p.id == id);
  }

  void resetFilter() {
    fromDateCtrl.text = 'Aug/1/2026';
    toDateCtrl.text = 'Aug/1/2026';
    branchFilterCtrl.text = 'All Branches';
    selectedBranchFilter.value = 'All Branches';
  }

  void applyFilter() {
    // TODO: implement actual filtering logic
  }

  void openFilter(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'packages.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'packages.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: 'packages.filter.branches'.trns(),
          type: FilterFieldType.dropdown,
          controller: branchFilterCtrl,
          dropdownItems: branchFilterOptions,
          selectedValue: selectedBranchFilter,
        ),
      ],
      onReset: resetFilter,
      onApply: applyFilter,
    );
  }

  @override
  void onClose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    branchFilterCtrl.dispose();
    super.onClose();
  }
}