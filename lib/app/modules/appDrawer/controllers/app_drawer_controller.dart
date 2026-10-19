import 'package:get/get.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';

class AppDrawerController extends GetxController {
  final RxBool isBookingExpanded = false.obs;
  final RxBool isInventoryExpanded = false.obs;
  final RxBool isReportingExpanded = false.obs;

  void toggleBooking() => isBookingExpanded.value = !isBookingExpanded.value;
  void toggleInventory() =>
      isInventoryExpanded.value = !isInventoryExpanded.value;
  void toggleReporting() =>
      isReportingExpanded.value = !isReportingExpanded.value;

  /// Sub-items filtered by Laravel permissions (empty section = hidden).
  List<String> get bookingSubItems {
    final items = <String>[];
    if (Permissions.can(AppPerm.index(AppPerm.bookings))) {
      items.add('All Bookings');
    }
    if (Permissions.can(AppPerm.create(AppPerm.bookings))) {
      items.add('Add Booking');
    }
    return items;
  }

  List<String> get inventorySubItems {
    final items = <String>[];
    if (Permissions.can(AppPerm.index(AppPerm.services))) {
      items.add('Services');
    }
    if (Permissions.can(AppPerm.index(AppPerm.serviceCategories))) {
      items.add('Service Categories');
    }
    if (Permissions.can(AppPerm.index(AppPerm.packages))) {
      items.add('Packages');
    }
    if (Permissions.can(AppPerm.index(AppPerm.products))) {
      items.add('Products');
    }
    if (Permissions.can(AppPerm.index(AppPerm.brands))) {
      items.add('Brands');
    }
    if (Permissions.can(AppPerm.index(AppPerm.productCategories))) {
      items.add('Product Categories');
    }
    if (Permissions.can(AppPerm.index(AppPerm.tags))) {
      items.add('Tags');
    }
    if (Permissions.can(AppPerm.index(AppPerm.units))) {
      items.add('Units');
    }
    if (Permissions.can(AppPerm.index(AppPerm.productVariations))) {
      items.add('Variations');
    }
    return items;
  }

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
