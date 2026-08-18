import 'package:get/get.dart';

class AppDrawerController extends GetxController {
  final RxBool isBookingExpanded = false.obs;
  final RxBool isInventoryExpanded = false.obs;
  final RxBool isReportingExpanded = false.obs;

  // Dummy user data
  final String userName = 'Shahid Mirza';
  final String userRole = 'Admin';
  final String userAvatar = '';

  void toggleBooking() => isBookingExpanded.value = !isBookingExpanded.value;
  void toggleInventory() => isInventoryExpanded.value = !isInventoryExpanded.value;
  void toggleReporting() => isReportingExpanded.value = !isReportingExpanded.value;

  final List<String> bookingSubItems = [
    'All Bookings',
    'Add Booking',
  ];

  final List<String> inventorySubItems = [
    'Services',
    'Service Categories',
    'Packages',
  ];

  final List<String> reportingSubItems = [
    'Branch Comparison',
    'Revenue Report',
    'Services Revenue Report',
    'Products Revenue Report',
    'Packages Revenue Report',
    'Commissions Report',
    'Expenses Report',
    'Customers Report',
  ];
}