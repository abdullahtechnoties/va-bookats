// lib/app/modules/customers/controllers/customers_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/customers/views/widgets/customer-card.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:va_bookats/widgets/Global-Widgets/filter-bottom-sheet.dart';

class CustomersController extends GetxController {
  final RxList<CustomerModel> customers = <CustomerModel>[
    const CustomerModel(
      id: '1',
      name: 'Ali Raza',
      phone: '0312-3456789',
      status: 'Active',
      branch: 'Branch Name Here',
      shift: 'Afternoon',
      designation: 'Designation Here',
      email: 'demo@owner.com',
      address: 'Pakistan,sindh,karachi',
      imageUrl: '',
    ),
    const CustomerModel(
      id: '2',
      name: 'Ali Raza',
      phone: '0312-3456789',
      status: 'Active',
      branch: 'Branch Name Here',
      shift: 'Afternoon',
      designation: 'Designation Here',
      email: 'demo@owner.com',
      address: 'Pakistan,sindh,karachi',
      imageUrl: '',
    ),
    const CustomerModel(
      id: '3',
      name: 'Sara Khan',
      phone: '0321-9876543',
      status: 'Active',
      branch: 'Main Branch',
      shift: 'Morning',
      designation: 'Senior Stylist',
      email: 'sara@owner.com',
      address: 'Pakistan,Punjab,Lahore',
      imageUrl: '',
    ),
    const CustomerModel(
      id: '4',
      name: 'Ahmed Ali',
      phone: '0333-1234567',
      status: 'Inactive',
      branch: 'Branch B',
      shift: 'Evening',
      designation: 'Junior Stylist',
      email: 'ahmed@owner.com',
      address: 'Pakistan,KPK,Peshawar',
      imageUrl: '',
    ),
  ].obs;

  final int totalCustomers = 142;

  // Date range display
  final RxString displayDateRange = 'Aug/1/2026 - Aug/1/2026'.obs;

  // Filter state
  final TextEditingController fromDateCtrl =
      TextEditingController(text: 'Aug/1/2026');
  final TextEditingController toDateCtrl =
      TextEditingController(text: 'Aug/1/2026');
  final TextEditingController branchFilterCtrl =
      TextEditingController(text: 'All Branches');
  final TextEditingController statusFilterCtrl =
      TextEditingController(text: 'Active');
  final TextEditingController countryFilterCtrl =
      TextEditingController(text: 'All Country');

  final RxString selectedBranchFilter = 'All Branches'.obs;
  final RxString selectedStatusFilter = 'Active'.obs;
  final RxString selectedCountryFilter = 'All Country'.obs;

  final List<String> branchOptions = [
    'All Branches',
    'Branch A',
    'Branch B',
    'Branch C',
  ];
  final List<String> statusOptions = ['Active', 'Inactive', 'All'];
  final List<String> countryOptions = [
    'All Country',
    'Pakistan',
    'UAE',
    'Saudi Arabia',
    'UK',
  ];

  void resetFilter() {
    fromDateCtrl.text = 'Aug/1/2026';
    toDateCtrl.text = 'Aug/1/2026';
    branchFilterCtrl.text = 'All Branches';
    statusFilterCtrl.text = 'Active';
    countryFilterCtrl.text = 'All Country';
    selectedBranchFilter.value = 'All Branches';
    selectedStatusFilter.value = 'Active';
    selectedCountryFilter.value = 'All Country';
    displayDateRange.value = 'Aug/1/2026 - Aug/1/2026';
  }

  void applyFilter() {
    displayDateRange.value =
        '${fromDateCtrl.text} - ${toDateCtrl.text}';
    // TODO: implement actual filtering
  }

  void openFilter(BuildContext context) {
    FilterBottomSheet.show(
      context,
      fields: [
        FilterField(
          label: 'customers.filter.fromDate'.trns(),
          type: FilterFieldType.date,
          controller: fromDateCtrl,
        ),
        FilterField(
          label: 'customers.filter.toDate'.trns(),
          type: FilterFieldType.date,
          controller: toDateCtrl,
        ),
        FilterField(
          label: 'customers.filter.branches'.trns(),
          type: FilterFieldType.dropdown,
          controller: branchFilterCtrl,
          dropdownItems: branchOptions,
          selectedValue: selectedBranchFilter,
        ),
        FilterField(
          label: 'customers.filter.status'.trns(),
          type: FilterFieldType.dropdown,
          controller: statusFilterCtrl,
          dropdownItems: statusOptions,
          selectedValue: selectedStatusFilter,
        ),
        FilterField(
          label: 'customers.filter.country'.trns(),
          type: FilterFieldType.dropdown,
          controller: countryFilterCtrl,
          dropdownItems: countryOptions,
          selectedValue: selectedCountryFilter,
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
    statusFilterCtrl.dispose();
    countryFilterCtrl.dispose();
    super.onClose();
  }
}